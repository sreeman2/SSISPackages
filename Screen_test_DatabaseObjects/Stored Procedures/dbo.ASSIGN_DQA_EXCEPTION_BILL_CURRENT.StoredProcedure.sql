/****** Object:  StoredProcedure [dbo].[ASSIGN_DQA_EXCEPTION_BILL_CURRENT]    Script Date: 01/03/2013 19:47:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ASSIGN_DQA_EXCEPTION_BILL_CURRENT]  
	@user_id			VARCHAR(100), 
	@INBOLID			NUMERIC(10,0), 
	@sDir				VARCHAR(100),
	@sProc_Name			VARCHAR(100), 
	@sCategory			VARCHAR(100),
	@sCategoryValues	VARCHAR(100),
	@Out_T_NBR			NUMERIC(13,2)OUT 
AS
SET NOCOUNT ON;

-- [aa] - 09/18/2010
-- Log start time
DECLARE @IdLogOut int
DECLARE @ParametersIn varchar(MAX)
SET @ParametersIn =
 '@user_id='''+@user_id+''''
+', @INBOLID='++LTRIM(RTRIM(STR(@INBOLID)))
+', @sDir='''+@sDir+''''
+', @sProc_Name='''+@sProc_Name+''''
+', @sCategory='''+@sCategory+''''
+', @sCategoryValues='''+@sCategoryValues+''''
EXEC dbo.usp_LogSProcCallsStart
 @SprocName = 'ASSIGN_DQA_EXCEPTION_BILL_CURRENT'
,@Parameters = @ParametersIn
,@IdLog = @IdLogOut OUT


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

	IF ( @sCategory = 'VDATE AS PRODMONTH' )
	BEGIN		
		SET @POSITION = CHARINDEX(' ',@sCategoryValues, 0 )
		SET @STRMONTH = SUBSTRING(@sCategoryValues,0,@POSITION+1 )
		SET @STRYEAR  = SUBSTRING(@sCategoryValues,@POSITION+1, LEN(@sCategoryValues) )

		SET @MONTHSTARTDATE = CAST('01/' + @STRMONTH + '/' + @STRYEAR AS DATETIME)
		SET @MONTHENDDATE = DATEADD(DD, -1, DATEADD(MM, 1, @MONTHSTARTDATE))
	END

	IF( @SProc_Name = 'COMPANY EXCEPTIONS' ) 
	BEGIN	
		IF ( @sCategory='DAILY_LOAD_DT' ) AND ( @sCategoryValues <> 'ALL')  AND ( @sCategoryValues <> '' )
		BEGIN				
			--Check if this is a non skipped last record , and if yes set @INBOLID = 0
			IF EXISTS
			(
				SELECT TOP 1 abol.BOL_ID
				FROM
				(	
					SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
					FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
					WHERE 
					( 
						( CONVERT(VARCHAR(10),cmpy_bills.DAILY_LOAD_DT,101) = @SCATEGORYVALUES )						
						AND NOT EXISTS
						( 
							SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
							WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
						) 												
					)
				) AS abol
				JOIN
				(
					SELECT bol.T_NBR 
					FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
					ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
					WHERE 
					( 						
						( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
						AND ( bol.DIR = @SDIR ) 
					)
				) AS bbol
				ON ( abol.BOL_ID = bbol.T_NBR )				
				WHERE ( abol.BOL_ID > @INBOLID )
				ORDER BY abol.BOL_ID ASC
			)
			BEGIN
				SET @INBOLID = @INBOLID
			END
			ELSE
			BEGIN
				IF EXISTS 
				( 
					SELECT TOP 1 abol.BOL_ID
					FROM
					(
						SELECT DISTINCT skip_bill.BOL_ID 
						FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)		
						WHERE ( CONVERT(VARCHAR(10),skip_bill.DAILY_LOAD_DT,101)=@SCATEGORYVALUES )				
					) AS abol
					JOIN
					(
						SELECT bol.T_NBR 
						FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
						ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
						WHERE 
						( 							
							( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
							AND ( bol.DIR = @SDIR ) 
						)
					) AS bbol
					ON ( abol.BOL_ID = bbol.T_NBR )				
					WHERE ( abol.BOL_ID > @INBOLID )
					ORDER BY abol.BOL_ID ASC
				)
				BEGIN
					--SET @INBOLID = @INBOLID
					SET @NEXT_BOL = @INBOLID
				END
				ELSE
				BEGIN
					SET @INBOLID = 0
					SET @NEXT_BOL =0
				END
			END			
			---------------------------------------------------------------------------------------------
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID 				 
			FROM
			(	
				SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
				FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
				WHERE 
				( 
					( CONVERT(VARCHAR(10),cmpy_bills.DAILY_LOAD_DT,101) = @SCATEGORYVALUES )
					AND NOT EXISTS
					( 
						SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
					) 					
				)
				UNION ALL
				SELECT DISTINCT BOL_ID,  1 AS SKIPPED 
				FROM v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN WITH (NOLOCK) 
				WHERE ( CONVERT(VARCHAR(10),DAILY_LOAD_DT,101) =@SCATEGORYVALUES )
			) abol
			JOIN
			(
				SELECT bol.T_NBR FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON ( bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE' )	 
				WHERE 
				( 
					( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') )
					AND ( bol.DIR = @SDIR )
				)
			) bbol
			ON abol.BOL_ID = bbol.T_NBR
			WHERE ( abol.BOL_ID > (CASE WHEN abol.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
			ORDER BY abol.SKIPPED ASC, abol.BOL_ID ASC
		END
		ELSE IF (@sCategory='LOAD_NBR') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
		BEGIN
			--Check if this is a non skipped last record , and if yes set @INBOLID = 0
			IF EXISTS
			(
				SELECT TOP 1 abol.BOL_ID
				FROM
				(	
					SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
					FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
					WHERE 
					( 
						NOT EXISTS
						( 
							SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
							WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
						) 						
						AND ( cmpy_bills.LOAD_NBR =@sCategoryValues )
					)
				) AS abol
				JOIN
				(
					SELECT bol.T_NBR 
					FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
					ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
					WHERE 
					( 
						( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
						AND ( bol.DIR = @SDIR ) 
					)
				) AS bbol
				ON ( abol.BOL_ID = bbol.T_NBR )				
				WHERE ( abol.BOL_ID > @INBOLID )
				ORDER BY abol.BOL_ID ASC
			)
			BEGIN
				SET @INBOLID = @INBOLID
			END
			ELSE
			BEGIN
				IF EXISTS 
				( 
					SELECT TOP 1 abol.BOL_ID
					FROM
					(
						SELECT DISTINCT skip_bill.BOL_ID 
						FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)		
						WHERE ( skip_bill.LOAD_NBR = @sCategoryValues )
					) AS abol
					JOIN
					(
						SELECT bol.T_NBR 
						FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
						ON (bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE')	 
						WHERE 
						( 
							( ISNULL(bol.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') ) 
							AND ( bol.DIR = @SDIR ) 
						)
					) AS bbol
					ON ( abol.BOL_ID = bbol.T_NBR )				
					WHERE ( abol.BOL_ID > @INBOLID )
					ORDER BY abol.BOL_ID ASC
				)
				BEGIN
					SET @NEXT_BOL = @INBOLID
				END
				ELSE
				BEGIN
					SET @INBOLID = 0
					SET @NEXT_BOL =0
				END
			END			
			----------------------------------------------------------------------------------------------
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID 				 
			FROM
			(	
				SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
				FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
					) 
					AND ( cmpy_bills.LOAD_NBR =@sCategoryValues )
				)
				UNION ALL
				SELECT DISTINCT BOL_ID, 1 AS SKIPPED 
				FROM v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN WITH (NOLOCK) 
				WHERE ( LOAD_NBR =@sCategoryValues )
			) abol
			JOIN
			(
				SELECT bol.T_NBR FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON ( bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE' )	 
				WHERE 
				(
					( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') )
					AND ( bol.DIR = @SDIR )
				)
			) bbol
			ON abol.BOL_ID = bbol.T_NBR
			WHERE ( abol.BOL_ID > (CASE WHEN abol.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
			ORDER BY abol.SKIPPED ASC, abol.BOL_ID ASC
		END
		ELSE IF (@sCategory='VDATE') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
		BEGIN				
			--Check if this is a non skipped last record , and if yes set @INBOLID = 0
			IF EXISTS
			(
				SELECT TOP 1 abol.BOL_ID
				FROM
				(	
					SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
					FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
					WHERE 
					( 
						NOT EXISTS
						( 
							SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
							WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
						) 						
						AND ( cmpy_bills.VDATE IS NOT NULL AND cmpy_bills.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
					)
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
				WHERE ( abol.BOL_ID > @INBOLID )
				ORDER BY abol.BOL_ID ASC
			)
			BEGIN
				SET @INBOLID = @INBOLID
			END
			ELSE
			BEGIN
				IF EXISTS 
				( 
					SELECT TOP 1 abol.BOL_ID
					FROM
					(
						SELECT DISTINCT skip_bill.BOL_ID 
						FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)		
						WHERE ( skip_bill.VDATE IS NOT NULL AND skip_bill.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
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
					WHERE ( abol.BOL_ID > @INBOLID )
					ORDER BY abol.BOL_ID ASC
				)
				BEGIN
					SET @NEXT_BOL = @INBOLID
				END
				ELSE
				BEGIN
					SET @INBOLID = 0
					SET @NEXT_BOL =0
				END
			END			
			----------------------------------------------------------------------------------------------
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID 				 
			FROM
			(	
				SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
				FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
					) 
					AND ( cmpy_bills.VDATE IS NOT NULL AND cmpy_bills.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
				)
				UNION ALL
				SELECT DISTINCT BOL_ID, 1 AS SKIPPED 
				FROM v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN WITH (NOLOCK) 
				WHERE ( VDATE IS NOT NULL AND VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
			) abol
			JOIN
			(
				SELECT bol.T_NBR FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON ( bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE' )	 
				WHERE 
				(
					( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') )					
					AND ( bol.DIR = @SDIR )
				)
			) bbol
			ON ( abol.BOL_ID = bbol.T_NBR )
			WHERE ( abol.BOL_ID > (CASE WHEN abol.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
			ORDER BY abol.SKIPPED ASC, abol.BOL_ID ASC
		END
		ELSE IF (@sCategory='VDATE AS PRODMONTH') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
		BEGIN
			--Check if this is a non skipped last record , and if yes set @INBOLID = 0
			IF EXISTS
			(
				SELECT TOP 1 abol.BOL_ID
				FROM
				(	
					SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
					FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
					WHERE 
					( 
						NOT EXISTS
						( 
							SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
							WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
						) 						
						AND ( cmpy_bills.VDATE IS NOT NULL AND cmpy_bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE)
					)
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
				WHERE ( abol.BOL_ID > @INBOLID )
				ORDER BY abol.BOL_ID ASC
			)
			BEGIN
				SET @INBOLID = @INBOLID
			END
			ELSE
			BEGIN
				IF EXISTS 
				( 
					SELECT TOP 1 abol.BOL_ID
					FROM
					(
						SELECT DISTINCT skip_bill.BOL_ID 
						FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)		
						WHERE ( skip_bill.VDATE IS NOT NULL AND skip_bill.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE)
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
					WHERE ( abol.BOL_ID > @INBOLID )
					ORDER BY abol.BOL_ID ASC
				)
				BEGIN
					SET @NEXT_BOL = @INBOLID
				END
				ELSE
				BEGIN
					SET @INBOLID = 0
					SET @NEXT_BOL =0
				END
			END			
			----------------------------------------------------------------------------------------------
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID 				 
			FROM
			(	
				SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
				FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
					) 						
					AND ( cmpy_bills.VDATE IS NOT NULL AND cmpy_bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE)
				)
				UNION ALL
				SELECT DISTINCT BOL_ID, 1 AS SKIPPED 
				FROM v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN WITH (NOLOCK) 					
				WHERE ( VDATE IS NOT NULL AND VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE)
				AND BOL_ID NOT IN ( @INBOLID,@NEXT_BOL ) 
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
			WHERE ( abol.BOL_ID > (CASE WHEN abol.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
			ORDER BY abol.SKIPPED ASC, abol.BOL_ID ASC
		END
		ELSE
		BEGIN
			IF EXISTS
			(
				SELECT TOP 1 abol.BOL_ID
				FROM
				(	
					SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
					FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
					WHERE 
					( 
						NOT EXISTS
						( 
							SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
							WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
						) 													
					)
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
				WHERE ( abol.BOL_ID > @INBOLID )
				ORDER BY abol.BOL_ID ASC
			)
			BEGIN
				SET @INBOLID = @INBOLID
			END
			ELSE
			BEGIN
				IF EXISTS 
				( 
					SELECT TOP 1 abol.BOL_ID
					FROM
					(
						SELECT DISTINCT skip_bill.BOL_ID 
						FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)								
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
					WHERE ( abol.BOL_ID > @INBOLID )
					ORDER BY abol.BOL_ID ASC
				)
				BEGIN
					SET @NEXT_BOL = @INBOLID
				END
				ELSE
				BEGIN
					SET @INBOLID = 0
					SET @NEXT_BOL =0
				END
			END		
			----------------------------------------------------------------------------------------------				
			--Populate BOL Ids first
			SELECT TOP 1 @local_t_nbr = abol.BOL_ID 				 
			FROM
			(	
				SELECT DISTINCT cmpy_bills.BOL_ID, 0 AS SKIPPED 
				FROM v_DQA_ASSIGN_CMPNY_EXCPTN AS cmpy_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.BOL_ID FROM dbo.v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( cmpy_bills.BOL_ID  = skip_bill.BOL_ID )
					) 					
				)
				UNION ALL
				SELECT DISTINCT BOL_ID, 1 AS SKIPPED 
				FROM v_DQA_ASSIGN_SKIP_CMPNY_EXCPTN WITH (NOLOCK) 
			) AS abol
			JOIN
			(
				SELECT	bol.T_NBR 
				FROM dbo.BL_BL AS bol WITH (NOLOCK) JOIN dbo.DQA_VOYAGE AS dvg WITH (NOLOCK) 
				ON ( bol.DQA_VOYAGE_ID = dvg.VOYAGE_ID AND dvg.VOYAGE_STATUS = 'AVAILABLE' )	 
				WHERE 
				(
					( ISNULL(bol.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') )					
					AND ( bol.DIR = @SDIR )
				)
			) AS bbol
			ON ( abol.BOL_ID = bbol.T_NBR )
			WHERE ( abol.BOL_ID > (CASE WHEN abol.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
			ORDER BY abol.SKIPPED ASC,abol.BOL_ID ASC
		END
	END
	ELSE IF ( @sCategory='DAILY_LOAD_DT' ) and ( @sCategoryValues <> 'ALL' )  and ( @sCategoryValues <> '' )
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					( CONVERT(VARCHAR(10),QC_bills.DAILY_LOAD_DT,101)=@SCATEGORYVALUES )
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
					AND ( QC_bills.DIR = @SDIR )
					AND NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
				)
			) AS A
--			JOIN
--			(
--				SELECT  T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--				WHERE 
--				( 
--					( BL_BL.DQA_BL_STATUS ='PENDING' )
--					AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
--				)       
--			) AS B
--			ON ( A.T_NBR = B.T_NBR )		
			WHERE ( A.T_NBR > @INBOLID )
			AND EXISTS 
			(
				SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
				WHERE 
				( 
					( A.T_NBR = BL_BL.T_NBR )
					AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
					AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
				)       
			)
			ORDER BY A.T_NBR ASC
	)
	BEGIN
		SET @INBOLID = @INBOLID
	END
	ELSE
	BEGIN
		IF EXISTS 
		( 
			SELECT TOP 1 A.T_NBR
			FROM
			(
				SELECT T_NBR
				FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
				WHERE 
				( 				
					( CONVERT(VARCHAR(10),DAILY_LOAD_DT,101) = @SCATEGORYVALUES )
					AND ( PROCESS_NAME =  @SPROC_NAME ) 
					AND ( DIR = @SDIR )
				)
			) AS A
--			JOIN
--			(
--				SELECT  T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--				AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')='PENDING' )
--				AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
--			) AS B
--			ON ( A.T_NBR = B.T_NBR )		
			WHERE ( A.T_NBR > @INBOLID )
			AND EXISTS 
			(
				SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
				WHERE 
				( 
					( A.T_NBR = BL_BL.T_NBR )
					AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
					AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
				)       
			)
			ORDER BY A.T_NBR ASC
		)
		BEGIN
			SET @NEXT_BOL = @INBOLID
		END
		ELSE
		BEGIN
			SET @INBOLID = 0
			SET @NEXT_BOL =0
		END
	END		
	---------------------------------------------------------------------------------------------
		--Populate BOL Ids first
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				( CONVERT(VARCHAR(10),QC_bills.DAILY_LOAD_DT,101) =@SCATEGORYVALUES )
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
				AND ( QC_bills.DIR = @SDIR )
				AND NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 
				( CONVERT(VARCHAR(10),DAILY_LOAD_DT,101) = @SCATEGORYVALUES )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
				AND ( DIR = @SDIR )
			)
		) AS A
--		JOIN
--		(
--				SELECT T_NBR 
--				FROM dbo.BL_BL (NOLOCK) JOIN dbo.DQA_VOYAGE (NOLOCK) 
--				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )
--				AND ( ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' )
--				AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
--		) AS B
--		ON ( A.T_NBR = B.T_NBR )
		WHERE EXISTS 
		(
			SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			WHERE 
			( 
				( A.T_NBR = BL_BL.T_NBR )
				AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
				AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
			)       
		)
		AND ( A.T_NBR > ( CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END ) )
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC	
	END
	ELSE IF (@sCategory='LOAD_NBR') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR 	
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					( QC_bills.LOAD_NUMBER =@sCategoryValues )
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
					AND ( QC_bills.DIR = @SDIR )
					AND NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
				)
			) AS A
--			JOIN
--			(
--				SELECT  T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--				AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')='PENDING' )
--				AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
--			) AS B
--			ON ( A.T_NBR = B.T_NBR )		
			WHERE ( A.T_NBR > @INBOLID )
			AND EXISTS 
			(
				SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
				WHERE 
				( 
					( A.T_NBR = BL_BL.T_NBR )
					AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
					AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
				)       
			)
			ORDER BY A.T_NBR ASC
	)
	BEGIN
			SET @INBOLID = @INBOLID
	END
	ELSE
	BEGIN
			IF EXISTS 
			( 
				SELECT TOP 1 A.T_NBR
				FROM
				(
					SELECT DISTINCT T_NBR
					FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
					WHERE 
					( 				
						( LOAD_NUMBER =@sCategoryValues )
						AND ( PROCESS_NAME =  @SPROC_NAME ) 
						AND ( DIR = @SDIR )
					)
				) AS A
--				JOIN
--				(
--					SELECT  T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--					ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--					AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')='PENDING' )
--					AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
--				) AS B
--				ON ( A.T_NBR = B.T_NBR )		
				WHERE ( A.T_NBR > @INBOLID )
				AND EXISTS 
				(
					SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
					ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
					WHERE 
					( 
						( A.T_NBR = BL_BL.T_NBR )
						AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
						AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
					)       
				)
				ORDER BY A.T_NBR ASC
			)
			BEGIN
				SET @NEXT_BOL = @INBOLID
			END
			ELSE
			BEGIN
				SET @INBOLID = 0
				SET @NEXT_BOL =0
			END
	END		
	---------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				( QC_bills.LOAD_NUMBER = @sCategoryValues )
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
				AND ( QC_bills.DIR = @SDIR )
				AND NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 
				( LOAD_NUMBER = @sCategoryValues )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
				AND ( DIR = @SDIR )
			)
		)A
--		JOIN
--		(
--			SELECT  T_NBR FROM dbo.BL_BL (NOLOCK) JOIN dbo.DQA_VOYAGE (NOLOCK) 
--			ON ( BL_BL.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )
--			AND ( BL_BL.LOAD_NBR = @sCategoryValues )
--			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'')='PENDING' )
--			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
--		)B
--		ON ( A.T_NBR = B.T_NBR )
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
		AND EXISTS 
		(
			SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			WHERE 
			( 
				( A.T_NBR = BL_BL.T_NBR )
				AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
				AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
			)       
		)
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC
	END
	ELSE IF ( @sCategory='VDATE' ) AND (@sCategoryValues <> 'ALL' ) AND ( @sCategoryValues <> '' )
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR 	
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					( QC_bills.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) ) --QC_bills.VDATE IS NOT NULL AND 
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
					AND ( QC_bills.DIR = @SDIR )
					AND NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
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
			WHERE ( A.T_NBR > @INBOLID )
--			AND EXISTS 
--			(
--				SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--				ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--				WHERE 
--				( 
--					( A.T_NBR = BL_BL.T_NBR )
--					AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
--					AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
--				)       
--			)
			ORDER BY A.T_NBR ASC
	)
	BEGIN
			SET @INBOLID = @INBOLID
		END
		ELSE
		BEGIN
			IF EXISTS 
			( 
				SELECT TOP 1 A.T_NBR
				FROM
				(
					SELECT DISTINCT T_NBR
					FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
					WHERE 
					( 				
						( VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) ) --VDATE IS NOT NULL AND 
						AND ( PROCESS_NAME =  @SPROC_NAME ) 
						AND ( DIR = @SDIR )
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
				WHERE ( A.T_NBR > @INBOLID )
--				AND EXISTS 
--				(
--					SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--					ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--					WHERE 
--					( 
--						( A.T_NBR = BL_BL.T_NBR )
--						AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
--						AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
--					)       
--				)
				ORDER BY A.T_NBR ASC
			)
			BEGIN
				SET @NEXT_BOL = @INBOLID
			END
			ELSE
			BEGIN
				SET @INBOLID = 0
				SET @NEXT_BOL =0
			END
		END		
		---------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				( QC_bills.VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )				--QC_bills.VDATE IS NOT NULL AND 
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
				AND ( QC_bills.DIR = @SDIR )
				AND NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 
				( VDATE IS NOT NULL AND VDATE BETWEEN CONVERT(SMALLDATETIME,@sCategoryValues) AND DATEADD(DD,7,CONVERT(SMALLDATETIME,@sCategoryValues)) )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
				AND ( DIR = @SDIR )				
			)
		) AS A
		JOIN
		(
			SELECT T_NBR 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		)AS B
		ON ( A.T_NBR = B.T_NBR )
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
--		AND EXISTS 
--		(
--			SELECT  1 FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
--			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
--			WHERE 
--			( 
--				( A.T_NBR = BL_BL.T_NBR )
--				AND ( BL_BL.DQA_BL_STATUS ='PENDING' )
--				AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )    
--			)       
--		)
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC
	END
	ELSE IF ( @sCategory = 'USPORT_ID') AND ( @sCategoryValues <> 'ALL' ) AND ( @sCategoryValues <> '' )
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR 	
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
					AND ( QC_Bills.USPORT_ID = @sCategoryValues )
					AND ( QC_bills.DIR = @SDIR )
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
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
			WHERE ( A.T_NBR > @INBOLID )
			ORDER BY A.T_NBR ASC
	)
	BEGIN
			SET @INBOLID = @INBOLID
		END
		ELSE
		BEGIN
			IF EXISTS 
			( 
				SELECT TOP 1 A.T_NBR
				FROM
				(
					SELECT DISTINCT T_NBR
					FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
					WHERE 
					( 				
						( USPORT_ID = @sCategoryValues )
						AND ( DIR = @SDIR )
						AND ( PROCESS_NAME =  @SPROC_NAME ) 
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
				WHERE ( A.T_NBR > @INBOLID )
				ORDER BY A.T_NBR ASC
			)
			BEGIN
				SET @NEXT_BOL = @INBOLID
			END
			ELSE
			BEGIN
				SET @INBOLID = 0
				SET @NEXT_BOL =0
			END
		END		
		---------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 
				AND ( QC_Bills.USPORT_ID = @sCategoryValues )
				AND ( QC_bills.DIR = @SDIR )
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 
				( USPORT_ID = @sCategoryValues )
				AND ( DIR = @SDIR )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
			)
		) AS A
		JOIN
		(
			SELECT T_NBR 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		)AS B
		ON ( A.T_NBR = B.T_NBR )
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC	
	END
	ELSE IF (@sCategory='CARRIER_ID') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR 	
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
					AND ( QC_Bills.CARRIER_ID = @sCategoryValues )
					AND ( QC_bills.DIR = @SDIR )
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
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
			WHERE ( A.T_NBR > @INBOLID )
			ORDER BY A.T_NBR ASC
	)
	BEGIN
			SET @INBOLID = @INBOLID
		END
		ELSE
		BEGIN
			IF EXISTS 
			( 
				SELECT TOP 1 A.T_NBR
				FROM
				(
					SELECT DISTINCT T_NBR
					FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
					WHERE 
					( 				
						( CARRIER_ID = @sCategoryValues )
						AND ( DIR = @SDIR )
						AND ( PROCESS_NAME =  @SPROC_NAME ) 
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
				WHERE ( A.T_NBR > @INBOLID )
				ORDER BY A.T_NBR ASC
			)
			BEGIN
				SET @NEXT_BOL = @INBOLID
			END
			ELSE
			BEGIN
				SET @INBOLID = 0
				SET @NEXT_BOL =0
			END
		END			
		-----------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 
				AND ( QC_Bills.CARRIER_ID = @sCategoryValues )
				AND ( QC_bills.DIR = @SDIR )
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 
				( CARRIER_ID = @sCategoryValues )
				AND ( DIR = @SDIR )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
			)
		) AS A
		JOIN
		(
			SELECT T_NBR 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID=DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS='AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		)AS B
		ON ( A.T_NBR = B.T_NBR )
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC	
	END
	ELSE IF (@sCategory='VESSEL_ID') and (@sCategoryValues <> 'ALL')and (@sCategoryValues <> '')
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR 	
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
					AND ( QC_Bills.VESSEL_ID = @sCategoryValues )
					AND ( QC_bills.DIR = @SDIR )
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
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
			WHERE ( A.T_NBR > @INBOLID )
			ORDER BY A.T_NBR ASC
	)
	BEGIN
			SET @INBOLID = @INBOLID
		END
		ELSE
		BEGIN
			IF EXISTS 
			( 
				SELECT TOP 1 A.T_NBR
				FROM
				(
					SELECT DISTINCT T_NBR
					FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
					WHERE 
					( 				
						( VESSEL_ID = @sCategoryValues )
						AND ( DIR = @SDIR )
						AND ( PROCESS_NAME =  @SPROC_NAME ) 
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
				WHERE ( A.T_NBR > @INBOLID )
				ORDER BY A.T_NBR ASC
			)
			BEGIN
				SET @NEXT_BOL = @INBOLID
			END
			ELSE
			BEGIN
				SET @INBOLID = 0
				SET @NEXT_BOL =0
			END
		END			
		----------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 
				AND ( QC_Bills.VESSEL_ID = @sCategoryValues )
				AND ( QC_bills.DIR = @SDIR )
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 
				( VESSEL_ID = @sCategoryValues )
				AND ( DIR = @SDIR )
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
			)
		) AS A
		JOIN
		(
			SELECT T_NBR 
			FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'') NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		)AS B
		ON ( A.T_NBR = B.T_NBR )
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC	
	END
	ELSE IF ( @sCategory='VDATE AS PRODMONTH' ) and (@sCategoryValues <> 'ALL' ) and (@sCategoryValues <> '' )
	BEGIN
		--Check if this is a non skipped last record , and if yes set @INBOLID = 0
		IF EXISTS
		(
			SELECT TOP 1 A.T_NBR 	
			FROM
			(
				SELECT DISTINCT QC_bills.T_NBR
				FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
				WHERE 
				( 
					( QC_Bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE) --QC_Bills.VDATE IS NOT NULL AND 
					AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
					AND ( QC_bills.DIR = @SDIR )
					AND NOT EXISTS
					( 
						SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
						WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
					) 				
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
			WHERE ( A.T_NBR > @INBOLID )
			ORDER BY A.T_NBR ASC
	)
	BEGIN
			SET @INBOLID = @INBOLID
		END
		ELSE
		BEGIN
			IF EXISTS 
			( 
				SELECT TOP 1 A.T_NBR
				FROM
				(
					SELECT DISTINCT T_NBR
					FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
					WHERE 
					( 				
						( VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE) --VDATE IS NOT NULL AND
						AND ( PROCESS_NAME =  @SPROC_NAME ) 
						AND ( DIR = @SDIR )
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
				WHERE ( A.T_NBR > @INBOLID )
				ORDER BY A.T_NBR ASC
			)
			BEGIN
				SET @NEXT_BOL = @INBOLID
			END
			ELSE
			BEGIN
				SET @INBOLID = 0
				SET @NEXT_BOL =0
			END
		END			
		-------------------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				( QC_Bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE)			--AND ( QC_Bills.VDATE IS NOT NULL AND QC_Bills.VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE)
				AND ( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
				AND ( QC_bills.DIR = @SDIR )
				AND NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 								
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 				
				( VDATE BETWEEN @MONTHSTARTDATE AND @MONTHENDDATE) --VDATE IS NOT NULL AND
				AND ( PROCESS_NAME =  @SPROC_NAME ) 
				AND ( DIR = @SDIR )
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
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC
	END
	ELSE 
	BEGIN
			--Check if this is a non skipped last record , and if yes set @INBOLID = 0
			IF EXISTS
			(
				SELECT TOP 1 A.T_NBR 	
				FROM
				(
					SELECT DISTINCT QC_bills.T_NBR
					FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
					WHERE 
					( 
						( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
						AND ( QC_bills.DIR = @SDIR )
						AND NOT EXISTS
						( 
							SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
							WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
						) 																
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
				WHERE ( A.T_NBR > @INBOLID )
				ORDER BY A.T_NBR ASC
		)
		BEGIN
				SET @INBOLID = @INBOLID
			END
			ELSE
			BEGIN
				IF EXISTS 
				( 
					SELECT TOP 1 A.T_NBR
					FROM
					(
						SELECT DISTINCT T_NBR
						FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
						WHERE 
						( 										
							( PROCESS_NAME =  @SPROC_NAME ) 
							AND ( DIR = @SDIR )
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
					WHERE ( A.T_NBR > @INBOLID )
					ORDER BY A.T_NBR ASC
				)
				BEGIN
					SET @NEXT_BOL = @INBOLID
				END
				ELSE
				BEGIN
					SET @INBOLID = 0
					SET @NEXT_BOL =0
				END
			END			
		-------------------------------------------------------------------------------------------------------------
		SELECT TOP 1 @LOCAL_T_NBR = A.T_NBR 		 
		FROM
		(
			SELECT DISTINCT QC_bills.T_NBR, 0 AS SKIPPED 
			FROM v_DQA_ASSIGN_QC_EXCPTN AS QC_bills WITH (NOLOCK)
			WHERE 
			( 
				( QC_bills.PROCESS_NAME =  @SPROC_NAME ) 
				AND ( QC_bills.DIR = @SDIR )
				AND NOT EXISTS
				( 
					SELECT skip_bill.T_NBR FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN AS skip_bill WITH (NOLOCK)
					WHERE ( ( QC_bills.T_NBR  = skip_bill.T_NBR ) AND ( skip_bill.PROCESS_NAME = @SPROC_NAME ) )
				) 												
			)
			UNION ALL
			SELECT DISTINCT T_NBR, 1 AS SKIPPED 
			FROM dbo.v_DQA_ASSIGN_SKIP_QC_EXCPTN WITH (NOLOCK) 
			WHERE 
			( 								
				( PROCESS_NAME =  @SPROC_NAME ) 
				AND ( DIR = @SDIR )
			)			
		) AS A
		JOIN
		(
			SELECT T_NBR FROM dbo.BL_BL WITH (NOLOCK) JOIN dbo.DQA_VOYAGE WITH (NOLOCK) 
			ON ( BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID AND DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE' )
			AND ( ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' )
			AND ( ISNULL(BL_BL.BOL_STATUS,'')NOT IN('MASTER','TEMPMASTER','HOUSE') )           
		) AS B
		ON ( A.T_NBR = B.T_NBR )		
		WHERE ( A.T_NBR > (CASE WHEN A.SKIPPED = 0 THEN @INBOLID ELSE @NEXT_BOL END) )
		ORDER BY A.SKIPPED ASC, A.T_NBR ASC
	END
	--CR #4881 Concurrency Issue (Locking code moved to the procedure).
--	IF ( @local_t_nbr > 0 )
--	BEGIN
--		UPDATE DQA_BL WITH (UPDLOCK) 
--		SET LOCKED_BY_USR = @user_id, locked_by_date = GETDATE() , edit_mode = 'EXCP_MGMT' 
--		WHERE T_NBR = @local_t_nbr	
--	END  

	SET @Out_T_NBR = @local_t_nbr 

-- [aa] - 09/18/2010
-- Log end time
EXEC dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut
,@RowsAffected = @@ROWCOUNT

END
GO
