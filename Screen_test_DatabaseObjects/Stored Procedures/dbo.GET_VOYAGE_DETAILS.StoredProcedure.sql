/****** Object:  StoredProcedure [dbo].[GET_VOYAGE_DETAILS]    Script Date: 01/03/2013 19:47:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <17TH NOV 2010>
-- Description:	<GET THE VOYAGE DETAILS FOR VALIDATION>
-- =============================================
CREATE PROCEDURE [dbo].[GET_VOYAGE_DETAILS]
	-- Add the parameters for the stored procedure here
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

	SELECT [SCAC], [VESSEL_CD], [VOYAGE_NBR], [PORT_UNLADING_CD], [ACT_ARRIVAL_DT], 
		[ACT_MANIFEST_NBR], [VOYAGE_STATUS], [REMARKS], [VESSEL_NAME], 
		[VESSEL_ID], [CARRIER_ID], [USPORT_ID], [GLOBAL_UPDATE], 
		[US_PORTNAME] 
	FROM [SCREEN_TEST].[dbo].[DQA_VOYAGE] WITH (NOLOCK) 
	WHERE [VOYAGE_ID] IN (SELECT [VALUE] FROM PES.DBO.[SPLIT](@VOYAGE_ID,','))

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
