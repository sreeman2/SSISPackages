/****** Object:  StoredProcedure [dbo].[INSERT_NEW_HIST_CARRIER]    Script Date: 01/03/2013 19:47:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <14th Oct 2009>
-- Description:	<Inserting a NEW CARRIER PERMUTATION Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_NEW_HIST_CARRIER]
	-- Add the parameters for the stored procedure here
	@perm varchar(max),
	@carrier varchar(max),
	@modif_by varchar(max),
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

	SET @REF_ID = ISNULL((SELECT TOP 1 ID FROM [PES].[DBO].[REF_CARRIER] WITH (NOLOCK) WHERE [CODE] = @carrier),-1)

	IF @REF_ID = -1
		SET @RETURN_VALUE = 0
	ELSE
		BEGIN
			SELECT @RECCOUNT = count(*) FROM [PES].[dbo].[LIB_CARRIER] L WITH (NOLOCK)
			INNER JOIN [PES].[DBO].[REF_CARRIER] R
			ON L.REF_ID = R.ID
			WHERE L.CODE_KEY= @perm AND R.[CODE] = @carrier

			IF @RECCOUNT=0
				BEGIN
					INSERT INTO [PES].[dbo].[LIB_CARRIER]
						   ([CODE_KEY]
						   ,[NAME_KEY]
						   ,[REF_ID]
						   ,[ACTIVE]
						   ,[MODIFY_DATE]
						   ,[MODIFY_USER])
					VALUES
						   (@perm
						   ,@carrier
						   ,@REF_ID
						   ,'Y'
						   ,GETDATE()
						   ,@modif_by)
					SET @RETURN_VALUE = (select max(id) from PES.dbo.lib_CARRIER WITH (NOLOCK))
					SELECT [TYPE] FROM [PES].[DBO].[REF_CARRIER] WITH (NOLOCK) WHERE ID = @REF_ID AND CODE = @carrier
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
