/****** Object:  StoredProcedure [dbo].[S_Comp]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[S_Comp](@str1 varchar(20),@r varchar(100) out) as   
    declare @str2 varchar(100)     
 set @str2 ='welcome to sql server. Sql server is a product of Microsoft'     
 if(PATINDEX('%'+@str1 +'%',@str2)>0)        
  SELECT @r =  @str1+' present in the string'     
 else          SELECT @r = @str1+' not present'
GO
