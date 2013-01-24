/****** Object:  StoredProcedure [dbo].[PES_SP_GET_LOADNUMBER]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[PES_SP_GET_LOADNUMBER] 'DIS120919_3.zip'
CREATE PROCEDURE [dbo].[PES_SP_GET_LOADNUMBER] 
@SrcFileName varchar(1000),
@Load_Num varchar(15) output
As
Begin

	Declare @Result int,
			@SUBSTRINGSrcFileName varchar(10),
			@Startdate varchar(10),
			@FEED_LOAD_VALUE varchar(4),
			@No_Of_days VARCHAR(3),
			@No_Of_days_3Digits varchar(3),
			@Vendor_Code varchar(10),
			@Counter VARCHAR(5)
			
	set @Vendor_Code = substring(@SrcFileName,1,patindex('%[0-9]%',@SrcFileName)-1)

	set @FEED_LOAD_VALUE=(select load_value from dbo.PES_FEED_SIMCONF_VALUE where vendor =@Vendor_Code)


	IF @FEED_LOAD_VALUE IS NOT NULL AND (CHARINDEX('.ZIP',@SrcFileName) = 0)
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
			select @Load_Num  =cast(SUBSTRING(@SUBSTRINGSrcFileName,2,1)as varchar)+ @No_Of_days_3Digits + @FEED_LOAD_VALUE
		ELSE
			select @Load_Num  =cast(SUBSTRING(@SUBSTRINGSrcFileName,1,2)as varchar)+ @No_Of_days_3Digits+ @FEED_LOAD_VALUE 

			PRINT 'Loadnumber' + @Load_Num

		--UPDATE PES_PROGRESS_STATUS SET LOADNUMBER=@Load_Num WHERE UPPER(FILENAME)=UPPER(@SrcFileName)
	END

	ELSE IF @FEED_LOAD_VALUE IS NOT NULL AND (CHARINDEX('DSB',@SrcFileName) > 0 OR CHARINDEX('AMS',@SrcFileName) > 0) AND (CHARINDEX('.ZIP',@SrcFileName) > 0)
	BEGIN
		set @SUBSTRINGSrcFileName=SUBSTRING(@SrcFileName,4,6)
       -- PRINT 'SUBFILE' + @SUBSTRINGSrcFileName
		set @Startdate=SUBSTRING(@SUBSTRINGSrcFileName,1,2)+ '0101'
       -- PRINT '@Startdate' + @Startdate
		SET @Counter = SUBSTRING(@SrcFileName,CHARINDEX('_', @SrcFileName) + 1,CHARINDEX('.', @SrcFileName) - (CHARINDEX('_', @SrcFileName)+1)) 
	   -- PRINT '@Counter' + @Counter
		SELECT @No_Of_days= CAST (datediff(dd,@Startdate,@SUBSTRINGSrcFileName) AS BIGINT)+1  
	   -- PRINT '@No_Of_days' + @No_Of_days
		
		IF LEN(@No_Of_days)=1
			SET @No_Of_days_3Digits='00'+ CAST (@No_Of_days AS VARCHAR(1))
		ELSE IF LEN(@No_Of_days)=2
			SET @No_Of_days_3Digits='0'+ CAST (@No_Of_days AS VARCHAR(2))
		ELSE IF LEN(@No_Of_days)=3
			SET @No_Of_days_3Digits=CAST(@No_Of_days AS VARCHAR(3))
		
		IF SUBSTRING(@SUBSTRINGSrcFileName,1,1)='0'
			select @Load_Num  =cast(SUBSTRING(@SUBSTRINGSrcFileName,2,1)as varchar)+ @No_Of_days_3Digits + cast(@COUNTER as varchar) + @FEED_LOAD_VALUE
		ELSE
			select @Load_Num  =cast(SUBSTRING(@SUBSTRINGSrcFileName,1,2)as varchar)+ @No_Of_days_3Digits + cast(@COUNTER as varchar) + @FEED_LOAD_VALUE 

		--UPDATE PES_PROGRESS_STATUS SET LOADNUMBER=@Load_Num WHERE UPPER(FILENAME)=UPPER(@SrcFileName)

		
	   PRINT 'Loadnumber' + @Load_Num


	END
	
END
 


--exec PES_SP_GET_LOADNUMBER 'AMS120917.DAT'
--exec PES_SP_GET_LOADNUMBER 'DIS120917_100.DAT'
GO
