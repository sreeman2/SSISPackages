/****** Object:  StoredProcedure [dbo].[SKIP_EXCEPTION_BILLS_TEST]    Script Date: 01/03/2013 19:48:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SKIP_EXCEPTION_BILLS_TEST]
	@T_NBR NUMERIC(12,0)		,	
	@EXCP_TYPE VARCHAR(50)		,
	@SKIP_REASON VARCHAR(MAX)	,
	@SKIP_BY VARCHAR(50)		,
	@GRP_T_NBR_LST VARCHAR(MAX) = NULL
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


DECLARE @CMPNY_STR_PTY AS TABLE(STR_PTY_ID INT)
--DECLARE @TRN_NBR_TBL AS TABLE(T_NBR INT)

--DECLARE @COUNT AS INT 
--DECLARE @POSITION AS INT
--DECLARE @LENTH AS INT
--DECLARE @T_NBR1 AS VARCHAR(25)

--SET @COUNT		= LEN(@GRP_T_NBR_LST)
--SET	@POSITION	= 0
--
--WHILE ( @COUNT > 0 )
--BEGIN
--	SET @LENTH	= CHARINDEX(',',@GRP_T_NBR_LST)	
--	
--	IF ( @LENTH <= 0 )
--	BEGIN
--		INSERT INTO @TRN_NBR_TBL
--		SELECT CAST(@GRP_T_NBR_LST AS INT)
--
--		BREAK
--	END
--	ELSE
--	BEGIN	
--		SET @T_NBR1	= SUBSTRING(@GRP_T_NBR_LST, @POSITION,  @LENTH)	
--
--		INSERT INTO @TRN_NBR_TBL
--		SELECT CAST(@T_NBR1 AS INT)
--		
--		SET @GRP_T_NBR_LST	= SUBSTRING(@GRP_T_NBR_LST, @LENTH+1, (LEN(@GRP_T_NBR_LST) - (LEN(@T_NBR1)+1)) )
--		SET @COUNT			= @COUNT - (LEN(@T_NBR1)+1)
--	END 
--END


IF ( @EXCP_TYPE = 'COMPANY EXCEPTIONS' )
BEGIN
	INSERT INTO @CMPNY_STR_PTY
	SELECT STR_PTY_ID FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)
	WHERE ( BOL_ID = @T_NBR ) AND ( STATUS <> 'CLEANSED' ) 	
END

IF EXISTS (SELECT STR_PTY_ID FROM @CMPNY_STR_PTY )
BEGIN
	IF NOT EXISTS 
	( 
		SELECT T_NBR FROM DBO.DQA_SKIPPED_STDN_BOL WITH (NOLOCK)
		WHERE ( ( PROCESS_NAME = @EXCP_TYPE ) AND ( SKIPPED_BY = @SKIP_BY )
		AND ( DELETED = 0 ) AND T_NBR =  @T_NBR )
	)
	BEGIN
		INSERT INTO dbo.DQA_SKIPPED_STDN_BOL ( 
			T_NBR			, 
			STR_PTY_ID		, 
			PROCESS_NAME	, 
			REASON_FOR_SKIP	, 
			SKIPPED_BY 
		)
		SELECT 
			@T_NBR		,
			STR_PTY_ID	, 
			@EXCP_TYPE	, 
			@SKIP_REASON, 
			@SKIP_BY 
		FROM @CMPNY_STR_PTY
	END
END
--ELSE IF ( LEN(@GRP_T_NBR_LST) > 0 )
--BEGIN
--	--Add T_NBR
--	INSERT INTO @TRN_NBR_TBL
--	SELECT @T_NBR
--
--	INSERT INTO dbo.DQA_SKIPPED_STDN_BOL ( 
--		T_NBR			, 
--		STR_PTY_ID		, 
--		PROCESS_NAME	, 
--		REASON_FOR_SKIP	, 
--		SKIPPED_BY 
--	)
--	SELECT 
--		T_NBR , NULL,  @EXCP_TYPE, @SKIP_REASON, @SKIP_BY 
--	FROM DQA_BL WITH (NOLOCK)
--	WHERE T_NBR IN (SELECT T_NBR FROM @TRN_NBR_TBL)
--END
ELSE
BEGIN
	IF NOT EXISTS 
	( 
		SELECT T_NBR FROM DBO.DQA_SKIPPED_STDN_BOL WITH (NOLOCK)
		WHERE ( ( PROCESS_NAME = @EXCP_TYPE ) AND ( SKIPPED_BY = @SKIP_BY )
		AND ( DELETED = 0 ) AND T_NBR =  @T_NBR )
	)
	BEGIN
		INSERT INTO dbo.DQA_SKIPPED_STDN_BOL ( 
			T_NBR			, 
			STR_PTY_ID		, 
			PROCESS_NAME	, 
			REASON_FOR_SKIP	, 
			SKIPPED_BY 
		)
		VALUES (
			@T_NBR		,
			NULL	, 
			@EXCP_TYPE	, 
			@SKIP_REASON, 
			@SKIP_BY 
		)
	END
END

	IF ( @EXCP_TYPE = 'COMPANY EXCEPTIONS' )
	BEGIN
		UPDATE PES.dbo.[PES_TRANSACTIONS_LIB_PTY]
		SET SKIPPED = 1 
		WHERE ( BOL_ID = @T_NBR ) 
	END
	ELSE
	BEGIN
		--UPDATE CTRL_PROCESS_VOYAGE table with the skipped VALUE
		UPDATE dbo.[CTRL_PROCESS_VOYAGE]
		SET SKIPPED = 1 
		WHERE ( T_NBR = @T_NBR ) AND ( PROCESS_NAME = @EXCP_TYPE )
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
