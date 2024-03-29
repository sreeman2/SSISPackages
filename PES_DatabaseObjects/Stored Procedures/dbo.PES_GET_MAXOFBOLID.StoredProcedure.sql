/****** Object:  StoredProcedure [dbo].[PES_GET_MAXOFBOLID]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_GET_MAXOFBOLID]
as
begin

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


--DECLARE @TRANNAME VARCHAR(20),@FILE VARCHAR(500),@FILE_NAME VARCHAR(50)
--DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),
--@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50)
--SET @TRANNAME = 'MyTransaction'
--SELECT @FILE = PATH FROM PES_CONFIGURATION WHERE SOURCE='SP_LOG'
--SELECT @FILE_NAME= FILENAME FROM PES_PROGRESS_STATUS WHERE LOADNUMBER=(SELECT DISTINCT LOAD_NUMBER FROM RAW_BOL)
--SET @FILE='"'+@FILE+@FILE_NAME+'_LOG.TXT'+'"'
--
--SET @CMD = 'ECHO PROCEDURE PES_GET_MAXOFBOLID EXECUTION STARTED' + '>>'+ @FILE
--EXEC MASTER..XP_CMDSHELL @CMD 
--
--BEGIN TRANSACTION @TRANNAME

--BEGIN TRY 

declare @Max_BOL_ID int
declare @Max_RAW_BOL_ID int
set @Max_BOL_ID=(select max(BOL_ID) from PES_MAX_OF_BOLID)

update raw_BOL set BOL_ID=BOL_ID + @Max_BOL_ID
update raw_CMD set BOL_ID=BOL_ID + @Max_BOL_ID
update raw_CNTR set BOL_ID=BOL_ID + @Max_BOL_ID
update raw_HZMT set BOL_ID=BOL_ID + @Max_BOL_ID
update RAW_PTY set BOL_ID=BOL_ID + @Max_BOL_ID
update raw_MAN set BOL_ID=BOL_ID + @Max_BOL_ID

set @Max_RAW_BOL_ID=(select Max(BOL_ID)from raw_BOL)

insert into PES_MAX_OF_BOLID(BOL_ID)values(@Max_RAW_BOL_ID)

--END TRY
--
--BEGIN CATCH
--	SET @ERROR_NUMBER=ERROR_NUMBER()
--	SET @ERROR_LINE=ERROR_LINE()
--	SET @ERROR_MESSAGE='STORED PROCEDURE PES_GET_MAXOFBOLID FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
--	
--	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE
--	EXEC master..xp_cmdshell @CMD 
--    SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE
--	EXEC master..xp_cmdshell @CMD 
--	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE
--	EXEC master..xp_cmdshell @CMD 
--	
--	ROLLBACK TRANSACTION @TRANNAME
--	SET @CMD = 'ECHO TRANSACTIONS ROLLBACKED'+ ' >> '+ @FILE
--	EXEC master..xp_cmdshell @CMD 
--	RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG
--END CATCH
--
--	--COMMITTING THE TRANSACTIONS IF NO ERROR OCCURRED
--	COMMIT TRANSACTION @TRANNAME
--	SET @cmd = 'ECHO PROCEDURE PES_GET_MAXOFBOLID EXECUTED SUCCESSFULLY'+ ' >> '+ @FILE
--	EXEC master..xp_cmdshell @CMD


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT


end
GO
