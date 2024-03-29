/****** Object:  View [dbo].[BOL_DSET]    Script Date: 01/03/2013 19:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BOL_DSET]
/*
Change History

Change Description: For AMS, display Port of Receipt in 'Receipt Point'. For non-AMS Feeds,
					display Destination City in 'Receipt Point'
					Refer UAT Defect 1815
Changes By: Cognizant, 21-July-2009
*/
AS
SELECT     b.BOL_ID, b.Carrier_Code AS CARRIER, 
b.Vessel_Name AS VESSELNAME, 
(CASE ISNULL(b.Discharge_Port,'') WHEN '' THEN b.port_of_departure ELSE b.Discharge_Port END)  AS PORTNAME, 
b.BOL_Number AS BOLNBR, 
(CASE ISNULL(b.Foreign_Loading_Port,'') WHEN '' THEN b.Port_Of_Destination ELSE b.Foreign_Loading_Port END) AS FOREIGNPORT, 
CAST(b.Weight AS VARCHAR(20)) + ' ' + b.Weight_Units AS WEIGHT, 

(CASE ISNULL(b.PLACE_OF_RECEIPT,'') WHEN '' THEN b.DESTINATION_CITY ELSE b.PLACE_OF_RECEIPT END) AS receiptpoint,

--t_rpoint.PORT_NAME AS receiptpoint,   
                   
t_ffinaldest.PORT_NAME AS FFINALDEST,
b.Inbound_Entry_Type AS INBOUNDCODE, 
b.Vessel_Country AS VESSELCOUNTRY,                     
b.Voyage_Number AS VOYAGE, 
CONVERT(char(10), CASE UPPER(SAILING_DATE) WHEN 'INVALID' THEN CONVERT(DATETIME,'1/1/1900') 									
				  ELSE  CONVERT(DATETIME, SUBSTRING(SAILING_DATE,5,4) + SUBSTRING(SAILING_DATE,1,4)) 
				   END, 101) AS ARRIVAL_DATE, 
                      
CAST(b.MFEST_Quantity AS VARCHAR(20)) + ' ' + b.MFEST_Units AS MANIFEST_QUANTITY, CAST(b.MEAS AS VARCHAR(20)) 
                      + ' ' + b.MEAS_UNITS AS MEASURE, t_usfinaldest.PORT_NAME AS USFINALDEST, b.Vessel_Code AS LLOYSCODE, 
                      b.Manifest_Number AS MANIFESTNBR, b.Mode_Transport AS TRANS_MODE, b.BATCH_ID AS BATCH_ID, '' AS ORIG_BOL, 
                      b.NVOSCAC_Code AS NVO_SCAC, b.Master_BOL_Data AS MST_BOL_DATA
FROM         PES.dbo.ARCHIVE_RAW_BOL AS b 
LEFT OUTER JOIN  PES.dbo.REF_PORT AS t_usport ON b.Discharge_Port = t_usport.CODE 
LEFT OUTER JOIN  PES.dbo.REF_PORT AS t_fport ON b.Foreign_Loading_Port = t_fport.CODE 
LEFT OUTER JOIN  PES.dbo.REF_PORT AS t_ffinaldest ON b.FOREIGN_PORT = t_ffinaldest.CODE 
LEFT OUTER JOIN  PES.dbo.REF_PORT AS t_usfinaldest ON b.US_DIST_PORT = t_usfinaldest.CODE 

--LEFT OUTER JOIN  PES.dbo.REF_PORT AS t_rpoint ON b.PLACE_OF_RECEIPT = t_rpoint.PORT_NAME
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[31] 4[23] 2[44] 3) )"
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
         Begin Table = "b"
            Begin Extent = 
               Top = 69
               Left = 327
               Bottom = 272
               Right = 537
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_usport"
            Begin Extent = 
               Top = 443
               Left = 69
               Bottom = 551
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_fport"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_ffinaldest"
            Begin Extent = 
               Top = 317
               Left = 437
               Bottom = 425
               Right = 602
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_usfinaldest"
            Begin Extent = 
               Top = 207
               Left = 766
               Bottom = 315
               Right = 931
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_rpoint"
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
      Begin ColumnWidths = 22
         Width = 284
         Width = 1500
         Width = 150' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BOL_DSET'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BOL_DSET'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BOL_DSET'
GO
