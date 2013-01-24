USE [PiersTILoad]
GO
/****** Object:  StoredProcedure [dbo].[ArchiveVinStage]    Script Date: 01/09/2013 18:40:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ArchiveVinStage]
AS 
BEGIN
	DELETE FROM dbo.VinsExportStage 
	WHERE VinProcessedOn < (DATEADD(month, -6, GETUTCDATE()))
END
GO
