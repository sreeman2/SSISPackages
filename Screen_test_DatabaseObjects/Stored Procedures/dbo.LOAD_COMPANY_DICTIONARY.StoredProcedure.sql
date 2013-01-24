/****** Object:  StoredProcedure [dbo].[LOAD_COMPANY_DICTIONARY]    Script Date: 01/03/2013 19:47:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_COMPANY_DICTIONARY]
	-- Add the parameters for the stored procedure here
	@PTY_NAME VARCHAR(100),
	@DICT_TYPE VARCHAR(3) ,
	@CNTRY_NAME VARCHAR(100) = NULL,
	@CITY_NAME VARCHAR(100) = NULL,
	@PAGE_NBR INT	,
	@PTY_ADDRESS VARCHAR(100) = NULL
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;

DECLARE @START_PAGE INT
DECLARE @PAGE_SIZE INT

SET @START_PAGE = ((200*@PAGE_NBR)-200)+@PAGE_NBR
SET @PAGE_SIZE  = 200*@PAGE_NBR
-- Declaring variables for wildcard (Party name )
DECLARE @WILD_CARD_INDX INT

--Setting values
SET @WILD_CARD_INDX = PATINDEX('%*%', @PTY_NAME )

--- Loop for PTY_NAME
IF ( @WILD_CARD_INDX > 0 )
BEGIN
	IF ( @WILD_CARD_INDX  =  1 ) 
	BEGIN
		SET @PTY_NAME = '%' + SUBSTRING(@PTY_NAME, 2, LEN(@PTY_NAME)-1 )
		SET @WILD_CARD_INDX = PATINDEX('%*%', @PTY_NAME )
	END
	
	IF ( @WILD_CARD_INDX  = LEN(@PTY_NAME) )
	BEGIN
		SET @PTY_NAME = SUBSTRING(@PTY_NAME, 1, LEN(@PTY_NAME)-1 ) + '%' 
	END	
	ELSE
	BEGIN
		--Default value
		SET @PTY_NAME = @PTY_NAME + '%'
	END
END
ELSE
BEGIN
	--Default value
	SET @PTY_NAME = @PTY_NAME + '%'
END




---Cheking  Null for PTY_ADDRESS variable and looping Only if its not NULL
IF (@PTY_ADDRESS != '' OR @PTY_ADDRESS IS NOT NULL)
BEGIN
	-- Declaring variables for wildcard (Party address)
	DECLARE @WILD_CARD_INDX_ADD INT
	---Setting Initial value for wild card index
	SET @WILD_CARD_INDX_ADD = PATINDEX('%*%', @PTY_ADDRESS )
	print (1)
	--- Loop For PTY_ADDRESS
	IF ( @WILD_CARD_INDX_ADD > 0 )
	BEGIN
		IF ( @WILD_CARD_INDX_ADD  =  1 ) 
		BEGIN
			SET @PTY_ADDRESS = '%' + SUBSTRING(@PTY_ADDRESS, 2, LEN(@PTY_ADDRESS)-1 )
			SET @WILD_CARD_INDX_ADD = PATINDEX('%*%', @PTY_ADDRESS )
			
		END
		
		IF ( @WILD_CARD_INDX_ADD  = LEN(@PTY_ADDRESS) )
		BEGIN
			SET @PTY_ADDRESS = SUBSTRING(@PTY_ADDRESS, 1, LEN(@PTY_ADDRESS)-1 ) + '%' 

		END	
		ELSE
		BEGIN
			--Default value
			SET @PTY_ADDRESS = @PTY_ADDRESS + '%'
		END
	END
	ELSE
	BEGIN
		--Default value
		SET @PTY_ADDRESS = @PTY_ADDRESS + '%'
	END
END


	IF ( @CNTRY_NAME IS NOT NULL )
	BEGIN 	
		IF ( @CITY_NAME IS NOT NULL )
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN		
				SELECT DISTINCT 
					ISNULL(CompanyWithRow.[Name],'') as Name	,
					ISNULL(CompanyWithRow.State,'') as st	,
					ISNULL(CompanyWithRow.City,'') as City	,
					ISNULL(CompanyWithRow.Zip,'') as Zip	,
					ISNULL(CompanyWithRow.Address1,'') as Addr1,
					ISNULL(CompanyWithRow.Piers_Country,'') as Country, 
					CompanyWithRow.Comp_ID as compid, 
					-1 AS ClusterID  
				FROM 
				( 
					SELECT  
						ROW_NUMBER() OVER (ORDER BY A.[Name] ASC) as Row,  
						a.[Name],
						a.State,
						a.City,
						a.Zip,
						a.Address1,
						a.Comp_ID,
						b.Piers_Country 
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY A WITH (NOLOCK) LEFT OUTER JOIN PES.dbo.ref_country b WITH (NOLOCK)  
					ON A.Country = CAST(b.JOC_CODE AS VARCHAR(10) ) 
					WHERE 
					(
						( A.[NAME] LIKE @PTY_NAME + '%' ) 
                        AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME )
						AND ( A.Address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE A.Address1 END ) )
						AND ( A.CITY = @CITY_NAME ) AND ( LEN(LTRIM(A.Address1))!= 0 ) 
                        AND ( LEN(LTRIM(B.Piers_Country)) !=0 )
--                      AND ( LEN(LTRIM(A.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) !=0 ) 
					)
				) AS CompanyWithRow  
				WHERE ( CompanyWithRow.Row BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
			ELSE
			BEGIN
				SELECT DISTINCT 
					ISNULL(A.comp_id, '') as compid ,  
					A.[Name],  
					A.address1 as Addr1, 
					A.City, 
					A.State as st, 
					A.Zip ,
					A.country as COUNTRY,
					A.ClusterID 
				FROM 
				( 
					SELECT 
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						lib.[Name],  
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country, 
						Cluster_ID AS ClusterID 
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10))  
					WHERE ( lib.[NAME] LIKE @PTY_NAME + '%') 
                    AND ( lib.CITY = @CITY_NAME ) 
					AND ( lib.address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE lib.address1 END ) )
					AND ( LEN(LTRIM(lib.address1))!= 0 )  
                    AND ( LEN(LTRIM(B.Piers_Country)) != 0 )
--					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 )  
					AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME )
				) A  
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
		END
		ELSE
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN		
				SELECT DISTINCT 
					ISNULL(CompanyWithRow.[Name],'') as Name	,
					ISNULL(CompanyWithRow.State,'') as st	,
					ISNULL(CompanyWithRow.City,'') as City	,
					ISNULL(CompanyWithRow.Zip,'') as Zip	,
					ISNULL(CompanyWithRow.Address1,'') as Addr1,
					ISNULL(CompanyWithRow.Piers_Country,'') as Country, 
					CompanyWithRow.Comp_ID as compid, 
					-1 AS ClusterID  
				FROM 
				( 
					SELECT  
						ROW_NUMBER() OVER (ORDER BY A.[Name] ASC) as Row,  
						a.[Name],
						a.State,
						a.City,
						a.Zip,
						a.Address1,
						a.Comp_ID,
						b.Piers_Country 
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY A WITH (NOLOCK) LEFT OUTER JOIN PES.dbo.ref_country b WITH (NOLOCK)  
					ON A.Country = CAST(b.JOC_CODE AS VARCHAR(10) ) 
					WHERE 
					(
						( A.[NAME] LIKE @PTY_NAME + '%' ) 
                        AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME )
						AND ( A.Address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE A.Address1 END ) )
						/*AND ( A.CITY = @CITY_NAME ) */ 
                        AND ( LEN(LTRIM(A.Address1))!= 0 ) 
                        AND ( LEN(LTRIM(B.Piers_Country)) !=0 ) 
