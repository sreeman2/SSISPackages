/****** Object:  View [dbo].[BOL_DSET_BKUP]    Script Date: 01/03/2013 19:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BOL_DSET_BKUP]
AS
SELECT     b.BOL_ID, b.Carrier_Code AS CARRIER, 
b.Vessel_Name AS VESSELNAME, 
(CASE ISNULL(b.Discharge_Port,'') WHEN '' THEN b.port_of_departure ELSE b.Discharge_Port END)  AS PORTNAME, 
b.BOL_Number AS BOLNBR, 
(CASE ISNULL(b.Foreign_Loading_Port,'') WHEN '' THEN b.Port_Of_Destination ELSE b.Foreign_Loading_Port END) AS FOREIGNPORT, 
CAST(b.Weight AS VARCHAR(20)) + ' ' + b.Weight_Units AS WEIGHT, 
t_rpoint.PORT_NAME AS receiptpoint,   
                   
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

LEFT OUTER JOIN  PES.dbo.REF_PORT AS t_rpoint ON b.PLACE_OF_RECEIPT = t_rpoint.PORT_NAME
GO
