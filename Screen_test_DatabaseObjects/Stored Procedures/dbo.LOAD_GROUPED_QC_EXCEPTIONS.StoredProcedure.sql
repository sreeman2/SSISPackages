/****** Object:  StoredProcedure [dbo].[LOAD_GROUPED_QC_EXCEPTIONS]    Script Date: 01/03/2013 19:48:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_GROUPED_QC_EXCEPTIONS] 
	@T_NUM			INT					,
	@VOYAGE_NUM		VARCHAR(5)			,
	@VDATE			DATETIME			,
	@DIR			CHAR(1)				,
	@PORT_EXP_FLAG	CHAR(2)				,
	@PROC_NAME		VARCHAR(100)		,
	@VESSEL			INT = NULL	,
	@CARRIER		INT = NULL	,
	@USPORT			INT = NULL	,
	@OLD_VAL		VARCHAR(100) = NULL
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


-- [aa] - 09/18/2010
-- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
--  '@T_NUM='''+CAST(@T_NUM AS VARCHAR(100))+''''
--+', @VOYAGE_NUM='''+@VOYAGE_NUM+''''
--+', @VDATE='''+CAST(@VDATE AS VARCHAR(100))+''''
--+', @DIR='''+@DIR+''''
--+', @PORT_EXP_FLAG='''+@PORT_EXP_FLAG+''''
--+', @PROC_NAME='''+@PROC_NAME+''''
--+', @VESSEL='''+CAST(@VESSEL AS VARCHAR(100))+''''
--+', @CARRIER='''+CAST(@CARRIER AS VARCHAR(100))+''''
--+', @USPORT='''+CAST(@USPORT AS VARCHAR(100))+''''
--
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'LOAD_GROUPED_QC_EXCEPTIONS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

IF ( @PROC_NAME = 'PORT EXCEPTIONS' OR @PROC_NAME = 'N/W EXCEPTIONS' ) 
BEGIN
	SELECT DISTINCT 
		dbl.T_NBR, 
		dbl.BL_NBR, 
		dbl.VOYAGE, 
		dbl.DIR, 
		(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
		(CASE ISNULL(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
		dbl.RECEIPT_CITY, 
		dbl.REGISTRY, 
		dbl.DESTINATION_CITY, 
		dbl.DESTINATION_ST, 
		cpv.COMPLETE_STATUS 
	FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
	ON dbl.T_NBR = cpv.T_NBR AND cpv.PROCESS_NAME = @PROC_NAME 
	AND cpv.COMPLETE_STATUS = 1 AND ISNULL(dbl.IS_DELETED, 'N') = 'N' 
	WHERE 
	(
		( dbl.VESSEL_ID = @VESSEL  OR dbl.VESSEL_ID_MOD = @VESSEL )
		AND ( dbl.CARRIER_ID = @CARRIER OR dbl.CARRIER_ID_MOD = @CARRIER )
		AND ( dbl.USPORT_ID = @USPORT OR dbl.USPORT_ID_MOD = @USPORT )
		AND ( dbl.VOYAGE = @VOYAGE_NUM )
		AND ( cpv.FLAG = @PORT_EXP_FLAG ) 
		AND 
		( 
			ISNULL(cpv.[KEY], '') = 
			( CASE WHEN @PORT_EXP_FLAG = 'PR' OR @PORT_EXP_FLAG = 'P' THEN (
				SELECT TOP 1 ISNULL([KEY], '') FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
				WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME ) ELSE '' END 
			) 
		)
		AND 
		( 
			ISNULL(cpv.[KEY1], '') = 
			(CASE WHEN @PORT_EXP_FLAG = 'PR' OR @PORT_EXP_FLAG = 'R' THEN (
				SELECT TOP 1 ISNULL([KEY1],'') FROM dbo.[CTRL_PROCESS_VOYAGE] WITH (NOLOCK)  
				WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME ) ELSE '' END 
			)
		)		
		AND ( dbl.DIR = @DIR )
		AND ( dbl.LOCKED_BY_USR IS NULL ) 
		AND ( dbl.LOCKED_BY_DATETIME IS NULL )
		AND ( dbl.t_nbr <> @T_NUM )		
	)
END
ELSE IF ( @PROC_NAME = 'INVALID REGISTRY' ) 
BEGIN
	IF ( @OLD_VAL IS NULL )
	BEGIN
		SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(			
			( dbl.VESSEL_ID = @VESSEL OR dbl.VESSEL_ID_MOD = @VESSEL )
			AND ( dbl.USPORT_ID = @USPORT OR dbl.USPORT_ID_MOD = @USPORT )
			AND ( dbl.VOYAGE = @VOYAGE_NUM )			
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
	END
	ELSE
	BEGIN
		SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(			
			( dbl.VESSEL_ID = @VESSEL OR dbl.VESSEL_ID_MOD = @VESSEL )
			--AND ( dbl.USPORT_ID = @USPORT OR dbl.USPORT_ID_MOD = @USPORT )
			AND ( dbl.VOYAGE = @VOYAGE_NUM )
			AND ( dbl.VDATE = @VDATE )
			AND ( cpv.[KEY] = ( SELECT TOP 1 [KEY] FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
					WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME 	)			 
			)
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
	END
END
ELSE IF ( @PROC_NAME = 'INVALID ORIGIN' )
BEGIN
	IF ( @DIR = 'E' )
	BEGIN
		SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(
			--( dbl.VESSEL_ID = @VESSEL OR dbl.VESSEL_ID_MOD = @VESSEL )
			--AND ( dbl.VOYAGE = @VOYAGE_NUM )
			( cpv.[KEY] = ( SELECT TOP 1 [KEY] FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
					WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME 	)			 
			)
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
	END
	ELSE
	BEGIN
		SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(
			--( dbl.VESSEL_ID = @VESSEL OR dbl.VESSEL_ID_MOD = @VESSEL )
			( dbl.VOYAGE = @VOYAGE_NUM )
			AND ( cpv.[KEY] = ( SELECT TOP 1 [KEY] FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
					WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME 	)			 
		)
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
	END
END
ELSE IF ( @PROC_NAME = 'TEMPORARY CARRIER' OR @PROC_NAME = 'ZZZZ CARRIER') 
BEGIN
		SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(			
			( dbl.DQA_VOYAGE_ID = ( SELECT DQA_VOYAGE_ID FROM dbo.DQA_BL WITH (NOLOCK) WHERE T_NBR = @T_NUM ) )
			AND ( cpv.[KEY] = ( SELECT TOP 1 [KEY] FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
					WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME 	)			 
			)
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
END
ELSE IF ( @PROC_NAME = 'INVALID DESTINATION') 
BEGIN
		SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(
			--( dbl.VESSEL_ID = @VESSEL OR dbl.VESSEL_ID_MOD = @VESSEL )
			( dbl.VOYAGE = @VOYAGE_NUM )
			AND ( cpv.[KEY] = ( SELECT TOP 1 [KEY] FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
					WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME 	)			 
		)
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
END
ELSE  
BEGIN
	SELECT DISTINCT 
			dbl.T_NBR, 
			dbl.BL_NBR, 
			dbl.VOYAGE, 
			dbl.DIR, 
			(CASE ISNULL(dbl.ULT_PORT_NAME,'') WHEN '' THEN dbl.ULT_PORT_CODE ELSE dbl.ULT_PORT_NAME END) AS ULT_PORT_NAME, 
			(CASE isnull(dbl.FGN_PORT_NAME,'') WHEN '' THEN dbl.FGN_PORT_CODE ELSE dbl.FGN_PORT_NAME END) AS FGN_PORT_NAME, 
			dbl.RECEIPT_CITY, 
			dbl.REGISTRY, 
			dbl.DESTINATION_CITY, 
			dbl.DESTINATION_ST, 
			cpv.COMPLETE_STATUS 
		FROM dbo.[DQA_BL] AS dbl WITH (NOLOCK) JOIN dbo.[CTRL_PROCESS_VOYAGE] AS cpv WITH (NOLOCK) 
		ON ( dbl.T_NBR = cpv.T_NBR ) AND ( cpv.PROCESS_NAME = @PROC_NAME )
		AND ( cpv.COMPLETE_STATUS = 1 ) AND ( ISNULL(dbl.IS_DELETED, 'N') = 'N' )
		WHERE 
		(
			( dbl.VESSEL_ID = @VESSEL OR dbl.VESSEL_ID_MOD = @VESSEL )
			AND ( dbl.VOYAGE = @VOYAGE_NUM )
			AND ( cpv.[KEY] = ( SELECT TOP 1 [KEY] FROM dbo.[CTRL_PROCESS_VOYAGE]  WITH (NOLOCK) 
					WHERE T_NBR = @T_NUM AND PROCESS_NAME = @PROC_NAME 	)			 
			)
			AND ( dbl.DIR = @DIR )
			AND ( dbl.LOCKED_BY_USR IS NULL ) 
			AND ( dbl.LOCKED_BY_DATETIME IS NULL )
			AND ( dbl.t_nbr <> @T_NUM )
		)
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
@Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
