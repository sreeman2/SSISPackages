/****** Object:  UserDefinedFunction [dbo].[Ufn_GenerateFileName]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 20-March-2009
-- Description:	Get Bank Name
-- =============================================
CREATE FUNCTION [dbo].[Ufn_GenerateFileName]()
RETURNS varchar(50)
AS
BEGIN
	DECLARE @FileName varchar(50)
	SELECT @FileName=NULL
	DECLARE @processdate datetime
	DECLARE @FileCount int

	SET @FileCount = 1
	SET @FileName=''
	SET @processdate = substring(convert(varchar, getdate(), 112),3,6)

	IF EXISTS (SELECT FileProcessDate from PES_IBIFileCounter where CONVERT(VARCHAR, FileProcessDate, 112) = @processdate)
	BEGIN
		SELECT @FileCount = MAX(FileCount) FROM PES_IBIFileCounter
		 WHERE CONVERT(VARCHAR, FileProcessDate, 112) = @processdate
        SET @FileCount = @FileCount+1
		
--	UPDATE PES_IBIFileCounter SET FileCount = @FileCount
--		 WHERE CONVERT(VARCHAR, FileProcessDate, 112) = @processdate
 	   --SET @FileName = @FileName+@processdate+'_'+@FileCount
		RETURN @FileName
	END
	ELSE
	BEGIN
		--INSERT INTO PES_IBIFileCounter (FileProcessDate,FileCount) VALUES (substring(convert(varchar, getdate(), 112),3,6),@FileCount)
		--   SET @FileName = @FileName+@processdate+'_'+@FileCount
	RETURN @FileName
	END 
	
	IF @FileName IS NULL
		SET @FileName=''
	RETURN @FileName
END

--SELECT * FROM PES_IBIFileCounter
GO
