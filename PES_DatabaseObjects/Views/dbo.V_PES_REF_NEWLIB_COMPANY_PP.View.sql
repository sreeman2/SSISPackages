/****** Object:  View [dbo].[V_PES_REF_NEWLIB_COMPANY_PP]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_PES_REF_NEWLIB_COMPANY_PP]
AS
SELECT     Name, State, City, Zip, Address1, Country, Comp_ID, Comp_Nbr
FROM         dbo.PES_Ref_Company AS a
WHERE     (State NOT IN ('XX', 'ZZ'))
UNION ALL
SELECT     Name, State, City, Postal_cd, Addr_1, Cntry_cd, Comp_ID, Company_Nbr
FROM         dbo.PES_LIB_NEW_PTY AS a
WHERE     (State NOT IN ('XX', 'ZZ'))
GO
