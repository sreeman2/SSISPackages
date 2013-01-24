/****** Object:  View [dbo].[REP1NEW]    Script Date: 01/03/2013 19:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[REP1NEW]
AS
SELECT     DQA_OWNER_ID, DIR, SUBSTRING(HEREDT, 1, 10) AS REPDATE, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 00 THEN blcnt WHEN 01 THEN blcnt WHEN 02 THEN blcnt WHEN 03 THEN blcnt WHEN 04 THEN blcnt WHEN 05 THEN blcnt ELSE 0 END) 
                      AS BEF6AM, SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 06 THEN blcnt ELSE 0 END) AS AM6CNT, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 07 THEN blcnt ELSE 0 END) AS AM7CNT, SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 08 THEN blcnt ELSE 0 END) AS AM8CNT, 
                      SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 09 THEN blcnt ELSE 0 END) AS AM9CNT, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 10 THEN blcnt ELSE 0 END) AS AM10CNT, SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 11 THEN blcnt ELSE 0 END) AS AM11CNT, 
                      SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 12 THEN blcnt ELSE 0 END) AS PM12CNT, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 13 THEN blcnt ELSE 0 END) AS PM1CNT, SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 14 THEN blcnt ELSE 0 END) AS PM2CNT, 
                      SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 15 THEN blcnt ELSE 0 END) AS PM3CNT, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 16 THEN blcnt ELSE 0 END) AS PM4CNT, SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 17 THEN blcnt ELSE 0 END) AS PM5CNT, 
                      SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 18 THEN blcnt ELSE 0 END) AS PM6CNT, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 19 THEN blcnt ELSE 0 END) AS PM7CNT, SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 20 THEN blcnt WHEN 21 THEN blcnt WHEN 22 THEN blcnt WHEN 23 THEN blcnt WHEN 24 THEN blcnt ELSE 0 END) AS AFT7PM, SUM(BLCNT) 
                      AS TOTCNT, ROUND(SUM(BLCNT) / NULLIF ((CASE SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 00 THEN blcnt WHEN 01 THEN blcnt WHEN 02 THEN blcnt WHEN 03 THEN blcnt WHEN 04 THEN blcnt WHEN 05 THEN blcnt ELSE 0 END) 
                      WHEN 0 THEN 0 ELSE 1 END) + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 06 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 07 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 08 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 09 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 10 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 11 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 12 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 13 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 14 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 15 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 16 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 17 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 18 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) WHEN 19 THEN blcnt ELSE 0 END) WHEN 0 THEN 0 ELSE 1 END) 
                      + (CASE SUM(CASE SUBSTRING(heredt, 12, 2) 
                      WHEN 20 THEN blcnt WHEN 21 THEN blcnt WHEN 22 THEN blcnt WHEN 23 THEN blcnt WHEN 24 THEN blcnt ELSE 0 END) 
                      WHEN 0 THEN 0 ELSE 1 END), 0), 0) AS PERHOUR
FROM         dbo.SUMDQA
GROUP BY DQA_OWNER_ID, DIR, SUBSTRING(HEREDT, 1, 10)
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
         Begin Table = "SUMDQA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 218
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'REP1NEW'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'REP1NEW'
GO
