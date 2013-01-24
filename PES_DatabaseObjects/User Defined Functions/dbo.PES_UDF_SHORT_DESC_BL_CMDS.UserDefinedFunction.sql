/****** Object:  UserDefinedFunction [dbo].[PES_UDF_SHORT_DESC_BL_CMDS]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PES_UDF_SHORT_DESC_BL_CMDS] (@STRIN  VARCHAR(8000),@CMD_CD1 VARCHAR(10)) RETURNS
VARCHAR(8000) AS
BEGIN
DECLARE @PARTSTR VARCHAR(8000)
DECLARE  @TEMPSTR VARCHAR(8000)
DECLARE @EXSTR   VARCHAR(8000)
DECLARE @POS     INT
DECLARE @POS2 INT
DECLARE @TEMP1 VARCHAR(8000)
DECLARE @TEMP2 VARCHAR(8000)
DECLARE @TEMP3 VARCHAR(8000)
DECLARE @FLG INT

SET @FLG=0

  SET   @POS = CHARINDEX('<:',@STRIN)
 SET @PARTSTR=''
      SET    @EXSTR = SUBSTRING(@STRIN,@POS + 3,LEN(@STRIN))
      SET    @TEMPSTR = @EXSTR
  
IF @POS=0
SET @PARTSTR='NO TOKENS FOUND'


		WHILE (@POS>0)
		BEGIN
        SET     @POS2 = CHARINDEX('>',@EXSTR)
		SET @TEMP1=SUBSTRING(@EXSTR,1,@POS2-1 )
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
		SET    @PARTSTR = @PARTSTR +LTRIM(RTRIM(@TEMP1))+' '
		LEVEL1:
        SET    @POS = CHARINDEX('<:',@EXSTR)
        SET    @EXSTR = SUBSTRING(@EXSTR,@POS + 3,LEN(@EXSTR))
		SET @FLG=0
		SET @TEMP2=''
        END

     RETURN RTRIM(@PARTSTR)
END
GO
