/****** Object:  View [dbo].[ti_prePES_data_usshipment_V]    Script Date: 01/08/2013 15:00:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ti_prePES_data_usshipment_V]
As
SELECT
 u.T_NBR
,u.RECNUM
,u.VDATE
,u.NVOCC_FLAG
--,sline.CARRIER_DESC As SLINE_DESC
,(SELECT TOP 1
  CASE WHEN u.SLINE='ZZZZ' THEN NULL ELSE sline.CARRIER_DESC END
  FROM PES_DW_REF_CARRIER sline
  WHERE sline.sline = u.sline) As SLINE_DESC
,u.SLINE
,country.COUNTRY As COUNTRYL
,country.CTRY_CODE As CTRYCODE
,port_us.CODE As USPORT_CODE
,port_us.PORT_NAME As UNLADING_PORT_NAME
,NULL As PORT_UNLADING_STATE
,port_f.CODE As FPORT_CODE
,port_f.PORT_NAME As FOREIGN_PORT_NAME
,NULL As REGION_ORIGIN
,NULL As US_COAST
,NULL As PORT_US_CLEARING_NAME
,NULL As PORT_US_CLEARING_ST
,NULL As PORT_US_CLEARING_DIST
,u.MANIFEST_NBR
,u.VALUE
,u.HARM_CODE
,u.COMCODE
,u.TEU
,u.POUNDS
,u.QTY
,u.U_M
,u.COMMODITY
,u.UDATE
,u.dir
 FROM PESDW.dbo.PIERS_usshipment_V u

-- this returns multiples if e.g. u.sline='ZZZZ'
--LEFT OUTER JOIN PES_DW_REF_CARRIER sline ON sline.sline = u.sline

LEFT OUTER JOIN PES_DW_REF_COUNTRY country ON country.CTRY_CODE = u.ctrycode
LEFT OUTER JOIN PES_DW_REF_PORT As port_us ON port_us.id = u.usport_id
LEFT OUTER JOIN PES_DW_REF_PORT As port_f ON port_f.id = u.fport_id
GO
