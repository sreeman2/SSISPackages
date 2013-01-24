/****** Object:  UserDefinedFunction [dbo].[isvin]    Script Date: 01/08/2013 14:57:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[isvin] (
  @strin varchar(25)
)
--select colslist
--where dbo.isvin(vincol)='Y'
returns char(1)
as
begin
  declare @vin_len int,
      @vin_length int,
      @total int,
      @position smallint,
      @char_val int,
      @pos_val int,
      @cksum_val int,
      @vin_cksum_pos smallint,
      @check_val int,
      @char_check_val varchar(1);
  set @vin_length=17;
  set @vin_len=len(@strin);
  if (@vin_len <> @vin_length)
  begin
    RETURN ('N');
  end
  set @vin_cksum_pos=9;
  set @total=0;
  set @position=1;
  while @position<=17
  begin
    select @char_val=vinvalue from character_value_list
      where vinchar =substring(@strin,@position ,1);
    if (@char_val is null)
    begin
      return ('N');
    end;
    select @pos_val=weight from position_weight_list
      where pos = @position;
    set @total=@total+(@char_val*@pos_val);
    set @position=@position+1;
  end;
  set @cksum_val=@total%11;
  if (@cksum_val=10)
    begin
      if (substring(@strin,@vin_cksum_pos,1)='X')
      begin 
        return ('Y');
      end;
    end;
  else
  begin
    set @char_check_val=substring(@strin,@vin_cksum_pos,1);
    if (cast(@cksum_val as varchar)=@char_check_val)
    begin
      return ('Y');
    end;
  end;
  return 'N';
end
GO
