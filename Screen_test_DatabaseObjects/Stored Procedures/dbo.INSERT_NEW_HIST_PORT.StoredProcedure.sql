/****** Object:  StoredProcedure [dbo].[INSERT_NEW_HIST_PORT]    Script Date: 01/03/2013 19:47:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CTS - 25th January 2010
--ADDED A NEW FIELD, PORT_CODE FOR FETCHING THE DATA
--REFER CR#2702

--CTS - 8th January 2010
--CHANGED THE CHECK FROM PORT_NAME TO PIERS_NAME
--REFER CR#2702


-- =============================================
-- Author:		<CTS>
-- Create date: <15th Oct 2009>
-- Description:	<Inserting a NEW US PORT PERMUTATION Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_NEW_HIST_PORT]
	-- Add the parameters for the stored procedure here
	@perm varchar(max),
	@piersname varchar(max),
	@modif_by varchar(max),
	@port_code varchar(max),
	@RETURN_VALUE INT OUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @RECCOUNT int
	DECLARE @REF_ID INT

	--SET @REF_ID = ISNULL((SELECT TOP 1 ID FROM [PES].[DBO].[REF_PORT] WHERE PORT_NAME = @piersname),-1)

--	SET @REF_ID = ISNULL((SELECT TOP 1 ID FROM [PES].[DBO].[REF_PORT] 
--							WHERE PIERS_NAME = @piersname AND IS_US_PORT = 1),-1)

	SELECT @REF_ID = COUNT(*) FROM PES.DBO.REF_PORT WITH (NOLOCK)
					WHERE PIERS_NAME = @piersname
						AND CODE = @port_code
						AND IS_US_PORT = 1

	IF @REF_ID = 0
		SET @RETURN_VALUE = 0
		
	ELSE
		BEGIN
--			SELECT @RECCOUNT = count(*) FROM PES.DBO.LIB_PORT L
--			INNER JOIN PES.DBO.REF_PORT R
--			ON L.REF_ID = R.ID
--			WHERE L.NAME_KEY = @perm
--			AND R.PORT_NAME = @piersname
--			AND L.IS_US_PORT = 1

			SELECT @RECCOUNT = count(*) FROM PES.DBO.LIB_PORT L WITH (NOLOCK)
			INNER JOIN PES.DBO.REF_PORT R WITH (NOLOCK)
			ON L.REF_ID = R.ID
			WHERE L.NAME_KEY = @perm
			AND R.PIERS_NAME = @piersname
			AND R.CODE = @port_code
			AND L.IS_US_PORT = 1

			IF @RECCOUNT=0
				BEGIN
					SELECT @REF_ID=[ID] FROM [PES].[DBO].[REF_PORT] WITH (NOLOCK)
								WHERE PIERS_NAME = @piersname AND CODE = @port_code
								AND IS_US_PORT = 1
					INSERT INTO [PES].[dbo].[LIB_PORT]
						   ([CODE_KEY]
						   ,[NAME_KEY]
						   ,[REF_ID]
						   ,[ACTIVE]
						   ,[MODIFY_DATE]
						   ,[MODIFY_USER]
						   ,[IS_US_PORT])
					VALUES
						   (NULL
						   ,@perm
						   ,@REF_ID
						   ,'Y'
						   ,GETDATE()
						   ,@modif_by
						   ,1)
					SET @RETURN_VALUE = (select max(id) from PES.dbo.lib_PORT WITH (NOLOCK))
--					SELECT [ID] FROM [PES].[DBO].[REF_PORT] WHERE ID = @REF_ID AND PORT_NAME = @piersname
--						AND IS_US_PORT = 1
					SELECT [ID] FROM [PES].[DBO].[REF_PORT] WITH (NOLOCK)
						WHERE PIERS_NAME = @piersname AND CODE = @port_code
						AND IS_US_PORT = 1
				END
			ELSE
				SET @RETURN_VALUE = 1
		END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
