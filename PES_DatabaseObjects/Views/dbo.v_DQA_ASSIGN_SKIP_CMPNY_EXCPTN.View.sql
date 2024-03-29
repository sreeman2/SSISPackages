/****** Object:  View [dbo].[v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN]    Script Date: 01/03/2013 19:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN]
AS
SELECT     tlp.BOL_ID, dbl.VDate, dbl.LOAD_NBR, dbl.DAILY_LOAD_DT, dbl.DIR
FROM         PES.dbo.PES_TRANSACTIONS_LIB_PTY AS tlp WITH (NOLOCK) JOIN
                      dbo.DQA_BL AS dbl WITH (NOLOCK) ON tlp.BOL_ID = dbl.T_NBR JOIN
                      dbo.DQA_SKIPPED_STDN_BOL AS skip WITH (NOLOCK) ON skip.T_NBR = tlp.BOL_ID AND skip.STR_PTY_ID = tlp.STR_PTY_ID AND 
                      skip.DELETED = 0
WHERE     (tlp.Status = 'PENDING') AND (ISNULL(dbl.LOCKED_BY_USR, '') = '') AND (ISNULL(dbl.IS_DELETED, 'N') = 'N') AND 
                      (skip.PROCESS_NAME = 'COMPANY EXCEPTIONS')
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
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tlp"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 114
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "dbl"
            Begin Extent = 
               Top = 6
               Left = 462
               Bottom = 114
               Right = 672
            End
            DisplayFlags = 280
            TopColumn = 26
         End
         Begin Table = "skip"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 214
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
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN'
GO
