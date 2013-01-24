USE [SCREEN_TEST]
GO
/****** Object:  StoredProcedure [dbo].[ADD_COMPANY_DICTIONARY]    Script Date: 01/03/2013 19:47:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ADD_COMPANY_DICTIONARY] 
	-- Add the parameters for the stored procedure here
	@p_STR_PTY_ID	AS INT			,
	@p_BOL_ID	AS INT				,	
	@p_Name		AS VARCHAR(150)		,
	@p_Addr_1	AS VARCHAR(125)		,
	@p_Addr_2	AS VARCHAR(125)		,
	@p_City		AS VARCHAR(125)		,
	@p_State	AS CHAR(9)			,
	@p_Cntry_cd AS VARCHAR(3)		,
	@p_Postal_cd AS VARCHAR(15)		,	
	@p_ClusterID AS INT	= NULL		,
	@p_IsNewDictionary AS BIT =0	,
	@p_IsMatchedCndate AS BIT =0	,
	@p_Updated_User	AS VARCHAR(50)	,
	@p_CompID		AS NUMERIC(12,0) OUTPUT,
	@p_NewCompany		AS BIT OUTPUT 
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@p_STR_PTY_ID='++LTRIM(RTRIM(STR(@p_STR_PTY_ID)))
+', @p_BOL_ID='++LTRIM(RTRIM(STR(@p_BOL_ID)))
+', @p_Name='''+@p_Name+''''
+', @p_Addr_1='''+@p_Addr_1+''''
+', @p_Addr_2='''+@p_Addr_2+''''
+', @p_City='''+@p_City+''''
+', @p_State='''+@p_State+''''
+', @p_Cntry_cd='''+@p_Cntry_cd+''''
+', @p_Postal_cd='''+@p_Postal_cd+''''
+', @p_ClusterID='++LTRIM(RTRIM(STR(@p_ClusterID)))
+', @p_IsNewDictionary='++LTRIM(RTRIM(STR(@p_IsNewDictionary)))
+', @p_IsMatchedCndate='++LTRIM(RTRIM(STR(@p_IsMatchedCndate)))
+', @p_Updated_User='''+@p_Updated_User+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @GETDATE AS DATETIME
DECLARE @IS_USCOMP AS VARCHAR(1)
DECLARE @COMP_ID AS NUMERIC(12,0)
DECLARE @MTCH_COMP_ID AS NUMERIC(12,0)
--DECLARE @COMP_DICT_TABLE AS TABLE(COMP_ID NUMERIC(12,0))

SET @GETDATE = GETDATE()
SET @IS_USCOMP = 'N'

/*
DE394 - duplicate Quote appended while inserting data into NAME, ADDRESS, CITY & STATE columns. Conditions for 
removing the duplicate quote. Pk Cognizant [10/08/2010]
*/
IF ( @p_Name IS NOT NULL )
	SET @p_Name	= REPLACE(@p_Name, '''''', '''')
IF ( @p_Addr_1 IS NOT NULL )
	SET @p_Addr_1	= REPLACE(@p_Addr_1, '''''', '''')
IF ( @p_Addr_2 IS NOT NULL )
	SET @p_Addr_2	= REPLACE(@p_Addr_2, '''''', '''')
IF ( @p_City IS NOT NULL )
	SET @p_City	= REPLACE(@p_City, '''''', '''')
IF ( @p_State IS NOT NULL )
	SET @p_State	= REPLACE(@p_State, '''''', '''')

-- Check if dictionary already exists 
BEGIN TRY
	
--	IF ( @p_IsNewDictionary = 1 )
--	BEGIN
--		IF EXISTS 
--		( 
--			SELECT 1 FROM PES.dbo.V_PES_COMPANY vpc WITH(NOLOCK) LEFT OUTER JOIN PES.dbo.REF_COUNTRY B WITH(NOLOCK) 
--			ON ( vpc.COUNTRY = CAST(b.JOC_CODE as VARCHAR(10)) )
--			WHERE  ( vpc.COUNTRY = @p_Cntry_cd ) 	--( vpc.ZIP = @p_Postal_cd )
--			AND ( vpc.[NAME] = @p_Name ) 
--			AND ( vpc.CITY = @p_City )
--			AND (vpc.[STATE] = @p_State)
--			AND (vpc.[ADDRESS1] = @p_Addr_1 )
--			AND ( LEN(LTRIM(vpc.address1))!= 0 ) 
--			AND ( LEN(LTRIM(vpc.State)) != 0 OR LEN(LTRIM(b.Piers_Country)) != 0 ) 
----			SELECT 1 FROM PES.dbo.V_PES_COMPANY AS pc JOIN @COMP_DICT_TABLE AS cdt ON cdt.COMP_ID = pc.COMP_ID 
----			WHERE ( pc.[STATE] = @p_State )  --( pc.[NAME] = @p_Name )
----			AND ( pc.CITY = @p_City )
----			AND ( pc.[ADDRESS1] = @p_Addr_1 )
--		)
--		BEGIN	
--			SET @p_CompID = -1
--			RAISERROR(
--				50001, 
--				16, 
--				1
--			)
--		END
--	END

	IF ( @p_Cntry_cd = '100') 
	BEGIN
		SET @IS_USCOMP = 'Y'
	END

	IF ( @p_IsMatchedCndate = 1 )
	BEGIN
		SELECT @COMP_ID = COMP_ID FROM PES.DBO.V_PES_COMPANY WITH(NOLOCK)
		WHERE COMP_ID = @p_ClusterID  
		
		IF ( LEN(@COMP_ID) > 0 )
		BEGIN
			SET @p_ClusterID = @COMP_ID
		END
		ELSE
			SET @p_ClusterID = NULL
	END

--Begin Transaction
BEGIN TRAN 

	IF ( @p_IsNewDictionary != 1  )
	BEGIN
		SET @p_NewCompany = 0

		IF EXISTS( 
			SELECT 1 
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)	
			WHERE 
			( 
				( BOL_ID = @p_BOL_ID ) 
				AND ( STR_PTY_ID = @p_STR_PTY_ID ) 
				AND ( ISNULL([NAME], '') != '' )
			)			
		)
		BEGIN						
			--Insert into PES_LIB_COMPANY table. 
			INSERT INTO [PES].[dbo].[PES_LIB_Company]
			(
			   [Name]		,
			   [Is_USComp]  ,
			   [Address1]	,
			   [City]		,
			   [State]		,
			   [Zip]		,
			   [Country]	,
			   [Verified]	,
			   [Cluster_ID]	,
			   [Created_By]	,
			   [Created_Dt]	,
			   [Modified_By],	
			   [Modified_Dt]
			)
			SELECT 
				[NAME], 
				IS_USComp,
				ADDR_1, 
				CITY, 
				STATE, 
				POSTAL_CD, 
				CNTRY_CD, 
				0, 
				@p_ClusterID, 
				@p_Updated_User,
				@GETDATE		, 
				@p_Updated_User	, 
				@GETDATE  
			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)
			WHERE 
			( 
				( BOL_ID = @p_BOL_ID ) 
				AND ( STR_PTY_ID = @p_STR_PTY_ID ) 
			)

			SET  @p_CompID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SET @p_CompID = @p_ClusterID 
		END
	END
	ELSE
	BEGIN
		SET @p_NewCompany =1	
		
		--Verify if company exception already exists in company dictionary 
		--'( verify in both PES_LIB_COMPANY as well as PES_REF_COMPANY).   
		SELECT @MTCH_COMP_ID = vpc.COMP_ID FROM PES.dbo.V_PES_COMPANY vpc WITH(NOLOCK) LEFT OUTER JOIN PES.dbo.REF_COUNTRY B WITH(NOLOCK) 
		ON ( vpc.COUNTRY = CAST(b.JOC_CODE as VARCHAR(10)) )
		WHERE  ( vpc.COUNTRY = @p_Cntry_cd ) 	
		AND ( vpc.[NAME] = @p_Name ) 
		AND ( vpc.CITY = @p_City )
		AND (vpc.[STATE] = @p_State)
		AND (vpc.[ADDRESS1] = @p_Addr_1 )
		AND ( LEN(LTRIM(vpc.address1))!= 0 ) 
		AND ( LEN(LTRIM(vpc.State)) != 0 OR LEN(LTRIM(b.Piers_Country)) != 0 ) 
		
		-- No match found ( New company created)	
		IF ( @MTCH_COMP_ID IS NOT NULL )
		BEGIN
			SET @p_ClusterID = @MTCH_COMP_ID
			SET @p_NewCompany = 0
		END
		--Insert into PES_LIB_COMPANY table. This will be the default flow for both new & existing companies.
		INSERT INTO [PES].[dbo].[PES_LIB_Company]
		(
		   [Name]		,
		   [Is_USComp]  ,
		   [Address1]	,
		   [City]		,
		   [State]		,
		   [Zip]		,
		   [Country]	,
		   [Verified]	,
		   [Cluster_ID]	,
		   [Created_By]	,
		   [Created_Dt]	,
		   [Modified_By],	
		   [Modified_Dt]
		)
		SELECT 
			[NAME], 
			IS_USComp,
			ADDR_1, 
			CITY, 
			STATE, 
			POSTAL_CD, 
			CNTRY_CD, 
			0, 
			@p_ClusterID, 
			@p_Updated_User,
			@GETDATE		, 
			@p_Updated_User	, 
			@GETDATE  
		FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)
		WHERE ( ( BOL_ID = @p_BOL_ID ) AND ( STR_PTY_ID = @p_STR_PTY_ID ) )

		SET  @p_CompID = SCOPE_IDENTITY()

		-- No match found ( New company created)	
		IF ( @MTCH_COMP_ID IS NULL )
		BEGIN
			IF ( @p_ClusterID = NULL )
			BEGIN
				SET @p_ClusterID = @p_CompID
			END

			INSERT INTO [PES].[dbo].[PES_Ref_Company]
			(
			   [Comp_ID]		,
			   [Is_USComp]		,
			   [Name]			,
			   [Address1]		,
			   [City]			,
			   [State]			,
			   [Zip]			,
			   [Country]		,
			   [Verified]		,
			   [Created_By]		,
			   [Created_Dt]		,
			   [Modified_By]	,
			   [Modified_Dt]
			)
			VALUES
			(
				@p_CompID		,
				@IS_USCOMP		,
				@p_Name			, 
				@p_Addr_1		, 
				@p_City			, 
				@p_State		, 
				@p_Postal_cd	, 
				@p_Cntry_cd		, 
				0				,
				@p_Updated_User	,
				@GETDATE		, 
				@p_Updated_User	, 
				@GETDATE 	
			)

		UPDATE [PES].[dbo].[PES_LIB_Company]
		SET Cluster_ID = @p_CompID
		WHERE COMP_ID = @p_CompID
		END 
	END

COMMIT TRAN 


	-- Added 5/16/2011
	-- If this is not a new ref company, then it is a match - update that information once the transaction is committed and the detail record has been created
	IF ( @p_NewCompany = 0 )
	BEGIN
		UPDATE [PES].[dbo].[PES_Ref_Company_Detail]
		SET AgentMatchDate = @GETDATE,
			MatchAgentId = @p_Updated_User
		WHERE COMP_ID = @p_CompID
	END
	-- Otherwise this is an auto generated match - update the auto match date
	ELSE
	BEGIN
		UPDATE [PES].[dbo].[PES_Ref_Company_Detail]
		SET AutoMatchDate = @GETDATE
		WHERE COMP_ID = @p_CompID
	END



END TRY
BEGIN CATCH
--		IF ( @@ERROR = 50001 ) 
--		BEGIN
--			RAISERROR(
--				'There is an existing company with this exect information. Please use the search feature.', 
--				16, 
--				1
--			)
--			RETURN
--		END
		ROLLBACK TRAN 
END CATCH

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
