/****** Object:  StoredProcedure [dbo].[LOAD_COMPANY_DICTIONARY_COUNT]    Script Date: 01/03/2013 19:48:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		PRAMOD KUMAT
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_COMPANY_DICTIONARY_COUNT]
	-- Add the parameters for the stored procedure here
	@PTY_NAME VARCHAR(100),
	@DICT_TYPE VARCHAR(3) ,
	@CNTRY_NAME VARCHAR(100) = NULL,
	@CITY_NAME VARCHAR(100) = NULL,
	@PAGE_NBR INT
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;

DECLARE @START_PAGE INT
DECLARE @PAGE_SIZE INT
DECLARE @WILD_CARD_INDX INT

SET @WILD_CARD_INDX = PATINDEX('%*%', @PTY_NAME )

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

SET @START_PAGE = ((200*@PAGE_NBR)-200)+@PAGE_NBR
SET @PAGE_SIZE  = 200*@PAGE_NBR

	IF ( @CNTRY_NAME IS NOT NULL )
	BEGIN 	
		IF ( @CITY_NAME IS NOT NULL )
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN		
				SELECT  Count(A.ROW)	
				FROM 
				(
					SELECT	ROW_NUMBER() OVER (ORDER BY libCmpny.[Name] ASC) AS Row, 
							libCmpny.State , 
							refCntry.Piers_Country
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY AS libCmpny WITH (NOLOCK) 
					LEFT OUTER JOIN PES.dbo.ref_country refCntry WITH (NOLOCK)
					ON libCmpny.Country = CAST(refCntry.joc_code as varchar(10))
					WHERE 
					(
						( libCmpny.[Name] LIKE @PTY_NAME  ) AND ( LEN(LTRIM(libCmpny.Address1))!= 0 ) 
						AND ( REPLACE(refCntry.Piers_Country, ' ', '') =  @CNTRY_NAME )
						AND ( libCmpny.City =  @CITY_NAME ) 
						AND ( LEN(LTRIM(libCmpny.State)) != 0 OR LEN(LTRIM(refCntry.Piers_Country)) !=0  )
					)
				) AS A
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )							
			END
			ELSE
			BEGIN
				SELECT	COUNT(A.ROW) 
				FROM 
				( 
					SELECT	
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						--lib.comp_nbr , 
						lib.[Name], 
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country AS B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10)) 
					WHERE ( lib.[Name] Like @PTY_NAME  ) AND ( LEN(LTRIM(lib.address1))!= 0 ) 
					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 ) 
					AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME  )
					AND ( lib.City = @CITY_NAME ) 
				) AS A 
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )	
			END
		END
		ELSE
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN		
				SELECT  Count(A.ROW)	
				FROM 
				(
					SELECT	ROW_NUMBER() OVER (ORDER BY libCmpny.[Name] ASC) AS Row, 
							libCmpny.State , 
							refCntry.Piers_Country
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY AS libCmpny WITH (NOLOCK) 
					LEFT OUTER JOIN PES.dbo.ref_country refCntry WITH (NOLOCK)
					ON libCmpny.Country = CAST(refCntry.joc_code as varchar(10))
					WHERE 
					(
						( libCmpny.[Name] LIKE @PTY_NAME ) AND ( LEN(LTRIM(libCmpny.Address1))!= 0 ) 
						AND ( REPLACE(refCntry.Piers_Country, ' ', '') =  @CNTRY_NAME )
						--AND ( libCmpny.City =  @CITY_NAME ) 
						AND ( LEN(LTRIM(libCmpny.State)) != 0 OR LEN(LTRIM(refCntry.Piers_Country)) !=0  )
					)
				) AS A
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )		
			END
			ELSE
			BEGIN
				SELECT	COUNT(A.ROW) 
				FROM 
				( 
					SELECT	
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						--lib.comp_nbr , 
						lib.[Name], 
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country AS B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10)) 
					WHERE ( lib.[Name] Like @PTY_NAME  ) AND ( LEN(LTRIM(lib.address1))!= 0 ) 
					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 ) 
					AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME  )
					--AND ( lib.City = @CITY_NAME ) 
				) AS A 
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
				SELECT  Count(A.ROW)	
				FROM 
				(
					SELECT	ROW_NUMBER() OVER (ORDER BY libCmpny.[Name] ASC) AS Row, 
							libCmpny.State , 
							refCntry.Piers_Country
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY AS libCmpny WITH (NOLOCK) 
					LEFT OUTER JOIN PES.dbo.ref_country refCntry WITH (NOLOCK)
					ON libCmpny.Country = CAST(refCntry.joc_code as varchar(10))
					WHERE 
					(
						( libCmpny.[Name] LIKE @PTY_NAME ) AND ( LEN(LTRIM(libCmpny.Address1))!= 0 ) 
--						AND ( REPLACE(refCntry.Piers_Country, ' ', '') =  @CNTRY_NAME )
--						AND ( libCmpny.City =  @CITY_NAME ) 
						AND ( LEN(LTRIM(libCmpny.State)) != 0 OR LEN(LTRIM(refCntry.Piers_Country)) !=0  )
					)
				) AS A
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )		
			END
			ELSE
			BEGIN
				SELECT	COUNT(A.ROW) 
				FROM 
				( 
					SELECT	
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						--lib.comp_nbr , 
						lib.[Name], 
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country AS B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10)) 
					WHERE ( lib.[Name] Like @PTY_NAME ) AND ( LEN(LTRIM(lib.address1))!= 0 ) 
					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 ) 
					--AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME  )
					--AND ( lib.City = @CITY_NAME ) 
				) AS A 
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )	
			END
		END
		ELSE
		BEGIN
			IF ( @DICT_TYPE = 'REF' )
			BEGIN
				SELECT  Count(A.ROW)	
				FROM 
				(
					SELECT	ROW_NUMBER() OVER (ORDER BY libCmpny.[Name] ASC) AS Row, 
							libCmpny.State , 
							refCntry.Piers_Country
					FROM PES.dbo.V_PES_REF_NEWLIB_COMPANY AS libCmpny WITH (NOLOCK) 
					LEFT OUTER JOIN PES.dbo.ref_country refCntry WITH (NOLOCK)
					ON libCmpny.Country = CAST(refCntry.joc_code as varchar(10))
					WHERE 
					(
						( libCmpny.[Name] LIKE @PTY_NAME  ) AND ( LEN(LTRIM(libCmpny.Address1))!= 0 ) 
						--AND ( REPLACE(refCntry.Piers_Country, ' ', '') =  @CNTRY_NAME )
						AND ( libCmpny.City =  @CITY_NAME ) 
						AND ( LEN(LTRIM(libCmpny.State)) != 0 OR LEN(LTRIM(refCntry.Piers_Country)) !=0  )
					)
				) AS A
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )		
			END
			ELSE
			BEGIN
				SELECT	COUNT(A.ROW) 
				FROM 
				( 
					SELECT	
						ROW_NUMBER() OVER (ORDER BY lib.[Name] ASC) as Row, 
						lib.comp_id , 
						--lib.comp_nbr , 
						lib.[Name], 
						lib.address1 , 
						lib.City, 
						lib.State , 
						lib.Zip , 
						b.Piers_Country As Country
					FROM PES.dbo.v_pes_lib_company AS lib WITH (NOLOCK) JOIN PES.dbo.Ref_Country AS B WITH (NOLOCK) 
					ON lib.country = CAST(b.joc_code as varchar(10)) 
					WHERE ( lib.[Name] Like @PTY_NAME ) AND ( LEN(LTRIM(lib.address1))!= 0 ) 
					AND ( LEN(LTRIM(lib.State)) != 0 OR LEN(LTRIM(B.Piers_Country)) != 0 ) 
					--AND ( REPLACE(b.Piers_Country, ' ', '') = @CNTRY_NAME  )
					AND ( lib.City = @CITY_NAME ) 
				) AS A 
				WHERE ( A.ROW BETWEEN @START_PAGE AND @PAGE_SIZE )	
			END
		END	
	END
END
GO
