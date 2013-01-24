/****** Object:  UserDefinedFunction [dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE_MATCHES]    Script Date: 01/03/2013 19:53:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Golbal Trade
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE_MATCHES] ()
RETURNS int
AS
BEGIN
	
DECLARE @recs int;
DECLARE @lastModified datetime;
SET @lastModified = (SELECT MAX(CreateDate) from [PES].[dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE] (NOLOCK));

WITH tmp_hsmatches AS 
(
	SELECT a.dqa_desc Description
		  ,dbo.GET_KEY(a.dqa_desc) CompressedDescription
		  ,a.cmd_cd HsCode
          ,a.joc_code JocCode
	FROM dqa_cmds a (NOLOCK)
         inner join CTRL_PROCESS_VOYAGE b (NOLOCK) ON a.T_NBR = b.T_NBR
	WHERE a.dqa_desc not in ('','DELETE','NO COMMODITY','88','U','.','/','8','Y','*','+',']')
		  AND ISNULL(IS_DELETE, 'N') <> 'Y'
		  AND ((b.COMPLETE_STATUS = 1 AND a.MODIFIED_DT > @lastModified) OR (b.COMPLETE_STATUS = 0 AND a.CREATED_DT > @lastModified)) 
	GROUP BY a.dqa_desc,a.cmd_cd,a.joc_code
)
SELECT @recs = COUNT(*)
FROM tmp_hsmatches a
WHERE EXISTS (SELECT 1 
			  FROM  [PES].[dbo].[PES_REF_COMMODITY_HSCODE_JOCCODE] b (nolock) 
			  WHERE a.CompressedDescription = b.CompressedDescription);

RETURN @recs


END
GO
