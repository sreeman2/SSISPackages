/****** Object:  View [dbo].[pes_dw_vocc_view]    Script Date: 01/08/2013 15:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[pes_dw_vocc_view]
AS
SELECT     a.BOL_ID, a.BILL_NUMBER, a.BILL_STATUS, a.DIRECTION, b.VDATE, b.BOL_QTY, b.REF_QTY_UNIT_ID, b.BOL_WGT, b.REF_WGT_UNIT_ID, 
                      b.BOL_MEAS, b.REF_MEAS_UNIT_ID, b.BOL_TEU, b.ORG_DEST_CITY, b.ORG_DEST_ST, b.SLINE_REF_ID, b.PORT_DEPART_REF_ID, 
                      b.PORT_ARRIVE_REF_ID, b.VESSEL_REF_ID, b.EST_VALUE, b.MANIFEST_NUMBER, b.ULTPORT_ID, b.CTRYCODE, b.VOYAGE, b.COMP_ID, 
                      b.FCOMP_ID, b.NTFCOMP_ID, b.SCAC, b.NVO_SCAC, b.REGISTRY_ID
FROM         dbo.PES_DW_MHR AS a WITH (nolock) INNER JOIN
                      PES_RAW.pes.dbo.PES_STG_BOL AS b WITH (nolock) ON a.BOL_ID = b.BOL_ID AND b.VDATE > '5/1/2010'
UNION ALL
SELECT     BOL_ID, BILL_NUMBER, BILL_STATUS, DIRECTION, VDATE, QUANTITY, QTY_UNIT_REF_ID, WEIGHT, WEIGHT_UNIT_REF_ID, MEASUREMENT, 
                      MEAS_UNIT_REF_ID, TEU, ORG_DEST_CITY, ORG_DEST_ST, SLINE_REF_ID, PORT_DEPART_REF_ID, PORT_ARRIVE_REF_ID, VESSEL_REF_ID, 
                      STND_EST_VALUE_DOLLAR, MANIFEST_NUMBER, ULTPORT_REF_ID, CTRYCODE, VOYAGE, CONGINEE_COMP_REF_ID, SHIPPER_COMP_REF_ID, 
                      NOTIFY_COMP_REF_ID, SCAC, NVO_SCAC, VESSEL_REGISTRY_COUNRTY_REF_ID
FROM         dbo.PES_DW_BOL AS b
WHERE     (MST_BOL_ID IS NULL) AND (VDATE > '5/1/2010')
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
         Configuration = "(H (4[30] 2[40] 3) )"
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
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'pes_dw_vocc_view'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'pes_dw_vocc_view'
GO
