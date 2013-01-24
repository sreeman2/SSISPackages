/****** Object:  StoredProcedure [dbo].[JOCS_SP_ERROR_STATUS]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[JOCS_SP_ERROR_STATUS]
 
@LOAD_NUMBER [int], 
@BIZ_END_TIME datetime,
@BIZ_STATUS varchar(10),
@BIZ_RETURNSTATUS  varchar(10) output 
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

UPDATE dbo.JOCS_PROGRESS_STATUS
SET
 BIZ_END_TIME = @BIZ_END_TIME,
 BIZ_STATUS = @BIZ_STATUS
WHERE LOAD_NUMBER = @LOAD_NUMBER
SET NOCOUNT ON
select @BIZ_RETURNSTATUS = BIZ_STATUS from dbo.JOCS_PROGRESS_STATUS WHERE LOAD_NUMBER = @LOAD_NUMBER

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

return 

END
GO
