/****** Object:  View [dbo].[PES_VW_HIGH_MED_CONF_COMPANY_INFO]    Script Date: 01/03/2013 19:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PES_VW_HIGH_MED_CONF_COMPANY_INFO] AS

Select	R.BOL_ID,
		R.Source,
		R.Name as Raw_Name,
		ISNULL(R.Addr_1,'') as Raw_Addr1,				
		ISNULL(R.Addr_2,'') as Raw_Addr2,				
		ISNULL(R.Addr_3,'') as Raw_Addr3,	
		ISNULL (R.Addr_4,'') as Raw_Addr4,
		S.[str_pty_id],
		S.[Name],
	    ISNULL(S.[Addr_1],'') AS Addr_1,
	    ISNULL(S.[Addr_2],'') AS Addr_2,
	    ISNULL(S.[City],'') as City, 
	    ISNULL(S.[St],'') AS State, 
	    ISNULL(S.[Zip],'') as Zip
from PES.DBO.Raw_Pty R WITH (NOLOCK)  
JOIN PES.DBO.PES_STRUCTURED_PTY S  WITH (NOLOCK) 
ON R.BOL_ID=S.BOL_ID
AND R.Source=S.Source
GO
