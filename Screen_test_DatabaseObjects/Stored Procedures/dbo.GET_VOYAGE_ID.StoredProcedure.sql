/****** Object:  StoredProcedure [dbo].[GET_VOYAGE_ID]    Script Date: 01/03/2013 19:47:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <17th Nov 2010>
-- Description:	<>
-- =============================================
CREATE PROCEDURE [dbo].[GET_VOYAGE_ID]	
	@VESSEL_ID NUMERIC(12,0) =NULL,
	@CARRIER_ID NUMERIC(12,0)=NULL,
	@USPORT_ID NUMERIC(12,0)=NULL,
	@VOYAGE_NBR CHAR(5)=NULL
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	SELECT VOYAGE_ID FROM [SCREEN_TEST].[dbo].[DQA_VOYAGE] WITH (NOLOCK) 
	WHERE ISNULL([VESSEL_ID], -1) = ISNULL(@VESSEL_ID, -1) 
		AND ISNULL([CARRIER_ID], -1) = ISNULL(@CARRIER_ID, -1)
		AND ISNULL([USPORT_ID], -1) = ISNULL(@USPORT_ID ,-1)
		AND ISNULL([VOYAGE_NBR], -1) = ISNULL(@VOYAGE_NBR, -1)

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
