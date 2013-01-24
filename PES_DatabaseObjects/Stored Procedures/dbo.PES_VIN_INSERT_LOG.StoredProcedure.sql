/****** Object:  StoredProcedure [dbo].[PES_VIN_INSERT_LOG]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <4TH AUGUST 2009>
-- Description:	<Inserting into the LOG>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_INSERT_LOG]
	-- Add the parameters for the stored procedure here
	@strLoadNbr varchar(max),
	@RUNSEQnbr varchar(max),
	@PROGRAM_VERSION varchar(max),
	@PARSER_VERSION varchar(max)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	declare @totalBillCnt int
	select @totalBillCnt = count(*) from 
		pes.dbo.archive_raw_bol  WITH (NOLOCK)  where load_number = @strLoadNbr
	
	insert into pes.dbo.VIN_LOG 
		(LOAD_NBR,
		RUN_SEQ_NBR,
		COMPL_STATUS,
		PROGRAM_VERSION,
		PARSER_VERSION,
		START_DT,
		STOP_DT,
		TOT_BL_CNT)
	values 
		(@strLoadNbr,
		@RUNSEQnbr,
		'-1',
		@PROGRAM_VERSION,
		@PARSER_VERSION,
		getdate(),
		'',
		@totalBillCnt
	)

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
