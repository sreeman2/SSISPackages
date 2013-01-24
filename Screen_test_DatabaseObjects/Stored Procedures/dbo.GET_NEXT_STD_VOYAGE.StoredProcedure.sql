/****** Object:  StoredProcedure [dbo].[GET_NEXT_STD_VOYAGE]    Script Date: 01/03/2013 19:47:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_NEXT_STD_VOYAGE]  
   @sUserName varchar(max),
   @outid float(53)  OUTPUT
AS 
BEGIN
SET NOCOUNT ON

---- [aa] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@sUserName='''+@sUserName+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'GET_NEXT_STD_VOYAGE'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT


-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@sUserName='''+@sUserName+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


      SET @outid = NULL
      DECLARE
         @STD_ID float(53), 
         @Tnbr numeric(10, 0), 
         @v_C1_rowcount int

      SET @STD_ID = 0

      DECLARE
          C1 CURSOR LOCAL FOR 
            SELECT STD_VOYAGE.T_NBR
            FROM dbo.STD_VOYAGE
            WHERE STD_VOYAGE.STD_ID = 0
            ORDER BY 
               STD_VOYAGE.USPORT, 
               STD_VOYAGE.CARRIER, 
               STD_VOYAGE.VESSEL_NAME, 
               STD_VOYAGE.VOYAGE_NBR

      SET @v_C1_rowcount = 0

      OPEN C1

      SET @outId = 0

      WHILE 1 = 1
      
         BEGIN

            FETCH C1
                INTO @TNBR

            IF @@FETCH_STATUS = 0
               SET @v_C1_rowcount = @v_C1_rowcount + 1
            IF @@FETCH_STATUS <> 0
               BREAK

            EXECUTE dbo.ASSIGN_STD_VOYAGE @INTNBR = @TNBR, @STRSTATUS = 'INPROCESS', @SUSERNAME = @sUserName, @OUTID = @std_id  OUTPUT

            IF (@STD_ID <> 0)
               BEGIN

                  SET @outId = @STD_ID

                  BREAK

               END

         END

      CLOSE C1

      DEALLOCATE C1

-- [aa] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

   END
GO
