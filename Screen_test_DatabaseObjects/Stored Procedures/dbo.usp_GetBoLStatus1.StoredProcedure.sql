/****** Object:  StoredProcedure [dbo].[usp_GetBoLStatus1]    Script Date: 01/03/2013 19:48:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetBoLStatus1]
	@SearchBy varchar(100),
	@SearchValue varchar(100)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	DECLARE @BOL_ID int
	SELECT @BOL_ID = CASE @SearchBy
		WHEN 'BOL_ID'		THEN @SearchValue
		WHEN 'CMD_ID'		THEN (SELECT TOP 1 BOL_ID FROM PES.dbo.ARCHIVE_RAW_CMD WHERE CMD_ID = @SearchValue)
		WHEN 'BOL_NUMBER'	THEN (SELECT TOP 1 BOL_ID FROM PES.dbo.ARCHIVE_RAW_BOL WHERE BOL_NUMBER = @SearchValue)
	END

	IF @BOL_ID IS NULL
	BEGIN
		RAISERROR('No matching records found!', 16, 1)
	END

--data load dates etc
SELECT '-- Raw/Staging --' As Source,b.BOL_ID,a.filename FeedName,a.Load_Dt RawInsertedDate,a.load_Dt StagingInsertedDate,
c.BOL_STATUS MasterHouseBillStatus,c.RECORD_STATUS BillStatus,
C.IS_DELETED IsDeleted,C.PPMM_FLAG IsReleasedToDataWarehouse,
d.voyage_status VoyageStatus
 FROM pes.dbo.pes_progress_status a WITH (NOLOCK) 
JOIN pes.dbo.archive_raw_bol b WITH (NOLOCK) ON a.loadnumber=b.load_number 
JOIN pes.dbo.pes_stg_bol c WITH (NOLOCK) ON b.bol_id=c.bol_id 
LEFT OUTER JOIN screen_test.dbo.dqa_voyage d WITH (NOLOCK) ON c.stnd_voyg_id=d.voyage_id 
WHERE b.bol_id=@BOL_ID

--Voyage details
SELECT '-- Voyage --' As Source,d.VOYAGE_ID,d.SCAC,d.VESSEL_NAME
,d.ACT_MANIFEST_NBR,d.ACT_MANIFEST_NBR_MOD
,d.EARLIEST_TAPE_DT,d.voyage_status VoyageStatus,d.Remarks
 FROM pes.dbo.pes_progress_status a WITH (NOLOCK) 
JOIN pes.dbo.archive_raw_bol b WITH (NOLOCK) ON a.loadnumber=b.load_number 
JOIN pes.dbo.pes_stg_bol c WITH (NOLOCK) ON b.bol_id=c.bol_id 
LEFT OUTER JOIN screen_test.dbo.dqa_voyage d WITH (NOLOCK) ON c.stnd_voyg_id=d.voyage_id 
WHERE b.bol_id=@BOL_ID

--Standardization Exception (Will show if the Bill has been deleted and by whom)
SELECT '-- Exceptions --' As Source,A.T_NBR,A.PROCESS_NAME ExceptionName,A.COMPLETE_STATUS CompleteStatus,
C.LOAD_DT ExceptionInsertedDate,
D.IS_DELETED IsDeleted,A.OWNER_ID ModifiedBy--MODIFIEDBY_DELETED
 FROM screen_test.dbo.ctrl_process_voyage A WITH (NOLOCK) 
JOIN PES.DBO.ARCHIVE_RAW_BOL b WITH (NOLOCK) ON a.t_nbr=b.bol_id 
JOIN pes.dbo.pes_progress_Status c WITH (NOLOCK) ON b.load_number=c.loadnumber
JOIN screen_test.dbo.dqa_bl d ON a.t_nbr=D.t_nbr 
WHERE a.t_nbr=@BOL_ID --and complete_status=1

--Commodity Structuring/Company Structuring Exception
SELECT '-- Exceptions --' As Source,A.T_NBR,A.DQA_BL_STATUS CommodityStructuringStatus,C.LOAD_DT ExceptionInsertedDate
 FROM screen_test.dbo.bl_cache a WITH (NOLOCK) 
JOIN PES.DBO.ARCHIVE_RAW_BOL b WITH (NOLOCK) ON a.t_nbr=b.bol_id 
JOIN pes.dbo.pes_progress_Status c WITH (NOLOCK) ON b.load_number=c.loadnumber
WHERE A.t_nbr=@BOL_ID --and A.dqa_bl_status in('pending','partial')

--Company Standardization Exception
SELECT '-- Exceptions --' As Source,A.BOL_ID,A.STATUS CompanyStandardizationStatus,C.LOAD_DT ExceptionInsertedDate
 FROM pes.dbo.pes_transactions_lib_pty A
JOIN PES.DBO.ARCHIVE_RAW_BOL b WITH (NOLOCK) ON a.BOL_ID=b.bol_id 
JOIN pes.dbo.pes_progress_Status c WITH (NOLOCK) ON b.load_number=c.loadnumber
WHERE A.bol_id=@BOL_ID --and [status]='pending'

--Bill in DW
SELECT '-- PES DW --' As Source,BOL_ID,DIRECTION Direction,INSERTED_DATE InsertedDate
,MODIFY_DATE ModifiedDate, MODIFY_BY ModifiedBy
,DELETED IsDeleted,IFX_FLAG iPIERSLoaded
 FROM PES_DW.PESDW.DBO.PES_DW_BOL
WHERE BOL_ID=@BOL_ID

--Bill in TI
SELECT '-- TI --' As Source,BOL_ID,Dir,ARRIVAL_DATE,MODIFY_DATE,VISIBILITY
 FROM PES_DW.PiersTILoad.dbo.TI_Export_MasterData
WHERE BOL_ID=@BOL_ID
UNION ALL
SELECT '-- TI --' As Source,BOL_ID,Dir,ARRIVAL_DATE,MODIFY_DATE,VISIBILITY
 FROM PES_DW.PiersTILoad.dbo.TI_Import_MasterData
WHERE BOL_ID=@BOL_ID

--Bill in Mypiers
SELECT '-- iPIERS --' As Source,BOLDetailId,BOL_ID,CMD_ID,Dir,VDate,UDate,PDate,CreateDate,UpdateDate,DeletedDate,IsCurrent,IsDeleted
 FROM NEWCBMI_DB.NEWCBMIDB.base.boldetail_pes 
WHERE BOL_ID=@BOL_ID
ORDER BY IsCurrent desc,CMD_ID,DIR

/*
--	-- Return sections, count of tables within each section
--	SELECT 'Tabular' As Layout, 'Raw,6;Staging,6;Exceptions,1;Warehouse,7' As Sections
--	UNION
--	SELECT 'Formatted' As Layout, 'Raw,1;Staging,1;Warehouse,1;iPIERS,1;TI,1' As Sections

	-- Return 'Tabular' data
	SELECT 'Raw BOL'  As Source, * FROM PES.dbo.ARCHIVE_RAW_BOL  WHERE BOL_ID = @BOL_ID
	SELECT 'Raw CMD'  As Source, * FROM PES.dbo.ARCHIVE_RAW_CMD  WHERE BOL_ID = @BOL_ID
	SELECT 'Raw CNTR' As Source, * FROM PES.dbo.ARCHIVE_RAW_CNTR WHERE BOL_ID = @BOL_ID
	SELECT 'Raw HZMT' As Source, * FROM PES.dbo.ARCHIVE_RAW_HZMT WHERE BOL_ID = @BOL_ID
	SELECT 'Raw MAN'  As Source, * FROM PES.dbo.ARCHIVE_RAW_MAN  WHERE BOL_ID = @BOL_ID
	SELECT 'Raw PTY'  As Source, * FROM PES.dbo.ARCHIVE_RAW_PTY  WHERE BOL_ID = @BOL_ID

	SELECT 'Staging BOL'  As Source, * FROM PES.dbo.PES_STG_BOL  WHERE BOL_ID = @BOL_ID
	SELECT 'Staging CMD'  As Source, * FROM PES.dbo.PES_STG_CMD  WHERE BOL_ID = @BOL_ID
	SELECT 'Staging CNTR' As Source, * FROM PES.dbo.PES_STG_CNTR WHERE BOL_ID = @BOL_ID
	SELECT 'Staging HZMT' As Source, * FROM PES.dbo.PES_STG_HZMT WHERE BOL_ID = @BOL_ID
	SELECT 'Staging MAN'  As Source, * FROM PES.dbo.PES_STG_MAN  WHERE BOL_ID = @BOL_ID
	SELECT 'Staging PTY'  As Source, * FROM PES.dbo.PES_STG_PTY  WHERE BOL_ID = @BOL_ID

	SELECT 'Exceptions' As Source, *
	 FROM SCREEN_TEST.dbo.CTRL_PROCESS_VOYAGE
	WHERE T_NBR = @BOL_ID

	SELECT 'Warehouse BOL'  As Source, * FROM PESDW.PESDW.dbo.PES_DW_BOL  WHERE BOL_ID = @BOL_ID
	SELECT 'Warehouse CMD'  As Source, * FROM PESDW.PESDW.dbo.PES_DW_CMD  WHERE BOL_ID = @BOL_ID
	SELECT 'Warehouse CNTR' As Source, * FROM PESDW.PESDW.dbo.PES_DW_CNTR WHERE BOL_ID = @BOL_ID
	SELECT 'Warehouse HZMT' As Source, * FROM PESDW.PESDW.dbo.PES_DW_HZMT WHERE BOL_ID = @BOL_ID
	SELECT 'Warehouse MAN'  As Source, * FROM PESDW.PESDW.dbo.PES_DW_MAN  WHERE BOL_ID = @BOL_ID
	SELECT 'Warehouse VIN'  As Source, * FROM PESDW.PESDW.dbo.PES_DW_VIN  WHERE BOL_ID = @BOL_ID
	SELECT 'Warehouse DEL'  As Source, * FROM PESDW.PESDW.dbo.PES_DW_DELETED_BILLS_LOG WHERE BOL_ID = @BOL_ID

	-- Return 'Formatted' data
*/
-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
