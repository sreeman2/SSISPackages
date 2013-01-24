/****** Object:  StoredProcedure [dbo].[usp_LoadStepLogCreate]    Script Date: 01/09/2013 18:40:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LoadStepLogCreate]
	 @IdLoadLog int
	,@StepName varchar(100)
	,@IdLoadStepLog int OUT
AS
BEGIN
	SET @IdLoadStepLog = -1

	DECLARE @IdLoadStep int
	SELECT @IdLoadStep=IdLoadStep FROM LoadStepDefinition WHERE StepName = @StepName

	IF @IdLoadStep IS NULL
	BEGIN
		DECLARE @Error varchar(100)
		SET @Error = 'Invalid @StepName ' + @StepName + ' specified!'
		RAISERROR(@Error,16,1)
		RETURN
	END

	INSERT INTO LoadStepLog
	 (IdLoadLog,IdLoadStep,StartDate)
	VALUES
	 (@IdLoadLog,@IdLoadStep,getdate())

	SET @IdLoadStepLog = @@IDENTITY
END
GO
