/****** Object:  StoredProcedure [dbo].[INS_COMMODITY]    Script Date: 01/03/2013 19:47:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INS_COMMODITY](
      @inT_NBR      NUMERIC(10,0),
      @inCMD_SEQ_NBR NUMERIC(4,0),
      @inDQA_CMD_SEQ_NBR NUMERIC(12,0),
      @inPIECE_CNT NUMERIC(12,2),
      @inPIECE_UNIT VARCHAR(9),
      @inSHIPPER_N_NBR NUMERIC(10,0),
      @inCONSIGNEE_N_NBR NUMERIC(10,0),
      @inDQA_DESC VARCHAR(100),
      @inCMD_CD VARCHAR(10),
      @inJOC_CODE VARCHAR(7),
      @inCREATED_BY VARCHAR(10)
)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE
      @CONF NUMERIC,
      @HCS_FLAG VARCHAR(1);
BEGIN TRY
      IF (@inCMD_CD IS NULL OR @inJOC_CODE IS NULL)
            BEGIN
            SET @CONF = ' '
--            SET @HCS_FLAG = ' '
			SET @HCS_FLAG = 'N'
            END
      ELSE
            BEGIN
            SET @CONF = 7
--            SET @HCS_FLAG = 'Y'
			SET @HCS_FLAG = 'N'
            END
INSERT INTO DQA_CMDS (T_NBR, CMD_SEQ_NBR,DQA_CMD_SEQ_NBR, PIECE_CNT,PIECE_UNIT,
       SHIPPER_N_NBR, CONSIGNEE_N_NBR, DQA_DESC, CMD_CD, JOC_CODE,CREATED_BY, CREATED_DT, CONFIDENCE_FACTOR, HCS_PROCESSED)
SELECT @inT_NBR, @inCMD_SEQ_NBR,@inDQA_CMD_SEQ_NBR, @inPIECE_CNT, @inPIECE_UNIT,
       @inSHIPPER_N_NBR, @inCONSIGNEE_N_NBR, @inDQA_DESC,@inCMD_CD, @inJOC_CODE,@inCREATED_BY,getdate(), @CONF,
	   @HCS_FLAG
END TRY
BEGIN CATCH
      UPDATE DQA_CMDS SET
                  PIECE_CNT = @inPIECE_CNT,
                  PIECE_UNIT = @inPIECE_UNIT,
                  SHIPPER_N_NBR = @inSHIPPER_N_NBR,
                  CONSIGNEE_N_NBR = @inCONSIGNEE_N_NBR,
                  DQA_DESC = @inDQA_DESC,
                  CMD_CD = @inCMD_CD,
                  JOC_CODE = @inJOC_CODE,
                  CREATED_BY = @inCREATED_BY,
				  CREATED_DT = GETDATE(),
                  CONFIDENCE_FACTOR = @CONF,
                  HCS_PROCESSED = @HCS_FLAG
            WHERE
                  T_NBR = @inT_NBR AND CMD_SEQ_NBR = @inCMD_SEQ_NBR AND DQA_CMD_SEQ_NBR = @inDQA_CMD_SEQ_NBR 
      END CATCH

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
