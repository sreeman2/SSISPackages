/****** Object:  StoredProcedure [dbo].[z_usp_PopulateProcessedDataPrePES]    Script Date: 01/09/2013 18:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		[aa]
-- Create date: 08/23/2010
-- Description:	Pull 'processed' data from pre-PES
-- NOTES:
	-- 1. Linked servers:
	-- 
	-- 2. Views:
	-- 
	-- 3. Static Reference tables:
	--
	-- 4. Conditions to fetch raw data:
	-- 
	-- 5. Final output:
	--
	-- 6. NOTES:
	-- a. 
	--
-- =============================================
CREATE PROCEDURE [dbo].[z_usp_PopulateProcessedDataPrePES] 
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
	IF EXISTS (SELECT * FROM dbo.LoadLog WHERE status NOT IN ('Successful','Failed','SuccessfulWithWarnings'))
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
	SELECT @ProcessName = 'PopulateProcessedDataPrePES', @StepName = '', @Comment = ''

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
	DECLARE @MaxUDate varchar(12)
	 -- pre-PES data that has been updated since PopulateProcessedDataPrePES was last run SUCCESSFULLY
	SELECT @MaxStartDt = MAX(StartDate)
	 FROM dbo.LoadLog WHERE ProcessName=@ProcessName AND Direction=@Direction
		 AND Status IN ('Successful','SuccessfulWithWarnings')

	-- If there are no entries in LoadLoad table, fetch what data
	IF @MaxStartDt IS NULL
		--SET @MaxStartDt = CONVERT(datetime,'1/1/1900') -- fetch all pre-PES data - do we want this? probably not
		SET @MaxStartDt = getdate()	-- fetch no PES data - just to be safe

	SET @MaxUDate = LTRIM(RTRIM(STR(MONTH(@MaxStartDt)))) +'/' +
					LTRIM(RTRIM(STR(DAY(@MaxStartDt)))) +'/' +
					LTRIM(RTRIM(STR(YEAR (@MaxStartDt))))
SELECT @RowsAffected = -1, @Comment = 'Done. @MaxUDate = ' + @MaxUDate
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- -- Get processed data
-- processed_bl
SET @StepName = 'GetProcessedDataPrePES_pre_pes_usshipment'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE pre_pes_usshipment
	INSERT INTO pre_pes_usshipment
	SELECT *
	 FROM PESDW.dbo.ti_prePES_data_usshipment_V tvub
	WHERE dir=@Direction
	 --AND SLINE NOT IN (SELECT SCAC FROM Ti3Load.DBO.RESTRICTED_SCAC (NOLOCK)) -- REMOVED!!! if at all we should fetch this information and apply these as deletes to the master table, right?
--	 AND udate >= @MaxUDate
-- This is for test phase only, udate condition above is the true filter
	 AND udate >= getdate()-1
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	-- Log Number of Recnums fetched
	IF @RowsAffected <= 0
	BEGIN
		SET @Comment = 'Warning - No Bills to load CMD!'
		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, 'SuccessfulWithWarnings', @Comment
		-- No recnums to process, nothing more to do, we're done at this point...
		RETURN
	END

-- -- Populate / Append to staging ref tables
-- port
SET @StepName = 'PopulateStgRefs_port'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- port table
	;WITH tmp_all_port As (
		SELECT	pbl.FPORT_CODE As code
				,pbl.FOREIGN_PORT_NAME As name
				,NULL As state
				,NULL As country
				,NULL As region
		 FROM dbo.pre_pes_usshipment pbl
		UNION -- Note: UNION removes duplicates already
		SELECT	pbl.USPORT_CODE As code
				,pbl.UNLADING_PORT_NAME As name
				,NULL As state
				,NULL As country
				,NULL As region
		 FROM dbo.pre_pes_usshipment pbl
		UNION
		SELECT	NULL As code
				,pbl.port_us_clearing_name As name
				,pbl.port_us_clearing_st As state
				,pbl.port_us_clearing_dist As country
				,NULL As region
		 FROM dbo.pre_pes_usshipment pbl
	)
	INSERT INTO dbo.stg_port (code,name,state,country,region)
	SELECT DISTINCT tap.code,tap.name,tap.state,tap.country,tap.region
	 FROM tmp_all_port tap
	LEFT JOIN	dbo.stg_port AS p ON -- only if tap.record does not exist in dbo.stg_port already
					COALESCE(p.code,'NullValue') = COALESCE(tap.code,'NullValue')
				AND COALESCE(p.name,'NullValue') = COALESCE(tap.name,'NullValue')
				AND COALESCE(p.state,'NullValue') = COALESCE(tap.state,'NullValue')
				AND COALESCE(p.country,'NullValue') = COALESCE(tap.country,'NullValue')
				AND COALESCE(p.region,'NullValue') = COALESCE(tap.region,'NullValue')
	WHERE		p.id IS NULL
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'PopulateStgRefs_sline'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- sline table
	;WITH tmp_all_sline As (
		SELECT	pbl.SLINE As code
				,pbl.SLINE_DESC As name
		 FROM dbo.pre_pes_usshipment pbl
	)
	INSERT INTO dbo.stg_sline (code,name)
	SELECT DISTINCT tas.code,tas.name
	 FROM tmp_all_sline tas
	LEFT JOIN	dbo.stg_sline AS s ON -- only if tas.record does not exist in dbo.stg_sline already
					COALESCE(s.code,'NullValue') = COALESCE(tas.code,'NullValue')
				AND COALESCE(s.name,'NullValue') = COALESCE(tas.name,'NullValue')
	WHERE		s.id IS NULL
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- -- Populate data tables
-- stg_cmd
SET @StepName = 'PopulateStgData_cmd'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_cmd
	INSERT INTO dbo.stg_cmd (
		BOL_ID
		,cmd_seq_nbr
		,CMD_ID
		,cntr_nbr
		,piece_cnt
		,piece_unit
		,cmd_desc
		,harm_code
		,joc_code
		,teu
		,pounds
		,estimated_value)
	SELECT 
		pc.t_nbr As BOL_ID
		,NULL As cmd_seq_nbr
		,NULL As CMD_ID
		,NULL As cntr_nbr
		,pc.QTY As piece_cnt
		,pc.U_M As piece_unit
		,pc.COMMODITY As cmd_desc
		,pc.HARM_CODE As harm_code
		,pc.COMCODE As COMCODE
		,pc.TEU As teu
		,pc.POUNDS As pounds
		,pc.VALUE As estimated_value
	FROM dbo.pre_pes_usshipment pc
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_bl
-- Populate non-id(ed) columns
SET @StepName = 'PopulateStgData_bl'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_bl
	;WITH tmp_unique_base_record As (
		-- NOTE: This is required because usshipment_joined might not have the same values for
		--		 the base BOL fields, e.g. REGION_ORIGIN,COUNTRYL,VDATE... etc.
		--		 We want to take the 1st available permutation for these fields and move on...
		SELECT
			 ROW_NUMBER() OVER (PARTITION BY t_nbr ORDER BY REGION_ORIGIN,COUNTRYL,VDATE,MANIFEST_NBR,NVOCC_FLAG,CTRYCODE,US_COAST) As Rank
			,pbl.t_nbr
			,NULL As bl_nbr
			,pbl.REGION_ORIGIN As origin_region
			,pbl.COUNTRYL As origin_country
			,pbl.VDATE As vdate
			,pbl.MANIFEST_NBR As manifest_nbr
			,pbl.NVOCC_FLAG As nvocc_flag
			,pbl.CTRYCODE As country_code
			,pbl.US_COAST As us_coast
			--,pbl.VISIBILITY As visibility
			,pbl.POUNDS As std_weight
			,pbl.QTY As manifest_qty
			,pbl.TEU As teu_cnt
			,pbl.VALUE As estimated_value
			--,pbl.CONFLAG AS conflag
		 FROM dbo.pre_pes_usshipment pbl
	), tmp_commodities_rolled_up As (
		SELECT 
			 cmd.t_nbr
			,SUM(cmd.pounds/2.14) As std_weight -- TODO - convert pounds to KG?
			,SUM(cmd.qty) As manifest_qty
			,SUM(cmd.teu) As teu_cnt
			,SUM(cmd.value) As estimated_value
		FROM dbo.pre_pes_usshipment cmd
		GROUP BY cmd.T_NBR
	)
	INSERT INTO dbo.stg_bl (
		 BOL_ID
		,bl_nbr
		,origin_region
		,origin_country
		,vdate
		,manifest_nbr
		,voyage_nbr
		--,conflag
		,std_weight
		,measure_value
		,measure_unit
		,manifest_qty
		,manifest_unit
		,teu_cnt
		,teu_src
		,inbond_entry_type
		,trans_mode_description
		,estimated_value
		,hazard_class
		,nvocc_flag
		,country_code
		,us_coast
		,cons_state
		,not_state
		,anot_state
		--,visibility
		,batch_id
		,load_nbr
		,IdLoadLog
	)
	SELECT
		 tubr.t_nbr As BOL_ID
		, NULL As bl_nbr
		,tubr.origin_region
		,tubr.origin_country
		,tubr.vdate
		,tubr.manifest_nbr
		,NULL As voyage_nbr
		--,NULL As conflag
		--,tubr.conflag
		,tcru.std_weight -- TODO - convert pounds to KG?
		,NULL As measure_value
		,NULL As measure_unit
		,tcru.manifest_qty
		,NULL As manifest_unit
		,tcru.teu_cnt
		,NULL As teu_src
		,NULL As inbond_entry_type
		,NULL As trans_mode_description
		,tcru.estimated_value
		,NULL As hazard_class
		,tubr.nvocc_flag
		,tubr.country_code
		,tubr.us_coast
		,NULL As cons_state
		,NULL As not_state
		,NULL As anot_state
		--,tubr.visibility
		,NULL As batch_id
		,NULL As load_nbr
		,@IdLoadLog As IdLoadLog
	 FROM tmp_unique_base_record tubr
	JOIN tmp_commodities_rolled_up tcru ON tcru.t_nbr = tubr.t_nbr
	WHERE  tubr.Rank = 1
	ORDER BY BOL_ID
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_bl_ids
-- Populate id(ed) columns
SET @StepName = 'PopulateStgData_bl_ids'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_bl_ids
	;WITH tmp_unique_base_record As (
		-- NOTE: This is required because usshipment_joined might not have the same values for
		--		 the base BOL fields, e.g. SLINE,FPORT_CODE,USPORT_CODE... etc.
		--		 We want to take the 1st available permutation for these fields and move on...
		SELECT
			 ROW_NUMBER() OVER (PARTITION BY BOL_ID ORDER BY SLINE,SLINE_DESC,FPORT_CODE,FOREIGN_PORT_NAME,USPORT_CODE,UNLADING_PORT_NAME,PORT_US_CLEARING_NAME,PORT_US_CLEARING_ST,PORT_US_CLEARING_DIST) As Rank
			,pbl.BOL_ID
			,pbl.SLINE
			,pbl.SLINE_DESC
			,pbl.FPORT_CODE
			,pbl.FOREIGN_PORT_NAME
			,pbl.USPORT_CODE
			,pbl.UNLADING_PORT_NAME
			,pbl.PORT_US_CLEARING_NAME
			,pbl.PORT_US_CLEARING_ST
			,pbl.PORT_US_CLEARING_DIST
		FROM dbo.processed_bl pbl
	--	ORDER BY BOL_ID
	) ,tmp_unique_base_record_ids As (
		SELECT
			ROW_NUMBER() OVER (PARTITION BY BOL_ID ORDER BY sline.id,port_foreign.id,port_unlading.id,port_us_clearing.id) As Rank
			,tubr.BOL_ID As BOL_ID
			,sline.id As id_carrier_sline
			,port_foreign.id As id_port_foreign
			,port_unlading.id As id_port_unlading
			,port_us_clearing.id As id_port_us_clearing
		 FROM tmp_unique_base_record tubr
		 -- join sline
		 LEFT OUTER JOIN dbo.stg_sline sline ON
			 COALESCE(tubr.SLINE,'NullValue') = COALESCE(sline.code,'NullValue')
		 AND COALESCE(tubr.SLINE_DESC,'NullValue') = COALESCE(sline.name,'NullValue')
		 -- join port_foreign
		 LEFT OUTER JOIN dbo.stg_port port_foreign ON
			 COALESCE(tubr.FPORT_CODE,'NullValue') = COALESCE(port_foreign.code,'NullValue')
		 AND COALESCE(tubr.FOREIGN_PORT_NAME,'NullValue') = COALESCE(port_foreign.name,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign.state,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign.country,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign.region,'NullValue')
		 -- join port_unlading
		 LEFT OUTER JOIN dbo.stg_port port_unlading ON
			 COALESCE(tubr.USPORT_CODE,'NullValue') = COALESCE(port_unlading.code,'NullValue')
		 AND COALESCE(tubr.UNLADING_PORT_NAME,'NullValue') = COALESCE(port_unlading.name,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_unlading.state,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_unlading.country,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_unlading.region,'NullValue')
		 -- join port_us_clearing
		 LEFT OUTER JOIN dbo.stg_port port_us_clearing ON
			 COALESCE(NULL,'NullValue') = COALESCE(port_us_clearing.code,'NullValue')
		 AND COALESCE(tubr.PORT_US_CLEARING_NAME,'NullValue') = COALESCE(port_us_clearing.name,'NullValue')
		 AND COALESCE(tubr.PORT_US_CLEARING_ST,'NullValue') = COALESCE(port_us_clearing.state,'NullValue')
		 AND COALESCE(tubr.PORT_US_CLEARING_DIST,'NullValue') = COALESCE(port_us_clearing.country,'NullValue')
		 AND COALESCE(NULL,'NullValue') = COALESCE(port_us_clearing.region,'NullValue')
		-- GROUP BY - rolls up to only 1st recnum for some fields, and SUM for other fields
		GROUP BY
			 tubr.BOL_ID
			,sline.id
			,port_foreign.id
			,port_unlading.id
			,port_us_clearing.id
	--	ORDER BY BOL_ID
	) ,tmp_unique_base_record_ided As (
		SELECT
			ROW_NUMBER() OVER (PARTITION BY BOL_ID ORDER BY tubri.id_carrier_sline,tubri.id_port_foreign,tubri.id_port_unlading,tubri.id_port_us_clearing) As Rank
			,tubri.BOL_ID
			,tubri.id_carrier_sline
			,tubri.id_port_foreign
			,tubri.id_port_unlading
			,tubri.id_port_us_clearing
		FROM tmp_unique_base_record_ids tubri
		WHERE tubri.Rank = 1
	--	ORDER BY BOL_ID
	)
	INSERT INTO dbo.stg_bl_ids (
		 BOL_ID
		,id_sline
		,id_scac
		,id_port_foreign
		,id_port_unlading
		,id_port_foreign_dest
		,id_port_receipt
		,id_port_us_clearing
		,id_pty_shipper
		,id_pty_consignee
		,id_pty_notify
		,id_pty_notify_also
		,id_vessel
	)
	SELECT
		 tubrided.BOL_ID
		,tubrided.id_carrier_sline
		,NULL As id_carrier_scac
		,tubrided.id_port_foreign
		,tubrided.id_port_unlading
		,NULL As id_port_foreign_dest
		,NULL As id_port_receipt
		,tubrided.id_port_us_clearing
		,NULL As id_pty_shipper
		,NULL As id_pty_consignee
		,NULL As id_pty_notify
		,NULL As id_pty_notify_also
		,NULL As id_vessel
	FROM tmp_unique_base_record_ided tubrided
	ORDER BY BOL_ID
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

--	-- Check if all incoming bills have been loaded in the past (i.e. t_nbr is in ti_archive.bl table, i.e. ucount>=1)
--	DECLARE @ValidBills INT
--	DECLARE @InValidBills INT
--	SET @ValidBills = -1
--	SET @InValidBills = -1
--	SELECT @ValidBills=COUNT(*) FROM dbo.stg_bl b WHERE b.ucount>=1
--	SELECT @InValidBills=COUNT(*) FROM dbo.stg_bl b WHERE b.ucount<1
--	-- If there are no Valid Bills, show warning
--	IF @ValidBills <= 0
--	BEGIN
--		SET @NumberOfWarningsRaised = @NumberOfWarningsRaised + 1
--		SET @Comment = 'Warning - No valid bills to load!'
--		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, NULL, @Comment
--	END
--	-- If there are Invalid Bills, show warning
--	IF @InValidBills > 0
--	BEGIN
--		SET @NumberOfWarningsRaised = @NumberOfWarningsRaised + 1
--		SET @Comment = 'Warning - ' + LTRIM(RTRIM(STR(@InValidBills))) + '(s) invalid bills found (BOL_IDs NOT found in TI Archive)!'
--		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, NULL, @Comment
--	END

-- Populate stgload table
SET @StepName = 'Populate_stgload_processed'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Truncate any previous stgload data
	TRUNCATE TABLE dbo.stgload_processed

	-- Populate new stgload data
	INSERT INTO dbo.stgload_processed
	 SELECT * FROM dbo.stgload_processed_V
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

--[aa] - 08/05/2010
-- DIR cannot be NULL anymore
--  Upto now we used to leave direction NULL for UPDATEs
--  We need to populate direction in STGLOAD for UPDATEs as well
UPDATE dbo.stgload_processed
 SET DIR = @Direction
WHERE DIR IS NULL
--[aa] - 08/05/2010

	-- Apply fixes to various columns
SET @StepName = 'FixStgload_region_coast_etc'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		-- Looks up port code on PORT_DIM.
		 PORT_UNLADING_STATE = pd.STATE_CD
		-- Looks up country code on REGION_SWAP.
		,REGION_ORIGIN = rs.REGION
		-- Looks up port code on COAST_SWAP.
		,US_COAST = cs.COAST
		-- Looks up port code against PORT_DIM for DISTRICT_CD, then looks that up against USCS_DISTRICT_DIM.
		,PORT_US_CLEARING_DIST = udd.NAME
		-- Is actually SLINE_DESC, not SCAC name
		,sl.SCAC_CARRIER_NAME = sline.name
		-- This value is set to the TI column PORT_UNLADING_NAME.
		,sl.PORT_US_CLEARING_NAME = sl.PORT_UNLADING_NAME
		-- This value is set to the TI column PORT_UNLADING_STATE.
		,sl.PORT_US_CLEARING_ST = pd.STATE_CD
		FROM dbo.stgload_processed sl
		JOIN dbo.tiref_port_dim pd
		 ON pd.PORT_KEY = sl.USPORT_CODE
		JOIN dbo.tiref_uscs_district_dim udd
		 ON pd.DISTRICT_CD = udd.DISTRICT_CD
		JOIN dbo.tiref_region_swap rs
		 ON rs.CNTRYCD = sl.CTRYCODE
		JOIN dbo.tiref_coast_swap cs
		 ON cs.PORT_CD = sl.USPORT_CODE
		JOIN dbo.stg_sline sline
		 ON sline.code = sl.SLINE
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'Archive_stgload'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Archive stgload data
	INSERT INTO dbo.stgload_archive
	SELECT *,@IdLoadLog As IdLoadLog,getdate() As archive_date
	 FROM dbo.stgload_processed
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'Sync_stgload_TI_MasterData'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Delete records from stgload_processed that are NOT already in TI_MasterData
	-- NOTE: This means we are picking up records from PES processed that have
	--  not been processed from PES raw in the past. This should NOT happen.

	IF @Direction = 'I'
		DELETE
		 FROM dbo.stgload_processed
		WHERE BOL_ID NOT IN (SELECT BOL_ID FROM dbo.TI_Import_MasterData)
	ELSE --  @Direction = 'E'
		DELETE
		 FROM dbo.stgload_processed
		WHERE BOL_ID NOT IN (SELECT BOL_ID FROM dbo.TI_Export_MasterData)

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'Populate_TI_MasterData'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Update records in TI_MasterData
	IF @Direction = 'I'
		UPDATE timdi SET 
			timdi.FOREIGN_PORT_NAME		=	sl.FOREIGN_PORT_NAME	,
			timdi.PORT_UNLADING_NAME	=	sl.PORT_UNLADING_NAME	,
			timdi.PORT_UNLADING_STATE	=	sl.PORT_UNLADING_STATE	,
			timdi.PORT_US_CLEARING_NAME	=	sl.PORT_US_CLEARING_NAME,
			timdi.PORT_US_CLEARING_ST	=	sl.PORT_US_CLEARING_ST	,
			timdi.PORT_US_CLEARING_DIST	=	sl.PORT_US_CLEARING_DIST,
			timdi.SCAC_CARRIER_NAME		=	sl.SCAC_CARRIER_NAME	,
			timdi.REGION_ORIGIN			=	sl.REGION_ORIGIN		,
			timdi.COUNTRY_ORIGIN		=	sl.COUNTRY_ORIGIN		,
			timdi.ARRIVAL_DATE			=	sl.ARRIVAL_DATE			,
			timdi.ARRIVAL_WEEK			=	sl.ARRIVAL_WEEK			,
			--timdi.PRODUCT_DESC	=	COALESCE(timdi.PRODUCT_DESC,'') + COALESCE(sl.PRODUCT_DESC,''),
			timdi.PRODUCT_DESC_PROCESSED=	sl.PRODUCT_DESC			,
			timdi.MANIFEST_NBR			=	sl.MANIFEST_NBR			,
			timdi.BL_CNTR_FLG			=	sl.BL_CNTR_FLG			,
			timdi.STD_WGT				=	sl.STD_WGT				,
			timdi.MANIFEST_QTY			=	sl.MANIFEST_QTY			,
			timdi.TEU_CNT				=	sl.TEU_CNT				,
			timdi.HS_CODES				=	sl.HS_CODES				,
			timdi.SLINE					=	sl.SLINE				,
			timdi.EST_VALUE				=	sl.EST_VALUE			,
			timdi.NVOCC_FLAG			=	sl.NVOCC_FLAG			,
			timdi.CTRYCODE				=	sl.CTRYCODE				,
			timdi.US_COAST				=	sl.US_COAST				,
			timdi.USPORT_CODE			=	sl.USPORT_CODE			,
			timdi.FPORT_CODE			=	sl.FPORT_CODE			,
			timdi.JOC_CODES				=	sl.JOC_CODES			,
			timdi.VISIBILITY			=	sl.VISIBILITY			,
			timdi.MODIFY_DATE			=	getdate()
		 FROM dbo.TI_Import_MasterData timdi
		JOIN dbo.stgload_processed sl ON sl.BOL_ID = timdi.BOL_ID
	ELSE --  @Direction = 'E'
		UPDATE timde SET 
			timde.FOREIGN_PORT_NAME		=	sl.FOREIGN_PORT_NAME	,
			timde.PORT_UNLADING_NAME	=	sl.PORT_UNLADING_NAME	,
			timde.PORT_UNLADING_STATE	=	sl.PORT_UNLADING_STATE	,
			timde.PORT_US_CLEARING_NAME	=	sl.PORT_US_CLEARING_NAME,
			timde.PORT_US_CLEARING_ST	=	sl.PORT_US_CLEARING_ST	,
			timde.PORT_US_CLEARING_DIST	=	sl.PORT_US_CLEARING_DIST,
			timde.SCAC_CARRIER_NAME		=	sl.SCAC_CARRIER_NAME	,
			timde.REGION_ORIGIN			=	sl.REGION_ORIGIN		,
			timde.COUNTRY_ORIGIN		=	sl.COUNTRY_ORIGIN		,
			timde.ARRIVAL_DATE			=	sl.ARRIVAL_DATE			,
			timde.ARRIVAL_WEEK			=	sl.ARRIVAL_WEEK			,
			--timde.PRODUCT_DESC	=	COALESCE(timde.PRODUCT_DESC,'') + COALESCE(sl.PRODUCT_DESC,'')			,
			timde.PRODUCT_DESC_PROCESSED=	sl.PRODUCT_DESC			,
			timde.MANIFEST_NBR			=	sl.MANIFEST_NBR			,
			timde.BL_CNTR_FLG			=	sl.BL_CNTR_FLG			,
			timde.STD_WGT				=	sl.STD_WGT				,
			timde.MANIFEST_QTY			=	sl.MANIFEST_QTY			,
			timde.TEU_CNT				=	sl.TEU_CNT				,
			timde.HS_CODES				=	sl.HS_CODES				,
			timde.SLINE					=	sl.SLINE				,
			timde.EST_VALUE				=	sl.EST_VALUE			,
			timde.NVOCC_FLAG			=	sl.NVOCC_FLAG			,
			timde.CTRYCODE				=	sl.CTRYCODE				,
			timde.US_COAST				=	sl.US_COAST				,
			timde.USPORT_CODE			=	sl.USPORT_CODE			,
			timde.FPORT_CODE			=	sl.FPORT_CODE			,
			timde.JOC_CODES				=	sl.JOC_CODES			,
			timde.VISIBILITY			=	sl.VISIBILITY			,
			timde.MODIFY_DATE			=	getdate()
		 FROM dbo.TI_Export_MasterData timde
		JOIN dbo.stgload_processed sl ON sl.BOL_ID = timde.BOL_ID

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- Generate Load Report
SET @StepName = 'GenerateLoadReport'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Pass in the load id and current process name
	EXEC dbo.usp_PopulateLoadStats
	 @IdLoadLog, @ProcessName
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done' -- TODO - not sure if stored proc call is going to set @@ROWCOUNT
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
