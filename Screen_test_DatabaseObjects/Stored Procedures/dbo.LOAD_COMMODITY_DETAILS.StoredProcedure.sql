/****** Object:  StoredProcedure [dbo].[LOAD_COMMODITY_DETAILS]    Script Date: 01/03/2013 19:47:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pramod BN
-- Create date: 24-JAN-2009
-- Description:	GET BILL COMMODITY DETAILS
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_COMMODITY_DETAILS] 
	-- Add the parameters for the stored procedure here
	@TNBR int, 
	@EXCEPTIONTYPE VARCHAR(50)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

---- 09/20/2010
---- Log Start Time
--DECLARE @IdLogOut INT
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@TNBR='''+ CAST(@TNBR AS VARCHAR(100)) +''''
--+',@EXCEPTIONTYPE='''+ @EXCEPTIONTYPE +''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'LOAD_COMMODITY_DETAILS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@TNBR='''+ CAST(@TNBR AS VARCHAR(100)) +''''
+',@EXCEPTIONTYPE='''+ @EXCEPTIONTYPE +''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


    SELECT DISTINCT 
			D.T_NBR, 
			D.DQA_CMD_SEQ_NBR, 
			D.PIECE_CNT, 
			RTRIM(LTRIM(D.PIECE_UNIT)) AS PIECE_UNIT, 
			D.FINAL_DEST_CITY, 
			D.FINAL_DEST_STATE, 
			D.FINAL_DEST_CNTRY_CD, 
			D.PIERS_PORT_ORIGIN_CD, 
			D.SHIPPER_N_NBR, D.CONSIGNEE_N_NBR, D.NOTIFY_N_NBR, 
			D.PIERS_PORT_ORIGIN_NAME, 
			ISNULL((CASE D .DQA_DESC_MOD WHEN ' ' THEN NULL ELSE D .DQA_DESC_MOD END), D.DQA_DESC) AS DQA_DESC, 
			D.CREATED_BY, 
			D.CREATED_DT, 
			D.MODIFIED_BY, 
			D.MODIFIED_DT, 
			D.HCS_PROCESSED, 
			ISNULL((CASE D .CMD_CD_MOD WHEN ' ' THEN NULL ELSE D .CMD_CD_MOD END), D.CMD_CD) AS CMD_CD, D.CONFIDENCE_FACTOR, 
			D.TEU, 
			COALESCE(D.WEIGHT, 0) AS WEIGHT, 
			D.EST_VALUE, ISNULL((CASE D .JOC_CODE_MOD WHEN ' ' THEN NULL ELSE D .JOC_CODE_MOD END), D.JOC_CODE) AS JOC_CODE, 
			D.RECNUM, 
			D.DQA_COMPRESS_DESC, D.COMPRESS_DESC, D.EDIT_MODE, D.EXCP_EDIT, 
			CASE WHEN (A.process_name = UPPER(@EXCEPTIONTYPE) AND A.complete_status = 1) THEN 1 ELSE 0 END AS EDITABLE, 
			ISNULL(A.PROCESS_NAME, 'VALID DATA') AS PROCESSNAME, D.CMD_ID , 
			ISNULL(D.IS_DELETE,'N') AS IS_DELETE
FROM         DQA_CMDS AS D WITH (NOLOCK) LEFT OUTER JOIN
                      CTRL_PROCESS_VOYAGE AS A WITH (NOLOCK) ON D.T_NBR = A.T_NBR AND D.CMD_SEQ_NBR = A.CMD_SEQ_NBR
WHERE     (D.T_NBR = @TNBR)

-- 09/20/2010
-- Log End Time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd 
 @Id = @IdLogOut, @RowsAffected = @@ROWCOUNT

END
GO
