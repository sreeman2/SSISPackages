/*USE PES
GO
DBCC SHRINKFILE(PES_log, 1)
BACKUP LOG  PES WITH TRUNCATE_ONLY
DBCC SHRINKFILE(PES_log, 1)
GO
*/