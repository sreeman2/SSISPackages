/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 01/03/2013 19:53:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split]
( @Delimiter varchar(5),@List varchar(8000))
	RETURNS @TableOfValues table ( RowID smallint IDENTITY(1,1),[Value] varchar(50))
AS
BEGIN

DECLARE @LenString int

WHILE len( @List ) > 0
BEGIN

SELECT @LenString =
(CASE charindex( @Delimiter, @List )
WHEN 0 THEN len( @List )
ELSE ( charindex( @Delimiter, @List ) -1 )
END
)

INSERT INTO @TableOfValues
SELECT substring( @List, 1, @LenString )

SELECT @List =
(CASE ( len( @List ) - @LenString )
WHEN 0 THEN ''
ELSE right( @List, len( @List ) - @LenString - 1 )
END
)
END

RETURN

END
GO
