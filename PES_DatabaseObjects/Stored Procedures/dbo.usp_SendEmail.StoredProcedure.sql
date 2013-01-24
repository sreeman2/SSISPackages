/****** Object:  StoredProcedure [dbo].[usp_SendEmail]    Script Date: 01/03/2013 19:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- Sample call
DECLARE @SendEmailOutput varchar(MAX), @SendEmailSuccess bit
EXEC dbo.usp_SendEmail
  @To		= 'aawasthi@piers.com'
 ,@From		= 'PIERS-NoReply@piers.com'
 ,@Subject	= 'Test email from PES - usp_SendEmail'
 ,@Body		= 'This is a test email from the PES Staging db server'
 ,@Success	= @SendEmailSuccess OUT
 ,@Output	= @SendEmailOutput OUT
SELECT @SendEmailSuccess, @SendEmailOutput
*/
CREATE PROCEDURE [dbo].[usp_SendEmail]
	 @To nvarchar(MAX)
	,@From nvarchar(MAX)
	,@Subject nvarchar(MAX)
	,@Body nvarchar(MAX)
	,@Success bit OUT
	,@Output nvarchar(MAX) OUT
AS
BEGIN
	SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	DECLARE @NEWLINE char(2)
	SET @NEWLINE = '\n'

	DECLARE @MailServer varchar(100), @MailUtilPath varchar(100)
	SET @MailUtilPath = 'E:\PES\MailUtil\postie.exe'
	SET @MailServer = '10.31.60.164' --'nwexchange01.joc.net'

	SELECT @Body = REPLACE(REPLACE(REPLACE(@Body,CHAR(13)+CHAR(10),'\n'),CHAR(13),'\n'),CHAR(10),'\n')
	SELECT @Body = REPLACE(REPLACE(REPLACE(@Body,'<br />','\n'),'<br >','\n'),'<br>','\n')
	SELECT @Body = @Body + @NEWLINE + @NEWLINE
		+ 'PES - PIERS - GT - UBM' + @NEWLINE
		+ '-----------------------------------' + @NEWLINE
		+ 'Please do not reply to this email!' + @NEWLINE
		+ 'In case of any questions, please contact dataprocessing@joc.com'

	--PESTechSupportTeam@piers.com

	DECLARE @MailUtilCommand varchar(8000)
	SET @MailUtilCommand =
	  @MailUtilPath
	+ ' -host:' + @MailServer
	+ ' -to:"' + REPLACE(LTRIM(RTRIM(@To)),';',',') + '"'
	+ ' -from:"' + @From + '"'
	+ ' -s:"' + @Subject + '"'
	--+ ' -a:"D:\Downloads\xyz.mdb"
	+ ' -msg:"' + REPLACE(LTRIM(RTRIM(@Body)),'"','''') + '"'
	--+ ' >> "E:\PES\MailUtil\log\usp_SendEmail.log'

	PRINT '@MailUtilCommand: ' + @MailUtilCommand

	DECLARE @MailUtilOutput TABLE (s varchar(MAX))
	INSERT @MailUtilOutput
	 EXEC master..xp_CMDShell @MailUtilCommand
	DELETE @MailUtilOutput WHERE s IS NULL

	-- In case of success, output looks like...
	--  ... Sent 471 bytes into 'xyz@piers.com' Tue Nov 17 11:59:19 2009
	SELECT TOP 1 @Output = COALESCE(s,'--') FROM @MailUtilOutput
	IF @Output LIKE '%Sent%bytes into%'
		SET @Success = 'True'
	ELSE
		SET @Success = 'False'


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
