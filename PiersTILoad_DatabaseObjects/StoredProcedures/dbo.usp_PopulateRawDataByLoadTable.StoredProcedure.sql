/****** Object:  StoredProcedure [dbo].[usp_PopulateRawDataByLoadTable]    Script Date: 01/09/2013 18:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PopulateRawDataByLoadTable] 
	@Direction varchar(100), @NumloadsToExecute int
AS
BEGIN

	WITH q AS (
		SELECT TOP(@NumloadsToExecute) * 
		FROM dbo.ManualTILoad tb2 
		WHERE tb2.Completed IS NULL 
		ORDER BY tb2.id
	)
	UPDATE q
	SET Started = GETDATE()
	
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
	SELECT @ProcessName = 'PopulateRawData', @StepName = '', @Comment = ''

	DECLARE @IdLoadLog int, @IdLoadStepLog int, @RowsAffected int
	SELECT @IdLoadLog = -1, @IdLoadStepLog = -1, @RowsAffected = -1

-- -- Log
EXEC dbo.usp_LoadLogCreate @ProcessName, @Direction, @IdLoadLog OUT

BEGIN TRY
-- -- Get the payload for this process run
SET @StepName = 'GetPayload'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	
	INSERT INTO dbo.LoadPayload
	SELECT TOP (@NumloadsToExecute) @IdLoadLog, ManualLoadNumber, @Direction, 'Valid', 'Manual by load number'
	FROM dbo.ManualTILoad WHERE Completed IS NULL ORDER BY Id
	
	SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- -- Get raw data
-- raw_bl
SET @StepName = 'GetRawData_raw_bl'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.raw_bl
	INSERT INTO dbo.raw_bl
		([BOL_ID]
		,[BL_NBR]
		,[X_SCAC]
		,[X_SCAC_NAME]
		,[VESSEL_CD]
		,[VESSEL_NAME]
		,[VESSEL_FLAG]
		,[VOYAGE_NBR]
		,[EST_ARR_DT]
		,[ACT_ARR_DT]
		,[PLACE_RECEIPT_CD]
		,[X_PLACE_RECEIPT_CD]
		,[PLACE_RECEIPT_REGION]
		,[PLACE_RECEIPT_NAME]
		,[FOREIGN_PORT]
		,[X_FP_LADING_CD]
		,[FP_LADING_REGION]
		,[FP_LADING_NAME]
		,[FP_LADING_REGION_NAME]
		,[US_PORT]
		,[X_PORT_UNLADING_CD]
		,[PORT_UNLADING_REGION]
		,[PORT_UNLADING_NAME]
		,[CLEARING_PORT_CD]
		,[X_CLEARING_PORT_CD]
		,[US_CLEARING_REGION]
		,[US_CLEARING_NAME]
		,[FP_DEST_CD]
		,[X_FP_DEST_CD]
		,[FP_DEST_CNTRY]
		,[FP_DEST_NAME]
		,[MANIFEST_QTY]
		,[X_MANIFEST_UNIT]
		,[WGT]
		,[STD_WGT]
		,[INTERP_STD_WGT_FLG]
		,[X_WGT_UNIT]
		,[MEAS]
		,[X_MEAS_UNIT]
		,[INBOND_ENTRY_TYPE]
		,[MANIFEST_NBR]
		,[TEU_CNT]
		,[TEU_SRC]
		,[LCL_FLG]
		,[CNTRIZED_SHPMT_FLG]
		,[X_TRANS_MODE_CD]
		,[TRANS_MODE_CD_DESCRIPTION]
		,[FRAME_NBR]
		,[LOAD_NBR]
		,[LOAD_SEQ_NBR]
		,[LOAD_TYPE]
		,[LAST_UPDATE_DT]
		,[DB_LOAD_NBR]
		,[HZRD_CLASS]
		,[SCAC]
		,[CONS_STATE]
		,[NOT_STATE]
		,[ANOT_STATE]
		,[DIR]
		,[BATCH_ID]
--		,[ORIG_BL_NBR]
		,[VISIBILITY])
	SELECT BOL_ID,
		BL_NBR,
		X_SCAC,
		X_SCAC_NAME,
		VESSEL_CD,
		VESSEL_NAME,
		VESSEL_FLAG,
		VOYAGE_NBR, 
		EST_ARR_DT, 
		ACT_ARR_DT, 
		PLACE_RECEIPT_CD,
		X_PLACE_RECEIPT_CD,
		PLACE_RECEIPT_REGION,
		PLACE_RECEIPT_NAME, 
		FOREIGN_PORT, 
		X_FP_LADING_CD,
		FP_LADING_REGION,
		FP_LADING_NAME, 
		FP_LADING_REGION_NAME,
		US_PORT, 
		X_PORT_UNLADING_CD,
		PORT_UNLADING_REGION,
		PORT_UNLADING_NAME, 
		CLEARING_PORT_CD, 
		X_CLEARING_PORT_CD,
		US_CLEARING_REGION,
		US_CLEARING_NAME, 
		FP_DEST_CD,
		X_FP_DEST_CD,
		FP_DEST_CNTRY,
		FP_DEST_NAME, 
		MANIFEST_QTY, 
		X_MANIFEST_UNIT,
		WGT, 
		STD_WGT,
		INTERP_STD_WGT_FLG, 
		X_WGT_UNIT,
		MEAS, 
		X_MEAS_UNIT,
		INBOND_ENTRY_TYPE,
		MANIFEST_NBR,
		TEU_CNT,
		TEU_SRC,
		LCL_FLG,
		CNTRIZED_SHPMT_FLG,
		X_TRANS_MODE_CD, 
		TRANS_MODE_CD_DESCRIPTION, 
		FRAME_NBR,
		LOAD_NBR,
		LOAD_SEQ_NBR,
		LOAD_TYPE, 
		LAST_UPDATE_DT,
		DB_LOAD_NBR,
		HZRD_CLASS,
		SCAC,
		CONS_STATE,
		NOT_STATE, 
		ANOT_STATE,
		DIR,
		BATCH_ID,
--		ORIG_BL_NBR,
		VISIBILITY 
	 FROM PES_RAW.PES.DBO.ti_raw_data_master_V	 tivbbj
	WHERE tivbbj.LOAD_NBR IN (SELECT TOP (@NumloadsToExecute) ManualLoadNumber FROM dbo.ManualTILoad WHERE Completed IS NULL ORDER BY Id)
	 AND X_SCAC NOT IN (SELECT SCAC FROM dbo.restricted_scac)
	 AND BOL_ID IN (SELECT BOL_ID FROM PESDW.dbo.PES_DW_BOL WHERE DELETED IS NULL)

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- raw_cmd
SET @StepName = 'GetRawData_raw_cmd'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.raw_cmd
	INSERT INTO dbo.raw_cmd
       ([BOL_ID]
       ,[TEXT_KEY]
       ,[BL_NBR]
       ,[CMD_SEQ_NBR]
       ,[CNTR_NBR]
       ,[CNTRY_ORIG_CD]
       ,[CNTRY_ORIG]
       ,[PIECE_CNT]
       ,[PIECE_UNIT]
       ,[DESCRIPTION]
       ,[WGT]
       ,[WGT_UNIT]
       ,[MEAS]
       ,[MEAS_UNIT]
       ,[CMD_CD]
       ,[CMD_CD_CHECK_DIGIT]
       ,[VALUE]
       ,[STD_WGT]
       ,[DEST_CITY]
       ,[DEST_STATE]
       ,[DEST_CNTRY]
       ,[ORG_CITY]
       ,[ORG_STATE]
       ,[ORG_CNTRY]
       ,[FINANCIAL_IND]
       ,[PAYMENT_IND])
	SELECT BOL_ID,
		CMD_ID AS TEXT_KEY,				-- Not available in PES RAW	
		BOL_Number AS BL_NBR,
		SequenceNo AS CMD_SEQ_NBR,
		Container_Number AS CNTR_NBR,
		NULL AS CNTRY_ORIG_CD,			-- Not available in PES RAW
		NULL AS [CNTRY_ORIG],			-- Not available in PES RAW
		CASE ISNUMERIC(PIECE_Count) WHEN 0 THEN CONVERT(NUMERIC(12,2),0) ELSE CONVERT(NUMERIC(12,2),PIECE_Count) END  AS PIECE_CNT,
		PackageUnit AS PIECE_UNIT,
		Commodity_Desc AS DESCRIPTION,
		CASE ISNUMERIC(Harm_Weight) WHEN 0 THEN CONVERT(NUMERIC(16,6),0) ELSE CONVERT(NUMERIC(16,6),HARM_WEIGHT) END  AS WGT,
		Harm_Unit AS WGT_UNIT,
		NULL AS MEAS,					-- Not available in PES RAW
		NULL AS MEAS_UNIT,				-- Not available in PES RAW
		NULL AS CMD_CD,					-- Not available in PES RAW
		NULL AS CMD_CD_CHECK_DIGIT,		-- Not available in PES RAW
		NULL AS [VALUE],				-- Not available in PES RAW
		NULL AS STD_WGT,				-- Not available in PES RAW
		NULL AS DEST_CITY,				-- Not available in PES RAW	
		NULL AS DEST_STATE,				-- Not available in PES RAW
		NULL AS DEST_CNTRY,				-- Not available in PES RAW
		NULL AS ORG_CITY,				-- Not available in PES RAW
		NULL AS ORG_STATE,				-- Not available in PES RAW
		NULL AS ORG_CNTRY,				-- Not available in PES RAW
		NULL AS FINANCIAL_IND,			-- Not available in PES RAW
		NULL AS PAYMENT_IND				-- Not available in PES RAW
	 FROM PES_RAW.PES.DBO.ARCHIVE_RAW_CMD rc
	WHERE EXISTS (SELECT 1 FROM dbo.raw_bl rbl WHERE rc.BOL_ID = rbl.BOL_ID)
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- raw_man
SET @StepName = 'GetRawData_raw_man'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.raw_man
	INSERT INTO dbo.raw_man
       ([BOL_ID]
       ,[TEXT_KEY]
       ,[BL_NBR]
       ,[MAN_SEQ_NBR]
       ,[CNTR_NBR]
       ,[MAN])
	SELECT BOL_ID,
		MAN_ID AS TEXT_KEY,			-- Not available in PES RAW
		BOL_Number AS BL_NBR,
		0 AS MAN_SEQ_NBR,			-- Not available in PES RAW
		CNTR_NBR,
		MAN_DESC AS MAN
	 FROM PES_RAW.PES.DBO.ARCHIVE_RAW_MAN rm 
	WHERE EXISTS (SELECT 1 FROM dbo.raw_bl rbl WHERE rm.BOL_ID = rbl.BOL_ID)
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- raw_pty
SET @StepName = 'GetRawData_raw_pty'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.raw_pty
	INSERT INTO dbo.raw_pty
       ([BOL_ID]
       ,[BL_NBR]
       ,[PTY_SEQ_NBR]
       ,[NAME]
       ,[ADDR_1]
       ,[ADDR_2]
       ,[ADDR_3]
       ,[ADDR_4]
       ,[UIN]
       ,[DUNS]
       ,[PUBLISH_FLG]
       ,[ORIGINAL_FLG]
       ,[SOURCE]
       ,[N_NBR]
       ,[MANUAL_NAME_EXCL_FLG]
       ,[CREATED_BY]
       ,[CREATED_DT]
       ,[MODIFIED_BY]
       ,[MODIFIED_DT])
	SELECT BOL_ID,
		BOL_Number AS BL_NBR,
		ISNULL(PTY_SEQ_NBR,0) as PTY_SEQ_NBR ,
		[NAME],
		[ADDR_1],
		[ADDR_2],
		[ADDR_3],
		[ADDR_4],
		NULL AS UIN,							-- Not available in PES RAW
		NULL AS DUNS,						-- Not available in PES RAW
		NULL AS PUBLISH_FLG,					-- Not available in PES RAW	
		NULL AS ORIGINAL_FLG,				-- Not available in PES RAW
		SOURCE,
		NULL AS N_NBR,						-- Not available in PES RAW
		NULL AS MANUAL_NAME_EXCL_FLG,		-- Not available in PES RAW
		CREATED_BY,
		CREATED_DT,
		MODIFIED_BY,
		MODIFIED_DT
	 FROM PES_RAW.PES.DBO.ARCHIVE_RAW_PTY rp 
	WHERE EXISTS (SELECT 1 FROM dbo.raw_bl rbl WHERE rp.BOL_ID = rbl.BOL_ID)
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- raw_cntry_orig
SET @StepName = 'GetRawData_cntry_orig'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.raw_cntry_orig
	INSERT INTO dbo.raw_cntry_orig
       ([BOL_ID]
-- *       ,[CNTRY_CD]
       ,[CNTRY_NAME]
-- *       ,[TRADE_REGION_CD]
       ,[TRADE_REGION_NAME])
-- *       ,[FORMATTED_NAME])
	SELECT rco.BOL_ID,
-- *		rco.CNTRY_CD,
		rco.CNTRY_LONG_NAME as CNTRY_NAME,
-- *		rco.TRADE_REGION_CD,
		rco.TRADE_REGION_NAME
-- *		rco.FORMATTED_NAME
	 FROM PES_RAW.PES.DBO.ti_country_origin_V rco
	WHERE EXISTS (SELECT 1 FROM dbo.raw_bl rbl WHERE rco.BOL_ID = rbl.BOL_ID)
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- -- Populate / Append to staging ref tables
-- port
SET @StepName = 'PopulateStgRefs_port'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- port table
	;WITH tmp_all_port As (
		SELECT	rbl.X_FP_LADING_CD As code
				,rbl.FP_LADING_NAME As name
				,NULL As state
				,NULL As country
				,rbl.FP_LADING_REGION_NAME As region
		 FROM dbo.raw_bl rbl
		UNION -- Note: UNION removes duplicates already
		SELECT	rbl.X_PORT_UNLADING_CD As code
				,rbl.PORT_UNLADING_NAME As name
				,NULL As state
				,NULL As country
				,NULL As region
		 FROM dbo.raw_bl rbl
		UNION
		SELECT	rbl.X_PLACE_RECEIPT_CD As code
				,rbl.PLACE_RECEIPT_NAME As name
				,NULL As state
				,rbl.PLACE_RECEIPT_REGION As country
				,NULL As region
		 FROM dbo.raw_bl rbl
		UNION
		SELECT	rbl.X_CLEARING_PORT_CD As code
				,rbl.US_CLEARING_NAME As name
				,NULL As state
				,NULL As country
				,NULL As region
		 FROM dbo.raw_bl rbl
		UNION
		SELECT	rbl.X_FP_DEST_CD As code
				,rbl.FP_DEST_NAME As name
				,NULL As state
				,rbl.FP_DEST_CNTRY As country
				,NULL As region
		 FROM dbo.raw_bl rbl
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

-- scac table
-- TODO - need to look at bl_bl.NVO_SCAC column... for either SCAC or SLINE
SET @StepName = 'PopulateStgRefs_scac'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	;WITH tmp_all_scac As (
		SELECT	rbl.X_SCAC As code
				,rbl.X_SCAC_NAME As name
				,NULL As addr
				,NULL As city
				,NULL As state_cd
				,NULL As zip
				,NULL As country
				,NULL As phone
		 FROM dbo.raw_bl rbl
	)
	INSERT INTO dbo.stg_scac (code,name,addr,city,state_cd,zip,country,phone)
	SELECT DISTINCT tas.code,tas.name,tas.addr,tas.city,tas.state_cd,tas.zip,tas.country,tas.phone
	FROM tmp_all_scac tas
	LEFT JOIN	dbo.stg_scac AS s ON -- only if tas.record does not exist in dbo.stg_scac already
					COALESCE(s.code,'NullValue') = COALESCE(tas.code,'NullValue')
				AND COALESCE(s.name,'NullValue') = COALESCE(tas.name,'NullValue')
				AND COALESCE(s.addr,'NullValue') = COALESCE(tas.addr,'NullValue')
				AND COALESCE(s.city,'NullValue') = COALESCE(tas.city,'NullValue')
				AND COALESCE(s.state_cd,'NullValue') = COALESCE(tas.state_cd,'NullValue')
				AND COALESCE(s.zip,'NullValue') = COALESCE(tas.zip,'NullValue')
				AND COALESCE(s.country,'NullValue') = COALESCE(tas.country,'NullValue')
				AND COALESCE(s.phone,'NullValue') = COALESCE(tas.phone,'NullValue')
	WHERE		s.id IS NULL
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- vessel table
SET @StepName = 'PopulateStgRefs_vessel'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	;WITH tmp_all_vessel As (
		SELECT	rbl.VESSEL_NAME As name
				,rbl.VESSEL_FLAG As flag
				,rbl.VESSEL_CD As imo_code
		 FROM dbo.raw_bl rbl
	)
	INSERT INTO dbo.stg_vessel (name,flag,imo_code)
	SELECT DISTINCT tav.name,tav.flag,tav.imo_code
	 FROM tmp_all_vessel tav
	LEFT JOIN	dbo.stg_vessel AS v ON -- only if tav.record does not exist in dbo.stg_vessel already
					COALESCE(v.name,'NullValue') = COALESCE(tav.name,'NullValue')
				AND COALESCE(v.flag,'NullValue') = COALESCE(tav.flag,'NullValue')
				AND COALESCE(v.imo_code,'NullValue') = COALESCE(tav.imo_code,'NullValue')
	WHERE		v.id IS NULL
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- pty table - [NOTE: party table is like a hybrid of ref and data tables]
SET @StepName = 'PopulateStgRefs_pty'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	INSERT INTO dbo.stg_pty (name,addr1,addr2,addr3,addr4,st,duns_nbr)
	SELECT DISTINCT rp.NAME As name,rp.ADDR_1 As addr1,rp.ADDR_2 As addr2,rp.ADDR_3 As addr3,rp.ADDR_4 As addr4,NULL As st,NULL As duns_nbr
	FROM dbo.raw_pty rp
	LEFT JOIN	dbo.stg_pty AS p ON -- only if rp.record does not exist in dbo.stg_pty already
					COALESCE(p.name,'NullValue') = COALESCE(rp.name,'NullValue')
				AND COALESCE(p.addr1,'NullValue') = COALESCE(rp.addr_1,'NullValue')
				AND COALESCE(p.addr2,'NullValue') = COALESCE(rp.addr_2,'NullValue')
				AND COALESCE(p.addr3,'NullValue') = COALESCE(rp.addr_3,'NullValue')
				AND COALESCE(p.addr4,'NullValue') = COALESCE(rp.addr_4,'NullValue')
				--AND p.st = rp.st
				--AND p.duns_nbr = rp.duns_nbr
	WHERE		p.id IS NULL
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- -- Populate data tables
-- stg_man
SET @StepName = 'PopulateStgData_man'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_man
	INSERT INTO dbo.stg_man (BOL_ID,man_seq_nbr,cntr_nbr,man_desc)
	SELECT m.BOL_ID,m.MAN_SEQ_NBR As man_seq_nbr,m.CNTR_NBR As cntr_nbr,m.MAN As man_desc
	FROM dbo.raw_man m
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_cmd
SET @StepName = 'PopulateStgData_cmd'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_cmd
	INSERT INTO dbo.stg_cmd (BOL_ID,cmd_seq_nbr,CMD_ID,cntr_nbr,piece_cnt,piece_unit,cmd_desc,harm_code,joc_code,teu,pounds,estimated_value)
	SELECT c.BOL_ID,c.CMD_SEQ_NBR As cmd_seq_nbr,NULL As CMD_ID,c.CNTR_NBR As cntr_nbr,c.PIECE_CNT As piece_cnt,c.PIECE_UNIT As piece_unit,c.DESCRIPTION As cmd_desc,NULL As harm_code,NULL As joc_code,NULL As teu,NULL As pounds,NULL As estimated_value
	FROM dbo.raw_cmd c
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_bl
-- Populate non-id(ed) columns
SET @StepName = 'PopulateStgData_bl'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_bl
	;WITH tmp_cd_cntry_orig As (
		-- NOTE: This is required becaused CD_CNTRY_ORIG view returns duplicate T_NBRs
		--			when all CMD_SEQ_NBRs of a BOL_ID do not have the same Country of Origin
		SELECT 
			 ROW_NUMBER() OVER (PARTITION BY BOL_ID ORDER BY CNTRY_NAME) As Rank
			,BOL_ID,CNTRY_NAME,TRADE_REGION_NAME
		FROM dbo.raw_cntry_orig cco
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
		,load_type
		,load_seq_nbr
		,db_load_nbr
		,frame_nbr
--		,load_source
--		,load_indicator
		,IdLoadLog
	)
	SELECT
		 rbl.BOL_ID
		,rbl.BL_NBR As bl_nbr
		,rbl.dir
--		,getdate() As pdate
--		,0 As ucount
--		,getdate() As udate
		,tcco.TRADE_REGION_NAME As origin_region
		,tcco.CNTRY_NAME As origin_country
		,rbl.EST_ARR_DT As vdate
		,rbl.MANIFEST_NBR As manifest_nbr
		,rbl.VOYAGE_NBR As voyage_nbr
		,rbl.CNTRIZED_SHPMT_FLG As conflag
		,rbl.STD_WGT As std_weight
		,rbl.MEAS As measure_value
		,rbl.X_MEAS_UNIT As measure_unit
		,rbl.MANIFEST_QTY As manifest_qty
		,rbl.X_MANIFEST_UNIT As manifest_unit
		,rbl.TEU_CNT As teu_cnt
		,rbl.TEU_SRC As teu_src
		,rbl.INBOND_ENTRY_TYPE As inbond_entry_type
		,rbl.X_TRANS_MODE_CD As trans_mode_description
		,NULL As estimated_value
		-- hazard_class
		--
		--rbl.HZRD_CLASS has values like...
		--9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9
		--2.1  2.1  2.1  2.1  2.1  2.1  3    2.1  2.1  2.1  3
		--6.1  6.1  6.1  6.1  6.1  6.1  6.1  6.1  6.1  6.1  6.1  6.1
		--
		--We take first 5 chars, ignore the rest...
		,LEFT(rbl.HZRD_CLASS,5) As hazard_class
		,NULL As nvocc_flag
		,NULL As country_code
		,NULL As us_coast
		,rbl.CONS_STATE As cons_state
		,rbl.NOT_STATE As not_state
		,rbl.ANOT_STATE As anot_state
		,rbl.VISIBILITY As visibility
		,rbl.BATCH_ID As batch_id
--		,rbl.ORIG_BL_NBR As orig_bl_nbr
--		,NULL As action
		,rbl.LOAD_NBR As load_nbr
		,rbl.LOAD_TYPE As load_type
		,rbl.LOAD_SEQ_NBR As load_seq_nbr
		,rbl.DB_LOAD_NBR As db_load_nbr
		,rbl.FRAME_NBR As frame_nbr
--		,'dqa' As load_source
--		,'insert' As load_indicator
		,@IdLoadLog As IdLoadLog
	 FROM dbo.raw_bl rbl
	LEFT OUTER JOIN tmp_cd_cntry_orig tcco ON tcco.BOL_ID = rbl.BOL_ID AND tcco.Rank = 1
	ORDER BY rbl.BOL_ID
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

-- stg_bl_ids
-- Populate id(ed) columns
--Changes by Cognizant, Start
--Rewrite the query to ensure the uniqueness of Bill Ids in the resultset
SET @StepName = 'PopulateStgData_bl_ids'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE dbo.stg_bl_ids

--Changes by Cognizant, 10-March-2010 to tune Step Performance, START

	CREATE TABLE #temp_pty (
		BOL_ID		int
		,SOURCE		char(1)
		,PTY_SEQ_NBR int
		,ID			int
		--,UNIQUE (BOL_ID, SOURCE, PTY_SEQ_NBR, ID)
		-- error: Cannot insert duplicate key in object 'dbo.#temp_pty'
		-- added a PK to make it unique so that we can add index for performance
		,pk_id		int IDENTITY(1,1)
		,UNIQUE (BOL_ID, SOURCE, PTY_SEQ_NBR, ID, pk_id) -- added for performance on temp table
	)

	INSERT INTO #temp_pty (BOL_ID, SOURCE, PTY_SEQ_NBR, ID)
	SELECT BOL_ID, SOURCE, PTY_SEQ_NBR, ID
	FROM dbo.PartyInfo_V

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
		 rbl.BOL_ID,
		 NULL As id_carrier_sline,
		 scac.id AS id_carrier_scac,
		 port_foreign.id As id_port_foreign,
		 port_unlading.id As id_port_unlading,
		 port_foreign_dest.id As id_port_foreign_dest,
		 port_receipt.id As id_port_receipt,
		 port_us_clearing.id As id_port_us_clearing,
		--Cognizant Changes for Defect #2787, 20-Jan-2010, start
		CASE rbl.dir WHEN 'I' THEN 
		( SELECT TOP 1 ID FROM #temp_pty tp (NOLOCK)
			WHERE rbl.BOL_ID = tp.BOL_ID AND tp.SOURCE='S' ) 
		ELSE
		( SELECT TOP 1 ID FROM #temp_pty tp (NOLOCK)
			WHERE rbl.BOL_ID = tp.BOL_ID AND tp.SOURCE='C' )
		END AS id_pty_shipper,
		CASE rbl.dir WHEN 'I' THEN 
		( SELECT TOP 1 ID FROM #temp_pty tp (NOLOCK)
			WHERE rbl.BOL_ID = tp.BOL_ID AND tp.SOURCE='C' ) 
		ELSE
		( SELECT TOP 1 ID FROM #temp_pty tp (NOLOCK)
			WHERE rbl.BOL_ID = tp.BOL_ID AND tp.SOURCE='S' ) 
		END AS id_pty_consignee,		
		/* ( SELECT TOP 1  ID FROM DBO.[PartyInfo_V] V (NOLOCK)
			WHERE rbl.BOL_ID = V.BOL_ID AND V.SOURCE='S'			
		) AS id_pty_shipper,
		( SELECT TOP 1  ID FROM DBO.[PartyInfo_V] V (NOLOCK)
			WHERE rbl.BOL_ID = V.BOL_ID AND V.SOURCE='C'			
		) AS id_pty_consignee, */
		--Cognizant Changes for Defect #2787, 20-Jan-2010,  end
		( SELECT TOP 1 ID FROM #temp_pty tp (NOLOCK)
			WHERE rbl.BOL_ID = tp.BOL_ID AND tp.SOURCE='N' AND tp.PTY_SEQ_NBR = 3			
		) AS id_pty_notify,
		( SELECT TOP 1 ID FROM #temp_pty tp (NOLOCK)
			WHERE rbl.BOL_ID = tp.BOL_ID AND tp.SOURCE='A' AND tp.PTY_SEQ_NBR = 4			
		) AS id_pty_notify_also,
		vessel.id AS id_vessel
	 FROM dbo.raw_bl rbl (NOLOCK)
	JOIN dbo.stg_scac scac (NOLOCK)
	 ON COALESCE(rbl.X_SCAC,'NullValue') = COALESCE(scac.code,'NullValue')
		AND COALESCE(rbl.X_SCAC_NAME,'NullValue') = COALESCE(scac.name,'NullValue')
	JOIN dbo.stg_port port_foreign (NOLOCK)
	 ON COALESCE(rbl.X_FP_LADING_CD,'NullValue') = COALESCE(port_foreign.code,'NullValue')
		AND COALESCE(rbl.FP_LADING_NAME,'NullValue') = COALESCE(port_foreign.name,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign.state,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign.country,'NullValue')
		AND COALESCE(rbl.FP_LADING_REGION_NAME,'NullValue') = COALESCE(port_foreign.region,'NullValue')
	JOIN dbo.stg_port port_unlading (NOLOCK)
	 ON COALESCE(rbl.X_PORT_UNLADING_CD,'NullValue') = COALESCE(port_unlading.code,'NullValue')
		AND COALESCE(rbl.PORT_UNLADING_NAME,'NullValue') = COALESCE(port_unlading.name,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_unlading.state,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_unlading.country,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_unlading.region,'NullValue')
	JOIN dbo.stg_port port_foreign_dest (NOLOCK)
	 ON COALESCE(rbl.X_FP_DEST_CD,'NullValue') = COALESCE(port_foreign_dest.code,'NullValue')
		AND COALESCE(rbl.FP_DEST_NAME,'NullValue') = COALESCE(port_foreign_dest.name,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign_dest.state,'NullValue')
		AND COALESCE(rbl.FP_DEST_CNTRY,'NullValue') = COALESCE(port_foreign_dest.country,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_foreign_dest.region,'NullValue')
	JOIN dbo.stg_port port_receipt (NOLOCK)
	 ON COALESCE(rbl.X_PLACE_RECEIPT_CD,'NullValue') = COALESCE(port_receipt.code,'NullValue')
		AND COALESCE(rbl.PLACE_RECEIPT_NAME,'NullValue') = COALESCE(port_receipt.name,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_receipt.state,'NullValue')
		AND COALESCE(rbl.PLACE_RECEIPT_REGION,'NullValue') = COALESCE(port_receipt.country,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_receipt.region,'NullValue')
	JOIN dbo.stg_port port_us_clearing (NOLOCK)
	 ON COALESCE(rbl.X_CLEARING_PORT_CD,'NullValue') = COALESCE(port_us_clearing.code,'NullValue')
		AND COALESCE(rbl.US_CLEARING_NAME,'NullValue') = COALESCE(port_us_clearing.name,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_us_clearing.state,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_us_clearing.country,'NullValue')
		AND COALESCE(NULL,'NullValue') = COALESCE(port_us_clearing.region,'NullValue')
	JOIN dbo.stg_vessel vessel (NOLOCK)
	 ON COALESCE(rbl.VESSEL_NAME,'NullValue') = COALESCE(vessel.name,'NullValue')
		AND COALESCE(rbl.VESSEL_FLAG,'NullValue') = COALESCE(vessel.flag,'NullValue')
		AND COALESCE(rbl.VESSEL_CD,'NullValue') = COALESCE(vessel.imo_code,'NullValue')
	ORDER BY rbl.BOL_ID
