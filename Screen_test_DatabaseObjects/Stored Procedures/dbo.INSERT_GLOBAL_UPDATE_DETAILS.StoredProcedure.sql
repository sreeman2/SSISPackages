/****** Object:  StoredProcedure [dbo].[INSERT_GLOBAL_UPDATE_DETAILS]    Script Date: 01/03/2013 19:47:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <17th Nov 2010>
-- Description:	<Inserting data into the GLOBAL UPDATE table>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_GLOBAL_UPDATE_DETAILS] 
	-- Add the parameters for the stored procedure here
	@MODIFIED_BY VARCHAR(50),
	@VOYAGE_ID VARCHAR(MAX)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	INSERT INTO [SCREEN_TEST].[dbo].[GLOBAL_UPDATE]
	([US_PORT_ID],[VESSEL_ID],[CARRIER_ID],[VOYAGE_NBR],[VOYAGE_ID],[MODIFIED_BY]) 
	SELECT [USPORT_ID],[VESSEL_ID],[CARRIER_ID],[VOYAGE_NBR],[VOYAGE_ID], @MODIFIED_BY 
	FROM [SCREEN_TEST].[dbo].[DQA_VOYAGE] WITH (NOLOCK) 
	WHERE VOYAGE_ID IN (SELECT [VALUE] FROM PES.DBO.[SPLIT](@VOYAGE_ID,','))

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
