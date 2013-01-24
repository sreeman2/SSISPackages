/****** Object:  StoredProcedure [dbo].[VinStageDataSet]    Script Date: 01/09/2013 18:40:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VinStageDataSet]
AS 
BEGIN
	SELECT expmst.[BL_NBR]
      ,expmst.[BOL_ID]
      ,expmst.[LOAD_NBR]
      ,expmst.[MODIFY_DATE]
      ,expmst.[PRODUCT_DESC_RAW]
  FROM [dbo].[TI_Export_MasterData] expmst
  WHERE expmst.MODIFY_DATE > (DATEADD(month, -12, GETUTCDATE()))
  AND expmst.[PRODUCT_DESC_RAW] LIKE '% VIN:%'
  AND expmst.[BOL_ID] NOT IN (SELECT vns.BOL_ID FROM dbo.VinsExportStage vns)
  
END
GO
