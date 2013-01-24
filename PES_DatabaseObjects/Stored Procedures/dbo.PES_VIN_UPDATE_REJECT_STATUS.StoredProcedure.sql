/****** Object:  StoredProcedure [dbo].[PES_VIN_UPDATE_REJECT_STATUS]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <6TH AUGUST 2009>
-- Description:	<Updating the status ACCEPT/REJECT for the VIN Exceptions>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_UPDATE_REJECT_STATUS]
	-- Add the parameters for the stored procedure here
	@REJECT_IDS VARCHAR(MAX)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE SCREEN_TEST.DBO.VIN_CACHE SET STATUS = 'REJECT', OWNER='QA'
		WHERE ID IN (SELECT * FROM PES.DBO.SPLIT(@REJECT_IDS,','))

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
