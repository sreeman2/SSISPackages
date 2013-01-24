/****** Object:  StoredProcedure [dbo].[INSERT_NEW_HIST_VESSEL]    Script Date: 01/03/2013 19:47:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <14th Oct 2009>
-- Description:	<Inserting a NEW VESSEL PERMUTATION Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_NEW_HIST_VESSEL]
	-- Add the parameters for the stored procedure here
	@perm varchar(max),
	@vessel varchar(max),
	@modif_by varchar(max),
	@RETURN_VALUE INT OUT
AS
BEGIN

SET NOCOUNT ON

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @RECCOUNT int

	--SET @REF_ID = ISNULL((SELECT ID FROM [PES].[DBO].[REF_VESSEL] WHERE STND_VESSEL = @vessel),-1)

	SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_VESSEL WITH (NOLOCK)
		WHERE STND_VESSEL = @vessel

	IF @RECCOUNT>0
		BEGIN
			SELECT @RECCOUNT = count(*) FROM [PES].[dbo].[LIB_VESSEL] WITH (NOLOCK)
				WHERE NAME_KEY= @perm AND REF_NAME = @vessel
			IF @RECCOUNT=0
				BEGIN
					INSERT INTO [PES].[dbo].[LIB_VESSEL]
						   ([CODE_KEY]
						   ,[NAME_KEY]
						   ,[REF_NAME]
						   ,[ACTIVE]
						   ,[MODIFY_DATE]
						   ,[MODIFY_USER])
					VALUES
						   (NULL
						   ,@perm
						   ,@vessel
						   ,'Y'
						   ,GETDATE()
						   ,@modif_by)
					SET @RETURN_VALUE = (select max(id) from PES.dbo.lib_vessel)
					SELECT [STND_VESSEL], [ID], @RETURN_VALUE FROM [PES].[DBO].[REF_VESSEL] WITH (NOLOCK)
						WHERE STND_VESSEL = @vessel
				END
			ELSE
				SET @RETURN_VALUE = 1
		END	
	ELSE
		SET @RETURN_VALUE = 0

--	IF @REF_ID = -1
--		SET @RETURN_VALUE = 0
--	ELSE
--		BEGIN
--			SELECT @RECCOUNT = count(*) FROM [PES].[dbo].[LIB_VESSEL] L
--			INNER JOIN [PES].[DBO].[REF_VESSEL] R
--			ON L.REF_ID = R.ID
--			WHERE L.NAME_KEY= @perm AND R.STND_VESSEL = @vessel
--
--			IF @RECCOUNT=0
--				BEGIN
--					--SET @REF_ID = (SELECT ID FROM [PES].[DBO].[REF_VESSEL] WHERE STND_VESSEL = @vessel)
--					INSERT INTO [PES].[dbo].[LIB_VESSEL]
--						   ([CODE_KEY]
--						   ,[NAME_KEY]
--						   ,[REF_ID]
--						   ,[ACTIVE]
--						   ,[MODIFY_DATE]
--						   ,[MODIFY_USER])
--					VALUES
--						   (NULL
--						   ,@perm
--						   ,@REF_ID
--						   ,'Y'
--						   ,GETDATE()
--						   ,@modif_by)
--					SET @RETURN_VALUE = (select max(id) from PES.dbo.lib_vessel)
--					SELECT [NAME], [ID], @RETURN_VALUE FROM [PES].[DBO].[REF_VESSEL] WHERE STND_VESSEL = @vessel
--				END
--			ELSE
--				SET @RETURN_VALUE = 1
--		END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END


SET NOCOUNT OFF
GO
