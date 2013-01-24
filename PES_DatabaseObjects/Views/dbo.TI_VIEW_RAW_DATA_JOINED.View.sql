/****** Object:  View [dbo].[TI_VIEW_RAW_DATA_JOINED]    Script Date: 01/03/2013 19:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TI_VIEW_RAW_DATA_JOINED]
AS
SELECT DISTINCT
BL_BL.BOL_ID AS T_NBR,

--Changes by Cognizant, 27-Jan-2010, start
BL_BL.BOL_NUMBER AS BL_NBR,

CASE ISNULL(BL_BL.CARRIER_CODE,'') 
WHEN '' THEN 'ZZZZ$'+CONVERT(VARCHAR, BL_BL.BOL_ID ) 
ELSE BL_BL.CARRIER_CODE+'$'+CONVERT(VARCHAR, BL_BL.BOL_ID ) 
END AS UNIQUE_BL_NBR,
--Changes by Cognizant, 27-Jan-2010, end

COALESCE(SCAC_ALIAS.CODE,BL_BL.CARRIER_CODE) AS X_SCAC,

--Changes by Cognizant, 18-Jan-2010, Defect 2763, Start
SCAC_ALIAS.CARRIER_DESC AS X_SCAC_NAME,
--SCAC_ALIAS.NAME AS X_SCAC_NAME,
--Changes by Cognizant, 18-Jan-2010, Defect 2763, End

BL_BL.VESSEL_CODE AS VESSEL_CD,
BL_BL.VESSEL_NAME,
CONVERT(CHAR(2),LEFT(BL_BL.VESSEL_COUNTRY,2)) AS VESSEL_FLAG,
BL_BL.VOYAGE_NUMBER AS VOYAGE_NBR,
/* Cognizant Changes, Start, 26-Oct-2009*/
CONVERT(DATETIME, SUBSTRING(BL_BL.SAILING_DATE,5,4) + SUBSTRING(BL_BL.SAILING_DATE,1,4))  AS EST_ARR_DT,
CONVERT(DATETIME, SUBSTRING(BL_BL.SAILING_DATE,5,4) + SUBSTRING(BL_BL.SAILING_DATE,1,4)) AS ACT_ARR_DT,
--COALESCE(DQA_VOYAGE.EST_ARRIVAL_DT,BL_BL.VDATE) AS EST_ARR_DT,
--COALESCE(DQA_VOYAGE.ACT_ARRIVAL_DT,BL_BL.VDATE) AS ACT_ARR_DT,
/* Cognizant Changes, End, 26-Oct-2009*/
NULL AS PLACE_RECEIPT_CD,					-- We do not have this value in PES RAW
NULL AS X_PLACE_RECEIPT_CD,					-- We do not have this value in PES RAW

--Changes by Cognizant, 21-Jan-2010, start
--NULL AS PLACE_RECEIPT_REGION,				-- We do not have this value in PES RAW
PES.DBO.ufn_GetRegionCode(	
						CASE WHEN BL_BL.IMPEXP='E' THEN COALESCE(BL_BL.DISCHARGE_PORT,BL_BL.PORT_OF_DEPARTURE)  
						ELSE BL_BL.PLACE_OF_RECEIPT END
						 ) AS PLACE_RECEIPT_REGION,
--Changes by Cognizant, 21-Jan-2010, end

/* Changes by Cognizant, 19-Jan-2010, start */
CASE WHEN BL_BL.IMPEXP='E' THEN COALESCE(BL_BL.DISCHARGE_PORT,BL_BL.PORT_OF_DEPARTURE)  
ELSE BL_BL.PLACE_OF_RECEIPT END AS PLACE_RECEIPT_NAME,

--LEFT(BL_BL.FOREIGN_LOADING_PORT,5) AS FOREIGN_PORT,
COALESCE(BL_BL.FOREIGN_LOADING_PORT,LEFT(PORT_OF_DESTINATION,5)) AS FOREIGN_PORT,

COALESCE(FPORT2.PIERS_PORT_CODE,COALESCE(BL_BL.FOREIGN_LOADING_PORT,LEFT(PORT_OF_DESTINATION,5)))     AS X_FP_LADING_CD,

--Changes by Cognizant, 21-Jan-2010, start
---NULL AS FP_LADING_REGION,					-- We do not have this value in PES RAW
PES.DBO.ufn_GetRegionCode(
							CASE WHEN BL_BL.IMPEXP='E' THEN BL_BL.PORT_OF_DESTINATION 
							ELSE FPORT2.PORT_NAME END 
						 ) as FP_LADING_REGION,
--Changes by Cognizant, 21-Jan-2010, end

