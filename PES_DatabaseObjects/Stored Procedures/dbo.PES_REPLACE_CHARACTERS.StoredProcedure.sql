/****** Object:  StoredProcedure [dbo].[PES_REPLACE_CHARACTERS]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_REPLACE_CHARACTERS]   
@STRING_IN VARCHAR(5),@STRING_OUT VARCHAR(5) OUTPUT

AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @TRANNAME VARCHAR(20),@FILE VARCHAR(500),@FILE_NAME VARCHAR(50)
DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),
@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50)
SET @TRANNAME = 'MyTransaction'

BEGIN TRANSACTION @TRANNAME

BEGIN TRY 
    DECLARE @IncorrectCharLoc SMALLINT, @TEMP CHAR(1)
	SET @STRING_OUT=@STRING_IN
	SELECT @STRING_OUT=SUBSTRING(@STRING_OUT,(PATINDEX('%[^0]%',
@STRING_OUT)),LEN(@STRING_OUT))
     SET @IncorrectCharLoc = PATINDEX('%[^0-9]%', 
	@STRING_OUT)
	 WHILE @IncorrectCharLoc > 0
     BEGIN
		SET @TEMP=SUBSTRING(@STRING_OUT,@IncorrectCharLoc,1)
        SET @STRING_OUT = REPLACE(@STRING_OUT, @TEMP,'')
		
        SET @IncorrectCharLoc = PATINDEX('%[^0-9]%', 
		@STRING_OUT)
     END

	--COMMITTING THE TRANSACTIONS IF NO ERROR OCCURRED
	COMMIT TRANSACTION @TRANNAME
END TRY

BEGIN CATCH
	SET @ERROR_NUMBER=ERROR_NUMBER()
	SET @ERROR_LINE=ERROR_LINE()
	SET @ERROR_MESSAGE='STORED PROCEDURE PES_REPLACE_CHARACTERS FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
	SELECT @FILE = PATH FROM PES_CONFIGURATION WHERE SOURCE='SP_LOG'
SELECT @FILE_NAME= FILENAME FROM PES_PROGRESS_STATUS WHERE LOADNUMBER=(SELECT DISTINCT LOAD_NUMBER FROM RAW_BOL)
SET @FILE='"'+@FILE+@FILE_NAME+'_LOG.TXT'+'"'

	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
    SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	
	
	SET @CMD = 'ECHO TRANSACTIONS ROLLBACKED'+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG

	ROLLBACK TRANSACTION @TRANNAME
END CATCH


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
