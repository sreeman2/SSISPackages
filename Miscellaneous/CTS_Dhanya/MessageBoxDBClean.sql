--exec [dbo].[bts_CleanupMsgbox]
--sp_helpdb BizTalkMsgBoxDb
-- EXEC [dbo].[bts_PurgeSubscriptions]
USE BizTalkMsgBoxDb

DBCC SHRINKDATABASE (BizTalkMsgBoxDb,1)---1 = value 1%