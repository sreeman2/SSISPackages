/****** Object:  StoredProcedure [dbo].[SP_INSERT_TRANSACTION]    Script Date: 01/08/2013 14:51:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_INSERT_TRANSACTION] 
	-- Add the parameters for the stored procedure here
  @BOLID INT, @FIELDNAME VARCHAR(50), @OLDVALUE VARCHAR(2000), @NEWVALUE VARCHAR(2000),
  @MODIFYUSERNAME VARCHAR(50), @DIRECTION CHAR(1), @CREATEDUSER VARCHAR(25)
    
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@BOLID='++LTRIM(RTRIM(STR(@BOLID)))
+', @FIELDNAME='''+@FIELDNAME+''''
+', @OLDVALUE='''+@OLDVALUE+''''
+', @NEWVALUE='''+@NEWVALUE+''''
+', @MODIFYUSERNAME='''+@MODIFYUSERNAME+''''
+', @DIRECTION='''+@DIRECTION+''''
+', @CREATEDUSER='''+@CREATEDUSER+''''
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

  INSERT INTO PES_DW_TRANSACTION
   (BOL_ID, FIELD_NAME, OLD_VALUE, NEW_VALUE, USER_NAME, MODIFY_DATE, DIRECTION,CREATED_USER,CREATED_DATE)
   VALUES
   (@BOLID, @FIELDNAME, @OLDVALUE, @NEWVALUE, @MODIFYUSERNAME,getdate(), @DIRECTION,@CREATEDUSER,getdate()); 

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END;
GO
