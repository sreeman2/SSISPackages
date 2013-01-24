/****** Object:  StoredProcedure [dbo].[PES_SP_UPD_STD_VOYAGE]    Script Date: 01/03/2013 19:48:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_UPD_STD_VOYAGE] 
AS
/*
	Procedure Name: PES_SP_UPD_STD_VOYAGE
	Created By:	Cognizant
	Created Date: 18-Feb-2009
	Description: Periodically lookup PES_TEMP_BOL_FUZZY table to identify bills for assigning new voyage ids
				 based on the correction for fuzzy exceptions (vessel, carrier, foreign port)
*/

/*
Modification History: Cognizant, 17-Feb-2010
a. Shift LCL Calculation to Update Staging Stored Procedure
b. Better way to calculate Voyage-level counts
*/

BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @TRANNAME VARCHAR(20),@FILE VARCHAR(500)  
DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),  
@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50)  

SET @TRANNAME = 'MyTransaction'  
SELECT @FILE = PATH FROM PES.DBO.PES_CONFIGURATION WITH (NOLOCK) WHERE SOURCE='SP_LOG'  
SET @FILE='"'+@FILE+'VOYAGE_CREATION'+REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(100),GETDATE(),100),' ','-'),':','-'),'--','-')+'_LOG.TXT"'  

