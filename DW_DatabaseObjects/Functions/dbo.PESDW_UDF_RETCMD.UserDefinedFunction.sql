/****** Object:  UserDefinedFunction [dbo].[PESDW_UDF_RETCMD]    Script Date: 01/08/2013 14:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PESDW_UDF_RETCMD](@BOL_ID INT)
RETURNS VARCHAR(255)
AS
BEGIN

DECLARE @Commodity VARCHAR(255)
DECLARE @FullCommodity VARCHAR(MAX)
DECLARE @Value VARCHAR(MAX)

SELECT @Value=''
SELECT @Commodity=''
SELECT @FullCommodity=''

DECLARE curCommodity CURSOR FOR
SELECT CMD_DESC FROM PES_DW_CMD WITH (NOLOCK)
WHERE BOL_ID=@BOL_ID

OPEN curCommodity
FETCH NEXT FROM curCommodity INTO @Value

WHILE @@FETCH_STATUS=0
BEGIN	
	SELECT @FullCommodity = @Value + SPACE(1) 
FETCH NEXT FROM curCommodity INTO @Value
END

CLOSE curCommodity
DEALLOCATE curCommodity

SELECT @Commodity=LEFT(@FullCommodity,255)

RETURN @Commodity

END
GO
