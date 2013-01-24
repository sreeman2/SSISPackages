/****** Object:  View [dbo].[TI_Import_MasterData_V]    Script Date: 01/09/2013 18:52:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TI_Import_MasterData_V] AS
(

-- Bills that are in master and in index, but have been updated in master
--  since the time they were indexed, i.e. 'updates'
SELECT

	 mdi.BL_NBR
	,mdi.BOL_ID
	,mdi.FOREIGN_PORT_NAME
	,mdi.FOREIGN_PORT_CNTRY
	,mdi.PORT_UNLADING_NAME
	,mdi.PORT_UNLADING_STATE
	,mdi.PORT_US_CLEARING_NAME
	,mdi.PORT_US_CLEARING_ST
	,mdi.PORT_US_CLEARING_DIST
	,mdi.FP_DEST_NAME
	,mdi.FP_DEST_CNTRY
	,mdi.PORT_RECEIPT_NAME
	,mdi.PORT_RECEIPT_CNTRY
	,mdi.SCAC_CARRIER_NAME
	,mdi.SCAC_ADDR
	,mdi.SCAC_CITY
	,mdi.SCAC_STATE_CD
	,mdi.SCAC_ZIP_CD
	,mdi.SCAC_CNTRY
	,mdi.SCAC_PHONE
	,mdi.REGION_ORIGIN
	,mdi.COUNTRY_ORIGIN
	,mdi.ARRIVAL_DATE
	,mdi.ARRIVAL_WEEK
	--mdi.z_PRODUCT_DESC
	,COALESCE(mdi.PRODUCT_DESC_RAW,'') + COALESCE(mdi.PRODUCT_DESC_PROCESSED,'') As PRODUCT_DESC
	,mdi.SHIPPER_DESC
	,mdi.CONSGN_DESC
	,mdi.NOTIFY_DESC
	,mdi.ALSO_NOTIFY_DESC
	,mdi.SHIPPER_DUNS
	,mdi.CONSGN_DUNS
	,mdi.NOTIFY_DUNS
	,mdi.ALSO_NOTIFY_DUNS
	,mdi.MANIFEST_NBR
	,mdi.VESSEL_NAME
	,mdi.VESSEL_FLAG
	,mdi.VOYAGE_NBR
	,mdi.BL_CNTR_FLG
	,mdi.STD_WGT
	,mdi.MEAS
	,mdi.MEAS_UNIT
	,mdi.MANIFEST_QTY
	,mdi.MANIFEST_UNIT
	,mdi.TEU_CNT
	,mdi.TEU_SRC
	,mdi.HS_CODES
	,mdi.INBOND_ENTRY_TYPE
	,mdi.TRANS_MODE_DESCRIPTION
	,mdi.LOAD_TYPE
	,mdi.LOAD_NBR
	,mdi.LOAD_SEQ_NBR
	,mdi.DB_LOAD_NBR
	,mdi.FRAME_NBR
	,mdi.FOREIGN_PORT_REGION
	,mdi.SLINE
	,mdi.EST_VALUE
	,mdi.LLOYDS_CODE
	,mdi.HZRD_CLASS
	,mdi.NVOCC_FLAG
	,mdi.CTRYCODE
	,mdi.SCAC
	,mdi.US_COAST
	,mdi.USPORT_CODE
	,mdi.FPORT_CODE
	,mdi.JOC_CODES
	,mdi.CONS_STATE
	,mdi.NOT_STATE
	,mdi.ANOT_STATE
	,mdi.VISIBILITY
	,mdi.DIR
	,mdi.BATCH_ID
	,mdi.ORIG_BL_NBR
	,mdi.MODIFY_DATE
	--mdi.PRODUCT_DESC_RAW
	--mdi.PRODUCT_DESC_PROCESSED

	,im.Shard
FROM
 dbo.TI_Import_MasterData mdi (NOLOCK)
JOIN dbo.Import_IndexMap im (NOLOCK)
 ON mdi.BOL_ID = im.BOL_ID
 AND mdi.MODIFY_DATE > im.IndexedAt
WHERE mdi.ARRIVAL_DATE >= 20100101
--AND mdi.BOL_ID in(101181781,223508290,101758915, 223543686)

UNION

-- Bills that are in master but not in index, i.e. 'inserts'
SELECT

	 mdi.BL_NBR
	,mdi.BOL_ID
	,mdi.FOREIGN_PORT_NAME
	,mdi.FOREIGN_PORT_CNTRY
	,mdi.PORT_UNLADING_NAME
	,mdi.PORT_UNLADING_STATE
	,mdi.PORT_US_CLEARING_NAME
	,mdi.PORT_US_CLEARING_ST
	,mdi.PORT_US_CLEARING_DIST
	,mdi.FP_DEST_NAME
	,mdi.FP_DEST_CNTRY
	,mdi.PORT_RECEIPT_NAME
	,mdi.PORT_RECEIPT_CNTRY
	,mdi.SCAC_CARRIER_NAME
	,mdi.SCAC_ADDR
	,mdi.SCAC_CITY
	,mdi.SCAC_STATE_CD
	,mdi.SCAC_ZIP_CD
	,mdi.SCAC_CNTRY
	,mdi.SCAC_PHONE
	,mdi.REGION_ORIGIN
	,mdi.COUNTRY_ORIGIN
	,mdi.ARRIVAL_DATE
	,mdi.ARRIVAL_WEEK
	--mdi.z_PRODUCT_DESC
	,COALESCE(mdi.PRODUCT_DESC_RAW,'') + COALESCE(mdi.PRODUCT_DESC_PROCESSED,'') As PRODUCT_DESC
	,mdi.SHIPPER_DESC
	,mdi.CONSGN_DESC
	,mdi.NOTIFY_DESC
	,mdi.ALSO_NOTIFY_DESC
	,mdi.SHIPPER_DUNS
	,mdi.CONSGN_DUNS
	,mdi.NOTIFY_DUNS
	,mdi.ALSO_NOTIFY_DUNS
	,mdi.MANIFEST_NBR
	,mdi.VESSEL_NAME
	,mdi.VESSEL_FLAG
	,mdi.VOYAGE_NBR
	,mdi.BL_CNTR_FLG
	,mdi.STD_WGT
	,mdi.MEAS
	,mdi.MEAS_UNIT
	,mdi.MANIFEST_QTY
	,mdi.MANIFEST_UNIT
	,mdi.TEU_CNT
	,mdi.TEU_SRC
	,mdi.HS_CODES
	,mdi.INBOND_ENTRY_TYPE
	,mdi.TRANS_MODE_DESCRIPTION
	,mdi.LOAD_TYPE
	,mdi.LOAD_NBR
	,mdi.LOAD_SEQ_NBR
	,mdi.DB_LOAD_NBR
	,mdi.FRAME_NBR
	,mdi.FOREIGN_PORT_REGION
	,mdi.SLINE
	,mdi.EST_VALUE
	,mdi.LLOYDS_CODE
	,mdi.HZRD_CLASS
	,mdi.NVOCC_FLAG
	,mdi.CTRYCODE
	,mdi.SCAC
	,mdi.US_COAST
	,mdi.USPORT_CODE
	,mdi.FPORT_CODE
	,mdi.JOC_CODES
	,mdi.CONS_STATE
	,mdi.NOT_STATE
	,mdi.ANOT_STATE
	,mdi.VISIBILITY
	,mdi.DIR
	,mdi.BATCH_ID
	,mdi.ORIG_BL_NBR
	,mdi.MODIFY_DATE
	--mdi.PRODUCT_DESC_RAW
	--mdi.PRODUCT_DESC_PROCESSED

	,NULL As Shard
FROM
 dbo.TI_Import_MasterData mdi (NOLOCK)
WHERE mdi.VISIBILITY ='v' 
    AND mdi.ARRIVAL_DATE >= 20100101
    --AND mdi.BOL_ID in(101181781,223508290,101758915, 223543686)
    AND NOT EXISTS
    (SELECT im.BOL_ID FROM dbo.Import_IndexMap im (NOLOCK)
      WHERE mdi.BOL_ID = im.BOL_ID)

-- could use one single query to return...
-- but we need to be able to return im.Shard as well

--SELECT COUNT(*)
--FROM
-- dbo.TI_Import_MasterData mdi (NOLOCK)
--WHERE NOT EXISTS
-- (SELECT im.BOL_ID FROM dbo.IndexMap im (NOLOCK)
--   WHERE mdi.BOL_ID = im.BOL_ID AND mdi.MODIFY_DATE < im.IndexedAt)

)
GO
