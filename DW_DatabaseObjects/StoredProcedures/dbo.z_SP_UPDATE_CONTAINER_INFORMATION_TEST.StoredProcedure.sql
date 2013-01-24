/****** Object:  StoredProcedure [dbo].[z_SP_UPDATE_CONTAINER_INFORMATION_TEST]    Script Date: 01/08/2013 14:51:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[z_SP_UPDATE_CONTAINER_INFORMATION_TEST] 
	-- Add the parameters for the stored procedure here
	@BOL_ID INT,
	@CMD_ID INT,
	@HAZMAT_FLAG CHAR(1),
	@RORO_FLAG CHAR(1),
	@REEFER_FLAG CHAR(1)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @CMD_COUNT INT
		
	update PES_DW_CMD WITH (UPDLOCK) 
		set HAZMAT_FLAG = @HAZMAT_FLAG,
			RORO_FLAG = @RORO_FLAG,
			REEFER_FLAG = @REEFER_FLAG,
			MODIFY_DATE = GETDATE()
	where CMD_ID = @CMD_ID AND BOL_ID = @BOL_ID
	

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
