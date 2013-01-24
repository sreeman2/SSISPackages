/****** Object:  View [dbo].[V_PES_REF_COMPANY_DETAIL]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_PES_REF_COMPANY_DETAIL]
AS
SELECT     TOP (100) PERCENT dbo.PES_Ref_Company.Comp_ID, dbo.PES_Ref_Company.Is_UsComp, dbo.PES_Ref_Company.Comp_Nbr, 
                      dbo.PES_Ref_Company.Duns_Number, dbo.PES_Ref_Company.Nbr_Shipments, dbo.PES_Ref_Company.Name, dbo.PES_Ref_Company.Address1, 
                      dbo.PES_Ref_Company.City, dbo.PES_Ref_Company.State, dbo.PES_Ref_Company.Zip, dbo.PES_Ref_Company.Country, 
                      dbo.PES_Ref_Company.Verified, dbo.PES_Ref_Company.Match_Flag, dbo.PES_Ref_Company.Created_By, dbo.PES_Ref_Company.Created_Dt, 
                      dbo.PES_Ref_Company.Modified_By, dbo.PES_Ref_Company.Modified_Dt, dbo.PES_Ref_Company_Detail.LastShipmentDate, 
                      dbo.PES_Ref_Company_Detail.AutoMatchDate, dbo.PES_Ref_Company_Detail.AgentMatchDate, dbo.PES_Ref_Company_Detail.MatchAgentId, 
                      dbo.PES_Ref_Company_Detail.MergeDate, dbo.PES_Ref_Company_Detail.MergeAgentId, dbo.PES_Ref_Company_Detail.ShipmentCount24Months, 
                      dbo.PES_Ref_Company_Detail.ShipmentCount12Months, dbo.PES_Ref_Company_Detail.CompanyUrl, dbo.PES_Ref_Company_Detail.CompanyEmail, 
                      dbo.PES_Ref_Company_Detail.CompanySic, dbo.PES_Ref_Company_Detail.CompanyPhone, dbo.PES_Ref_Company_Detail.CassValidDate, 
                      dbo.PES_Ref_Company_Detail.ExternalReferenceVerifyDate, dbo.PES_Ref_Company_Detail.ExternalReferenceSource, 
                      dbo.PES_Ref_Company_Detail.QualityClassScore, dbo.PES_Ref_Company_Detail.IsPiersCustomer, dbo.PES_Ref_Company_Detail.IsNvocc, 
                      dbo.PES_Ref_Company_Detail.ScacCode, dbo.PES_Ref_Company_Detail.IsFreightForwarder, dbo.PES_Ref_Company_Detail.YearStarted, 
                      dbo.PES_Ref_Company_Detail.NumberOfEmployees, dbo.PES_Ref_Company_Detail.IsPublicCompany, 
                      dbo.PES_Ref_Company_Detail.AnnualSalesDollars, dbo.PES_Ref_Company_Detail.NetIncomeDollars, 
                      dbo.PES_Ref_Company_Detail.MarketCapDollars, dbo.PES_Ref_Company_Detail.NaicsCode, dbo.PES_Ref_Company_Detail.FmcLicenseCode, 
                      dbo.PES_Ref_Company_Detail.UNLoCode, dbo.PES_Ref_Company_Detail.PublicCompanySymbol, dbo.PES_Ref_Company_Detail.NotesX, 
                      dbo.PES_Ref_Company_Detail.NotesX2, dbo.PES_Ref_Company_Detail.NotesX3, dbo.PES_Ref_Company.IsPersonalName
FROM         dbo.PES_Ref_Company_Detail RIGHT OUTER JOIN
                      dbo.PES_Ref_Company ON dbo.PES_Ref_Company_Detail.Comp_ID = dbo.PES_Ref_Company.Comp_ID
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -228
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PES_Ref_Company_Detail"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 574
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "PES_Ref_Company"
            Begin Extent = 
               Top = 6
               Left = 297
               Bottom = 343
               Right = 449
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_PES_REF_COMPANY_DETAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_PES_REF_COMPANY_DETAIL'
GO
