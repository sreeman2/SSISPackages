/****** Object:  StoredProcedure [dbo].[GET_VOYAGE_STATUS]    Script Date: 01/03/2013 19:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <8th Nov 2010>
-- Description:	<Get the Voyage Status>
-- =============================================
CREATE PROCEDURE [dbo].[GET_VOYAGE_STATUS]
	-- Add the parameters for the stored procedure here
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	SELECT VOYAGE_STATUS, VOYAGE_STATUS_NAME FROM DQA_VOYAGE_STATUS WITH (NOLOCK) 
	WHERE VOYAGE_STATUS <> 'INPROCESS'

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
