/****** Object:  StoredProcedure [dbo].[UPDATE_LIB_PORT]    Script Date: 01/03/2013 19:48:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <16th July 2009>
-- Description:	<Updating the PORT PERMUTATION Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_LIB_PORT]  
	-- Add the parameters for the stored procedure here
   @perm varchar(max),
   @REF_ID float(53),
   @modif_by varchar(max),
   @ID FLOAT(53),
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

	SELECT @RECCOUNT=COUNT(*) FROM [PES].[dbo].[LIB_PORT] WITH (NOLOCK)
		WHERE NAME_KEY=@perm AND REF_ID=@REF_ID
			AND IS_US_PORT = 1

	IF @RECCOUNT=0
		BEGIN
			UPDATE PES.DBO.LIB_PORT WITH (UPDLOCK) SET
			NAME_KEY = @perm,
			MODIFY_DATE = getdate(),
			MODIFY_USER = @modif_by
			WHERE ID = @ID

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
