/****** Object:  View [dbo].[PES_VW_EXCEPTION_COMPANY_INFO]    Script Date: 01/03/2013 19:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PES_VW_EXCEPTION_COMPANY_INFO] AS

Select	R.BOL_ID,
		R.Source,
		ISNULL(R.Name,'') as Raw_Name,
		ISNULL(R.Addr_1,'') as Raw_Addr1,				
		ISNULL(R.Addr_2,'') as Raw_Addr2,				
		ISNULL(R.Addr_3,'') as Raw_Addr3,	
		ISNULL (R.Addr_4,'') as Raw_Addr4,
		P.[str_pty_id] as [str_pty_id],
		'' as [Name],
	    '' AS Addr_1,
	    '' AS Addr_2,
	    '' as City, 
	    '' AS State, 
	    '' as Zip
from PES.DBO.Raw_Pty R WITH (NOLOCK)  
JOIN PES.DBO.PES_Transactions_Exceptions_pty P WITH (NOLOCK) 
ON R.BOL_ID=P.BOL_ID
AND R.Source=P.Source
GO
