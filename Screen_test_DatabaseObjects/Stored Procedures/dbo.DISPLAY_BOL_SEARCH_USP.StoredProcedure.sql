/****** Object:  StoredProcedure [dbo].[DISPLAY_BOL_SEARCH_USP]    Script Date: 01/03/2013 19:47:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DISPLAY_BOL_SEARCH_USP]
	@SEARCH_TXT AS VARCHAR(MAX)		,
	@SEARCH_TYPE AS VARCHAR(100)	,
	@DIR AS VARCHAR(1)
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


	IF ( @SEARCH_TYPE = 'BL_NBR' )
	BEGIN        
		SELECT	BL.BL_NBR AS BL_NBR	, 
				BL.t_nbr, 
				BL.DQA_VOYAGE_ID 
		FROM dbo.BL_BL BL WITH (NOLOCK) 
        WHERE 
		( 
			( BL.DIR = @DIR ) 
			AND ( BL.BL_NBR LIKE  @SEARCH_TXT+'%' )
		)
	END
	ELSE
	BEGIN
		IF ( ISNUMERIC(@SEARCH_TXT) <> 1 )
			SET @SEARCH_TXT = '0'

		SELECT	BL.BL_NBR AS BL_NBR	, 
				BL.t_nbr, 
				BL.DQA_VOYAGE_ID 
		FROM dbo.BL_BL BL WITH (NOLOCK) 
        WHERE 
		( 
			( BL.DIR = @DIR ) 
			AND ( BL.T_NBR = @SEARCH_TXT ) 
		)
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
