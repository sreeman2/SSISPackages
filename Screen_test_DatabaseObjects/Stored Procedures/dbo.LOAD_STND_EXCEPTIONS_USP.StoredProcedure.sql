/****** Object:  StoredProcedure [dbo].[LOAD_STND_EXCEPTIONS_USP]    Script Date: 01/03/2013 19:48:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_STND_EXCEPTIONS_USP]
	@EXCP_FILTER VARCHAR(50)
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


	SELECT DISTINCT PROCESS_NAME 
	FROM dbo.[CTRL_PROCESS_DEFINITION] WITH (NOLOCK)
	WHERE ( PROCESS_NAME LIKE '%CHEM OR CHEMICAL(S)%' ) --@EXCP_FILTER 

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
