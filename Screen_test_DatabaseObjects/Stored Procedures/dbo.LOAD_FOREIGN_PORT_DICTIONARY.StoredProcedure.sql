/****** Object:  StoredProcedure [dbo].[LOAD_FOREIGN_PORT_DICTIONARY]    Script Date: 01/03/2013 19:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_FOREIGN_PORT_DICTIONARY]
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
		ID		, 
		PORTNAME, 
		NAME	, 
		CODE	, 
		COUNTRY	, 
		DEEPWATER_FLG 
	FROM 
	(
		SELECT	
			ROW_NUMBER() OVER (ORDER BY PORTNAME ASC) as Row,
			ID		, 
			PORTNAME, 
			NAME	, 
			CODE	, 
			COUNTRY	, 
			DEEPWATER_FLG 
		FROM PES.dbo.V_REF_LIB_PORT WITH (NOLOCK) 	
		WHERE ( NAME LIKE @FILTER_TEXT + '%')
	) AS A
	WHERE A.ROW BETWEEN @START_PAGE AND @NEXT_PAGE 
END
ELSE
BEGIN
	SELECT 		
		ID		, 
		PORTNAME, 
		NAME	, 
		CODE	, 
		COUNTRY	, 
		DEEPWATER_FLG 
	FROM 
	(
		SELECT	
			ROW_NUMBER() OVER (ORDER BY PORTNAME ASC) as Row,
			ID		, 
			PORTNAME, 
			NAME	, 
			CODE	, 
			COUNTRY	, 
			DEEPWATER_FLG 
		FROM PES.dbo.V_REF_LIB_PORT WITH (NOLOCK) 	
		WHERE 
		( 
			( NAME LIKE '%' + @FILTER_TEXT + '%' )
			OR ( PORTNAME LIKE '%' + @FILTER_TEXT + '%' )
			OR ( CODE LIKE '%' + @FILTER_TEXT + '%' )
			OR ( COUNTRY LIKE '%' + @FILTER_TEXT + '%' )
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
