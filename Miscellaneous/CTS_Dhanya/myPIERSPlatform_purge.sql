USE myPIERSPlatform
GO
DBCC SHRINKFILE(N'MyPIERS-ReportQueue_log' , 1)
BACKUP LOG  myPIERSPlatform WITH TRUNCATE_ONLY
DBCC SHRINKFILE(N'MyPIERS-ReportQueue_log' , 1)
GO