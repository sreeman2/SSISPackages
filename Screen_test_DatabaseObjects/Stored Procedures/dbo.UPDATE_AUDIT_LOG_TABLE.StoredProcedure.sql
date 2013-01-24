/****** Object:  StoredProcedure [dbo].[UPDATE_AUDIT_LOG_TABLE]    Script Date: 01/03/2013 19:48:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_AUDIT_LOG_TABLE]
	   @T_NBR_LST VARCHAR(MAX),
	   @CMD_ID_LST VARCHAR(MAX) = NULL,
       @RECNUM varchar(8) = NULL,
       @EXCEPTION_TYPE varchar(50),
--     @COMPANY_SOURCE varchar(1),
       @MODIFY_BY varchar(25),
       @DATA_BEFORE varchar(255) = NULL,
       @DATA_AFTER varchar(255) =  NULL,
--     @RECORD_STATUS varchar(50),
	   @USER_TYPE TINYINT =  1, -- 1-STANDARDIZATION, 2 - ADMIN
	   @COMMODITY_DATA_XML XML = NULL,	
	   @IS_BL_DELETED BIT =  0,
	   @IS_CMD_DELETED BIT = 0
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;

-- [Pramod K] - 09/24/2010
-- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@T_NBR_LST='''+@T_NBR_LST+''''
--+', @EXCEPTION_TYPE='''+@EXCEPTION_TYPE+''''
--+', @DATA_BEFORE='+COALESCE(''''+@DATA_BEFORE+'''', 'NULL')
--+', @MODIFY_BY='''+@MODIFY_BY+''''
--
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'UPDATE_AUDIT_LOG_TABLE'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT



DECLARE @PTY_SRC_TABLE AS TABLE (T_NBR NUMERIC(12,0), PTY_SRC VARCHAR(1))
DECLARE @COMMODITY_DATA_TBL AS TABLE (CMD_ID NUMERIC(12,0), CMD_CODE CHAR(10), JOC_CODE CHAR(10) )

DECLARE @T_NBR_XML AS XML
DECLARE @CMD_ID_XML AS XML

DECLARE @HNDLR AS INT

SET @T_NBR_XML = '<I>' + REPLACE(@T_NBR_LST, ',', '</I><I>') + '</I>'
SET @CMD_ID_XML = '<J>' + REPLACE(@CMD_ID_LST, ',', '</J><J>') + '</J>'

IF ( @COMMODITY_DATA_XML IS NOT NULL )
BEGIN
	EXEC SP_XML_PREPAREDOCUMENT @HNDLR OUTPUT, @COMMODITY_DATA_XML 

	INSERT INTO @COMMODITY_DATA_TBL
	SELECT	ID, 
			(CASE WHEN CMDCD = '' THEN NULL ELSE CMDCD END ), 
			(CASE WHEN JOCCODE = '' THEN NULL ELSE JOCCODE END ) 
	FROM OPENXML(@HNDLR, '/ROOT/COMMODITY' ,2) WITH (ID VARCHAR(10),CMDCD CHAR(10), JOCCODE CHAR(10))
END

--If Exception type is of the type  Company Exceptions
IF ( @EXCEPTION_TYPE = 'COMPANY EXCEPTIONS' )
BEGIN
	--Get the Party Source for the Bills
	INSERT INTO @PTY_SRC_TABLE
	SELECT BOL_ID, SOURCE FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY 
	WHERE ( BOL_ID IN ( SELECT	X.I.value('.', 'Numeric(12,0)') FROM @T_NBR_XML.nodes('//I') AS X(I) ) 
	AND ( MODIFIED_BY = @MODIFY_BY ) )

	INSERT INTO [SCREEN_TEST].[dbo].[PES_AUDIT_LOGS]
		(
			[T_NBR]			,
			[EXCEPTION_TYPE],
			[COMPANY_SOURCE],
			[MODIFY_BY]		,
			[USER_TYPE]		,
			[BILL_DELETED]	
		)
		SELECT	X.I.value('.', 'Numeric(12,0)') ,
			@EXCEPTION_TYPE	, 
			PTY_SRC			, 
			@MODIFY_BY		, 
			@USER_TYPE		,
			@IS_BL_DELETED	
		FROM @T_NBR_XML.nodes('//I') AS X(I) JOIN @PTY_SRC_TABLE AS PTY_SRC 
		ON X.I.value('.', 'Numeric(12,0)') = PTY_SRC.T_NBR
END
ELSE
BEGIN
	IF EXISTS ( SELECT 1 FROM @COMMODITY_DATA_TBL WHERE CMD_CODE IS NOT NULL OR JOC_CODE IS NOT NULL )
	BEGIN
		-- COMMODITY STANDARDIZATION 
		INSERT INTO [SCREEN_TEST].[dbo].[PES_AUDIT_LOGS]
		(
			[T_NBR]			,
			[CMD_ID]		,
			[EXCEPTION_TYPE],
			[COMPANY_SOURCE],
			[MODIFY_BY]		,
			[USER_TYPE]		,
			[BILL_DELETED]	,
			[CMD_DELETED]	,
			[CMD_CODE]		,
			[JOC_CODE]
		)
		SELECT	X.I.value('.', 'Numeric(12,0)') ,
			--Y.J.value('.', 'Numeric(12,0)')	, 
			CMD.CMD_ID			,
			@EXCEPTION_TYPE	, 
			NULL			, 
			@MODIFY_BY		, 
			@USER_TYPE		,
			@IS_BL_DELETED	,
			@IS_CMD_DELETED	,
			CMD.CMD_CODE	,
			CMD.JOC_CODE
		FROM @T_NBR_XML.nodes('//I') AS X(I) CROSS JOIN @COMMODITY_DATA_TBL AS CMD
	END
	ELSE
	BEGIN
		INSERT INTO [SCREEN_TEST].[dbo].[PES_AUDIT_LOGS]
		(
			[T_NBR]			,
			[EXCEPTION_TYPE],
			[COMPANY_SOURCE],
			[MODIFY_BY]		,
			[USER_TYPE]		,
			[BILL_DELETED]	,
			[CMD_DELETED]
		)
		SELECT	X.I.value('.', 'Numeric(12,0)') ,
			@EXCEPTION_TYPE	, 
			NULL			, 
			@MODIFY_BY		, 
			@USER_TYPE		,
			@IS_BL_DELETED	,
			@IS_CMD_DELETED
		FROM @T_NBR_XML.nodes('//I') AS X(I)  
	END
END


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END

--SELECT * FROM CTRL_PROCESS_VOYAGE WHERE T_NBR = 1521185
--SELECT * FROM [dbo].[PES_AUDIT_LOGS] WHERE T_NBR = 1521185
GO
