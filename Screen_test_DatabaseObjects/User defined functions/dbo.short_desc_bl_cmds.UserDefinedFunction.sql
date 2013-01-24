/****** Object:  UserDefinedFunction [dbo].[short_desc_bl_cmds]    Script Date: 01/03/2013 19:53:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[short_desc_bl_cmds] (@strIn  VARCHAR(8000),@CMD_CD1 VARCHAR(10)) RETURNS
VARCHAR(8000) AS
BEGIN
DECLARE @partStr VARCHAR(8000)
DECLARE  @tempStr VARCHAR(8000)
DECLARE @exStr   VARCHAR(8000)
DECLARE @pos     INT
DECLARE @pos2 INT
DECLARE @TEMP1 VARCHAR(8000)
DECLARE @TEMP2 VARCHAR(8000)
DECLARE @TEMP3 VARCHAR(8000)
DECLARE @FLG INT

SET @FLG=0

  SET   @pos = CHARINDEX('<:',@strIn)
 SET @partStr=''
      SET    @exStr = SUBSTRING(@strIn,@pos + 3,LEN(@strIn))
      SET    @tempStr = @exStr
  
IF @pos=0
SET @partStr='NO TOKENS FOUND'


		while (@pos>0)
		BEGIN
        SET     @pos2 = CHARINDEX('>',@exStr)
		SET @TEMP1=SUBSTRING(@exStr,1,@pos2-1 )
		IF @TEMP1='%-/!:.,''\34;()[]*^$#@'
		GOTO LEVEL1
		SET @TEMP1=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TEMP1,'\',' '),',',' '),'.',' '),'''',''),'\\',' '),'/',' '),'(',' '),')',' '),'_',' '),'%',' ')
		IF LEN(@TEMP1)>3 AND (SUBSTRING(@TEMP1,LEN(@TEMP1),1)='S')
		BEGIN
		SET @TEMP2=''
		SET @TEMP3=SUBSTRING(@TEMP1,1,LEN(@TEMP1)-1)
		SELECT @TEMP2=PIERSWORD FROM PES.DBO.PES_REF_SYNONYM WITH (NOLOCK) WHERE AMSWORD=@TEMP3
		END
		ELSE IF LEN(@TEMP1)>3 
		BEGIN
		SET @TEMP2=''
		SELECT @TEMP2=PIERSWORD FROM PES.DBO.PES_REF_SYNONYM WITH (NOLOCK) WHERE AMSWORD=@TEMP1
		END
		IF (@TEMP2 IS NOT NULL) AND LEN(@TEMP2)>0
		SET @TEMP1=@TEMP2
		IF PATINDEX('%[0-9]%', @TEMP1) <> 0
		SET @FLG=1
				
		IF @FLG=1 AND (SUBSTRING(@TEMP1,1,2)='UN' OR SUBSTRING(@TEMP1,LEN(@TEMP1)-1,2)='UN')
		SET @FLG=0
		ELSE IF (@FLG=1 AND SUBSTRING(@CMD_CD1,1,3)='870')
			SET @FLG=0

		IF @FLG=0
		SET    @partStr = @partStr +LTRIM(RTRIM(@TEMP1 ))+' '
		LEVEL1:
        SET    @pos = CHARINDEX('<:',@exStr)
        SET    @exStr = SUBSTRING(@exStr,@pos + 3,LEN(@exStr))
		SET @FLG=0
		SET @TEMP2=''
        END

     RETURN RTRIM(@partStr)
END
GO
