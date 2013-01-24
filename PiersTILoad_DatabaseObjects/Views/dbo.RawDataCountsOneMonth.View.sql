/****** Object:  View [dbo].[RawDataCountsOneMonth]    Script Date: 01/09/2013 18:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----SELECT TOP 100 * FROM dbo.LoadLog
--SELECT TOP 100 * FROM dbo.LoadReport 
--WHERE IdLoadLog = 6837
--ORDER BY IdLoadLog DESC

CREATE VIEW [dbo].[RawDataCountsOneMonth]
----WITH ENCRYPTION, SCHEMABINDING, VIEW_METADATA
AS
SELECT RANK() OVER (ORDER BY IdLoadReport DESC) AS ID,
CONVERT(VARCHAR (20), StartDate, 101) AS RunDate,
FieldName,
NumRecs,
Direction
FROM dbo.LoadLog ldlg WITH(NOLOCK)
INNER JOIN dbo.LoadReport ldrp WITH(NOLOCK) ON ldlg.IdLoadLog = ldrp.IdLoadLog
WHERE 
ProcessName LIKE 'PopulateRawData' 
AND FieldName IN (
'TOTAL_BOL_IN'
--,'BOL_WITHOUT_CMD'
)
AND StartDate BETWEEN DATEADD(MONTH,-1, GETUTCDATE()) AND GETUTCDATE()
GO
