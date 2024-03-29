/****** Object:  StoredProcedure [dbo].[Insert_Manifest_AssignDate_bkp_Aug29]    Script Date: 01/03/2013 19:47:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================
-- Author:		Cognizant
-- Create date: 30-March-2009
-- Description:	Carry Manifest Number and Arrival Date Changes 
-- to DQA_BL and BL_CACHE tables of SCREEN_TEST

--Modification History: Cognizant, 10-Aug-2009
-- Whenever, Global Update in DQA_VOYAGE is 1, do regular update to DQA_BL and BL_CACHE as before
-- Whenever, Global Update in DQA_VOYAGE is 2, do updates to DQA_BL, PES_STG_BOL, BL_BL and BL_CACHE tables

--Modification History: Cognizant, 16-Feb-2009
-- Log job start and stop status into a log file.

--Modification History: Cognizant, 17-Feb-2009
--UPDATE DQA_VOYAGE table for Global Update NULL using JOIN instead of IN clause

--Modification History: Cognizant, 19-Feb-2009
--Address Synchronization Issue between DQA_VOYAGE and other Bill Tables

--Modification History: Cognizant, 11-March-2010
--Update Mod fields of DQA_BL instead of the default fields during Global Update

-- =================================================================================
CREATE PROCEDURE [dbo].[Insert_Manifest_AssignDate_bkp_Aug29]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	DECLARE @FILE VARCHAR(1024)  --Changes, 16-Feb-2010, Log job status
	DECLARE @CMD VARCHAR(2000)   --Changes, 16-Feb-2010, Log job status

	DECLARE @TRAN_NAME_REGULAR VARCHAR(32),@TRAN_NAME_GLOBAL VARCHAR(32)
	DECLARE @ERROR_MESSAGE VARCHAR(1000),@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50),@DATE DATETIME
	
	DECLARE @Count_Regular int
	DECLARE @Count_Global_Update int

	DECLARE @LastModifyDate datetime
	DECLARE @LastModifyUser varchar(32)

	CREATE TABLE #VOYAGES_REGULAR
	(
		VOYAGE_ID		INT,
		DAILY_LOAD_DT	DATETIME,
		MANIFEST_NBR	VARCHAR(6)		
	)

	CREATE TABLE #VOYAGES_GLOBAL_UPDATE
	(
		VOYAGE_ID		INT,
		VOYAGE_NBR		VARCHAR(5),
		DAILY_LOAD_DT	DATETIME,
		MANIFEST_NBR	VARCHAR(6),
		USPORT_ID		INT, 
		USPORT_CD		VARCHAR(4),
		USPORT_NAME		VARCHAR(35),
		VESSEL_ID		INT,
		VESSEL_CD		VARCHAR(7),
		VESSEL_NAME		VARCHAR(35),
		CARRIER_ID		INT,
		CARRIER_CD		VARCHAR(4)
	)
	--Changes, 16-Feb-2010, Log job status, start
	SELECT @FILE =PATH FROM PES.dbo.PES_CONFIGURATION WITH (NOLOCK) WHERE SOURCE='SP_LOG'  
	SET @FILE='"'+@FILE+'INSERT_MANIFEST_ASSIGNDATE_'+REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(100),GETDATE(),100),' ','-'),':','-'),'--','-')+'_LOG.TXT"'  
	--Changes, 16-Feb-2010, Log job status, end

	SELECT @Count_Regular =0
	SELECT @Count_Global_Update =0

	SELECT @TRAN_NAME_REGULAR='REGULAR'
	SELECT @TRAN_NAME_GLOBAL='GLOBAL'

	SELECT @LastModifyDate = getdate()
	SELECT @LastModifyUser = user_name()

	--Changes, 16-Feb-2010, Log job status, start
	SET @CMD = 'ECHO PROCEDURE INSERT_MANIFEST_ASSIGNDATE STARTED >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD   
	--Changes, 16-Feb-2010, Log job status, end

	--Fetch the list of all voyage ids from DQA_VOYAGE table for which there is only Arrival Date/Manifest Number Update
	--into a temporary table 

	SELECT @Count_Regular=COUNT(VOYAGE_ID)
	FROM SCREEN_TEST.DBO.DQA_VOYAGE WITH (NOLOCK) 
	WHERE  ISNULL(GLOBAL_UPDATE,0) =1

	IF ISNULL(@Count_Regular,0) > 0
	BEGIN
		--Changes, 16-Feb-2010, Log job status, start
		SET @cmd = 'ECHO PROCEDURE INSERT_MANIFEST_ASSIGNDATE - REGULAR UPDATE STARTED' + ' AT :' + CONVERT(VARCHAR(100),GETDATE(),100) + ' >> ' + @FILE  
		EXEC master..xp_cmdshell @CMD   
		--Changes, 16-Feb-2010, Log job status, end

		INSERT INTO #VOYAGES_REGULAR(VOYAGE_ID,DAILY_LOAD_DT,MANIFEST_NBR)
		SELECT ISNULL(VOYAGE_ID,0),
		--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, start
		--	  (CASE ISNULL(ACT_ARRIVAL_DT_MOD,'') WHEN '' THEN ACT_ARRIVAL_DT ELSE ACT_ARRIVAL_DT_MOD END),
			 (CASE WHEN ACT_ARRIVAL_DT_MOD IS NULL THEN ACT_ARRIVAL_DT ELSE ACT_ARRIVAL_DT_MOD END),
		--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, end		
			  ACT_MANIFEST_NBR
		FROM SCREEN_TEST.DBO.DQA_VOYAGE WITH (NOLOCK) 
		WHERE ISNULL(GLOBAL_UPDATE,0) =1
		
		BEGIN TRANSACTION @TRAN_NAME_REGULAR
		BEGIN TRY

			--Update DQA_BL table		
			UPDATE B WITH (UPDLOCK)
			--Changes by Cognizant, 5-Feb-2010, start (to fix Daily Load Date Issue)
			--SET DAILY_LOAD_DT=V.DAILY_LOAD_DT,
			SET VDATE=V.DAILY_LOAD_DT,
			--Changes by Cognizant, 5-Feb-2010, end
			MANIFEST_NBR_MOD=V.MANIFEST_NBR,
			MODIFIED_DT	= @LastModifyDate			
			FROM DQA_BL B JOIN #VOYAGES_REGULAR V
			ON ISNULL(B.DQA_VOYAGE_ID,0)=V.VOYAGE_ID		

		--Update ARCHIVE_DQA_BL table		
--			UPDATE B WITH (UPDLOCK)
--			--Changes by Cognizant, 5-Feb-2010, start (to fix Daily Load Date Issue)
--			--SET DAILY_LOAD_DT=V.DAILY_LOAD_DT,
--			SET VDATE=V.DAILY_LOAD_DT,
--			--Changes by Cognizant, 5-Feb-2010, end
--			MANIFEST_NBR_MOD=V.MANIFEST_NBR,
--			MODIFIED_DT	= @LastModifyDate			
--			FROM PES_PURGE.DBO.ARCHIVE_DQA_BL B JOIN #VOYAGES_REGULAR V
--			ON ISNULL(B.DQA_VOYAGE_ID,0)=V.VOYAGE_ID		


			SET @cmd = 'ECHO REGULAR DQA_BL UPDATE COMPLETED '+ ' AT :' + CAST(GETDATE() AS VARCHAR(35))
			EXEC master..xp_cmdshell @CMD   

			--Update BL_CACHE table

			UPDATE C WITH (UPDLOCK)
			SET ACT_ARRIVAL_DT=V.DAILY_LOAD_DT,
				DQA_VOYAGE_ID=B.DQA_VOYAGE_ID
				/*
				Commented by Cognizant, 10-Feb-2010 as it is affecting productivity report
				DT_LAST_UPDT=@LastModifyDate
				*/
			FROM BL_CACHE C JOIN BL_BL B  WITH (NOLOCK)
			ON B.T_NBR = C.T_NBR 
			JOIN #VOYAGES_REGULAR V 
			ON ISNULL(B.DQA_VOYAGE_ID,0) = V.VOYAGE_ID		

			--Update BL_CACHE table

