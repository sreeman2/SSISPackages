USE [PES]
GO
/****** Object:  UserDefinedFunction [dbo].[ExtractHarmCodes]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[ExtractHarmCodes](@BOLId int,@CommodityId int,@Commodity_Desc nvarchar(max))
returns @HarmCodes table
(
	BolID	int,
	CommodityId int,
	HarmCode varchar(6)
)
as
begin

	declare @iPosition int
	declare @char varchar(1)

	declare @harmcode varchar(6)

	declare @iLength int

	select @iLength = LEN(@Commodity_Desc)
	SELECT @iPosition=1
	select @harmcode=''

	WHILE @iPosition <= @iLength
	BEGIN		
		select @char=substring(@Commodity_Desc,@iPosition,1)

		if PATINDEX('%[0-9]%', @char) =1
		begin
			select @harmcode=@harmcode+@char

			if len(@harmcode) = 6
			begin
					
				if not exists(select HarmCode from @HarmCodes where harmcode=@harmcode)
				begin
					insert into @HarmCodes(BolID,CommodityId,HarmCode)
					select @BOLId,@CommodityId, @harmcode
				end

				select @harmcode=''
			end
		end
		else
		begin
			select @harmcode=''
		end
		select @iPosition=@iPosition+1

	END	

	RETURN
END



--select * from dbo.ExtractHarmCodes('34e343434frtrtre45454')
GO
