/****** Object:  UserDefinedFunction [dbo].[PESDW_UDF_GET_TRADE_REGION]    Script Date: 01/08/2013 14:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PESDW_UDF_GET_TRADE_REGION](@CTRY_CODE VARCHAR(2))
RETURNS VARCHAR(4)
AS
BEGIN

DECLARE @TradeRegion varchar(4)
DECLARE @TradeRegion_FullName varchar(30)
SELECT @TradeRegion = ''
SELECT @TradeRegion_FullName=''

IF @CTRY_CODE IS NULL
	SELECT @TradeRegion=''
ELSE
BEGIN
	SELECT @TradeRegion_FullName=(SELECT TOP 1 NAME
	FROM PES_DW_REF_TRADE_REGION R JOIN PES_DW_REF_COUNTRY_TRADE_REGION C
	ON R.TRADE_REGION_CD=C.TRADE_REGION_CD
	WHERE C.COUNTRY_CD=@CTRY_CODE)

	IF @TradeRegion_FullName IS NULL
		SELECT @TradeRegion_FullName=''

	SELECT @TradeRegion=LEFT(@TradeRegion_FullName,4)	
END

RETURN @TradeRegion

END
GO
