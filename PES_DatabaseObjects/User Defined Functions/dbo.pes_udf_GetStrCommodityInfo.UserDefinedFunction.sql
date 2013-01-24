/****** Object:  UserDefinedFunction [dbo].[pes_udf_GetStrCommodityInfo]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[pes_udf_GetStrCommodityInfo]
(
	@BOL_ID int
)
RETURNS varchar(max)
AS
BEGIN
	declare @StrCmdInfo varchar(max)

	DECLARE @SequenceNo		int,
	@DQASequenceNo		int,
	@CommodityDesc	varchar(max),
	@HarmCode		varchar(10),
	@JOCCode		varchar(10),
	@UserName		varchar(25)

	
	SELECT @StrCmdInfo =''

	DECLARE curStrCmd CURSOR FOR
	SELECT CMD_SEQ_NBR,DQA_CMD_SEQ_NBR,DQA_DESC,CMD_CD,JOC_CODE,CREATED_BY
	FROM SCREEN_TEST.DBO.DQA_CMDS WITH (NOLOCK) 
	WHERE T_NBR = @BOL_ID

	OPEN curStrCmd
	FETCH NEXT FROM curStrCmd INTO @SequenceNo,@DQASequenceNo,@CommodityDesc,@HarmCode,@JOCCode,@UserName

	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT 	@StrCmdInfo = @StrCmdInfo +
		'DESCRIPTION: ' + isnull(@CommodityDesc,'')+ '?'+
		'HARM CODE: ' + isnull(@HarmCode,'')+ '?'+
		'JOC CODE: ' + isnull(@JOCCode,'')+ '?'+
		'STRUCTURED BY: ' + isnull(@UserName,'') + '?'

	FETCH NEXT FROM curStrCmd INTO @SequenceNo,@DQASequenceNo,@CommodityDesc,@HarmCode,@JOCCode,@UserName
	END		

	CLOSE curStrCmd
	DEALLOCATE curStrCmd

	RETURN @StrCmdInfo
END
GO
