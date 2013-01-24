/****** Object:  StoredProcedure [dbo].[usp_PopulateProcessedData]    Script Date: 01/09/2013 18:40:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		[aa]
-- Create date: 08/23/2010
-- Description:	Pull 'processed' data from PES
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
CREATE PROCEDURE [dbo].[usp_PopulateProcessedData] 
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
	SELECT @ProcessName = 'PopulateProcessedData', @StepName = '', @Comment = ''

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
	 -- IPiers data that has been updated since PopulateProcessedData was last run SUCCESSFULLY
	SELECT @MaxStartDt = MAX(StartDate)
	 FROM dbo.LoadLog WHERE ProcessName=@ProcessName AND Direction=@Direction
		 AND Status IN ('Successful','SuccessfulWithWarnings')

	-- If there are no entries in LoadLoad table, fetch what data
	IF @MaxStartDt IS NULL
		SET @MaxStartDt = CONVERT(datetime,'1/1/1900') -- fetch all PES data - do we want this? probably not
		--SET @MaxStartDt = getdate()	-- fetch no PES data - just to be safe

	SET @MaxUDate = LTRIM(RTRIM(STR(MONTH(@MaxStartDt)))) +'/' +
					LTRIM(RTRIM(STR(DAY(@MaxStartDt)))) +'/' +
					LTRIM(RTRIM(STR(YEAR (@MaxStartDt))))
SELECT @RowsAffected = -1, @Comment = 'Done. @MaxUDate = ' + @MaxUDate
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

--//////////////////////////////////////////////////////
--REMOVED BY KRS11262012 - changed the table structure instead to accomidate the larger numbers.  
--//////////////////////////////////////////////////////
-- Added By Harish on Oct-13-- This part will take care of Field POUND 
--Modified by Hemal on 02/27/2012 this will take care of import as well as exports data.
--if exceeds 2147483647 (ie, if it over flows in INT data type)
--TRUNCATE TABLE PiersTILoad.dbo.WeightErrTemp

--if @Direction='I'
--	BEGIN
--		insert	into PiersTILoad.dbo.WeightErrTemp 
--		SELECT  DISTINCT T2.BL_NBR,T1.bol_id,T1.pounds 
--				FROM PESDW.DBO.ti_processed_data_bol_V   T1 WITH (nolock),
--				PiersTILoad.dbo.TI_Import_MasterData  T2 WITH (nolock)
--				WHERE T1.dir=@Direction
--				 AND T1.LOAD_STATUS ='C'
--				 AND T1.udate >=@MaxUDate
--				 AND T1.Pounds>=2147483647
--				 AND T1.bol_id=T2.bol_id
--	END

--if @Direction='E'
--	BEGIN
--		insert	into PiersTILoad.dbo.WeightErrTemp 
--		SELECT  DISTINCT T2.BL_NBR,T1.bol_id,T1.pounds 
--				FROM PESDW.DBO.ti_processed_data_bol_V   T1 WITH (nolock),
--				PiersTILoad.dbo.TI_Export_MasterData  T2 WITH (nolock)
--				WHERE T1.dir=@Direction
--				 AND T1.LOAD_STATUS ='C'
--				 AND T1.udate >=@MaxUDate
--				 AND T1.Pounds>=2147483647
--				 AND T1.bol_id=T2.bol_id
--	END




--IF @@Rowcount!=0 
--	BEGIN 
--		DECLARE @EBODY varchar(1000) 
--		DECLARE @ERECIPIENTS varchar(1000)
--		SELECT @ERECIPIENTS='hdesai@joc.com;SKasi@piers.com'--TOADDRESS FROM pes.dbo.METAMAILADDRESS (NOLOCK)
		
--		EXEC PiersTILoad.dbo.SendEmailObjectAsHTML 
--						  @source_db    = 'PiersTILoad',
--                          @schema       = '',
--                          @object_name  = 'dbo.WeightErrTemp',
--                          @order_clause = 'bol_id',
--                          @email = @ERECIPIENTS,
--						  @subject ='TI Load - Weight Error (POUNDS FIELD) ',
--						  @profile_name = 'Piers TI Mail Profile',
--						  @textBeforeObject='Hello,<br><br> Following bill(s) have been filtered out due to invalid value in its POUNDS field.<br> Please correct these bills. Once corrected, TI load will automatically load these bills.',
--						  @textAfterObject='<br>NOTE: This is NOT A PRODUCTION DOWN. <br><br> Thanks,<br>Administrator'
--	END

-- Added By Harish on Oct-13 -- ENDS HERE --
--//////////////////////////////////////////////////////
--END REMOVAL SECTION
--//////////////////////////////////////////////////////

DECLARE @NumBols int

-- -- Get processed data
-- processed_bl
SET @StepName = 'GetProcessedData_processed_bl'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.processed_bl
	INSERT INTO dbo.processed_bl
	SELECT 
		BOL_ID
		, NULL As z_BL_NBR
		, VDATE, NVOCC_FLAG, SLINE_DESC, SLINE, 
		COUNTRYL, CTRYCODE, 
		COALESCE(
			(
				SELECT TOP 1 LEFT(SOURCE,4)
				FROM PES_RAW.PES.DBO.PES_PORT_CONVERSION P (NOLOCK)
				WHERE TARGET = USPORT_CODE
			),LEFT(USPORT_CODE,4)) AS USPORT_CODE,
		UNLADING_PORT_NAME, 
		PORT_UNLADING_STATE, 
		COALESCE(
			(
				SELECT TOP 1 SOURCE
				FROM PES_RAW.PES.DBO.PES_PORT_CONVERSION P (NOLOCK)
				WHERE TARGET = FPORT_CODE
			),FPORT_CODE) AS FPORT_CODE,
		FOREIGN_PORT_NAME, 
		REGION_ORIGIN, 
		US_COAST, 
		VISIBILITY, 
		PORT_US_CLEARING_NAME, 
		PORT_US_CLEARING_ST, 
		PORT_US_CLEARING_DIST, 
		MANIFEST_NBR, VALUE, TEU, POUNDS,MANIFEST_QTY, U_M, UDATE, DIR ,CONFLAG
	 FROM NWPES.PESDW.DBO.ti_processed_data_bol_V tvub
	WHERE dir=@Direction
	 AND LOAD_STATUS ='C'
	 -- removed!!! if at all required, run a query directly on Master table to mark these records as Visibility 'H' or 'D' or 'R' for restricted sacc
	 -- AND SLINE NOT IN (SELECT SCAC FROM Ti3Load.DBO.RESTRICTED_SCAC (NOLOCK))

	 AND udate >= @MaxUDate

-- [aa] - 12/17/2010
-- In case we ever need to run a 'special' update
--  populate the BOL_IDs you need to include into a temp table (called tmp_bols_to_fix)
--  then comment the 'AND udate >= @MaxUDate' clause above and uncomment the line below
--	 AND (udate >= @MaxUDate OR BOL_ID IN (SELECT BOL_ID FROM tmp_bols_to_fix WHERE dir=@Direction))


-- Added By Harish on Oct-13-- This part will take care of Field POUND 
--if exceeds 2147483647 (ie, if it over flows in INT data type)
	AND  tvub.BOL_ID NOT IN	 
		(SELECT BOL_ID FROM PiersTILoad.dbo.WeightErrTemp)
-- Added By Harish on Oct-13 -- ENDS HERE --


SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @NumBols = @RowsAffected

-- processed_cmd
SET @StepName = 'GetProcessedData_processed_cmd'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.processed_cmd
	INSERT INTO dbo.processed_cmd
	SELECT tvuc.BOL_ID,
		 tvuc.CMD_ID, 
		tvuc.VALUE,
		tvuc.HARM_CODE As harm_code,
		tvuc.COMCODE As COMCODE,
		tvuc.TEU As teu,
		tvuc.POUNDS As pounds,
		tvuc.QTY,
		tvuc.U_M ,
		tvuc.COMMODITY,
		NULL As z_udate,
		NULL As z_dir		 
		FROM NWPES.PESDW.DBO.ti_processed_data_cmd_V tvuc 
		WHERE EXISTS (SELECT 1 FROM dbo.processed_bl pbl WHERE tvuc.BOL_ID = pbl.BOL_ID)
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

--	-- Log Number of CMDs fetched
--	IF @RowsAffected <= 0
--	BEGIN
--		SET @Comment = 'Warning - No Bills to load CMD!'
--		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, 'SuccessfulWithWarnings', @Comment
--		-- No commodities to process, nothing more to do, we're done at this point...
--		RETURN
--	END

SET @StepName = 'GetProcessedDataPrePES_pre_pes_usshipment'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE pre_pes_usshipment
	INSERT INTO pre_pes_usshipment
	SELECT *
	 FROM PESDW.dbo.ti_prePES_data_usshipment_V tvub
	WHERE dir=@Direction

	 -- REMOVED!!! if at all we should fetch this information and apply these as deletes to the master table, right?
	 --AND SLINE NOT IN (SELECT SCAC FROM Ti3Load.DBO.RESTRICTED_SCAC (NOLOCK)) 

	 -- ONLY fetching updates to 2010 data from pre-PES for now
	 -- We can keep expanding this as older data is re-indexed
	 AND vdate >= '01/01/2010'

	 AND udate >= @MaxUDate

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @NumBols = @NumBols + @RowsAffected

	-- Log Number of BOLs fetched
	IF @NumBols <= 0
	BEGIN
		SET @Comment = 'Warning - No Bills to load BOL!'
		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, 'SuccessfulWithWarnings', @Comment
		-- No BOLs to process, nothing more to do, we're done at this point...
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
		 FROM dbo.processed_bl pbl
		UNION -- Note: UNION removes duplicates already
		SELECT	pbl.USPORT_CODE As code
				,pbl.UNLADING_PORT_NAME As name
				,NULL As state
				,NULL As country
				,NULL As region
		 FROM dbo.processed_bl pbl
		UNION
		SELECT	NULL As code
				,pbl.port_us_clearing_name As name
				,pbl.port_us_clearing_st As state
				,pbl.port_us_clearing_dist As country
				,NULL As region
		 FROM dbo.processed_bl pbl
		UNION
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
		 FROM dbo.processed_bl pbl
		UNION
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
		pc.BOL_ID
		,NULL As cmd_seq_nbr
		,pc.CMD_ID
		,NULL As cntr_nbr
		,pc.QTY As piece_cnt
		,pc.U_M As piece_unit
		,pc.COMMODITY As cmd_desc
		,pc.HARM_CODE As harm_code
		,pc.COMCODE As COMCODE
		,pc.TEU As teu
		,pc.POUNDS As pounds
		,pc.VALUE As estimated_value
	FROM dbo.processed_cmd pc
-- [aa] - 09/01/2010 - changed stg_cmd.piece_cnt from int to bigint
-- *    WHERE 
-- * 		qty < 2147483647 -- ???
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_cmd
SET @StepName = 'PopulateStgData_cmd_pre_pes'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	--TRUNCATE TABLE dbo.stg_cmd
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
		,pc.recnum As CMD_ID
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
			 ROW_NUMBER() OVER (PARTITION BY BOL_ID ORDER BY REGION_ORIGIN,COUNTRYL,VDATE,MANIFEST_NBR,NVOCC_FLAG,CTRYCODE,US_COAST,VISIBILITY) As Rank
			,pbl.BOL_ID
			,NULL As bl_nbr
			,dir
--			-- IF a t_nbr comes through DQA, it gets a ucount of 0 in the archive
--			-- IF a t_nbr comes through IPiers, without first coming through DQA, it gets a ucount of -1
--			--	even if it comes from IPiers multiple times
--			-- IF a t_nbr comes through IPiers, after first coming through DQA, it gets a ucount of ++1 for every new update
--			,(SELECT CASE WHEN COALESCE(MAX(ucount),-1) = -1 THEN -1 ELSE MAX(ucount)+1 END
--			  FROM ti_archive.bl tab WHERE tab.t_nbr=pbl.BOL_ID) As ucount
--			,getdate() As udate
			,pbl.REGION_ORIGIN As origin_region
			,pbl.COUNTRYL As origin_country
			,pbl.VDATE As vdate
			,pbl.MANIFEST_NBR As manifest_nbr
			,pbl.NVOCC_FLAG As nvocc_flag
			,pbl.CTRYCODE As country_code
			,pbl.US_COAST As us_coast
			,pbl.VISIBILITY As visibility
			,pbl.POUNDS As std_weight
			,pbl.MANIFEST_QTY As manifest_qty
			,pbl.TEU As teu_cnt
			,pbl.VALUE As estimated_value
			,pbl.CONFLAG AS conflag
		 FROM dbo.processed_bl pbl
	)
	INSERT INTO dbo.stg_bl (
		 BOL_ID
		,bl_nbr
		,dir
--		,pdate
--		,ucount
--		,udate
		,origin_region
		,origin_country
		,vdate
		,manifest_nbr
		,voyage_nbr
		,conflag
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
		,visibility
		,batch_id
--		,orig_bl_nbr
--		,action
		,load_nbr
--		,load_source
--		,load_indicator
		,IdLoadLog
	)
	SELECT
		 tubr.BOL_ID

--		,STR(tubr.t_nbr)+'_'+'U' As bl_nbr -- BL_NBR column is NOT NULL in prod stgload table -- 'U' is to indicate update
--		,tubr.t_nbr As bl_nbr -- 
		-- [aa] - 08/13/2010 - t_nbr + '_U' is not working because indexation needs to happen
		--  against bl_nbr, but not such bl_nbr is ever found in the index
		-- See dbo.usp_PopulateTISTGLOADFromDQAandIPIERS for temp fix
		, NULL As bl_nbr
		,tubr.dir
--		,NULL As pdate
--		,tubr.ucount
--		,tubr.udate
		,tubr.origin_region
		,tubr.origin_country
		,tubr.vdate
		,tubr.manifest_nbr
		,NULL As voyage_nbr
		--,NULL As conflag
		,tubr.conflag
		,tubr.std_weight -- TODO - convert pounds to KG?
		,NULL As measure_value
		,NULL As measure_unit
		,tubr.manifest_qty
		,NULL As manifest_unit
		,tubr.teu_cnt
		,NULL As teu_src
		,NULL As inbond_entry_type
		,NULL As trans_mode_description
		,tubr.estimated_value
		,NULL As hazard_class
		,tubr.nvocc_flag
		,tubr.country_code
		,tubr.us_coast
		,NULL As cons_state
		,NULL As not_state
		,NULL As anot_state
		,tubr.visibility
		,NULL As batch_id
--		,NULL As orig_bl_nbr
--		,tubr.bl_nbr As orig_bl_nbr
--		,NULL As action
		,NULL As load_nbr
--		,'ipiers' As load_source
--		,'update' As load_indicator
		,@IdLoadLog As IdLoadLog
	 FROM tmp_unique_base_record tubr
	WHERE  tubr.Rank = 1
	ORDER BY BOL_ID
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_bl
-- Populate non-id(ed) columns
SET @StepName = 'PopulateStgData_bl_pre_pes'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	--TRUNCATE TABLE dbo.stg_bl
	;WITH tmp_unique_base_record As (
		-- NOTE: This is required because usshipment_joined might not have the same values for
		--		 the base BOL fields, e.g. REGION_ORIGIN,COUNTRYL,VDATE... etc.
		--		 We want to take the 1st available permutation for these fields and move on...
		SELECT
			 ROW_NUMBER() OVER (PARTITION BY t_nbr ORDER BY REGION_ORIGIN,COUNTRYL,VDATE,MANIFEST_NBR,NVOCC_FLAG,CTRYCODE,US_COAST) As Rank
			,pbl.t_nbr
			,NULL As bl_nbr
			,pbl.dir
			,pbl.REGION_ORIGIN As origin_region
			,pbl.COUNTRYL As origin_country
			,pbl.VDATE As vdate
			,pbl.MANIFEST_NBR As manifest_nbr
			,pbl.NVOCC_FLAG As nvocc_flag
			,pbl.CTRYCODE As country_code
			,pbl.US_COAST As us_coast
			,'V' As visibility
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
		,dir
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
		,visibility
		,batch_id
		,load_nbr
		,IdLoadLog
	)
	SELECT
		 tubr.t_nbr As BOL_ID
		, NULL As bl_nbr
		,tubr.dir
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
		,tubr.visibility
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

-- stg_bl_ids
-- Populate id(ed) columns
SET @StepName = 'PopulateStgData_bl_ids_pre_pes'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	--TRUNCATE TABLE dbo.stg_bl_ids
	;WITH tmp_unique_base_record As (
		-- NOTE: This is required because usshipment_joined might not have the same values for
		--		 the base BOL fields, e.g. SLINE,FPORT_CODE,USPORT_CODE... etc.
		--		 We want to take the 1st available permutation for these fields and move on...
		SELECT
			 ROW_NUMBER() OVER (PARTITION BY t_nbr ORDER BY SLINE,SLINE_DESC,FPORT_CODE,FOREIGN_PORT_NAME,USPORT_CODE,UNLADING_PORT_NAME,PORT_US_CLEARING_NAME,PORT_US_CLEARING_ST,PORT_US_CLEARING_DIST) As Rank
			,pbl.t_nbr As BOL_ID
			,pbl.SLINE
			,pbl.SLINE_DESC
			,pbl.FPORT_CODE
			,pbl.FOREIGN_PORT_NAME
			,pbl.USPORT_CODE
			,pbl.UNLADING_PORT_NAME
			,pbl.PORT_US_CLEARING_NAME
			,pbl.PORT_US_CLEARING_ST
			,pbl.PORT_US_CLEARING_DIST
		FROM dbo.pre_pes_usshipment pbl
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

----[aa] - 08/05/2010
---- DIR cannot be NULL anymore
----  Upto now we used to leave direction NULL for UPDATEs
----  We need to populate direction in STGLOAD for UPDATEs as well
--UPDATE dbo.stgload_processed
-- SET DIR = @Direction
--WHERE DIR IS NULL
----[aa] - 08/05/2010

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
-- [aa] - 12/17/2010
--  sline_desc should not be updated here - commenting it out
--		-- Is actually SLINE_DESC, not SCAC name
--		,sl.SCAC_CARRIER_NAME = sline.name
		-- This value is set to the TI column PORT_UNLADING_NAME.
		,sl.PORT_US_CLEARING_NAME = sl.PORT_UNLADING_NAME
		-- This value is set to the TI column PORT_UNLADING_STATE.
		,sl.PORT_US_CLEARING_ST = pd.STATE_CD
--SELECT sl.BOL_ID,sl.sline,sl.SCAC_CARRIER_NAME,sline.*
		FROM dbo.stgload_processed sl
		JOIN dbo.tiref_port_dim pd
		 ON pd.PORT_KEY = sl.USPORT_CODE
		JOIN dbo.tiref_uscs_district_dim udd
		 ON pd.DISTRICT_CD = udd.DISTRICT_CD
		JOIN dbo.tiref_region_swap rs
		 ON rs.CNTRYCD = sl.CTRYCODE
		JOIN dbo.tiref_coast_swap cs
		 ON cs.PORT_CD = sl.USPORT_CODE
--		JOIN dbo.stg_sline sline
--		 ON sline.code = sl.SLINE
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

	-- Populate dbo.stgload_processed_deletes table for analysis
	--TRUNCATE TABLE dbo.stgload_processed_deletes

	IF @Direction = 'I'
	BEGIN
		INSERT INTO dbo.stgload_processed_deletes
		SELECT *,@IdLoadLog As IdLoadLog
		 FROM dbo.stgload_processed
		WHERE BOL_ID NOT IN (SELECT BOL_ID FROM dbo.TI_Import_MasterData)

		DELETE
		 FROM dbo.stgload_processed
		WHERE BOL_ID NOT IN (SELECT BOL_ID FROM dbo.TI_Import_MasterData)
	END
	ELSE --  @Direction = 'E'
	BEGIN
		INSERT INTO dbo.stgload_processed_deletes
		SELECT *,@IdLoadLog As IdLoadLog
		 FROM dbo.stgload_processed
		WHERE BOL_ID NOT IN (SELECT BOL_ID FROM dbo.TI_Export_MasterData)

		DELETE
		 FROM dbo.stgload_processed
		WHERE BOL_ID NOT IN (SELECT BOL_ID FROM dbo.TI_Export_MasterData)
	END
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	-- IF @RowsAffected > 0, means we are picking up records from PES processed that have
	-- not been processed from PES raw in the past. This should NOT happen
	IF @RowsAffected > 0
	BEGIN
		SET @NumberOfWarningsRaised = @NumberOfWarningsRaised + 1
		SET @Comment = 'Warning - ' + LTRIM(RTRIM(STR(@RowsAffected)))
		 + ' records were removed from stgload_processed as they are not in Master table!'
		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, 'SuccessfulWithWarnings', @Comment
	END

SET @StepName = 'Populate_TI_MasterData'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Update records in TI_MasterData
	IF @Direction = 'I'
		UPDATE timdi SET 
			timdi.FOREIGN_PORT_NAME		=	COALESCE(sl.FOREIGN_PORT_NAME, timdi.FOREIGN_PORT_NAME),
			timdi.PORT_UNLADING_NAME	=	COALESCE(sl.PORT_UNLADING_NAME, timdi.PORT_UNLADING_NAME),
			timdi.PORT_UNLADING_STATE	=	COALESCE(sl.PORT_UNLADING_STATE, timdi.PORT_UNLADING_STATE),
			timdi.PORT_US_CLEARING_NAME	=	COALESCE(sl.PORT_US_CLEARING_NAME, timdi.PORT_US_CLEARING_NAME),
			timdi.PORT_US_CLEARING_ST	=	COALESCE(sl.PORT_US_CLEARING_ST, timdi.PORT_US_CLEARING_ST),
			timdi.PORT_US_CLEARING_DIST	=	COALESCE(sl.PORT_US_CLEARING_DIST, timdi.PORT_US_CLEARING_DIST),
			timdi.SCAC_CARRIER_NAME		=	COALESCE(sl.SCAC_CARRIER_NAME, timdi.SCAC_CARRIER_NAME),
			timdi.REGION_ORIGIN			=	COALESCE(sl.REGION_ORIGIN, timdi.REGION_ORIGIN),
			timdi.COUNTRY_ORIGIN		=	COALESCE(sl.COUNTRY_ORIGIN, timdi.COUNTRY_ORIGIN),
			timdi.ARRIVAL_DATE			=	COALESCE(sl.ARRIVAL_DATE, timdi.ARRIVAL_DATE),
			timdi.ARRIVAL_WEEK			=	COALESCE(sl.ARRIVAL_WEEK, timdi.ARRIVAL_WEEK),
			timdi.PRODUCT_DESC_PROCESSED=	COALESCE(sl.PRODUCT_DESC, timdi.PRODUCT_DESC_PROCESSED),
			timdi.MANIFEST_NBR			=	COALESCE(sl.MANIFEST_NBR, timdi.MANIFEST_NBR),
			timdi.BL_CNTR_FLG			=	COALESCE(sl.BL_CNTR_FLG, timdi.BL_CNTR_FLG),
			timdi.STD_WGT				=	COALESCE(sl.STD_WGT, timdi.STD_WGT),
			timdi.MANIFEST_QTY			=	COALESCE(sl.MANIFEST_QTY, timdi.MANIFEST_QTY),
			timdi.TEU_CNT				=	COALESCE(sl.TEU_CNT, timdi.TEU_CNT),
			timdi.HS_CODES				=	COALESCE(sl.HS_CODES, timdi.HS_CODES),
			timdi.SLINE					=	COALESCE(sl.SLINE, timdi.SLINE),
			timdi.EST_VALUE				=	COALESCE(sl.EST_VALUE, timdi.EST_VALUE),
			timdi.NVOCC_FLAG			=	COALESCE(sl.NVOCC_FLAG, timdi.NVOCC_FLAG),
			timdi.CTRYCODE				=	COALESCE(sl.CTRYCODE, timdi.CTRYCODE),
			timdi.US_COAST				=	COALESCE(sl.US_COAST, timdi.US_COAST),
			timdi.USPORT_CODE			=	COALESCE(sl.USPORT_CODE, timdi.USPORT_CODE),
			timdi.FPORT_CODE			=	COALESCE(sl.FPORT_CODE, timdi.FPORT_CODE),
			timdi.JOC_CODES				=	COALESCE(sl.JOC_CODES, timdi.JOC_CODES),
			timdi.VISIBILITY			=	COALESCE(sl.VISIBILITY, timdi.VISIBILITY),
			timdi.MODIFY_DATE			=	getdate()
		 FROM dbo.TI_Import_MasterData timdi
		JOIN dbo.stgload_processed sl ON sl.BOL_ID = timdi.BOL_ID
	ELSE --  @Direction = 'E'
		UPDATE timde SET 
			timde.FOREIGN_PORT_NAME		=	COALESCE(sl.FOREIGN_PORT_NAME, timde.FOREIGN_PORT_NAME),
			timde.PORT_UNLADING_NAME	=	COALESCE(sl.PORT_UNLADING_NAME, timde.PORT_UNLADING_NAME),
			timde.PORT_UNLADING_STATE	=	COALESCE(sl.PORT_UNLADING_STATE, timde.PORT_UNLADING_STATE),
			timde.PORT_US_CLEARING_NAME	=	COALESCE(sl.PORT_US_CLEARING_NAME, timde.PORT_US_CLEARING_NAME),
			timde.PORT_US_CLEARING_ST	=	COALESCE(sl.PORT_US_CLEARING_ST, timde.PORT_US_CLEARING_ST),
			timde.PORT_US_CLEARING_DIST	=	COALESCE(sl.PORT_US_CLEARING_DIST, timde.PORT_US_CLEARING_DIST),
			timde.SCAC_CARRIER_NAME		=	COALESCE(sl.SCAC_CARRIER_NAME, timde.SCAC_CARRIER_NAME),
			timde.REGION_ORIGIN			=	COALESCE(sl.REGION_ORIGIN, timde.REGION_ORIGIN),
			timde.COUNTRY_ORIGIN		=	COALESCE(sl.COUNTRY_ORIGIN, timde.COUNTRY_ORIGIN),
			timde.ARRIVAL_DATE			=	COALESCE(sl.ARRIVAL_DATE, timde.ARRIVAL_DATE),
			timde.ARRIVAL_WEEK			=	COALESCE(sl.ARRIVAL_WEEK, timde.ARRIVAL_WEEK),
			timde.PRODUCT_DESC_PROCESSED=	COALESCE(sl.PRODUCT_DESC, timde.PRODUCT_DESC_PROCESSED),
			timde.MANIFEST_NBR			=	COALESCE(sl.MANIFEST_NBR, timde.MANIFEST_NBR),
			timde.BL_CNTR_FLG			=	COALESCE(sl.BL_CNTR_FLG, timde.BL_CNTR_FLG),
			timde.STD_WGT				=	COALESCE(sl.STD_WGT, timde.STD_WGT),
			timde.MANIFEST_QTY			=	COALESCE(sl.MANIFEST_QTY, timde.MANIFEST_QTY),
			timde.TEU_CNT				=	COALESCE(sl.TEU_CNT, timde.TEU_CNT),
			timde.HS_CODES				=	COALESCE(sl.HS_CODES, timde.HS_CODES),
			timde.SLINE					=	COALESCE(sl.SLINE, timde.SLINE),
			timde.EST_VALUE				=	COALESCE(sl.EST_VALUE, timde.EST_VALUE),
			timde.NVOCC_FLAG			=	COALESCE(sl.NVOCC_FLAG, timde.NVOCC_FLAG),
			timde.CTRYCODE				=	COALESCE(sl.CTRYCODE, timde.CTRYCODE),
			timde.US_COAST				=	COALESCE(sl.US_COAST, timde.US_COAST),
			timde.USPORT_CODE			=	COALESCE(sl.USPORT_CODE, timde.USPORT_CODE),
			timde.FPORT_CODE			=	COALESCE(sl.FPORT_CODE, timde.FPORT_CODE),
			timde.JOC_CODES				=	COALESCE(sl.JOC_CODES, timde.JOC_CODES),
			timde.VISIBILITY			=	COALESCE(sl.VISIBILITY, timde.VISIBILITY),
			timde.MODIFY_DATE			=	getdate()
		 FROM dbo.TI_Export_MasterData timde
		JOIN dbo.stgload_processed sl ON sl.BOL_ID = timde.BOL_ID

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- [aa] - 12/17/2010
-- This is to propogate any sline reference updates that are
--  made to PES.dbo.REF_CARRIER up to the Master tables
-- The idea is to see if there are multiple entries for the same code
--  in stg_sline table and update any records in master table that are referring
--  to any of the older permutations
SET @StepName = 'Update_TI_MasterData_SLINE_REF'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Update records in TI_MasterData
	IF @Direction = 'I'
		BEGIN
			;WITH tmp_code_dup As ( -- duplicate sline codes
			 SELECT code,count(*) As count
			  FROM dbo.stg_sline
			 GROUP BY code
			 HAVING count(*)>1
			), tmp_code_dups As ( -- duplicate sline codes, ranked
			 SELECT 
			   ROW_NUMBER() OVER (PARTITION BY code ORDER BY id DESC) As Rank
			  ,*
			  FROM dbo.stg_sline
			 WHERE code IN (SELECT code FROM tmp_code_dup)
			) --SELECT * FROM tmp_code_dups
			, tmp_code_max As ( -- duplicate sline codes, get latest record
			 SELECT *
			  FROM tmp_code_dups
			 WHERE Rank=1
			) --SELECT * FROM tmp_code_max
			--SELECT COUNT(*)
			--SELECT TOP 100 timdi.BOL_ID, timdi.SLINE, timdi.SCAC_CARRIER_NAME, timdi.MODIFY_DATE, sline.*
			UPDATE timdi SET timdi.SCAC_CARRIER_NAME = sline.name, timdi.MODIFY_DATE = getdate()
			 FROM dbo.TI_Import_MasterData timdi
			JOIN tmp_code_max sline ON sline.code = timdi.SLINE
			 AND sline.name != timdi.SCAC_CARRIER_NAME
		END
	ELSE --  @Direction = 'E'
		BEGIN
			;WITH tmp_code_dup As ( -- duplicate sline codes
			 SELECT code,count(*) As count
			  FROM dbo.stg_sline
			 GROUP BY code
			 HAVING count(*)>1
			), tmp_code_dups As ( -- duplicate sline codes, ranked
			 SELECT 
			   ROW_NUMBER() OVER (PARTITION BY code ORDER BY id DESC) As Rank
			  ,*
			  FROM dbo.stg_sline
			 WHERE code IN (SELECT code FROM tmp_code_dup)
			) --SELECT * FROM tmp_code_dups
			, tmp_code_max As ( -- duplicate sline codes, get latest record
			 SELECT *
			  FROM tmp_code_dups
			 WHERE Rank=1
			) --SELECT * FROM tmp_code_max
			--SELECT COUNT(*)
			--SELECT TOP 100 timde.BOL_ID, timde.SLINE, timde.SCAC_CARRIER_NAME, timde.MODIFY_DATE, sline.*
			UPDATE timde SET timde.SCAC_CARRIER_NAME = sline.name, timde.MODIFY_DATE = getdate()
			 FROM dbo.TI_Export_MasterData timde
			JOIN tmp_code_max sline ON sline.code = timde.SLINE
			 AND sline.name != timde.SCAC_CARRIER_NAME -- update the records for which sline_desc has changed
		END

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- [aa] - 12/22/2010
-- This is to propogate update any 'TEMPORARY CARRIER' to 'UNAVAILABLE ON BILL'
SET @StepName = 'Update_TI_MasterData_SLINE_REF'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Update records in TI_MasterData
	IF @Direction = 'I'
		BEGIN
			UPDATE dbo.TI_Import_MasterData
			 SET SCAC_CARRIER_NAME='UNAVAILABLE ON BILL', MODIFY_DATE=getdate()
			WHERE SCAC_CARRIER_NAME='TEMPORARY CARRIER'
		END
	ELSE --  @Direction = 'E'
		BEGIN
			UPDATE dbo.TI_Export_MasterData
			 SET SCAC_CARRIER_NAME='UNAVAILABLE ON BILL', MODIFY_DATE=getdate()
			WHERE SCAC_CARRIER_NAME='TEMPORARY CARRIER'
		END

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
