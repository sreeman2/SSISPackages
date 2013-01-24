/****** Object:  StoredProcedure [dbo].[UPDATE_REF_CUSTOM_HARMCODE]    Script Date: 01/03/2013 19:48:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <25th January 2010>
-- Description:	<Updating the CUSTOM HARMCODE Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_REF_CUSTOM_HARMCODE]  
	-- Add the parameters for the stored procedure here
   @harm_code varchar(max),
   @description varchar(max),
   @modif_by varchar(max),
   @rec_num varchar(max),
   @RETURN_VALUE int OUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @RECCOUNT int

	SELECT @RECCOUNT = COUNT(*) FROM PES.DBO.REF_HARM_CODES WITH (NOLOCK)
		WHERE HARM_CODE = @harm_code

	IF @RECCOUNT = 0 
		BEGIN
			UPDATE PES.dbo.REF_HARM_CODES WITH (UPDLOCK) 
				SET DESCRIPTION = @description,
					HARM_CODE  = @harm_code, 
					MODIFIED_BY = @modif_by,
					MODIFIED_DT = getdate() 
				WHERE REC_NUM = @rec_num
				SET @RETURN_VALUE = 0
		END
	ELSE
		BEGIN
			SET @RETURN_VALUE = 1
		END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
