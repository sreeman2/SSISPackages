/****** Object:  UserDefinedFunction [dbo].[pes_udf_GetRawCommodityInfo]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[pes_udf_GetRawCommodityInfo]
(
	@BOL_ID int
)
RETURNS varchar(max)
AS
BEGIN
	declare @RawCmdInfo varchar(max)

	DECLARE @SequenceNo		int,
	@CommodityDesc	varchar(max)
	
	SELECT @RawCmdInfo =''

	DECLARE curRawCmd CURSOR FOR
	SELECT SequenceNo,Commodity_Desc
	FROM PES.DBO.ARCHIVE_RAW_CMD WITH (NOLOCK) 
	WHERE BOL_ID = @BOL_ID

	OPEN curRawCmd
	FETCH NEXT FROM curRawCmd INTO @SequenceNo,@CommodityDesc

	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT 	@RawCmdInfo = @RawCmdInfo +
		'DESCRIPTION: ' + isnull(@CommodityDesc,'') + '?'

	FETCH NEXT FROM curRawCmd INTO @SequenceNo,@CommodityDesc
	END		

	CLOSE curRawCmd
	DEALLOCATE curRawCmd

	RETURN @RawCmdInfo
END
GO
