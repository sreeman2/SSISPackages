/****** Object:  StoredProcedure [dbo].[ASSIGN_STD_VOYAGE]    Script Date: 01/03/2013 19:47:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from std_voyage
-- exec ASSIGN_STD_VOYAGE 380,'INPROCESS','user4',0
CREATE PROCEDURE [dbo].[ASSIGN_STD_VOYAGE]
(
	@inTNBR NUMERIC(10,0), 
	@strStatus VARCHAR(20),
	@sUserName VARCHAR(20), 
	@outId INT OUTPUT
)
AS
BEGIN

---- [aa] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@inTNBR='''+CAST(@inTNBR AS VARCHAR(100))+''''
--+', @strStatus='''+@strStatus+''''
--+', @sUserName='''+@sUserName+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'ASSIGN_STD_VOYAGE'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT


-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@inTNBR='''+CAST(@inTNBR AS VARCHAR(100))+''''
+', @strStatus='''+@strStatus+''''
+', @sUserName='''+@sUserName+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


      DECLARE
            @BOL_NUMBER NUMERIC(10,0),
            @UPCNT INT,
            @CNT INT,
            @I INT,
            @nextID INT,
            @CNT1 INT;
      CREATE TABLE #TEMP (ID INT IDENTITY(1,1),TNBR NUMERIC(10,0))


SET @CNT =0
SET @CNT1 = 0
SET @I = 0
      INSERT INTO #TEMP(TNBR)
      SELECT DISTINCT A.T_NBR FROM dbo.CTRL_PROCESS_VOYAGE A, dbo.CTRL_PROCESS_VOYAGE B, dbo.STD_VOYAGE C, dbo.STD_VOYAGE D
      WHERE
      B.T_NBR = @inTNBR AND
      A.COMPLETE_STATUS=1 AND
      B.COMPLETE_STATUS=1 AND
      A.PROCESS_NAME=B.PROCESS_NAME AND
	  --A.[KEY]=B.[KEY]AND
	  isnull(A.[KEY],'')=isnull(B.[KEY],'') AND
      A.T_NBR=C.T_NBR AND
      B.T_NBR = D.T_NBR AND 
      C.VOYAGE_STATUS=D.VOYAGE_STATUS AND 
      C.STD_ID=0 AND
      D.STD_ID=0 AND
      D.VOYAGE_STATUS = @strStatus AND
      C.DIR=D.DIR AND
      A.PROCESS_NAME IN ('INVALID VESSEL NAME', 'INVALID CARRIER', 'INVALID USPORT')

    SELECT @CNT = COUNT(ID) FROM #TEMP
	
	IF (@CNT > 0)
    BEGIN
            SELECT @nextID=MaxValue from dbo.PEA_SEQUENCE WHERE TableName='STD_VOYAGE'
            SET @nextID=@nextID+1
            UPDATE dbo.PEA_SEQUENCE SET MaxValue=@nextID 
			WHERE TableName='STD_VOYAGE'
    END
	WHILE (@I <= @CNT)
    BEGIN
        SELECT @BOL_NUMBER = TNBR FROM #TEMP WHERE ID = @I
        UPDATE dbo.STD_VOYAGE 
		SET STD_ID=@nextID, SEQ_NBR=@CNT1, MODIFIED_BY = @sUserName, MODIFIED_DT = GETDATE() 
		WHERE T_NBR = @BOL_NUMBER AND STD_ID=0;
        
		SET @I = @I + 1 
		SET @CNT1 = @CNT1 + 1
    END
	IF @@ROWCOUNT <> 0
      SET @UPCNT = @UPCNT + 1
	
	IF (@CNT = 0)
      SET @OUTID = 0
	ELSE IF (@CNT <> @UPCNT)
      BEGIN
            UPDATE dbo.STD_VOYAGE SET STD_ID=0 WHERE STD_ID=@nextID
            SET @OUTID = 0
      END
	ELSE
	begin
      SET @OUTID = @NEXTID
	end 
	DROP TABLE #TEMP
	--print @outid

-- [aa] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
