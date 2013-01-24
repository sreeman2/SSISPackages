/****** Object:  StoredProcedure [dbo].[z_usp_PopulateTIRefData]    Script Date: 01/09/2013 18:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[z_usp_PopulateTIRefData] 
AS
BEGIN

SELECT * INTO dbo.tiref_coast_swap FROM PiersTI.TI_DWH.coast_swap 
SELECT * INTO dbo.tiref_country_dim FROM PiersTI.TI_DWH.country_dim 
SELECT * INTO dbo.tiref_foreign_port_dim FROM PiersTI.TI_DWH.foreign_port_dim 
SELECT * INTO dbo.tiref_piers_country FROM PiersTI.TI_DWH.piers_country 
SELECT * INTO dbo.tiref_port_dim FROM PiersTI.TI_DWH.port_dim 
SELECT * INTO dbo.tiref_ppmm_ports FROM PiersTI.TI_DWH.ppmm_ports 
SELECT * INTO dbo.tiref_scac_dim FROM PiersTI.TI_DWH.scac_dim 
SELECT * INTO dbo.tiref_uscs_district_dim FROM PiersTI.TI_DWH.uscs_district_dim 
SELECT * INTO dbo.z_tiref_region_swap FROM PiersTI.TI_DWH.region_swap 
--
--(6000 row(s) affected)
--(242 row(s) affected)
--(1734 row(s) affected)
--(186 row(s) affected)
--(493 row(s) affected)
--(28961 row(s) affected)
--(99427 row(s) affected)
--(44 row(s) affected)
--(985 row(s) affected)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProcessStatus varchar(50)
	SET @ProcessStatus = ''
	DECLARE @NumberOfWarningsRaised INT
	SET @NumberOfWarningsRaised = 0

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
	SELECT @ProcessName = 'PopulateTIRefData', @StepName = '', @Comment = ''

	DECLARE @IdLoadLog int, @IdLoadStepLog int, @RowsAffected int
	SELECT @IdLoadLog = -1, @IdLoadStepLog = -1, @RowsAffected = -1

-- -- Log
EXEC dbo.usp_LoadLogCreate @ProcessName, 'B' /*@Direction*/, @IdLoadLog OUT

BEGIN TRY

-- -- Get TI Ref tables
SET @StepName = 'GetTIRefs_PORT_DIM'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT	
	TRUNCATE TABLE ti_prod.port_dim
	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[port_dim]
           ([PORT_KEY]
           ,[DISTRICT_CD]
           ,[NAME]
           ,[EI_FLG]
           ,[PORT_CD_ALIAS]
           ,[STATE_CD]
           ,[INSERT_DT]
           ,[SOURCE]
           ,[APPROVED_DT]
           ,[UPDATE_DT]
           ,[REVISED_DT]
           ,[US_COAST])
	SELECT [PORT_KEY]
      ,[DISTRICT_CD]
      ,[NAME]
      ,[EI_FLG]
      ,[PORT_CD_ALIAS]
      ,[STATE_CD]
      ,[INSERT_DT]
      ,[SOURCE]
      ,[APPROVED_DT]
      ,[UPDATE_DT]
      ,[REVISED_DT]
      ,[US_COAST]
	FROM TI_IMP.PIERSTI.TI_DWH.PORT_DIM
    
	--INSERT INTO ti_prod.port_dim
	--SELECT * FROM TI_IMP.PIERSTI.TI_DWH.PORT_DIM
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_USCS_DISTRICT_DIM'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.uscs_district_dim
	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[uscs_district_dim]
           ([DISTRICT_CD]
           ,[NAME_ABBR]
           ,[EI_FLG]
           ,[NAME]
           ,[DISTRICT_CD_ALIAS]
           ,[SOURCE])
	SELECT [DISTRICT_CD]
      ,[NAME_ABBR]
      ,[EI_FLG]
      ,[NAME]
      ,[DISTRICT_CD_ALIAS]
      ,[SOURCE]
	FROM TI_IMP.PIERSTI.TI_DWH.USCS_DISTRICT_DIM

	--INSERT INTO ti_prod.uscs_district_dim
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.USCS_DISTRICT_DIM
	--Changes by Cognizant, 25-Nov-2009, end

SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_SCAC_DIM'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.scac_dim
	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[scac_dim]
           ([SCAC_KEY]
           ,[MC_NBR]
           ,[CARRIER_NAME]
           ,[ADDR]
           ,[CITY]
           ,[STATE_CD]
           ,[ZIP_CD]
           ,[CNTRY]
           ,[PHONE]
           ,[SCAC_ALIAS]
           ,[LAST_UPDATE_DT]
           ,[INSERT_DT]
           ,[SOURCE]
           ,[APPROVED_DT]
           ,[UPDATE_DT]
           ,[REVISED_DT])
	SELECT [SCAC_KEY]
		  ,[MC_NBR]
		  ,[CARRIER_NAME]
		  ,[ADDR]
		  ,[CITY]
		  ,[STATE_CD]
		  ,[ZIP_CD]
		  ,[CNTRY]
		  ,[PHONE]
		  ,[SCAC_ALIAS]
		  ,[LAST_UPDATE_DT]
		  ,[INSERT_DT]
		  ,[SOURCE]
		  ,[APPROVED_DT]
		  ,[UPDATE_DT]
		  ,[REVISED_DT]
	  FROM TI_IMP.PIERSTI.TI_DWH.SCAC_DIM

	--INSERT INTO ti_prod.scac_dim
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.SCAC_DIM
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_PIERS_COUNTRY'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.piers_country
	--Changes by Cognizant, 25-Nov-2009, start
	--INSERT INTO ti_prod.piers_country
	INSERT INTO [Ti3Load].[ti_prod].[piers_country]
           ([ID]
           ,[CODE]
           ,[DESCR])
	--Changes by Cognizant, 25-Nov-2009, end
	--Changes by Cognizant, 23-Nov-2009, start
	--PIERSTI is now a SQL Server Database instead of Oracle Database
	SELECT ID,CODE,DESCR FROM TI_IMP.PIERSTI.TI_DWH.PIERS_COUNTRY
	--Changes by Cognizant, 23-Nov-2009, end

	--There was an error stating 'Invalid data for type "numeric"' due to some issue with ORAOLEDB driver in interpreting
	--numeric data types in Oracle.
	--As per the recommendation from this forum http://forums.oracle.com/forums/thread.jspa?threadID=337842&tstart=-2
	--Using the to_char transformation for the numeric column
	
	--Changes by Cognizant, 23-Nov-2009, start
	--PIERSTI is now a SQL Server Database instead of Oracle Database

	--SELECT * FROM OPENQUERY(TI_IMP,'SELECT TO_CHAR(ID),CODE,DESCR FROM TI_DWH.PIERS_COUNTRY')
	--Changes by Cognizant, 23-Nov-2009, end

	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.PIERS_COUNTRY
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_FOREIGN_PORT_DIM'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.foreign_port_dim
	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[foreign_port_dim]
           ([FP_KEY]
           ,[NAME]
           ,[COUNTRY_KEY]
           ,[FOREIGN_PORT_CD_ALIAS]
           ,[INSERT_DT]
           ,[SOURCE]
           ,[APPROVED_DT]
           ,[UPDATE_DT]
           ,[REVISED_DT])
    SELECT [FP_KEY]
		,[NAME]
		,[COUNTRY_KEY]
		,[FOREIGN_PORT_CD_ALIAS]
      ,[INSERT_DT]
      ,[SOURCE]
      ,[APPROVED_DT]
      ,[UPDATE_DT]
      ,[REVISED_DT]         
  FROM TI_IMP.PIERSTI.TI_DWH.FOREIGN_PORT_DIM

	--INSERT INTO ti_prod.foreign_port_dim
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.FOREIGN_PORT_DIM
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_COUNTRY_DIM'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.country_dim
	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[country_dim]
           ([COUNTRY_KEY]
           ,[NAME]
           ,[CNTRY_CD_ALIAS]
           ,[USCS_CNTRY_CD]
           ,[SOURCE]
           ,[NAME_ABBR])
    SELECT [COUNTRY_KEY]
		,[NAME]
		,[CNTRY_CD_ALIAS]
		,[USCS_CNTRY_CD]
		,[SOURCE]
      ,[NAME_ABBR]
  FROM TI_IMP.PIERSTI.TI_DWH.COUNTRY_DIM
	
	--INSERT INTO ti_prod.country_dim
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.COUNTRY_DIM
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_COAST_SWAP'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT	
	TRUNCATE TABLE ti_prod.coast_swap
	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[coast_swap]
           ([PORT_CD]
           ,[COAST])
    SELECT [PORT_CD]
      ,[COAST]
	FROM TI_IMP.PIERSTI.TI_DWH.COAST_SWAP

	--INSERT INTO ti_prod.coast_swap
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.COAST_SWAP
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_REGION_SWAP'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.region_swap
	--Changes by Cognizant, 25-Nov-2009, start

	INSERT INTO [Ti3Load].[ti_prod].[region_swap]
           ([CNTRYCD]
           ,[REGION])
	SELECT [CNTRYCD]
      ,[REGION]
	FROM TI_IMP.PIERSTI.TI_DWH.REGION_SWAP
    
	--INSERT INTO ti_prod.region_swap
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.REGION_SWAP
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

SET @StepName = 'GetTIRefs_TI_VIEW_PPMM_PORTS'
EXEC dbo.usp_LoadStepLogCreate @IdLoadLog, @StepName, @IdLoadStepLog OUT
	TRUNCATE TABLE ti_prod.ppmm_ports_view

	--Changes by Cognizant, 25-Nov-2009, start
	INSERT INTO [Ti3Load].[ti_prod].[ppmm_ports_view]
           ([PORT_NAME]
           ,[PORT]
           ,[COUNTRY]
           ,[JOC_CODE])
	SELECT [PORT_NAME]
      ,[PORT]
      ,[COUNTRY]
      ,[JOC_CODE]
	FROM TI_IMP.PIERSTI.TI_DWH.TI_VIEW_PPMM_PORTS 
    
	--INSERT INTO ti_prod.ppmm_ports_view
	 --SELECT * FROM TI_IMP.PIERSTI.TI_DWH.TI_VIEW_PPMM_PORTS 
	--Changes by Cognizant, 25-Nov-2009, end
SELECT @RowsAffected = @@ROWCOUNT, @Comment = 'Done'
EXEC dbo.usp_LoadStepLogUpdate @IdLoadStepLog, @RowsAffected, @Comment

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

--    * ERROR_NUMBER() - returns the number of the error.
--    * ERROR_SEVERITY() - returns the severity.
--    * ERROR_STATE() - returns the error state number.
--    * ERROR_PROCEDURE() - returns the name of the stored procedure or trigger where the error occurred.
--    * ERROR_LINE() - returns the line number inside the routine that caused the error.
--    * ERROR_MESSAGE() - returns the complete text of the error message.

	UPDATE dbo.LoadLog SET
	 Status = 'Failed', comments = comments + @NEWLINE + CONVERT(VARCHAR,GETDATE(),109) + ': ' + @ErrorInfo
	,StopDate = getdate()
	WHERE IdLoadLog=@IdLoadLog
END CATCH

END
GO
