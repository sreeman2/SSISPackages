USE [PiersTILoad]
GO
/****** Object:  View [dbo].[LoadStepLog_V]    Script Date: 01/09/2013 18:52:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LoadStepLog_V] As
SELECT 
lsl.IdLoadStepLog
,lsl.IdLoadLog
--,ll.ProcessName
,lsd.StepName,lsl.StartDate,lsl.StopDate,lsl.RowsAffected,lsl.Comment
,DATEDIFF(millisecond,lsl.StartDate,COALESCE(lsl.StopDate,getdate()))*1.0/1000.0 DurationInSec
,DATEDIFF(millisecond,lsl.StartDate,COALESCE(lsl.StopDate,getdate()))*1/1000/60 DurationInMin
 FROM dbo.LoadStepLog lsl
JOIN dbo.LoadLog ll ON ll.IdLoadLog = lsl.IdLoadLog
JOIN dbo.LoadStepDefinition lsd ON lsd.IdLoadStep = lsl.IdLoadStep
--ORDER BY StartDate
GO
