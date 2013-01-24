/****** Object:  StoredProcedure [dbo].[PES_GET_STRUCT_PARTY_INFO]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <26th August 2009>
-- Description:	<Retreive Structured Party Information>
-- =============================================
CREATE PROCEDURE [dbo].[PES_GET_STRUCT_PARTY_INFO] 
	-- Add the parameters for the stored procedure here
	@SCNA_nbr INT,
	@strPtyId INT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @RECCOUNT INT

	SELECT @RECCOUNT=COUNT(*) FROM PES_STRUCTURED_PTY PSP, PES_MATCH_PTY PMP
	WHERE PMP.MATCH_PTY_ID = @SCNA_nbr
		AND PMP.IS_STRUCTURED = 'Y'
		AND PSP.MATCH_PTY_ID = PMP.MATCH_PTY_ID 
		AND PSP.STR_PTY_ID = @strPtyId

	IF @RECCOUNT > 0
	BEGIN
--		DECLARE @TEMP_TNBR NUMERIC(12,0)
--		SET @TEMP_TNBR = (SELECT BOL_ID FROM PES_STRUCTURED_PTY 
--							WHERE STR_PTY_ID = @strPtyId)
--
--		DECLARE @STRUCT_COUNT INT
--		SELECT @STRUCT_COUNT=COUNT(*) FROM PES_TEMP_PTY_STR
--			WHERE BOL_ID = @TEMP_TNBR
--			AND STR_PTY_ID = @strPtyId
--
--		IF @STRUCT_COUNT = 0
--		BEGIN
--			INSERT INTO PES_TEMP_PTY_STR
--			(BOL_ID, STR_PTY_ID, MATCH_PTY_ID)
--			VALUES (
--				CAST(@TEMP_TNBR AS INT), 
--				@strPtyId, 
--				@SCNA_nbr)
--		END

		SELECT STR_NAME, STR_ADDR_1, STR_ADDR_2, STR_CITY,
			STR_ST, STR_ZIP
		FROM PES_MATCH_PTY  WITH (NOLOCK) 
		WHERE MATCH_PTY_ID = @SCNA_nbr
	END
		

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
