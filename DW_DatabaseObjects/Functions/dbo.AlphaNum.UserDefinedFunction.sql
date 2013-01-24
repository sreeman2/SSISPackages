USE [PESDW]
GO
/****** Object:  UserDefinedFunction [dbo].[AlphaNum]    Script Date: 01/08/2013 14:57:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [dbo].[AlphaNum](@Temp VarChar(1000))
Returns VarChar(1000)
AS
Begin

    While PatIndex('%[^a-z]%', @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex('%[^a-z]%', @Temp), 1, '')

    Return @Temp
End
GO
