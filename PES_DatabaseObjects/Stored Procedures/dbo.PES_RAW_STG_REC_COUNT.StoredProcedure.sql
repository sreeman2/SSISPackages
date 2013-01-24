/****** Object:  StoredProcedure [dbo].[PES_RAW_STG_REC_COUNT]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_RAW_STG_REC_COUNT]
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @TRANNAME VARCHAR(20),@FILE VARCHAR(500),@FILE_NAME VARCHAR(50)
DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50),@LOAD_NUM INT,@DATE DATETIME,@TIME INT
declare	@PendingCommodityCount			int
declare @PendingCommodityCount_hcs		int
declare @PendingCommodityCount_QCExp	int
declare @TotalCommodityCount_StgCmd		int
declare @TotalCommodityCount_hcs		int
declare @TotalCommodityCount			int
declare @DeletedCount					int
declare @IntransitCount					int
declare @bl_cnt							int
declare @CNTR_cnt						int
declare @Good_bl_cnt					int
declare @Truck_bl_cnt					int
declare @Test_bl_cnt					int
declare @Total_bl_cnt					int
declare @Field_err_bl_cnt				int


SET @TRANNAME = 'MyTransaction'
SELECT @FILE = PATH FROM PES_CONFIGURATION WHERE SOURCE='SP_LOG'
SELECT @FILE_NAME= FILENAME,@LOAD_NUM=LOADNUMBER FROM PES.DBO.PES_PROGRESS_STATUS WITH (NOLOCK)  WHERE LOADNUMBER=(SELECT DISTINCT LOAD_NUMBER FROM PES.DBO.RAW_BOL)
SET @FILE='"'+@FILE+@FILE_NAME+'_LOG.TXT'+'"'

SET @CMD = 'ECHO PROCEDURE PES_RAW_STG_REC_COUNT EXECUTION STARTED' + '>>'+ @FILE
EXEC MASTER..XP_CMDSHELL @CMD 

BEGIN TRANSACTION @TRANNAME

BEGIN TRY 

SET @DATE=GETDATE()
---------------------------------------Delted and Intransit Count -----------------------------------------

set @IntransitCount=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE INVALIDBILLTYPE='I')
set @DeletedCount=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE INVALIDBILLTYPE='D')
set @bl_cnt=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL)
set @Good_bl_cnt=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL)
set @Total_bl_cnt=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) )
set @Truck_bl_cnt=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE INVALIDBILLTYPE='K')
set @Test_bl_cnt=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE INVALIDBILLTYPE='T')
set @Field_err_bl_cnt=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE INVALIDBILLTYPE='F')
----------------------------------------------------------------------------------------------------------

--------------------------------------Pending Commodity Count--------------------------------------------------------------------
select @PendingCommodityCount_QCExp = isnull(sum(a.cnt),0)
	from
	(	
		select t_nbr, count( distinct cmd_seq_nbr) cnt
		from screen_test.dbo.ctrl_process_voyage  WITH (NOLOCK) 
		where load_number =  @LOAD_NUM
		and complete_status=1
		and cmd_seq_nbr is not null
		group by t_nbr
	)a

	select @PendingCommodityCount_hcs = isnull(count(h.bol_id),0) 
	from hcs_commodity h  WITH (NOLOCK) 
	join screen_test.dbo.bl_cache c WITH (NOLOCK) 
	on h.bol_id = c.t_nbr
	where h.bol_id in (
						select bol_id from pes_stg_bol  WITH (NOLOCK) 
						where ref_load_num_id =@LOAD_NUM
					  )
	and c.dqa_bl_status = 'PENDING'

SET @PendingCommodityCount = @PendingCommodityCount_QCExp + @PendingCommodityCount_hcs
--------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------Total Commodity Count--------------------------------------------------------------------
select @TotalCommodityCount_StgCmd = count(bol_id) from PES.DBO.PES_STG_CMD  WITH (NOLOCK)  WHERE LOADNUMBER=@LOAD_NUM

	select @TotalCommodityCount_hcs = isnull(count(h.bol_id),0) 
	from hcs_commodity h  WITH (NOLOCK) 
	join screen_test.dbo.bl_cache c WITH (NOLOCK) 
	on h.bol_id = c.t_nbr
	where h.bol_id in (
						select bol_id from pes_stg_bol  WITH (NOLOCK) 
						where ref_load_num_id =@LOAD_NUM
					  )
	and c.dqa_bl_status = 'PENDING'

SET @TotalCommodityCount = @TotalCommodityCount_StgCmd + @TotalCommodityCount_hcs
--------------------------------------------------------------------------------------------------------------------------------------------




--------------------------------Temp table for RAW_PTY Table-----------------------------------

--SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE INTO #TEMP_RAW_PTY FROM RAW_BOL A WITH (NOLOCK) ,PES_STRUCTURED_PTY B  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL AND A.BOL_ID=B.BOL_ID  
SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE INTO #TEMP_RAW_PTY FROM RAW_BOL A  WITH (NOLOCK) ,RAW_PTY B  WITH (NOLOCK) WHERE ISNULL(InvalidBillFlag,'') = '' AND A.BOL_ID=B.BOL_ID  

--------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------Temp table for PES_TRANSACTIONS_EXCEPTIONS_PTY Table-----------------------------------

--SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE INTO #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY FROM PES.DBO.PES_STG_BOL A  WITH (NOLOCK)  ,PES.DBO.PES_TRANSACTIONS_EXCEPTIONS_PTY B  WITH (NOLOCK) 
--WHERE A.REF_LOAD_NUM_ID=@LOAD_NUM AND A.BOL_ID=B.BOL_ID 
--and b.status='PENDING'

SELECT X.BOL_ID BOL_ID,X.SOURCE SOURCE INTO #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY 
FROM (SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE FROM PES.DBO.PES_STG_BOL A  WITH (NOLOCK)  ,PES.DBO.PES_TRANSACTIONS_EXCEPTIONS_PTY B  WITH (NOLOCK) 
WHERE A.REF_LOAD_NUM_ID=@LOAD_NUM AND A.BOL_ID=B.BOL_ID 
and b.status='PENDING'
UNION 
SELECT B.BOL_ID BOL_ID,B.SOURCE SOURCE FROM PES.DBO.PES_STG_BOL A  WITH (NOLOCK)  ,PES.DBO.PES_TRANSACTIONS_LIB_PTY B  WITH (NOLOCK) 
WHERE A.REF_LOAD_NUM_ID=@LOAD_NUM AND A.BOL_ID=B.BOL_ID 
and b.status='PENDING') X


--------------------------------------------------------------------------------------------------------------------------------------------



UPDATE RAW_STG_REC_COUNT SET
ImpEXP=(SELECT top 1 ImpEXP FROM RAW_BOL  WITH (NOLOCK) ),
RAWBOLCount=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) ),
RAWCommodityCount=(SELECT COUNT(*) FROM RAW_CMD  WITH (NOLOCK)  ),
RAWContainerCount=(SELECT COUNT(*) FROM RAW_CNTR   WITH (NOLOCK) ),
RAWHazmatCount=(SELECT COUNT(*) FROM RAW_HZMT  WITH (NOLOCK) ),
RAWMANCount=(SELECT COUNT(*) FROM RAW_MAN  WITH (NOLOCK) ),
RAWShipperCount=(SELECT COUNT(*) FROM RAW_PTY  WITH (NOLOCK)  WHERE SOURCE='S'),
RAWConsigneeCount=(SELECT COUNT(*) FROM RAW_PTY  WITH (NOLOCK)  WHERE SOURCE='C'),
RAWNotifyCount=(SELECT COUNT(*) FROM RAW_PTY  WITH (NOLOCK)  WHERE SOURCE='N'),
RAWAlsoNotifyCount=(SELECT COUNT(*) FROM RAW_PTY  WITH (NOLOCK)  WHERE SOURCE='A' ),
RAWDeletedBillCount=@DeletedCount,
RAWFgnCargoBillCount=@IntransitCount,
RAWInvalidVeslBillCount=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE INVALIDBILLTYPE='V'),
STGBOLCount=(SELECT COUNT(*) FROM RAW_BOL  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL),
STGCommodityCount=@TotalCommodityCount,
STGContainerCount=(SELECT COUNT(*) FROM RAW_BOL A WITH (NOLOCK) ,RAW_CNTR B  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL AND A.BOL_ID=B.BOL_ID ),


STGShipperCount=(SELECT COUNT(DISTINCT BOL_ID) FROM #TEMP_RAW_PTY WHERE SOURCE='S' ),
STGConsigneeCount=(SELECT COUNT(DISTINCT BOL_ID) FROM #TEMP_RAW_PTY WHERE SOURCE='C' ),
STGNotifyCount=(SELECT COUNT(DISTINCT BOL_ID) FROM #TEMP_RAW_PTY WHERE SOURCE='N' ),
STGAlsoNotifyCount=(SELECT COUNT(DISTINCT BOL_ID) FROM #TEMP_RAW_PTY WHERE SOURCE='A' ),



STGHazmatCount=(SELECT COUNT(*) FROM RAW_BOL A WITH (NOLOCK) ,RAW_HZMT B  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL AND A.BOL_ID=B.BOL_ID ),
STGMANCount=(SELECT COUNT(*) FROM RAW_BOL A WITH (NOLOCK) ,RAW_MAN B  WITH (NOLOCK) WHERE InvalidBillFlag IS NULL AND A.BOL_ID=B.BOL_ID ),

ExceptionSTGBOLCount=(SELECT COUNT(*) FROM PES_STG_BOL WHERE REF_LOAD_NUM_ID=@LOAD_NUM AND RECORD_STATUS='PENDING'),
ExceptionSTGCommodityCount=@PendingCommodityCount,
ExceptionSTGShipperCount=(SELECT COUNT(BOL_ID) FROM #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY  WITH (NOLOCK)  WHERE  SOURCE='S' ),

ExceptionSTGConsigneeCount=(SELECT COUNT(BOL_ID) FROM #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY  WITH (NOLOCK)  WHERE  SOURCE='C' ),
ExceptionSTGNotifyCount=(SELECT COUNT(BOL_ID) FROM #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY  WITH (NOLOCK)  WHERE  SOURCE='N' ),
ExceptionSTGAlsoNotifyCount=(SELECT COUNT(BOL_ID) FROM #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY  WITH (NOLOCK)  WHERE  SOURCE='A' ),





AutomatedCount=(SELECT COUNT(*) FROM PES_STG_BOL WHERE REF_LOAD_NUM_ID=@LOAD_NUM AND RECORD_STATUS='AUTOMATED')



where LoadNumber=@LOAD_NUM 

--------------------------Update Hep Log Table------------------

--Changes by cognizant: Feb 19th 2010 - start

--UPDATE HEP_LOG SET LOAD_NBR=@LOAD_NUM,IN_TRANSIT_BL_CNT=@IntransitCount,
--DEL_BL_CNT=@DeletedCount,IN_BL_CNT=@bl_cnt, TOT_BL_CNT=@Total_bl_cnt, GOOD_BL_CNT=@Good_bl_cnt,
--FLD_ERR_BL_CNT=@Field_err_bl_cnt, TEST_BL_CNT=@Test_bl_cnt, TRUCK_BL_CNT=@Truck_bl_cnt
--WHERE FILENAME=@FILE_NAME

UPDATE HEP_LOG SET LOAD_NBR=@LOAD_NUM,IN_TRANSIT_BL_CNT=@IntransitCount,
DEL_BL_CNT=@DeletedCount,TOT_BL_CNT=IN_BL_CNT,GOOD_BL_CNT=@Good_bl_cnt,
FLD_ERR_BL_CNT=@Field_err_bl_cnt, TEST_BL_CNT=@Test_bl_cnt, TRUCK_BL_CNT=@Truck_bl_cnt
WHERE FILENAME=@FILE_NAME

--Changes by cognizant: Feb 19th 2010 - end

-----------------------Update Hep Log Table AES feed------------------

SELECT TOP 1 @CNTR_cnt=RAWContainerCount FROM PES.DBO.RAW_STG_REC_COUNT WHERE LoadNumber=@LOAD_NUM
--UPDATE HEP_LOG SET IN_HAZMAT_CNT=@CNTR_cnt
--WHERE FILENAME=@FILE_NAME AND LEFT(LTRIM(@FILE_NAME),3)='ESCAN'

----------------------------------------------------------------


-------------DROP TEMPORARY TABLE----------------------------------------------------

DROP TABLE #TEMP_PES_TRANSACTIONS_EXCEPTIONS_PTY
DROP TABLE #TEMP_RAW_PTY

--------------------------------------------------------------------------------------
END TRY

BEGIN CATCH
	SET @ERROR_NUMBER=ERROR_NUMBER()
	SET @ERROR_LINE=ERROR_LINE()
	SET @ERROR_MESSAGE='STORED PROCEDURE PES_RAW_STG_REC_COUNT FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
	
	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
    SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	
	ROLLBACK TRANSACTION @TRANNAME
	SET @CMD = 'ECHO TRANSACTIONS ROLLBACKED'+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG
END CATCH

	--COMMITTING THE TRANSACTIONS IF NO ERROR OCCURRED
	COMMIT TRANSACTION @TRANNAME
	SET @TIME= DATEDIFF(N,GETDATE(),@DATE)
	SET @cmd = 'ECHO PROCEDURE PES_RAW_STG_REC_COUNT EXECUTED SUCCESSFULLY'+ CAST(@TIME AS VARCHAR(20))+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
