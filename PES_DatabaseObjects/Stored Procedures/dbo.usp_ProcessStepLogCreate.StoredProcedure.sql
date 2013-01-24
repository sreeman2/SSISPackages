/****** Object:  StoredProcedure [dbo].[usp_ProcessStepLogCreate]    Script Date: 01/03/2013 19:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProcessStepLogCreate]
	 @IdProcessLog int
	,@StepName varchar(100)
	,@IdProcessStepLog int OUT
AS
BEGIN
	SET @IdProcessStepLog = -1

	DECLARE @IdProcessStep int
	SELECT @IdProcessStep=IdProcessStep FROM ProcessStepDefinition WHERE StepName = @StepName

	IF @IdProcessStep IS NULL
	BEGIN
		DECLARE @Error varchar(100)
		SET @Error = 'Invalid @StepName ' + @StepName + ' specified!'
		RAISERROR(@Error,16,1)
		RETURN
	END

	INSERT INTO ProcessStepLog
	 (IdProcessLog,IdProcessStep,StartDate)
	VALUES
	 (@IdProcessLog,@IdProcessStep,getdate())

	SET @IdProcessStepLog = @@IDENTITY
END
GO
