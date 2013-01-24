/****** Object:  StoredProcedure [dbo].[ASSIGN_DQA_EXCEPTION_BILL]    Script Date: 01/03/2013 19:47:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ASSIGN_DQA_EXCEPTION_BILL]  
@user_id			VARCHAR(100), 
@INBOLID			NUMERIC(10,0), 
@sDir				VARCHAR(100),
@sProc_Name			VARCHAR(100), 
@sCategory			VARCHAR(100),
@sCategoryValues	VARCHAR(100),
@Out_T_NBR			NUMERIC(13,2)OUT 
AS
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@user_id='''+@user_id+''''
+', @INBOLID='++LTRIM(RTRIM(STR(@INBOLID)))
+', @sDir='''+@sDir+''''
+', @sProc_Name='''+@sProc_Name+''''
+', @sCategory='''+@sCategory+''''
+', @sCategoryValues='''+@sCategoryValues+''''
EXEC dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @local_t_nbr INTEGER
DECLARE @SKIPPED_BOL CHAR(1)
DECLARE @NEXT_BOL INT

SET @local_t_nbr = 0

BEGIN

DECLARE @BOLID TABLE( BOL_ID numeric(10,0) )

DECLARE @POSITION AS INT
DECLARE @STRMONTH AS VARCHAR(25)
DECLARE @STRYEAR AS VARCHAR(4)
DECLARE @MONTHSTARTDATE AS DATETIME
DECLARE @MONTHENDDATE AS DATETIME
DECLARE @LOAD_START_DT SMALLDATETIME, @LOAD_END_DT SMALLDATETIME

IF ( @sCategory = 'VDATE AS PRODMONTH' )
BEGIN		
SET @POSITION = CHARINDEX(' ',@sCategoryValues, 0 )
SET @STRMONTH = SUBSTRING(@sCategoryValues,0,@POSITION+1 )
SET @STRYEAR  = SUBSTRING(@sCategoryValues,@POSITION+1, LEN(@sCategoryValues) )

SET @MONTHSTARTDATE = CAST('01/' + @STRMONTH + '/' + @STRYEAR AS DATETIME)
SET @MONTHENDDATE = DATEADD(DD, -1, DATEADD(MM, 1, @MONTHSTARTDATE))
END

IF ( @sCategory = 'DAILY_LOAD_DT' )
BEGIN		
	SET @LOAD_START_DT = @SCATEGORYVALUES+' 00:00:00'
	SET @LOAD_END_DT = @SCATEGORYVALUES+' 23:59:59'
END

IF( @SProc_Name = 'COMPANY EXCEPTIONS' ) 
BEGIN					
IF ( @sCategory='DAILY_LOAD_DT' ) AND ( @sCategoryValues <> 'ALL')  AND ( @sCategoryValues <> '' )
BEGIN
	IF ( @INBOLID = 0 )
	BEGIN
		SELECT TOP 1 @INBOLID = T_NBR 
		FROM dbo.DQA_BL WITH (NOLOCK)
		WHERE ( DAILY_LOAD_DT BETWEEN @LOAD_START_DT AND @LOAD_END_DT )
		--( CONVERT(VARCHAR(10),DAILY_LOAD_DT,101) = @SCATEGORYVALUES )
		AND ( DIR = @SDIR ) 
		ORDER BY LOAD_NBR, T_NBR 
	END

	--Get TOP T_NBR from the PES_TRANSACTIONS_LIB_PTY bucket excluding the 
	SELECT TOP 1 @LOCAL_T_NBR = abol.BOL_ID
	FROM
	(	
		SELECT cmpy_bills.BOL_ID, cmpy_bills.LOAD_NBR
		FROM dbo.v_DQA_ASSIGN_CMPNY_EXCPTN_1 AS cmpy_bills WITH (NOLOCK)
		WHERE 
		( 
			( cmpy_bills.BOL_ID > @INBOLID )
			AND ( cmpy_bills.DAILY_LOAD_DT BETWEEN @LOAD_START_DT AND @LOAD_END_DT )				
			AND ( cmpy_bills.DIR = @SDIR ) 			
		)
	) AS abol
	WHERE EXISTS
	(
		SELECT 1 
		FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
		ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
		AND ( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
		WHERE ( bol.T_NBR = abol.BOL_ID )
	) 
	ORDER BY right(abol.load_nbr,3) desc, abol.BOL_ID ASC
	
	--If no T_NBR returned, search from the SKIPPED bucket
	IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
	BEGIN
		SELECT TOP 1 @LOCAL_T_NBR = abol.BOL_ID
		FROM
		(
			SELECT skip_bill.BOL_ID 
			FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN_1 AS skip_bill WITH (NOLOCK)		
			WHERE ( skip_bill.BOL_ID > @INBOLID )				
			AND ( skip_bill.DAILY_LOAD_DT BETWEEN @LOAD_START_DT AND @LOAD_END_DT )
			AND ( skip_bill.DIR = @SDIR )			
		) AS abol
		WHERE EXISTS
		(
			SELECT 1 
			FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
			ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
			AND ( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			WHERE ( bol.T_NBR = abol.BOL_ID )
		) 
		ORDER BY abol.BOL_ID ASC
	END
END
ELSE IF (@sCategory='LOAD_NBR') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
BEGIN
		IF ( @INBOLID = 0 )
		BEGIN
			SELECT TOP 1 @INBOLID = T_NBR 
			FROM dbo.DQA_BL WITH (NOLOCK)
			WHERE ( LOAD_NBR = @SCATEGORYVALUES )
			ORDER BY T_NBR 
		END

		SELECT TOP 1 @local_t_nbr = abol.BOL_ID
		FROM
		(	
			SELECT cmpy_bills.BOL_ID 
			FROM dbo.v_DQA_ASSIGN_CMPNY_EXCPTN_1 AS cmpy_bills WITH (NOLOCK)
			WHERE 
			( 					
				( cmpy_bills.BOL_ID > @INBOLID )					
				AND ( cmpy_bills.LOAD_NBR = @sCategoryValues )
				AND ( cmpy_bills.DIR = @SDIR ) 
			)
		) AS abol
		WHERE EXISTS
		(
			SELECT 1 
			FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
			ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
			AND ( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			WHERE ( bol.T_NBR = abol.BOL_ID )
		) 
		ORDER BY abol.BOL_ID ASC

		--If no T_NBR returned, search from the SKIPPED bucket
		IF ( @local_t_nbr = 0 OR @local_t_nbr IS NULL )
		BEGIN
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID
			FROM
			(
				SELECT skip_bill.BOL_ID 
				FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN_1 AS skip_bill WITH (NOLOCK)		
				WHERE ( skip_bill.BOL_ID > @INBOLID )
				AND ( skip_bill.DIR = @SDIR ) 					
				AND ( skip_bill.LOAD_NBR = @sCategoryValues )
			) AS abol
			WHERE EXISTS
			(
				SELECT 1 
				FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
				AND ( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
				WHERE ( bol.T_NBR = abol.BOL_ID )
			) 
			ORDER BY abol.BOL_ID ASC
		END
END
ELSE IF (@sCategory='VDATE') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
BEGIN				
		IF ( @INBOLID = 0 )
		BEGIN
			SELECT TOP 1 @INBOLID = T_NBR 
			FROM dbo.DQA_BL WITH (NOLOCK)
			WHERE ( VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
			ORDER BY T_NBR 
		END

		SELECT TOP 1 @LOCAL_T_NBR = abol.BOL_ID
		FROM
		(	
			SELECT cmpy_bills.BOL_ID 
			FROM dbo.v_DQA_ASSIGN_CMPNY_EXCPTN_1 AS cmpy_bills WITH (NOLOCK)
			WHERE 
			( 
				( cmpy_bills.BOL_ID > @INBOLID )
				AND ( cmpy_bills.DIR = @SDIR ) 
				AND ( cmpy_bills.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )					
			)
		) AS abol
		WHERE EXISTS
		(
			SELECT 1 
			FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
			ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
			AND ( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			WHERE ( bol.T_NBR = abol.BOL_ID )
		) 
		ORDER BY abol.BOL_ID ASC

		--If no T_NBR returned, search from the SKIPPED bucket
		IF ( @local_t_nbr = 0 OR @local_t_nbr IS NULL )
		BEGIN
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID
			FROM
			(
				SELECT skip_bill.BOL_ID 
				FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN_1 AS skip_bill WITH (NOLOCK)		
				WHERE ( skip_bill.BOL_ID > @INBOLID )
				AND ( skip_bill.DIR = @SDIR ) 
				AND ( skip_bill.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
			) AS abol
			WHERE EXISTS
			(
				SELECT 1 
				FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
				AND ( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
				WHERE ( bol.T_NBR = abol.BOL_ID )
			) 
			ORDER BY abol.BOL_ID ASC
		END
END
ELSE IF (@sCategory='VDATE AS PRODMONTH') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
BEGIN
		IF ( @INBOLID = 0 )
		BEGIN
			SELECT TOP 1 @INBOLID = T_NBR 
			FROM dbo.DQA_BL WITH (NOLOCK)
			WHERE ( VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE )
			ORDER BY T_NBR 
		END

		SELECT TOP 1 @LOCAL_T_NBR = abol.BOL_ID
		FROM
		(	
			SELECT cmpy_bills.BOL_ID 
			FROM dbo.v_DQA_ASSIGN_CMPNY_EXCPTN_1 AS cmpy_bills WITH (NOLOCK)
			WHERE 
			( 
				( cmpy_bills.BOL_ID > @INBOLID )		
				AND ( cmpy_bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE )				
				AND ( cmpy_bills.DIR = @SDIR ) 			
			)
		) AS abol
		WHERE EXISTS
		(
			SELECT 1 
			FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
			ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
			AND ( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 					
			WHERE ( bol.T_NBR = abol.BOL_ID )
		) 
		ORDER BY abol.BOL_ID

		--If no T_NBR returned, search from the SKIPPED bucket
		IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
		BEGIN
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID
			FROM
			(
				SELECT skip_bill.BOL_ID 
				FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN_1 AS skip_bill WITH (NOLOCK)		
				WHERE ( skip_bill.BOL_ID > @INBOLID )			
				AND ( skip_bill.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE )					
				AND ( skip_bill.DIR = @SDIR )
			) AS abol
			WHERE EXISTS
			(
				SELECT 1 
				FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
				AND ( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
				WHERE ( bol.T_NBR = abol.BOL_ID )
			)
			ORDER BY abol.BOL_ID 					
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @local_t_nbr = abol.BOL_ID
		FROM
		(	
			SELECT cmpy_bills.BOL_ID 
			FROM dbo.v_DQA_ASSIGN_CMPNY_EXCPTN_1 AS cmpy_bills WITH (NOLOCK)
			WHERE 
			( 
				( cmpy_bills.BOL_ID > @INBOLID )
				AND ( cmpy_bills.DIR = @SDIR ) 
			)
		) AS abol
		WHERE EXISTS
		(
			SELECT 1 
			FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
			ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
			WHERE 
			( 						
				( bol.T_NBR = abol.BOL_ID )								
				AND ( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
			)
		) 
		ORDER BY abol.BOL_ID ASC

		--If no T_NBR returned, search from the SKIPPED bucket
		IF ( @local_t_nbr = 0 OR @local_t_nbr IS NULL )
		BEGIN
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID
			FROM
			(
				SELECT skip_bill.BOL_ID 
				FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN_1 AS skip_bill WITH (NOLOCK)								
				WHERE ( skip_bill.BOL_ID > @INBOLID )
			) AS abol
			JOIN
			(
				SELECT bol.T_NBR 
				FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
				WHERE 
				( 
					( bol.DIR = @SDIR ) 
					AND ( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
				)
			) AS bbol
			ON ( abol.BOL_ID = bbol.T_NBR )	
			ORDER BY abol.BOL_ID							
		END

		/*If no T_NBR returned in both the above cases, read the first available bill from the SKIPPED BUCKET
		as the exception list reached the logical end*/
		IF ( @local_t_nbr = 0 OR @local_t_nbr IS NULL )
		BEGIN
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID
			FROM
			(
				SELECT skip_bill.BOL_ID 
				FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN_1 AS skip_bill WITH (NOLOCK)								
				WHERE ( skip_bill.BOL_ID > 0 )
			) AS abol
			JOIN
			(
				SELECT bol.T_NBR 
				FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
				WHERE 
				( 
					( bol.DIR = @SDIR ) 
					AND ( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
				)
			) AS bbol
			ON ( abol.BOL_ID = bbol.T_NBR )		
			ORDER BY abol.BOL_ID						
		END
	END
END
ELSE IF ( @sCategory='DAILY_LOAD_DT' ) and ( @sCategoryValues <> 'ALL' )  and ( @sCategoryValues <> '' )
BEGIN
	IF ( @INBOLID = 0 )
	BEGIN
		SELECT TOP 1 @INBOLID = T_NBR 
		FROM dbo.DQA_BL WITH (NOLOCK)
		WHERE ( CONVERT(VARCHAR(10),DAILY_LOAD_DT,101) = @SCATEGORYVALUES )
		AND ( DIR = @SDIR ) 
		ORDER BY T_NBR 
	END

	SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
	FROM
	(
		SELECT QC_bills.T_NBR
		FROM dbo.v_DQA_ASSIGN_QC_EXCPTN_1 AS QC_bills WITH (NOLOCK)
		WHERE 
		( 
			( QC_bills.T_NBR > @INBOLID )
			AND ( CONVERT(VARCHAR(10),QC_bills.DAILY_LOAD_DT,101)= @SCATEGORYVALUES )
			AND ( QC_bills.DIR = @SDIR )
			AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 				
		)
	) AS A		
	WHERE EXISTS 
	(
		SELECT  1 
		FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
		AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
		AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		WHERE ( BL_BL.T_NBR = A.T_NBR )
	)
	ORDER BY A.T_NBR

	--If no T_NBR returned, search from the SKIPPED bucket
	IF ( @local_t_nbr = 0 OR @local_t_nbr IS NULL )
	BEGIN
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
		FROM
		(
			SELECT T_NBR
			FROM dbo.[v_DQA_ASSIGN_SKIP_QC_EXCPTN_1] WITH (NOLOCK) 
			WHERE 
			( 				
				( CONVERT(VARCHAR(10),DAILY_LOAD_DT,101) = @SCATEGORYVALUES )					
				AND ( T_NBR > @INBOLID )
				AND ( DIR = @SDIR )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
			)
		) AS A
		WHERE EXISTS 
		(
			SELECT  1 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
			WHERE ( BL_BL.T_NBR = A.T_NBR )
		)
		ORDER BY A.T_NBR
	END	
END
ELSE IF (@sCategory='LOAD_NBR') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
BEGIN
	IF ( @INBOLID = 0 )
	BEGIN
		SELECT TOP 1 @INBOLID = T_NBR 
		FROM dbo.DQA_BL WITH (NOLOCK)
		WHERE ( LOAD_NBR = @SCATEGORYVALUES )
		ORDER BY T_NBR 
	END

	SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 	
	FROM
	(
		SELECT QC_bills.T_NBR
		FROM dbo.v_DQA_ASSIGN_QC_EXCPTN_1 AS QC_bills WITH (NOLOCK)
		WHERE 
		( 				
			( QC_bills.LOAD_NUMBER = @sCategoryValues )
			AND ( QC_bills.T_NBR > @INBOLID )
			AND ( QC_bills.DIR = @SDIR )
			AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 				
		)
	) AS A			
	WHERE EXISTS 
	(
		SELECT  1 
		FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
		AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
		AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		WHERE ( BL_BL.T_NBR = A.T_NBR )
	)
	ORDER BY A.T_NBR

	--If no T_NBR returned, search from the SKIPPED bucket
	IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
	BEGIN		
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
		FROM
		(
			SELECT T_NBR
			FROM dbo.[v_DQA_ASSIGN_SKIP_QC_EXCPTN_1] WITH (NOLOCK) 
			WHERE 
			( 					
				( LOAD_NUMBER =@sCategoryValues )
				AND ( T_NBR > @INBOLID )
				AND ( DIR = @SDIR )					
				AND ( PROCESS_NAME =  @SPROC_NAME ) 									
			)
		) AS A			
		WHERE EXISTS 
		(
			SELECT  1 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
			WHERE ( BL_BL.T_NBR = A.T_NBR )
		)
		ORDER BY A.T_NBR

	END
END
ELSE IF ( @sCategory='VDATE' ) AND (@sCategoryValues <> 'ALL' ) AND ( @sCategoryValues <> '' )
BEGIN
	SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 	
	FROM
	(
		SELECT QC_bills.T_NBR
		FROM dbo.v_DQA_ASSIGN_QC_EXCPTN_1 AS QC_bills WITH (NOLOCK)
		WHERE 
		( 
			( QC_bills.T_NBR > @INBOLID ) 
			AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
			AND ( QC_bills.DIR = @SDIR )
			AND ( QC_bills.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) ) 
		)
	) AS A
	JOIN
	(
		SELECT  T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
		AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')='PENDING' )
		AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
	) AS B
	ON ( A.T_NBR = B.T_NBR )		
	ORDER BY A.T_NBR ASC

	--If no T_NBR returned, search from the SKIPPED bucket
	IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
	BEGIN		
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
		FROM
		(
			SELECT T_NBR
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 									
				( PROCESS_NAME =  @SPROC_NAME ) 					
				AND ( T_NBR > @INBOLID )
				AND ( DIR = @SDIR )			
				AND ( VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) ) 				
			)
		) AS A
		JOIN
		(
			SELECT  T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')= 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		) AS B
		ON ( A.T_NBR = B.T_NBR )
		ORDER BY A.T_NBR ASC					
	END

	/*If no T_NBR returned in both the above cases, read the first available bill from the SKIPPED BUCKET
	as the exception list reached the logical end*/
	IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
	BEGIN		
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
		FROM
		(
			SELECT T_NBR
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 				
				( T_NBR > 0 )			
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
				AND ( DIR = @SDIR )
				AND ( VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) ) 
			)
		) AS A
		JOIN
		(
			SELECT T_NBR 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')= 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		) AS B
		ON ( A.T_NBR = B.T_NBR )
		ORDER BY A.T_NBR ASC
	END
END
ELSE IF ( @sCategory='VDATE AS PRODMONTH' ) and (@sCategoryValues <> 'ALL' ) and (@sCategoryValues <> '' )
BEGIN
	IF ( @INBOLID = 0 )
	BEGIN
		SELECT TOP 1 @INBOLID = T_NBR 
		FROM dbo.DQA_BL WITH (NOLOCK)
		WHERE ( VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE )
		AND ( DIR = @SDIR )
		ORDER BY T_NBR 
	END

	SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 	
	FROM
	(
		SELECT QC_bills.T_NBR 
		FROM dbo.v_DQA_ASSIGN_QC_EXCPTN_1 AS QC_bills WITH (NOLOCK)
		WHERE 
		( 			
			( QC_bills.T_NBR > @INBOLID )				
			AND ( QC_Bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE) 				
			AND ( QC_bills.DIR = @SDIR )							
			AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 				
		)
	) AS A
	WHERE EXISTS 
	(
		SELECT  1 
		FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE') 
		AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
		AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )          
		WHERE ( BL_BL.T_NBR = A.T_NBR )
	)
	ORDER BY A.T_NBR

	IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
	BEGIN
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
		FROM
		(
			SELECT T_NBR
			FROM dbo.[v_DQA_ASSIGN_SKIP_QC_EXCPTN_1] WITH (NOLOCK) 
			WHERE 
			( 				
				( VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE) 
				AND ( T_NBR > @INBOLID )
				AND ( DIR = @SDIR )									
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
			)
		) AS A
		WHERE EXISTS 
		(
			SELECT  1 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( BL_BL.DQA_BL_STATUS='PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
			WHERE ( BL_BL.T_NBR = A.T_NBR )
		)
		ORDER BY A.T_NBR ASC
	END
END
ELSE 
BEGIN
	IF ( @INBOLID = 0 )
	BEGIN
		SELECT TOP 1 @INBOLID = T_NBR 
		FROM dbo.DQA_BL WITH (NOLOCK)
		WHERE ( DIR = @SDIR )
		ORDER BY T_NBR 
	END

	SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 	
	FROM
	(
		SELECT QC_bills.T_NBR
		FROM dbo.v_DQA_ASSIGN_QC_EXCPTN_1 AS QC_bills WITH (NOLOCK)
		WHERE 
		( 
			( QC_bills.T_NBR > @INBOLID )
			AND ( QC_bills.DIR = @SDIR )
			AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
		)
	) AS A
	WHERE EXISTS 
	(
		SELECT  1 
		FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
		ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
		AND ( BL_BL.DQA_BL_STATUS='PENDING' )
		AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		WHERE ( BL_BL.T_NBR = A.T_NBR )
	)
	ORDER BY A.T_NBR ASC

	IF ( @LOCAL_T_NBR = 0 OR @LOCAL_T_NBR IS NULL )
	BEGIN
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR
		FROM
		(
			SELECT T_NBR
			FROM dbo.[v_DQA_ASSIGN_SKIP_QC_EXCPTN_1] WITH (NOLOCK) 
			WHERE 
			( 					
				( T_NBR > @INBOLID )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 					
				AND ( DIR = @SDIR )					
			)
		) AS A
		WHERE EXISTS 
		(
			SELECT  1 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( BL_BL.DQA_BL_STATUS='PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
			WHERE ( BL_BL.T_NBR = A.T_NBR )
		)
		ORDER BY A.T_NBR ASC
	END
END

--CR #4881 Concurrency Issue (Locking code moved to the procedure).
IF ( @local_t_nbr > 0 )
BEGIN
	UPDATE dbo.DQA_BL WITH (UPDLOCK) 
	SET LOCKED_BY_USR = @user_id, locked_by_date = GETDATE() , edit_mode = 'EXCP_MGMT' 
	WHERE T_NBR = @local_t_nbr	
END  

SET @Out_T_NBR = @local_t_nbr 

-- [aa] - 09/18/2010
-- Log end time
EXEC dbo.usp_LogSProcCallsEnd
@Id = @IdLogOut
,@RowsAffected = @@ROWCOUNT

END
GO
