/****** Object:  UserDefinedFunction [dbo].[pes_udf_GetHazmatClass]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[pes_udf_GetHazmatClass](@BOL_ID int)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @ClassStr varchar(200)
	DECLARE @Class varchar(4)

	DECLARE @HzmtCnt int

	SELECT @HzmtCnt=0

	SELECT @HzmtCnt = COUNT(*) FROM PES.DBO.ARCHIVE_RAW_HZMT WITH (NOLOCK) WHERE BOL_ID = @BOL_ID
	
	IF @HzmtCnt > 0
	BEGIN

		SELECT @ClassStr=''

		DECLARE curBOL CURSOR FOR
		SELECT RTRIM(Class) FROM PES.DBO.ARCHIVE_RAW_HZMT WITH (NOLOCK)
		WHERE BOL_ID = @BOL_ID

		OPEN  curBOL
		FETCH NEXT FROM curBOL INTO @Class

		WHILE @@FETCH_STATUS=0
		BEGIN
			
			if isnull(@Class,'') <> ''
			begin
				SELECT @ClassStr=@ClassStr+' '+@Class
			end	

		FETCH NEXT FROM curBOL INTO @Class
		END

		CLOSE curBOL
		DEALLOCATE curBOL
	END
	ELSE
		SELECT @ClassStr=''

	RETURN @ClassStr
END
GO
