/****** Object:  StoredProcedure [dbo].[UPDATE_STND_SKIPPED_STATUS]    Script Date: 01/03/2013 19:48:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_STND_SKIPPED_STATUS] 	
	@T_NBR_LST VARCHAR(MAX)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

---- [Pramod K] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@T_NBR_LST='''+@T_NBR_LST+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'UPDATE_STND_SKIPPED_STATUS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@T_NBR_LST='''+@T_NBR_LST+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @TRN_NBR_TBL AS TABLE(T_NBR INT)

DECLARE @COUNT AS INT 
DECLARE @POSITION AS INT
DECLARE @LENTH AS INT
DECLARE @T_NBR1 AS VARCHAR(25)

SET @COUNT		= LEN(@T_NBR_LST)
SET	@POSITION	= 0

WHILE ( @COUNT > 0 )
BEGIN
	SET @LENTH	= CHARINDEX(',',@T_NBR_LST)	
	
	IF ( @LENTH <= 0 )
	BEGIN
		INSERT INTO @TRN_NBR_TBL
		SELECT CAST(@T_NBR_LST AS INT)

		BREAK
	END
	ELSE
	BEGIN	
		SET @T_NBR1	= SUBSTRING(@T_NBR_LST, @POSITION,  @LENTH)	

		INSERT INTO @TRN_NBR_TBL
		SELECT CAST(@T_NBR1 AS INT)
		
		SET @T_NBR_LST	= SUBSTRING(@T_NBR_LST, @LENTH+1, (LEN(@T_NBR_LST) - (LEN(@T_NBR1)+1)) )
		SET @COUNT			= @COUNT - (LEN(@T_NBR1)+1)
	END 
END
	
--UPDATE DQA_SKIPPED_STDN_BOL
--SET DELETED = 1
DELETE FROM dbo.DQA_SKIPPED_STDN_BOL
WHERE ( T_NBR IN ( SELECT T_NBR FROM @TRN_NBR_TBL ) )

/*
--SELECT * FROM dbo.ufn_SplitString(@T_NBR_LST,',') 

DELETE
 FROM dbo.DQA_SKIPPED_STDN_BOL
WHERE T_NBR IN ( SELECT Item As T_NBR FROM dbo.ufn_SplitString(@T_NBR_LST,',') )
*/

-- [Pramod K] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT
	
END
GO
