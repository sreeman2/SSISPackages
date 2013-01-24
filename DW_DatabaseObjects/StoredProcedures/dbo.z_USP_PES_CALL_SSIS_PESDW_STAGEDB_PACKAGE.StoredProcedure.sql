/****** Object:  StoredProcedure [dbo].[z_USP_PES_CALL_SSIS_PESDW_STAGEDB_PACKAGE]    Script Date: 01/08/2013 14:51:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[z_USP_PES_CALL_SSIS_PESDW_STAGEDB_PACKAGE]
@xml_ret XML OUTPUT


As
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

 
Declare @PackagePath varchar(1000)
Declare @Command varchar(2000)
Declare @Result int

Set @PackagePath = 'E:\PIERS Enterprise Solution\StagingComponents\SSISPackage\PES_PESDW_MYPIERS.dtsx'

Set @command = 'dtexec -f ' + '"'+ @PackagePath + '"'



CREATE TABLE #DTSErrorOutputs 
     (ErrorString varchar(8000) NULL)
INSERT #DTSErrorOutputs
EXEC @Result=xp_cmdshell @command

IF @Result > 1
Set @Result=1
IF @Result<>0
BEGIN
	SET @xml_ret = (SELECT  @Result as STATUS ,(SELECT  LTRIM(ErrorString)as EXCEPTIONS FROM #DTSErrorOutputs PES_DW_INFORMIX_ERROR  
	WHERE ErrorString like '%cannot%' or ErrorString like '%Err%' or ErrorString like '%fail%' or ErrorString like '%trun%' or ErrorString like '%valid%'
	FOR XML AUTO,TYPE )
	FOR XML RAW,ELEMENTS,ROOT('SP_PESDW_TO_STAGEDB_RETURN_STATUS'))
	--EXEC PES_SP_EMAIL 'MYPIERS Load failed','MYPIERS Load has failed. Please check log files and resolve the issue.','','',''
END
ELSE
BEGIN
	SET @xml_ret = (SELECT  @Result as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_PESDW_TO_STAGEDB_RETURN_STATUS'))
	--EXEC PES_SP_EMAIL 'MYPIERS Load successful','MYPIERS Load completed successfully.','','',''
END

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
