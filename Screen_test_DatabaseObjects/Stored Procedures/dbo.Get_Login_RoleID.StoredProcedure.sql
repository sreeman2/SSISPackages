/****** Object:  StoredProcedure [dbo].[Get_Login_RoleID]    Script Date: 01/03/2013 19:47:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <3rd Nov 2010>
-- Description:	<Procedure to check for the User Login and Password>
-- =============================================
CREATE PROCEDURE [dbo].[Get_Login_RoleID]
	-- Add the parameters for the stored procedure here
	@userName varchar(max),
	@userPWD varchar(max)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	select a.[USER_ID], a.[USER_NAME], a.USER_PWD, 
		b.ROLE_ID,
		c.ROLE_NAME,c.READ_ONLY,c.STND_FLG  
	from PEA_USER a WITH (NOLOCK), PEA_USER_ROLE b WITH (NOLOCK), PEA_ROLE c WITH (NOLOCK) 
	where a.[USER_ID]=b.[USER_ID] 
		and b.[ROLE_ID]=c.[ROLE_ID] 
		and a.[USER_NAME]= @userName
		and a.[USER_PWD]= @userPWD
		AND c.PROJECT_CD = 1

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
