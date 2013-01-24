/****** Object:  StoredProcedure [dbo].[PES_VIN_UPDATE_LOG]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <4TH AUGUST 2009>
-- Description:	<Updating the LOG>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_UPDATE_LOG]
	-- Add the parameters for the stored procedure here
	@strLoadNbr varchar(max),
	@iTotalBillProcessedCount varchar(max),
	@iTotalCmdProcessedCount varchar(max),
	@iTotalManProcessedCount varchar(max),
	@iTotalVinGoodCount varchar(max),
	@iTotalCmdVinCount varchar(max),
	@iTotalManVinCount varchar(max)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	update PES.DBO.VIN_LOG 
	set 
		compl_status='0', 
		stop_dt=getdate(),
		BL_PROCESSED_CNT=@iTotalBillProcessedCount,
		CMD_PROCESSED_CNT=@iTotalCmdProcessedCount,
		MAN_PROCESSED_CNT=@iTotalManProcessedCount,
		BL_VIN_FOUND_CNT=@iTotalVinGoodCount,
		CMD_VIN_FOUND_CNT=@iTotalCmdVinCount,
		MAN_VIN_FOUND_CNT=@iTotalManVinCount
	where load_nbr=@strLoadNbr

	UPDATE PES.DBO.PES_PROGRESS_STATUS
	SET VIN_STATUS = 1
	WHERE LOADNUMBER=@strLoadNbr

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
