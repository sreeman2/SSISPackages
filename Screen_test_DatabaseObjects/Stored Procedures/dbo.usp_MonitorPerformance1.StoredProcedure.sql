/****** Object:  StoredProcedure [dbo].[usp_MonitorPerformance1]    Script Date: 01/03/2013 19:48:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MonitorPerformance1]
	@Type varchar(100)
AS
BEGIN

-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	IF @Type = 'LoadByDay'
	BEGIN
		-- Load by Day
		;WITH tmp_xx1 As (
		SELECT CONVERT(varchar(10), dateadd(dd,datediff(dd,0,StartDate),0), 120) + ', ' + LEFT(DATENAME(weekday, StartDate),3) As Date
		,COUNT(*) As NumCalls, CEILING(SUM(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000)) As TotalSeconds
		,MAX(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000) As MaxSeconds
		FROM Xecute_SProc_Log --v_Xecute_SProc_Log
		WHERE [System_User] = 'pes_ui'
		GROUP BY CONVERT(varchar(10), dateadd(dd,datediff(dd,0,StartDate),0), 120) + ', ' + LEFT(DATENAME(weekday, StartDate),3) --dateadd(dd,datediff(dd,0,StartDate),0)
		)
		SELECT TOP 24 *, TotalSeconds/NumCalls As AverageSeconds
		 FROM tmp_xx1 
		ORDER BY 1 DESC
	END
	ELSE IF @Type = 'LoadByHour'
	BEGIN
		-- Load by Hour
		;WITH tmp_xx1 As (
		SELECT CONVERT(varchar(19), dateadd(hh,datediff(hh,0,StartDate),0), 120) As Hour
		,COUNT(*) As NumCalls, CEILING(SUM(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000)) As TotalSeconds
		,MAX(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000) As MaxSeconds
		FROM Xecute_SProc_Log --v_Xecute_SProc_Log
		WHERE [System_User] = 'pes_ui'
		GROUP BY dateadd(hh,datediff(hh,0,StartDate),0)
		)
		SELECT TOP 30 *, TotalSeconds/NumCalls As AverageSeconds
		 FROM tmp_xx1 
		ORDER BY 1 DESC
	END
	ELSE IF @Type = 'LoadBySProc'
	BEGIN
		-- Load by Sproc
		;WITH tmp_xx1 As (
		SELECT SprocName
		,COUNT(*) As NumCalls, CEILING(SUM(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000)) As TotalSeconds
		,MAX(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000) As MaxSeconds
		FROM Xecute_SProc_Log --v_Xecute_SProc_Log
		WHERE [System_User] = 'pes_ui'
		GROUP BY SprocName
		)
		SELECT *, TotalSeconds/NumCalls As AverageSeconds
		 FROM tmp_xx1 
		ORDER BY 1
	END
	ELSE IF @Type = 'LoadBySProcByDay'
	BEGIN
		-- Load by Sproc / Day
		;WITH tmp_xx1 As (
		SELECT SprocName
		, dateadd(dd,datediff(dd,0,StartDate),0) As Date
		,COUNT(*) As NumCalls, CEILING(SUM(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000)) As TotalSeconds
		,MAX(DATEDIFF(millisecond, StartDate, EndDate)*1.0/1000) As MaxSeconds
		FROM Xecute_SProc_Log --v_Xecute_SProc_Log
		WHERE [System_User] = 'pes_ui'
		GROUP BY SprocName, dateadd(dd,datediff(dd,0,StartDate),0)
		)
		SELECT *, TotalSeconds/NumCalls As AverageSeconds
		 FROM tmp_xx1 
		ORDER BY 1,2
	END

-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
