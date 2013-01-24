/****** Object:  StoredProcedure [dbo].[usp_ProcessLogUpdate]    Script Date: 01/03/2013 19:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProcessLogUpdate]
	 @IdProcessLog int
	,@Status varchar(100)-- = NULL
	,@Comment varchar(MAX)-- = NULL
AS
BEGIN
	DECLARE @NEWLINE char(6)
	SET @NEWLINE = '<br>' + CHAR(10) + CHAR(13)

	-- NOTE - Usage of COALESCE
	--  ensures the original column value is maintained if corr.
	--  input parameter is passed a NULL or skipped
	UPDATE dbo.ProcessLog
	 SET Status = COALESCE(@Status,Status)
		,StopDate = getdate()
		,Comments = COALESCE(
					   Comments
						 + @NEWLINE
						 + CONVERT(VARCHAR,GETDATE(),109) + ': '
						 + @Comment
					, Comments)
	WHERE IdProcessLog=@IdProcessLog
END
GO
