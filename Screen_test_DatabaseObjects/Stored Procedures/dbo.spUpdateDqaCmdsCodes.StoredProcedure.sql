/****** Object:  StoredProcedure [dbo].[spUpdateDqaCmdsCodes]    Script Date: 01/03/2013 19:48:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBM Global Trade
-- Create date: 19/06/2011
-- Description:	Auto Code Commodity Exception Records
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateDqaCmdsCodes]
AS
BEGIN

	DECLARE @rightNow datetime;
	SET @rightNow = GETDATE();
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION

		--Lock the records in dqa_bl so they can't be assigned to operations.
		UPDATE dbo.DQA_BL WITH (UPDLOCK) 
		SET LOCKED_BY_USR = 'Commodity_Auto_Coder'
		   ,LOCKED_BY_DATE = @rightNow 
		   ,EDIT_MODE = 'Auto_Coding'
	    --SELECT COUNT(*) --For testing.
		FROM SCREEN_TEST.dbo.CTRL_PROCESS_VOYAGE A (NOLOCK)
			 INNER JOIN SCREEN_TEST.dbo.DQA_CMDS B (NOLOCK) ON A.T_NBR = B.T_NBR AND A.CMD_SEQ_NBR = B.CMD_SEQ_NBR
			 INNER JOIN SCREEN_TEST.dbo.DQA_BL C ON B.T_NBR = C.T_NBR
			 INNER JOIN PES.dbo.PES_REF_COMMODITY_HSCODE_JOCCODE D (NOLOCK) ON B.COMPRESS_DESC = D.CompressedDescription
		WHERE A.PROCESS_NAME = 'COMMODITY STANDARDIZATION'
			  AND A.COMPLETE_STATUS <> 0
			  AND B.DQA_DESC NOT IN ('','DELETE','NO COMMODITY','88','U','.','/','8','Y','*','+',']')
			  AND ISNULL(B.IS_DELETE, 'N') <> 'Y'
			  AND C.LOCKED_BY_USR IS NULL
			  AND C.LOCKED_BY_DATE IS NULL
			  AND C.EDIT_MODE IS NULL
			  AND (B.CMD_CD <> D.HSCode OR B.JOC_CODE <> D.JocCode OR ISNULL(B.CMD_CD,'') = '' OR ISNULL(B.JOC_CODE,'') = '')
			  IF @@ERROR != 0
				  BEGIN
					ROLLBACK TRANSACTION
					RETURN
				  END
			  ELSE
		--Update dqa_cmds with the new codes.
		UPDATE DQA_CMDS WITH (UPDLOCK) 
		SET CMD_CD = D.HSCode
		   ,JOC_CODE = D.JocCode
		   ,MODIFIED_DT = @rightNow
		   ,MODIFIED_BY = 'Commodity_Auto_Coder' 
		FROM SCREEN_TEST.dbo.CTRL_PROCESS_VOYAGE A (NOLOCK)
			 INNER JOIN SCREEN_TEST.dbo.DQA_CMDS B ON A.T_NBR = B.T_NBR AND A.CMD_SEQ_NBR = B.CMD_SEQ_NBR
			 INNER JOIN SCREEN_TEST.dbo.DQA_BL C (NOLOCK) ON B.T_NBR = C.T_NBR
			 INNER JOIN PES.dbo.PES_REF_COMMODITY_HSCODE_JOCCODE D (NOLOCK) ON B.COMPRESS_DESC = D.CompressedDescription
		WHERE C.LOCKED_BY_USR = 'Commodity_Auto_Coder'
			  AND C.EDIT_MODE = 'Auto_Coding'
		      IF @@ERROR != 0
				  BEGIN
					ROLLBACK TRANSACTION
					RETURN
				  END
			  ELSE
		--Update ctrl_process_voyage to complete the records.
		UPDATE CTRL_PROCESS_VOYAGE WITH (UPDLOCK) 
		SET  COMPLETE_STATUS = 0
			,LOCKED = 0
			,OWNER_ID = 'Commodity_Auto_Coder'
			,MODIFIED_DT = @rightNow  
		FROM SCREEN_TEST.dbo.CTRL_PROCESS_VOYAGE A
			 INNER JOIN SCREEN_TEST.dbo.DQA_CMDS B (NOLOCK) ON A.T_NBR = B.T_NBR AND A.CMD_SEQ_NBR = B.CMD_SEQ_NBR
			 INNER JOIN SCREEN_TEST.dbo.DQA_BL C (NOLOCK) ON B.T_NBR = C.T_NBR
			 INNER JOIN PES.dbo.PES_REF_COMMODITY_HSCODE_JOCCODE D (NOLOCK) ON B.COMPRESS_DESC = D.CompressedDescription
		WHERE C.LOCKED_BY_USR = 'Commodity_Auto_Coder'
			  AND C.EDIT_MODE = 'Auto_Coding'
			  IF @@ERROR != 0
				  BEGIN
					ROLLBACK TRANSACTION
					RETURN
				  END
			  ELSE
		--Unlock the records in dqa_bl.
		UPDATE DQA_BL WITH (UPDLOCK) 
		SET LOCKED_BY_USR=NULL
		   ,LOCKED_BY_DATE=NULL
		   ,EDIT_MODE=NULL  
		WHERE LOCKED_BY_USR = 'Commodity_Auto_Coder'
			  AND EDIT_MODE = 'Auto_Coding'
			  IF @@ERROR != 0
				  BEGIN
					ROLLBACK TRANSACTION
					RETURN
				  END
			  ELSE
			  
	COMMIT TRANSACTION
END
GO
