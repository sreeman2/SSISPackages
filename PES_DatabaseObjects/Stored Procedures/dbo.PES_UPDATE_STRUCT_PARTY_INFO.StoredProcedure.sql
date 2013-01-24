/****** Object:  StoredProcedure [dbo].[PES_UPDATE_STRUCT_PARTY_INFO]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <26th August 2009>
-- Description:	<Procedure to save the structured Party information>
-- =============================================
CREATE PROCEDURE [dbo].[PES_UPDATE_STRUCT_PARTY_INFO] 
	-- Add the parameters for the stored procedure here
	@PTY_NAME VARCHAR(150),
	@PTY_ADDR1 VARCHAR(125),
	@PTY_ADDR2 VARCHAR(125),
	@PTY_CITY VARCHAR(125),
	@PTY_STATE VARCHAR(9),
	@PTY_ZIP VARCHAR(15),
	@USER_ID VARCHAR(10),
	@SCNA_nbr INT,
	@PTY_CNTRY_CODE VARCHAR(3),
	@STR_PTY_ID INT

AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE PES.DBO.PES_MATCH_PTY WITH (UPDLOCK)
	SET 
		STR_NAME = @PTY_NAME,
		STR_ADDR_1 = @PTY_ADDR1,
		STR_ADDR_2 = @PTY_ADDR2,
		STR_CITY = @PTY_CITY,
		STR_CTRY_CODE = @PTY_CNTRY_CODE,
		STR_ST = @PTY_STATE,
		STR_ZIP = @PTY_ZIP,
		IS_STRUCTURED = 'Y',
		MODIFIED_BY = @USER_ID,
		MODIFIED_DT = GETDATE()
	WHERE MATCH_PTY_ID = @SCNA_nbr
	AND IS_STRUCTURED = 'N'

	UPDATE PES.DBO.PES_STRUCTURED_PTY WITH (UPDLOCK)
	SET
		STR_PTY_STATUS = 'CLEANSED',
		[NAME] = @PTY_NAME,
		ADDR_1 = @PTY_ADDR1,
		ADDR_2 = @PTY_ADDR2,
		CITY = @PTY_CITY,
		CTRY_CODE = @PTY_CNTRY_CODE,
		ST = @PTY_STATE,
		ZIP = @PTY_ZIP,
		MODIFIED_BY = @USER_ID,
		MODIFIED_DT = GETDATE()
	WHERE STR_PTY_ID = @STR_PTY_ID

	UPDATE PES.DBO.PES_TRANSACTIONS_EXCEPTIONS_PTY WITH (UPDLOCK)
	SET STATUS = 'CLEANSED',
		MODIFIED_BY = @USER_ID,
		MODIFIED_DT = GETDATE()
	WHERE STR_PTY_ID = @STR_PTY_ID

--	DECLARE @TEMP_TNBR NUMERIC(10,0)
--	DECLARE @TEMP_MATCH_PTY_ID INT
--	SET @TEMP_TNBR = (SELECT TOP 1 T_NBR FROM SCREEN_TEST.DBO.BL_CACHE  WITH (NOLOCK) 
--		 WHERE 
--			SH_NBR = @SCNA_nbr OR CH_NBR = @SCNA_nbr
--			OR NH_NBR = @SCNA_nbr OR AH_NBR = @SCNA_nbr)
--	SET @TEMP_MATCH_PTY_ID = (SELECT MATCH_PTY_ID FROM PES_MATCH_PTY  WITH (NOLOCK) 
--			WHERE MATCH_PTY_ID = @SCNA_nbr)
--
--	DECLARE @TEMP_PTY_COUNT INT
--	SELECT @TEMP_PTY_COUNT = COUNT(*) FROM PES_TEMP_PTY_STR
--	WHERE BOL_ID = @TEMP_TNBR AND STR_PTY_ID = @TEMP_MATCH_PTY_ID
--	IF @TEMP_PTY_COUNT = 0
--	BEGIN
--		INSERT INTO PES_TEMP_PTY_STR
--		(BOL_ID, STR_PTY_ID, MATCH_PTY_ID)
--		VALUES (
--			@TEMP_TNBR, 
--			@STR_PTY_ID,
--			@SCNA_nbr)
--	END


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
