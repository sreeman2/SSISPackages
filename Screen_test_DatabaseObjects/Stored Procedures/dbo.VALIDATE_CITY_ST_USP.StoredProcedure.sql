/****** Object:  StoredProcedure [dbo].[VALIDATE_CITY_ST_USP]    Script Date: 01/03/2013 19:48:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[VALIDATE_CITY_ST_USP]
	@CITY AS VARCHAR(125)	,
	@STATE AS VARCHAR(2)
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


IF ( @CITY IS NOT NULL )
	SET @CITY = REPLACE(@CITY, '''''', '''')	
IF ( @STATE IS NOT NULL )
	SET @STATE = REPLACE(@STATE, '''''', '''')	

SELECT [CTST_ID]
FROM PES.dbo.[REF_CITYST] WITH (NOLOCK) 
WHERE 
( 	
	( [M_CITY] = @CITY  )
	AND ( [M_ST] = @STATE )
	AND ( [DELETED] = 'N' ) 
)

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
