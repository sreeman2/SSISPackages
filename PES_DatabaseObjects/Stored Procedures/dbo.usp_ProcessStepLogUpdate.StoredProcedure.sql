/****** Object:  StoredProcedure [dbo].[usp_ProcessStepLogUpdate]    Script Date: 01/03/2013 19:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProcessStepLogUpdate]
	 @IdProcessStepLog int
	,@RowsAffected int
	,@Comment varchar(MAX)
AS
BEGIN
	UPDATE ProcessStepLog
	 SET RowsAffected = @RowsAffected
		,StopDate = getdate()
		,Comment = @Comment
	WHERE IdProcessStepLog = @IdProcessStepLog
END
GO
