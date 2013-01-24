/****** Object:  UserDefinedFunction [dbo].[ufn_ValidateContainerType]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_ValidateContainerType]
(
	@Container_Type varchar(10)
)
RETURNS bit
AS
BEGIN

DECLARE @IsValidContainerType bit, @Message varchar(1024)
DECLARE @LengthIndex int, @WidthIndex int, @TypeIndex int
SELECT @IsValidContainerType = 'false', @Message=''

-- Convert to upper-case and trim extra spaces
SELECT @Container_Type = LTRIM(RTRIM(UPPER(@Container_Type)))

-- Is length 4 characters
DECLARE @Length int
SELECT @Length = LEN(isnull(@Container_Type,''))
--SELECT @Length As Length
IF @Length != 4
BEGIN
	SELECT @IsValidContainerType = 'false', @Message='Container Number should be 4 characters long'
	RETURN @IsValidContainerType
END

--Validate first character
SELECT @LengthIndex = PATINDEX('%'+SUBSTRING(@Container_Type,1,1)+'%','1234ABCDEFGHKLMNP')
IF @LengthIndex = 0
BEGIN
	SELECT @IsValidContainerType = 'false', @Message='Container Length Code is not valid'
	RETURN @IsValidContainerType
END

--Validate second character
SELECT @WidthIndex = PATINDEX('%'+SUBSTRING(@Container_Type,2,1)+'%','0245689CDEFLMNP')
IF @WidthIndex = 0
BEGIN
	SELECT @IsValidContainerType = 'false', @Message='Container Length Code is not valid'
	RETURN @IsValidContainerType
END

--Validate last 2 characters
SELECT @TypeIndex = PATINDEX('%'+SUBSTRING(@Container_Type,3,2)+'%',
	'G0 G1 G2 G3 V0 V2 V4 B0 B1 B3 B4 B5 B6 S0 S1 S2 R0 R1 R2 R3 ' +
	'H0 H1 H2 H5 H6 U0 U1 U2 U3 U4 U5 P0 P1 P2 P3 P4 P5 ' +
	'T0 T1 T2 T3 T4 T5 T6 T7 T8 T9 A0 ')
IF @TypeIndex = 0 OR LEN(LTRIM(SUBSTRING(@Container_Type,3,2)))<2
BEGIN
	SELECT @IsValidContainerType = 'false', @Message='Container Type Code is not valid'
	RETURN @IsValidContainerType
END


-- Everything checked-out! Looking good!
SELECT @IsValidContainerType = 'true', @Message='Container Number is valid'
RETURN @IsValidContainerType

END
GO
