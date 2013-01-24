/****** Object:  StoredProcedure [dbo].[USP_PES_ENHANCE_DESC]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		PRABHAV BHATT
-- CREATE DATE: 29 APRIL 2009
-- DESCRIPTION:	CREATE ENHANCE DESCRIPTION FOR COMMODITIES INSERTION IN 
--				HCS_COMMODITY IN REPROCESSING
-- =============================================
CREATE PROCEDURE [dbo].[USP_PES_ENHANCE_DESC]
(
	@DQA_DESC TEXT,@BOL_ID NUMERIC(12,0),@ENH_DESC VARCHAR(MAX) OUTPUT
)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE 
@TEMP_ENH_DESC VARCHAR(MAX),
@DESCRIPTION VARCHAR(MAX)
SET @DESCRIPTION = CONVERT(VARCHAR(MAX),@DQA_DESC)
SET @TEMP_ENH_DESC = '' 

WHILE LEN(@DESCRIPTION)>0
BEGIN
	IF PATINDEX('%[ ]%',@DESCRIPTION) <> 0
	BEGIN
	SELECT @TEMP_ENH_DESC  = @TEMP_ENH_DESC + '<: ' + SUBSTRING(@DESCRIPTION,1,PATINDEX('%[ ]%',@DESCRIPTION)) + ' >'  
	SELECT @DESCRIPTION = SUBSTRING(@DESCRIPTION,PATINDEX('%[ ]%',@DESCRIPTION)+1,LEN(@DESCRIPTION))
	END 
	ELSE
	BEGIN
	SET @TEMP_ENH_DESC = @TEMP_ENH_DESC + '<: ' + @DESCRIPTION + ' >'
	SET @DESCRIPTION = ''
	END

END
SET @ENH_DESC = @TEMP_ENH_DESC

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
