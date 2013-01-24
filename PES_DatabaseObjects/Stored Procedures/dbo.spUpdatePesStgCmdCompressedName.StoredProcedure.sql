/****** Object:  StoredProcedure [dbo].[spUpdatePesStgCmdCompressedName]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Global Trade
-- Create date: 09/28/2011
-- Description:	Update PES_STG_CMD	CompressedName
-- =============================================
CREATE PROCEDURE [dbo].[spUpdatePesStgCmdCompressedName]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE TOP (100000) PES.dbo.PES_STG_CMD WITH (UPDLOCK)
	SET CompressedDescription = SCREEN_TEST.dbo.GET_KEY(CMD_DESC)
	WHERE CompressedDescription IS NULL;
	
END
GO
