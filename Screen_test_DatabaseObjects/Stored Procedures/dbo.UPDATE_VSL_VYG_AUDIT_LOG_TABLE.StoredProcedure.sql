/****** Object:  StoredProcedure [dbo].[UPDATE_VSL_VYG_AUDIT_LOG_TABLE]    Script Date: 01/03/2013 19:48:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_VSL_VYG_AUDIT_LOG_TABLE] 
	@VOYAGE_ID_LST	VARCHAR(max)	,
	@IS_GLOBAL		BIT	= 0			,
	@MANIFEST_NBR	VARCHAR(50)		,
	@VOYAGE_STAT	VARCHAR(50)		,
	@ARRIVAL_DATE	DATETIME = NULL,
	@REMARKS		VARCHAR(100)= NULL	,
	@MODIFY_BY		VARCHAR(50)	= NULL	,
	@CARRIER_ID		NUMERIC(12,0)	= NULL,
	@VESSEL_ID		NUMERIC(12,0)	= NULL,
	@USPORT_ID		NUMERIC(12,0)	= NULL,
	@VOYAGE_NBR		VARCHAR(100)	= NULL,
	@GROUP_UPDATE_TYPE TINYINT		= 0
AS
BEGIN
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @VYG_XML AS XML

SET @VYG_XML = '<I>' + REPLACE(@VOYAGE_ID_LST, ',', '</I><I>') + '</I>'

IF ( @IS_GLOBAL = 1 )
BEGIN
	INSERT INTO [dbo].[PES_AUDIT_LOGS_VSL_VYG]
	(
		[VOYAGE_ID]	,
		[IS_GLOBALUPDATE]	,
		[MANIFEST_NBR]		,
		[VOYAGE_STATUS]		,
		[ARRIVAL_DATE]		,
		[REMARKS]			,
		[MODIFY_BY]			,
		[MODIFY_DATE]		,
		[CARRIER_NAME]		,
		[VESSEL_NAME]		,
		[USPORT_NAME]		,
		[VOYAGE_NBR]		,
		[MANIFEST_NBR_NEW]	,
		[UI_INSTANCE_TYPE]
	)
	SELECT 
		VOYAGE_ID			,
		@IS_GLOBAL			,
		[ACT_MANIFEST_NBR]	,
		[VOYAGE_STATUS]		,
		[ACT_ARRIVAL_DT]	,
		[REMARKS]			,
		@MODIFY_BY			, 
		GETDATE()			,
		[CARRIER_ID]		,
		[VESSEL_ID]			,
		[USPORT_ID]			,
		[VOYAGE_NBR]		,
		@MANIFEST_NBR		,
		@GROUP_UPDATE_TYPE
	FROM DQA_VOYAGE 
	WHERE 
	( 
		[VOYAGE_ID] IN ( SELECT X.I.value('.', 'Numeric(12,0)') FROM @VYG_XML.nodes('//I') AS X(I)  )   
	)	

END
ELSE
BEGIN
	INSERT INTO [dbo].[PES_AUDIT_LOGS_VSL_VYG]
	(
		[VOYAGE_ID]		,
		[MANIFEST_NBR]	,
		[VOYAGE_STATUS]	,
		[ARRIVAL_DATE]	,
		[REMARKS]		,
		[MODIFY_BY]		,
		[MODIFY_DATE]	,
		[MANIFEST_NBR_NEW]
	)
	SELECT 
		VOYAGE_ID			,
		[ACT_MANIFEST_NBR]	,
		[VOYAGE_STATUS]		,
		[ACT_ARRIVAL_DT]	,
		[REMARKS]			,
		@MODIFY_BY			, 
		GETDATE()			,
		@MANIFEST_NBR
	FROM dbo.DQA_VOYAGE WITH (NOLOCK)
	WHERE 
	( 
		[VOYAGE_ID] IN ( SELECT X.I.value('.', 'Numeric(12,0)') FROM @VYG_XML.nodes('//I') AS X(I)  )   
	)	
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
