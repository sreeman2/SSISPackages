/****** Object:  StoredProcedure [dbo].[usp_PES_PopulateRawTEUs_Old]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Calculate Raw TEUs

Parameters:
 @VMonth int - e.g. 201103 for March 2011. If NULL, it will work on 'Production Month'

Input: PES.dbo.PES_STG_BOL, PES.dbo.PES_STG_CNTR, PES.dbo.REF_CONTAINER_ISO
Intermediate: TEMP_PES.dbo.RawTEU_Bol, TEMP_PES.dbo.RawTEU_Container
Final Output: PESDW.PESDW.dbo.PES_DW_BOL_Extension, [10.31.18.147]/SQLInstance02.Piers.dbo.MAIN_ACTIVE_BOL_Extension

1. Get incremental BOLs
2. Calculate Master_BOL_ID for all House BOLs
3. Get incremental Containers, and length from ref container table
4. For each Container, calculate how many BOLs it is shared on (OnNBols)
5. For each Container, calculate TEU based on ContainerLength and OnNBols
6. For each Bol, calculate TEU by adding up TEUs for all Containers on the Bol
  All of above use tables TEMP_PES.dbo.RawTEU_Bol & TEMP_PES.dbo.RawTEU_Container
7. Populate Raw TEU to PESDW
  Above uses table PESDW.dbo.PES_DW_BOL_Extension

Input: PES.dbo.PES_STG_BOL, PES.dbo.PES_STG_CNTR, PES.dbo.REF_CONTAINER_ISO
Intermediate: TEMP_PES.dbo.RawTEU_Bol, TEMP_PES.dbo.RawTEU_Container
Final Output: PESDW.PESDW.dbo.PES_DW_BOL_Extension, [10.31.18.147]/SQLInstance02.Piers.dbo.MAIN_ACTIVE_BOL_Extension

Usage: EXEC dbo.usp_PES_PopulateRawTEUs @VMonth=201106
Usage: EXEC dbo.usp_PES_PopulateRawTEUs
*/
CREATE PROCEDURE [dbo].[usp_PES_PopulateRawTEUs_Old]
	@VMonth int = NULL -- If NULL, uses 'Production Month'
AS
BEGIN

IF @VMonth IS NULL
BEGIN
	-- Get current Production Month
	--SELECT * FROM SCREEN_TEST.dbo.DQA_PROD_MONTH
	SELECT @VMonth = YEAR(START_DT)*100 + MONTH(START_DT) FROM SCREEN_TEST.dbo.DQA_PROD_MONTH
END
PRINT '@VMonth = ' + LTRIM(RTRIM(STR(@VMonth)))

-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@VMonth=' + LTRIM(RTRIM(STR(@VMonth)))
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @StartTime datetime
SET @StartTime = getdate()

-- 1. Get all BOLs
INSERT INTO TEMP_PES.dbo.RawTEU_Bol
SELECT --COUNT(*)
  psb.BOL_DIRECTION As Direction
 ,YEAR(psb.VDATE)*100+MONTH(psb.VDATE) As VMonth
 ,psb.BOL_ID
 ,psb.STND_VOYG_ID As VoyageId
 ,ISNULL(psb.MST_BOL_TYPE,'') As BillType
 ,psb.BOL_NTERP_STD_WGT As WeightInKilos
 ,NULL As TEU
 ,psb.BOL_NBR
 ,SUBSTRING(psb.BOL_MST_BOL_DATA,42,16) As Master_BOL_NBR
 ,NULL As Master_BOL_ID
 ,getdate() As ModifiedDate
 FROM PES.dbo.PES_STG_BOL psb WITH (NOLOCK)
WHERE NOT EXISTS (SELECT 1 FROM TEMP_PES.dbo.RawTEU_Bol rtb WITH (NOLOCK) WHERE rtb.BOL_ID = psb.BOL_ID)

-- 1b. Update any NULL VoyageIds that are now assigned
--SELECT COUNT(*) FROM TEMP_PES.dbo.RawTEU_Bol rtb WITH (NOLOCK) WHERE rtb.VoyageId IS NULL
--134219
--SELECT COUNT(*) FROM TEMP_PES.dbo.RawTEU_Bol rtb WITH (NOLOCK) WHERE rtb.TEU IS NULL
--1102048
UPDATE rtb SET
  rtb.VoyageId = psb.STND_VOYG_ID
 ,ModifiedDate = getdate()
