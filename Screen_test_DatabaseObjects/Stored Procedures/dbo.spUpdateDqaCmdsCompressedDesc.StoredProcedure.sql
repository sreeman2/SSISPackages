/****** Object:  StoredProcedure [dbo].[spUpdateDqaCmdsCompressedDesc]    Script Date: 01/03/2013 19:48:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Global Trade
-- Create date: 09/28/2011
-- Description:	Update DQA_CMDS Compressed_Desc
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateDqaCmdsCompressedDesc]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE TOP (100000) SCREEN_TEST.dbo.DQA_CMDS WITH (UPDLOCK)
	SET COMPRESS_DESC = SCREEN_TEST.dbo.GET_KEY(DQA_DESC)
	FROM SCREEN_TEST.dbo.DQA_CMDS A 
		 INNER JOIN SCREEN_TEST.dbo.DQA_BL B (NOLOCK) ON A.T_NBR = B.T_NBR
	WHERE A.COMPRESS_DESC IS NULL
          AND B.LOCKED_BY_USR IS NULL
          AND B.LOCKED_BY_DATE IS NULL
          AND B.EDIT_MODE IS NULL
	
END
GO
