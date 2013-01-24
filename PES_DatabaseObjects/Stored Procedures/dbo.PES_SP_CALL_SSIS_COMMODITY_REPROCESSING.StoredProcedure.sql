/****** Object:  StoredProcedure [dbo].[PES_SP_CALL_SSIS_COMMODITY_REPROCESSING]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_CALL_SSIS_COMMODITY_REPROCESSING]
@xml_ret XML OUTPUT


As
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

 
Declare @PackagePath varchar(1000)
Declare @Command varchar(2000)
Declare @Result int

Set @PackagePath = 'E:\PIERS Enterprise Solution\StagingComponents\SSISPackage\PES_COMMODITY_REPROCESSING.dtsx'

Set @command = 'dtexec -f ' + '"'+ @PackagePath + '"'



CREATE TABLE #DTSErrorOutputs 
     (ErrorString varchar(8000) NULL)
INSERT #DTSErrorOutputs
EXEC @Result=xp_cmdshell @command

IF @Result > 1
Set @Result=1
IF @Result<>0
BEGIN
	SET @xml_ret = (SELECT  @Result as STATUS ,(SELECT  LTRIM(ErrorString)as EXCEPTIONS FROM #DTSErrorOutputs PES_STG_DW_ERROR  
	WHERE ErrorString like '%cannot%' or ErrorString like '%Err%' or ErrorString like '%fail%' or ErrorString like '%trun%' or ErrorString like '%valid%'
	FOR XML AUTO,TYPE )
	FOR XML RAW,ELEMENTS,ROOT('SP_HUB_REPROCESS_RETURN_STATUS'))
	--EXEC PES_SP_EMAIL 'Company Re-process load failed','Company Re-process load has failed. Please check log files and resolve the issue.','','',''
END
ELSE
BEGIN
	SET @xml_ret = (SELECT  @Result as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_HUB_REPROCESS_RETURN_STATUS'))
	--EXEC PES_SP_EMAIL 'Company Re-process load successful','Company Re-process load completed successfully.','','',''
END


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
