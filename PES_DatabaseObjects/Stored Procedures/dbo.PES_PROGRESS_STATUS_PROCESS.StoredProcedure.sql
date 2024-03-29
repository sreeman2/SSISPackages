/****** Object:  StoredProcedure [dbo].[PES_PROGRESS_STATUS_PROCESS]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_PROGRESS_STATUS_PROCESS] @LOADNUM VARCHAR(100),
@FIELDNAME VARCHAR(50),@EXCEPTION VARCHAR(50)=1
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @FullInsertStatement NVARCHAR(1000)
DECLARE @FullUpdateStatement NVARCHAR(1000)
DECLARE @FullUpdateStatement1 NVARCHAR(1000)

IF @LOADNUM =''
BEGIN
SET @LOADNUM=(SELECT TOP 1 LOAD_NUMBER FROM RAW_BOL)
END
SET @FullUpdateStatement='UPDATE PES_PROGRESS_STATUS WITH(UPDLOCK) SET '+@FIELDNAME +'='+@EXCEPTION+' WHERE LOADNUMBER='+@LOADNUM

SET @FullUpdateStatement1='UPDATE PES_PROGRESS_STATUS WITH(UPDLOCK) SET '+@FIELDNAME +'='+@EXCEPTION+' WHERE FILENAME='''+@LOADNUM+''''


IF ISNUMERIC(@LOADNUM)=1
BEGIN
EXECUTE sp_executesql @FullUpdateStatement
END
ELSE
BEGIN
SET @FullInsertStatement='INSERT INTO PES_PROGRESS_STATUS([FILENAME],'+@FIELDNAME+') VALUES('''+@LOADNUM+''','+@EXCEPTION+')'
IF @LOADNUM NOT IN (SELECT DISTINCT [FILENAME] FROM dbo.PES_PROGRESS_STATUS WITH (NOLOCK) )
EXECUTE sp_executesql @FullInsertStatement
ELSE
EXECUTE sp_executesql @FullUpdateStatement1

END 


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
