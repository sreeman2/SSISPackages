/****** Object:  View [dbo].[stgload_processed_V]    Script Date: 01/09/2013 18:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[stgload_processed_V] AS
(
SELECT
  LTRIM(RTRIM(bl.bl_nbr)) AS BL_NBR
, bl.BOL_ID AS BOL_ID
, LTRIM(RTRIM(UPPER(LEFT(DATENAME(MONTH,bl.vdate),3))))+LTRIM(RTRIM(STR(YEAR(bl.vdate)))) AS TABLE_NAME
, NULL AS z_PUBLISH_DATE
, NULL AS z_REVISED_CNT
, NULL AS z_REVISED_DATE
, LTRIM(RTRIM(port_foreign.name)) AS FOREIGN_PORT_NAME
, LTRIM(RTRIM(port_foreign.country)) AS FOREIGN_PORT_CNTRY
, LTRIM(RTRIM(port_unlading.name)) AS PORT_UNLADING_NAME
, LTRIM(RTRIM(port_unlading.state)) AS PORT_UNLADING_STATE
, LTRIM(RTRIM(port_us_clearing.name)) AS PORT_US_CLEARING_NAME
, LTRIM(RTRIM(port_us_clearing.state)) AS PORT_US_CLEARING_ST
, LTRIM(RTRIM(port_us_clearing.country)) AS PORT_US_CLEARING_DIST
, LTRIM(RTRIM(port_foreign_dest.name)) AS FP_DEST_NAME
, LTRIM(RTRIM(port_foreign_dest.country)) AS FP_DEST_CNTRY
, LTRIM(RTRIM(port_receipt.name)) AS PORT_RECEIPT_NAME
, LTRIM(RTRIM(port_receipt.country)) AS PORT_RECEIPT_CNTRY
, LTRIM(RTRIM(scac.name)) AS SCAC_CARRIER_NAME
, LTRIM(RTRIM(scac.addr)) AS SCAC_ADDR
, LTRIM(RTRIM(scac.city)) AS SCAC_CITY
, LTRIM(RTRIM(scac.state_cd)) AS SCAC_STATE_CD
, LTRIM(RTRIM(scac.zip)) AS SCAC_ZIP_CD
, LTRIM(RTRIM(scac.country)) AS SCAC_CNTRY
, LTRIM(RTRIM(scac.phone)) AS SCAC_PHONE
, LTRIM(RTRIM(bl.origin_region)) AS REGION_ORIGIN
, LTRIM(RTRIM(bl.origin_country)) AS COUNTRY_ORIGIN
, YEAR(bl.vdate)*10000+MONTH(bl.vdate)*100+DAY(bl.vdate) AS ARRIVAL_DATE
, DATENAME(week, bl.vdate) AS ARRIVAL_WEEK

-- * , dbo.ufn_GetTaggedCommodityValues(bl.BOL_ID, 'PRODUCT_DESC') AS PRODUCT_DESC
-- performance improvement by getting rid of the UDF above
, REPLACE(REPLACE(REPLACE(
	(SELECT ''
		+ CASE WHEN c.piece_cnt IS NULL THEN '<QTY />' ELSE '<QTY>' + LTRIM(RTRIM(STR(c.piece_cnt))) + '</QTY>' END
		+ CASE WHEN c.piece_unit IS NULL THEN '<UM />' ELSE '<UM>' + LTRIM(RTRIM(c.piece_unit)) + '</UM>' END
		+ CASE WHEN c.cmd_desc IS NULL THEN '<SHORTDESC />' ELSE '<SHORTDESC>' + LTRIM(RTRIM(c.cmd_desc)) + '</SHORTDESC>' END
      FROM dbo.stg_cmd c (NOLOCK)
      WHERE c.BOL_ID = bl.BOL_ID
		AND (c.cmd_desc IS NOT NULL AND c.cmd_desc!='CONTAINER CARGO' AND c.cmd_desc!='GENERAL CARGO')
      FOR XML PATH('')
   ),'&lt;','<'),'&gt;','>'),'&amp;','&') AS PRODUCT_DESC

, NULL AS SHIPPER_DESC
, NULL AS CONSGN_DESC
, NULL AS NOTIFY_DESC
, NULL AS ALSO_NOTIFY_DESC
, NULL AS SHIPPER_DUNS
, NULL AS CONSGN_DUNS
, NULL AS NOTIFY_DUNS
, NULL AS ALSO_NOTIFY_DUNS
-- * , dbo.ufn_GetTaggedPartyValues(bl_ids.id_pty_shipper) AS SHIPPER_DESC
-- * , dbo.ufn_GetTaggedPartyValues(bl_ids.id_pty_consignee) AS CONSGN_DESC
-- * , dbo.ufn_GetTaggedPartyValues(bl_ids.id_pty_notify) AS NOTIFY_DESC
-- * , dbo.ufn_GetTaggedPartyValues(bl_ids.id_pty_notify_also) AS ALSO_NOTIFY_DESC
-- * , LTRIM(RTRIM(pty_shipper.duns_nbr)) AS SHIPPER_DUNS
-- * , LTRIM(RTRIM(pty_consignee.duns_nbr)) AS CONSGN_DUNS
-- * , LTRIM(RTRIM(pty_notify.duns_nbr)) AS NOTIFY_DUNS
-- * , LTRIM(RTRIM(pty_notify_also.duns_nbr)) AS ALSO_NOTIFY_DUNS
, LTRIM(RTRIM(bl.manifest_nbr)) AS MANIFEST_NBR
, LTRIM(RTRIM(vessel.name)) AS VESSEL_NAME
, LTRIM(RTRIM(vessel.flag)) AS VESSEL_FLAG
, LTRIM(RTRIM(bl.voyage_nbr)) AS VOYAGE_NBR
, LTRIM(RTRIM(bl.conflag)) AS BL_CNTR_FLG
, bl.std_weight AS STD_WGT
, bl.measure_value AS MEAS
, LTRIM(RTRIM(bl.measure_unit)) AS MEAS_UNIT
, bl.manifest_qty AS MANIFEST_QTY
, LTRIM(RTRIM(bl.manifest_unit)) AS MANIFEST_UNIT
, bl.teu_cnt AS TEU_CNT
, LTRIM(RTRIM(bl.teu_src)) AS TEU_SRC

--, dbo.ufn_GetTaggedCommodityValues(bl.BOL_ID, 'HS_CODES') AS HS_CODES
-- performance improvement by getting rid of the UDF above
, REPLACE(
	(SELECT ' ' + LTRIM(RTRIM(c.harm_code))
	  FROM dbo.stg_cmd c (NOLOCK)
	  WHERE c.BOL_ID = bl.BOL_ID
		AND (c.harm_code IS NOT NULL AND c.cmd_desc!='CONTAINER CARGO' AND c.cmd_desc!='GENERAL CARGO')
	  FOR XML PATH('')
	),'&#x20;',' ') as HS_CODES

, LTRIM(RTRIM(bl.inbond_entry_type)) AS INBOND_ENTRY_TYPE
, LTRIM(RTRIM(bl.trans_mode_description)) AS TRANS_MODE_DESCRIPTION
, bl.load_type AS LOAD_TYPE
, bl.load_nbr AS LOAD_NBR
, bl.load_seq_nbr AS LOAD_SEQ_NBR
, bl.db_load_nbr AS DB_LOAD_NBR
, LTRIM(RTRIM(bl.frame_nbr)) AS FRAME_NBR
, LTRIM(RTRIM(port_foreign.region)) AS FOREIGN_PORT_REGION
, LTRIM(RTRIM(sline.code)) AS SLINE
, bl.estimated_value AS EST_VALUE
, LTRIM(RTRIM(vessel.imo_code)) AS LLOYDS_CODE
, LTRIM(RTRIM(bl.hazard_class)) AS HZRD_CLASS
, LTRIM(RTRIM(bl.nvocc_flag)) AS NVOCC_FLAG
, LTRIM(RTRIM(bl.country_code)) AS CTRYCODE
, LTRIM(RTRIM(scac.code)) AS SCAC
, LTRIM(RTRIM(bl.us_coast)) AS US_COAST
, LTRIM(RTRIM(port_unlading.code)) AS USPORT_CODE
, LTRIM(RTRIM(port_foreign.code)) AS FPORT_CODE

--, dbo.ufn_GetTaggedCommodityValues(bl.BOL_ID, 'JOC_CODES') AS JOC_CODES
-- performance improvement by getting rid of the UDF above
, REPLACE(
	(SELECT ' ' + LTRIM(RTRIM(c.joc_code))
	  FROM dbo.stg_cmd c (NOLOCK)
	  WHERE c.BOL_ID = bl.BOL_ID
		AND (c.joc_code IS NOT NULL AND c.cmd_desc!='CONTAINER CARGO' AND c.cmd_desc!='GENERAL CARGO')
	  FOR XML PATH('')
	),'&#x20;',' ') as JOC_CODES

--, LTRIM(RTRIM(pty_consignee.st)) AS CONS_STATE
--, LTRIM(RTRIM(pty_notify.st)) AS NOT_STATE
--, LTRIM(RTRIM(pty_notify_also.st)) AS ANOT_STATE
, LTRIM(RTRIM(bl.cons_state)) AS CONS_STATE
, LTRIM(RTRIM(bl.not_state)) AS NOT_STATE
, LTRIM(RTRIM(bl.anot_state)) AS ANOT_STATE
, LTRIM(RTRIM(bl.visibility)) AS VISIBILITY
, bl.dir AS DIR
, LTRIM(RTRIM(bl.batch_id)) AS BATCH_ID
, NULL AS z_ORIG_BL_NBR
--, LTRIM(RTRIM(bl.action)) AS ACTION
-- * , CASE WHEN bl.load_source='dqa'    AND bl.load_indicator='insert' THEN 'I'
-- * 	   WHEN bl.load_source='ipiers' AND bl.load_indicator='update' THEN 'U'
-- *   END As ACTION
, NULL As z_ACTION
FROM
 dbo.stg_bl bl
LEFT OUTER JOIN dbo.stg_bl_ids bl_ids ON bl.BOL_ID = bl_ids.BOL_ID
--LEFT OUTER JOIN dbo.LoadPayload ON bl.load_nbr = LoadPayload.load_nbr AND LoadPayload.IdLoadLog = bl.IdLoadLog
-- * LEFT OUTER JOIN dbo.stg_pty AS pty_shipper ON bl_ids.id_pty_shipper = pty_shipper.id
-- * LEFT OUTER JOIN dbo.stg_pty AS pty_consignee ON bl_ids.id_pty_consignee = pty_consignee.id
-- * LEFT OUTER JOIN dbo.stg_pty AS pty_notify ON bl_ids.id_pty_notify = pty_notify.id
-- * LEFT OUTER JOIN dbo.stg_pty AS pty_notify_also ON bl_ids.id_pty_notify_also = pty_notify_also.id
LEFT OUTER JOIN dbo.stg_sline sline ON bl_ids.id_sline = sline.id
LEFT OUTER JOIN dbo.stg_scac scac ON bl_ids.id_scac = scac.id
LEFT OUTER JOIN dbo.stg_vessel vessel ON bl_ids.id_vessel = vessel.id
LEFT OUTER JOIN dbo.stg_port AS port_foreign ON bl_ids.id_port_foreign = port_foreign.id
LEFT OUTER JOIN dbo.stg_port AS port_unlading ON bl_ids.id_port_unlading = port_unlading.id
LEFT OUTER JOIN dbo.stg_port AS port_foreign_dest ON bl_ids.id_port_foreign_dest = port_foreign_dest.id
LEFT OUTER JOIN dbo.stg_port AS port_receipt ON bl_ids.id_port_receipt = port_receipt.id
LEFT OUTER JOIN dbo.stg_port AS port_us_clearing ON bl_ids.id_port_us_clearing = port_us_clearing.id
-- * WHERE (
-- * 	(bl.load_source='dqa'    AND bl.load_indicator='insert' AND bl.ucount=0	)
-- *  OR (bl.load_source='ipiers' AND bl.load_indicator='update' AND bl.ucount>=1) )

--WHERE bl.vdate BETWEEN '01/01/2009' AND '01/31/2010'
)
GO
