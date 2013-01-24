/****** Object:  StoredProcedure [dbo].[GET_USER_MENUS]    Script Date: 01/03/2013 19:47:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <3rd Nov 2010>
-- Description:	<Fetch the Menu Items based on the User Role>
-- =============================================
CREATE PROCEDURE [dbo].[GET_USER_MENUS] 
	-- Add the parameters for the stored procedure here
	@Role_ID int
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	SELECT M.MENU_NAME 
	FROM DQA_MENU M WITH (NOLOCK), DQA_ROLE_MENU RM WITH (NOLOCK) 
	WHERE RM.USER_ROLE_ID = @Role_ID
		AND RM.MENU_ID = M.MENU_ID

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
