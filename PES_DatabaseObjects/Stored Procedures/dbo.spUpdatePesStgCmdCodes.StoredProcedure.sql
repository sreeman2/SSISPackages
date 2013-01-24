/****** Object:  StoredProcedure [dbo].[spUpdatePesStgCmdCodes]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Global Trade	
-- Create date: 09/26/2011
-- Description:	Update PES_STG_CMD Codes
-- =============================================
CREATE PROCEDURE [dbo].[spUpdatePesStgCmdCodes]
AS
BEGIN

	DECLARE @UpdateDateTime DATETIME;
	SET @UpdateDateTime = GETDATE();

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRANSACTION

		UPDATE PES.dbo.PES_STG_CMD WITH (UPDLOCK)
		SET CMD_HSCODE = A.HSCode,
			CMD_CD = A.JocCode,
			MODIFY_USER = 'Commodity_Auto_Coder',
			MODIFY_DATE = @UpdateDateTime
		FROM PES.dbo.PES_REF_COMMODITY_HSCODE_JOCCODE A (NOLOCK)
			 INNER JOIN PES.dbo.PES_STG_CMD B ON A.Processed = 0 AND A.CompressedDescription = b.CompressedDescription
			 INNER JOIN PES.dbo.PES_STG_BOL C (NOLOCK) ON B.BOL_ID = C.BOL_ID
		WHERE (CMD_HSCODE <> A.HSCode OR CMD_CD <> A.JocCode)
			  AND C.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
			  AND C.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
			  AND ISNULL(B.IS_DELETE,'') <> 'Y'
			  AND ISNULL(C.IS_DELETED,'') <> 'Y';
			  IF @@ERROR != 0
				  BEGIN
					ROLLBACK TRANSACTION
					RETURN
				  END
			  ELSE

		UPDATE PES.dbo.PES_STG_BOL WITH (UPDLOCK)
		SET MODIFY_DATE = @UpdateDateTime
		FROM PES.dbo.PES_STG_CMD A (NOLOCK)
			 INNER JOIN PES.dbo.PES_STG_BOL B ON A.MODIFY_DATE = @UpdateDateTime AND A.BOL_ID = B.BOL_ID
		WHERE A.MODIFY_USER = 'Commodity_Auto_Coder'
			  AND B.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
			  AND B.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
			  AND ISNULL(B.IS_DELETED,'') <> 'Y';
			  IF @@ERROR != 0
				  BEGIN
					ROLLBACK TRANSACTION
					RETURN
				  END
			  ELSE

	COMMIT TRANSACTION

END
GO
