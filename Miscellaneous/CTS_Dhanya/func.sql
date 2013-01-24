-- getdate
-- check if date exists in the table 
-- if exists update counter by 1
-- create the strfilename as date+counter
-- return the filename

USE [PES]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetRegionCode]    Script Date: 09/14/2012 14:59:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Ufn_GenerateFileName]
RETURNS VARCHAR(50)
BEGIN	
	DECLARE @processdate datetime
	DECLARE @FileName varchar(50)
	DECLARE @FileCount int

	SET @FileCount = 1
	SET @FileName=''
	SET @processdate = substring(convert(varchar, getdate(), 112),3,6)
	

	IF EXISTS (SELECT FileProcessDate from PES_IBIFileCounter where CONVERT(VARCHAR, FileProcessDate, 112) = @processdate)
	BEGIN
		UPDATE FileProcessDate 
		   SET FileCount = FileCount+1
		 WHERE FileProcessDate = @processdate

		SELECT @FileCount = MAX(FileCount) FROM PES_IBIFileCounter
		 WHERE FileProcessDate = @processdate

		   SET @FileName = @FileName+@processdate+'_'+@FileCount
	END
	ELSE
	BEGIN
		INSERT INTO FileProcessDate (FileProcessDate,DateCreated) VALUES (@FileCount,substring(convert(varchar, getdate(), 112),3,6))
		   SET @FileName = @FileName+@processdate+'_'+@FileCount
	END

	RETURN (@FileName)
END






