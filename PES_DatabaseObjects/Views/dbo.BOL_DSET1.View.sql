/****** Object:  View [dbo].[BOL_DSET1]    Script Date: 01/03/2013 19:49:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BOL_DSET1]
AS
SELECT     b.bol_id AS BOL_ID, b.carrier_code AS CARRIER, b.VESSEL_NAME AS VESSELNAME, 0 AS PORTNAME, b.BOL_NUMBER AS BOL_NUMBER, 
                      0 AS FOREIGNPORT, CAST(b.WEIGHT AS VARCHAR(20)) + ' ' + b.WEIGHT_UNITS AS WEIGHT, '' AS receiptpoint, 
					  --t_ffinaldest.NAME
					  '' AS FFINALDEST, b.INBOUND_ENTRY_TYPE AS INBOUNDCODE, b.VESSELFLAG AS VESSELCOUNTRY, 
					  b.VOYAGE_NUMBER AS VOYAGE, convert(char(10),CONVERT(datetime,b.SAILING_DATE),101) AS ARRIVAL_DATE,
                      --CONVERT(, b.SAILING_DATE, 101) AS ARRIVAL_DATE,
					  CAST(b.MFEST_QUANTITY AS VARCHAR(20)) + ' ' + b.MFEST_UNITS AS MANIFEST_QUANTITY, CAST(b.MEAS AS VARCHAR(20)) + ' ' + b.MEAS_UNITS AS MEASURE, 
				      -- t_usfinaldest.NAME 
					  NULL AS USFINALDEST, b.VESSEL_CODE AS LLOYSCODE, b.MANIFEST_NUMBER AS MANIFESTNBR, b.MODE_TRANSPORT AS TRANS_MODE, 
                      b.VENDOR_CODE AS BATCH_ID, '' AS ORIG_BOL FROM 
			          pes.dbo.archive_raw_bol AS b LEFT OUTER JOIN
                      PES.dbo.REF_PORT AS t_usport ON b.DISCHARGE_PORT = t_usport.CODE LEFT OUTER JOIN
                      PES.dbo.REF_PORT AS t_fport ON b.FOREIGN_LOADING_PORT = t_fport.CODE 
					  --LEFT OUTER JOIN PES.dbo.REF_PORT AS t_ffinaldest ON b.FP_DEST_CD = t_ffinaldest.ID 
                      --LEFT OUTER JOIN PES.dbo.REF_PORT AS t_usfinaldest ON b.CLEARING_PORT_CD = t_usfinaldest.ID
GO
