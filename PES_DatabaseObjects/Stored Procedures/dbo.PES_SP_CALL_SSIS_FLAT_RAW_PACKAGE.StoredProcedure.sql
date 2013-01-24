/****** Object:  StoredProcedure [dbo].[PES_SP_CALL_SSIS_FLAT_RAW_PACKAGE]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_CALL_SSIS_FLAT_RAW_PACKAGE] @BOLFile varchar(1000),
@CmdFile varchar(1000), @CntrFile varchar(1000), 
@ConsFile varchar(1000), @HazmFile varchar(1000), @MANFile varchar(1000),
@AlsoNtfFile varchar(1000),@NtfFile varchar(1000),@ShpFile varchar(1000),
@SrcFileName varchar(1000)  
As
Begin
-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


-- [aa] - 09/30/2010
-- Log - process started
DECLARE @ProcessName varchar(100), @IdProcessLog int
SELECT @ProcessName = 'FeedLoad-FileToRaw', @IdProcessLog = -1
EXEC dbo.usp_ProcessLogCreate @ProcessName, 'NA', @IdProcessLog OUT, @SrcFileName

Declare @PackagePath varchar(1000)
Declare @Command varchar(3000)
Declare @Result int
Declare @CompanyResult int
Declare @SUBSTRINGSrcFileName varchar(10)
declare @Startdate varchar(10)
declare @Load_Num varchar(15)
declare @FEED_LOAD_VALUE varchar(4)
declare @TAPE_DT DATETIME
declare @CompanyPackagePath varchar(1000)
Declare @CompanyCommand varchar(2000)
declare @No_Of_days int
declare @No_Of_days_3Digits varchar(3)
declare @Vendor_Code varchar(10)

--set @Vendor_Code=substring(@SrcFileName,1,3)

---------------------------------------------------------------------------------------------
--Modified by Prabhav on 15th April 2009
--Vendor code can come more than 3 character

set @Vendor_Code = substring(@SrcFileName,1,patindex('%[0-9]%',@SrcFileName)-1)

----------------------------------------------------------------------------------------------
--If @Vendor_Code='AES'
--	set @Vendor_Code='ESCAN'
set @FEED_LOAD_VALUE=(select load_value from dbo.PES_FEED_SIMCONF_VALUE where vendor =@Vendor_Code)
--set @FEED_LOAD_VALUE=(select load_value from dbo.PES_FEED_SIMCONF_VALUE where vendor like substring(@SrcFileName,1,3)+'%')
IF @FEED_LOAD_VALUE IS NOT NULL
	BEGIN
		IF CHARINDEX('_',@SrcFileName) > 0
			BEGIN
				set @SUBSTRINGSrcFileName=reverse(SUBSTRING(reverse(@SrcFileName),CHARINDEX('_',reverse(@SrcFileName))+1,6))
			END
		ELSE
			BEGIN
				set @SUBSTRINGSrcFileName=reverse(SUBSTRING(reverse(@SrcFileName),CHARINDEX('.',reverse(@SrcFileName))+1,6))
			END
		--select @SUBSTRINGSrcFileName
		/*
		set @Startdate=SUBSTRING(@SUBSTRINGSrcFileName,1,2)+ '0101'
		SELECT @No_Of_days=datediff(dd,@Startdate,@SUBSTRINGSrcFileName)+1
		IF LEN(@No_Of_days)=1
		SET @No_Of_days_3Digits='00'+ CAST (@No_Of_days AS VARCHAR(1))
		ELSE IF LEN(@No_Of_days)=2
		SET @No_Of_days_3Digits='0'+ CAST (@No_Of_days AS VARCHAR(2))
		ELSE IF LEN(@No_Of_days)=3
		SET @No_Of_days_3Digits=CAST(@No_Of_days AS VARCHAR(3))
		*/
		BEGIN TRY
			IF isnumeric(replace(@SUBSTRINGSrcFileName,'_',''))=1 -- or isnumeric(@SUBSTRINGSrcFileName)=0
			BEGIN
		        DECLARE	@return_value int
				EXEC @return_value =[dbo].[PES_SP_GET_LOADNUMBER] @SrcFileName ,@Load_Num  OUTPUT
				--select @Load_Num
					
				IF SUBSTRING(@SUBSTRINGSrcFileName,1,1)='0'
					SET @Load_Num  = @Load_Num --cast(SUBSTRING(@SUBSTRINGSrcFileName,2,1)as varchar)+ @No_Of_days_3Digits + @FEED_LOAD_VALUE
				ELSE
						SET @Load_Num  =@Load_Num --cast(SUBSTRING(@SUBSTRINGSrcFileName,1,2)as varchar)+ @No_Of_days_3Digits+ @FEED_LOAD_VALUE 

						Set @SrcFileName=upper(@SrcFileName)
						Set @CompanyPackagePath = 'E:\PIERS Enterprise Solution\StagingComponents\SSISPackage\PES_Company.dtsx'
					
						Set @PackagePath = 'E:\PIERS Enterprise Solution\StagingComponents\SSISPackage\PES_Flat_Raw.dtsx'

						Set @command = 
						'dtexec -f ' + '"'+ @PackagePath + '"'
						+ ' /set \Package.Variables[User::BOL_VAR].Properties[Value];' + '"' + @BOLFile + '"'
						+ ' /set \Package.Variables[User::CMD_VAR].Properties[Value];' + '"' +@CmdFile + '"'
						+ ' /set \Package.Variables[User::CNTR_VAR].Properties[Value];' + '"' +@CntrFile + '"'
						+ ' /set \Package.Variables[User::CNG_VAR].Properties[Value];' + '"' +@ConsFile + '"'
						+ ' /set \Package.Variables[User::HZMT_VAR].Properties[Value];' + '"' +@HazmFile + '"'
						+ ' /set \Package.Variables[User::MAN_VAR].Properties[Value];' + '"' +@MANFile + '"'
						+ ' /set \Package.Variables[User::NTY_VAR].Properties[Value];' + '"' +@NtfFile + '"'
						+ ' /set \Package.Variables[User::ANTY_VAR].Properties[Value];' + '"' +@AlsoNtfFile + '"'
						+ ' /set \Package.Variables[User::SHP_VAR].Properties[Value];' + '"' +@ShpFile + '"'
						+ ' /set \Package.Variables[User::SRCFILENAME_VAR].Properties[Value];' + '"' +@Load_Num + '"'
                        + ' /set \Package.Variables[User::FEEDNAME].Properties[Value];' + '"' +reverse(SUBSTRING(reverse(@SrcFileName),CHARINDEX('.',reverse(@SrcFileName))+1,LEN(@SrcFileName))) + '"'
						+ ' /set \Package.Variables[User::FILENAME].Properties[Value];' + '"' + UPPER(@SrcFileName) + '"'
					    + ' /set \Package.Variables[User::TAPEDATE].Properties[Value];' + '"' + @SUBSTRINGSrcFileName + '"'
						+ ' /set \Package.Variables[User::VENDORCODE].Properties[Value];' + '"' + UPPER(@Vendor_Code) + '"'
						
				UPDATE PES_PROGRESS_STATUS SET LOADNUMBER=@Load_Num WHERE  UPPER(FILENAME)=UPPER(@SrcFileName)

						CREATE TABLE #DTSErrorOutput 
							 (ErrorString varchar(8000) NULL)
						INSERT #DTSErrorOutput
						EXEC @Result = xp_cmdshell @command
						
						--print @Result					
						--select @Result result
						--select * from #DTSErrorOutput
						IF @Result >1 
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


					END
				END


			ELSE 
				BEGIN
				set @Load_Num = 0
				-- 3 MEANS FOR LOAD NUMBER GENERATION THE LAST 6 NUMERIC LETTERS SHOULD BE IN YYMMDD FORMAT
				SELECT  3 as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_FLAT_To_Raw_RETURN_STATUS')
				END
			END TRY
			BEGIN CATCH
			set @Load_Num = 0
			SELECT  3 as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_FLAT_To_Raw_RETURN_STATUS')
		END CATCH
	END
		-- 2 MEANS FOR FIRST 3 LETTERS OF FEED NAME SHOULD MATCH IN 'PES_FEED_SIMCONF_VALUE' TABLE 
		IF  @Load_Num < 0 OR @Load_Num IS NULL
		SELECT  2 as STATUS FOR XML RAW,ELEMENTS,ROOT('SP_FLAT_To_Raw_RETURN_STATUS')

-- [aa] - 09/30/2010
-- Log - process completed
EXEC dbo.usp_ProcessLogUpdate @IdProcessLog, 'Successful', 'Done'


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

End
GO
