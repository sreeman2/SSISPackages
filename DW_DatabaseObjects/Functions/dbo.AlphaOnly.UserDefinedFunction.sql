/****** Object:  UserDefinedFunction [dbo].[AlphaOnly]    Script Date: 01/08/2013 14:57:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[AlphaOnly](@string varchar(max))

returns varchar(max)

begin

   While PatIndex('%[^a-z]%', @string) > 0

        Set @string = Stuff(@string, PatIndex('%[^a-z]%', @string), 1, '')

return @string

end
GO
