/****** Object:  StoredProcedure [dbo].[JOCS_SP_UPDATE_SSISTRIGGERSTATUS]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[JOCS_SP_UPDATE_SSISTRIGGERSTATUS]
@LOAD_NUMBER [int], 
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

if((select count(SSIS_STATUS) from JOCS_PROGRESS_STATUS where SSIS_STATUS = 'Running')= 0 and (select count(BIZ_STATUS) from JOCS_PROGRESS_STATUS where BIZ_STATUS = 'Triggered')= 0 )
 begin
  UPDATE dbo.JOCS_PROGRESS_STATUS
  SET
  BIZ_STATUS = 'Triggered'
  WHERE LOAD_NUMBER = @LOAD_NUMBER
  SET NOCOUNT ON
  select @BIZ_RETURNSTATUS = BIZ_STATUS from dbo.JOCS_PROGRESS_STATUS WHERE LOAD_NUMBER = @LOAD_NUMBER
end
else
begin
 UPDATE dbo.JOCS_PROGRESS_STATUS
  SET
  BIZ_STATUS = 'Waiting'
  WHERE LOAD_NUMBER = @LOAD_NUMBER
  select @BIZ_RETURNSTATUS = BIZ_STATUS from dbo.JOCS_PROGRESS_STATUS WHERE LOAD_NUMBER = @LOAD_NUMBER
end 


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

return 
	
END
GO
