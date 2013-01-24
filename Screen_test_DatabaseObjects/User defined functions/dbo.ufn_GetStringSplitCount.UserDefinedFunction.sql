/****** Object:  UserDefinedFunction [dbo].[ufn_GetStringSplitCount]    Script Date: 01/03/2013 19:53:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetStringSplitCount](@stringValue as varchar(8000),@splitCharacter as char(1))
returns int
as
begin
   declare @Ret int;
   declare @i int;
   declare @c char(1);

   select @i=1;
   select @Ret = case when @stringValue is null then 0 else 1 end;
   
   while (@i <= len(@stringValue))
   	select @c= substring(@stringValue,@i,1),
               @Ret = @Ret + case when @c = @SplitCharacter then 1 else 0 end,
               @i = @i +1

   return @Ret
end
GO
