USE [PiersTILoad]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ReversePATINDEX]    Script Date: 01/09/2013 18:57:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_ReversePATINDEX] (
@pattern VARCHAR(25),
@str VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
	DECLARE @rtn INT

	SELECT @rtn =
		CASE
			WHEN PATINDEX(@Pattern,@str) > 0
				THEN LEN(@str) - ((PATINDEX(REVERSE(@pattern),REVERSE(@str))) + LEN(@Pattern)-3)
			ELSE 0
		END

	RETURN @rtn
END
GO
