/****** Object:  StoredProcedure [dbo].[GET_PORT_FLAG_USP]    Script Date: 01/03/2013 19:47:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_PORT_FLAG_USP]
	@T_NBR AS NUMERIC(12,0)	,
	@PROCESS_NAME AS VARCHAR(50) 
AS
BEGIN
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


SELECT  FLAG 
FROM dbo.CTRL_PROCESS_VOYAGE  WITH (NOLOCK) 
WHERE ( ( T_NBR = @T_NBR ) AND  ( PROCESS_NAME = @PROCESS_NAME )  )

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
