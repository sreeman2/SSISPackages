/****** Object:  StoredProcedure [dbo].[usp_MonitorSystemStatus1]    Script Date: 01/03/2013 19:48:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MonitorSystemStatus1]
	@Type varchar(100)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	IF @Type = 'StatusByUserActive'
	BEGIN
		-- Status by User Active
		WITH tmp_ActiveUsers As (
		SELECT Rank() over (Partition BY pul.USER_ID order by pul.LOGIN DESC) as Rank
			, pul.USER_ID
			, CONVERT(varchar(19), pul.LOGIN, 120) As LOGIN
		 FROM dbo.PEA_USER_LOG pul
		WHERE pul.MODIFIED_DT > getdate()-7
		 AND pul.LOGOUT = '1/1/1900'
		)
		SELECT tau.USER_ID, tau.LOGIN
		 FROM tmp_ActiveUsers tau
		WHERE tau.Rank = 1
		ORDER BY tau.LOGIN DESC
	END
	ELSE IF @Type = 'StatusByUserHistory'
	BEGIN
		-- Status by User History
		SELECT pul.USER_ID
		, CONVERT(varchar(19), pul.LOGIN, 120) As LOGIN --pul.LOGIN
		, CASE WHEN pul.LOGOUT = '1/1/1900' THEN NULL ELSE CONVERT(varchar(19), pul.LOGOUT, 120) END As LOGOUT
		 FROM dbo.PEA_USER_LOG pul
		WHERE pul.MODIFIED_DT > getdate()-7
		ORDER BY pul.MODIFIED_DT DESC
	END
	ELSE IF @Type = 'StatusByProcessActive'
	BEGIN
		-- Status by Process
		SELECT pl.IdProcessLog, pl.IdProcess, pd.ProcessName, pl.Direction
			, CONVERT(varchar(16),pl.StartDate,120) As StartDate, CONVERT(varchar(16),pl.StopDate,120) As StopDate
			, DATEDIFF(minute,StartDate,StopDate) As DurationInMinutes
			, pl.Status, pl.Comments
		 FROM PES.dbo.ProcessLog pl
		JOIN PES.dbo.ProcessDefinition pd ON pd.IdProcess = pl.IdProcess
		WHERE Status = 'Running' --StopDate IS NULL
		ORDER BY IdProcessLog DESC
	END
	ELSE IF @Type = 'StatusByProcessHistory'
	BEGIN
		-- Status by Process
		SELECT pl.IdProcessLog, pl.IdProcess, pd.ProcessName, pl.Direction
			, CONVERT(varchar(16),pl.StartDate,120) As StartDate, CONVERT(varchar(16),pl.StopDate,120) As StopDate
			, DATEDIFF(minute,StartDate,StopDate) As DurationInMinutes
			, pl.Status, pl.Comments
		 FROM PES.dbo.ProcessLog pl
		JOIN PES.dbo.ProcessDefinition pd ON pd.IdProcess = pl.IdProcess
		WHERE StartDate > getdate()-30
		ORDER BY IdProcessLog DESC
	END
	ELSE IF @Type = 'StatusByProcessUpcoming'
	BEGIN
		-- Status by Process
		DECLARE @HowManyHoursAhead int
		SET @HowManyHoursAhead=24*7 -- i.e. processes scheduled to run in the next week

		;WITH Jobs132 AS (
			SELECT  job.job_id,  job.[name]
			  , CASE job.[description] WHEN 'No description available.' THEN NULL ELSE job.description END AS Description
			  , job.date_modified
			  , CASE sched.next_run_date
					WHEN 0 THEN 'Never'
					ELSE
					  CONVERT(varchar(10), CONVERT(smalldatetime, CAST(sched.next_run_date as varchar), 120), 120)+' '+
					  RIGHT('0'+CAST((sched.next_run_time/10000) AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((sched.next_run_time-((sched.next_run_time/10000)*10000))/100 AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((sched.next_run_time-((sched.next_run_time/10000)*10000)-((sched.next_run_time-((sched.next_run_time/10000)*10000))/100*100)) AS VARCHAR), 2)
			  END AS NextRunDateTime
			  , (
				SELECT CASE last_run_date
					WHEN 0 THEN 'Never'
					ELSE
					  CONVERT(varchar(10), CONVERT(smalldatetime, CAST(last_run_date as varchar), 120), 120)+' '+
					  RIGHT('0'+CAST((last_run_time/10000) AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((last_run_time-((last_run_time/10000)*10000))/100 AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((last_run_time-((last_run_time/10000)*10000)-((last_run_time-((last_run_time/10000)*10000))/100*100)) AS VARCHAR), 2)
				  END AS LastRunDateTime
				FROM msdb.dbo.sysjobsteps
				WHERE job_id = job.job_id AND step_id = (
				  SELECT MAX(step_id)
				  FROM msdb.dbo.sysjobsteps
				  WHERE job_id = job.job_id
				)
			  ) as LastSuccessfulExecution
			FROM msdb.dbo.sysjobs job JOIN msdb.dbo.sysjobschedules sched
				ON sched.job_id = job.job_id
			WHERE job.enabled = 1 -- remove this if you wish to return all jobs
				AND sched.next_run_date > 0
		), Jobs134 As (
			SELECT  job.job_id,  job.[name]
			  , CASE job.[description] WHEN 'No description available.' THEN NULL ELSE job.description END AS Description
			  , job.date_modified
			  , CASE sched.next_run_date
					WHEN 0 THEN 'Never'
					ELSE
					  CONVERT(varchar(10), CONVERT(smalldatetime, CAST(sched.next_run_date as varchar), 120), 120)+' '+
					  RIGHT('0'+CAST((sched.next_run_time/10000) AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((sched.next_run_time-((sched.next_run_time/10000)*10000))/100 AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((sched.next_run_time-((sched.next_run_time/10000)*10000)-((sched.next_run_time-((sched.next_run_time/10000)*10000))/100*100)) AS VARCHAR), 2)
			  END AS NextRunDateTime
			  , (
				SELECT CASE last_run_date
					WHEN 0 THEN 'Never'
					ELSE
					  CONVERT(varchar(10), CONVERT(smalldatetime, CAST(last_run_date as varchar), 120), 120)+' '+
					  RIGHT('0'+CAST((last_run_time/10000) AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((last_run_time-((last_run_time/10000)*10000))/100 AS VARCHAR), 2)+':'+
					  RIGHT('0'+CAST((last_run_time-((last_run_time/10000)*10000)-((last_run_time-((last_run_time/10000)*10000))/100*100)) AS VARCHAR), 2)
				  END AS LastRunDateTime
				FROM PESDW.msdb.dbo.sysjobsteps
				WHERE job_id = job.job_id AND step_id = (
				  SELECT MAX(step_id)
				  FROM PESDW.msdb.dbo.sysjobsteps
				  WHERE job_id = job.job_id
				)
			  ) as LastSuccessfulExecution
			FROM PESDW.msdb.dbo.sysjobs job JOIN PESDW.msdb.dbo.sysjobschedules sched
				ON sched.job_id = job.job_id
			WHERE job.enabled = 1 -- remove this if you wish to return all jobs
				AND sched.next_run_date > 0
		)
		SELECT --*,
		Name,NextRunDateTime
		--,DATEDIFF(minute, GETDATE(), NextRunDateTime) As Minutes
--		,LTRIM(RTRIM(STR(DATEDIFF(minute, GETDATE(), NextRunDateTime)/60))) + ' hr(s) ' +
--		 LTRIM(RTRIM(STR(DATEDIFF(minute, GETDATE(), NextRunDateTime)%60))) + ' minute(s)' As InXHoursFromNow
	,CONVERT(VARCHAR(40), 
      DATEDIFF(minute, GETDATE(), NextRunDateTime)/(24*60))
   + ' days, '
   + CONVERT(VARCHAR(40), 
      DATEDIFF(minute, GETDATE(), NextRunDateTime)%(24*60)/60)
   + ' hours, and '
   + CONVERT(VARCHAR(40), 
      DATEDIFF(minute, GETDATE(), NextRunDateTime)%60)
   + ' minutes' As InXHoursFromNow
		,LastSuccessfulExecution
		 FROM Jobs132 j132
		WHERE DATEDIFF(hh, GETDATE(), NextRunDateTime) <= @HowManyHoursAhead
		 AND (name LIKE 'PES%' OR name LIKE 'myPIERS%' or name LIKE 'TI%')
UNION
		SELECT --*,
		Name,NextRunDateTime
		--,DATEDIFF(minute, GETDATE(), NextRunDateTime) As Minutes
--		,LTRIM(RTRIM(STR(DATEDIFF(minute, GETDATE(), NextRunDateTime)/60))) + ' hr(s) ' +
--		 LTRIM(RTRIM(STR(DATEDIFF(minute, GETDATE(), NextRunDateTime)%60))) + ' minute(s)' As InXHoursFromNow
	,CONVERT(VARCHAR(40), 
      DATEDIFF(minute, GETDATE(), NextRunDateTime)/(24*60))
   + ' days, '
   + CONVERT(VARCHAR(40), 
      DATEDIFF(minute, GETDATE(), NextRunDateTime)%(24*60)/60)
   + ' hours, and '
   + CONVERT(VARCHAR(40), 
      DATEDIFF(minute, GETDATE(), NextRunDateTime)%60)
   + ' minutes' As InXHoursFromNow
		,LastSuccessfulExecution
		 FROM Jobs134 j134
		WHERE DATEDIFF(hh, GETDATE(), NextRunDateTime) <= @HowManyHoursAhead
		 AND (name LIKE 'PES%' OR name LIKE 'myPIERS%' or name LIKE 'TI%')
		ORDER BY NextRunDateTime
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
