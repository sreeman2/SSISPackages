/****** Object:  StoredProcedure [dbo].[spPES_REF_COMMODITY_HSCODE_JOCCODE_MATCHES]    Script Date: 01/03/2013 19:48:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Golbal Trade
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE PROCEDURE [dbo].[spPES_REF_COMMODITY_HSCODE_JOCCODE_MATCHES]
AS
BEGIN
		DECLARE @lastCreate datetime;
		DECLARE @createDate datetime;
		SET @lastCreate = (SELECT MAX(CreateDate) from [PES].[dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE] (NOLOCK));
		SET @createDate = GetDate();

		--Select a distinct list, based on the record's primary key of records 
		--from the commodity exception table that are complete and have been 
		--modified since the last run of the dictionary build or are not complete 
		--but have been created since the last run of the dictionary build.
		SELECT a.T_NBR T_NBR
			  ,a.CMD_SEQ_NBR CMD_SEQ_NBR
			  ,a.DQA_CMD_SEQ_NBR DQA_CMD_SEQ_NBR into #tmpIndex
		FROM dqa_cmds a (NOLOCK)
			 inner join CTRL_PROCESS_VOYAGE b (NOLOCK) ON a.T_NBR = b.T_NBR AND a.CMD_SEQ_NBR = b.CMD_SEQ_NBR
		WHERE a.dqa_desc not in ('','DELETE','NO COMMODITY','88','U','.','/','8','Y','*','+',']')
			  AND ISNULL(IS_DELETE, 'N') <> 'Y'
			  --AND ((b.COMPLETE_STATUS = 0 AND a.MODIFIED_DT > @lastCreate) OR (b.COMPLETE_STATUS <> 0 AND a.CREATED_DT > @lastCreate))  
			  AND (b.COMPLETE_STATUS <> 0)
		GROUP BY a.T_NBR
				,a.CMD_SEQ_NBR
				,a.DQA_CMD_SEQ_NBR

		--Grab the pertinent information from the commodity exception table.
		SELECT a.dqa_desc Description
			  ,dbo.GET_KEY(a.dqa_desc) CompressedDescription
			  ,a.cmd_cd HsCode
			  ,a.joc_code JocCode INTO #tmp
		FROM dqa_cmds a (NOLOCK)
			 INNER JOIN #tmpIndex b ON a.T_NBR = b.T_NBR AND a.CMD_SEQ_NBR = b.CMD_SEQ_NBR AND A.DQA_CMD_SEQ_NBR = B.DQA_CMD_SEQ_NBR;

		--Insert matches.
		INSERT INTO SCREEN_TEST.dbo.PES_REF_COMMODITY_HSCODE_JOCCODE_MATCH (Description
																		   ,CompressedDescription
																		   ,HsCode
																		   ,JocCode
																		   ,CreateDate)
		SELECT Description
			  ,CompressedDescription
			  ,HsCode
			  ,JocCode
			  ,@createDate
		FROM #tmp b
		WHERE EXISTS (SELECT 1 
					  FROM  [PES].[dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE] c (nolock) 
					  WHERE b.CompressedDescription = c.CompressedDescription);

		--Return match count.
		SELECT COUNT(*) AS MatchedRecs
		FROM #tmp a
		WHERE EXISTS (SELECT 1 
					  FROM  [PES].[dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE] b (nolock) 
					  WHERE a.CompressedDescription = b.CompressedDescription);

END
GO
