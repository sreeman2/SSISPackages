/****** Object:  StoredProcedure [dbo].[POPULATE_BL_CACHE_LATE]    Script Date: 01/03/2013 19:48:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Procedure modified to populate only the recent Late Bills - CTS - 6th Nov 2009

--Procedure modified to add a condition for checking the DQA_BL_STATUS.  The purpose
--is to populate 'L' only for the bills that needs to be processed.
CREATE PROCEDURE [dbo].[POPULATE_BL_CACHE_LATE]  
	@fromdate datetime,
	@todate datetime,
	@source varchar(2),
    @blcnt float(53)  OUTPUT

/*
Change History
Changes by Cognizant to fix the Late Bill Count and improve performance
23-Feb-2010
*/
AS 

BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	--Retreive the existing bills which have the late bill flag already as 'L'
	--DECLARE @LATE_BILL_COUNT INT

	--SELECT @LATE_BILL_COUNT = COUNT(*) FROM BL_CACHE (NOLOCK) WHERE LATE_BOL_FLAG = 'L'

	--Calculate the total number of Bills which will be updated as 'L'(Late Bills)
	--DECLARE @LATE_BILL_COUNT_NEW INT

	/*
		SELECT @LATE_BILL_COUNT_NEW = COUNT(*) 
		FROM BL_CACHE B (NOLOCK)
		INNER JOIN BL_BL (NOLOCK) 
		ON BL_BL.T_NBR = B.T_NBR
		INNER JOIN DQA_VOYAGE V (NOLOCK) 
		ON BL_BL.DQA_VOYAGE_ID = V.VOYAGE_ID
		WHERE V.VOYAGE_STATUS = 'AVAILABLE' 
		AND B.ACT_ARRIVAL_DT BETWEEN CAST(@fromdate AS DATETIME) AND CAST(@todate AS DATETIME)	
		AND B.DIR = @source
	*/

	DECLARE @dtFromDate datetime
	DECLARE @dtToDate datetime

	SELECT @dtFromDate=convert(datetime,CONVERT(varchar,@fromdate,101))
	SELECT @dtToDate=convert(datetime,CONVERT(varchar,@todate,101))
	
	--Update the bills with the Late Bill flag 'L'
	UPDATE B WITH (UPDLOCK)
	SET B.LATE_BOL_FLAG = 'L'
	FROM BL_CACHE B 
	INNER JOIN BL_BL  WITH (NOLOCK)  
	ON BL_BL.T_NBR = B.T_NBR 
	INNER JOIN DQA_VOYAGE V WITH (NOLOCK) 
	ON BL_BL.DQA_VOYAGE_ID = V.VOYAGE_ID
	WHERE V.VOYAGE_STATUS='AVAILABLE' 
	AND V.ACT_ARRIVAL_DT BETWEEN @dtFromDate AND @dtToDate
	AND B.DIR = @source
	AND B.DQA_BL_STATUS NOT IN ('PARTIAL', 'CLEANSED')
	AND ISNULL(B.LATE_BOL_FLAG,'') <> 'L'

	SELECT @blcnt = @@ROWCOUNT

	/*
	--Calculate and set the number of Late Bills populated at present
	IF (@LATE_BILL_COUNT_NEW > @LATE_BILL_COUNT)
	BEGIN
		SET @blcnt = @LATE_BILL_COUNT_NEW - @LATE_BILL_COUNT
	END
	ELSE
		SET @blcnt = 0
	*/

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
