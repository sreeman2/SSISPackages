/****** Object:  StoredProcedure [dbo].[GetJobStatus]    Script Date: 01/03/2013 19:40:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetJobStatus] 
   @ps_JobName nvarchar(128),
   @pn_JobState int out,
   @pn_JobOutcome int out
as
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--X AUTHOR:			Harish Sreekumar
--X CREATED DATE:	30-Aug-2011
--X DESCRIPTION:	Procedure used to determine if a SQL Agent job is running
--X	
--X ASSUMPTIONS:	Need execute permissions on master..xp_sqlagent_enum_jobs
--X
--X PARAMETERS: @ps_JobName - Name of job to find running
--X             @pn_JobState - state of the job
--X                   Valid Options for Job_State are
--X                    0 - Not Idle or Suspended
--X                    1 - Executing Job
--X                    2 - Waiting For Thread
--X                    3 - Between Retries
--X                    4 - Idle
--X                    5 - Suspended
--X                    6 - WaitingForStepToFinish
--X                    7 - PerformingCompletionActions
--X             @pn_JobOutcome - Outcome status of job 
--X                   Valid options for Last_Run_Outcome are
--X                    0 - Failed
--X                    1 - Successful
--X                    2 - Not Valid
--X                    3 - Canceled
--X                    4 - Executing
--X                    5 - Undetermined State
--X
--X RETURNS:  @pn_JobState and @pn_JobOutcome
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
begin
set nocount on
 Declare @vt_JobResults TABLE  (
    job_id UNIQUEIDENTIFIER NOT NULL,
      last_run_date INT NOT NULL,
      last_run_time INT NOT NULL,
      next_run_date INT NOT NULL,
      next_run_time INT NOT NULL,
      next_run_schedule_id INT NOT NULL,
      requested_to_run INT NOT NULL, -- BOOL
      request_source INT NOT NULL,
      request_source_id sysname COLLATE database_default NULL,
      running INT NOT NULL, -- BOOL
      current_step INT NOT NULL,
      current_retry_attempt INT NOT NULL,
      job_state INT NOT NULL)
      
 declare @vn_job_id UNIQUEIDENTIFIER

        -- Get the Job ID.  This is needed to see if the job is actually running
        select @vn_job_id = job_id 
          from msdb..sysjobs
         where [name] = @ps_JobName

        -- Populate temp table with results of all jobs
        insert into @vt_JobResults
        exec master..xp_sqlagent_enum_jobs 1,''
    
        -- Check to see if the job is already running
        select @pn_jobstate = job_state, @pn_JobOutcome = last_run_outcome 
          from @vt_JobResults r 
                 inner join msdb.dbo.sysjobservers so 
                     on r.job_id = so.job_id
          where r.job_id = @vn_job_id
end
GO