--SELECT TOP 100 rtb.VoyageId, psb.STND_VOYG_ID, rtb.ModifiedDate, psb.MODIFY_DATE, rtb.*--,psb.* --57122
--SELECT DISTINCT psb.STND_VOYG_ID --2663, pasted below
FROM TEMP_PES.dbo.RawTEU_Bol rtb WITH (NOLOCK)
JOIN PES.dbo.PES_STG_BOL psb
 ON psb.BOL_ID = rtb.BOL_ID AND psb.STND_VOYG_ID IS NOT NULL
WHERE rtb.VoyageId IS NULL
--(57122 row(s) affected)

-- 2. Calculate Master_BOL_ID for all House BOLs
-- 2a. Get the BOL_ID to Master_BOL_ID match
--     Look for Master BOL_NBR, where:
--       direction is Import
--       bill type is Master
--       vdate is at most 1 month before or after the house bill
SELECT
 rtbH.BOL_ID
,(SELECT TOP 1 rtbM.BOL_ID
   FROM TEMP_PES.dbo.RawTEU_Bol rtbM WITH (NOLOCK) 
  WHERE rtbH.Master_BOL_NBR = rtbM.BOL_NBR
   AND rtbM.BillType = 'M'
   AND rtbM.Direction = 'I'
   AND rtbM.VMonth BETWEEN rtbH.VMonth-1 AND rtbH.VMonth+1
  ) As Master_BOL_ID
INTO #tmpMapHouseToMaster
FROM TEMP_PES.dbo.RawTEU_Bol rtbH WITH (NOLOCK)
WHERE rtbH.BillType = 'H'
 AND rtbH.Direction = 'I'
 AND rtbH.Master_BOL_ID IS NULL
--SELECT * FROM #tmpMapHouseToMaster
-- 2b. No need to update where match not found
DELETE FROM #tmpMapHouseToMaster WHERE Master_BOL_ID IS NULL
-- 2c. Update BOL_ID to Master_BOL_ID mapping
UPDATE rtbH SET
  rtbH.Master_BOL_ID = t.Master_BOL_ID
 ,ModifiedDate = getdate()
FROM TEMP_PES.dbo.RawTEU_Bol rtbH WITH (NOLOCK)
JOIN #tmpMapHouseToMaster t
 ON t.BOL_ID = rtbH.BOL_ID
 
-- 3. Get all Containers
INSERT INTO TEMP_PES.dbo.RawTEU_Container
SELECT
  psc.BOL_ID,psc.CNTR_NBR As ContainerNumber
 ,ISNULL(rci.ContainerLength,30) As ContainerLength
 ,1 As OnNBols, NULL As TEU
 FROM PES.dbo.PES_STG_CNTR psc WITH (NOLOCK)
JOIN PES.dbo.REF_CONTAINER_ISO rci WITH (NOLOCK)
 ON rci.ContainerNumber = psc.CNTR_NBR
WHERE NOT EXISTS (SELECT 1 FROM TEMP_PES.dbo.RawTEU_Container rtb WITH (NOLOCK) WHERE rtb.BOL_ID = psc.BOL_ID)

-- Only for testing
--DECLARE @VMonth int
--SET @VMonth = 201104

--DROP TABLE #tmp_VoyageId_Workload
--SELECT COUNT(*) FROM #tmp_VoyageId_Workload
--SELECT * FROM #tmp_VoyageId_Workload

