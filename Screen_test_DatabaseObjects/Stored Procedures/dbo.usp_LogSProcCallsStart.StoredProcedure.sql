/****** Object:  StoredProcedure [dbo].[usp_LogSProcCallsStart]    Script Date: 01/03/2013 19:48:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_LogSProcCallsStart]
  @DbName  varchar(100) = NULL
 ,@SprocName  varchar(100)
 ,@Parameters varchar(MAX)
 ,@IdLog int OUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO Xecute_SProc_Log
	 ([DbName], [SprocName], [StartDate], [SYSTEM_USER], [Parameters])
	VALUES
	 (@DbName, @SprocName, getdate(), SYSTEM_USER, @Parameters)

	SET @IdLog = @@IDENTITY

END
GO
