/****** Object:  StoredProcedure [dbo].[PES_SP_EMAIL]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_EMAIL] @SUBJECT1 VARCHAR(100)='',@STATEMENT VARCHAR(100)='', @ERROR_MESSAGE VARCHAR(MAX)='',@ERROR_LINE VARCHAR(50)='',@ERROR_NUMBER VARCHAR(50)=''  
AS  
BEGIN  

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

 DECLARE @tableHTML  NVARCHAR(MAX)  
 DECLARE @MAIL_RECIPIENTS VARCHAR(1000),@BODY1 VARCHAR(1000)  
 SELECT @MAIL_RECIPIENTS=ToAddress from METAMAILADDRESS WITH (NOLOCK)   
   
 IF ltrim(@ERROR_MESSAGE) <> ''   
	SET @tableHTML =  
	'Hi Support Team,' + CHAR(10) + CHAR(10) +
	@STATEMENT + CHAR(10) + 
	'Error Message-- ' + @ERROR_MESSAGE + CHAR(10) + 
	'Error Line-- ' + @ERROR_LINE +  CHAR(10) +  
	'Error Number-- ' + @ERROR_NUMBER + CHAR(10) + CHAR(10) +
	'Thanks,' +  CHAR(10) + 'PES' + CHAR(10) + CHAR(10) +   
	'Note :This is a System Generated EMail. Please do not respond to this EMail.'
   
ELSE 
	SET @tableHTML =  
	'Hi Support Team,' + char(10) + char(10) +  
	@STATEMENT + char(10) + char(10) + 
	'Thanks,' + char(10) + 'PES' +  char(10) + char(10) + 
	'Note :This is a System Generated EMail. Please do not respond to this EMail.'  
    
EXEC msdb.dbo.sp_send_dbmail @recipients=@MAIL_RECIPIENTS,  
  @subject = @SUBJECT1,  
  @body = @tableHTML,  
  @body_format = 'TEXT'  

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
