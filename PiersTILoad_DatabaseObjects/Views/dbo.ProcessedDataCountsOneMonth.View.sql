/****** Object:  View [dbo].[ProcessedDataCountsOneMonth]    Script Date: 01/09/2013 18:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ProcessedDataCountsOneMonth]
--WITH ENCRYPTION, SCHEMABINDING, VIEW_METADATA
AS
SELECT RANK() OVER (ORDER BY IdLoadReport DESC) AS ID,
CONVERT(VARCHAR (20), StartDate, 101) AS RunDate,
FieldName,
NumRecs,
Direction
FROM dbo.LoadLog ldlg WITH(NOLOCK)
INNER JOIN dbo.LoadReport ldrp WITH(NOLOCK) ON ldlg.IdLoadLog = ldrp.IdLoadLog
WHERE 
ProcessName LIKE 'PopulateProcessedData' 
AND FieldName IN (
'TOTAL_BOL_IN',
'TOTAL_CMD_IN',
'TOTAL_BOL_OUT',
'BOL_WITHOUT_CMD'
)
AND StartDate BETWEEN DATEADD(MONTH,-1, GETUTCDATE()) AND GETUTCDATE()
GO
