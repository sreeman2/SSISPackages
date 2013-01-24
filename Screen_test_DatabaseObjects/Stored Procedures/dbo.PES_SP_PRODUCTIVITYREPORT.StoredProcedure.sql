/****** Object:  StoredProcedure [dbo].[PES_SP_PRODUCTIVITYREPORT]    Script Date: 01/03/2013 19:48:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_PRODUCTIVITYREPORT]
(
  @USERNAME VARCHAR(MAX),
  @FROMDATE VARCHAR(50),
  @TODATE VARCHAR(50),
  @DIRECTION VARCHAR(1)
)
AS
BEGIN
SET NOCOUNT ON;

---- [Pramod K] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@USERNAME='''+@USERNAME+''''
--+', @FROMDATE='''+@FROMDATE+''''
--+', @TODATE='''+@TODATE+''''
--+', @DIRECTION='''+@DIRECTION+''''
----+', @TODATE='+COALESCE(''''+@TODATE+'''','NULL')
--
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'PES_SP_PRODUCTIVITYREPORT'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@USERNAME='''+@USERNAME+''''
+', @FROMDATE='''+@FROMDATE+''''
+', @TODATE='''+@TODATE+''''
+', @DIRECTION='''+@DIRECTION+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	DECLARE @FRMDATE DATETIME,
			@TOODATE DATETIME,
            @USERXML XML

	SELECT @FRMDATE = CONVERT(DATETIME, @FROMDATE),
		   @TOODATE = CONVERT(DATETIME, @TODATE)
    
    SELECT @USERXML = DBO.XMLOFUSERS(@USERNAME)

	SELECT DQA_OWNER_ID, BEF6AM, AM6CNT, AM7CNT, AM8CNT, AM9CNT, 
		   AM10CNT, AM11CNT, PM12CNT, PM1CNT, PM2CNT, PM3CNT, PM4CNT, 
		   PM5CNT, PM6CNT, PM7CNT, AFT7PM, TOTCNT, PERHOUR 
	FROM  dbo.REP1NEW AS REP1NEW WITH (NOLOCK) 
	WHERE CONVERT(DATETIME, REPDATE)  BETWEEN @FRMDATE AND @TOODATE
		AND DQA_OWNER_ID IN(SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I)) 
		AND DIR = @DIRECTION 
	ORDER BY 1

-- [Pramod K] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