-- Get all Voyages that need to be worked on
;WITH tmp_VoyageId_WorkLoad As (
	-- Get all voyages for the month
	SELECT DISTINCT(VOYAGE_ID) As VoyageId
	 FROM SCREEN_TEST.dbo.DQA_VOYAGE  WITH (NOLOCK) 
	WHERE YEAR(EST_ARRIVAL_DT)*100+MONTH(EST_ARRIVAL_DT)=@VMonth
	 OR   YEAR(ACT_ARRIVAL_DT)*100+MONTH(ACT_ARRIVAL_DT)=@VMonth
	UNION
	-- Get all voyages with uncalculated container TEUs
	SELECT DISTINCT(VoyageId) As VoyageId
	 FROM TEMP_PES.dbo.RawTEU_Bol WITH (NOLOCK)
	WHERE BOL_ID IN (
		SELECT BOL_ID
		 FROM TEMP_PES.dbo.RawTEU_Container WITH (NOLOCK)
		WHERE TEU IS NULL
	 )
	 AND VoyageId IS NOT NULL
)
SELECT DISTINCT(VoyageId) As VoyageId
INTO #tmp_VoyageId_Workload
FROM tmp_VoyageId_WorkLoad
ORDER BY VoyageId 

DECLARE db_cursor CURSOR FOR 
SELECT DISTINCT VoyageId
 FROM #tmp_VoyageId_Workload 
ORDER BY VoyageId 

CREATE TABLE #tmp_RawTEU_ContainerShared (
	 VoyageId			int
	,BillType			varchar(1)
	,ContainerNumber	varchar(14)
	,OnNBols			int
)

DECLARE @VoyageId int
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @VoyageId  

WHILE @@FETCH_STATUS = 0  
BEGIN
	PRINT '@VoyageId = ' + LTRIM(RTRIM(STR(@VoyageId)))

-- 4. For each Container, calculate how many BOLs it is shared on (OnNBols)
	INSERT INTO #tmp_RawTEU_ContainerShared
	SELECT tb1.VoyageId,tb1.BillType,tc1.ContainerNumber,COUNT(DISTINCT tc2.BOL_ID) As OnNBols -- *
	--INTO #tmp_RawTEU_ContainerShared
	 FROM TEMP_PES.dbo.RawTEU_Bol tb1 WITH (NOLOCK)
	JOIN TEMP_PES.dbo.RawTEU_Bol tb2 WITH (NOLOCK)
	 ON tb1.BillType = tb2.BillType -- Match Master to Master, House to House, Regular to Regular ONLY
	  AND tb1.VoyageId = tb2.VoyageId -- Match BOLs on the same voyage
	  AND tb1.BOL_ID != tb2.BOL_ID
	JOIN TEMP_PES.dbo.RawTEU_Container tc1 WITH (NOLOCK)
	 ON tb1.BOL_ID = tc1.BOL_ID
	JOIN TEMP_PES.dbo.RawTEU_Container tc2 WITH (NOLOCK)
	 ON tb2.BOL_ID = tc2.BOL_ID
	WHERE tc1.ContainerNumber = tc2.ContainerNumber
	 AND tb1.VoyageId = @VoyageId
	 AND tb2.VoyageId = @VoyageId
	GROUP BY tb1.VoyageId,tb1.BillType,tc1.ContainerNumber

	FETCH NEXT FROM db_cursor INTO @VoyageId  
END  

CLOSE db_cursor  
DEALLOCATE db_cursor

--SELECT * FROM #tmp_RawTEU_ContainerShared

--SELECT tc.*, tcs.*
UPDATE tc SET tc.OnNBols = tcs.OnNBols
FROM TEMP_PES.dbo.RawTEU_Container tc
JOIN TEMP_PES.dbo.RawTEU_Bol tb
 ON tb.BOL_ID = tc.BOL_ID
JOIN #tmp_RawTEU_ContainerShared tcs
 ON tcs.ContainerNumber = tc.ContainerNumber
  AND tcs.VoyageId = tb.VoyageId
  AND tcs.BillType = tb.BillType
--  AND tcs.OnNBols != tc.OnNBols -- Update only if value is going to change
--WHERE tb.VoyageId = @VoyageId

DROP TABLE #tmp_RawTEU_ContainerShared

-- 5. For each Container, calculate TEUs based on ContainerLength and OnNBols
UPDATE TEMP_PES.dbo.RawTEU_Container
 SET TEU = ContainerLength*1.0/20.0/OnNBols*1.0
