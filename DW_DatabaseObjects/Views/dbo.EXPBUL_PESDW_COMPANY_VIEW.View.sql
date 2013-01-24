/****** Object:  View [dbo].[EXPBUL_PESDW_COMPANY_VIEW]    Script Date: 01/08/2013 15:00:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[EXPBUL_PESDW_COMPANY_VIEW] 
AS
	SELECT  COMP_ID,
			IS_USCOMP IS_USCOMP,
			COMPANY_NBR COMP_NBR,
			LTRIM(RTRIM(SUBSTRING(NAME,1,35))) RAWNAME,
			LTRIM(RTRIM(SUBSTRING(ADDRESS1,1,35))) STREET,
			' ' STREET2,
			LTRIM(RTRIM(SUBSTRING(CITY,1,13))) CITY,
			LTRIM(RTRIM(SUBSTRING(STATE,1,2))) ST,
			COUNTRY_CD CTRYCODE,
			ISNULL(LTRIM(RTRIM(SUBSTRING(REPLACE(ZIPCODE,' ',''),1,9))),' ') ZIPCODE,
			' ' IS_NOTIFY,
			' ' IS_CONSGN,
			' ' IS_SHIPPER,
			' ' IS_NEW,
			' ' IN_DIRCTRY,
			MODIFIED_DT LST_DATE_CHNG,
			CASE WHEN IS_USCOMP = 'Y' THEN 'N'
			ELSE 'Y' END IS_FCOMP,
			LTRIM(RTRIM(SUBSTRING(NAME,1,35))) NAME,
			REPLACE(LTRIM(RTRIM(SUBSTRING(NAME,1,35))),' ','') COMPRESSEDNAME,
			0 GCOMP_ID
	FROM PES_DW_REF_COMPANY WITH (NOLOCK)
	
	/*UNION

	SELECT  COMP_ID,
			IS_USCOMP IS_USCOMP,
			COMPANY_NBR COMP_NBR,
			LTRIM(RTRIM(SUBSTRING(NAME,1,35))) RAWNAME,
			LTRIM(RTRIM(SUBSTRING(ADDR_1,1,35))) STREET,
			' ' STREET2,
			LTRIM(RTRIM(SUBSTRING(CITY,1,13))) CITY,
			LTRIM(RTRIM(SUBSTRING(STATE,1,2))) ST,
			CNTRY_CD CTRYCODE,
			ISNULL(LTRIM(RTRIM(SUBSTRING(REPLACE(ZIPCODE,' ',''),1,9))),' ') ZIPCODE,
			' ' IS_NOTIFY,
			' ' IS_CONSGN,
			' ' IS_SHIPPER,
			' ' IS_NEW,
			' ' IN_DIRCTRY,
			MODIFIED_DT LST_DATE_CHNG,
			CASE WHEN IS_USCOMP = 'Y' THEN 'N'
			ELSE 'Y' END IS_FCOMP,
			LTRIM(RTRIM(SUBSTRING(NAME,1,35))) NAME,
			REPLACE(LTRIM(RTRIM(SUBSTRING(NAME,1,35))),' ','') COMPRESSEDNAME,
			0 GCOMP_ID
	FROM PES_DW_NEW_COMPANY WITH (NOLOCK)*/
GO
