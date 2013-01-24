/****** Object:  StoredProcedure [dbo].[usp_LoadLogCreate]    Script Date: 01/09/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LoadLogCreate]
	 @ProcessName varchar(100)
	 ,@Direction varchar(100)
	,@IdLoadLog int OUT
AS
BEGIN
	SET @IdLoadLog = -1

	INSERT INTO LoadLog
	 (ProcessName,Direction,StartDate,Status,Comments)
	VALUES
	 (@ProcessName,@Direction,getdate(),'Running','')

	SET @IdLoadLog = @@IDENTITY
END
GO
