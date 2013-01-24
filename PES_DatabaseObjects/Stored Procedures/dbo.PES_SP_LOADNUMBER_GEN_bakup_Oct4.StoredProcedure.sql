/****** Object:  StoredProcedure [dbo].[PES_SP_LOADNUMBER_GEN_bakup_Oct4]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_LOADNUMBER_GEN_bakup_Oct4] 
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


	Declare @Result int,
			@SUBSTRINGSrcFileName varchar(10),
			@Startdate varchar(10),
			@Load_Num varchar(15),
			@FEED_LOAD_VALUE varchar(4),
			@No_Of_days int,
			@No_Of_days_3Digits varchar(3),
			@Vendor_Code varchar(10)
	

	set @Vendor_Code = substring(@SrcFileName,1,patindex('%[0-9]%',@SrcFileName)-1)

	set @FEED_LOAD_VALUE=(select load_value from dbo.PES_FEED_SIMCONF_VALUE where 
	vendor =@Vendor_Code)

	IF @FEED_LOAD_VALUE IS NOT NULL
	BEGIN
		set @SUBSTRINGSrcFileName=reverse(SUBSTRING(reverse(@SrcFileName),CHARINDEX('.',reverse(@SrcFileName))+1,6))
		set @Startdate=SUBSTRING(@SUBSTRINGSrcFileName,1,2)+ '0101'
		SELECT @No_Of_days=datediff(dd,@Startdate,@SUBSTRINGSrcFileName)+1
		IF LEN(@No_Of_days)=1
			SET @No_Of_days_3Digits='00'+ CAST (@No_Of_days AS VARCHAR(1))
		ELSE IF LEN(@No_Of_days)=2
			SET @No_Of_days_3Digits='0'+ CAST (@No_Of_days AS VARCHAR(2))
		ELSE IF LEN(@No_Of_days)=3
			SET @No_Of_days_3Digits=CAST(@No_Of_days AS VARCHAR(3))
		
		IF SUBSTRING(@SUBSTRINGSrcFileName,1,1)='0'
			SET @Load_Num  =cast(SUBSTRING(@SUBSTRINGSrcFileName,2,1)as varchar)+ @No_Of_days_3Digits + @FEED_LOAD_VALUE
		ELSE
			SET @Load_Num  =cast(SUBSTRING(@SUBSTRINGSrcFileName,1,2)as varchar)+ @No_Of_days_3Digits+ @FEED_LOAD_VALUE 

		UPDATE PES_PROGRESS_STATUS SET LOADNUMBER=@Load_Num WHERE UPPER(FILENAME)=UPPER(@SrcFileName)
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
