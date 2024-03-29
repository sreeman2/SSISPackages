/****** Object:  StoredProcedure [dbo].[LOAD_MATCH_PTY_BOLS]    Script Date: 01/03/2013 19:48:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_MATCH_PTY_BOLS]
	-- Add the parameters for the stored procedure here
	@T_NBR NUMERIC(12,0),
	@PTY_ID NUMERIC(12,0)
AS
BEGIN
SET NOCOUNT ON;

---- [Pramod K] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
--  '@T_NBR='''+ CAST(@T_NBR AS VARCHAR(100))+''''
--+', @PTY_ID='''+CAST(@PTY_ID AS VARCHAR(100))+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'LOAD_MATCH_PTY_BOLS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@T_NBR='''+ CAST(@T_NBR AS VARCHAR(100))+''''
+', @PTY_ID='''+CAST(@PTY_ID AS VARCHAR(100))+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


    SELECT DISTINCT 
		tmp.str_pty_id, 
		tmp.comp_id as compid, 
		tmp.confidence as conf_factor, 
		tmp.company_nbr as compnbr, 
		tmp.name, 
		tmp.addr_1, 
		tmp.addr_2,
		tmp.city, tmp.state, 
		tmp.postal_cd as zip, 
		b.Piers_Country as Country, 
		-1 AS ClusterID 
    FROM PES.dbo.pes_transaction_match_pty AS tmp WITH (NOLOCK) 
    LEFT OUTER JOIN PES.dbo.REF_COUNTRY AS b WITH (NOLOCK) on tmp.cntry_cd = cast(b.joc_code as varchar(10))
    WHERE 
	( 
		 EXISTS ( SELECT COMP_ID FROM PES.dbo.PES_LIB_COMPANY WITH (NOLOCK) WHERE COMP_ID <> tmp.COMP_ID ) 
		AND ( tmp.BOL_ID = @T_NBR ) AND ( tmp.STR_PTY_ID = @PTY_ID )
	)
	ORDER BY tmp.CONFIDENCE DESC

-- [Pramod K] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
