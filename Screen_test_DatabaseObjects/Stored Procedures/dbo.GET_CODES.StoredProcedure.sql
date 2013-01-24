/****** Object:  StoredProcedure [dbo].[GET_CODES]    Script Date: 01/03/2013 19:47:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_CODES] @description  varchar(100), @h_code varchar(10) OUTPUT, @j_code  varchar(10) OUTPUT,@msg INT OUTPUT 

AS
  DECLARE @search_key varchar(100);
--  DECLARE @h varchar(6)
--  DECLARE @j varchar(7)
--  DECLARE @harm_ind INT
  DECLARE @RECCOUNT int
--  DECLARE @joc_ind int
--  SET @harm_ind=0
--  SET @joc_ind=0

 
BEGIN 

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

		SET @search_key=dbo.GET_KEY(@description);
		SET @RECCOUNT=0
		SELECT @RECCOUNT=count(*) FROM HIST_CODES WITH (NOLOCK) WHERE PERM_KEY = @search_key
        SELECT @h_code=HARM_CODE,@j_code=JOC_CODE FROM HIST_CODES WHERE PERM_KEY = @search_key
        SET @msg=0
        IF @h_code IS NULL 
             SET @msg= 2
        IF @j_code IS NULL 
             SET @msg=3
		IF @RECCOUNT = 0  
             SET @msg= 1

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
