/****** Object:  View [dbo].[V_PES_LIB_NEW_PTY]    Script Date: 01/03/2013 19:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_PES_LIB_NEW_PTY]
AS
SELECT     STR_PTY_ID, BOL_ID, Comp_ID, Source, IS_USComp, Company_Nbr, Name, Addr_1, Addr_2, City, State, Cntry_cd, Postal_cd, Confidence, Status, 
                      Created_By, Created_Dt, Modified_By, Modified_Dt, Raw_Pty_Id
FROM         PES.dbo.PES_LIB_NEW_PTY WITH (NOLOCK)
GO
