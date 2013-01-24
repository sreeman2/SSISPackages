/****** Object:  StoredProcedure [dbo].[PES_UPDATE_RAW_STG_REC_COUNT]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_UPDATE_RAW_STG_REC_COUNT] 
	@FeedName varchar(20)=NULL,   
	@LoadNumber numeric(12,0)=NULL
AS
BEGIN

----Added by Harish on Oct-04-2011 to Check Duplicates
		DECLARE @NEWLINE char(6)
		SET @NEWLINE = '<br>' + CHAR(10) + CHAR(13)
		DECLARE @EMAILBODY varchar(1000)
		DECLARE @EMAILRECIPIENTS varchar(1000)

		SELECT LoadNumber,COUNT(*) As Count
		into #tmpDupsInraw_stg_rec_count
		FROM PES.DBO.raw_stg_rec_count  (nolock)
		GROUP BY LoadNumber
		HAVING COUNT(*)>1

		IF @@Rowcount=0 
			BEGIN 
				DROP TABLE #tmpDupsInraw_stg_rec_count
			END
		ELSE
			BEGIN 
				SELECT @EMAILRECIPIENTS='hsreekumar@joc.com;SKasi@piers.com;cpatel@ubmglobaltrade.com'
				Select @EMAILBODY=  'Duplicates in PES.DBO.raw_stg_rec_count'
				EXEC msdb.dbo.sp_send_dbmail
				@recipients=@EMAILRECIPIENTS,  
				@subject ='Test  - Screen To Staging',  
				@body =   @EMAILBODY ,
				@profile_name = 'PES Mail Profile - 1',
				@body_format = 'HTML'
				 
				DROP TABLE #tmpDupsInraw_stg_rec_count
		END
		
---Added by Harish on Oct-04-2011 to Check Duplicates ENDS HERE

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


BEGIN TRY 

DECLARE @ERROR_MESSAGE VARCHAR(1000),
@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50)
DECLARE @TRANNAME VARCHAR(20)
SET @TRANNAME = 'MyTransaction'

declare @FileName						varchar(100)
declare	@PendingBOLCount				int
----------------added-----------------
declare	@DELETEDBOLCOUNT				int
--------------------------------------
declare	@PendingCommodityCount			int
declare @PendingCommodityCount_hcs		int
declare @PendingCommodityCount_QCExp	int
declare @TotalCommodityCount			int
declare @TotalCommodityCount_StgCmd		int
declare @TotalCommodityCount_hcs		int
declare @PendingShipperCount			int
declare @PendingConsigneeCount			int
declare @PendingNotifyCount				int
declare @PendingAlsoNotifyCount			int

declare @tmpLoadNumber numeric(12,0)

/* Nimisha/Shree, June 14, 2011 added new variable */
--start (1)
declare @FeedName_new   varchar(20)
declare @LoadNumber_new numeric(12,0)
Select @FeedName_new = @FeedName
Select @LoadNumber_new = @LoadNumber
---end  (1)

Create Table #stg_rec_count 
(
	LoadNumber				numeric(12,0),
----------------added-----------------
	deletedbolcount			int,
--------------------------------------
	PendingBOLCount			int,
	PendingCommodityCount	int,
	TotalCommodityCount		int,
	PendingShipperCount		int,
	PendingConsigneeCount	int,
	PendingNotifyCount		int,
	PendingAlsoNotifyCount	int
)

Create Table #company_exceptions 
(	
	bol_id	numeric(12,0),
	source  char(1)
)

select @FeedName = rtrim(ISNULL(@FeedName,''))
select @FileName = @FeedName + '%'

select @LoadNumber = isnull(@LoadNumber,-1)


/* Nimisha/Shree, June 14 2011, Commented below code 
--First fetch all the load numbers into #stg_rec_count table
--start (2)
insert into #stg_rec_count(LoadNumber)
select loadnumber
from PES_PROGRESS_STATUS  WITH (NOLOCK) 
where rtrim(filename) like @FileName
and loadnumber = case @LoadNumber when -1 then loadnumber else @loadnumber end
--end (2)
*/


/* Nimisha/Shree, June 14 2011 
   
   After speaking to Pat, If feedname, loadnumber is null,we are assuming to 
   take (current date  - 8 months) load numbers
*/

IF  ( ( @FeedName_new is null ) and  ( @LoadNumber_new is null ) 
    )
