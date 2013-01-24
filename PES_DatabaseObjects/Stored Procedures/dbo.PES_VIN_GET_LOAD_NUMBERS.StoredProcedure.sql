/****** Object:  StoredProcedure [dbo].[PES_VIN_GET_LOAD_NUMBERS]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <4TH AUGUST 2009>
-- Description:	<Retreiving the Load numbers for VIN Extraction>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_GET_LOAD_NUMBERS]  
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	select loadnumber from pes.dbo.pes_progress_status  WITH (NOLOCK) 
	where file_process_status = 'COMPLETE' 
	and	VIN_STATUS=0

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