BEGIN TRANSACTION @TRANNAME  
BEGIN TRY  

	-- Variable Declaration
	
	DECLARE @NEW_USPORT_ID INT
	DECLARE @NEW_VESSEL_ID INT
	DECLARE @NEW_CARRIER_ID INT
	DECLARE @NEW_T_NBR INT
	DECLARE @CNT INT
	DECLARE @vvessel VARCHAR(25)
	DECLARE @VOYAGENBR VARCHAR(5)
	DECLARE @MANIFEST_NUMBER VARCHAR(6)
	DECLARE @LNBR INT
	DECLARE @ESTDT DATETIME
	DECLARE @BOL_ID INT 
	DECLARE @DIR CHAR(1)
	DECLARE @BATCH_ID VARCHAR(10)
	DECLARE @VSCAC VARCHAR(4)  
	DECLARE @VPORTCD VARCHAR(4)
	DECLARE @MNBR VARCHAR(6)
	DECLARE @VOYAGEDATE DATETIME
	DECLARE @TAPE_DT DATETIME
	DECLARE @VSTATUS VARCHAR(10)
	DECLARE @VESSEL_CD VARCHAR(7)
	DECLARE @MAX_VOYAGE_ID INT
	
	DECLARE @Bills TABLE
	(
		T_NBR int
	)
	
	-- Changes by Cognizant, 17-Feb-2010, start
	CREATE TABLE #Voyages 
	(
		VOYAGE_ID INT,
		PPMM_CNT INT,
		CLEANSED_CNT INT,	
		PENDING_CNT INT,
		DELETED_CNT INT,
		TOTAL_CNT INT,
		SKIPPED_CNT INT		
	)
	-- Changes by Cognizant, 17-Feb-2010, end
	
	--First fetch the bills from PES_TEMP_BOL_FUZZY
	INSERT INTO @Bills(T_NBR)
	SELECT T_NBR FROM PES_TEMP_BOL_FUZZY WITH (NOLOCK)
	WHERE PROCESS_FLG = 'N' ORDER BY T_NBR

	DECLARE curBills CURSOR FOR
	SELECT T_NBR FROM @Bills

	OPEN curBills
	FETCH NEXT FROM curBills INTO @NEW_T_NBR

	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT  @NEW_VESSEL_ID=ISNULL(VESSEL_ID_MOD,VESSEL_ID),
				@NEW_USPORT_ID=ISNULL(USPORT_ID_MOD,USPORT_ID),
				@NEW_CARRIER_ID=ISNULL(CARRIER_ID_MOD,CARRIER_ID)
		FROM DQA_BL WITH (NOLOCK)
		WHERE T_NBR = @NEW_T_NBR

	--*********************************************************************
	--UPD_STD_VOYAGE Trigger Logic Starts Here	

		SET @CNT=0
		SET @MNBR= ''

		SET @TAPE_DT=GETDATE()

		Select	@BOL_ID=A.T_NBR,
				@LNBR=LOAD_NBR,
				@VOYAGENBR=ISNULL(A.VOYAGE_NBR,''),
				@ESTDT=ISNULL(A.EST_ARR_DT,''),
				@MANIFEST_NUMBER=ISNULL(A.MANIFEST_NBR,''),
				@DIR=A.DIR,
				@BATCH_ID=A.BATCH_ID 
		FROM BL_BL A WITH (NOLOCK)
		WHERE A.T_NBR=@NEW_T_NBR 

		IF SUBSTRING(CAST (@LNBR AS VARCHAR),LEN(CAST (@LNBR AS VARCHAR))-2,3) IN ('002','007','004','005','003','006','008','009','016','017','012','013','014' )
        BEGIN
			SELECT @CNT=COUNT(*) FROM DQA_VOYAGE WITH (NOLOCK)
            WHERE vessel_id = @NEW_VESSEL_ID
			AND carrier_id = @NEW_CARRIER_ID
			AND usport_id = @NEW_usport_id
			AND dir = @DIR
			AND voyage_nbr = @VOYAGENBR
			AND ISNULL(ACT_MANIFEST_NBR,'') = @MANIFEST_NUMBER
			--AND CONVERT(VARCHAR(10),ACT_ARRIVAL_DT,101) = CONVERT(VARCHAR(10),@ESTDT,101)
            AND ((@ESTDT BETWEEN ACT_ARRIVAL_DT AND ACT_ARRIVAL_DT+10) OR
			(@ESTDT BETWEEN ACT_ARRIVAL_DT-10 AND ACT_ARRIVAL_DT))

		END
		ELSE
        BEGIN
            SELECT @CNT=COUNT (*) FROM DQA_VOYAGE WITH (NOLOCK)
            WHERE vessel_id = @NEW_vessel_id
            AND carrier_id = @NEW_carrier_id
            AND usport_id = @NEW_usport_id
            AND dir = @DIR
            AND voyage_nbr=@VOYAGENBR     
			--AND CONVERT(VARCHAR(10),ACT_ARRIVAL_DT,101) = CONVERT(VARCHAR(10),@ESTDT,101)
            AND ((@ESTDT BETWEEN ACT_ARRIVAL_DT AND ACT_ARRIVAL_DT+10) OR
			(@ESTDT BETWEEN ACT_ARRIVAL_DT-10 AND ACT_ARRIVAL_DT))
        END
                     
        IF @cnt > 0
        BEGIN
			 IF SUBSTRING(CAST (@LNBR AS VARCHAR),LEN(CAST (@LNBR AS VARCHAR))-2,3) IN ('002','007','004','005','003','006','008','009','016','017','012','013','014' )
             BEGIN
				SELECT @CNT=MAX(VOYAGE_ID)FROM DQA_VOYAGE WITH (NOLOCK)
				WHERE vessel_id = @NEW_vessel_id
				AND carrier_id = @NEW_carrier_id
				AND usport_id = @NEW_usport_id
				AND dir = @DIR
				AND voyage_nbr=@VOYAGENBR
				AND ISNULL(ACT_MANIFEST_NBR,'') = @MANIFEST_NUMBER
				--AND CONVERT(VARCHAR(10),ACT_ARRIVAL_DT,101) = CONVERT(VARCHAR(10),@ESTDT,101)
				AND ((@ESTDT BETWEEN ACT_ARRIVAL_DT AND ACT_ARRIVAL_DT+10) OR
				(@ESTDT BETWEEN ACT_ARRIVAL_DT-10 AND ACT_ARRIVAL_DT))

			END
            ELSE
			BEGIN
				SELECT @CNT=MAX(VOYAGE_ID)FROM DQA_VOYAGE WITH (NOLOCK)
				 WHERE vessel_id = @NEW_vessel_id
				 AND carrier_id = @NEW_carrier_id
				 AND usport_id = @NEW_usport_id
				 AND dir = @DIR
				 AND voyage_nbr = @VOYAGENBR	
				 --AND CONVERT(VARCHAR(10),ACT_ARRIVAL_DT,101) = CONVERT(VARCHAR(10),@ESTDT,101)
                 AND ((@ESTDT BETWEEN ACT_ARRIVAL_DT AND ACT_ARRIVAL_DT+10) OR
				(@ESTDT BETWEEN ACT_ARRIVAL_DT-10 AND ACT_ARRIVAL_DT))

             END

			UPDATE BL_BL WITH (UPDLOCK)
			SET	CARRIER_ID=@NEW_CARRIER_ID,
				US_PORT=@NEW_USPORT_ID,
				VESSEL_ID=@NEW_VESSEL_ID,
				DQA_VOYAGE_ID=@CNT 
			WHERE BL_BL.T_NBR=@BOL_ID 
			
			--UPDATE DQA_VOYAGE_ID IN DQA_BL TABLE
			UPDATE DQA_BL WITH (UPDLOCK)
			SET DQA_VOYAGE_ID=@CNT 
			WHERE T_NBR=@BOL_ID

			UPDATE PES.DBO.PES_STG_BOL WITH (UPDLOCK)
			SET STND_VOYG_ID=@CNT,
			MODIFY_DATE=GETDATE()
			WHERE BOL_ID=@BOL_ID

			--Changes by Cognizant, 17-Feb-2010, start
			-- Insert into #VOYAGES table
			IF NOT EXISTS(SELECT VOYAGE_ID FROM #VOYAGES WHERE VOYAGE_ID=@CNT)
			BEGIN
				INSERT INTO #VOYAGES (Voyage_Id)
				SELECT @CNT
			END
			--Changes by Cognizant, 17-Feb-2010, end

         END
         ELSE
         BEGIN
               IF @ESTDT < '1900/01/01'
                  SET @voyagedate = '01/01/1900'
			   ELSE
				  SET @voyagedate=@ESTDT
               
				SELECT @VSCAC=ISNULL(CODE,'') FROM PES.DBO.REF_CARRIER WITH (NOLOCK)
				WHERE ID = @NEW_CARRIER_ID

				SELECT @VVESSEL=ISNULL([NAME],'') FROM PES.DBO.REF_VESSEL WITH (NOLOCK)
				WHERE ID = @NEW_VESSEL_ID

				SELECT @VPORTCD=ISNULL(CODE,'') FROM PES.DBO.REF_PORT WITH (NOLOCK)
				WHERE ID = @NEW_USPORT_ID

				SELECT @VESSEL_CD=ISNULL(IMO_CODE,'') FROM PES.DBO.REF_VESSEL WITH (NOLOCK)
				WHERE ID=@NEW_VESSEL_ID

			    SELECT @TAPE_DT=TAPE_DT 
			   FROM PES.DBO.RAW_STG_REC_COUNT WITH (NOLOCK)
			   where LOADNUMBER=@LNBR

               SET @vstatus = 'HOLD'

               IF @batch_id NOT IN ('AMS', 'OOLU', 'APLU', 'MAEU', 'CSCO','EVER','ESCAN','TRBR','SBRE','TRBI','CRLI','CRLE')
                  AND SUBSTRING(@BATCH_ID, 1,2) NOT IN('I$','E$') 
                BEGIN                 
                  SET @mnbr = @MANIFEST_NUMBER
                  SET @vstatus = 'AVAILABLE'
                END        
               ELSE
				   SET @mnbr = ''
            
              IF @batch_id IN ('ESCAN')
                 SET @mnbr = @MANIFEST_NUMBER
              
			  IF @ESTDT IS NULL OR @ESTDT =''
                  SET @ESTDT=GETDATE()			   

               INSERT INTO DQA_VOYAGE
                           (SCAC, vessel_cd, voyage_nbr,
                            port_unlading_cd, est_arrival_dt, act_arrival_dt,
                            manifest_nbr, 
                            earliest_tape_dt, 
                            priority_cd,
                            voyage_status, pending_cnt, cleansed_cnt,
							skipped_cnt, ppmm_cnt, total_cnt, vessel_name,
                            carrier_id, vessel_id, usport_id,
                            dir, batch_id, act_manifest_nbr
                           )
                VALUES (@vscac, @vessel_cd, @voyagenbr,
                        @vportcd, @voyagedate, @voyagedate,
                        @MANIFEST_NUMBER, 
                        @tape_dt, 
                        'M',
                        @vstatus, 0, 0,
                        0, 0, 1, @vvessel,
                        @NEW_carrier_id, @NEW_vessel_id, @NEW_usport_id,
                        @dir, @batch_id, @mnbr
                  )
			
				SELECT @MAX_VOYAGE_ID=MAX(VOYAGE_ID) FROM DQA_VOYAGE WITH (NOLOCK)

				UPDATE BL_BL WITH (UPDLOCK)
				SET CARRIER_ID=@NEW_CARRIER_ID,
					US_PORT=@NEW_USPORT_ID,
					VESSEL_ID=@NEW_VESSEL_ID,
					DQA_VOYAGE_ID=@MAX_VOYAGE_ID 
				WHERE BL_BL.T_NBR=@BOL_ID

				  --UPDATING DQA_VOYAGE_ID IN DQA_BL TABLE
				UPDATE DQA_BL WITH (UPDLOCK)
				SET dqa_voyage_id =@MAX_VOYAGE_ID 
				WHERE T_NBR = @BOL_ID 

				UPDATE PES.DBO.PES_STG_BOL WITH (UPDLOCK)
				SET STND_VOYG_ID=@MAX_VOYAGE_ID,
				MODIFY_DATE=GETDATE() 
				WHERE BOL_ID = @BOL_ID          

				--Changes by Cognizant, 17-Feb-2010, start
				-- Insert into #VOYAGES table
				IF NOT EXISTS(SELECT VOYAGE_ID FROM #VOYAGES WHERE VOYAGE_ID=@MAX_VOYAGE_ID)
				BEGIN
					INSERT INTO #VOYAGES (Voyage_Id)
					SELECT @MAX_VOYAGE_ID
				END
				--Changes by Cognizant, 17-Feb-2010, end
         END

	--UPD_STD_VOYAGE Trigger Logic Ends Here	
	--*********************************************************************
		--Set the status of the bill to 'Y' in PES_TEMP_BOL_FUZZY table
		UPDATE PES_TEMP_BOL_FUZZY WITH (UPDLOCK)
		SET PROCESS_FLG='Y'
		WHERE T_NBR=@NEW_T_NBR
	

	FETCH NEXT FROM curBills INTO @NEW_T_NBR
	END

	CLOSE curBills
	DEALLOCATE curBills

--Changes by Cognizant, 17-Feb-2010, start

--Populate the counts in temporary table #Voyages
--PPMM Count
UPDATE V
SET PPMM_CNT = X.PPMM_CNT
FROM #VOYAGES V
JOIN
(
	SELECT VOYAGE_ID,COUNT(ISNULL(T_NBR,0)) AS PPMM_CNT
	FROM #VOYAGES V JOIN SCREEN_TEST.DBO.BL_BL A WITH (NOLOCK)
	ON A.DQA_VOYAGE_ID=V.VOYAGE_ID 
	WHERE A.DQA_BL_STATUS='AUTOMATED' AND ISNULL(A.IS_DELETED,'') <> 'Y'
	GROUP BY VOYAGE_ID	
)X
ON V.VOYAGE_ID=X.VOYAGE_ID

--Cleansed Count
UPDATE V
SET CLEANSED_CNT = X.CLEANSED_CNT
FROM #VOYAGES V
JOIN
(
	SELECT VOYAGE_ID,COUNT(ISNULL(T_NBR,0)) AS CLEANSED_CNT
	FROM #VOYAGES V JOIN SCREEN_TEST.DBO.BL_BL A WITH (NOLOCK)
	ON A.DQA_VOYAGE_ID=V.VOYAGE_ID 
	WHERE A.DQA_BL_STATUS='CLEANSED' AND ISNULL(A.IS_DELETED,'') <> 'Y'
	GROUP BY VOYAGE_ID	
)X
ON V.VOYAGE_ID=X.VOYAGE_ID

--Pending Count
UPDATE V
SET PENDING_CNT = X.PENDING_CNT
FROM #VOYAGES V
JOIN
(
	SELECT VOYAGE_ID,COUNT(ISNULL(T_NBR,0)) AS PENDING_CNT
	FROM #VOYAGES V JOIN SCREEN_TEST.DBO.BL_BL A WITH (NOLOCK)
	ON A.DQA_VOYAGE_ID=V.VOYAGE_ID 
	WHERE A.DQA_BL_STATUS='PENDING' AND ISNULL(A.IS_DELETED,'') <> 'Y'
	GROUP BY VOYAGE_ID	
)X
ON V.VOYAGE_ID=X.VOYAGE_ID

--Deleted Count
UPDATE V
SET DELETED_CNT = X.DELETED_CNT
FROM #VOYAGES V
JOIN
(
	SELECT VOYAGE_ID,COUNT(ISNULL(T_NBR,0)) AS DELETED_CNT
	FROM #VOYAGES V JOIN SCREEN_TEST.DBO.BL_BL A WITH (NOLOCK)
	ON A.DQA_VOYAGE_ID=V.VOYAGE_ID 
	WHERE ISNULL(A.IS_DELETED,'') = 'Y'
	GROUP BY VOYAGE_ID	
)X
ON V.VOYAGE_ID=X.VOYAGE_ID

--Total Count
UPDATE V
SET TOTAL_CNT = X.TOTAL_CNT
FROM #VOYAGES V
JOIN
(
	SELECT VOYAGE_ID,COUNT(ISNULL(T_NBR,0)) AS TOTAL_CNT
	FROM #VOYAGES V JOIN SCREEN_TEST.DBO.BL_BL A WITH (NOLOCK)
	ON A.DQA_VOYAGE_ID=V.VOYAGE_ID 	
	GROUP BY VOYAGE_ID	
)X
ON V.VOYAGE_ID=X.VOYAGE_ID

--Skipped Count
UPDATE V
SET SKIPPED_CNT = X.SKIPPED_CNT
FROM #VOYAGES V
JOIN
(
	SELECT VOYAGE_ID,COUNT(ISNULL(T_NBR,0)) AS SKIPPED_CNT
	FROM #VOYAGES V JOIN SCREEN_TEST.DBO.BL_BL A WITH (NOLOCK)
	ON A.DQA_VOYAGE_ID=V.VOYAGE_ID 
	WHERE A.DQA_BL_STATUS='SKIPPED' AND ISNULL(A.IS_DELETED,'') <> 'Y'
	GROUP BY VOYAGE_ID	
)X
ON V.VOYAGE_ID=X.VOYAGE_ID

--Update the counts in DQA_VOYAGE table
UPDATE D WITH (UPDLOCK)
SET PPMM_CNT=ISNULL(V.PPMM_CNT,0),
	CLEANSED_CNT=ISNULL(V.CLEANSED_CNT,0),
	PENDING_CNT=ISNULL(V.PENDING_CNT,0),
	DELETED_CNT=ISNULL(V.DELETED_CNT,0),
	TOTAL_CNT=ISNULL(V.TOTAL_CNT,0),
	SKIPPED_CNT=ISNULL(V.SKIPPED_CNT,0)	
FROM SCREEN_TEST.DBO.DQA_VOYAGE D JOIN #VOYAGES V
ON V.VOYAGE_ID=D.VOYAGE_ID

/*
--UPDATE STATUS COUNTS IN DQA_VOYAGE
UPDATE SCREEN_TEST.DBO.DQA_VOYAGE WITH (UPDLOCK)   
 SET PPMM_CNT=(  
      SELECT COUNT(ISNULL(T_NBR,0))   
      FROM SCREEN_TEST.DBO.BL_BL A    (NOLOCK)
      WHERE A.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID   
      AND A.DQA_BL_STATUS='AUTOMATED' AND ISNULL(A.IS_DELETED,'') <> 'Y'
     )  

 UPDATE SCREEN_TEST.DBO.DQA_VOYAGE WITH (UPDLOCK)   
 SET CLEANSED_CNT=(  
      SELECT COUNT(ISNULL(T_NBR,0))   
      FROM SCREEN_TEST.DBO.BL_BL A    (NOLOCK)
      WHERE A.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID   
      AND A.DQA_BL_STATUS='CLEANSED' AND ISNULL(A.IS_DELETED,'') <> 'Y'
     )  
  
 UPDATE SCREEN_TEST.DBO.DQA_VOYAGE WITH (UPDLOCK)     
 SET PENDING_CNT=(  
      SELECT COUNT(ISNULL(T_NBR,0))   
      FROM SCREEN_TEST.DBO.BL_BL A    (NOLOCK)
      WHERE A.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID   
      AND A.DQA_BL_STATUS='PENDING' AND ISNULL(A.IS_DELETED,'') <> 'Y'
     )  
  
 UPDATE SCREEN_TEST.DBO.DQA_VOYAGE WITH (UPDLOCK)   
 SET DELETED_CNT=(  
     SELECT COUNT(T_NBR)   
     FROM  SCREEN_TEST.DBO.BL_BL A    (NOLOCK)
     WHERE A.DQA_VOYAGE_ID =DQA_VOYAGE.VOYAGE_ID   
     AND A.IS_DELETED ='Y'  
     )  

 UPDATE SCREEN_TEST.DBO.DQA_VOYAGE WITH (UPDLOCK)      
 SET TOTAL_CNT=(  
     SELECT COUNT(isnull(T_NBR,0)) FROM SCREEN_TEST.DBO.BL_BL A   (NOLOCK) 
     WHERE A.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID  
     )  
 

   UPDATE SCREEN_TEST.DBO.DQA_VOYAGE   WITH (UPDLOCK)   
	SET SKIPPED_CNT=(  
      SELECT COUNT(ISNULL(T_NBR,0))   
      FROM SCREEN_TEST.DBO.BL_BL A  (NOLOCK)  
      WHERE A.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID   
      AND A.DQA_BL_STATUS='SKIPPED' AND ISNULL(A.IS_DELETED,'') <> 'Y'
     )
--Changes by Cognizant, 17-Feb-2010, end
*/

	--Changes by Cognizant, 17-Feb-2010, start

	--Insert into PES_TEMP_BOL_FUZZY_LC table. LCL calculation will be taken care in PES_UPD_STAGING procedure.
	INSERT INTO PES_TEMP_BOL_FUZZY_LC(T_NBR)
	SELECT T_NBR FROM PES_TEMP_BOL_FUZZY WITH (NOLOCK)
	WHERE PROCESS_FLG='Y'	
	and t_nbr not in (SELECT T_NBR FROM PES_TEMP_BOL_FUZZY_LC WITH (NOLOCK))
		
	--Set Consize to 'LC'
	CREATE TABLE #LCL 
		(
			BOL_ID INT,
			CNTR_NBR VARCHAR(14),
			STND_VOYG_ID INT,
			BOL_CNTRZD_FLG CHAR(1),
			CONTAINERCOUNTFORLC INT
		)

		INSERT INTO #LCL(BOL_ID,CNTR_NBR,STND_VOYG_ID,BOL_CNTRZD_FLG,CONTAINERCOUNTFORLC)
		SELECT A.BOL_ID,CNTR_NBR,STND_VOYG_ID,BOL_CNTRZD_FLG,0
		FROM PES.DBO.PES_STG_BOL A WITH (NOLOCK)
		JOIN PES.DBO.PES_STG_CNTR B WITH (NOLOCK)
		ON A.BOL_ID=B.BOL_ID
		JOIN  SCREEN_TEST.DBO.PES_TEMP_BOL_FUZZY_LC T  WITH (NOLOCK)
		ON A.BOL_ID=T.T_NBR
		WHERE A.STND_VOYG_ID IS NOT NULL
		AND BOL_CNTRZD_FLG = 'Y'
		AND (CNTR_NBR NOT LIKE '*#*%' AND ISNULL(CNTR_NBR,'') <> '')

		UPDATE #LCL
		SET CONTAINERCOUNTFORLC =  PES.DBO.pes_udf_GetLCContainerCount(CNTR_NBR,STND_VOYG_ID)

		UPDATE A  WITH (UPDLOCK)   
			SET A.CONSIZE='LC', 
			A.BOL_LCL_FLAG='Y' 
		FROM PES.DBO.PES_STG_BOL A
		JOIN #LCL L
		ON A.BOL_ID=L.BOL_ID
		WHERE ISNULL(CONTAINERCOUNTFORLC,0) > 1

		UPDATE A  WITH (UPDLOCK)   
			SET A.CONSIZE_MOD='LC'
			FROM SCREEN_TEST.DBO.DQA_BL A
		JOIN #LCL L
		ON A.T_NBR=L.BOL_ID
		WHERE ISNULL(CONTAINERCOUNTFORLC,0) > 1

		--DELETE FROM SCREEN_TEST.DBO.PES_TEMP_BOL_FUZZY_LC WHERE T_NBR IN (SELECT BOL_ID FROM #LCL)

		DROP TABLE #LCL

	--Drop all bills from PES_TEMP_BOL_FUZZY table where PROCESS_FLG is 'Y'
	DELETE FROM PES_TEMP_BOL_FUZZY
	WHERE PROCESS_FLG='Y'
	
	--Changes by Cognizant, 17-Feb-2010, start
	DROP TABLE #Voyages
	--Changes by Cognizant, 17-Feb-2010, end
	COMMIT TRANSACTION @TRANNAME  

END TRY  
BEGIN CATCH  
 ROLLBACK TRANSACTION @TRANNAME 
 SET @ERROR_NUMBER=ERROR_NUMBER()  
  SET @ERROR_LINE=ERROR_LINE()  
 SET @ERROR_MESSAGE='Stored Procedure PES_SP_UPD_STD_VOYAGE failed with ERROR DESCRIPTION:  '+ERROR_MESSAGE() 
 SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE  
 EXEC master..xp_cmdshell @CMD   
 SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE  
 EXEC master..xp_cmdshell @CMD   
 SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE  
 EXEC master..xp_cmdshell @CMD  
 SET @CMD = 'ECHO TRANSACTIONS ROLLBACKED'+ ' >> '+ @FILE  
 EXEC master..xp_cmdshell @CMD  
  
 EXEC PES.DBO.PES_SP_EMAIL 'Voyage Creation','Voyage Creation Process Failed',@ERROR_MESSAGE,@ERROR_LINE,@ERROR_NUMBER  
 
 RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG

--Changes by Cognizant, 17-Feb-2010, start
DROP TABLE #Voyages
--Changes by Cognizant, 17-Feb-2010, end

END CATCH  



-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
