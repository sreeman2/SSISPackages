/****** Object:  StoredProcedure [dbo].[PES_SP_STNDN_PRODUCTIVITY_RPRT]    Script Date: 01/03/2013 19:48:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PES_SP_STNDN_PRODUCTIVITY_RPRT]
	@FROM_DATE	DATETIME	,
	@TO_DATE	DATETIME	,
	@DIR		VARCHAR(1)	,
	@VENDOR_GRP	XML =  NULL,
	@PES_USERS	VARCHAR(MAX) =  NULL,
	@RPT_OWNER_ID VARCHAR(10) =	NULL
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@FROM_DATE='''+CAST(@FROM_DATE AS VARCHAR(100))+''''
+',@TO_DATE='''+CAST(@TO_DATE AS VARCHAR(100))+''''
+', @DIR='''+@DIR+''''
+', @RPT_OWNER_ID='+COALESCE(''''+@RPT_OWNER_ID+'''','NULL')
+', @VENDOR_GRP='+COALESCE(''''+CAST(@VENDOR_GRP As varchar(MAX))+'''','NULL')
+', @PES_USERS='+COALESCE(''''+@PES_USERS+'''','NULL')
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @USERXML XML

---- [Pramod K] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
--  '@FROM_DATE='''+CAST(@FROM_DATE AS VARCHAR(100))+''''
--+',@TO_DATE='''+CAST(@TO_DATE AS VARCHAR(100))+''''
--+', @DIR='''+@DIR+''''
--+', @RPT_OWNER_ID='+COALESCE(''''+@RPT_OWNER_ID+'''','NULL')
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'PES_SP_STNDN_PRODUCTIVITY_RPRT'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT


IF ( @PES_USERS IS NOT NULL  )
BEGIN    
	SELECT @USERXML = DBO.XMLOFUSERS(@PES_USERS)
END

---- Get all the Vendor Groups assigned to the Report generating User.
--SELECT vg.VendorGroupName  
--FROM dbo.[PEA_USER_VENDOR_GRP] AS uvg WITH (NOLOCK) JOIN  dbo.[PEA_VENDOR_GROUP] AS vg WITH (NOLOCK)
--ON ( vg.VendorGroupId = uvg.VendorGroupId )
--WHERE ( uvg.OWNER_ID = @RPT_OWNER_ID )

IF ( @VENDOR_GRP IS NOT NULL )
BEGIN
	SELECT	STND_RPT.MODIFY_BY, 
		STND_RPT.BEF6AM, 
		STND_RPT.AM6CNT, 
		STND_RPT.AM7CNT, 
		STND_RPT.AM8CNT, 
		STND_RPT.AM9CNT, 
		STND_RPT.AM10CNT, 
		STND_RPT.AM11CNT, 
		STND_RPT.PM12CNT, 
		STND_RPT.PM1CNT, 
		STND_RPT.PM2CNT, 
		STND_RPT.PM3CNT, 
		STND_RPT.PM4CNT, 
		STND_RPT.PM5CNT, 
		STND_RPT.PM6CNT, 
		STND_RPT.PM7CNT, 
		STND_RPT.AFT7PM, 
		STND_RPT.TOTCNT, 
		STND_RPT.PERHOUR ,
		STND_RPT.EXCEPTION_TYPE
	FROM  dbo.[v_STND_EXCEPTION_RPTVIEW] AS STND_RPT WITH (NOLOCK) 
	WHERE 
	( 
		( CONVERT(DATETIME, STND_RPT.REPORT_DATE)  BETWEEN @FROM_DATE AND @TO_DATE )
		AND 
		( 
			STND_RPT.MODIFY_BY IN 
			( 
				SELECT usr.[USER_NAME] 
				FROM dbo.[PEA_USER_VENDOR_GRP] AS uvg WITH (NOLOCK) JOIN  dbo.[PEA_VENDOR_GROUP] AS vg WITH (NOLOCK)			
				ON ( vg.VendorGroupId = uvg.VendorGroupId ) JOIN dbo.[PEA_USER] AS usr ON usr.[USER_ID] = uvg.[USERID]
				WHERE 
				( 
					vg.VendorGroupName IN ( 
						SELECT Vendor.Groups.value('.', 'VARCHAR(100)') 
						FROM @VENDOR_GRP.nodes('//Groups') AS Vendor(Groups)  
					) 
				)
			)
		)
	AND ( STND_RPT.[DIR] = @DIR )
	)
	ORDER BY 1
END
ELSE
BEGIN
		SELECT	STND_RPT.MODIFY_BY, 
			STND_RPT.BEF6AM, 
			STND_RPT.AM6CNT, 
			STND_RPT.AM7CNT, 
			STND_RPT.AM8CNT, 
			STND_RPT.AM9CNT, 
			STND_RPT.AM10CNT, 
			STND_RPT.AM11CNT, 
			STND_RPT.PM12CNT, 
			STND_RPT.PM1CNT, 
			STND_RPT.PM2CNT, 
			STND_RPT.PM3CNT, 
			STND_RPT.PM4CNT, 
			STND_RPT.PM5CNT, 
			STND_RPT.PM6CNT, 
			STND_RPT.PM7CNT, 
			STND_RPT.AFT7PM, 
			STND_RPT.TOTCNT, 
			STND_RPT.PERHOUR ,
			STND_RPT.EXCEPTION_TYPE
		FROM  dbo.[v_STND_EXCEPTION_RPTVIEW] AS STND_RPT WITH (NOLOCK) 
		WHERE 
		( 
			( CONVERT(DATETIME, STND_RPT.REPORT_DATE)  BETWEEN @FROM_DATE AND @TO_DATE )
			AND ( STND_RPT.MODIFY_BY IN(SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I)) )
			AND ( STND_RPT.[DIR] = @DIR )
		)
		ORDER BY 1
END

-- [Pramod K] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
