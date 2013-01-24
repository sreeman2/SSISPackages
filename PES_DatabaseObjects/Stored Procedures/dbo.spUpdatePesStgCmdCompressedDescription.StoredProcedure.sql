/****** Object:  StoredProcedure [dbo].[spUpdatePesStgCmdCompressedDescription]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Global Trade	
-- Create date: 09/26/2011
-- Description:	Update PES_STG_CMD Compressed Description	
-- =============================================
CREATE PROCEDURE [dbo].[spUpdatePesStgCmdCompressedDescription]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Updating the entire table faster than the conditional statement below.
	UPDATE PES.dbo.PES_STG_CMD WITH (UPDLOCK)
	SET CompressedDescription = SCREEN_TEST.dbo.GET_KEY(CMD_DESC)
	WHERE CompressedDescription IS NULL;
	
--	UPDATE PES.dbo.PES_STG_CMD WITH (UPDLOCK)
--	SET CompressedDescription = SCREEN_TEST.dbo.GET_KEY(CMD_DESC)
--	SELECT C.CMD_DESC
--	FROM PES.dbo.PES_STG_BOL B (NOLOCK)
--	     INNER JOIN PES.dbo.PES_STG_CMD C ON C.CompressedDescription IS NULL AND B.BOL_ID = C.BOL_ID
--	WHERE B.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
--          AND B.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
--          AND ISNULL(C.IS_DELETE,'') <> 'Y'
--          AND ISNULL(B.IS_DELETED,'') <> 'Y'
END
GO
