/****** Object:  View [dbo].[TI_Export_MasterData_V]    Script Date: 01/09/2013 18:52:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TI_Export_MasterData_V] AS
(

-- Bills that are in master and in index, but have been updated in master
--  since the time they were indexed, i.e. 'updates'
SELECT

	 mde.BL_NBR
	,mde.BOL_ID
	,mde.FOREIGN_PORT_NAME
	,mde.FOREIGN_PORT_CNTRY
	,mde.PORT_UNLADING_NAME
	,mde.PORT_UNLADING_STATE
	,mde.PORT_US_CLEARING_NAME
	,mde.PORT_US_CLEARING_ST
	,mde.PORT_US_CLEARING_DIST
	,mde.FP_DEST_NAME
	,mde.FP_DEST_CNTRY
	,mde.PORT_RECEIPT_NAME
	,mde.PORT_RECEIPT_CNTRY
	,mde.SCAC_CARRIER_NAME
	,mde.SCAC_ADDR
	,mde.SCAC_CITY
	,mde.SCAC_STATE_CD
	,mde.SCAC_ZIP_CD
	,mde.SCAC_CNTRY
	,mde.SCAC_PHONE
	,mde.REGION_ORIGIN
	,mde.COUNTRY_ORIGIN
	,mde.ARRIVAL_DATE
	,mde.ARRIVAL_WEEK
	--mde.z_PRODUCT_DESC
	,COALESCE(mde.PRODUCT_DESC_RAW,'') + COALESCE(mde.PRODUCT_DESC_PROCESSED,'') As PRODUCT_DESC
	,mde.SHIPPER_DESC
	,mde.CONSGN_DESC
	,mde.NOTIFY_DESC
	,mde.ALSO_NOTIFY_DESC
	,mde.SHIPPER_DUNS
	,mde.CONSGN_DUNS
	,mde.NOTIFY_DUNS
	,mde.ALSO_NOTIFY_DUNS
	,mde.MANIFEST_NBR
	,mde.VESSEL_NAME
	,mde.VESSEL_FLAG
	,mde.VOYAGE_NBR
	,mde.BL_CNTR_FLG
	,mde.STD_WGT
	,mde.MEAS
	,mde.MEAS_UNIT
	,mde.MANIFEST_QTY
	,mde.MANIFEST_UNIT
	,mde.TEU_CNT
	,mde.TEU_SRC
	,mde.HS_CODES
	,mde.INBOND_ENTRY_TYPE
	,mde.TRANS_MODE_DESCRIPTION
	,mde.LOAD_TYPE
	,mde.LOAD_NBR
	,mde.LOAD_SEQ_NBR
	,mde.DB_LOAD_NBR
	,mde.FRAME_NBR
	,mde.FOREIGN_PORT_REGION
	,mde.SLINE
	,mde.EST_VALUE
	,mde.LLOYDS_CODE
	,mde.HZRD_CLASS
	,mde.NVOCC_FLAG
	,mde.CTRYCODE
	,mde.SCAC
	,mde.US_COAST
	,mde.USPORT_CODE
	,mde.FPORT_CODE
	,mde.JOC_CODES
	,mde.CONS_STATE
	,mde.NOT_STATE
	,mde.ANOT_STATE
	,mde.VISIBILITY
	,mde.DIR
	,mde.BATCH_ID
	,mde.ORIG_BL_NBR
	,mde.MODIFY_DATE
	--mde.PRODUCT_DESC_RAW
	--mde.PRODUCT_DESC_PROCESSED

	,im.Shard
FROM
 dbo.TI_Export_MasterData mde (NOLOCK)
JOIN dbo.export_IndexMap im (NOLOCK)
 ON mde.BOL_ID = im.BOL_ID
 AND mde.MODIFY_DATE > im.IndexedAt
WHERE mde.ARRIVAL_DATE >= 20100101
--AND mde.BOL_ID in(102134408,102157195,102157200,102157210,220789848,220812539, 223621027)

UNION

-- Bills that are in master but not in index, i.e. 'inserts'
SELECT

	 mde.BL_NBR
	,mde.BOL_ID
	,mde.FOREIGN_PORT_NAME
	,mde.FOREIGN_PORT_CNTRY
	,mde.PORT_UNLADING_NAME
	,mde.PORT_UNLADING_STATE
	,mde.PORT_US_CLEARING_NAME
	,mde.PORT_US_CLEARING_ST
	,mde.PORT_US_CLEARING_DIST
	,mde.FP_DEST_NAME
	,mde.FP_DEST_CNTRY
	,mde.PORT_RECEIPT_NAME
	,mde.PORT_RECEIPT_CNTRY
	,mde.SCAC_CARRIER_NAME
	,mde.SCAC_ADDR
	,mde.SCAC_CITY
	,mde.SCAC_STATE_CD
	,mde.SCAC_ZIP_CD
	,mde.SCAC_CNTRY
	,mde.SCAC_PHONE
	,mde.REGION_ORIGIN
	,mde.COUNTRY_ORIGIN
	,mde.ARRIVAL_DATE
	,mde.ARRIVAL_WEEK
	--mde.z_PRODUCT_DESC
	,COALESCE(mde.PRODUCT_DESC_RAW,'') + COALESCE(mde.PRODUCT_DESC_PROCESSED,'') As PRODUCT_DESC
	,mde.SHIPPER_DESC
	,mde.CONSGN_DESC
	,mde.NOTIFY_DESC
	,mde.ALSO_NOTIFY_DESC
	,mde.SHIPPER_DUNS
	,mde.CONSGN_DUNS
	,mde.NOTIFY_DUNS
	,mde.ALSO_NOTIFY_DUNS
	,mde.MANIFEST_NBR
	,mde.VESSEL_NAME
	,mde.VESSEL_FLAG
	,mde.VOYAGE_NBR
	,mde.BL_CNTR_FLG
	,mde.STD_WGT
	,mde.MEAS
	,mde.MEAS_UNIT
	,mde.MANIFEST_QTY
	,mde.MANIFEST_UNIT
	,mde.TEU_CNT
	,mde.TEU_SRC
	,mde.HS_CODES
	,mde.INBOND_ENTRY_TYPE
	,mde.TRANS_MODE_DESCRIPTION
	,mde.LOAD_TYPE
	,mde.LOAD_NBR
	,mde.LOAD_SEQ_NBR
	,mde.DB_LOAD_NBR
	,mde.FRAME_NBR
	,mde.FOREIGN_PORT_REGION
	,mde.SLINE
	,mde.EST_VALUE
	,mde.LLOYDS_CODE
	,mde.HZRD_CLASS
	,mde.NVOCC_FLAG
	,mde.CTRYCODE
	,mde.SCAC
	,mde.US_COAST
	,mde.USPORT_CODE
	,mde.FPORT_CODE
	,mde.JOC_CODES
	,mde.CONS_STATE
	,mde.NOT_STATE
	,mde.ANOT_STATE
	,mde.VISIBILITY
	,mde.DIR
	,mde.BATCH_ID
	,mde.ORIG_BL_NBR
	,mde.MODIFY_DATE
	--mde.PRODUCT_DESC_RAW
	--mde.PRODUCT_DESC_PROCESSED

	,NULL As Shard
FROM
 dbo.TI_Export_MasterData mde (NOLOCK)
WHERE mde.VISIBILITY ='v' 
      AND mde.ARRIVAL_DATE >= 20100101
      --AND mde.BOL_ID in(102134408,102157195,102157200,102157210,220789848,220812539, 223621027)
      AND NOT EXISTS
              (SELECT im.BOL_ID FROM dbo.export_IndexMap im (NOLOCK)
               WHERE mde.BOL_ID = im.BOL_ID)

-- could use one single query to return...
-- but we need to be able to return im.Shard as well

--SELECT COUNT(*)
--FROM
-- dbo.TI_Export_MasterData mde (NOLOCK)
--WHERE NOT EXISTS
-- (SELECT im.BOL_ID FROM dbo.IndexMap im (NOLOCK)
--   WHERE mde.BOL_ID = im.BOL_ID AND mde.MODIFY_DATE < im.IndexedAt)

)
GO