WHERE BOL_ID IN (
	SELECT BOL_ID
	 FROM TEMP_PES.dbo.RawTEU_Bol  WITH (NOLOCK) 
	WHERE VoyageId IN (SELECT VoyageId FROM #tmp_VoyageId_Workload)
)

-- 6. For each Bol, calculate TEUs by adding up TEUs for all Containers on the Bol
;WITH tmp_Bol_TEU As (
	SELECT tb.BOL_ID, SUM(tc.TEU) As TEU
	 FROM TEMP_PES.dbo.RawTEU_Bol tb
	JOIN TEMP_PES.dbo.RawTEU_Container tc
	 ON tb.BOL_ID = tc.BOL_ID
	WHERE tb.VoyageId IN (SELECT VoyageId FROM #tmp_VoyageId_Workload)
	GROUP BY tb.BOL_ID
)
UPDATE tb
 SET tb.TEU = tbT.TEU
,ModifiedDate = getdate()
 FROM TEMP_PES.dbo.RawTEU_Bol tb
JOIN tmp_Bol_TEU tbT
 ON tb.BOL_ID = tbT.BOL_ID
  AND (tb.TEU IS NULL OR tb.TEU != tbT.TEU) -- No need to update if the value hasn't changed

-- 7. Populate Raw TEUs to PESDW
-- 7a. Insert records that do not exist
INSERT INTO PESDW.PESDW.dbo.PES_DW_BOL_Extension
 (BOL_ID,RawTEU,ModifiedDate)
SELECT rtb.BOL_ID,rtb.TEU,getdate()
--SELECT COUNT(*)
 FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
WHERE NOT EXISTS (SELECT 1 FROM PESDW.PESDW.dbo.PES_DW_BOL_Extension pdbe  WITH (NOLOCK)  WHERE pdbe.BOL_ID = rtb.BOL_ID)
--7b. Update records that already exist, but have been modified since... (and TEU value has changed)
UPDATE pdbe SET
 RawTEU = rtb.TEU
,ModifiedDate = getdate()
--SELECT COUNT(*)
 FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
JOIN PESDW.PESDW.dbo.PES_DW_BOL_Extension pdbe  WITH (NOLOCK) 
 ON pdbe.BOL_ID = rtb.BOL_ID -- already exists
  AND rtb.ModifiedDate > pdbe.ModifiedDate -- has been modified since
  AND ((pdbe.RawTEU IS NULL AND rtb.TEU IS NOT NULL) OR pdbe.RawTEU != rtb.TEU) -- TEU value has changed
----6,157,286
--SELECT COUNT(*) FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
----19,994,182
--SELECT COUNT(*) FROM PESDW.PESDW.dbo.PES_DW_BOL_Extension pdbe  WITH (NOLOCK) 
----19,994,182
--SELECT YEAR(rtb.ModifiedDate)*10000+MONTH(rtb.ModifiedDate)*100+DAY(rtb.ModifiedDate) As ModDate,VMonth,BillType, COUNT(*)
-- FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
--GROUP BY YEAR(rtb.ModifiedDate)*10000+MONTH(rtb.ModifiedDate)*100+DAY(rtb.ModifiedDate),BillType,VMonth
--ORDER BY 1 DESC,2,3

-- 8. Send out notification email
DECLARE @NEWLINE char(2)
SET @NEWLINE = CHAR(13) + CHAR(10)

DECLARE @Message varchar(MAX)
SET @Message = 'PES PopulateRawTEUs completed.' + @NEWLINE
+ 'VMonth = ' + LTRIM(RTRIM(STR(@VMonth))) + @NEWLINE
+ 'Start Time = ' + CAST(@StartTime As varchar(20)) + @NEWLINE
+ 'End Time = ' + CAST(getdate() As varchar(20)) + @NEWLINE
+ '' + @NEWLINE
+ '---------------------------' + @NEWLINE
+ 'usp_PES_PopulateRawTEUs' + @NEWLINE
+ '---------------------------'

DECLARE @SendEmailOutput varchar(MAX), @SendEmailSuccess bit
EXEC PES.dbo.usp_SendEmail
  @To		= 'HDesai@joc.com;AAwasthi@piers.com;SKasi@piers.com'
 ,@From		= 'PIERS-NoReply@piers.com'
 ,@Subject	= 'PES Raw TEU completed'
 ,@Body		= @Message
 ,@Success	= @SendEmailSuccess OUT
 ,@Output	= @SendEmailOutput OUT
SELECT @SendEmailSuccess, @SendEmailOutput

-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END

/*
--SELECT TOP 100 * FROM TEMP_PES.dbo.RawTEU_Bol  WITH (NOLOCK)  ORDER BY 1
--SELECT TOP 100 * FROM TEMP_PES.dbo.RawTEU_Container  WITH (NOLOCK)  ORDER BY 1,2

SELECT Direction,VMonth,BillType, COUNT(BOL_ID) As BolCount, SUM(TEU) As TEU
 FROM TEMP_PES.dbo.RawTEU_Bol  WITH (NOLOCK) 
WHERE VMonth BETWEEN 201001 AND 201103
GROUP BY Direction,VMonth,BillType
ORDER BY Direction,VMonth,BillType

SELECT rtb.Direction,rtb.VMonth,rtb.BillType,psb.BOL_STATUS As BolStatus, COUNT(rtb.BOL_ID) As BolCount, SUM(rtb.TEU) As RawTEU, SUM(psb.BOL_TEU) As BolTEU
 FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
JOIN PES.dbo.PES_STG_BOL psb  WITH (NOLOCK) 
 ON psb.BOL_ID = rtb.BOL_ID
WHERE rtb.VMonth = 201103 --BETWEEN 201001 AND 201103
 AND rtb.Direction='I'
 AND psb.IS_DELETED IS NULL
GROUP BY rtb.Direction,rtb.VMonth,rtb.BillType,psb.BOL_STATUS
ORDER BY rtb.Direction,rtb.VMonth,rtb.BillType,psb.BOL_STATUS

-- Summary By Dir, Month, BillType, BolStatus
SELECT rtb.Direction,rtb.VMonth,rtb.BillType,psb.BOL_STATUS As BolStatus, COUNT(rtb.BOL_ID) As BolCount, SUM(rtb.TEU) As RawTEU, SUM(psb.BOL_TEU) As BolTEU
 FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
JOIN PES.dbo.PES_STG_BOL psb  WITH (NOLOCK) 
 ON psb.BOL_ID = rtb.BOL_ID AND psb.IS_DELETED IS NULL
JOIN SCREEN_TEST.dbo.DQA_Voyage dv  WITH (NOLOCK) 
 ON rtb.VoyageId = dv.VOYAGE_ID AND dv.VOYAGE_STATUS = 'Available'
WHERE 
 ( rtb.Direction='E' OR 
   (rtb.Direction='I' AND (rtb.BillType IN ('','M') OR (rtb.BillType = 'H' AND rtb.Master_BOL_ID IS NULL)))
 )
 AND rtb.VMonth = 201103 -- BETWEEN 201001 AND 201103 -- >= 201001
GROUP BY rtb.Direction,rtb.VMonth,rtb.BillType,psb.BOL_STATUS
ORDER BY rtb.Direction,rtb.VMonth,rtb.BillType,psb.BOL_STATUS

-- Summary By Dir, Month, BillType
SELECT rtb.Direction,rtb.VMonth,rtb.BillType, COUNT(rtb.BOL_ID) As BolCount, SUM(rtb.TEU) As RawTEU, SUM(psb.BOL_TEU) As BolTEU
 FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
JOIN PES.dbo.PES_STG_BOL psb  WITH (NOLOCK) 
 ON psb.BOL_ID = rtb.BOL_ID AND psb.IS_DELETED IS NULL
JOIN SCREEN_TEST.dbo.DQA_Voyage dv  WITH (NOLOCK) 
 ON rtb.VoyageId = dv.VOYAGE_ID AND dv.VOYAGE_STATUS = 'Available'
WHERE 
 ( rtb.Direction='E' OR 
   (rtb.Direction='I' AND (rtb.BillType IN ('','M') OR (rtb.BillType = 'H' AND rtb.Master_BOL_ID IS NULL)))
 )
 AND rtb.VMonth = 201103 -- BETWEEN 201001 AND 201103 -- >= 201001
GROUP BY rtb.Direction,rtb.VMonth,rtb.BillType
ORDER BY rtb.Direction,rtb.VMonth,rtb.BillType

-- Summary By Dir, Month
SELECT rtb.Direction,rtb.VMonth, COUNT(rtb.BOL_ID) As BolCount, SUM(rtb.TEU) As RawTEU, SUM(psb.BOL_TEU) As BolTEU
 FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK) 
JOIN PES.dbo.PES_STG_BOL psb  WITH (NOLOCK) 
 ON psb.BOL_ID = rtb.BOL_ID AND psb.IS_DELETED IS NULL
JOIN SCREEN_TEST.dbo.DQA_Voyage dv  WITH (NOLOCK) 
 ON rtb.VoyageId = dv.VOYAGE_ID AND dv.VOYAGE_STATUS = 'Available'
WHERE 
 ( rtb.Direction='E' OR 
   (rtb.Direction='I' AND (rtb.BillType IN ('','M') OR (rtb.BillType = 'H' AND rtb.Master_BOL_ID IS NULL)))
 )
 AND rtb.VMonth >= 201001 --= 201103 -- BETWEEN 201001 AND 201103 -- >= 201001
GROUP BY rtb.Direction,rtb.VMonth
ORDER BY rtb.Direction,rtb.VMonth DESC

-- List House vs Masters
SELECT TOP 5000
-- rtbH.*,rtbM.*
  rtbH.BOL_ID As House_BOL_ID,rtbH.BOL_NBR As House_BOL_NBR,rtbH.TEU As House_RawTEU
 ,psbH.BOL_TEU As House_BolTEU,psbH.BOL_STATUS As House_BolStatus
 ,rtbM.BOL_ID As Master_BOL_ID,rtbM.BOL_NBR As Master_BOL_NBR,rtbM.TEU As Master_RawTEU
 ,psbM.BOL_TEU As Master_BolTEU,psbM.BOL_STATUS As Master_BolStatus
 FROM TEMP_PES.dbo.RawTEU_Bol rtbH  WITH (NOLOCK) 
JOIN TEMP_PES.dbo.RawTEU_Bol rtbM  WITH (NOLOCK) 
 ON rtbH.Master_BOL_ID = rtbM.BOL_ID
JOIN PES.dbo.PES_STG_BOL psbH  WITH (NOLOCK) 
 ON psbH.BOL_ID = rtbH.BOL_ID AND psbH.IS_DELETED IS NULL
JOIN PES.dbo.PES_STG_BOL psbM  WITH (NOLOCK) 
 ON psbM.BOL_ID = rtbM.BOL_ID AND psbM.IS_DELETED IS NULL
WHERE rtbH.Direction='I'
 AND rtbH.VMonth = 201104
ORDER BY rtbM.BOL_ID, rtbH.BOL_ID

-- List House vs Masters
SELECT 
-- rtbH.*,rtbM.*
  rtbH.BOL_ID As House_BOL_ID,rtbH.BOL_NBR As House_BOL_NBR,rtbH.TEU As House_RawTEU
 ,psbH.BOL_TEU As House_BolTEU,psbH.BOL_STATUS As House_BolStatus
 ,rtbM.BOL_ID As Master_BOL_ID,rtbM.BOL_NBR As Master_BOL_NBR,rtbM.TEU As Master_RawTEU
 ,psbM.BOL_TEU As Master_BolTEU,psbM.BOL_STATUS As Master_BolStatus
 FROM TEMP_PES.dbo.RawTEU_Bol rtbH  WITH (NOLOCK) 
JOIN TEMP_PES.dbo.RawTEU_Bol rtbM  WITH (NOLOCK) 
 ON rtbH.Master_BOL_ID = rtbM.BOL_ID
JOIN PES.dbo.PES_STG_BOL psbH  WITH (NOLOCK) 
 ON psbH.BOL_ID = rtbH.BOL_ID AND psbH.IS_DELETED IS NULL
JOIN PES.dbo.PES_STG_BOL psbM  WITH (NOLOCK) 
 ON psbM.BOL_ID = rtbM.BOL_ID AND psbM.IS_DELETED IS NULL
WHERE rtbM.BOL_ID IN (SELECT TOP 5000 rtb.BOL_ID FROM TEMP_PES.dbo.RawTEU_Bol rtb  WITH (NOLOCK)  WHERE rtb.BillType='M' AND rtb.VMonth = 201104)
ORDER BY rtbM.BOL_ID, rtbH.BOL_ID
*/
GO
