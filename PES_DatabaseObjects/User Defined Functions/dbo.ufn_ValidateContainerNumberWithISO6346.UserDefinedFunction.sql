/****** Object:  UserDefinedFunction [dbo].[ufn_ValidateContainerNumberWithISO6346]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 
-- [aa] - 11/17/2010
-- Description: Validate Container Number against ISO standard - ISO 6346
-- Note 1. ISO standard at - http://www.iso.org/iso/catalogue_detail?csnumber=20453
-- Note 2. Algorithm from - http://en.wikipedia.org/wiki/ISO_6346
-- Sample: SELECT dbo.ufn_ValidateContainerNumberWithISO6346('MEDU1321986')
CREATE FUNCTION [dbo].[ufn_ValidateContainerNumberWithISO6346]
(
	@Container varchar(100)
)
RETURNS bit
AS
BEGIN

DECLARE @IsISO bit, @Message varchar(1024)
SELECT @IsISO = 'false', @Message=''

-- For testing only
--DECLARE @Container varchar(11)
--SELECT @Container = 'mEDU1321986'

--SELECT @Container As Container

-- Convert to upper-case
SELECT @Container = UPPER(@Container)
-- Trim extra spaces
SELECT @Container = LTRIM(RTRIM(@Container))
--SELECT @Container As Container

-- Is length 11 characters
DECLARE @Length int
SELECT @Length = LEN(@Container)
--SELECT @Length As Length
IF @Length != 11
BEGIN
	SELECT @IsISO = 'false', @Message='Container Number should be 11 characters long'
	--SELECT @IsISO As IsISO, @Message As Message
	RETURN @IsISO
END

-- Is there a non-AlphaNumeric character
DECLARE @NonAlphaNumericCharacterIndex int
SELECT @NonAlphaNumericCharacterIndex = PATINDEX('%[^A-Z,0-9]%',@Container)
--SELECT @NonAlphaNumericCharacterIndex As NonAlphaNumericCharacterIndex
IF @NonAlphaNumericCharacterIndex > 0
BEGIN
	SELECT @IsISO = 'false', @Message='Container Number should have only alpha numeric characters'
	--SELECT @IsISO As IsISO, @Message As Message
	RETURN @IsISO
END

-- Are first 4 characters alpha
DECLARE @First4AlphaCharacterIndex int
SELECT @First4AlphaCharacterIndex = PATINDEX('[A-Z][A-Z][A-Z][A-Z]%',@Container)
--SELECT @First4AlphaCharacterIndex As First4AlphaCharacterIndex
IF @First4AlphaCharacterIndex != 1
BEGIN
	SELECT @IsISO = 'false', @Message='Container Number should have only alpha characters in first 4 positions'
	--SELECT @IsISO As IsISO, @Message As Message
	RETURN @IsISO
END

-- Are last 7 characters numeric
DECLARE @Last7NumericCharacterIndex int
SELECT @Last7NumericCharacterIndex = PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9]',@Container)
--SELECT @Last7NumericCharacterIndex As Last7NumericCharacterIndex
IF @Last7NumericCharacterIndex != 5
BEGIN
	SELECT @IsISO = 'false', @Message='Container Number should have only numeric characters in last 7 positions'
	--SELECT @IsISO As IsISO, @Message As Message
	RETURN @IsISO
END

-- Is last character (digit) matching up to check-sum calculation
DECLARE @CalculatedCheckSum int
DECLARE @CalculatedCheckSumDigit int

;WITH tmp_ContainerAsTable_Step0 As (
 SELECT n.number As CharacterPosition, SUBSTRING(@Container, n.number, 1) As ContainerCharacter
  FROM SCREEN_TEST.dbo.Numbers n WITH (NOLOCK)
 WHERE n.number <= LEN(@Container)
), tmp_ContainerAsTable_Step1 As (
SELECT CharacterPosition, ContainerCharacter
, CASE ContainerCharacter
   WHEN 'A' THEN 10 WHEN 'B' THEN 12 WHEN 'C' THEN 13 WHEN 'D' THEN 14 WHEN 'E' THEN 15 WHEN 'F' THEN 16
   WHEN 'G' THEN 17 WHEN 'H' THEN 18 WHEN 'I' THEN 19 WHEN 'J' THEN 20 WHEN 'K' THEN 22 WHEN 'L' THEN 23
   WHEN 'M' THEN 24 WHEN 'N' THEN 25 WHEN 'O' THEN 26 WHEN 'P' THEN 27 WHEN 'Q' THEN 28 WHEN 'R' THEN 29
   WHEN 'S' THEN 30 WHEN 'T' THEN 31 WHEN 'U' THEN 32 WHEN 'V' THEN 34 WHEN 'W' THEN 35 WHEN 'X' THEN 36
   WHEN 'Y' THEN 37 WHEN 'Z' THEN 38
   ELSE ContainerCharacter --individual digits of the serial number keep their numeric value
  END As ContainerCharacterAssignedValue
 FROM tmp_ContainerAsTable_Step0
 WHERE CharacterPosition < 11
), tmp_ContainerAsTable_Step2 As (
SELECT CharacterPosition, ContainerCharacter, ContainerCharacterAssignedValue
, POWER(2, CharacterPosition-1) As Multiplier
, ContainerCharacterAssignedValue * POWER(2, CharacterPosition-1) As ContainerCharacterWeightedValue
 FROM tmp_ContainerAsTable_Step1
)
SELECT @CalculatedCheckSum = SUM(ContainerCharacterWeightedValue)
 FROM tmp_ContainerAsTable_Step2
--SELECT @CalculatedCheckSum As CalculatedCheckSum

SELECT @CalculatedCheckSumDigit = @CalculatedCheckSum - @CalculatedCheckSum/11*11

--SELECT @CalculatedCheckSumDigit As CalculatedCheckSumDigit
--SELECT SUBSTRING(@Container,11,1) As SpecifiedCheckSumDigit

IF SUBSTRING(@Container,11,1) != @CalculatedCheckSumDigit
BEGIN
	SELECT @IsISO = 'false', @Message='Container Number check-sum digit (last position) calculation failed'
	--SELECT @IsISO As IsISO, @Message As Message
	RETURN @IsISO
END

-- Everything checked-out! Looking good!
SELECT @IsISO = 'true', @Message='Container Number is valid'
--SELECT @IsISO As IsISO, @Message As Message
RETURN @IsISO

END
GO
