/****** Object:  View [dbo].[TI_VIEW_REF_PORT]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TI_VIEW_REF_PORT]
AS

SELECT ID,CODE,PORT_NAME,DEEPWATER_FLG,ACTIVE,MODIFIED_DT,MODIFIED_BY,IS_TMP,STATE,DELETED,COUNTRY,PIERS_NAME,PIERS_PORT_CODE,
IS_US_PORT,PORT_DESC,
(
	SELECT TOP 1 COUNTRY 
	FROM PES.DBO.REF_COUNTRY C  WITH (NOLOCK) 
	WHERE P.COUNTRY = C.PIERS_COUNTRY
	AND ISNULL(IS_MASTER,'N')='Y'
)AS COUNTRYL

FROM 
(
	SELECT RANK() OVER(PARTITION BY CODE ORDER BY ID) AS RANK,*
	FROM PES.DBO.REF_PORT R  WITH (NOLOCK) 	
)P
WHERE RANK=1
GO
