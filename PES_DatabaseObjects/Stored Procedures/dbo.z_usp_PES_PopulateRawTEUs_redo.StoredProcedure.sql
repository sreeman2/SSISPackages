/****** Object:  StoredProcedure [dbo].[z_usp_PES_PopulateRawTEUs_redo]    Script Date: 01/03/2013 19:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Calculate Raw TEUs

Parameters:
 @VMonth int - e.g. 201103 for March 2011. If NULL, it will work on 'Production Month'
 @Direction varchar(1) - e.g. 'I' or 'E'
Input: PES.dbo.PES_STG_BOL, PES.dbo.PES_STG_CNTR, PES.dbo.REF_CONTAINER_ISO
Intermediate: TEMP_PES.dbo.RawTEU_Bol, TEMP_PES.dbo.RawTEU_Container
Final Output: PESDW.PESDW.dbo.PES_DW_BOL_Extension, [10.31.18.147]/SQLInstance02.Piers.dbo.MAIN_ACTIVE_BOL_Extension

Usage: EXEC dbo.z_usp_PES_PopulateRawTEUs_redo @VMonth=201104, @Direction='E'
*/
CREATE PROCEDURE [dbo].[z_usp_PES_PopulateRawTEUs_redo]
	 @VMonth int
	,@Direction varchar(1)
AS
BEGIN

PRINT '@VMonth = ' + LTRIM(RTRIM(STR(@VMonth)))
PRINT '@Direction = ' + @Direction

-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@VMonth=' + LTRIM(RTRIM(STR(@VMonth)))
 + ', @Direction=' + @Direction
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @StartTime datetime
SET @StartTime = getdate()

--DROP TABLE #tmp_VoyageId_Workload
SELECT DISTINCT(VoyageId) As VoyageId
INTO #tmp_VoyageId_Workload
 FROM TEMP_PES.dbo.RawTEU_Bol WITH (NOLOCK)
WHERE BOL_ID IN (
	SELECT DISTINCT BOL_ID
	 FROM TEMP_PES.dbo.RawTEU_Container WITH (NOLOCK)
	WHERE OnNBols = 1
)
AND VMonth = @VMonth
AND Direction = @Direction

DECLARE db_cursor CURSOR FOR 
SELECT VoyageId
 FROM #tmp_VoyageId_Workload 
ORDER BY VoyageId DESC

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
  @To		= 'AAwasthi@piers.com'
 ,@From		= 'PIERS-NoReply@piers.com'
 ,@Subject	= 'PES Raw TEU redo completed'
 ,@Body		= @Message
 ,@Success	= @SendEmailSuccess OUT
 ,@Output	= @SendEmailOutput OUT
SELECT @SendEmailSuccess, @SendEmailOutput

-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END

/*
SELECT TOP 100 * FROM TEMP_PES.dbo.RawTEU_Bol WITH (NOLOCK)  ORDER BY 1
SELECT TOP 100 * FROM TEMP_PES.dbo.RawTEU_Container WITH (NOLOCK)  ORDER BY 1,2

SELECT COUNT(*) FROM TEMP_PES.dbo.RawTEU_Bol  WITH (NOLOCK) WHERE ModifiedDate > '2011-07-11'
--0

SELECT * FROM TEMP_PES.dbo.RawTEU_Bol WITH (NOLOCK) WHERE BOL_ID BETWEEN 231801655 AND 231801672
SELECT * FROM TEMP_PES.dbo.RawTEU_Container WITH (NOLOCK) WHERE BOL_ID BETWEEN 231801655 AND 231801672
*/
GO
