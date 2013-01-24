/****** Object:  StoredProcedure [dbo].[UPDATE_RECORD_LOGIN]    Script Date: 01/03/2013 19:48:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <3rd Nov 2010>
-- Description:	<This Procedure will record the date/time into the PEA_USER_LOG Table 
--		when a user logs into the application.  The LOG_SEQ_NO is fetched from the 
--		PEA_USER_LOG for the specified username and a new row is inserted based on the UserName>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_RECORD_LOGIN]
	-- Add the parameters for the stored procedure here
	@userName varchar(max),
	@OUTseqNum int OUTPUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @SEQNUM INT
	SELECT @SEQNUM = (MAX(LOG_SEQ_NO)+1) FROM dbo.[PEA_USER_LOG] WITH (NOLOCK) 
	WHERE [USER_ID] = @userName
	-- in case this is the first time user is logging in, the record does not exist so set 
	--  @SEQNUM to 1
	SELECT @SEQNUM = COALESCE(@SEQNUM,1)

	INSERT INTO dbo.[PEA_USER_LOG] (USER_ID, LOG_SEQ_NO, LOGIN, LOGOUT)
	VALUES (@userName, @SEQNUM, GETDATE(), '')

	SET @OUTseqNum = @SEQNUM

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
