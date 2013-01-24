/****** Object:  UserDefinedFunction [dbo].[PES_UDF_PLACE_OF_RECEIPT]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PES_UDF_PLACE_OF_RECEIPT] 
(  
@STRING_IN VARCHAR(35)
)
RETURNS VARCHAR(35)
AS
BEGIN
    DECLARE @STRING_OUT VARCHAR(35) 
	DECLARE @IncorrectCharLoc INT,@TEMP CHAR,@Loc int

	SET @STRING_OUT=LTRIM(RTRIM(@STRING_IN))
	
	SET @IncorrectCharLoc = PATINDEX('%[^0-9A-Za-z& ]%',@STRING_OUT)
	IF @IncorrectCharLoc=3
	BEGIN
		SET @TEMP=SUBSTRING(@STRING_OUT,@IncorrectCharLoc,1)
		SET @STRING_OUT=REPLACE(@STRING_OUT,@TEMP,' ')
	END
	
	SET @IncorrectCharLoc = PATINDEX('%[^0-9A-Za-z& ]%',@STRING_OUT)
	IF @IncorrectCharLoc>1
		SET @STRING_OUT=SUBSTRING(@STRING_IN,1,@IncorrectCharLoc-1) 
	ELSE IF @IncorrectCharLoc=1
		SET @STRING_OUT=''

	SET @LOC=CHARINDEX(' ',@STRING_OUT)
	IF @LOC>0
	BEGIN
		SET @LOC=CHARINDEX(' ',SUBSTRING(@STRING_OUT,@LOC+1,LEN(@STRING_OUT)))
		IF @LOC>0
			SET @STRING_OUT=REVERSE(SUBSTRING(REVERSE(@STRING_OUT),CHARINDEX(' ',REVERSE(@STRING_OUT))+1,LEN(@STRING_OUT)))
	END


		



RETURN @STRING_OUT
END
GO
