/****** Object:  StoredProcedure [dbo].[UPDATE_DQA_BL_LOCKS_USP]    Script Date: 01/03/2013 19:48:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_DQA_BL_LOCKS_USP]
	@T_NBR_LIST AS VARCHAR(MAX)	,
	@USERID AS VARCHAR(25)		,
	@EDIT_MODE VARCHAR(12)
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


UPDATE DBO.[DQA_BL] WITH(UPDLOCK) 
SET LOCKED_BY_USR = @USERID		, 
	LOCKED_BY_DATE = GETDATE()	, 
	EDIT_MODE = @EDIT_MODE 
WHERE T_NBR IN (SELECT [VALUE] FROM PES.DBO.[SPLIT](@T_NBR_LIST,',') )

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
