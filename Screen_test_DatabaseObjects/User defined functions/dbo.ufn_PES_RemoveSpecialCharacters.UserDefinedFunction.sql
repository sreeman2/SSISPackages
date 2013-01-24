/****** Object:  UserDefinedFunction [dbo].[ufn_PES_RemoveSpecialCharacters]    Script Date: 01/03/2013 19:53:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_PES_RemoveSpecialCharacters] 
(  
@STRING_IN VARCHAR(500)
)
RETURNS VARCHAR(500)
AS
BEGIN
    DECLARE @STRING_OUT VARCHAR(500) 
 DECLARE @IncorrectCharLoc INT,@IncorrectChar CHAR(1)
    SET @STRING_OUT=@STRING_IN
 SET @IncorrectCharLoc = PATINDEX('%[^.0-9A-Za-z&]%',@STRING_IN)
    WHILE @IncorrectCharLoc > 0
    BEGIN
  SET @IncorrectChar=SUBSTRING(@STRING_OUT,@IncorrectCharLoc,1)
        SET @STRING_OUT = REPLACE(@STRING_OUT,@IncorrectChar,'')
  SET @IncorrectCharLoc = PATINDEX('%[^.0-9A-Za-z&]%',@STRING_OUT)
 END
RETURN @STRING_OUT
END
GO
