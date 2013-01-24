/****** Object:  StoredProcedure [dbo].[RETREIVE_USER_ROLES_USP]    Script Date: 01/03/2013 19:48:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RETREIVE_USER_ROLES_USP]
	@p_USER_NAME VARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	SELECT 
	pr.ROLE_ID As RoleId, 
	pr.ROLE_NAME As RoleName, 
	ISNULL(pr.READ_ONLY, '') As ReadOnlyMode
FROM PEA_ROLE pr JOIN PEA_USER_ROLE pur 
ON pr.ROLE_ID =pur.ROLE_ID
JOIN PEA_USER pu ON pu.[USER_ID] = pur.[USER_ID]
WHERE ( pu.[USER_NAME] = @p_USER_NAME )
AND ( pr.PROJECT_CD = 1 )



-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
