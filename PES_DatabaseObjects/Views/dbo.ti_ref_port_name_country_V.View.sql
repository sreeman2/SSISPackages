/****** Object:  View [dbo].[ti_ref_port_name_country_V]    Script Date: 01/03/2013 19:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ti_ref_port_name_country_V]
AS
/*
Modification History: Cognizant, 25-Jan-2010
Change Description: Fetch Country Name from REF_COUNTRY table.
*/
SELECT ID,CODE,PORT_NAME,DEEPWATER_FLG,ACTIVE,MODIFIED_DT,MODIFIED_BY,IS_TMP,STATE,DELETED,COUNTRY,PIERS_NAME,PIERS_PORT_CODE,
IS_US_PORT,PORT_DESC,
--Changes by Cognizant, 25-Jan-2010, start
(
	SELECT TOP 1 COUNTRY 
	FROM PES.DBO.REF_COUNTRY C  WITH (NOLOCK) 
	WHERE P.COUNTRY = C.PIERS_COUNTRY
	AND ISNULL(IS_MASTER,'N') = 'Y'
)AS COUNTRYL
--Changes by Cognizant, 25-Jan-2010, end
FROM 
(
	SELECT RANK() OVER(PARTITION BY PIERS_NAME ORDER BY ID) AS RANK,*
	FROM PES.DBO.REF_PORT  WITH (NOLOCK) 	
	WHERE ISNULL(COUNTRY,'') <>''
)P
WHERE RANK=1
GO
