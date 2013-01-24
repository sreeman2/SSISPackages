/****** Object:  StoredProcedure [dbo].[LOAD_VESSEL_DICTIONARY]    Script Date: 01/03/2013 19:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_VESSEL_DICTIONARY]
	@FILTER_TEXT	VARCHAR(MAX),
	@CURRENT_PAGE	INT	= 1		,
	@IS_GLOBAL		BIT = 0		,
	@PAGE_SIZE		INT	
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


DECLARE @START_PAGE INT
DECLARE @NEXT_PAGE INT

SET @START_PAGE = ((200*@CURRENT_PAGE)-200)+@CURRENT_PAGE
SET @NEXT_PAGE  = @CURRENT_PAGE*@PAGE_SIZE

IF ( @IS_GLOBAL = 0 )
BEGIN
	SELECT 		
		ID			, 
		NAME		,	 
		CODE		, 
		VESSEL_COUNTRY	
	FROM 
	(
		SELECT  
			ROW_NUMBER() OVER (ORDER BY t.IMO_CODE ASC) as Row,
			t.ID, 
			t.STND_VESSEL NAME, 
			t.IMO_CODE AS CODE, 
			t.VESSEL_COUNTRY  
		FROM PES.dbo.REF_VESSEL AS t WITH (NOLOCK) 
		WHERE 
		( 
			t.ID <> 0 
			AND ( t.is_tmp = 'N' ) 
			AND ( t.deleted = 'N' )
			AND ( t.STND_VESSEL LIKE @FILTER_TEXT + '%' )
		)
	) AS A
	WHERE A.ROW BETWEEN @START_PAGE AND @NEXT_PAGE 
END
ELSE
BEGIN
		SELECT 		
		ID			, 
		NAME		,	 
		CODE		, 
		VESSEL_COUNTRY	
	FROM 
	(
		SELECT  
			ROW_NUMBER() OVER (ORDER BY t.IMO_CODE ASC) as Row,
			t.ID, 
			t.STND_VESSEL NAME, 
			t.IMO_CODE AS CODE, 
			t.VESSEL_COUNTRY  
		FROM PES.dbo.REF_VESSEL AS t WITH (NOLOCK) 
		WHERE 
		( 
			t.ID <> 0 
			AND ( t.is_tmp = 'N' ) 
			AND ( t.deleted = 'N' )
			AND ( t.STND_VESSEL LIKE @FILTER_TEXT + '%' OR t.VESSEL_COUNTRY  LIKE @FILTER_TEXT + '%' )
		)
	) AS A 
	WHERE A.ROW BETWEEN @START_PAGE AND @NEXT_PAGE 
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
