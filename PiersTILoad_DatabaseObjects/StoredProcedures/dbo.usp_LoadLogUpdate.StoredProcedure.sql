/****** Object:  StoredProcedure [dbo].[usp_LoadLogUpdate]    Script Date: 01/09/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LoadLogUpdate]
	 @IdLoadLog int
	,@Status varchar(100)-- = NULL
	,@Comment varchar(MAX)-- = NULL
AS
BEGIN
	DECLARE @NEWLINE char(6)
	SET @NEWLINE = '<br>' + CHAR(10) + CHAR(13)

	-- NOTE - Usage of COALESCE
	--  ensures the original column value is maintained if corr.
	--  input parameter is passed a NULL or skipped
	UPDATE dbo.LoadLog
	 SET Status = COALESCE(@Status,Status)
		,Comments = COALESCE(
					   Comments
						 + @NEWLINE
						 + CONVERT(VARCHAR,GETDATE(),109) + ': '
						 + @Comment
					, Comments)
	WHERE IdLoadLog=@IdLoadLog
END
GO
