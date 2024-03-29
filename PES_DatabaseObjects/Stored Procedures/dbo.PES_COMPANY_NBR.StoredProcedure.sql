/****** Object:  StoredProcedure [dbo].[PES_COMPANY_NBR]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_COMPANY_NBR] @SOURCE_OF_EXECUTION VARCHAR(20)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	BEGIN TRY
		DECLARE @FILE VARCHAR(500),@FILE_NAME VARCHAR(50), @LOADNUMBER NUMERIC(12,0)
		DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),
		@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50),@DATE DATETIME,@TIME INT,@DATE1 DATETIME,@TIME1 INT
		DECLARE @COMP_ID INT,@NAME VARCHAR(150),
		@NAME_NBR VARCHAR(20),@COMPANY_NBR VARCHAR(20)

	
		IF @SOURCE_OF_EXECUTION='RAW_TO_STAGING'
		BEGIN
			SELECT @FILE = PATH FROM PES_CONFIGURATION  WITH (NOLOCK)  WHERE SOURCE='SP_LOG'
			SELECT @FILE_NAME= FILENAME, @LOADNUMBER = LOADNUMBER FROM PES_PROGRESS_STATUS  WITH (NOLOCK)  
			WHERE LOAD_DT=(SELECT MAX(isnull(Load_DT,getdate())) FROM PES_PROGRESS_STATUS  WITH (NOLOCK) )
			SET @FILE='"'+@FILE+@FILE_NAME+'_LOG.TXT'+'"'
			SET @CMD = 'ECHO PROCEDURE PES_COMPANY_NBR FOR RAW_TO_STAGING EXECUTION STARTED' + '>>'+ @FILE
			EXEC MASTER..XP_CMDSHELL @CMD 
		END

		CREATE TABLE #TEMP_PES_REF_COMPANY(
		COMP_ID INT,
		[NAME] VARCHAR(150),
		NAME_NBR VARCHAR(20),
		COMPANY_NBR VARCHAR(20)
		)
	
		INSERT INTO #TEMP_PES_REF_COMPANY(COMP_ID,[NAME])
		(SELECT COMP_ID,[NAME] FROM PES_REF_COMPANY  WITH (NOLOCK)  WHERE COMP_NBR IS NULL)

		--UPDATE NAME_NBR
		UPDATE A WITH (UPDLOCK) SET A.NAME_NBR=SUBSTRING(B.COMP_NBR,1,8) FROM #TEMP_PES_REF_COMPANY A, PES_REF_COMPANY B  WITH (NOLOCK)  WHERE ISNULL(DBO.PES_UDF_REMOVE_SPECIAL_CHARACTERS(A.NAME),'')=ISNULL(DBO.PES_UDF_REMOVE_SPECIAL_CHARACTERS(B.NAME),'')
		--UPDATE A WITH (UPDLOCK) SET A.NAME_NBR=SUBSTRING(B.COMP_NBR,1,8) FROM #TEMP_PES_REF_COMPANY A, PES_LIB_COMPANY B  WITH (NOLOCK)  WHERE ISNULL(DBO.PES_UDF_REMOVE_SPECIAL_CHARACTERS(A.NAME),'')=ISNULL(DBO.PES_UDF_REMOVE_SPECIAL_CHARACTERS(B.NAME),'') AND A.NAME_NBR IS NULL
		

		DECLARE COMP_NBR_CURSOR1 CURSOR FOR 
		SELECT COMP_ID,[NAME],NAME_NBR,COMPANY_NBR FROM #TEMP_PES_REF_COMPANY  WITH (NOLOCK)  WHERE ISNULL(COMPANY_NBR,'')='' OR ISNULL(NAME_NBR,'')=''

		OPEN COMP_NBR_CURSOR1
		--BEGIN FETCHING RECORDS STG_CMD AND STG_BOL
		FETCH NEXT FROM COMP_NBR_CURSOR1 INTO @COMP_ID,@NAME,@NAME_NBR,@COMPANY_NBR
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF ISNULL(@NAME_NBR,'')=''
			BEGIN
				SELECT @COMPANY_NBR=CAST(COMPANY_NAME_NBR AS VARCHAR(20))+'000000' FROM PES_COMPANY_SIMCONF WITH (NOLOCK)  WHERE TASK='NEW_COMPANY'
				UPDATE PES_COMPANY_SIMCONF WITH (UPDLOCK) SET COMPANY_NAME_NBR=COMPANY_NAME_NBR+1 WHERE TASK='NEW_COMPANY'
			END
			ELSE
			BEGIN
				SELECT @COMPANY_NBR=@NAME_NBR+CAST(ADDRESS_NBR AS VARCHAR(20)) FROM PES_COMPANY_SIMCONF WITH (NOLOCK)  WHERE TASK='NEW_COMPANY'
				UPDATE PES_COMPANY_SIMCONF WITH (UPDLOCK) SET ADDRESS_NBR=ADDRESS_NBR-1 WHERE TASK='NEW_COMPANY'
			END

			UPDATE #TEMP_PES_REF_COMPANY WITH (UPDLOCK) SET COMPANY_NBR=@COMPANY_NBR WHERE COMP_ID=@COMP_ID
			FETCH NEXT FROM COMP_NBR_CURSOR1 INTO @COMP_ID,@NAME,@NAME_NBR,@COMPANY_NBR
		END
		CLOSE COMP_NBR_CURSOR1
		DEALLOCATE COMP_NBR_CURSOR1

		--Populate new entries for City, State and Country in the reference tables REF_CITYST and REF_CITYCOUN
		--before updating the Company Number in PES_LIB_NEW_PTY

		--Insertion into REF_CITYST for US Company
--		INSERT INTO [PES].[dbo].[REF_CITYST]
--			   ([MODIFIED_BY]
--			   ,[MODIFIED_DT]
--			   ,[DELETED]
--			   ,[M_CITY]
--			   ,[M_ST])
--		SELECT USER_NAME(),GETDATE(),'N',X.CITY,X.STATE
--		FROM
--		(	
--		  SELECT DISTINCT CITY,STATE
--		  FROM PES_REF_COMPANY  WITH (NOLOCK) 
--		  WHERE ISNUMERIC(COUNTRY)=1 AND CREATED_BY IS NOT NULL AND ISNUMERIC(CREATED_BY)=0
--		  AND COMP_NBR IS NULL
--		  AND ISNULL(CITY,'') <> ''
--		  AND ISNULL(STATE,'') <> ''
--		  AND COUNTRY='100' 
--		)X
--		LEFT JOIN REF_CITYST CS  WITH (NOLOCK) 
--		ON X.CITY=CS.M_CITY
--		AND X.STATE=CS.M_ST
--		WHERE CS.M_CITY IS NULL
--
--		--Insertion into REF_CITYCOUN for Foreign Company

--		INSERT INTO [PES].[dbo].[REF_CITYCOUN]
--			   ([MODIFIED_BY]
--			   ,[MODIFIED_DT]
--			   ,[DELETED]
--			   ,[M_CITY]
--			   ,[M_COUNTRY])
--		SELECT USER_NAME(),GETDATE(),'N',X.CITY,X.COUNTRY
--		FROM
--		(
--		  SELECT DISTINCT CITY,
--		  (
--				SELECT TOP 1 PIERS_COUNTRY 
--				FROM REF_COUNTRY R  WITH (NOLOCK) 
--				WHERE R.JOC_CODE=N.COUNTRY
--		  ) AS COUNTRY
--		  FROM PES_REF_COMPANY N  WITH (NOLOCK) 
--		  WHERE ISNUMERIC(N.COUNTRY)=1 AND CREATED_BY IS NOT NULL AND ISNUMERIC(CREATED_BY)=0
--		  AND COMP_NBR IS NULL
--		  AND ISNULL(CITY,'') <> ''
--		  AND ISNULL(COUNTRY,'') <> ''
--		  AND COUNTRY <>'100' --Not a US company
--		)X
--		LEFT JOIN REF_CITYCOUN CC  WITH (NOLOCK) 
--		ON X.CITY=CC.M_CITY
--		AND X.COUNTRY=CC.M_COUNTRY
--		WHERE CC.M_CITY IS NULL

		--BULK UPDATE ON PES_REF_COMPANY
		UPDATE A WITH (UPDLOCK) SET A.COMP_NBR=B.COMPANY_NBR,A.MODIFIED_DT=GETDATE() 
		FROM PES_REF_COMPANY A,#TEMP_PES_REF_COMPANY B  WITH (NOLOCK)  WHERE A.COMP_ID=B.COMP_ID 

		DROP TABLE #TEMP_PES_REF_COMPANY

		UPDATE PES_REF_COMPANY SET IS_USCOMP=
		CASE COUNTRY WHEN '100' THEN 'Y' ELSE 'N' END,MODIFIED_DT=GETDATE()
		WHERE LTRIM(RTRIM(ISNULL(COUNTRY,'')))<>'' AND ISNULL(IS_USCOMP,'')=''

		IF @SOURCE_OF_EXECUTION='RAW_TO_STAGING'
		BEGIN
		SET @cmd = 'ECHO PROCEDURE PES_PES_COMPANY_NBR FOR RAW_TO_STAGING SUCCESSFULLY	COMPLETED'+' >> '+ @FILE
		EXEC master..xp_cmdshell @CMD
		END
	END TRY

	BEGIN CATCH
		SET @ERROR_NUMBER=ERROR_NUMBER()
		SET @ERROR_LINE=ERROR_LINE()
		SET @ERROR_MESSAGE='STORED PROCEDURE PES_COMPANY_NBR FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
		
		SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE
		EXEC master..xp_cmdshell @CMD 
		SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE
		EXEC master..xp_cmdshell @CMD 
		SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE
		EXEC master..xp_cmdshell @CMD 
		
		RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG
	
	END CATCH

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
