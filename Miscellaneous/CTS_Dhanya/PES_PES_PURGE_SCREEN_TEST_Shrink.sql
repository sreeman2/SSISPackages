
USE PES
GO
DBCC SHRINKFILE(PES_log, 1)
BACKUP LOG  PES WITH TRUNCATE_ONLY
DBCC SHRINKFILE(PES_log, 1)
GO

USE PES_PURGE
GO
DBCC SHRINKFILE(PES_PURGE_log, 1)
BACKUP LOG  PES_PURGE WITH TRUNCATE_ONLY
DBCC SHRINKFILE(PES_PURGE_log, 1)
GO

GO
USE [SCREEN_TEST]
GO
DBCC SHRINKFILE(pdqdb_log, 1)
BACKUP LOG  SCREEN_TEST WITH TRUNCATE_ONLY
DBCC SHRINKFILE (pdqdb_log, 1)
GO

