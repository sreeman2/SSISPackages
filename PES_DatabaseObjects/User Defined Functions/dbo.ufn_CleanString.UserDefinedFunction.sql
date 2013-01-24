/****** Object:  UserDefinedFunction [dbo].[ufn_CleanString]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_CleanString](
	@InputString VARCHAR(MAX)
	--,@ReplaceChar char(1)
)
-- Usage: SELECT dbo.ufn_CleanString('se+*a r%c&h^da#tab~se@9')--,'_')
RETURNS VARCHAR(MAX)
AS
BEGIN   

DECLARE @ReplaceChar char(1)
SELECT @ReplaceChar = ''

DECLARE @Result VARCHAR(MAX)
DECLARE @badcodes TABLE (badcode INT)

DECLARE @mycode INT
SET @mycode=33
WHILE @mycode<=255
BEGIN
	IF NOT ((@mycode BETWEEN 48 AND 57) -- i.e. 0 to 9
		 OR (@mycode BETWEEN 65 AND 90) -- i.e. A to Z
		 OR (@mycode BETWEEN 97 AND 122) -- i.e. a to z
			)
		INSERT INTO @badcodes SELECT @mycode
	SET @mycode=@mycode+1
END

SET @Result = @InputString
-- Remove spaces
SET @Result=REPLACE(@Result,' ',@ReplaceChar)

-- Remove non-alphanumeric characters
UPDATE @badcodes
SET @Result=REPLACE(@Result,CHAR(badcode),@ReplaceChar)
--PRINT @Result


RETURN(@Result)
END
GO