BEGIN
   insert into #stg_rec_count(LoadNumber)
   select  LoadNUmber
   from dbo.pes_progress_status ( nolock) 
   where load_dt >= ( GETDATE()-180 )
   order by load_dt
END
ELSE 
BEGIN
   insert into #stg_rec_count(LoadNumber)
   select loadnumber
   from dbo.PES_PROGRESS_STATUS (nolock)
   where rtrim(filename) like @FileName
   and loadnumber = case @LoadNumber when -1 then loadnumber else @loadnumber end

END

--Fetching the counts for the individual load numbers
declare curStgRecCount cursor for
select LoadNumber from #stg_rec_count

open curStgRecCount
fetch next from curStgRecCount into @tmpLoadNumber

while @@fetch_status=0
begin
	select @PendingBOLCount=0
	select @PendingCommodityCount=0
	select @PendingCommodityCount_QCExp =0
	select @PendingCommodityCount_hcs=0
	select @TotalCommodityCount=0
	select @TotalCommodityCount_StgCmd=0
	select @TotalCommodityCount_hcs	=0
	select @PendingShipperCount=0
	select @PendingConsigneeCount=0
	select @PendingNotifyCount=0
	select @PendingAlsoNotifyCount=0
----------------added-----------------
	select @DeletedBOLCount=0
--------------------------------------	
	----------------------------------------------BOL Counts---------------------------------------------
--	--Total Exception (Pending) BOL Count
--	select @PendingBOLCount = count(isnull(bol_id,0))
--	from PES.DBO.pes_stg_bol  WITH (NOLOCK)  
--	where ref_load_num_id =@tmpLoadNumber
--	and record_status = 'PENDING'

    -- Modified by Prabhav on 20TH March 2009
	SELECT @PENDINGBOLCOUNT = COUNT(BOL_ID)
	FROM PES.DBO.PES_STG_BOL  WITH (NOLOCK)  
	WHERE REF_LOAD_NUM_ID =@TMPLOADNUMBER
	AND RECORD_STATUS = 'PENDING' AND ISNULL(IS_DELETED,'') <> 'Y'

	---DELETED bill counts
	SELECT @DELETEDBOLCOUNT = COUNT(BOL_ID)
	FROM PES.DBO.PES_STG_BOL  WITH (NOLOCK)  
	WHERE REF_LOAD_NUM_ID =@TMPLOADNUMBER
	AND ISNULL(IS_DELETED,'') = 'Y'
	----------------------------------------------Commodity Counts---------------------------------------------	
	--Total Commodity Count
	
	select @TotalCommodityCount_StgCmd = count(isnull(bol_id,0)) 
	from PES.DBO.PES_STG_CMD  WITH (NOLOCK)  
	WHERE LOADNUMBER=@tmpLoadNumber

	select @TotalCommodityCount_hcs = count(isnull(h.bol_id,0))
	from hcs_commodity h  WITH (NOLOCK) 
	join screen_test.dbo.bl_cache c WITH (NOLOCK) 
	on h.bol_id = c.t_nbr
	where h.bol_id in (
						select bol_id from pes_stg_bol  WITH (NOLOCK) 
						where ref_load_num_id =@tmpLoadNumber
					  )
	and c.dqa_bl_status = 'PENDING'

	select @TotalCommodityCount = isnull(@TotalCommodityCount_StgCmd,0) + isnull(@TotalCommodityCount_hcs,0)


	--Exception Commodity Counts
	--Exception Commodity Count = Count of Commodities in ctrl_process_voyage where complete_status=1 + Count of commodities in hcs_commodity 
	--for bills which have a status of pending in bl_cache 
	select @PendingCommodityCount_QCExp = sum(isnull(a.cnt,0))
	from
	(	
		select t_nbr, count( distinct isnull(cmd_seq_nbr,0)) cnt
		from screen_test.dbo.ctrl_process_voyage  WITH (NOLOCK) 
		where load_number =  @tmpLoadNumber
		and complete_status=1
		and cmd_seq_nbr is not null
		group by t_nbr
	)a

	select @PendingCommodityCount_hcs = count(isnull(h.bol_id,0)) 
	from hcs_commodity h  WITH (NOLOCK) 
	join screen_test.dbo.bl_cache c WITH (NOLOCK) 
	on h.bol_id = c.t_nbr
	where h.bol_id in (
						select bol_id from pes_stg_bol  WITH (NOLOCK) 
						where ref_load_num_id =@tmpLoadNumber
					  )
	and c.dqa_bl_status = 'PENDING'

	select @PendingCommodityCount = isnull(@PendingCommodityCount_QCExp,0) + isnull(@PendingCommodityCount_hcs,0)

	------------------------------------------------Company Counts----------------------------------------------------------------
	--Shipper, Consignee, Notify & Also Notify Counts
	
	delete from #company_exceptions

