/****** Object:  View [dbo].[EXPBUL_SOURCE_VIEW]    Script Date: 01/08/2013 15:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[EXPBUL_SOURCE_VIEW]

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
       LEFT(DBO.EXP_BUL_UDF_FMTDATE([vdate])+[dir] ,9)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([uscode],4) ,4)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([usport],13) ,13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([st],2) ,2)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ctrycode],3) ,3)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([sline],4),4)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([comcode],7),7)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([harm_code],6),6)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([filler2],2),2)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fcode],5),5)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fport],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([comp_nbr],14),14)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([recnum1],8),8)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([commodity],35),35)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_valid],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([name],35),35)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([city],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([vessel1],17),17)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([u_m],3),3)
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM([pounds],10),10)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([country],7),7)
      ,LEFT(DBO.EXP_BUL_UDF_FMTDATE([pdate]),8)
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM([qty],8),8)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ultport],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ultcode],5),5)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([conflag],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM([conqty],3),3)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([consize],2),2)
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM([convol],10),10)
      ,LEFT(CASE WHEN LEN([teua])<3 THEN REPLICATE('0',3-ISNULL(LEN([teua]),0))+[teua] ELSE [teua] END,3)
      ,LEFT(CASE WHEN LEN([teub])<2 THEN [teub]+REPLICATE('0',2-ISNULL(LEN([teub]),0)) ELSE [teub] END,2)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([recnum2],8),8)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([baseloc],12),12)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([bol_nbr],12),12)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([manifest_nbr],6),6)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([conscity],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([consst],2),2)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([consaddress],35),35)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([consaddlinfo],25),25)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([conszip],9),9)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfname],50),50)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfcity],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfst],2),2)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfaddress],35),35)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfaddlinfo],25),25)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfzip],9),9)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fcity],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fctry],7),7)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([faddress],35),35)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([faddlinfo],25),25)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fzipcode],9),9)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([vessel2],7),7)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([voyage],8),8)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([usfinal],4),4)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fgnfinal],5),5)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([ntfcomp_nbr],14),14)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([fccomp_nbr],14),14)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_consgn],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_notify],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_shipper],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([recnum3],8),8)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([vessel_regst],7),7)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_financl],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([payable_flag],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([org_dest_city],13),13)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([org_dest_st],7),7)
      ,LEFT(DBO.EXP_BUL_UDF_FMTNUM([value],10),10)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_hazmat],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_reefer],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([is_roro],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([nvocc_flag],1),1)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([bank_name],35),35)
      ,LEFT(DBO.EXP_BUL_UDF_FMTSTR([filler23],23),23)
	 
  FROM [PESDW].[dbo].[EXPBUL_VIEW_USSHIPMENT]
GO
