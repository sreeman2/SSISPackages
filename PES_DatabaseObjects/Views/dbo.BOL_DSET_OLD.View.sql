/****** Object:  View [dbo].[BOL_DSET_OLD]    Script Date: 01/03/2013 19:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BOL_DSET_OLD]
AS
SELECT     b.T_NBR, b.SCAC AS CARRIER, b.VESSEL_NAME AS VESSELNAME, b.US_PORT AS PORTNAME, b.BL_NBR AS BOLNBR, 
                      b.FOREIGN_PORT AS FOREIGNPORT, CAST(b.WGT AS VARCHAR(20)) + ' ' + b.WGT_UNIT AS WEIGHT, '' AS receiptpoint, 
                      t_ffinaldest.NAME AS FFINALDEST, b.INBOND_ENTRY_TYPE AS INBOUNDCODE, b.VESSEL_FLAG AS VESSELCOUNTRY, 
                               b.VOYAGE_NBR AS VOYAGE, 
                      CONVERT(VARCHAR(10), b.ACT_ARR_DT, 101) AS ARRIVAL_DATE, CAST(b.MANIFEST_QTY AS VARCHAR(20)) 
                      + ' ' + b.MANIFEST_UNIT AS MANIFEST_QUANTITY, CAST(b.MEAS AS VARCHAR(20)) + ' ' + b.MEAS_UNIT AS MEASURE, 
                      t_usfinaldest.NAME AS USFINALDEST, b.VESSEL_CD AS LLOYSCODE, b.MANIFEST_NBR AS MANIFESTNBR, b.TRANS_MODE_CD AS TRANS_MODE, 
                      b.BATCH_ID, '' AS ORIG_BOL
FROM         dbo.BL_BL AS b LEFT OUTER JOIN
                      PES.dbo.REF_PORT AS t_usport ON b.US_PORT = t_usport.ID LEFT OUTER JOIN
                      PES.dbo.REF_PORT AS t_fport ON b.FOREIGN_PORT = t_fport.ID LEFT OUTER JOIN
                      PES.dbo.REF_PORT AS t_ffinaldest ON b.FP_DEST_CD = t_ffinaldest.ID LEFT OUTER JOIN
                      PES.dbo.REF_PORT AS t_usfinaldest ON b.CLEARING_PORT_CD = t_usfinaldest.ID
GO
