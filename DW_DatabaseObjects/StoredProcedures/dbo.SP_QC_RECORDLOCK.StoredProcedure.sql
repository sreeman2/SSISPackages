/****** Object:  StoredProcedure [dbo].[SP_QC_RECORDLOCK]    Script Date: 01/08/2013 14:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_QC_RECORDLOCK] 
	-- Add the parameters for the stored procedure here
   @BOLID INT, @USERNAME VARCHAR(50) = NULL, @CURRENTUSERNAME VARCHAR(50)

AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@BOLID='++LTRIM(RTRIM(STR(@BOLID)))
+', @USERNAME='''+@USERNAME+''''
+', @CURRENTUSERNAME='''+@CURRENTUSERNAME+''''
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


  UPDATE PES_DW_BOL SET LOCKED_BY_USER = @USERNAME 
  WHERE BOL_ID = @BOLID;  
  IF 
    @USERNAME = NULL
  
     UPDATE PES_DW_BOL SET LOCKED_BY_USER = @USERNAME 
     WHERE BOL_ID = @BOLID
     AND LOCKED_BY_USER = @CURRENTUSERNAME;  
 
END
-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

;
GO
