/****** Object:  StoredProcedure [dbo].[UPDATE_LIB_VESSEL]    Script Date: 01/03/2013 19:48:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CTS-MODIFIED ON 13-01-2010
--CHANGES REQUIRED FOR VESSEL DICTIONARY MIGRATION

-- =============================================
-- Author:		<CTS>
-- Create date: <15th July 2009>
-- Description:	<Updating the VESSEL PERMUTATION Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_LIB_VESSEL]  
	-- Add the parameters for the stored procedure here
   @perm varchar(max),
--   @ref_id float(53),
   @vessel varchar(max),
   @modif_by varchar(max),
   @id varchar(max),
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

--	SELECT @RECCOUNT=COUNT(*) FROM [PES].[dbo].[LIB_VESSEL]
--		WHERE NAME_KEY=@perm AND REF_ID=@ref_id

	SELECT @RECCOUNT=COUNT(*) FROM [PES].[dbo].[LIB_VESSEL] WITH (NOLOCK)
		WHERE NAME_KEY=@perm AND REF_NAME=@vessel

	IF @RECCOUNT=0
		BEGIN
			UPDATE PES.DBO.LIB_VESSEL WITH (UPDLOCK) SET
			NAME_KEY = @perm,
			MODIFY_DATE = getdate(),
			MODIFY_USER = @modif_by
			WHERE ID = @id

			SET @RETURN_VALUE = 0
		END
	ELSE
		BEGIN
			SET @RETURN_VALUE = 1
		END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
