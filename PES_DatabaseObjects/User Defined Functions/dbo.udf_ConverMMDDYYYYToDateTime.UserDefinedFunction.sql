/****** Object:  UserDefinedFunction [dbo].[udf_ConverMMDDYYYYToDateTime]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_ConverMMDDYYYYToDateTime](
	@string VARCHAR(8)
)
RETURNS DATETIME
AS
BEGIN   
DECLARE @date datetime
SET @date = CONVERT(datetime, '19000101');

IF (LEN(@string) = 8)
BEGIN
	IF(ISNUMERIC(@string) = 1)
	BEGIN
		IF(ISDATE(RIGHT(@String,4)+LEFT(@String,2)+SUBSTRING(@String,3,2)) = 1)
		BEGIN
			SET @date = CONVERT(datetime,RIGHT(@String,4)+LEFT(@String,2)+SUBSTRING(@String,3,2))
		END
	END
END


RETURN(@date)
END
GO
