/****** Object:  StoredProcedure [dbo].[PES_BL_CACHE_NEW]    Script Date: 01/03/2013 19:48:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_BL_CACHE_NEW]  
AS
BEGIN

/*
Change History

Changes by Cognizant, 26-Aug-2009, to populate SH_NBR, CH_NBR, NH-NBR and AH_NBR columns 
of BL_CACHE table with group ids from PES_MATCH_PTY table

The purpose of this change is to prevent a party from getting structured if a similar
party has already been structured by a user. This will reduce the number of party structure exceptions
to be corrected in Typist Screen

Cognizant Change, 19-Feb-2010, start
Address Synchronization issues for Arrival Date between BL_CACHE and DQA_VOYAGE
Populate Actual Arrival Date from DQA_VOYAGE into ACT_ARRIVAL_DT column of BL_CACHE

*/

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @TRANNAME VARCHAR(20),@FILE VARCHAR(500),@FILE_NAME VARCHAR(50)
DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),
@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50),@DATE DATETIME,@TIME INT,@TIME1 INT,@TIME2 INT,@TIME3 INT

--Included as per Code Review Comment by Dilip, 9-April-2009. Use Load Number to fetch bills from RAW_BOL table
DECLARE @Load_Number int

SET @TRANNAME = 'MyTransaction'
SELECT @FILE = PATH FROM PES.DBO.PES_CONFIGURATION WITH (NOLOCK)
WHERE SOURCE='SP_LOG'

SELECT @FILE_NAME= FILENAME ,
		@Load_Number = LOADNUMBER
FROM PES.DBO.PES_PROGRESS_STATUS WITH (NOLOCK)
WHERE LOAD_DT=(SELECT MAX(Load_DT) FROM PES.DBO.PES_PROGRESS_STATUS WITH (NOLOCK))

SET @FILE='"'+@FILE+@FILE_NAME+'_LOG.TXT'+'"'

--Timestamp added temporarily to check performance of various parts of this procedure. 
SET @DATE=GETDATE()

SET @CMD = 'ECHO PROCEDURE PES_BL_CACHE STARTED AT  '+ ''''+ CONVERT(VARCHAR(56),GETDATE(),9)+'''' + '>>'+ @FILE
EXEC MASTER..XP_CMDSHELL @CMD 

--Declare Variables
DECLARE @BOL_ID INT
DECLARE @CMDIDS VARCHAR(100)
DECLARE @CID VARCHAR(100)
 DECLARE @CMD_ID INT
 DECLARE @CMD_ID1 INT
 DECLARE @Commodity_Desc VARCHAR(MAX)
 DECLARE @COMMODITY VARCHAR(MAX)
 DECLARE @MAN_ID INT
 DECLARE @MAN VARCHAR(1024)
 DECLARE @CHKCNT INT

CREATE TABLE #TEMP_BLCACHE
(
	[DIR] [varchar](1),
	[T_NBR] [numeric](10, 0),
	[BL_NBR] [varchar](16),
	[SCAC] [varchar](4),
	[VESSEL_NAME] [varchar](25) ,
	[VOYAGE_NBR] [varchar](5),
	[US_PORT] [nvarchar](35),
	[FOREIGN_PORT] [nvarchar](35),
	[MANIFEST_QTY] [numeric](11, 0),
	[MANIFEST_UNIT] [varchar](5),
	[WGT] [numeric](16, 0),
	[WGT_UNIT] [varchar](2),	
	[FINAL_DEST_CITY] [varchar](60),
	[FINAL_DEST_STATE] [varchar](2),
	[FINAL_DEST_CNTRY] [varchar](35),
	[SHIPPER] [varchar](500),
	[CONSIGNEE] [varchar](500),
	[NOTIFY] [varchar](500),
	[ALSONOTIFY] [varchar](500),
	[COMMODITY] [nvarchar](max),
	[MARKS] [nvarchar](max),
	[DQA_BL_STATUS] [varchar](10),
	[DQA_OWNER_ID] [varchar](10),	
	[ACT_ARRIVAL_DT] [datetime],
	[SH_NBR] [numeric](10, 0),
	[CH_NBR] [numeric](10, 0),
	[NH_NBR] [numeric](10, 0),	
	--Cognizant Change-26 Aug 2009, Start
	[AH_NBR] [numeric](10, 0),	
	--Cognizant Change-26 Aug 2009, End
	[DQA_VOYAGE_ID] [numeric](12, 0),
	[PRECARRIER] [varchar](35)
)

