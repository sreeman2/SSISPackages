/****** Object:  StoredProcedure [dbo].[usp_LoadStepLogUpdate]    Script Date: 01/09/2013 18:40:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LoadStepLogUpdate]
	 @IdLoadStepLog int
	,@RowsAffected int
	,@Comment varchar(MAX)
AS
BEGIN
	UPDATE LoadStepLog
	 SET RowsAffected = @RowsAffected
		,StopDate = getdate()
		,Comment = @Comment
	WHERE IdLoadStepLog = @IdLoadStepLog
END
GO