--			UPDATE C WITH (UPDLOCK)
--			SET ACT_ARRIVAL_DT=V.DAILY_LOAD_DT,
--				DQA_VOYAGE_ID=B.DQA_VOYAGE_ID
--				/*
--				Commented by Cognizant, 10-Feb-2010 as it is affecting productivity report
--				DT_LAST_UPDT=@LastModifyDate
--				*/
--			FROM PES_PURGE.DBO.ARCHIVE_BL_CACHE C JOIN PES_PURGE.DBO.ARCHIVE_BL_BL B  (NOLOCK)
--			ON B.T_NBR = C.T_NBR 
--			JOIN #VOYAGES_REGULAR V 
--			ON ISNULL(B.DQA_VOYAGE_ID,0) = V.VOYAGE_ID		

			SET @cmd = 'ECHO REGULAR BL_CACHE UPDATE COMPLETED '+ ' AT :' + CAST(GETDATE() AS VARCHAR(35))
			EXEC master..xp_cmdshell @CMD   


			--There was a trigger UPD_DT_DQA_VOYAGE that was updating Modify_date in PES_STG_BOL.
			--This was freezing up the co-ordinator screen, when Data Load jobs were running in parallel - Defect #3728
			--Thereby, we set the modify_date in PES_STG_BOL as part of this procedure
			UPDATE B WITH (UPDLOCK)
			SET MODIFY_DATE =@LastModifyDate,
			MODIFY_USER =@LastModifyUser			
			FROM PES.DBO.PES_STG_BOL B JOIN #VOYAGES_REGULAR V
			ON ISNULL(B.STND_VOYG_ID,0)=V.VOYAGE_ID
			WHERE B.RECORD_STATUS IN('AUTOMATED','CLEANSED')

			--Update Global Update Flag back to null
			--Changes by Cognizant, 17-Feb-2010, start
			--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, start
			--Do not set Status to NULL if data between DQA_VOYAGE and  #VOYAGES_REGULAR has changed
			UPDATE V WITH (UPDLOCK)
			SET GLOBAL_UPDATE = NULL, MODIFIED_BY = @LastModifyUser, MODIFIED_DT = @LastModifyDate			
			FROM DQA_VOYAGE V JOIN #VOYAGES_REGULAR R
			ON V.VOYAGE_ID=R.VOYAGE_ID
			WHERE R.DAILY_LOAD_DT = (CASE WHEN ACT_ARRIVAL_DT_MOD IS NULL THEN ACT_ARRIVAL_DT ELSE ACT_ARRIVAL_DT_MOD END)
			AND	R.MANIFEST_NBR	= V.ACT_MANIFEST_NBR
			AND ISNULL(V.GLOBAL_UPDATE,0)=1
			--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, start
			--Changes by Cognizant, 17-Feb-2010, end

			SET @cmd = 'ECHO REGULAR DQA_VOYAGE UPDATE COMPLETED '+ ' AT :' + CONVERT(VARCHAR(100),GETDATE(),100)
			EXEC master..xp_cmdshell @CMD   
		END TRY
		BEGIN CATCH  
		  ROLLBACK TRANSACTION @TRAN_NAME_REGULAR
		  SET @ERROR_NUMBER=ERROR_NUMBER()  		  
		  SET @ERROR_LINE=ERROR_LINE()  
		  SET @ERROR_MESSAGE='Stored Procedure Insert_Manifest_AssignDate failed with ERROR DESCRIPTION:  '+ERROR_MESSAGE()  
		  GOTO PROC_RETURN_REGULAR_UPDATE
		END CATCH  		
		
		COMMIT TRANSACTION @TRAN_NAME_REGULAR

		--Changes, 16-Feb-2010, Log job status, start
		SET @cmd = 'ECHO PROCEDURE INSERT_MANIFEST_ASSIGNDATE - REGULAR UPDATE ENDED'+ ' AT :' + CAST(GETDATE() AS VARCHAR(35)) + ' >> '+ @FILE  
		EXEC master..xp_cmdshell @CMD   
		--Changes, 16-Feb-2010, Log job status, end

	END	
	
	SELECT @Count_Global_Update=COUNT(VOYAGE_ID)
	FROM DQA_VOYAGE WITH (NOLOCK) 
	WHERE ISNULL(GLOBAL_UPDATE,0) =2

	IF ISNULL(@Count_Global_Update,0) > 0
	BEGIN
		--Changes, 16-Feb-2010, Log job status, start
		SET @cmd = 'ECHO PROCEDURE INSERT_MANIFEST_ASSIGNDATE - GLOBAL UPDATE STARTED'+ ' >> '+ @FILE  
		EXEC master..xp_cmdshell @CMD   
		--Changes, 16-Feb-2010, Log job status, end

		INSERT INTO #VOYAGES_GLOBAL_UPDATE(VOYAGE_ID,VOYAGE_NBR,DAILY_LOAD_DT,MANIFEST_NBR,USPORT_ID,USPORT_CD,USPORT_NAME,
					VESSEL_ID,VESSEL_CD,VESSEL_NAME,CARRIER_ID,CARRIER_CD)
		SELECT ISNULL(VOYAGE_ID,0),VOYAGE_NBR,
		--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, start
		--	  (CASE ISNULL(ACT_ARRIVAL_DT_MOD,'') WHEN '' THEN ACT_ARRIVAL_DT ELSE ACT_ARRIVAL_DT_MOD END),
			 (CASE WHEN ACT_ARRIVAL_DT_MOD IS NULL THEN ACT_ARRIVAL_DT ELSE ACT_ARRIVAL_DT_MOD END),
		--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, end		
			  ACT_MANIFEST_NBR,
			  USPORT_ID,
			  PORT_UNLADING_CD,
			  US_PORTNAME,
			  VESSEL_ID,	
			  VESSEL_CD,
			  VESSEL_NAME,
			  CARRIER_ID,
			  SCAC			  	
		FROM SCREEN_TEST.DBO.DQA_VOYAGE WITH (NOLOCK) 
		WHERE ISNULL(GLOBAL_UPDATE,0) =2

		--Update DQA_BL table
		BEGIN TRANSACTION @TRAN_NAME_GLOBAL
		BEGIN TRY
			Declare @BillID int
		
			declare dqaCursor cursor for
			select t_nbr from screen_test.dbo.dqa_bl WITH (NOLOCK)
			where DQA_VOYAGE_ID	in (select VOYAGE_ID from #VOYAGES_GLOBAL_UPDATE)

			OPEN dqaCursor
			FETCH NEXT FROM dqaCursor INTO @BillID

			WHILE @@FETCH_STATUS=0
			BEGIN

				UPDATE B WITH (UPDLOCK)
				--Changes by Cognizant, 5-Feb-2010, start (to fix Daily Load Date Issue)
				--SET DAILY_LOAD_DT=V.DAILY_LOAD_DT,
				SET vdate=V.DAILY_LOAD_DT,
				--Changes by Cognizant, 5-Feb-2010, end (to fix Daily Load Date Issue)
					MANIFEST_NBR_MOD=V.MANIFEST_NBR,
					VOYAGE = V.VOYAGE_NBR, 
					CARRIER_ID_MOD = V.CARRIER_ID,
					CARRIER_NAME_MOD = V.CARRIER_CD,
					VESSEL_ID_MOD=V.VESSEL_ID,
					VESSEL_NAME_MOD = V.VESSEL_NAME,
					USPORT_ID_MOD=V.USPORT_ID,
					USPORT_CODE_MOD=V.USPORT_CD,
					USPORT_NAME_MOD=V.USPORT_NAME,
					MODIFIED_DT	= @LastModifyDate				
				FROM DQA_BL B JOIN #VOYAGES_GLOBAL_UPDATE V
				ON ISNULL(B.DQA_VOYAGE_ID,0)=V.VOYAGE_ID	
				WHERE B.T_NBR=@BillID

			--UPDATE ARCHIVE_DQA_BL
--			UPDATE B WITH (UPDLOCK)
--				--Changes by Cognizant, 5-Feb-2010, start (to fix Daily Load Date Issue)
--				--SET DAILY_LOAD_DT=V.DAILY_LOAD_DT,
--				SET vdate=V.DAILY_LOAD_DT,
--				--Changes by Cognizant, 5-Feb-2010, end (to fix Daily Load Date Issue)
--					MANIFEST_NBR_MOD=V.MANIFEST_NBR,
--					VOYAGE = V.VOYAGE_NBR, 
--					CARRIER_ID_MOD = V.CARRIER_ID,
--					CARRIER_NAME_MOD = V.CARRIER_CD,
--					VESSEL_ID_MOD=V.VESSEL_ID,
--					VESSEL_NAME_MOD = V.VESSEL_NAME,
--					USPORT_ID_MOD=V.USPORT_ID,
--					USPORT_CODE_MOD=V.USPORT_CD,
--					USPORT_NAME_MOD=V.USPORT_NAME,
--					MODIFIED_DT	= @LastModifyDate				
--				FROM PES_PURGE.DBO.ARCHIVE_DQA_BL B JOIN #VOYAGES_GLOBAL_UPDATE V
--				ON ISNULL(B.DQA_VOYAGE_ID,0)=V.VOYAGE_ID	
--				WHERE B.T_NBR=@BillID

			FETCH NEXT FROM dqaCursor INTO @BillID
			END

			CLOSE dqaCursor
			DEALLOCATE dqaCursor

			--Update BL_BL table
			UPDATE B WITH (UPDLOCK)
			SET ACT_ARR_DT=V.DAILY_LOAD_DT,
				MANIFEST_NBR=V.MANIFEST_NBR,
				VOYAGE_NBR = V.VOYAGE_NBR, 
				CARRIER_ID = V.CARRIER_ID,
				SCAC  = V.CARRIER_CD,
				VESSEL_ID=V.VESSEL_ID,
				VESSEL_NAME = V.VESSEL_NAME,
				US_PORT=V.USPORT_ID,
				CLEARING_PORT_CD=V.USPORT_CD,
				LAST_UPDATE_DT=@LastModifyDate							
			FROM BL_BL B JOIN #VOYAGES_GLOBAL_UPDATE V
			ON ISNULL(B.DQA_VOYAGE_ID,0)=V.VOYAGE_ID		

	--Update ARCHIVE_BL_BL table
--			UPDATE B WITH (UPDLOCK)
--			SET ACT_ARR_DT=V.DAILY_LOAD_DT,
--				MANIFEST_NBR=V.MANIFEST_NBR,
--				VOYAGE_NBR = V.VOYAGE_NBR, 
--				CARRIER_ID = V.CARRIER_ID,
--				SCAC  = V.CARRIER_CD,
--				VESSEL_ID=V.VESSEL_ID,
--				VESSEL_NAME = V.VESSEL_NAME,
--				US_PORT=V.USPORT_ID,
--				CLEARING_PORT_CD=V.USPORT_CD,
--				LAST_UPDATE_DT=@LastModifyDate							
--			FROM PES_PURGE.DBO.ARCHIVE_BL_BL B JOIN #VOYAGES_GLOBAL_UPDATE V
--			ON ISNULL(B.DQA_VOYAGE_ID,0)=V.VOYAGE_ID		


			--Update PES_STG_BOL table
			UPDATE B WITH (UPDLOCK)
			SET VDATE=V.DAILY_LOAD_DT,
				MANIFEST_NUMBER=V.MANIFEST_NBR,
				VOYAGE = V.VOYAGE_NBR, 
				SLINE_REF_ID = V.CARRIER_ID,
				SCAC  = V.CARRIER_CD,
				VESSEL_REF_ID=V.VESSEL_ID,
				VESSEL_NAME = V.VESSEL_NAME,
				PORT_DEPART_REF_ID=V.USPORT_ID,
				USPORT = V.USPORT_CD,
				PORT_OF_DEPARTURE=V.USPORT_NAME,
				MODIFY_DATE =@LastModifyDate,
				MODIFY_USER =@LastModifyUser			
			FROM PES.DBO.PES_STG_BOL B JOIN #VOYAGES_GLOBAL_UPDATE V
			ON ISNULL(B.STND_VOYG_ID,0)=V.VOYAGE_ID

			--Update BL_CACHE table
			UPDATE C WITH (UPDLOCK)
			SET ACT_ARRIVAL_DT=B.VDATE,
				VOYAGE_NBR = B.VOYAGE,
				SCAC = B.SCAC,
				VESSEL_NAME = B.VESSEL_NAME,
				US_PORT=B.PORT_OF_DEPARTURE,
				DQA_VOYAGE_ID=	B.STND_VOYG_ID
				/*
				Commented by Cognizant, 10-Feb-2010 as it is affecting productivity report
				,
				DT_LAST_UPDT=@LastModifyDate		
				*/
			FROM BL_CACHE C 
			INNER JOIN PES.DBO.PES_STG_BOL B WITH (NOLOCK)  ON B.BOL_ID=C.T_NBR 		
			WHERE ISNULL(B.STND_VOYG_ID,0) IN (SELECT VOYAGE_ID FROM #VOYAGES_GLOBAL_UPDATE)		
			
			--Update ARCHIVE_BL_CACHE table
--			UPDATE C WITH (UPDLOCK)
--			SET ACT_ARRIVAL_DT=B.VDATE,
--				VOYAGE_NBR = B.VOYAGE,
--				SCAC = B.SCAC,
--				VESSEL_NAME = B.VESSEL_NAME,
--				US_PORT=B.PORT_OF_DEPARTURE,
--				DQA_VOYAGE_ID=	B.STND_VOYG_ID
--				/*
--				Commented by Cognizant, 10-Feb-2010 as it is affecting productivity report
--				,
--				DT_LAST_UPDT=@LastModifyDate		
--				*/
--			FROM PES_PURGE.DBO.ARCHIVE_BL_CACHE C 
--			INNER JOIN PES.DBO.PES_STG_BOL B (NOLOCK)  ON B.BOL_ID=C.T_NBR 		
--			WHERE ISNULL(B.STND_VOYG_ID,0) IN (SELECT VOYAGE_ID FROM #VOYAGES_GLOBAL_UPDATE)		
			
			--Changes by Cognizant, 17-Feb-2010, start
			--Update Global Update Flag back to null
			
			--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, start
			--Do not set Status to NULL if data between DQA_VOYAGE and  #VOYAGES_GLOBAL_UPDATE has changed
			--Presently, we are only checking for Manifest Number and Arrival Date to be same from a performance standpoint
			UPDATE V WITH (UPDLOCK)
			SET GLOBAL_UPDATE = NULL, MODIFIED_BY = @LastModifyUser, MODIFIED_DT = @LastModifyDate			
			FROM DQA_VOYAGE V JOIN #VOYAGES_GLOBAL_UPDATE G
			ON V.VOYAGE_ID=G.VOYAGE_ID
			WHERE G.DAILY_LOAD_DT = (CASE WHEN ACT_ARRIVAL_DT_MOD IS NULL THEN ACT_ARRIVAL_DT ELSE ACT_ARRIVAL_DT_MOD END)
			AND	G.MANIFEST_NBR	= V.ACT_MANIFEST_NBR
			AND ISNULL(V.GLOBAL_UPDATE,0)=2
			--Changes for Synchronization Issue, Cognizant, 19-Feb-2010, end

			--Changes by Cognizant, 17-Feb-2010, end

		END TRY
		BEGIN CATCH  
		  ROLLBACK TRANSACTION @TRAN_NAME_GLOBAL
		  SET @ERROR_NUMBER=ERROR_NUMBER()  		  
		  SET @ERROR_LINE=ERROR_LINE()  
		  SET @ERROR_MESSAGE='Stored Procedure Insert_Manifest_AssignDate failed with ERROR DESCRIPTION:  '+ERROR_MESSAGE()  
		  GOTO PROC_RETURN_GLOBAL_UPDATE
		END CATCH  
		
		
		
		COMMIT TRANSACTION @TRAN_NAME_GLOBAL	
		DROP TABLE #VOYAGES_REGULAR
		DROP TABLE #VOYAGES_GLOBAL_UPDATE	

		--Changes, 16-Feb-2010, Log job status, start
		SET @cmd = 'ECHO PROCEDURE INSERT_MANIFEST_ASSIGNDATE - GLOBAL UPDATE ENDED'+ ' >> '+ @FILE  
		EXEC master..xp_cmdshell @CMD   
		--Changes, 16-Feb-2010, Log job status, end

	END		

	
--Changes, 16-Feb-2010, Log job status, start
SET @cmd = 'ECHO PROCEDURE INSERT_MANIFEST_ASSIGNDATE ENDED'+ ' >> '+ @FILE  
EXEC master..xp_cmdshell @CMD   
--Changes, 16-Feb-2010, Log job status, end

PROC_RETURN_REGULAR_UPDATE:
IF @ERROR_NUMBER IS NOT NULL  
BEGIN
	EXEC PES.DBO.PES_SP_EMAIL 'Regular Update of Voyage Details Failed','Regular Update of Voyage Details Failed',@ERROR_MESSAGE,@ERROR_LINE,@ERROR_NUMBER  

	--Changes, 16-Feb-2010, Log job status, start
	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD   
	SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD   
	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD  	
	--Changes, 16-Feb-2010, Log job status, end

	RETURN --Changes, 19-Feb-2010, Include RETURN statement
END

PROC_RETURN_GLOBAL_UPDATE:
IF @ERROR_NUMBER IS NOT NULL  
BEGIN	
	EXEC PES.DBO.PES_SP_EMAIL 'Global Update of Voyage Details Failed','Global Update of Voyage Details Failed',@ERROR_MESSAGE,@ERROR_LINE,@ERROR_NUMBER  

	--Changes, 16-Feb-2010, Log job status, start
	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD   
	SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD   
	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE  
	EXEC master..xp_cmdshell @CMD  	
	--Changes, 16-Feb-2010, Log job status, end

	RETURN --Changes, 19-Feb-2010, Include RETURN statement
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
