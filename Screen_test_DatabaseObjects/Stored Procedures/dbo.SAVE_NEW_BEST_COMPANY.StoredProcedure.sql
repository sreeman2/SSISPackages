/****** Object:  StoredProcedure [dbo].[SAVE_NEW_BEST_COMPANY]    Script Date: 01/03/2013 19:48:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SAVE_NEW_BEST_COMPANY] 
	-- Add the parameters for the stored procedure here
	@p_STR_PTY_ID AS INT,
	@p_BOL_ID AS INT,
	@p_Source AS CHAR(1),
	@p_Name AS VARCHAR(150),
	@p_Addr_1 AS VARCHAR(125),
	@p_Addr_2 AS VARCHAR(125),
	@p_City AS VARCHAR(125),
	@p_State AS CHAR(9),
	@p_Cntry_cd AS VARCHAR(3),
	@p_Postal_cd AS VARCHAR(15),
	@p_Status AS VARCHAR(50),
	@p_Updated_User AS VARCHAR(50),
	@p_CompID AS INT OUTPUT
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

---- 09/20/2010
---- Log Start Time
--DECLARE @IdLogOut INT
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@p_STR_PTY_ID='''+ CAST(@p_STR_PTY_ID AS VARCHAR(100)) +''''
--+', @p_BOL_ID='''+ CAST(@p_BOL_ID AS VARCHAR(100)) +''''
--+', @p_Name='''+ @p_Name +''''
--+', @p_Addr_1='''+ @p_Addr_1 +''''
--+', @p_Addr_2='''+ @p_Addr_2 +''''
--+', @p_City='''+ @p_City +''''
--+', @p_State='''+ @p_State +''''
--+', @p_Cntry_cd='''+ @p_Cntry_cd +''''
--+', @p_Postal_cd='''+ @p_Postal_cd +''''
--+', @p_Status='''+ @p_Status +''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'SAVE_NEW_BEST_COMPANY'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@p_STR_PTY_ID='''+ CAST(@p_STR_PTY_ID AS VARCHAR(100)) +''''
+', @p_BOL_ID='''+ CAST(@p_BOL_ID AS VARCHAR(100)) +''''
+', @p_Name='''+ @p_Name +''''
+', @p_Addr_1='''+ @p_Addr_1 +''''
+', @p_Addr_2='''+ @p_Addr_2 +''''
+', @p_City='''+ @p_City +''''
+', @p_State='''+ @p_State +''''
+', @p_Cntry_cd='''+ @p_Cntry_cd +''''
+', @p_Postal_cd='''+ @p_Postal_cd +''''
+', @p_Status='''+ @p_Status +''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


INSERT INTO PES.dbo.PES_LIB_NEW_PTY 
(
	STR_PTY_ID, BOL_ID, Source, Name, Addr_1, Addr_2, City, State, Cntry_cd,
	Postal_cd, Status,	Created_By, Created_Dt, Modified_By, Modified_Dt 
)
VALUES 
(
	@p_STR_PTY_ID, @p_BOL_ID, @p_Source, @p_Name, @p_Addr_1, @p_Addr_2,
	@p_City, @p_State, @p_Cntry_cd, @p_Postal_cd, @p_Status, @p_Updated_User,
	GETDATE(), @p_Updated_User, GETDATE() 
)

SET  @p_CompID = SCOPE_IDENTITY()

-- 09/20/2010
-- Log End Time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
