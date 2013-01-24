/****** Object:  StoredProcedure [dbo].[usp_PopulateDeletedData]    Script Date: 01/09/2013 18:40:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		[aa]
-- Create date: 08/23/2010
-- Description:	Pull 'deleted' data from PES
-- NOTES:
	-- 1. Linked servers:
	-- 
	-- 2. Views:
	-- 
	-- 3. Conditions to fetch raw data:
	-- 
	-- 4. Final output:
	--
	-- 5. NOTES:
	-- a. 
	--
-- =============================================
CREATE PROCEDURE [dbo].[usp_PopulateDeletedData] 
	@Direction varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProcessStatus varchar(50)
	SET @ProcessStatus = ''
	DECLARE @NumberOfWarningsRaised INT
	SET @NumberOfWarningsRaised = 0

    -- Insert statements for procedure here
	IF (@Direction NOT IN ('I','E'))
	BEGIN
		RAISERROR('Invalid @Direction specified!',16,1)
		RETURN
	END

	-- Check if another load process is already running (or failed)
	IF EXISTS
	 (SELECT * FROM dbo.LoadLog
		 WHERE ProcessName IN ('PopulateRawData','PopulateProcessedData','PopulateDeletedData')
			AND status NOT IN ('Successful','Failed','SuccessfulWithWarnings'))
	BEGIN
		RAISERROR('Another load process is currently active!',16,1)
		RETURN
	END

--	DECLARE @NEWLINE char(2)
--	SET @NEWLINE = CHAR(10) + CHAR(13)
	DECLARE @NEWLINE char(6)
	SET @NEWLINE = '<br>' + CHAR(10) + CHAR(13)

	DECLARE @ProcessName varchar(100)
	DECLARE @StepName varchar(100)
	DECLARE @Comment varchar(MAX)
	SELECT @ProcessName = 'PopulateDeletedData', @StepName = '', @Comment = ''

	DECLARE @IdLoadLog int, @IdLoadStepLog int, @RowsAffected int
	SELECT @IdLoadLog = -1, @IdLoadStepLog = -1, @RowsAffected = -1

-- -- Log
EXEC dbo.usp_LoadLogCreate @ProcessName, @Direction, @IdLoadLog OUT

BEGIN TRY

-- -- Get the payload for this process run
SET @StepName = 'GetPayload'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Get the udate to use as filter
	DECLARE @MaxStartDt datetime
	 -- PES data that has been deleted since PopulateDeletededData was last run SUCCESSFULLY
	SELECT @MaxStartDt = MAX(StartDate)
	 FROM dbo.LoadLog WHERE ProcessName=@ProcessName AND Direction=@Direction
		 AND Status IN ('Successful','SuccessfulWithWarnings')

	-- If there are no entries in LoadLoad table, fetch what data
	IF @MaxStartDt IS NULL
		SET @MaxStartDt = CONVERT(datetime,'1/1/1900') -- fetch all PES data - do we want this? probably not
		--SET @MaxStartDt = getdate()	-- fetch no PES data - just to be safe

SELECT @RowsAffected = -1, @Comment = 'Done. @MaxStartDt = ' + LTRIM(RTRIM(CAST(@MaxStartDt As varchar(20))))
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment


--Delete data marked as deleted in PESDW added by Harish on July-12-2011
SET @StepName = 'ApplyPESDWDeletes'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Update records in TI_MasterData
	IF @Direction = 'I'
			 UPDATE dbo.TI_Import_MasterData SET 
				VISIBILITY	=	'D',
				MODIFY_DATE	=	getdate()
			where visibility='V' and
			bol_id in
			(select bol_ID from 
			PESDW.DBO.PES_DW_BOL (nolock) 
			where Deleted='Y' and Direction='I')
	ELSE --  @Direction = 'E'
			UPDATE dbo.TI_Export_MasterData SET 
				VISIBILITY	=	'D',
				MODIFY_DATE	=	getdate()
			where visibility='V' and
			bol_id in
			(select bol_ID from 
			PESDW.DBO.PES_DW_BOL (nolock) 
			where Deleted='Y' and Direction='E')

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment
--PESDW deletes end here


-- -- Get deleted data
SET @StepName = 'ApplyPESDeletes'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
--SELECT * FROM PESDW.dbo.PES_DW_DELETED_BILLS_LOG
--SELECT reason,direction,count(*) FROM PESDW.dbo.PES_DW_DELETED_BILLS_LOG
--GROUP BY reason,direction ORDER BY reason,direction

	-- Update records in TI_MasterData
	IF @Direction = 'I'
		UPDATE timdi SET 
			timdi.VISIBILITY	=	'D',
			timdi.MODIFY_DATE	=	getdate()
		 FROM dbo.TI_Import_MasterData timdi
		JOIN PESDW.dbo.PES_DW_DELETED_BILLS_LOG d
		 ON d.BOL_ID = timdi.BOL_ID
		  AND d.DELETED_DATE >= @MaxStartDt
	ELSE --  @Direction = 'E'
		UPDATE timde SET 
			timde.VISIBILITY	=	'D',
			timde.MODIFY_DATE	=	getdate()
		 FROM dbo.TI_Export_MasterData timde
		JOIN PESDW.dbo.PES_DW_DELETED_BILLS_LOG d
		 ON d.BOL_ID = timde.BOL_ID
		  AND d.DELETED_DATE >= @MaxStartDt

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	-- Mark as success
	IF @NumberOfWarningsRaised >= 1
		SET @ProcessStatus = 'SuccessfulWithWarnings'
	ELSE
		SET @ProcessStatus = 'Successful'

	UPDATE dbo.LoadLog SET
	 Status = @ProcessStatus
	,StopDate = getdate()
	WHERE IdLoadLog=@IdLoadLog

END TRY
BEGIN CATCH
	DECLARE @ErrorInfo varchar(MAX)
	SELECT @ErrorInfo =
	 + @NEWLINE + 'ERROR:'
	 + @NEWLINE + 'Error_number: '		+ CAST(COALESCE(ERROR_NUMBER(),'') As varchar(MAX))
	 + @NEWLINE + 'Error_severity: '	+ CAST(COALESCE(ERROR_SEVERITY(),'') As varchar(MAX))
	 + @NEWLINE + 'Error_state: '		+ CAST(COALESCE(ERROR_STATE(),'') As varchar(MAX))
	 + @NEWLINE + 'Error_procedure: '	+ CAST(COALESCE(ERROR_PROCEDURE(),'') As varchar(MAX))
	 + @NEWLINE + 'Error_line: '		+ CAST(COALESCE(ERROR_LINE(),'') As varchar(MAX))
	 + @NEWLINE + 'Error_message: '		+ CAST(COALESCE(ERROR_MESSAGE(),'') As varchar(MAX))

	UPDATE dbo.LoadLog SET
	 Status = 'Failed', comments = comments + @NEWLINE + CONVERT(VARCHAR,GETDATE(),109) + ': ' + @ErrorInfo
	,StopDate = getdate()
	WHERE IdLoadLog=@IdLoadLog
END CATCH

END
GO
