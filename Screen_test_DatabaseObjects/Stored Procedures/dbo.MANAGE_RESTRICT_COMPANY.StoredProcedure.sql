/****** Object:  StoredProcedure [dbo].[MANAGE_RESTRICT_COMPANY]    Script Date: 01/03/2013 19:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MANAGE_RESTRICT_COMPANY]
	@COMP_ID					INT,
	@RSTRCTN_CODE			TINYINT,
	@RSTRCTN_MODE			TINYINT,
	@START_DT					DATETIME,
	@EXPIRY_DT					DATETIME,
	@RSTRCTN_CODE_MODIFIED	CHAR(1) =NULL,
	@MODIFIED_BY				VARCHAR(25),
	@INSERT_MODE				CHAR(1)	
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


IF ( @INSERT_MODE = 'Y' )
BEGIN
	INSERT INTO PES.dbo.PES_COMPANY_RESTRICTION_INFO
	   ([COMP_ID]
	   ,[RESTRICTION_CODE]
	   ,[RESTRICTION_MODE]
	   ,[START_DT]
	   ,[EXPIRY_DT]
	   ,[RESTRICTION_CODE_MODIFIED]
	   ,[MODIFIED_BY]
	)
	VALUES
	(
		@COMP_ID,
		@RSTRCTN_CODE,
		@RSTRCTN_MODE,
		@START_DT, 
		@EXPIRY_DT,
		@RSTRCTN_CODE_MODIFIED,
		@MODIFIED_BY
	)
	
END
ELSE
BEGIN
	--UPDATE 
	UPDATE PES.dbo.PES_COMPANY_RESTRICTION_INFO WITH (UPDLOCK)
	SET [RESTRICTION_CODE] = @RSTRCTN_CODE,
	    [RESTRICTION_MODE] = @RSTRCTN_MODE,
		[START_DT] = @START_DT,
		[EXPIRY_DT] = @EXPIRY_DT,
		[RESTRICTION_CODE_MODIFIED] = @RSTRCTN_CODE_MODIFIED,
		[MODIFIED_BY] = @MODIFIED_BY
	WHERE ( [COMP_ID] = @COMP_ID )


END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
