/****** Object:  StoredProcedure [dbo].[usp_ProcessLogCreate]    Script Date: 01/03/2013 19:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProcessLogCreate]
	 @ProcessName varchar(100)
	,@Direction varchar(100)
	,@IdProcessLog int OUT
	,@Comment varchar(MAX) = NULL
AS
BEGIN
	SET @IdProcessLog = -1

	DECLARE @IdProcess int
	SELECT @IdProcess=IdProcess FROM ProcessDefinition WHERE ProcessName = @ProcessName

	IF @IdProcess IS NULL
	BEGIN
		DECLARE @Error varchar(100)
		SET @Error = 'Invalid @ProcessName ' + @ProcessName + ' specified!'
		RAISERROR(@Error,16,1)
		RETURN
	END

	INSERT INTO ProcessLog
	 (IdProcess,Direction,StartDate,Status,Comments)
	VALUES
	 (@IdProcess,@Direction,getdate(),'Running',COALESCE(CONVERT(VARCHAR,GETDATE(),109) + ': ' + @Comment,''))

	SET @IdProcessLog = @@IDENTITY
END
GO