--Changes by Cognizant, 10-March-2010 to tune Step Performance, START

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

DROP TABLE #temp_pty

--Changes by Cognizant, End

-- Populate stgload table
SET @StepName = 'Populate_stgload_raw'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Truncate any previous stgload data
	TRUNCATE TABLE dbo.stgload_raw

	-- Populate new stgload data
	INSERT INTO dbo.stgload_raw
	 SELECT * FROM dbo.stgload_raw_V
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	-- Apply fixes to various columns
	IF @Direction = 'I'
	BEGIN
SET @StepName = 'FixStgload_foreign_port_I'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE dbo.stgload_raw SET
		FOREIGN_PORT_NAME =
			CASE
				WHEN FOREIGN_PORT_NAME LIKE '%,%' THEN
					-- Anything before 1st ,
					LTRIM(RTRIM(LEFT(FOREIGN_PORT_NAME,CHARINDEX(',',FOREIGN_PORT_NAME,0)-1)))
				ELSE
					--Changes by Cognizant, 22-Jan-2010, start
					--Fix for Defect #2800 (Blank Port of Departure fields in Import Bills in TI3)
					FOREIGN_PORT_NAME
					--NULL -- TODO - maybe this should be FOREIGN_PORT_NAME instead of null? but then it might return values like 'HIGH SEAS (UNDE)'
					--Changes by Cognizant, 22-Jan-2010, end
			END
		,FOREIGN_PORT_CNTRY =
			CASE
				WHEN FOREIGN_PORT_NAME LIKE '%,%(%' THEN
					-- Anything after last , and before last (
					LTRIM(RTRIM(SUBSTRING(FOREIGN_PORT_NAME
										, dbo.ufn_ReversePATINDEX('%,%',FOREIGN_PORT_NAME)+2
										, dbo.ufn_ReversePATINDEX('%(%',FOREIGN_PORT_NAME)-dbo.ufn_ReversePATINDEX('%,%',FOREIGN_PORT_NAME)-2)))
				WHEN FOREIGN_PORT_NAME LIKE '%(%' THEN
					-- Anything before last (
					LTRIM(RTRIM(LEFT(FOREIGN_PORT_NAME,dbo.ufn_ReversePATINDEX('%(%',FOREIGN_PORT_NAME))))
				ELSE
					--Changes by Cognizant, 22-Jan-2010, start
					--Fix for Defect #2800 (Blank Port of Departure fields in Import Bills in TI3)
					FOREIGN_PORT_CNTRY
					--NULL
					--Changes by Cognizant, 22-Jan-2010, end
			END
		,FOREIGN_PORT_REGION = 
			LTRIM(RTRIM(REPLACE(REPLACE(FOREIGN_PORT_REGION,'(',''),')','')))
		WHERE DIR='I'
		 AND COALESCE(FOREIGN_PORT_NAME,'') != ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_us_clearing_port_I'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.PORT_US_CLEARING_NAME = pd.NAME
		,sl.PORT_US_CLEARING_ST = pd.STATE_CD
		,sl.PORT_US_CLEARING_DIST = udd.NAME
		FROM dbo.stgload_raw sl
		JOIN dbo.raw_bl rbl
		 ON rbl.BOL_ID = sl.BOL_ID
		JOIN dbo.tiref_port_dim pd
		 ON pd.PORT_KEY = rbl.X_CLEARING_PORT_CD--'sl.portKey'--clearing_port_cd
		JOIN dbo.tiref_uscs_district_dim udd
		 ON pd.DISTRICT_CD = udd.DISTRICT_CD
		WHERE sl.DIR='I'
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_unlading_port_I'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.PORT_UNLADING_NAME = pd.NAME
		,sl.PORT_UNLADING_STATE = pd.STATE_CD
		FROM dbo.stgload_raw sl
		JOIN dbo.raw_bl rbl
		 ON rbl.BOL_ID = sl.BOL_ID
		JOIN dbo.tiref_port_dim pd
		 ON pd.PORT_KEY = rbl.X_PORT_UNLADING_CD--'sl.unladingKey'--port_unlading_cd
		WHERE sl.DIR='I'
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_scac_I'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.scac_carrier_name = sd.CARRIER_NAME
		,sl.scac_addr = sd.ADDR
		,sl.scac_city = sd.CITY
		,sl.scac_state_cd = sd.STATE_CD
		,sl.scac_zip_cd = sd.ZIP_CD
		,sl.scac_cntry = sd.CNTRY
		,sl.scac_phone = sd.PHONE
		FROM dbo.stgload_raw sl
		JOIN dbo.raw_bl rbl
		 ON rbl.BOL_ID = sl.BOL_ID
		JOIN dbo.tiref_scac_dim sd
		 ON sd.SCAC_KEY = rbl.X_SCAC--'sl.scacKey'--x_scac
		WHERE sl.DIR='I'
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_cntry_orig_I'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.COUNTRY_ORIGIN = pc.DESCR -- TODO - is pc.NAME in loadjava (Loader.java - Ln 993), but no such column!
		--,sl.REGION_ORIGIN = '' -- TODO - can/should we set this too?
		FROM dbo.stgload_raw sl
		JOIN dbo.raw_bl rbl
		 ON rbl.BOL_ID = sl.BOL_ID
		JOIN dbo.tiref_piers_country pc
		 ON pc.CODE = SUBSTRING(rbl.X_FP_LADING_CD,1,3)--'sl.fp_lading_cd.SUBSTRING(0, 3)'--X_FP_LADING_CD
			AND ISNUMERIC(SUBSTRING(rbl.X_FP_LADING_CD,1,3))=1
		WHERE sl.DIR='I'
		 AND COALESCE(sl.COUNTRY_ORIGIN,'') = ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment
	END
	ELSE IF @Direction = 'E'
	BEGIN
SET @StepName = 'FixStgload_foreign_port_E'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.FOREIGN_PORT_NAME = fpd.NAME
		,sl.FOREIGN_PORT_CNTRY = cd.NAME
		,sl.COUNTRY_ORIGIN = cd.NAME
		--,sl.REGION_ORIGIN = '' -- TODO - can/should we set this too?
		,sl.FPORT_CODE = fpd.FP_KEY
		,sl.FOREIGN_PORT_REGION = 
			LTRIM(RTRIM(REPLACE(REPLACE(FOREIGN_PORT_REGION,'(',''),')','')))
		FROM dbo.stgload_raw sl
		JOIN dbo.tiref_foreign_port_dim fpd
		 ON (IsNumeric(sl.FOREIGN_PORT_NAME) = 1
				 AND LTRIM(RTRIM(fpd.FP_KEY)) = LTRIM(RTRIM(sl.FOREIGN_PORT_NAME)))
		 OR (IsNumeric(sl.FOREIGN_PORT_NAME) = 0
				 AND LTRIM(RTRIM(fpd.NAME)) = 
					CASE WHEN sl.FOREIGN_PORT_NAME LIKE '%,%' 
						 THEN LTRIM(RTRIM(LEFT(sl.FOREIGN_PORT_NAME,CHARINDEX(',',sl.FOREIGN_PORT_NAME,0)-1)))
						 ELSE LTRIM(RTRIM(sl.FOREIGN_PORT_NAME))
					END)
		JOIN dbo.tiref_country_dim cd ON cd.USCS_CNTRY_CD = fpd.COUNTRY_KEY
		WHERE sl.DIR='E'
		 AND COALESCE(sl.FOREIGN_PORT_NAME,'') != ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_us_clearing_unlading_port_E'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.PORT_RECEIPT_NAME = pd.NAME
		--,sl.PORT_RECEIPT_CNTRY = '' -- TODO - can/should we set this too?
		,sl.PORT_US_CLEARING_NAME = pd.NAME
		,sl.PORT_US_CLEARING_ST = pd.STATE_CD
		,sl.PORT_US_CLEARING_DIST = udd.NAME
		,sl.PORT_UNLADING_NAME = pd.NAME
		,sl.PORT_UNLADING_STATE = pd.STATE_CD
		,sl.USPORT_CODE = pd.PORT_KEY
		,sl.US_COAST = cs.COAST
		FROM dbo.stgload_raw sl
		JOIN dbo.raw_bl rbl
		 ON rbl.BOL_ID = sl.BOL_ID
		JOIN dbo.tiref_port_dim pd
		 ON (IsNumeric(rbl.PLACE_RECEIPT_NAME) = 1
				 AND LTRIM(RTRIM(pd.PORT_KEY)) = LTRIM(RTRIM(rbl.PLACE_RECEIPT_NAME)))
		 OR (IsNumeric(rbl.PLACE_RECEIPT_NAME) = 0
				 AND LTRIM(RTRIM(pd.NAME)) = LTRIM(RTRIM(rbl.PLACE_RECEIPT_NAME)))
		JOIN dbo.tiref_uscs_district_dim udd
		 ON pd.DISTRICT_CD = udd.DISTRICT_CD
		LEFT OUTER JOIN dbo.tiref_coast_swap cs
		 ON cs.PORT_CD = pd.PORT_KEY
		WHERE sl.DIR='E'
		 AND COALESCE(rbl.PLACE_RECEIPT_NAME,'') != ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_scac_E'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.scac_carrier_name = sd.CARRIER_NAME
		,sl.scac_addr = sd.ADDR
		,sl.scac_city = sd.CITY
		,sl.scac_state_cd = sd.STATE_CD
		,sl.scac_zip_cd = sd.ZIP_CD
		,sl.scac_cntry = sd.CNTRY
		,sl.scac_phone = sd.PHONE
		FROM dbo.stgload_raw sl
		JOIN dbo.raw_bl rbl
		 ON rbl.BOL_ID = sl.BOL_ID
		JOIN dbo.tiref_scac_dim sd
		 ON sd.SCAC_KEY = rbl.X_SCAC--'sl.scacKey'--x_scac
		WHERE sl.DIR='E'
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_cntry_orig_E1'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.COUNTRY_ORIGIN = pc.DESCR
		--,sl.REGION_ORIGIN = '' -- TODO - can/should we set this too?
		FROM dbo.stgload_raw sl
		JOIN dbo.tiref_ppmm_ports_view pp
		 ON LTRIM(RTRIM(pp.port_name)) = LTRIM(RTRIM(sl.FOREIGN_PORT_NAME))
		JOIN dbo.tiref_piers_country pc
		 ON pc.CODE = SUBSTRING(pp.JOC_CODE,1,3)
		WHERE sl.DIR='E'
		 AND COALESCE(sl.COUNTRY_ORIGIN,'') = ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

		-- TODO - if COUNTRY_ORIGIN is not resolved in above operation, need to do the below
		/*
SET @StepName = 'FixStgload_country_origin_E2'
		-- if still blank
		String[] tokens = sl.FOREIGN_PORT_NAME.split(" ");
		String fport = null;
		if (tokens.length == 3) {
			fport = tokens[0] + " " + tokens[1];
		} else {
			fport = tokens[0];
		}
		SELECT b.descr
		 FROM ppmm_ports a , piers_country b 
		WHERE b.code=substr(a.joc_code,1,3) AND a.port_name = fport
		sl.COUNTRY_ORIGIN = b.descr
		*/

SET @StepName = 'FixStgload_cntry_orig_E2'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.COUNTRY_ORIGIN = 'N/A'
		--,sl.REGION_ORIGIN = '' -- TODO - can/should we set this too?
		FROM dbo.stgload_raw sl
		WHERE sl.DIR='E'
		 AND COALESCE(sl.COUNTRY_ORIGIN,'') = ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment
	END

	-- Adjust COUNTRY_ORIGIN/REGION_ORIGIN as per Rawfile.java/Loader.java
SET @StepName = 'FixStgload_cntry_orig'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.COUNTRY_ORIGIN = 
			CASE WHEN LTRIM(RTRIM(sl.COUNTRY_ORIGIN)) = 'CHINA' THEN 'PEOPLES REP OF CHINA'
				 WHEN LTRIM(RTRIM(sl.COUNTRY_ORIGIN)) = 'KOREA' THEN 'REPUBLIC OF KOREA'
				 ELSE LTRIM(RTRIM(sl.COUNTRY_ORIGIN))
			END
		FROM dbo.stgload_raw sl
		WHERE LTRIM(RTRIM(sl.COUNTRY_ORIGIN)) IN ('CHINA','KOREA')
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'FixStgload_region_origin'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
		UPDATE sl SET
		 sl.REGION_ORIGIN = 
			CASE WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'ASIA' THEN 'Asia'
				 WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'EURO' THEN 'Europe'
				 WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'AFRI' THEN 'Africa'
				 WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'AUST' THEN 'Australia/New Zealand'
				 WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'SAMR' THEN 'South America'
				 WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'MIDE' THEN 'Middle East'
				 WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'CARI' THEN 'Caribbean'
				 -- TODO - below 2 values are not accounted for in current code, maybe we should fix this?
				 --WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'CANA' THEN ''
				 --WHEN LTRIM(RTRIM(sl.FOREIGN_PORT_REGION)) = 'UNDE' THEN ''
				 ELSE LTRIM(RTRIM(sl.FOREIGN_PORT_REGION))
			END
		-- TODO - FOREIGN_PORT_REGION is not fixed in current code, even though we use it to fixe REGION_ORIGIN, maybe we should fix this?
		--,sl.FOREIGN_PORT_REGION = Repeat the above CASE WHEN here too?
		FROM dbo.stgload_raw sl
		WHERE COALESCE(sl.FOREIGN_PORT_REGION,'') != ''
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	IF @Direction = 'I'
	BEGIN
		SET @StepName = 'Company_Exception_I'
		EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
			EXEC dbo.usp_ProcessRestrictedCompanies1 @Direction
			EXEC dbo.usp_ProcessRestrictedCompanies2_I @Direction
		SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
		EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment
	END
	ELSE -- @Direction = 'E'
	BEGIN
		SET @StepName = 'Company_Exception_E'
		EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
			EXEC dbo.usp_ProcessRestrictedCompanies1 @Direction
			EXEC dbo.usp_ProcessRestrictedCompanies2_E @Direction
		SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
		EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment
	END

SET @StepName = 'Archive_stgload'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Archive stgload data
	INSERT INTO dbo.stgload_archive
	SELECT *,@IdLoadLog As IdLoadLog,getdate() As archive_date
	 FROM dbo.stgload_raw
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'Sync_stgload_TI_MasterData'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Delete records from stgload_raw that are already in TI_MasterData
	-- NOTE: This means we are picking up records from PES raw that have
	--  already been processed from PES raw in the past. This should NOT happen.

	-- Populate dbo.stgload_raw_deletes table for analysis
	--TRUNCATE TABLE dbo.stgload_raw_deletes

	IF @Direction = 'I'
	BEGIN
		INSERT INTO dbo.stgload_raw_deletes
		SELECT *,@IdLoadLog As IdLoadLog
		 FROM dbo.stgload_raw
		WHERE BOL_ID IN (SELECT BOL_ID FROM dbo.TI_Import_MasterData)

		DELETE
		 FROM dbo.stgload_raw
		WHERE BOL_ID IN (SELECT BOL_ID FROM dbo.TI_Import_MasterData)
	END
	ELSE --  @Direction = 'E'
	BEGIN
		INSERT INTO dbo.stgload_raw_deletes
		SELECT *,@IdLoadLog As IdLoadLog
		 FROM dbo.stgload_raw
		WHERE BOL_ID IN (SELECT BOL_ID FROM dbo.TI_Export_MasterData)

		DELETE
		 FROM dbo.stgload_raw
		WHERE BOL_ID IN (SELECT BOL_ID FROM dbo.TI_Export_MasterData)
	END
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	-- IF @RowsAffected > 0, means we are picking up records from PES raw that have
	-- already been processed from PES raw in the past. This should NOT happen
	IF @RowsAffected > 0
	BEGIN
		SET @NumberOfWarningsRaised = @NumberOfWarningsRaised + 1
		SET @Comment = 'Warning - ' + LTRIM(RTRIM(STR(@RowsAffected)))
		 + ' records were removed from stgload_raw as they are already in Master table!'
		EXEC dbo.usp_LoadLogUpdate @IdLoadLog, 'SuccessfulWithWarnings', @Comment
	END

SET @StepName = 'Populate_TI_MasterData'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Insert records into TI_MasterData

	IF @Direction = 'I'
		INSERT INTO dbo.TI_Import_MasterData
		SELECT
			 BL_NBR
			,BOL_ID
			--,TABLE_NAME
			--,PUBLISH_DATE
			--,REVISED_CNT
			--,REVISED_DATE
			,FOREIGN_PORT_NAME
			,FOREIGN_PORT_CNTRY
			,PORT_UNLADING_NAME
			,PORT_UNLADING_STATE
			,PORT_US_CLEARING_NAME
			,PORT_US_CLEARING_ST
			,PORT_US_CLEARING_DIST
			,FP_DEST_NAME
			,FP_DEST_CNTRY
			,PORT_RECEIPT_NAME
			,PORT_RECEIPT_CNTRY
			,SCAC_CARRIER_NAME
			,SCAC_ADDR
			,SCAC_CITY
			,SCAC_STATE_CD
			,SCAC_ZIP_CD
			,SCAC_CNTRY
			,SCAC_PHONE
			,REGION_ORIGIN
			,COUNTRY_ORIGIN
			,ARRIVAL_DATE
			,ARRIVAL_WEEK
			,NULL As PRODUCT_DESC
			,SHIPPER_DESC
			,CONSGN_DESC
			,NOTIFY_DESC
			,ALSO_NOTIFY_DESC
			,SHIPPER_DUNS
			,CONSGN_DUNS
			,NOTIFY_DUNS
			,ALSO_NOTIFY_DUNS
			,MANIFEST_NBR
			,VESSEL_NAME
			,VESSEL_FLAG
			,VOYAGE_NBR
			,BL_CNTR_FLG
			,STD_WGT
			,MEAS
			,MEAS_UNIT
			,MANIFEST_QTY
			,MANIFEST_UNIT
			,TEU_CNT
			,TEU_SRC
			,HS_CODES
			,INBOND_ENTRY_TYPE
			,TRANS_MODE_DESCRIPTION
			,LOAD_TYPE
			,LOAD_NBR
			,LOAD_SEQ_NBR
			,DB_LOAD_NBR
			,FRAME_NBR
			,FOREIGN_PORT_REGION
			,SLINE
			,EST_VALUE
			,LLOYDS_CODE
			,HZRD_CLASS
			,NVOCC_FLAG
			,CTRYCODE
			,SCAC
			,US_COAST
			,USPORT_CODE
			,FPORT_CODE
			,JOC_CODES
			,CONS_STATE
			,NOT_STATE
			,ANOT_STATE
			,VISIBILITY
			,DIR
			,BATCH_ID
			,NULL As ORIG_BL_NBR
			--,ACTION
			,getdate() As MODIFY_DATE
			,PRODUCT_DESC As PRODUCT_DESC_RAW
			,NULL As PRODUCT_DESC_PROCESSED
		 FROM dbo.stgload_raw sr
	ELSE -- @Direction = 'E'
		INSERT INTO dbo.TI_Export_MasterData
		SELECT
			 BL_NBR
			,BOL_ID
			--,TABLE_NAME
			--,PUBLISH_DATE
			--,REVISED_CNT
			--,REVISED_DATE
			,FOREIGN_PORT_NAME
			,FOREIGN_PORT_CNTRY
			,PORT_UNLADING_NAME
			,PORT_UNLADING_STATE
			,PORT_US_CLEARING_NAME
			,PORT_US_CLEARING_ST
			,PORT_US_CLEARING_DIST
			,FP_DEST_NAME
			,FP_DEST_CNTRY
			,PORT_RECEIPT_NAME
			,PORT_RECEIPT_CNTRY
			,SCAC_CARRIER_NAME
			,SCAC_ADDR
			,SCAC_CITY
			,SCAC_STATE_CD
			,SCAC_ZIP_CD
			,SCAC_CNTRY
			,SCAC_PHONE
			,REGION_ORIGIN
			,COUNTRY_ORIGIN
			,ARRIVAL_DATE
			,ARRIVAL_WEEK
			,NULL As PRODUCT_DESC
			,SHIPPER_DESC
			,CONSGN_DESC
			,NOTIFY_DESC
			,ALSO_NOTIFY_DESC
			,SHIPPER_DUNS
			,CONSGN_DUNS
			,NOTIFY_DUNS
			,ALSO_NOTIFY_DUNS
			,MANIFEST_NBR
			,VESSEL_NAME
			,VESSEL_FLAG
			,VOYAGE_NBR
			,BL_CNTR_FLG
			,STD_WGT
			,MEAS
			,MEAS_UNIT
			,MANIFEST_QTY
			,MANIFEST_UNIT
			,TEU_CNT
			,TEU_SRC
			,HS_CODES
			,INBOND_ENTRY_TYPE
			,TRANS_MODE_DESCRIPTION
			,LOAD_TYPE
			,LOAD_NBR
			,LOAD_SEQ_NBR
			,DB_LOAD_NBR
			,FRAME_NBR
			,FOREIGN_PORT_REGION
			,SLINE
			,EST_VALUE
			,LLOYDS_CODE
			,HZRD_CLASS
			,NVOCC_FLAG
			,CTRYCODE
			,SCAC
			,US_COAST
			,USPORT_CODE
			,FPORT_CODE
			,JOC_CODES
			,CONS_STATE
			,NOT_STATE
			,ANOT_STATE
			,VISIBILITY
			,DIR
			,BATCH_ID
			,NULL As ORIG_BL_NBR
			--,ACTION
			,getdate() As MODIFY_DATE
			,PRODUCT_DESC As PRODUCT_DESC_RAW
			,NULL As PRODUCT_DESC_PROCESSED
		 FROM dbo.stgload_raw sr

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GenerateLoadReport'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	-- Pass in the load id and current process name
	EXEC dbo.usp_PopulateLoadStats
	 @IdLoadLog, @ProcessName
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done' -- TODO - not sure if stored proc call is going to set @@ROWCOUNT
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

	-- Mark as success
	IF @NumberOfWarningsRaised > 1
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
