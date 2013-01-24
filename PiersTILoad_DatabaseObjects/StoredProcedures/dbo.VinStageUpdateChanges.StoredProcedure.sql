/****** Object:  StoredProcedure [dbo].[VinStageUpdateChanges]    Script Date: 01/09/2013 18:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VinStageUpdateChanges]
AS 
BEGIN
	UPDATE [dbo].[TI_Export_MasterData]
	SET PRODUCT_DESC_RAW = vns.NewValue,
	MODIFY_DATE = GETUTCDATE()
	FROM dbo.VinsExportStage vns 
	INNER JOIN [dbo].[TI_Export_MasterData] expmst ON vns.BL_NBR = expmst.BL_NBR 
	AND vns.BOL_ID = expmst.BOL_ID 
	AND vns.LOAD_NBR = expmst.LOAD_NBR
END
GO
