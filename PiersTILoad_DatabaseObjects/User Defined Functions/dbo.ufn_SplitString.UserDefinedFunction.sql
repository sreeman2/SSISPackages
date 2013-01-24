/****** Object:  UserDefinedFunction [dbo].[ufn_SplitString]    Script Date: 01/09/2013 18:57:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[aa] - 09/01/2010
--Use it to split strings like -
--	SELECT * FROM dbo.ufn_SplitString('one,two,three,four,five,six,seven,eight,nine,ten',',') 
--	or
--	SELECT * FROM dbo.ufn_SplitString('Monday--Tuesday--Wednesday--thursday--friday--saturday--sunday','--') 
CREATE FUNCTION [dbo].[ufn_SplitString]
(
	@String VARCHAR(8000),
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