/* Cognizant Changes, 15-Jan-2010, Start */
--CASE WHEN BL_BL.IMPEXP='E' THEN BL_BL.FOREIGN_LOADING_PORT ELSE FPORT2.PORT_NAME END AS      FP_LADING_NAME,
CASE WHEN BL_BL.IMPEXP='E' THEN BL_BL.PORT_OF_DESTINATION ELSE FPORT2.PORT_NAME END AS      FP_LADING_NAME,
/* Cognizant Changes, 15-Jan-2010, End */

--Changes by Cognizant, 21-Jan-2010, start
LEFT(PES.DBO.ufn_GetRegionName(
							CASE WHEN BL_BL.IMPEXP='E' THEN BL_BL.PORT_OF_DESTINATION 
							ELSE FPORT2.PORT_NAME END 
						 ),4) as FP_LADING_REGION_NAME,

--NULL AS FP_LADING_REGION_NAME,				-- We do not have this value in PES RAW
--Changes by Cognizant, 21-Jan-2010, end

/* Changes by Cognizant, 19-Jan-2010, end*/

--Changes by Cognizant on 19-Jan-2010, start
COALESCE(BL_BL.DISCHARGE_PORT,LEFT(BL_BL.PORT_OF_DEPARTURE,4)) AS US_PORT,
COALESCE(USPORT1.PIERS_PORT_CODE,COALESCE(BL_BL.DISCHARGE_PORT,LEFT(BL_BL.PORT_OF_DEPARTURE,4)))    AS X_PORT_UNLADING_CD,

--Changes by Cognizant, 21-Jan-2010, start
PES.DBO.ufn_GetRegionCode(USPORT1.PORT_NAME) AS PORT_UNLADING_REGION,	
--NULL AS PORT_UNLADING_REGION,				-- We do not have this value in PES RAW
--Changes by Cognizant, 21-Jan-2010, end

USPORT1.PORT_NAME AS PORT_UNLADING_NAME,
/*
BL_BL.DISCHARGE_PORT AS US_PORT,
COALESCE(USPORT1.PIERS_PORT_CODE,LEFT(BL_BL.DISCHARGE_PORT,4))    AS X_PORT_UNLADING_CD,
NULL AS PORT_UNLADING_REGION,				-- We do not have this value in PES RAW
USPORT1.PORT_NAME AS PORT_UNLADING_NAME,
*/
--Changes by Cognizant on 19-Jan-2010, end

--Changes by Cognizant on 20-Jan-2010, START
BL_BL.US_DIST_PORT AS CLEARING_PORT_CD,
COALESCE(USPORT2.PIERS_PORT_CODE,LEFT(BL_BL.US_DIST_PORT,4),USPORT3.PIERS_PORT_CODE) AS X_CLEARING_PORT_CD,

--Changes by Cognizant, 21-Jan-2010, start
--NULL AS US_CLEARING_REGION	,				-- We do not have this value in PES RAW
PES.DBO.ufn_GetRegionCode(COALESCE(USPORT2.PORT_NAME,USPORT3.PORT_NAME,BL_BL.ORIGINCITY)) AS US_CLEARING_REGION,
--Changes by Cognizant, 21-Jan-2010, end

COALESCE(USPORT2.PORT_NAME,USPORT3.PORT_NAME,BL_BL.ORIGINCITY) AS US_CLEARING_NAME,
/*
BL_BL.US_DIST_PORT AS CLEARING_PORT_CD,
COALESCE(USPORT2.PIERS_PORT_CODE,LEFT(BL_BL.US_DIST_PORT,4)) AS X_CLEARING_PORT_CD,
NULL AS US_CLEARING_REGION	,				-- We do not have this value in PES RAW
USPORT2.PORT_NAME AS US_CLEARING_NAME,
*/
--Changes by Cognizant on 20-Jan-2010, end

BL_BL.FOREIGN_PORT AS FP_DEST_CD,
--Changes by Cognizant on 20-Jan-2010, START
COALESCE(FPORT4.PIERS_PORT_CODE,FPORT3.PIERS_PORT_CODE,BL_BL.FOREIGN_PORT) AS X_FP_DEST_CD,
--COALESCE(FPORT3.PIERS_PORT_CODE,FOREIGN_PORT) AS X_FP_DEST_CD,
--Changes by Cognizant on 20-Jan-2010, END

--Changes by Cognizant on 20-Jan-2010, START

--Changes by Cognizant on 25-Jan-2010,Defect #2789, START
COALESCE(BL_BL.DESTINATION_COUNTRY,FPORT4.COUNTRYL,FPORT3.COUNTRYL) AS FP_DEST_CNTRY,
--COALESCE(BL_BL.DESTINATION_COUNTRY,FPORT4.COUNTRY,FPORT3.COUNTRY) AS FP_DEST_CNTRY,
--Changes by Cognizant on 25-Jan-2010,Defect #2789, END

