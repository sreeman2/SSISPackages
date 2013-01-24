/****** Object:  View [dbo].[EXPBUL_SOURCE_QUERY_VIEW]    Script Date: 01/08/2013 15:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[EXPBUL_SOURCE_QUERY_VIEW]

(vdate_dir,				--	(Directory)
		uscode,
		usport,
		st,					--(State)
		ctrycode,
		sline,					--(Ship Line)
		comcode,				--(Commodity Code)
		harm_code,
		filler2, 
		fcode,
		fport,
		comp_nbr,		--(Company Number)
		recnum1,
		commodity,
		is_valid,
		[name], 
		city,
		vessel1,
		u_m,					--(Unit of Measure)
		pounds,
		country,
		pdate,					--(Process Date)
		qty,		
		ultport,
		ultcode,
		conflag,					--(Container Flag)
		conqty,
		consize,
		convol,
		teua,  -- integer part
		teub,  -- decimal part
		recnum2,
		baseloc,   -- 12 char spaces
		bol_nbr,
		manifest_nbr,
		conscity,
		consst,
		consaddress,
		consaddlinfo,
		conszip,
		ntfname,
		ntfcity,
		ntfst,
		ntfaddress,
		ntfaddlinfo,
		ntfzip,
		fcity,
		fctry,
		faddress,
		faddlinfo,
		fzipcode,
		vessel2,
		voyage,
		usfinal,
		fgnfinal,
		ntfcomp_nbr,
		fccomp_nbr,
		is_consgn,
		is_notify,
		is_shipper,
		recnum3,
		vessel_regst,
		is_financl,
		payable_flag,
		org_dest_city,
		org_dest_st,
		[value],
		is_hazmat,
		is_reefer,
		is_roro,
		nvocc_flag,
		bank_name,
		filler23)
AS

SELECT 
	LEFT(DBO.EXP_BUL_UDF_FMTDATE(BOL.VDATE)+BOL.DIRECTION ,9) vdate_dir
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(USPORT.CODE,4) ,4) uscode
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(USPORT.PORT_NAME,13) ,13) usport
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(LTRIM(RTRIM(SUBSTRING(CONS.ST,1,2))),'XX') ,2) ,2) st
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(BOL.CTRYCODE,3) ,3) ctrycode
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CAR.SLINE,4),4) sline
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(LTRIM(RTRIM(CMD.JOC_CODE)),7),7) comcode
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(LTRIM(RTRIM(SUBSTRING(CMD.HSCODE,1,6))),6),6) harm_code
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR('  ',2),2)  filler2
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FPORT.CODE,5),5) fcode
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FPORT.PORT_NAME,13),13) fport
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.COMP_NBR,14),14) comp_nbr
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(DBO.PES_UDF_RECNUM(CMD.CMD_ID) ,8),8) recnum1
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(LTRIM(RTRIM(SUBSTRING(CMD.CMD_DESC,1,35))),35),35) commodity
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CASE WHEN ISNULL(BOL.DELETED,'N')='Y' OR ISNULL(CMD.DELETED,'N')='Y' THEN 'N'
			  ELSE 'Y' END,1),1) is_valid
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.NAME,35),35) name
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.CITY,13),13) city
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(SUBSTRING(VESS.NAME,1,17),17),17) vessel1
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(UOM.UM,3),3) u_m
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM(ROUND((CMD.STND_WEIGHT_KG)*(SELECT CAST((1/CONVERSION_FACTOR ) AS FLOAT) CONVERSION_FACTOR FROM PES_RAW.PES.DBO.vREF_WEIGHT_UNIT WHERE WGT_UNIT='LB'),0) ,10),10) pounds
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(COUN.COUNTRY,7),7) country
      ,LEFT(DBO.EXP_BUL_UDF_FMTDATE(CAST(CONVERT(VARCHAR(10), BOL.PDATE, 101) AS DATETIME)),8) pdate
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM(CMD.QTY,8),8) qty
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ULTPORT.PORT_NAME,13),13) ultport
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ULTPORT.CODE,5),5) ultcode
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CMD.CNTR_FLAG ,1),1) conflag
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM(CMD.CNTR_QUANTITY,3),3) conqty
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(CMD.CNTR_SIZE,' ') ,2),2) consize
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM(CMD.CNTR_VOL,10),10) convol
      ,LEFT(CASE WHEN LEN(LEFT(CMD.TEU,CHARINDEX('.',CMD.TEU)-1))<3 THEN REPLICATE('0',3-ISNULL(LEN(LEFT(CMD.TEU,CHARINDEX('.',CMD.TEU)-1)),0))+(LEFT(CMD.TEU,CHARINDEX('.',CMD.TEU)-1)) ELSE (LEFT(CMD.TEU,CHARINDEX('.',CMD.TEU)-1)) END,3) teua
      ,LEFT(CASE WHEN LEN(RIGHT(CMD.TEU,LEN(CMD.TEU)-CHARINDEX('.',CMD.TEU)) )<2 THEN (RIGHT(CMD.TEU,LEN(CMD.TEU)-CHARINDEX('.',CMD.TEU)) )+REPLICATE('0',2-ISNULL(LEN((RIGHT(CMD.TEU,LEN(CMD.TEU)-CHARINDEX('.',CMD.TEU)) )),0)) ELSE (RIGHT(CMD.TEU,LEN(CMD.TEU)-CHARINDEX('.',CMD.TEU)) ) END,2) teub
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(DBO.PES_UDF_RECNUM(CMD.CMD_ID),8),8) recnum2
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR('            ',12),12) baseloc
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(BOL.BILL_NUMBER ,12),12) bol_nbr
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(LTRIM(RTRIM(SUBSTRING(BOL.MANIFEST_NUMBER,1,7))) ,6),6) manifest_nbr
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.CITY,13),13) conscity
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.ST,2),2) consst
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.STREET ,35),35) consaddress
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.STREET2,25),25) consaddlinfo
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.ZIPCODE,9),9) conszip
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.RAWNAME,50),50) ntfname
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.CITY ,13),13) ntfcity
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.ST,2),2) ntfst
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.STREET ,35),35) ntfaddress
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.STREET2,25),25) ntfaddlinfo
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.ZIPCODE,9),9) ntfzip
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FC.CITY,13),13) fcity
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FCOUN.COUNTRY ,7),7) fctry
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FC.STREET,35),35) faddress
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FC.STREET2,25),25) faddlinfo
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FC.ZIPCODE ,9),9) fzipcode
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(VESS.NAME ,7),7) vessel2
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(LTRIM(RTRIM(SUBSTRING(BOL.VOYAGE,1,5))),8),8) voyage
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(BOL.USIB_CODE,4),4) usfinal
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(BOL.FGNIB_CODE,5),5) fgnfinal
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(NTF.COMP_NBR,14),14) ntfcomp_nbr
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(FC.COMP_NBR,14),14) fccomp_nbr
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.IS_CONSGN,1),1) is_consgn
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.IS_NOTIFY,1),1) is_notify
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(CONS.IS_SHIPPER,1),1) is_shipper
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(DBO.PES_UDF_RECNUM(CMD.CMD_ID),8),8) recnum3
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(VESS_COUN.COUNTRY ,7),7) vessel_regst
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(BOL.FINANCIAL_FLAG,' '),1),1) is_financl
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(BOL.PAYABLE_FLAG,' '),1),1) payable_flag
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(BOL.ORG_DEST_CITY,' ') ,13),13) org_dest_city
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(BOL.ORG_DEST_ST,' '),7),7) org_dest_st
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM(CMD.STND_EST_VALUE_DOLLAR,10),10) value
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(CMD.HAZMAT_FLAG,' '),1),1) is_hazmat
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(CMD.REEFER_FLAG,' '),1),1) is_reefer
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(CMD.RORO_FLAG,' '),1),1) is_roro
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(ISNULL(BOL.NVOCC_FLAG,' '),1),1) nvocc_flag
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR(BK.BANK_NAME,35),35) bank_name
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR('                       ',23),23) filler23
      
      FROM 
		
		PES_DW_BOL BOL WITH (NOLOCK) 
		 JOIN PES_DW_CMD CMD WITH (NOLOCK)
			ON BOL.BOL_ID = CMD.BOL_ID 
		LEFT OUTER JOIN PES_DW_REF_PORT USPORT WITH (NOLOCK)
			ON BOL.PORT_DEPART_REF_ID = USPORT.ID
		LEFT OUTER JOIN PES_DW_REF_PORT FPORT WITH (NOLOCK)
			ON BOL.PORT_ARRIVE_REF_ID = FPORT.ID
		LEFT OUTER JOIN PES_DW_REF_PORT ULTPORT WITH (NOLOCK)
			ON BOL.ULTPORT_REF_ID = ULTPORT.ID
		LEFT OUTER JOIN PES_DW_REF_CARRIER CAR WITH (NOLOCK)
			ON BOL.SLINE_REF_ID = CAR.ID	
		LEFT OUTER JOIN PES_DW_REF_VESSEL VESS WITH (NOLOCK)
			ON BOL.VESSEL_REF_ID = VESS.ID
		LEFT OUTER JOIN PES_DW_REF_UOM UOM WITH (NOLOCK)
			ON CMD.QTY_UNIT_REF_ID = UOM.ID
		LEFT OUTER JOIN EXPBUL_PESDW_COMPANY_VIEW FC WITH (NOLOCK)
			ON FC.COMP_ID = BOL.CONGINEE_COMP_REF_ID
		LEFT OUTER JOIN EXPBUL_PESDW_COMPANY_VIEW CONS WITH (NOLOCK)
			ON CONS.COMP_ID = BOL.SHIPPER_COMP_REF_ID
		LEFT OUTER JOIN EXPBUL_PESDW_COMPANY_VIEW NTF WITH (NOLOCK)
			ON NTF.COMP_ID = BOL.NOTIFY_COMP_REF_ID
		LEFT OUTER JOIN PES_DW_REF_COUNTRY VESS_COUN WITH (NOLOCK)
			ON VESS_COUN.COUNTRY_ID = BOL.VESSEL_REGISTRY_COUNRTY_REF_ID 
		LEFT OUTER JOIN PES_DW_REF_COUNTRY COUN WITH (NOLOCK)
			ON COUN.CTRY_CODE = BOL.CTRYCODE
		LEFT OUTER JOIN PES_DW_REF_COUNTRY FCOUN WITH (NOLOCK)
			ON FCOUN.CTRY_CODE = FC.CTRYCODE
		LEFT OUTER JOIN PES_DW_REF_BANK BK WITH (NOLOCK)
			ON BK.BANK_ID = BOL.BANK_REF_ID
WHERE BOL.DIRECTION='E'
GO
