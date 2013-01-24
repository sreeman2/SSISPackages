/****** Object:  UserDefinedFunction [dbo].[short_descComm]    Script Date: 01/03/2013 19:53:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[short_descComm] (@strIn  VARCHAR(8000)) RETURNS
VARCHAR(8000) AS
BEGIN
DECLARE @partStr VARCHAR(8000)
DECLARE  @tempStr VARCHAR(8000)
DECLARE @exStr   VARCHAR(8000)
DECLARE  @tempString VARCHAR(8000)
DECLARE  @PWORD VARCHAR(8000)
DECLARE @pos     INT
DECLARE @pos2 INT
SET   @pos = CHARINDEX(' ',@strIn)
IF @pos=0
 SET @partStr=@strIn
ELSE
  BEGIN
   SET @partStr=''
      SET    @exStr = @strIn
      SET    @tempStr = @exStr
  
while (@pos>0)
BEGIN
		SET     @pos2 = CHARINDEX(' ',@exStr)
	IF @pos2<>0
	SET  @tempString=SUBSTRING(@exStr,1,@pos2-1 )
	ELSE 
	BEGIN
	SET  @tempString=SUBSTRING(@exStr,1,@pos2)
	END

	IF LEN(@tempString)>3 AND (SUBSTRING(@tempString,LEN(@tempString),LEN(@tempString)))='S'
	BEGIN
	SET  @tempString=SUBSTRING(@tempString,1,LEN(@tempString)-1)
	END

		SELECT @PWORD=PIERSWORD FROM PES.DBO.PES_REF_SYNONYM WHERE AMSWORD=@tempString

	IF @PWORD IS NULL OR @PWORD= '' 
	SET @PWORD=@tempString

	IF @pos2<>0
	SET    @partStr = @partStr + LTRIM(RTRIM(@PWORD))+ ' '
	ELSE 
	SET    @partStr = @partStr + LTRIM(RTRIM(@PWORD))

	SET   @pos = CHARINDEX(' ',@exStr)

IF @pos=0
	SET    @exStr = LTRIM(RTRIM(SUBSTRING(@exStr,@pos,LEN(@exStr)+1)))
ELSE 
SET    @exStr = LTRIM(RTRIM(SUBSTRING(@exStr,@pos,LEN(@exStr))))
IF @pos=0
BEGIN
IF LEN(@exStr)>3 AND (SUBSTRING(@exStr,LEN(@exStr),LEN(@exStr)+1))='S'
	BEGIN
	SET  @exStr=SUBSTRING(@exStr,1,LEN(@exStr)-1)
	END

		SELECT @PWORD=PIERSWORD FROM PES.DBO.PES_REF_SYNONYM WHERE AMSWORD=@exStr


	IF @PWORD IS NULL OR @PWORD= '' 
	SET @PWORD=@exStr

SET    @partStr = @partStr + LTRIM(RTRIM(@PWORD))

END

SET @PWORD=''
END

END
RETURN @partStr
END
GO
