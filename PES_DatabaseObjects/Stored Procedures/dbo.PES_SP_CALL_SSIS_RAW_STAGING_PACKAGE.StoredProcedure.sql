/****** Object:  StoredProcedure [dbo].[PES_SP_CALL_SSIS_RAW_STAGING_PACKAGE]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_CALL_SSIS_RAW_STAGING_PACKAGE]
@xml_ret XML OUTPUT
As
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


-- [aa] - 09/30/2010
-- Log - process started
DECLARE @ProcessName varchar(100), @IdProcessLog int
SELECT @ProcessName = 'FeedLoad-RawToStaging', @IdProcessLog = -1
EXEC dbo.usp_ProcessLogCreate @ProcessName, 'NA', @IdProcessLog OUT

Declare @PackagePath varchar(1000)
Declare @Command varchar(2000)
DECLARE @LOADNUM VARCHAR(50)
Declare @Result int
DECLARE @S6 INT
DECLARE @S7 INT
DECLARE @S8 INT
DECLARE @S9 INT
DECLARE @S10 INT
DECLARE @S11 INT

Set @PackagePath = 'E:\PIERS Enterprise Solution\StagingComponents\SSISPackage\PES_RAW_STAGING.dtsx'

SET @LOADNUM=(SELECT TOP 1 LOAD_NUMBER FROM RAW_BOL)


Set @command = 'dtexec -f ' + '"'+ @PackagePath + '"'
+ ' /set \Package.Variables[User::LOAD_NBR].Properties[Value];' + '"' + @LOADNUM + '"'

--TRUNCATE TABLE PES_XMLERROROUTPUT

CREATE TABLE #DTSErrorOutput 
     (ErrorString varchar(8000) NULL)
INSERT #DTSErrorOutput
EXEC @Result = xp_cmdshell @command

IF @Result > 1
Set @Result=1
IF @Result<>0
BEGIN

SELECT @S6=S5,@S7=S6,@S8=S7,@S9=S8,@S10=S9,@S11=S10 FROM PES_PROGRESS_STATUS  WITH (NOLOCK) WHERE  LOADNUMBER=@LOADNUM
IF @S10=1
BEGIN
IF @S11=0
EXEC PES_PROGRESS_STATUS_PROCESS @LOADNUM,'S10',2
END
ELSE
IF @S9=1
EXEC PES_PROGRESS_STATUS_PROCESS @LOADNUM,'S9',2
ELSE
IF @S8=1
EXEC PES_PROGRESS_STATUS_PROCESS @LOADNUM,'S8',2
ELSE
IF @S7=1
EXEC PES_PROGRESS_STATUS_PROCESS @LOADNUM,'S7',2
ELSE
IF @S6=1
EXEC PES_PROGRESS_STATUS_PROCESS @LOADNUM,'S6',2



SET @xml_ret = (SELECT  @Result as STATUS ,(SELECT  LTRIM(ErrorString)as ERROR FROM PES_XMLERROROUTPUT PES_RAW_FLAT_ERROR  
WHERE ErrorString like '%cannot%' or ErrorString like '%Err:%' 
FOR XML AUTO,TYPE )
FOR XML RAW,ELEMENTS,ROOT('SP_RAW_To_STAGING_RETURN_STATUS'))
END 
ELSE
BEGIN
--UPDATE PES_PROGRESS_STATUS SET FILE_PROCESS_STATUS='COMPLETE' WHERE LOADNUMBER=@LOADNUM
SET @xml_ret = (SELECT  @Result as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_RAW_To_STAGING_RETURN_STATUS'))
END

--TRUNCATE TABLE #DTSErrorOutput 

-- [aa] - 09/30/2010
-- Log - process completed
EXEC dbo.usp_ProcessLogUpdate @IdProcessLog, 'Successful', 'Done'

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT


END
GO