--FPORT3.COUNTRY AS FP_DEST_CNTRY,
--Changes by Cognizant on 20-Jan-2010, END

--Changes by Cognizant on 20-Jan-2010, START
LTRIM(RTRIM(COALESCE(FPORT4.PORT_NAME,FPORT4.PIERS_NAME,BL_BL.DESTINATION_CITY,BL_BL.PORT_OF_DESTINATION,FPORT3.PORT_NAME,FPORT3.PIERS_NAME)))AS    FP_DEST_NAME,
--LTRIM(RTRIM(COALESCE(FPORT3.PORT_NAME,FPORT3.PIERS_NAME)))AS    FP_DEST_NAME,
--Changes by Cognizant on 20-Jan-2010, END

BL_BL.MFEST_QUANTITY AS MANIFEST_QTY,

--Changes by Cognizant, 28-Jan-2010, start
--Defect #2794, 2804
--COALESCE(MANIFEST_UNIT_ALIAS.UM,BL_BL.MFEST_UNITS) AS  X_MANIFEST_UNIT,
BL_BL.MFEST_UNITS AS  X_MANIFEST_UNIT,
--Changes by Cognizant, 28-Jan-2010, end

ROUND(BL_BL.WEIGHT,2) AS WGT,
ROUND((BL_BL.WEIGHT * WEIGHT_UNIT_ALIAS.CONVERSION_FACTOR),2) AS STD_WGT,
NULL AS INTERP_STD_WGT_FLG,-- We do not have this value in PES RAW

COALESCE(WEIGHT_UNIT_ALIAS.WGT_UNIT_ALIAS,BL_BL.WEIGHT_UNITS) AS X_WGT_UNIT,
ROUND (BL_BL.MEAS,2) MEAS,
COALESCE (MEAS_UNIT_ALIAS.MEAS_UNIT_ALIAS,BL_BL.MEAS_UNITS) AS X_MEAS_UNIT,
BL_BL.INBOUND_ENTRY_TYPE AS INBOND_ENTRY_TYPE,
/* Cognizant Changes, Start, 26-Oct-2009*/
BL_BL.MANIFEST_NUMBER AS MANIFEST_NBR,
--COALESCE (DQA_VOYAGE.ACT_MANIFEST_NBR,BL_BL.MANIFEST_NUMBER) AS MANIFEST_NBR,
/* Cognizant Changes, End, 26-Oct-2009*/

NULL AS TEU_CNT,	-- We do not have this value in PES RAW
NULL AS TEU_SRC,	-- We do not have this value in PES RAW
NULL AS LCL_FLG,	-- We do not have this value in PES RAW

NULL AS CNTRIZED_SHPMT_FLG,	-- We do not have this value in PES RAW
COALESCE (TRANS_MODE_ALIAS.TRANS_MODE_CD_ALIAS,BL_BL.MODE_TRANSPORT) AS X_TRANS_MODE_CD,
TRANS_MODE_ALIAS.DESCRIPTION AS TRANS_MODE_CD_DESCRIPTION,
NULL AS FRAME_NBR,		-- We do not have this value in PES RAW
BL_BL.LOAD_NUMBER AS LOAD_NBR,
NULL AS LOAD_SEQ_NBR, 	-- We do not have this value in PES RAW
NULL LOAD_TYPE,			-- We do not have this value in PES RAW. We do not populate LOAD_TYPE in HEP_LOG
NULL AS LAST_UPDATE_DT,  -- We do not have this value in PES RAW
NULL AS DB_LOAD_NBR,		-- We do not have this value in PES RAW

PES.DBO.pes_udf_GetHazmatClass(BL_BL.BOL_ID) AS HZRD_CLASS,			-- Need to create a UDF for this, based on hazmat_class() UDF in Batch
/* Cognizant Changes, Start, 26-Oct-2009*/
BL_BL.CARRIER_CODE AS SCAC,
--COALESCE(DQA_VOYAGE.SCAC,BL_BL.CARRIER_CODE) AS SCAC,
/* Cognizant Changes, End, 26-Oct-2009*/
NULL AS CONS_STATE,
NULL AS NOT_STATE,
NULL AS ANOT_STATE,
BL_BL.IMPEXP AS DIR,
BL_BL.BATCH_ID,
BL_BL.BOL_NUMBER AS ORIG_BL_NBR,
CASE WHEN COALESCE(SUBSTRING(BL_BL.MASTER_BOL_DATA,41,1),'X')='M' THEN 'H'ELSE 'V' END AS VISIBILITY
		