--Populate all bills with uncoded commodity exceptions into a temporary table
SELECT DISTINCT BOL_ID INTO #TEMP_UNCODEDCMD
FROM PES.DBO.HCS_COMMODITY WITH (NOLOCK) 
WHERE  DQA_CMDS_STATUS='UNCODED' 
AND BOL_ID  IN (SELECT BOL_ID FROM PES.DBO.RAW_BOL WITH (NOLOCK) WHERE Load_Number = @Load_Number)


INSERT INTO #TEMP_BLCACHE(
	[DIR],
	[T_NBR],
	[BL_NBR],
	[SCAC],
	[VESSEL_NAME],
	[VOYAGE_NBR],
	[US_PORT],
	[FOREIGN_PORT],
	[MANIFEST_QTY],
	[MANIFEST_UNIT],
	[WGT],
	[WGT_UNIT],	
	[FINAL_DEST_CITY],
	[FINAL_DEST_STATE],
	[FINAL_DEST_CNTRY],
	[SHIPPER],
	[CONSIGNEE],
	[NOTIFY],
	[ALSONOTIFY],
	[COMMODITY],
	[MARKS],
	[DQA_BL_STATUS],
	[DQA_OWNER_ID],	
	[ACT_ARRIVAL_DT],
	[SH_NBR],
	[CH_NBR],
	[NH_NBR],	
--Cognizant Change-26 Aug 2009, Start
	[AH_NBR],
--Cognizant Change-26 Aug 2009, End
	[DQA_VOYAGE_ID],
	[PRECARRIER]
)

	SELECT	R.ImpExp as DIR,
		A.BOL_ID as T_NBR,
		R.BOL_Number as BL_NBR,

		--Carrier Code
		-- As per Code Review comment by Dilip, 9-Apr-2009, use Carrier_Code from RAW_BOL.
		R.Carrier_Code as SCAC,
		--SUBSTRING(LTRIM(R.BOL_Number),1,4) as SCAC,

		--Vessel Name
		(
			--Changes on 25-May-2009. Directly use VESSEL_NAME from PES_STG_BOL			
			--SELECT isnull(dbo.pes_udf_GetVesselName(B.VESSEL_REF_ID),R.Vessel_Name)
			--SELECT ISNULL(B.VESSEL_NAME,'')
            SELECT ISNULL(substring(B.VESSEL_NAME,1,25),'')
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) AS VESSEL_NAME,

		R.Voyage_Number as VOYAGE_NBR,

		--US_PORT
		(
			--Changes on 25-May-2009. Directly use PORT_OF_DEPARTURE from PES_STG_BOL
			--SELECT isnull(dbo.pes_udf_GetPortName(B.PORT_DEPART_REF_ID),R.US_DIST_PORT)
			--SELECT isnull(dbo.pes_udf_GetPortName(B.PORT_DEPART_REF_ID),ISNULL(R.PORT_OF_DEPARTURE,''))
			SELECT ISNULL(B.PORT_OF_DEPARTURE,'')
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) AS US_PORT,

		--Foreign Port
		(
			--Changes on 25-May-2009. Directly use PORT_OF_DESTINATION from PES_STG_BOL
			--SELECT isnull(dbo.pes_udf_GetPortName(B.PORT_ARRIVE_REF_ID),R.FOREIGN_PORT)
			--SELECT isnull(dbo.pes_udf_GetPortName(B.PORT_ARRIVE_REF_ID),ISNULL(R.PORT_OF_DESTINATION,''))
			SELECT ISNULL(B.PORT_OF_DESTINATION,'')
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) AS FOREIGN_PORT,
		
		R.MFEST_Quantity as MANIFEST_QTY,
		R.MFEST_Units as MANIFEST_UNIT,
		R.Weight as WGT,
		R.Weight_Units as WGT_UNIT,		

		--FINAL_DEST_CITY,
		(
			SELECT B.ORG_DEST_CITY
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) AS FINAL_DEST_CITY,

		--FINAL_DEST_STATE,
		(
			SELECT dbo.pes_udf_Get_Orig_State_Country(B.ORG_DEST_CD,B.ORG_DEST_ST,'STATE')
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) AS FINAL_DEST_STATE,

		--FINAL_DEST_CNTRY
		(
			SELECT dbo.pes_udf_Get_Orig_State_Country(B.ORG_DEST_CD,B.ORG_DEST_ST,'COUNTRY')
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) AS FINAL_DEST_CNTRY,		
		null AS SHIPPER,		
		null AS CONSIGNEE ,		
		null AS NOTIFY,		
		null AS ALSONOTIFY,
		null as COMMODITY,
		null as MARKS,
		'PENDING'as DQA_BL_STATUS,
		'UNASSIGNED' as DQA_OWNER_ID,
		--Cognizant Change-21 APR 2010, Start
		(
			SELECT B.Vdate
			FROM PES.DBO.PES_STG_BOL B WITH (NOLOCK)				
			where B.BOL_ID = R.BOL_ID
		) as ACT_ARRIVAL_DT,
		--Cognizant Change-21 APR 2010, End
		--Cognizant Change-26 Aug 2009, Start
		null as SH_NBR,
		null as CH_NBR,
		null as NH_NBR,
		null as AH_NBR,
		--Cognizant Change-26 Aug 2009, End
		2 as DQA_VOYAGE_ID,
		R.PLACE_OF_RECEIPT as PRECARRIER
					
	FROM PES.DBO.RAW_BOL R WITH (NOLOCK) JOIN
	(
		--Commodity Uncoded Exceptions in current load
		SELECT DISTINCT BOL_ID 
		FROM PES.DBO.HCS_COMMODITY WITH (NOLOCK) 
		WHERE  DQA_CMDS_STATUS='UNCODED' 
		AND BOL_ID IN (SELECT BOL_ID FROM PES.DBO.RAW_BOL WITH (NOLOCK) WHERE Load_Number = @Load_Number)

		UNION 

		--Party Structure Exceptions in current load
		SELECT DISTINCT BOL_ID FROM PES.DBO.PES_TRANSACTIONS_EXCEPTIONS_PTY  WITH (NOLOCK) 
		WHERE STATUS = 'PENDING' 
		AND BOL_ID IN(SELECT BOL_ID FROM PES.DBO.RAW_BOL WITH (NOLOCK) WHERE Load_Number = @Load_Number)
	)A 	
	ON R.BOL_ID=A.BOL_ID	


