/****** Object:  StoredProcedure [dbo].[usp_LogSProcCallsEnd]    Script Date: 01/03/2013 19:48:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_LogSProcCallsEnd] (
   @Id  int
 , @RowsAffected int)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE Xecute_SProc_Log 
	SET EndDate = getdate()
	   ,RowsAffected = @RowsAffected
	WHERE Id = @Id
END
GO