FROM PES.DBO.ARCHIVE_RAW_BOL BL_BL  WITH (NOLOCK) 

--Changes by Cognizant, 18-Jan-2010, Defect 2763, Start
LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_CARRIER SCAC_ALIAS  WITH (NOLOCK) 
ON SCAC_ALIAS.CODE = BL_BL.CARRIER_CODE
/*
LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_CARRIER SCAC_ALIAS  WITH (NOLOCK) 
ON SCAC_ALIAS.CODE = 
(CASE 
WHEN COALESCE(SUBSTRING(BL_BL.MASTER_BOL_DATA,41,1),'X')='H' THEN 
SUBSTRING(BL_BL.MASTER_BOL_DATA,42,4) ELSE BL_BL.CARRIER_CODE
END)
*/
-- Changes by Cognizant, 18-Jan-2010, Defect 2763, End 

LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT FPORT2  WITH (NOLOCK) 
ON FPORT2.CODE = BL_BL.FOREIGN_LOADING_PORT

LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT USPORT1  WITH (NOLOCK) 
ON USPORT1.CODE = BL_BL.DISCHARGE_PORT

LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT USPORT2  WITH (NOLOCK) 
ON USPORT2.CODE = BL_BL.US_DIST_PORT

--Changes by Cognizant, 20-Jan-2010, start
LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT_NAME_STATE USPORT3  WITH (NOLOCK) 
ON (USPORT3.PIERS_NAME = BL_BL.ORIGINCITY AND USPORT3.STATE = BL_BL.ORIGINSTATE)
--Changes by Cognizant, 20-Jan-2010, END

LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT FPORT3  WITH (NOLOCK) 
ON FPORT3.CODE = BL_BL.FOREIGN_PORT

--Changes by Cognizant, 20-Jan-2010, start
LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT_NAME FPORT4  WITH (NOLOCK) 
ON FPORT4.PIERS_NAME = COALESCE(BL_BL.DESTINATION_CITY,BL_BL.PORT_OF_DESTINATION)
--Changes by Cognizant, 20-Jan-2010, start

/* Cognizant Changes, Start, 26-Oct-2009*/
--LEFT OUTER JOIN PES.DBO.TI_VIEW_DQA_VOYAGE DQA_VOYAGE  WITH (NOLOCK) 
--ON DQA_VOYAGE.VOYAGE_NBR = BL_BL.VOYAGE_NUMBER
/* Cognizant Changes, End, 26-Oct-2009*/

/*
--Changes by Cognizant, 28-Jan-2010, start
--Defect #2794, 2804
LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PPMM_PACK MANIFEST_UNIT_ALIAS  WITH (NOLOCK) 
ON MANIFEST_UNIT_ALIAS.AMSUM = BL_BL.MFEST_UNITS
--Changes by Cognizant, 28-Jan-2010, end
*/

LEFT OUTER JOIN PES.DBO.REF_WEIGHT_UNIT WEIGHT_UNIT_ALIAS  WITH (NOLOCK) 
ON WEIGHT_UNIT_ALIAS.WGT_UNIT = BL_BL.WEIGHT_UNITS

LEFT OUTER JOIN PES.DBO.REF_MEAS_UNIT MEAS_UNIT_ALIAS  WITH (NOLOCK) 
ON MEAS_UNIT_ALIAS.MEAS_UNIT = BL_BL.MEAS_UNITS

LEFT OUTER JOIN PES.DBO.REF_TRANS_MODE TRANS_MODE_ALIAS  WITH (NOLOCK) 
ON TRANS_MODE_ALIAS.TRANS_MODE_CD = BL_BL.MODE_TRANSPORT

--Commented by Cognizant on 23-Jan-2010, start
--These joins below are not needed
/*
LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT US_PORT_REGION  WITH (NOLOCK) 
ON US_PORT_REGION.CODE = BL_BL.DISCHARGE_PORT

LEFT OUTER JOIN PES.DBO.TI_VIEW_REF_PORT US_CLEARING_REGION  WITH (NOLOCK) 
ON US_PORT_REGION.CODE = BL_BL.US_DIST_PORT
*/
--Commented by Cognizant on 23-Jan-2010, end
/* Cognizant Changes, Start, 26-Oct-2009*/
WHERE BL_BL.INVALIDBILLFLAG IS NULL
/* Cognizant Changes, End, 26-Oct-2009*/

-- [aa] - 02/03/2011
--  Added because ESOL load was failing because of 
--   invalid data in PES.dbo.ARCHIVE_RAW_BOL.SAILING_DATE
 AND BL_BL.SAILING_DATE != 'Invalid'
GO
