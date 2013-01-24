/****** Object:  StoredProcedure [dbo].[UPDATE_LOGOUT_INFO]    Script Date: 01/03/2013 19:48:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <4th Nov 2010>
-- Description:	<Updating the Logout information when the user logs out of the application>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_LOGOUT_INFO]
	-- Add the parameters for the stored procedure here
	@USERNAME VARCHAR(MAX), 
	@LOG_SEQ_NUM INT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE PEA_USER_LOG WITH (UPDLOCK) 
	SET LOGOUT = getdate() 
	WHERE USER_ID = @USERNAME 
	AND LOG_SEQ_NO = @LOG_SEQ_NUM

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
