/****** Object:  StoredProcedure [dbo].[usp_PES_DatabaseMaintenance_Backup_07_31_2012]    Script Date: 01/03/2013 19:48:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- [aa] - 11/09/2010
-- Performs scheduled/recurring maintenance on PES databases
-- 
-- 1. Archive Sproc Logs from SCREEN_TEST to PES_PURGE
-- 2. Archive UI data, e.g. bl_bl,etc...
-- 3. Re-index SCREEN_TEST db
-- 4. Re-index PES db
-- 5. Re-index PES_PURGE db
-- 6. Update Statistics for PES, PES_PURGE, SCREEN_TEST
--
CREATE PROCEDURE [dbo].[usp_PES_DatabaseMaintenance_Backup_07_31_2012]
AS
BEGIN

-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	
	DECLARE @StartTime datetime
	SET @StartTime = getdate()

	PRINT 'Archive Sproc Logs from UI'
	-- 1. Archive Sproc Logs from UI

	INSERT INTO PES_PURGE.dbo.Xecute_SProc_Log_Archive
	 ([DbName],SprocName,StartDate,EndDate,[SYSTEM_USER],RowsAffected,Parameters)
		SELECT [DbName],SprocName,StartDate,EndDate,[SYSTEM_USER],RowsAffected,Parameters
		 FROM dbo.Xecute_SProc_Log

	TRUNCATE TABLE dbo.Xecute_SProc_Log

	PRINT 'Archive UI data, e.g. bl_bl,...'
	-- 2. Archive UI data, e.g. bl_bl,etc...
	-- Call PES_PURGE.dtsx here... REPALACE BY queries below

	-- Prepare the payload to be archived
	TRUNCATE TABLE PES_PURGE.dbo.TEMP_BOLID
	PRINT 'Truncated Done on Table PES_PURGE.dbo.TEMP_BOLID'
	INSERT INTO PES_PURGE.dbo.TEMP_BOLID
	SELECT BOL_ID
	 FROM PES.dbo.PES_STG_BOL A WITH (NOLOCK)
	JOIN PES.dbo.PES_PROGRESS_STATUS B WITH (NOLOCK)
	ON A.REF_LOAD_NUM_ID=B.LOADNUMBER
	WHERE A.RECORD_STATUS IN ('CLEANSED','AUTOMATED') AND A.PPMM_FLAG='Y'
	AND B.LOAD_DT <= GETDATE() - 92
	UNION 
	SELECT BOL_ID
	 FROM PES.dbo.PES_STG_BOL A WITH (NOLOCK)
	JOIN PES.dbo.PES_PROGRESS_STATUS B WITH (NOLOCK)
	ON A.REF_LOAD_NUM_ID=B.LOADNUMBER
	WHERE A.BOL_STATUS in ('MASTER', 'HOUSE') 
	AND B.LOAD_DT <= GETDATE() - 92
	PRINT 'Records Inserted into PES_PURGE.dbo.TEMP_BOLID'
	-- Archive DQA_CMDS
	INSERT INTO PES_PURGE.dbo.ARCHIVE_DQA_CMDS
	SELECT * FROM SCREEN_TEST.DBO.DQA_CMDS WITH (NOLOCK)
	WHERE T_NBR IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive DQA_CMDS'
	-- Archive STD_VOYAGE
	INSERT INTO PES_PURGE.dbo.ARCHIVE_STD_VOYAGE
	SELECT * FROM SCREEN_TEST.DBO.STD_VOYAGE WITH (NOLOCK)
	WHERE T_NBR IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive STD_VOYAGE'
	-- Archive DQA_BL
	INSERT INTO PES_PURGE.dbo.ARCHIVE_DQA_BL
	SELECT * FROM SCREEN_TEST.DBO.DQA_BL WITH (NOLOCK)
	WHERE T_NBR IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive DQA_BL'	
	-- Archive BL_BL
	INSERT INTO PES_PURGE.dbo.ARCHIVE_BL_BL
	SELECT * FROM SCREEN_TEST.DBO.BL_BL WITH (NOLOCK)
	WHERE T_NBR IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive BL_BL'	
	-- Archive CTRL_PROCESS_VOYAGE
	INSERT INTO PES_PURGE.dbo.ARCHIVE_CTRL_PROCESS_VOYAGE
	SELECT * FROM SCREEN_TEST.DBO.CTRL_PROCESS_VOYAGE WITH (NOLOCK)
	WHERE T_NBR IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive CTRL_PROCESS_VOYAGE'
	-- Archive PES_TRANSACTIONS_LIB_PTY
	INSERT INTO PES_PURGE.dbo.ARCHIVE_PES_TRANSACTIONS_LIB_PTY
	SELECT * FROM PES.DBO.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)
	WHERE BOL_ID IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive PES_TRANSACTIONS_LIB_PTY'
	-- Archive PES_TRANSACTION_MATCH_PTY
	INSERT INTO PES_PURGE.dbo.ARCHIVE_PES_TRANSACTION_MATCH_PTY
	SELECT * FROM PES.DBO.PES_TRANSACTION_MATCH_PTY WITH (NOLOCK)
	WHERE BOL_ID IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive PES_TRANSACTION_MATCH_PTY'
	-- Archive PES_TRANSACTIONS_MATCH_TEMP_PTY
	INSERT INTO PES_PURGE.dbo.ARCHIVE_PES_TRANSACTIONS_MATCH_TEMP_PTY
	SELECT * FROM PES.DBO.PES_TRANSACTIONS_MATCH_TEMP_PTY WITH (NOLOCK)
	WHERE BOL_ID IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	PRINT 'Done--Archive PES_TRANSACTIONS_MATCH_TEMP_PTY'
	-- Archive PES_STRUCTURED_PTY
	INSERT INTO PES_PURGE.dbo.ARCHIVE_PES_STRUCTURED_PTY
	SELECT * FROM PES.DBO.PES_STRUCTURED_PTY WITH (NOLOCK)
	WHERE BOL_ID IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Archive PES_STRUCTURED_PTY'
	-- Archive PES_STRUCTURED_PTY_ORIG
	INSERT INTO PES_PURGE.dbo.ARCHIVE_PES_STRUCTURED_PTY_ORIG
	SELECT * FROM PES.DBO.PES_STRUCTURED_PTY_ORIG WITH (NOLOCK)
	WHERE BOL_ID IN (SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Archive PES_STRUCTURED_PTY_ORIG'
	-- Archive BL_CACHE
	INSERT INTO PES_PURGE.dbo.ARCHIVE_BL_CACHE
	SELECT * FROM SCREEN_TEST.DBO.BL_CACHE WITH (NOLOCK) WHERE T_NBR IN (
	SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Archive BL_CACHE'
	-- Delete from CTRL_PROCESS_VOYAGE
	DELETE FROM SCREEN_TEST.DBO.CTRL_PROCESS_VOYAGE WHERE T_NBR IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from CTRL_PROCESS_VOYAGE'
	-- Delete from STD_VOYAGE
	DELETE FROM SCREEN_TEST.DBO.STD_VOYAGE WHERE T_NBR IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from STD_VOYAGE'
	-- Delete from DQA_CMDS
	DELETE FROM SCREEN_TEST.DBO.DQA_CMDS WHERE T_NBR IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from DQA_CMDS'
	-- Delete from BL_CACHE
	DELETE FROM SCREEN_TEST.DBO.BL_CACHE WHERE T_NBR IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from BL_CACHE'
	-- Delete from DQA_BL
	DELETE FROM SCREEN_TEST.DBO.DQA_BL WHERE T_NBR IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from DQA_BL'
	-- Delete from PES_TRANSACTIONS_LIB_PTY
	DELETE FROM PES.DBO.PES_TRANSACTIONS_LIB_PTY WHERE BOL_ID IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from PES_TRANSACTIONS_LIB_PTY'
	-- Delete from PES_TRANSACTION_MATCH_PTY
	DELETE FROM PES.DBO.PES_TRANSACTION_MATCH_PTY WHERE BOL_ID IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from PES_TRANSACTION_MATCH_PTY'
	-- Delete from PES_TRANSACTIONS_MATCH_TEMP_PTY
	DELETE FROM PES.DBO.PES_TRANSACTIONS_MATCH_TEMP_PTY WHERE BOL_ID IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from PES_TRANSACTIONS_MATCH_TEMP_PTY'
	-- Delete from PES_STRUCTURED_PTY
	DELETE FROM PES.DBO.PES_STRUCTURED_PTY WHERE BOL_ID IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from PES_STRUCTURED_PTY'
	-- Delete from PES_STRUCTURED_PTY_ORIG
	DELETE FROM PES.DBO.PES_STRUCTURED_PTY_ORIG WHERE BOL_ID IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'done--Delete from PES_STRUCTURED_PTY_ORIG'
	-- Delete from BL_BL
	DELETE FROM SCREEN_TEST.DBO.BL_BL WHERE T_NBR IN 
	(SELECT BOL_ID FROM PES_PURGE.dbo.TEMP_BOLID WITH (NOLOCK))
	print 'Done--Delete from BL_BL'
	PRINT 'Re-index SCREEN_TEST tables'
	-- 3. Re-index SCREEN_TEST tables
	EXEC [TEMP_PES].[dbo].[dba_indexDefrag_sp]
		  @minFragmentation     = 5.0 
		, @rebuildThreshold     = 10.0 
		, @executeSQL           = 1    
		, @defragOrderColumn    = 'range_scan_count'
		, @defragSortOrder      = 'DESC'
		, @timeLimit            = 60 --minutes --i.e. 1 hour
		, @database             = 'SCREEN_TEST'
		, @tableName            = Null
		, @forceRescan          = 1
		, @scanMode             = N'LIMITED'
		, @minPageCount         = 8
		, @maxPageCount         = Null
		, @excludeMaxPartition  = 0
		, @onlineRebuild        = 1    
		, @sortInTempDB         = 0
		, @maxDopRestriction    = Null
		, @printCommands        = 1    
		, @printFragmentation   = 1
		, @defragDelay          = '00:00:05'
		, @debugMode            = 1

	PRINT 'Re-index PES tables'
	-- 4. Re-index PES tables
	EXEC [TEMP_PES].[dbo].[dba_indexDefrag_sp]
		  @minFragmentation     = 5.0 
		, @rebuildThreshold     = 10.0 
		, @executeSQL           = 1    
		, @defragOrderColumn    = 'range_scan_count'
		, @defragSortOrder      = 'DESC'
		, @timeLimit            = 120 --minutes --i.e. 2 hours
		, @database             = 'PES'
		, @tableName            = Null
		, @forceRescan          = 1
		, @scanMode             = N'LIMITED'
		, @minPageCount         = 8
		, @maxPageCount         = Null
		, @excludeMaxPartition  = 0
		, @onlineRebuild        = 1    
		, @sortInTempDB         = 0
		, @maxDopRestriction    = Null
		, @printCommands        = 1    
		, @printFragmentation   = 1
		, @defragDelay          = '00:00:05'
		, @debugMode            = 1

	PRINT 'Re-index PES_PURGE tables'
	-- 5. Re-index PES_PURGE tables
	EXEC [TEMP_PES].[dbo].[dba_indexDefrag_sp]
		  @minFragmentation     = 5.0 
		, @rebuildThreshold     = 10.0 
		, @executeSQL           = 1    
		, @defragOrderColumn    = 'range_scan_count'
		, @defragSortOrder      = 'DESC'
		, @timeLimit            = 60 --minutes --i.e. 1 hour
		, @database             = 'PES_PURGE'
		, @tableName            = Null
		, @forceRescan          = 1
		, @scanMode             = N'LIMITED'
		, @minPageCount         = 8
		, @maxPageCount         = Null
		, @excludeMaxPartition  = 0
		, @onlineRebuild        = 1    
		, @sortInTempDB         = 0
		, @maxDopRestriction    = Null
		, @printCommands        = 1    
		, @printFragmentation   = 1
		, @defragDelay          = '00:00:05'
		, @debugMode            = 1

	PRINT 'Update Statistics'
	-- 6. Update Statistics
-- Use sp_updatestats
-- In SQL Server 2005, sp_updatestats updates only those statistics that require updating based on the rowmodctr
--  information in the sys.sysindexes compatibility view; therefore, preventing unnecessary updates of unchanged items.
-- http://msdn.microsoft.com/en-us/library/ms173804%28SQL.90%29.aspx
-- http://sqlserverpedia.com/blog/sql-server-bloggers/update-statistics-before-or-after-an-index-rebuild/
-- http://www.sqlmag.com/Forums/tabid/426/aff/89/aft/83383/afv/topic/Default.aspx

	EXECUTE sp_msforeachdb 'USE ?
	 IF DB_NAME() IN(''PES'',''SCREEN_TEST'',''PES_PURGE'')
	  PRINT DB_NAME()
	  EXEC sp_updatestats
	'

	-- 7. Send out notification email
	DECLARE @NEWLINE char(2)
	SET @NEWLINE = CHAR(13) + CHAR(10)

	DECLARE @Message varchar(MAX)
	SET @Message = 'PES DatabaseMaintenance completed.' + @NEWLINE
 + 'Start Time = ' + CAST(@StartTime As varchar(20)) + @NEWLINE
 + 'End Time = ' + CAST(getdate() As varchar(20)) + @NEWLINE
 + '' + @NEWLINE
 + '---------------------------' + @NEWLINE
 + 'usp_PES_DatabaseMaintenance' + @NEWLINE
 + '---------------------------'

	DECLARE @SendEmailOutput varchar(MAX), @SendEmailSuccess bit
	EXEC PES.dbo.usp_SendEmail
	  @To		= 'hdesai@joc.com;cpatel@ubmglobaltrade.com;JGuy@piers.com;SKasi@piers.com;HDesai@piers.com;AAwasthi@piers.com'
	 ,@From		= 'PIERS-NoReply@piers.com'
	 ,@Subject	= 'PES Database Maintenance completed'
	 ,@Body		= @Message
	 ,@Success	= @SendEmailSuccess OUT
	 ,@Output	= @SendEmailOutput OUT
	SELECT @SendEmailSuccess, @SendEmailOutput

-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
