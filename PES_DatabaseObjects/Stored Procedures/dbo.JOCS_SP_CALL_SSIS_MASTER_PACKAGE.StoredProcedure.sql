/****** Object:  StoredProcedure [dbo].[JOCS_SP_CALL_SSIS_MASTER_PACKAGE]    Script Date: 01/03/2013 19:40:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[JOCS_SP_CALL_SSIS_MASTER_PACKAGE] 
@LOAD_NUMBER INT
---@BIZ_RETURNSTATUS  varchar(10) output 
As
Begin

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

Declare @PackagePath varchar(1000)
Declare @Command varchar(3000)
Declare @Result int
--Declare @CompanyResult int
--Declare @SUBSTRINGSrcFileName varchar(10)
--declare @Startdate varchar(10)
declare @Load_Num INT
--declare @FEED_LOAD_VALUE varchar(4)
--declare @TAPE_DT DATETIME
--declare @CompanyPackagePath varchar(1000)
--Declare @CompanyCommand varchar(2000)
--declare @No_Of_days int
--declare @No_Of_days_3Digits varchar(3)
--declare @Vendor_Code varchar(10)



	BEGIN
					
					SET @Load_Num  =@LOAD_NUMBER


						Set @PackagePath = '\\10.31.18.132\joc sailings\SSIS\SSIS_Packages\PKG_JOC_MASTER.dtsx'
					

						Set @Command = 
						'dtexec -f ' + '"'+ @PackagePath + '"'
						+ ' /set \Package.Variables[User::LOADNUMBER].Properties[Value];'+ CAST(@Load_Num AS VARCHAR(10))
						

--						CREATE TABLE #DTSErrorOutput 
--							 (ErrorString varchar(8000) NULL)
--						INSERT #DTSErrorOutput
						EXEC /*@Result =*/ xp_cmdshell @command
						
						--print @Result
						--print @command
						/*IF @Result >1 
							set @result=1
						IF @Result<>0
						BEGIN
							EXEC PES_PROGRESS_STATUS_PROCESS @Load_Num,'S3',2
							SELECT  @Result as STATUS ,(SELECT  LTRIM(ErrorString)as EXCEPTIONS FROM PES_XMLErrorOutput PES_FLAT_RAW_ERROR  
							--WHERE ErrorString like '%cannot%' or ErrorString like '%Err%' or ErrorString like '%fail%' or ErrorString like '%trun%' or ErrorString like '%valid%'
							FOR XML AUTO,TYPE )
							FOR XML RAW,ELEMENTS,ROOT('SP_FLAT_To_Raw_RETURN_STATUS')
						END 
						ELSE
							BEGIN
							EXEC PES_PROGRESS_STATUS_PROCESS @Load_Num,'S3'
							SELECT  @Result as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_FLAT_To_Raw_RETURN_STATUS')


					END*/

                   --SELECT SSIS_STATUS as SSIS_STATUS FROM dbo.JOCS_PROGRESS_STATUS where LOAD_NUMBER = @LOAD_NUMBER  for xml auto  
                  --SELECT MAX(LOAD_NUMBER) as LOAD_NUMBER FROM dbo.JOCS_PROGRESS_STATUS  for xml auto  
                  -- SET NOCOUNT ON
                   --select @BIZ_RETURNSTATUS = BIZ_STATUS from dbo.JOCS_PROGRESS_STATUS WHERE LOAD_NUMBER = @LOAD_NUMBER
                   --return 
				END





-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT



END
GO
