/****** Object:  StoredProcedure [dbo].[LOAD_COMPANY_EXCP_COUNTS]    Script Date: 01/03/2013 19:48:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_COMPANY_EXCP_COUNTS] 
	@EDIT_MODE		TINYINT				, --1: ADMIN, 2: EXCEPTION MGMT --not used!!!
	@DIR			VARCHAR(1)			, --I: IMPORT, E:EXPORT
	@CATEGORY		VARCHAR(50)			,
	@CATEGORY_VAL	VARCHAR(50)	 = NULL	,
	@MOD_BY_USERS	VARCHAR(2000)		, --not used!!!
	@IS_DELETED		BIT				--1:DELETED, 0:ACTIVE --not used!!!
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;

---- [aa] - 09/18/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
---- '@EDIT_MODE='+LTRIM(RTRIM(STR(@EDIT_MODE)))
--+'@DIR='''+@DIR+''''
--+', @CATEGORY='''+@CATEGORY+''''
--+', @CATEGORY_VAL='+COALESCE(''''+@CATEGORY_VAL+'''','NULL')
----+', @MOD_BY_USERS='''+@MOD_BY_USERS+''''
----+', @IS_DELETED='++LTRIM(RTRIM(STR(@IS_DELETED)))
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'LOAD_COMPANY_EXCP_COUNTS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT


-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@DIR='''+@DIR+''''
+', @CATEGORY='''+@CATEGORY+''''
+', @CATEGORY_VAL='+COALESCE(''''+@CATEGORY_VAL+'''','NULL')
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


SET @CATEGORY_VAL = REPLACE(@CATEGORY_VAL, '''', '')

DECLARE @CATEGORY_TYPE AS SMALLINT
SET @CATEGORY_TYPE = 1 --DEFAULT TYPE AS DAILY_LOAD_DT

IF ( @CATEGORY = 'DAILY_LOAD_DT' )
BEGIN
	IF ( @CATEGORY_VAL IS NULL )	
		SET @CATEGORY_TYPE = 1 -- B.DAILY_LOAD_DT IS NOT NULL 
	ELSE
		SET @CATEGORY_TYPE = 3
	--B.DAILY_LOAD_DT IS NOT NULL AND convert(VARCHAR(10),b.DAILY_LOAD_DT,101) IN (@CATEGORY_VAL)
END
ELSE IF ( ( @CATEGORY = 'VDATE' OR @CATEGORY = 'VDATE AS PRODMONTH' ) )
BEGIN	
	IF ( @CATEGORY_VAL IS NULL )
		SET @CATEGORY_TYPE = 2 --B.VDATE IS NOT NULL
	ELSE IF ( @CATEGORY = 'VDATE' )
		SET @CATEGORY_TYPE = 4 
		--B.VDATE IS NOT NULL AND B.VDATE BETWEEN CONVERT(SMALLDATETIME,'" & strCategoryValues & "') AND DATEADD(DD,7,CONVERT(SMALLDATETIME,'" & strCategoryValues & "'))
	ELSE IF ( @CATEGORY = 'VDATE AS PRODMONTH' )	
		SET @CATEGORY_TYPE = 5 
		--B.VDATE IS NOT NULL AND DATENAME(MM,b.VDATE) + ' ' + DATENAME(YYYY,b.VDATE) = '" & strCategoryValues & "'
END
ELSE IF ( @CATEGORY = 'LOAD_NBR' )
BEGIN
	IF ( @CATEGORY_VAL IS NULL )
	BEGIN
		SET @CATEGORY_TYPE = 6 
		--B.LOAD_NBR IS NOT NULL 		
	END
	ELSE
		SET @CATEGORY_TYPE = 7 --AND LOAD_NBR IN (@CATEGORY_VAL)
END
ELSE IF ( @CATEGORY = 'LATE BILLS' )
BEGIN
		SET @CATEGORY_TYPE = 8
END
ELSE
BEGIN
	SET @CATEGORY_TYPE = 9
	--B.CATEGORY
END

IF ( @CATEGORY_TYPE = 1 OR @CATEGORY_TYPE = 2 )
BEGIN
SELECT	'COMPANY EXCEPTIONS' as Exception, 
		'Y' as [Grouping],    
		--ABS(ISNULL(SUM(CASE tlp_1.status WHEN 'PENDING' THEN 1 ELSE 0 END),0)- sum (CASE upper(b.is_deleted) WHEN 'Y'  THEN 1 ELSE 0 END)) AS Pending,    
		SUM
		(
			(
				CASE WHEN 
				( 
					ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
				) 
				THEN 1 ELSE 0 END
			)
		) AS Pending,    
		ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
		COUNT(b.t_nbr) as Total ,  
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
		SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
		1 AS GROUP_ID  
FROM dbo.DQA_BL AS b WITH (NOLOCK)  
JOIN ( 		
	SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
	FROM   
	(
		SELECT DISTINCT tlp_in.BOL_ID, 
		( 
			CASE WHEN (
				SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
				WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
			THEN 'PENDING' ELSE (
				SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
				WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
			) END 
		) AS [STATUS]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
		GROUP BY tlp_in.BOL_ID
		HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
	) AS tlp_drv
	JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
	ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
	UNION ALL
	SELECT DISTINCT tlp_main.BOL_ID			, 
					tlp_main.[STATUS]		, 
					tlp_main.[MODIFIED_BY]
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY AS tlp_main WITH (NOLOCK)
	WHERE 
	( 
		--tlp_main.BOL_ID NOT IN 
		EXISTS
		( 
			SELECT DISTINCT tlp_sub.BOL_ID		
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
			WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
			GROUP BY tlp_sub.BOL_ID
			HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
		) 
	)
)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
WHERE 
(
	( 		
		( CASE	
			 WHEN @CATEGORY_TYPE = 6 THEN b.LOAD_NBR ELSE ( CASE 
			 WHEN @CATEGORY_TYPE = 1 THEN b.DAILY_LOAD_DT ELSE ( CASE 
			 WHEN @CATEGORY_TYPE = 2 THEN b.VDATE END ) END )		
		END ) IS NOT NULL 
	)  
	AND ( b.DIR = @DIR ) 
	AND EXISTS 
	(  
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND ( BL_BL.T_NBR = b.T_NBR	)
		)	
	) 
)
END
ELSE IF ( @CATEGORY_TYPE = 6 )
BEGIN
SELECT	'COMPANY EXCEPTIONS' as Exception, 
		'Y' as [Grouping],    
		--ABS(ISNULL(SUM(CASE tlp_1.status WHEN 'PENDING' THEN 1 ELSE 0 END),0)- sum (CASE upper(b.is_deleted) WHEN 'Y'  THEN 1 ELSE 0 END)) AS Pending,    
		SUM
		(
			(
				CASE WHEN 
				( 
					ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
				) 
				THEN 1 ELSE 0 END
			)
		) AS Pending,    
		ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
		COUNT(b.t_nbr) as Total ,  
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
		SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
		1 AS GROUP_ID  
FROM dbo.DQA_BL AS b WITH (NOLOCK)  
JOIN ( 		
	SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
	FROM   
	(
		SELECT DISTINCT tlp_in.BOL_ID, 
		( 
			CASE WHEN (
				SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
				WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
			THEN 'PENDING' ELSE (
				SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
				WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
			) END 
		) AS [STATUS]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
		GROUP BY tlp_in.BOL_ID
		HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
	) AS tlp_drv
	JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
	ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
	UNION ALL
	SELECT DISTINCT tlp_main.BOL_ID			, 
					tlp_main.[STATUS]		, 
					tlp_main.[MODIFIED_BY]
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY tlp_main WITH (NOLOCK)
	WHERE 
	( 
		--tlp_main.BOL_ID NOT IN 
		EXISTS
		( 
			SELECT DISTINCT tlp_sub.BOL_ID		
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
			WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
			GROUP BY tlp_sub.BOL_ID
			HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
		) 
	)
)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
WHERE 
(
	( b.LOAD_NBR IS NOT NULL )  
	AND ( b.DIR = @DIR ) 
	AND EXISTS   
	( 
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND (BL_BL.T_NBR = b.T_NBR )
		)	
	) 
)
END
ELSE IF ( @CATEGORY_TYPE = 3 )
BEGIN
SELECT	'COMPANY EXCEPTIONS' as Exception, 
		'Y' as [Grouping],    
		--ABS(ISNULL(SUM(CASE tlp_1.status WHEN 'PENDING' THEN 1 ELSE 0 END),0)- sum (CASE upper(b.is_deleted) WHEN 'Y'  THEN 1 ELSE 0 END)) AS Pending,    
		SUM
		(
			(
				CASE WHEN 
				( 
					ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
				) 
				THEN 1 ELSE 0 END
			)
		) AS Pending,    
		ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
		COUNT(b.t_nbr) as Total ,  
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
		SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
		1 AS GROUP_ID  
FROM dbo.DQA_BL AS b WITH (NOLOCK)  
JOIN ( 		
	SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
	FROM   
	(
		SELECT DISTINCT tlp_in.BOL_ID, 
		( 
			CASE WHEN (
				SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
				WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
			THEN 'PENDING' ELSE (
				SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
				WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
			) END 
		) AS [STATUS]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
		GROUP BY tlp_in.BOL_ID
		HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
	) AS tlp_drv
	JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
	ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
	UNION ALL
	SELECT DISTINCT tlp_main.BOL_ID			, 
					tlp_main.[STATUS]		, 
					tlp_main.[MODIFIED_BY]
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY tlp_main WITH (NOLOCK)
	WHERE 
	( 
		--tlp_main.BOL_ID NOT IN 
		EXISTS
		( 
			SELECT DISTINCT tlp_sub.BOL_ID		
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
			WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
			GROUP BY tlp_sub.BOL_ID
			HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
		) 
	)
)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
WHERE 
(
	( CONVERT(VARCHAR(10),b.DAILY_LOAD_DT,101) =@CATEGORY_VAL ) 
	AND ( b.DIR = @DIR ) 
	AND EXISTS 
	(
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND (BL_BL.T_NBR = b.T_NBR )
		) 
	)
) 

END
ELSE IF ( @CATEGORY_TYPE = 4 )
BEGIN
SELECT	'COMPANY EXCEPTIONS' as Exception, 
		'Y' as [Grouping],    
		--ABS(ISNULL(SUM(CASE tlp_1.status WHEN 'PENDING' THEN 1 ELSE 0 END),0)- sum (CASE upper(b.is_deleted) WHEN 'Y'  THEN 1 ELSE 0 END)) AS Pending,    
		SUM
		(
			(
				CASE WHEN 
				( 
					ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
				) 
				THEN 1 ELSE 0 END
			)
		) AS Pending,    
		ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
		COUNT(b.t_nbr) as Total ,  
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
		SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
		1 AS GROUP_ID  
FROM dbo.DQA_BL AS b WITH (NOLOCK)  
JOIN ( 		
	SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
	FROM   
	(
		SELECT DISTINCT tlp_in.BOL_ID, 
		( 
			CASE WHEN (
				SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
				WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
			THEN 'PENDING' ELSE (
				SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
				WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
			) END 
		) AS [STATUS]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
		GROUP BY tlp_in.BOL_ID
		HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
	) AS tlp_drv
	JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
	ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
	UNION ALL
	SELECT DISTINCT tlp_main.BOL_ID			, 
					tlp_main.[STATUS]		, 
					tlp_main.[MODIFIED_BY]
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY tlp_main WITH (NOLOCK)
	WHERE 
	( 
		--tlp_main.BOL_ID NOT IN 
		EXISTS
		( 
			SELECT DISTINCT tlp_sub.BOL_ID		
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
			WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
			GROUP BY tlp_sub.BOL_ID
			HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
		) 
	)
)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
WHERE 
(
	( B.VDATE BETWEEN CONVERT(SMALLDATETIME, @CATEGORY_VAL ) AND DATEADD(DD,7,CONVERT(SMALLDATETIME, @CATEGORY_VAL ) ) )
	AND ( b.DIR = @DIR )
	AND EXISTS
	(  
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND (BL_BL.T_NBR = b.T_NBR )
		) 
	) 
)
END
ELSE IF ( @CATEGORY_TYPE = 5 )
BEGIN
SELECT	'COMPANY EXCEPTIONS' as Exception, 
		'Y' as [Grouping],    
		--ABS(ISNULL(SUM(CASE tlp_1.status WHEN 'PENDING' THEN 1 ELSE 0 END),0)- sum (CASE upper(b.is_deleted) WHEN 'Y'  THEN 1 ELSE 0 END)) AS Pending,    
		SUM
		(
			(
				CASE WHEN 
				( 
					ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
				) 
				THEN 1 ELSE 0 END
			)
		) AS Pending,    
		ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
		COUNT(b.t_nbr) as Total ,  
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
		SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
		1 AS GROUP_ID  
FROM dbo.DQA_BL AS b WITH (NOLOCK)  
JOIN ( 		
	SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
	FROM   
	(
		SELECT DISTINCT tlp_in.BOL_ID, 
		( 
			CASE WHEN (
				SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
				WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
			THEN 'PENDING' ELSE (
				SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
				WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
			) END 
		) AS [STATUS]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
		GROUP BY tlp_in.BOL_ID
		HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
	) AS tlp_drv
	JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
	ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
	UNION ALL
	SELECT DISTINCT tlp_main.BOL_ID			, 
					tlp_main.[STATUS]		, 
					tlp_main.[MODIFIED_BY]
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY tlp_main WITH (NOLOCK)
	WHERE 
	( 
		--tlp_main.BOL_ID NOT IN 
		EXISTS
		( 
			SELECT DISTINCT tlp_sub.BOL_ID		
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
			WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
			GROUP BY tlp_sub.BOL_ID
			HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
		) 
	)
)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
WHERE 
(
	( DATENAME(MM,b.VDATE)+ ' ' +DATENAME(YYYY,b.VDATE)= @CATEGORY_VAL )	
	AND ( b.DIR = @DIR )
	AND EXISTS
	(  
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND (BL_BL.T_NBR = b.T_NBR )
		) 
	) 
)
END
ELSE IF ( @CATEGORY_TYPE = 7 )
BEGIN
SELECT	'COMPANY EXCEPTIONS' as Exception, 
		'Y' as [Grouping],    
		--ABS(ISNULL(SUM(CASE tlp_1.status WHEN 'PENDING' THEN 1 ELSE 0 END),0)- sum (CASE upper(b.is_deleted) WHEN 'Y'  THEN 1 ELSE 0 END)) AS Pending,    
		SUM
		(
			(
				CASE WHEN 
				( 
					ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
				) 
				THEN 1 ELSE 0 END
			)
		) AS Pending,    
		ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
		COUNT(b.t_nbr) as Total ,  
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
		ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
		SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
		1 AS GROUP_ID  
FROM dbo.DQA_BL AS b WITH (NOLOCK)  
JOIN ( 		
	SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
	FROM   
	(
		SELECT DISTINCT tlp_in.BOL_ID, 
		( 
			CASE WHEN (
				SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
				WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
			THEN 'PENDING' ELSE (
				SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
				WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
			) END 
		) AS [STATUS]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
		GROUP BY tlp_in.BOL_ID
		HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
	) AS tlp_drv
	JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
	ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
	UNION ALL
	SELECT DISTINCT tlp_main.BOL_ID			, 
					tlp_main.[STATUS]		, 
					tlp_main.[MODIFIED_BY]
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY tlp_main WITH (NOLOCK)
	WHERE 
	( 
		--tlp_main.BOL_ID NOT IN 
		EXISTS
		( 
			SELECT DISTINCT tlp_sub.BOL_ID		
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
			WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
			GROUP BY tlp_sub.BOL_ID
			HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
		) 
	)
)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
WHERE 
(
	b.LOAD_NBR = CAST(@CATEGORY_VAL AS NUMERIC(12,0))
	AND ( b.DIR = @DIR )
	AND EXISTS
	(  
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND (BL_BL.T_NBR = b.T_NBR )
		) 
	) 
)
END
ELSE IF ( @CATEGORY_TYPE = 8 )
BEGIN
	SELECT	'COMPANY EXCEPTIONS' as Exception, 
			'Y' as [Grouping],    
			SUM
			(
				(
					CASE WHEN 
					( 
						ISNULL(TLP_1.STATUS, 0) = 'PENDING' AND UPPER(ISNULL(b.IS_DELETED, 'N')) != 'Y'
					) 
					THEN 1 ELSE 0 END
				)
			) AS Pending,    
			ISNULL(SUM(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END),0) AS Complete,   
			COUNT(b.t_nbr) as Total ,  
			ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 0 ELSE 1 END)- sum(CASE tlp_1.status WHEN 'CLEANSED' THEN 1 ELSE 0 END) ) AS UnlockedRecordCount,   
			ABS(sum(CASE ltrim(rtrim(upper(b.locked_by_usr))) WHEN isnull(ltrim(rtrim(upper(b.locked_by_usr))),'')  THEN 1 ELSE 0 END)) AS LockedRecordCount,  
			SUM(CASE upper(b.is_deleted) WHEN 'Y' THEN 1 ELSE 0 END) as Deleted, 
			1 AS GROUP_ID  
	FROM dbo.DQA_BL AS b WITH (NOLOCK)  
	JOIN ( 		
		SELECT DISTINCT tlp_drv.BOL_ID, tlp_drv.[STATUS], tlp_out.MODIFIED_BY 
		FROM   
		(
			SELECT DISTINCT tlp_in.BOL_ID, 
			( 
				CASE WHEN (
					SELECT TOP 1 B.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY B WITH (NOLOCK) 
					WHERE B.BOL_ID = tlp_in.BOL_ID AND ( UPPER(B.STATUS) = 'PENDING' ) ) IS NOT NULL 
				THEN 'PENDING' ELSE (
					SELECT TOP 1 D.STATUS FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY D WITH (NOLOCK) 
					WHERE D.BOL_ID = tlp_in.BOL_ID AND ( UPPER(D.STATUS) = 'CLEANSED' )
				) END 
			) AS [STATUS]
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  AS tlp_in WITH (NOLOCK)
			GROUP BY tlp_in.BOL_ID
			HAVING COUNT(DISTINCT tlp_in.STATUS) > 1	
		) AS tlp_drv
		JOIN PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_out WITH (NOLOCK)
		ON ( ( tlp_drv.BOL_ID = tlp_out.BOL_ID ) AND ( tlp_drv.STATUS = tlp_out.STATUS ) )
		UNION ALL
		SELECT DISTINCT tlp_main.BOL_ID			, 
						tlp_main.[STATUS]		, 
						tlp_main.[MODIFIED_BY]
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY AS tlp_main WITH (NOLOCK)
		WHERE 
		( 
			--tlp_main.BOL_ID NOT IN 
			EXISTS
			( 
				SELECT DISTINCT tlp_sub.BOL_ID		
				FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  tlp_sub WITH (NOLOCK)
				WHERE tlp_main.BOL_ID = tlp_sub.BOL_ID
				GROUP BY tlp_sub.BOL_ID
				HAVING COUNT(DISTINCT tlp_sub.STATUS) = 1	
			) 
		)
	)tlp_1 ON ( b.T_NBR = tlp_1.BOL_ID )
	WHERE ( b.VDATE < ( SELECT START_DT FROM DQA_PROD_MONTH WITH (NOLOCK) ) )  
	AND ( b.DIR = @DIR ) 
	AND EXISTS 
	(  
		SELECT BL_BL.T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID )
		WHERE 
		( 
			( DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )  
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			AND ( BL_BL.T_NBR = b.T_NBR	)
		)			 
	)

END

-- [aa] - 09/18/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