--Update #TEMP_BLCACHE for Company Information
UPDATE #TEMP_BLCACHE
SET SHIPPER = CASE [DIR] when 'I' then dbo.pes_udf_Get_CompanyInformation(T_NBR,'S') else dbo.pes_udf_Get_CompanyInformation(T_NBR,'C') end ,
CONSIGNEE =CASE [DIR] when 'I' then dbo.pes_udf_Get_CompanyInformation(T_NBR,'C') else dbo.pes_udf_Get_CompanyInformation(T_NBR,'S') end,
NOTIFY = dbo.pes_udf_Get_CompanyInformation(T_NBR,'N'),
ALSONOTIFY=dbo.pes_udf_Get_CompanyInformation(T_NBR,'A')

--Cognizant Change-26 Aug 2009, Start
--Update #TEMP_BLCACHE for Company Match Id Information
UPDATE #TEMP_BLCACHE
SET SH_NBR = CASE [DIR] when 'I' then dbo.pes_udf_Get_CompanyMatchInfo(T_NBR,'S') else dbo.pes_udf_Get_CompanyMatchInfo(T_NBR,'C') end ,
CH_NBR =CASE [DIR] when 'I' then dbo.pes_udf_Get_CompanyMatchInfo(T_NBR,'C') else dbo.pes_udf_Get_CompanyMatchInfo(T_NBR,'S') end,
NH_NBR = dbo.pes_udf_Get_CompanyMatchInfo(T_NBR,'N'),
AH_NBR=dbo.pes_udf_Get_CompanyMatchInfo(T_NBR,'A')
--Cognizant Change-26 Aug 2009, End

--Cognizant Change, 19-Feb-2010, start
--Synchronization issues for Arrival Date between BL_CACHE and DQA_VOYAGE
UPDATE B 
SET ACT_ARRIVAL_DT = V.ACT_ARRIVAL_DT
from #TEMP_BLCACHE b  JOIN BL_BL A WITH (NOLOCK)
ON B.T_NBR=A.T_NBR
JOIN DQA_VOYAGE V WITH (NOLOCK) 
ON V.VOYAGE_ID=A.DQA_VOYAGE_ID

--Cognizant Change, 19-Feb-2010, start

--Company Information Population into bl_cache
--Timestamp added temporarily to check performance of various parts of this procedure. 
SET @TIME= DATEDIFF(N,@DATE,GETDATE())
SET @TIME3= DATEDIFF(S,@DATE,GETDATE())

