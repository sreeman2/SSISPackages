/****** Object:  UserDefinedFunction [dbo].[ufn_GetBolNumberFromBolData]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetBolNumberFromBolData]
(
	@BolData varchar(57)
)
RETURNS varchar(16)
AS
BEGIN

DECLARE @BolNumber varchar(16);

SELECT @BolData=ltrim(rtrim(@BolData));

IF(len(@BolData)>10)
	SELECT @BolNumber = substring(@BolData,10,16)
	--SELECT @BolNumber = substring(@BolData,10,(len(@BolData)-9))
ELSE
	SELECT @BolNumber = ''

RETURN @BolNumber

END
GO
