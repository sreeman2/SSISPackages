AMS110621.DAT

select top 1 *  from 
-- Select * from PES.dbo.PES_PROGRESS_STATUS (nolock) where FileName ='AMS110902.DAT'

--delete from PES.dbo.PES_PROGRESS_STATUS where FileName ='AMS110719.DAT'
(nolock) 
order by load_dt desc


--exec PES_LOAD_CLEANUP  'AMS110719.DAT'
--Run the below Feed cleanup job incase a feed failure.
-- exec PESFeedClean  'AMS111015.DAT'
--SELECT @LOADNUMBER = LOADNUMBER FROM PES.DBO.PES_PROGRESS_STATUS  WITH (NOLOCK)  WHERE [FILENAME] = @BOLFILE

--select  *    from screen_test.dbo.FeedLoadPriority (nolock) where  status is null or status='pickedupbypes' order by priority
feedfilename = 'crle110716.DAT'
--select * from sys.sysprocesses
SELECT scheduler_id, current_tasks_count, runnable_tasks_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255


--update screen_test.dbo.FeedLoadPriority set status=null where feedfilename = 'AMS110719.DAT'
--Select * from dbo.PES_PROCESS_STATUS
--Select * from dbo.hep_log where  FileName ='AMS110719.DAT' and load_NBR is null

--Delete  from dbo.hep_log where load_NBR is null and FileName ='AMS110719.DAT'

Select count(*) from screen_test.dbo.dqa_cmds where hcs_processed='n' 


select  *    from screen_test.dbo.FeedLoadPriority (nolock) where  status ='processedbypes' order by id desc