--	insert into #company_exceptions(bol_id,source)
--	SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE 
--	FROM PES.DBO.PES_STG_BOL A  WITH (NOLOCK)  join PES.DBO.PES_TRANSACTIONS_EXCEPTIONS_PTY B  WITH (NOLOCK) 
--	on  A.BOL_ID=B.BOL_ID 
--	where A.REF_LOAD_NUM_ID=@tmpLoadNumber 
--	and B.status='PENDING'

insert into #company_exceptions(bol_id,source)
SELECT X.BOL_ID BOL_ID,X.SOURCE SOURCE 
FROM (
SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE FROM PES.DBO.PES_STG_BOL A  WITH (NOLOCK)  join  PES.DBO.PES_TRANSACTIONS_EXCEPTIONS_PTY B  WITH (NOLOCK) 
 on A.BOL_ID=B.BOL_ID 
WHERE A.REF_LOAD_NUM_ID=@tmpLoadNumber AND  B.status='PENDING'  and ISNULL(IS_DELETED,'') <> 'Y'
UNION 
SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE FROM PES.DBO.PES_STG_BOL A  WITH (NOLOCK)  join PES.DBO.PES_TRANSACTIONS_LIB_PTY B  WITH (NOLOCK) 
ON A.BOL_ID=B.BOL_ID 
WHERE A.REF_LOAD_NUM_ID=@tmpLoadNumber AND B.status='PENDING'  and ISNULL(IS_DELETED,'') <> 'Y') X

	select @PendingShipperCount=COUNT(isnull(bol_id,0)) FROM #company_exceptions WHERE  source='S'
	select @PendingConsigneeCount=COUNT(isnull(bol_id,0)) FROM #company_exceptions WHERE  source='C'
	select @PendingNotifyCount=COUNT(isnull(bol_id,0)) FROM #company_exceptions WHERE  source='N'
	select @PendingAlsoNotifyCount=COUNT(isnull(bol_id,0)) FROM #company_exceptions WHERE  source='A'

	----------------------------------------------Update all the Counts in #stg_rec_count table---------------------------------------------
	update #stg_rec_count
	set PendingBOLCount = isnull(@PendingBOLCount,0),
		PendingCommodityCount = isnull(@PendingCommodityCount,0),
		TotalCommodityCount=isnull(@TotalCommodityCount,0),
		PendingShipperCount=isnull(@PendingShipperCount,0),
		PendingConsigneeCount=isnull(@PendingConsigneeCount,0),
		PendingNotifyCount=isnull(@PendingNotifyCount,0),
		PendingAlsoNotifyCount=isnull(@PendingAlsoNotifyCount,0),		
		DeletedBOLCount = isnull(@DeletedBOLCount,0)
	where loadnumber =@tmpLoadNumber

fetch next from curStgRecCount into @tmpLoadNumber
end

close curStgRecCount
deallocate curStgRecCount

BEGIN TRANSACTION @TRANNAME

	UPDATE r with (updlock) SET
		ExceptionSTGBOLCount = PendingBOLCount,
		ExceptionSTGCommodityCount = PendingCommodityCount,
		STGCommodityCount=TotalCommodityCount,
		ExceptionSTGShipperCount=PendingShipperCount,
		ExceptionSTGConsigneeCount=PendingConsigneeCount,
		ExceptionSTGNotifyCount=PendingNotifyCount,
		ExceptionSTGAlsoNotifyCount=PendingAlsoNotifyCount,
		DeletedCount = DeletedBOLCount
	FROM RAW_STG_REC_COUNT r join #stg_rec_count s
	ON r.LoadNumber = s.LoadNumber
END TRY

BEGIN CATCH
	SET @ERROR_NUMBER=ERROR_NUMBER()
	SET @ERROR_LINE=ERROR_LINE()
	SET @ERROR_MESSAGE='STORED PROCEDURE PES_UPDATE_RAW_STG_REC_COUNT FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
	
	ROLLBACK TRANSACTION @TRANNAME
	RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG
END CATCH
	--COMMITTING THE TRANSACTIONS IF NO ERROR OCCURRED
	COMMIT TRANSACTION @TRANNAME

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