--                      AND ( LEN(LTRIM(A.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) !=0 ) 
					)
				) AS CompanyWithRow  
				WHERE ( CompanyWithRow.Row BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
			ELSE
			BEGIN
				SELECT DISTINCT 
					ISNULL(A.comp_id, '') as compid ,  
					A.[Name],  
					A.address1 as Addr1, 
					A.City, 
					A.State as st, 
					A.Zip ,
					A.country as COUNTRY,
					A.ClusterID 
				FROM 
				( 
					SELECT 
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						lib.[Name],  
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country, 
						Cluster_ID AS ClusterID 
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10))  
					WHERE ( lib.[NAME] LIKE @PTY_NAME + '%') --AND ( lib.CITY = @CITY_NAME ) 
					AND ( lib.address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE lib.address1 END ) )
					AND ( LEN(LTRIM(lib.address1))!= 0 )  
                    AND ( LEN(LTRIM(B.Piers_Country)) != 0 ) 
--					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 )  
					AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME )
				) A  
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
		END
	END
	ELSE
	BEGIN
		IF ( @CITY_NAME IS NULL )
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN
				SELECT DISTINCT 
					ISNULL(CompanyWithRow.Name,'') as Name	,
					ISNULL(CompanyWithRow.State,'') as st	,
					ISNULL(CompanyWithRow.City,'') as City	,
					ISNULL(CompanyWithRow.Zip,'') as Zip	,
					ISNULL(CompanyWithRow.Address1,'') as Addr1,
					ISNULL(CompanyWithRow.Piers_Country,'') as Country, 
					CompanyWithRow.Comp_ID as compid, 
					-1 AS ClusterID  
				FROM 
				( 
					SELECT  
						ROW_NUMBER() OVER (ORDER BY A.[Name] ASC) as Row,  
						a.[Name],
						a.State,
						a.City,
						a.Zip,
						a.Address1,
						a.Comp_ID,
						b.Piers_Country 
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY A WITH (NOLOCK) LEFT OUTER JOIN PES.dbo.ref_country b WITH (NOLOCK)  
					ON A.Country = cast(b.JOC_CODE AS VARCHAR(10) ) 
					WHERE 
					(
						( A.[NAME] LIKE @PTY_NAME + '%' ) 
                        AND ( LEN(LTRIM(A.Address1))!= 0 ) 
						AND ( A.Address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE A.Address1 END ) )
                        AND ( LEN(LTRIM(B.Piers_Country)) !=0 )
--						AND ( LEN(LTRIM(A.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) !=0 ) 
					)
				) AS CompanyWithRow  
				WHERE ( CompanyWithRow.Row BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
			ELSE
			BEGIN
				SELECT DISTINCT 
					ISNULL(A.comp_id, '') as compid ,  
					A.[Name],  
					A.address1 as Addr1, 
					A.City, 
					A.State as st, 
					A.Zip ,
					A.country as COUNTRY,
					A.ClusterID 
				FROM 
				( 
					SELECT 
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						lib.[Name],  
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country, 
						Cluster_ID AS ClusterID 
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10))  
					WHERE ( lib.[NAME] LIKE @PTY_NAME + '%') 
						  AND ( LEN(LTRIM(lib.address1))!= 0 ) 
						  AND ( lib.address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE lib.address1 END ) )
						  AND ( LEN(LTRIM(B.Piers_Country)) != 0 )
		--				  AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 )  			
				) A  
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
		END
		ELSE
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN
				SELECT DISTINCT 
					ISNULL(CompanyWithRow.Name,'') as Name	,
					ISNULL(CompanyWithRow.State,'') as st	,
					ISNULL(CompanyWithRow.City,'') as City	,
					ISNULL(CompanyWithRow.Zip,'') as Zip	,
					ISNULL(CompanyWithRow.Address1,'') as Addr1,
					ISNULL(CompanyWithRow.Piers_Country,'') as Country, 
					CompanyWithRow.Comp_ID as compid, 
					-1 AS ClusterID  
				FROM 
				( 
					SELECT  
						ROW_NUMBER() OVER (ORDER BY A.[Name] ASC) as Row,  
						a.[Name],
						a.State,
						a.City,
						a.Zip,
						a.Address1,
						a.Comp_ID,
						b.Piers_Country 
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY A WITH (NOLOCK) LEFT OUTER JOIN PES.dbo.ref_country b WITH (NOLOCK)  
					ON A.Country = cast(b.JOC_CODE AS VARCHAR(10) ) 
					WHERE 
					(
						( A.[NAME] LIKE @PTY_NAME + '%' ) AND ( a.CITY = @CITY_NAME )
						AND ( A.Address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE A.Address1 END ) )
						AND ( LEN(LTRIM(A.Address1))!= 0 ) 
                        AND ( LEN(LTRIM(B.Piers_Country)) !=0 )
--						AND ( LEN(LTRIM(A.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) !=0 ) 
					)
				) AS CompanyWithRow  
				WHERE ( CompanyWithRow.Row BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
			ELSE
			BEGIN
				SELECT DISTINCT 
					ISNULL(A.comp_id, '') as compid ,  
					A.[Name],  
					A.address1 as Addr1, 
					A.City, 
					A.State as st, 
					A.Zip ,
					A.country as COUNTRY,
					A.ClusterID 
				FROM 
				( 
					SELECT 
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						lib.[Name],  
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country, 
						Cluster_ID AS ClusterID 
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10))  
					WHERE ( lib.[NAME] LIKE @PTY_NAME + '%') AND ( lib.CITY = @CITY_NAME )
					AND ( lib.address1 LIKE ( CASE WHEN @PTY_ADDRESS IS NOT NULL THEN @PTY_ADDRESS ELSE lib.address1 END ) )
					AND ( LEN(LTRIM(lib.address1))!= 0 )  
                    AND ( LEN(LTRIM(B.Piers_Country)) != 0 ) 
--					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 )  			
				) A  
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )
			END
		END	
	END
END
GO
