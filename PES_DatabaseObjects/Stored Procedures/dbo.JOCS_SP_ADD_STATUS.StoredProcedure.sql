/****** Object:  StoredProcedure [dbo].[JOCS_SP_ADD_STATUS]    Script Date: 01/03/2013 19:40:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[JOCS_SP_ADD_STATUS]
@LOAD_DATE  datetime,
@SRC_FILENAME  varchar(100),
@BIZ_START_TIME datetime,
@BIZ_STATUS varchar(10), 
@LOAD_NUMBER int output

as
Begin

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

insert into dbo.JOCS_PROGRESS_STATUS  
 (
   LOAD_DATE ,
   SRC_FILENAME ,
   BIZ_START_TIME ,
   BIZ_STATUS
  )
values
(
   @LOAD_DATE,
   @SRC_FILENAME,
   @BIZ_START_TIME,
   @BIZ_STATUS
 )
SET NOCOUNT ON
SELECT @LOAD_NUMBER =LOAD_NUMBER FROM dbo.JOCS_PROGRESS_STATUS where SRC_FILENAME = @SRC_FILENAME and BIZ_START_TIME = @BIZ_START_TIME

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

return 
END
GO
