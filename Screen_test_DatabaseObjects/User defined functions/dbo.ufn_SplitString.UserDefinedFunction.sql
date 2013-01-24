/****** Object:  UserDefinedFunction [dbo].[ufn_SplitString]    Script Date: 01/03/2013 19:53:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--AA
--25/10/2007
--Use it to split strings like -
--	SELECT * FROM dbo.ufn_SplitString('one,two,three,four,five,six,seven,eight,nine,ten',',') 
--	or
--	SELECT * FROM dbo.ufn_SplitString('Monday--Tuesday--Wednesday--thursday--friday--saturday--sunday','--') 
CREATE FUNCTION [dbo].[ufn_SplitString]
(
	@String VARCHAR(MAX),
	@Delimiter VARCHAR(255)
)
RETURNS
	@Results TABLE
(
	SeqNo INT IDENTITY(1, 1),
	Item VARCHAR(8000)
)
AS
BEGIN
	INSERT INTO @Results (Item)
	SELECT SUBSTRING(@String+@Delimiter, number,
		CHARINDEX(@Delimiter, @String+@Delimiter, number) - number)
	FROM Numbers
	WHERE number <= LEN(REPLACE(@String,' ','|'))
	AND SUBSTRING(@Delimiter + @String,
				number,
				LEN(REPLACE(@delimiter,' ','|'))) = @Delimiter
	ORDER BY number RETURN
END
GO
