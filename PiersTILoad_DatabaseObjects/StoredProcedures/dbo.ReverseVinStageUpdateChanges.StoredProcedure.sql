/****** Object:  StoredProcedure [dbo].[ReverseVinStageUpdateChanges]    Script Date: 01/09/2013 18:40:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReverseVinStageUpdateChanges]
AS 
BEGIN
	UPDATE [dbo].[TI_Export_MasterData]
	SET PRODUCT_DESC_RAW = vns.PRODUCT_DESC_Raw
	FROM dbo.VinsExportStage vns 
	INNER JOIN [dbo].[TI_Export_MasterData] expmst ON vns.BL_NBR = expmst.BL_NBR 
	AND vns.BOL_ID = expmst.BOL_ID 
	AND vns.LOAD_NBR = expmst.LOAD_NBR
END
GO
