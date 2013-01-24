/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 01/03/2013 19:42:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 6-Aug-2009
-- Description:	Split a comma-separated list of values into a table variable
-- =============================================
CREATE FUNCTION [dbo].[Split]
(
	@List	nvarchar(max),
	@Separator	char(1)
)
RETURNS @RtnValue TABLE
(
	Value varchar(64)
)
AS
BEGIN
	WHILE (CHARINDEX(@SEPARATOR,@LIST)>0)
	BEGIN 

		INSERT INTO @RTNVALUE (VALUE)

		SELECT VALUE = LTRIM(RTRIM(SUBSTRING(@LIST,1,CHARINDEX(@SEPARATOR,@LIST)-1)))  
		SET @LIST = SUBSTRING(@LIST,CHARINDEX(@SEPARATOR,@LIST)+LEN(@SEPARATOR),LEN(@LIST))

	END

	INSERT INTO @RTNVALUE (VALUE)

    SELECT VALUE = LTRIM(RTRIM(@LIST))

	RETURN 
END
GO
