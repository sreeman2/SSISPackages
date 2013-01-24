/****** Object:  StoredProcedure [dbo].[PES_SendEmail_BOL_CMD_COUNTS]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SendEmail_BOL_CMD_COUNTS]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @SendEmailOutput VARCHAR(MAX), @SendEmailSuccess BIT
		DECLARE @FromAddress VARCHAR(MAX), @ToAddress VARCHAR(MAX)
		DECLARE @iRecordCountBOL VARCHAR(MAX), @iRecordCountCMD VARCHAR(MAX), @BodyMail VARCHAR(MAX)

		SELECT @FromAddress = FROMADDRESS, @ToAddress =	TOADDRESS FROM METAMAILADDRESS WITH (NOLOCK) 
		SET @ToAddress = @ToAddress +';pes.tech.support.team@joc.com'

		SELECT @iRecordCountBOL = COUNT(A.BOL_ID) FROM PES_STG_BOL A   WITH  (NOLOCK)  
		INNER JOIN PES_STG_TEMP_BOL_ID B   WITH  (NOLOCK) ON 
			A.BOL_ID = B.BOL_ID

		SELECT @iRecordCountCMD = COUNT(A.CMD_ID) FROM PES_STG_CMD A   WITH  (NOLOCK)   
			INNER JOIN PES_STG_TEMP_BOL_ID B   WITH  (NOLOCK) ON 
				A.BOL_ID=B.BOL_ID

		SET @BodyMail = 'Hi Team \n\n' +@iRecordCountBOL+ ' records of BOL and '+@iRecordCountCMD+' records of CMD are updated from staging to DW'

		EXEC PES.dbo.usp_SendEmail
		  @To		= @ToAddress
		 ,@From		= @FromAddress
		 ,@Subject	= 'PES: Records update status - Staging to DW'
		 ,@Body		= @BodyMail
		 ,@Success	= @SendEmailSuccess OUT
		 ,@Output	= @SendEmailOutput OUT
		SELECT @SendEmailSuccess, @SendEmailOutput

	END TRY
	BEGIN CATCH
	END CATCH

END
GO
