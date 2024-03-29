/****** Object:  StoredProcedure [dbo].[LOAD_COMMODITY_REF_DICT_USP]    Script Date: 01/03/2013 19:47:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_COMMODITY_REF_DICT_USP]
	@FILTER_VAL AS VARCHAR(250)	,
	@NO_OF_RECORDS AS INT		,
	@IS_HARM_CODE AS BIT = 1	,
	@IS_COMM_CODE AS BIT = 0
AS
BEGIN
SET NOCOUNT ON;

/*
-- [aa] - 11/08/2010
-- Log start time
DECLARE @IdLogOut int
DECLARE @ParametersIn varchar(MAX)
SET @ParametersIn =
'@FILTER_VAL='''+@FILTER_VAL+''''
+', @NO_OF_RECORDS='+LTRIM(RTRIM(STR(@NO_OF_RECORDS)))
+', @IS_HARM_CODE='+LTRIM(RTRIM(STR(@IS_HARM_CODE)))
+', @IS_COMM_CODE='+LTRIM(RTRIM(STR(@IS_COMM_CODE)))
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
@SprocName = 'LOAD_COMMODITY_REF_DICT_USP'
,@Parameters = @ParametersIn
,@IdLog = @IdLogOut OUT
*/

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT



	IF ( @IS_HARM_CODE  = 1 )
	BEGIN
		IF ( @IS_COMM_CODE = 1 )
		BEGIN
--Fix for the Commodity Dictionary Lookup
--			SELECT  TOP 200 HARMCODE, 
			SELECT  TOP 1000 HARMCODE, 
					FULL_NAME AS Commname 
			FROM PES.dbo.REF_HARMCMST WITH (NOLOCK) 
			WHERE 
			( 
				( FULL_NAME LIKE '%'+@FILTER_VAL+'%' OR HARMCODE LIKE '%'+@FILTER_VAL+'%' ) 
				AND ( DELETED = 'N' ) 
			)
		END
		ELSE
		BEGIN
--Fix for the Commodity Dictionary Lookup
--			SELECT  TOP 200  FULL_NAME AS Commname 
			SELECT  TOP 1000  FULL_NAME AS Commname
			FROM PES.dbo.REF_HARMCMST WITH (NOLOCK) 
			WHERE 
			( 
				( FULL_NAME LIKE '%'+@FILTER_VAL+'%' ) AND ( DELETED = 'N' ) 
			)
		END
	END
	ELSE
	BEGIN		
		IF ( @IS_COMM_CODE = 1 )
		BEGIN
			SELECT	TOP 200 TSUSA AS TSUSA	, 		
					FULL_NAME AS Commname 
			FROM PES.dbo.REF_CMMCST WITH (NOLOCK) 
			WHERE 
			( 
				( FULL_NAME LIKE '%'+@FILTER_VAL+'%' OR TSUSA LIKE '%'+@FILTER_VAL+'%' ) 
				AND ( DELETED = 'N' ) 
			)
		END
		ELSE
		BEGIN
			SELECT	TOP 200 FULL_NAME AS Commname 
			FROM PES.dbo.REF_CMMCST WITH (NOLOCK) 
			WHERE 
			( 
				( FULL_NAME LIKE '%'+@FILTER_VAL+'%' ) 
				AND ( DELETED = 'N' ) 
			)
		END
	END


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
