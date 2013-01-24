/****** Object:  StoredProcedure [dbo].[UPDATE_BL_BL_DETAILS]    Script Date: 01/03/2013 19:48:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <19th NOV 2010>
-- Description:	<Updating the BL_BL table after structuring>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_BL_BL_DETAILS]
	-- Add the parameters for the stored procedure here
	@DQA_OWNER_ID VARCHAR(25),
	@DQA_BL_STATUS VARCHAR(10),
	@T_NBR NUMERIC
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE BL_BL  WITH (UPDLOCK) 
	SET DQA_OWNER_ID=@DQA_OWNER_ID, 
		LAST_UPDATE_DT = GETDATE(), 
		DQA_BL_STATUS = @DQA_BL_STATUS 
	WHERE t_nbr = @T_NBR

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
