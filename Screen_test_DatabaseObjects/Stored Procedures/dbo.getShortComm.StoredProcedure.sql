/****** Object:  StoredProcedure [dbo].[getShortComm]    Script Date: 01/03/2013 19:47:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[getShortComm] 
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE  @cmdsDesc      VARCHAR(8000);
DECLARE  @BOL_ID INT  
DECLARE  @CMD_ID INT     
DECLARE  @retDesc      VARCHAR(8000);
DECLARE  @cleancmdsDesc     VARCHAR(8000);
DECLARE COMMSHORTDESC CURSOR FOR  SELECT BOL_ID,CMD_ID,CMD_DESC FROM PES.DBO.PES_STG_CMD WHERE BOL_ID IN (SELECT BOL_ID 
FROM PES.DBO.RAW_CMD)
OPEN COMMSHORTDESC
FETCH NEXT FROM COMMSHORTDESC INTO @BOL_ID,@CMD_ID,@cmdsDesc
WHILE @@FETCH_STATUS = 0
BEGIN

IF @cmdsDesc IS NULL
  SET @retDesc='NO COMMODITY'
ELSE
BEGIN
     SET  @cleanCmdsDesc = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@cmdsDesc,'.',''),'\\',''),'/',''),',',''),'''','')));
     SET @cleanCmdsdesc = REPLACE(REPLACE(REPLACE(@cleanCmdsdesc,CHAR(1),' '),CHAR(2),' '),CHAR(3),' ');
     SELECT @retDesc=DBO.short_descComm(@cleanCmdsdesc)
END

--  IF (@retDesc is not null)
--           BREAK
--      
BEGIN TRY
UPDATE PES.DBO.PES_STG_CMD SET CMD_DESC=@retDesc WHERE BOL_ID=@BOL_ID AND CMD_ID=@CMD_ID
END TRY
BEGIN CATCH
END CATCH
FETCH NEXT FROM COMMSHORTDESC INTO @BOL_ID,@CMD_ID,@cmdsDesc
END
CLOSE COMMSHORTDESC
DEALLOCATE COMMSHORTDESC
END
GO