BEGIN TRANSACTION @TRANNAME
BEGIN TRY
	--Cognizant Change-26 Aug 2009, Start
	-- Insert into BL_CACHE table
	INSERT INTO [Screen_Test].[dbo].[BL_CACHE]
			   ([DIR],[T_NBR],[BL_NBR],[SCAC]
			   ,[VESSEL_NAME],[VOYAGE_NBR],[US_PORT],[FOREIGN_PORT]
			   ,[MANIFEST_QTY],[MANIFEST_UNIT],[WGT],[WGT_UNIT]
			   ,[FINAL_DEST_CITY],[FINAL_DEST_STATE],[FINAL_DEST_CNTRY]
			   ,[SHIPPER],[CONSIGNEE],[NOTIFY],[ALSONOTIFY],[COMMODITY]
			   ,[MARKS],[DQA_BL_STATUS],[DQA_OWNER_ID]
			   ,[ACT_ARRIVAL_DT],[SH_NBR],[CH_NBR],[NH_NBR],[AH_NBR]
			   ,[DQA_VOYAGE_ID],PRECARRIER)
	select [DIR],[T_NBR],[BL_NBR],[SCAC]
			   ,[VESSEL_NAME],[VOYAGE_NBR],[US_PORT],[FOREIGN_PORT]
			   ,[MANIFEST_QTY],[MANIFEST_UNIT],[WGT],[WGT_UNIT]
			   ,[FINAL_DEST_CITY],[FINAL_DEST_STATE],[FINAL_DEST_CNTRY]
			   ,[SHIPPER],[CONSIGNEE],[NOTIFY],[ALSONOTIFY],[COMMODITY]
			   ,[MARKS],[DQA_BL_STATUS],[DQA_OWNER_ID]
			   ,[ACT_ARRIVAL_DT],[SH_NBR],[CH_NBR],[NH_NBR],[AH_NBR]
			   ,[DQA_VOYAGE_ID],PRECARRIER
	from #TEMP_BLCACHE
	--Cognizant Change-26 Aug 2009, End
	
	SET @cmd = 'ECHO COMPANY INFORMATION LOADED  SUCCESSFULLY  TO BL_CACHE TABLE IN : '+ CAST(@TIME AS VARCHAR(20)) +'Minutes '+ ' >> '+ @FILE
		EXEC master..xp_cmdshell @CMD
	SET @cmd = 'ECHO COMPANY INFORMATION LOADED  SUCCESSFULLY  TO BL_CACHE TABLE AT : '+ ''''+ CONVERT(VARCHAR(56),GETDATE(),9)+''''  + ' >> '+ @FILE
		EXEC master..xp_cmdshell @CMD

	----------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------UPDATE COMMODITY INFORMATION-------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------

	--Iterate through #TEMP_BOLID table and call PES_PROCCMD stored procedure to update [COMMODITY],[MARKS] and [DQA_BL_STATUS] values
	declare @ins_bol_id numeric(9,0)

	DECLARE CS_BLCACHE_INS CURSOR FOR
	SELECT BOL_ID FROM #TEMP_UNCODEDCMD 

	OPEN CS_BLCACHE_INS
	FETCH NEXT FROM CS_BLCACHE_INS INTO @ins_bol_id

	WHILE @@FETCH_STATUS=0
	BEGIN
		EXEC PES_PROCCMD @ins_bol_id
	FETCH NEXT FROM CS_BLCACHE_INS INTO @ins_bol_id
	END

	CLOSE CS_BLCACHE_INS
	DEALLOCATE CS_BLCACHE_INS
	
	--Timestamp added temporarily to check performance of various parts of this procedure. 
	SET @TIME1= DATEDIFF(S,@DATE,GETDATE())
	SET @TIME2=@TIME1-@TIME3
	--COMMITTING THE TRANSACTIONS IF NO ERROR OCCURRED
	COMMIT TRANSACTION @TRANNAME
	SET @cmd = 'ECHO COMMODITY RECORDS LOADED SUCCESSFULLY TO BL_CACHE TABLE IN : '+ CAST(@TIME2 AS VARCHAR(20)) + 'Seconds' + ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD

	SET @cmd = 'ECHO COMMODITY RECORDS LOADED SUCCESSFULLY TO BL_CACHE TABLE AT :  '+ ''''+ CONVERT(VARCHAR(56),GETDATE(),9)+''''+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD

	--Drop Temporary Tables
	DROP TABLE #TEMP_BLCACHE
	DROP TABLE #TEMP_UNCODEDCMD	
END TRY
BEGIN CATCH
	SET @ERROR_NUMBER=ERROR_NUMBER()
	SET @ERROR_LINE=ERROR_LINE()
	SET @ERROR_MESSAGE='STORED PROCEDURE PES_BL_CACHE FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
	
	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
    SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 

	
	SET @CMD = 'ECHO TRANSACTIONS ROLLBACKED'+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG

	ROLLBACK TRANSACTION @TRANNAME
END CATCH


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
