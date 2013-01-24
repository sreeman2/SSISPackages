/****** Object:  UserDefinedFunction [dbo].[getShort]    Script Date: 01/03/2013 19:53:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[getShort] (@tnbr  INT, @cmdseq  INT)
RETURNS varchar(8000) AS
BEGIN
DECLARE  @cmdsDesc      VARCHAR(8000);
DECLARE  @retDesc      VARCHAR(8000);
DECLARE  @cleancmdsDesc     VARCHAR(8000);
DECLARE SHORTDESC CURSOR FOR  SELECT enh_desc FROM PES.DBO.HCS_COMMODITY WHERE  BOL_ID = @tnbr AND cmd_seq_nbr = @cmdseq 
OPEN SHORTDESC
FETCH NEXT FROM SHORTDESC INTO  @cmdsDesc
WHILE @@FETCH_STATUS = 0
BEGIN

  
   SET  @cleanCmdsDesc = LTRIM(RTRIM(REPLACE(@cmdsDesc,'"','')));
     SET @cleanCmdsdesc = REPLACE(REPLACE(REPLACE(@cleanCmdsdesc,CHAR(1),' '),CHAR(2),' '),CHAR(3),' ');
     SELECT @retDesc=DBO.short_desc(@cleanCmdsdesc)

--  IF (@retDesc is not null)
--           BREAK
      
 FETCH NEXT FROM SHORTDESC INTO  @cmdsDesc
END
CLOSE SHORTDESC
DEALLOCATE SHORTDESC
return (@retDesc)
end
GO
