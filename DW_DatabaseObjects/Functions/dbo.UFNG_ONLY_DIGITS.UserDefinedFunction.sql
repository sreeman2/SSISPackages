/****** Object:  UserDefinedFunction [dbo].[UFNG_ONLY_DIGITS]    Script Date: 01/08/2013 14:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UFNG_ONLY_DIGITS] (@StrVal AS VARCHAR(max))
RETURNS VARCHAR(max)
AS
BEGIN
      WHILE PATINDEX('%[^0-9]%', @StrVal) > 0
            SET @StrVal = REPLACE(@StrVal,
                SUBSTRING(@StrVal,PATINDEX('%[^0-9]%', @StrVal),1),'')
      RETURN @StrVal
END
GO
