/****** Object:  StoredProcedure [dbo].[LOAD_COMPANY_DETAILS]    Script Date: 01/03/2013 19:47:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pramod Kumar
-- Create date: 29-SEP-2009
-- Description:	GET COMPANY DETAILS
-- Changed on 29th SEP 2009
-- To select the External BOL Number for company exception which is not in DQA_BL
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_COMPANY_DETAILS] 
	-- Add the parameters for the stored procedure here
	@TNBR int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

---- 09/20/2010
---- Log Start Time
--DECLARE @IdLogOut INT
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@TNBR='''+ CAST(@TNBR AS VARCHAR(100)) +''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'LOAD_COMPANY_DETAILS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@TNBR='''+ CAST(@TNBR AS VARCHAR(100)) +''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @COMP_ID AS NUMERIC(12,0)
DECLARE @CLUSTER_ID AS NUMERIC(12,0)

DECLARE @COMP_NBR VARCHAR(14)
DECLARE @STR_PTY_ID INT
DECLARE @STATUS VARCHAR(50)
DECLARE @BOL_ID INT
DECLARE @SOURCE CHAR(1)
DECLARE @COMPRESSED_NAME VARCHAR(50)
DECLARE @BL_NBR AS VARCHAR(200)
DECLARE @TRNS_TBL AS TABLE(BOL_ID INT, 
	COMP_NBR VARCHAR(14), 
	STR_PTY_ID INT, 
	SOURCE VARCHAR(1), 
	CompKey VARCHAR(50),[Name] VARCHAR(150), ADDR1 VARCHAR(125) , ADDR2 VARCHAR(125), City VARCHAR(125), 
	ST VARCHAR(100),Country VARCHAR(100), Zip VARCHAR(15), BL_NBR VARCHAR(200), 
	STATUS VARCHAR(50) ) 

DECLARE @ALL_STR_PTY_LST AS TABLE(PTY_ID INT IDENTITY(1,1), STR_PTY_ID INT)
DECLARE @CURR_POS INT
DECLARE @IS_REF_LIB_DICT BIT 
DECLARE @IS_LIB_DICT BIT 
DECLARE @IS_REF_DICT BIT 

SET @CURR_POS= 1
SELECT @IS_REF_LIB_DICT =0, @IS_LIB_DICT =0 , @IS_REF_DICT =0

INSERT INTO @ALL_STR_PTY_LST
SELECT STR_PTY_ID FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)
WHERE BOL_ID = @TNBR

SELECT @BL_NBR = B.BL_NBR FROM SCREEN_TEST.DBO.BL_BL B WITH (NOLOCK) 
WHERE B.T_NBR = @TNBR

--LOOP THROUGH THE PTY
WHILE EXISTS
( 
	SELECT 1 FROM @ALL_STR_PTY_LST 
	WHERE PTY_ID = @CURR_POS  
)
BEGIN
	SELECT 
		@COMP_ID	= COMP_ID		,
		@COMP_NBR	= Company_Nbr	,
		@STR_PTY_ID	= STR_PTY_ID	,
		@BOL_ID		= BOL_ID		,
		@COMPRESSED_NAME = ISNULL(COMPRESSED_NAME, ''),
		@STATUS	= STATUS			,
		@SOURCE	= ISNULL(Source,'')
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK) 
	WHERE 
	( 
		( BOL_ID = @TNBR ) AND 
		( STR_PTY_ID = (SELECT STR_PTY_ID FROM @ALL_STR_PTY_LST WHERE PTY_ID = @CURR_POS) ) 
	)

	IF ( @COMP_ID IS NOT NULL )
	BEGIN
		SELECT @CLUSTER_ID = CLUSTER_ID FROM PES.dbo.v_pes_lib_company WITH (NOLOCK) 
		WHERE ( COMP_ID = @COMP_ID ) 

		--CR ## Company dictionary changes Pk Cognizant dtd 06/10/2010. Cluster ID query added for getting dictionary record.
		--New Company
		IF ( @CLUSTER_ID = @COMP_ID )
		BEGIN
				INSERT INTO @TRNS_TBL
				SELECT	DISTINCT 
					@BOL_ID	AS BOL_ID,
					@COMP_NBR AS Comp_Nbr,
					@STR_PTY_ID	AS STR_PTY_ID,
					@SOURCE	AS Source,
					@COMPRESSED_NAME AS CompKey,
					ISNULL(vpc1.[Name],'') AS [Name],
					ISNULL(vpc1.Address1,'') AS addr1, 
					'' AS addr2,
					ISNULL(vpc1.City,'') AS City, 
					ISNULL(vpc1.State,'') AS St, 
					ISNULL(vpc1.Country,'') AS Country,
					ISNULL(vpc1.Zip,'') AS Zip,
					@BL_NBR	AS BL_NBR,
					@STATUS AS Status
				FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY vpc1 WITH (NOLOCK) 
				WHERE (COMP_ID = @COMP_ID )
		END
		ELSE
		BEGIN
			--Set the Bit variable to 1 If the Dictionary from the lib company 
			IF EXISTS ( SELECT 1 FROM PES.dbo.v_pes_lib_company WITH (NOLOCK) WHERE COMP_ID = @CLUSTER_ID )
			BEGIN
				SET @IS_LIB_DICT =1
			END						
			--Set the Bit variable to 1 If the Dictionary from the REF company or from Both.
			IF EXISTS ( SELECT 1 FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY WITH (NOLOCK) WHERE COMP_ID = @CLUSTER_ID )
			BEGIN
				IF (@IS_LIB_DICT = 1 )
					SET @IS_REF_LIB_DICT = 1
				ELSE
					SET @IS_REF_DICT =1
			END
			
			--Load from LIB company If the Dictionary exists in LIB COMPANY or in both. 
			IF ( @IS_LIB_DICT = 1 AND @IS_REF_LIB_DICT =0 )
			BEGIN
				INSERT INTO @TRNS_TBL
				SELECT	DISTINCT 
					@BOL_ID	AS BOL_ID,
					@COMP_NBR AS Comp_Nbr,
					@STR_PTY_ID	AS STR_PTY_ID,
					@SOURCE	AS Source,
					@COMPRESSED_NAME AS CompKey,
					ISNULL(vpc2.[Name],'') AS [Name],
					ISNULL(vpc2.Address1,'') AS addr1,
					'' AS addr2,
					ISNULL(vpc2.City,'') AS City,
					ISNULL(vpc2.State,'') AS St,
					ISNULL(vpc2.Country,'') AS Country,
					ISNULL(vpc2.Zip,'') AS Zip,
					@BL_NBR	AS BL_NBR,		
					@STATUS AS Status
				FROM PES.dbo.v_pes_lib_company vpc2 WITH (NOLOCK) 
				WHERE ( vpc2.COMP_ID = @CLUSTER_ID )
			END
			
			--Load from the REF company If the Dictionary exists in REF COMPANY only. 
			IF (@IS_REF_DICT =1 OR @IS_REF_LIB_DICT = 1)
			BEGIN
				INSERT INTO @TRNS_TBL
				SELECT	DISTINCT 
					@BOL_ID	AS BOL_ID,
					@COMP_NBR AS Comp_Nbr,
					@STR_PTY_ID	AS STR_PTY_ID,
					@SOURCE	AS Source,
					@COMPRESSED_NAME AS CompKey,
					ISNULL(vpc1.Name,'') AS [Name],
					ISNULL(vpc1.Address1,'') AS addr1,
					'' AS addr2,
					ISNULL(vpc1.City,'') AS City, 
					ISNULL(vpc1.State,'') AS St, 
					ISNULL(vpc1.Country,'') AS Country,
					ISNULL(vpc1.Zip,'') AS Zip,				
					@BL_NBR AS BL_NBR,
					@STATUS AS Status
				FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY vpc1 WITH (NOLOCK) 
				WHERE ( vpc1.COMP_ID = @CLUSTER_ID )
			END		
		END
	END
	ELSE
	BEGIN
		INSERT INTO @TRNS_TBL
		SELECT	tlp.BOL_ID, 
				tlp.Company_Nbr AS Comp_Nbr, 
				tlp.STR_PTY_ID, 
				ISNULL(tlp.Source,'') AS Source, 
				ISNULL(tlp.Compressed_Name,'') AS CompKey, 
				ISNULL(tlp.[Name],'') AS [Name], 
				ISNULL(tlp.Addr_1,'') AS addr1, 
				ISNULL(tlp.Addr_2,'') AS addr2, 
				ISNULL(tlp.City,'') AS City, 
				ISNULL(tlp.State,'') AS St, 
				(CASE WHEN tlp.cntry_cd IS NULL OR tlp.cntry_cd <=0 THEN '' ELSE CAST(tlp.cntry_cd AS VARCHAR(20)) END) as Country, 
				ISNULL(tlp.Postal_cd,'') AS Zip,
				(	
					SELECT B.BL_NBR FROM SCREEN_TEST.DBO.BL_BL B WITH (NOLOCK) WHERE B.T_NBR =tlp.BOL_ID
				) AS BL_NBR,
				tlp.STATUS AS Status
		FROM    PES.dbo.PES_TRANSACTIONS_LIB_PTY tlp WITH (NOLOCK)
		WHERE   (tlp.BOL_ID = @TNBR) AND (tlp.STR_PTY_ID =  @STR_PTY_ID)

	END

	SET @CURR_POS=@CURR_POS+1
	SELECT @IS_REF_LIB_DICT =0, @IS_LIB_DICT =0 , @IS_REF_DICT =0
END 

SELECT * FROM @TRNS_TBL

-- 09/20/2010
-- Log End Time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd 
 @Id = @IdLogOut, @RowsAffected = @@ROWCOUNT

END
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
