/****** Object:  UserDefinedFunction [dbo].[short_desc]    Script Date: 01/03/2013 19:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[short_desc] (@strIn  VARCHAR(8000)) RETURNS
VARCHAR(8000) AS
BEGIN
DECLARE @partStr VARCHAR(8000)
DECLARE  @tempStr VARCHAR(8000)
DECLARE @exStr   VARCHAR(8000)
DECLARE @pos     INT
DECLARE @pos2 INT
  SET   @pos = CHARINDEX('<:',@strIn)
 SET @partStr=''
      SET    @exStr = SUBSTRING(@strIn,@pos + 3,LEN(@strIn))
      SET    @tempStr = @exStr
  
		while (@pos>0)
		BEGIN
        SET     @pos2 = CHARINDEX('>',@exStr)
--		
		IF @pos2 = 0
		SET @POS2 = 1
--		
		SET    @partStr = @partStr + SUBSTRING(@exStr,1,@pos2-1 )
		SET    @pos = CHARINDEX('<:',@exStr)
        SET    @exStr = SUBSTRING(@exStr,@pos + 3,LEN(@exStr))
        END

IF @partStr='' SET @partStr='NO TOKENS FOUND'
     RETURN @partStr
END
GO
