/****** Object:  StoredProcedure [dbo].[PES_VIN_UPDATE_ACCEPT_STATUS]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <6TH AUGUST 2009>
-- Description:	<Updating the status ACCEPT/REJECT for the VIN Exceptions>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_UPDATE_ACCEPT_STATUS]
	-- Add the parameters for the stored procedure here
	@ACCEPT_IDS VARCHAR(MAX)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	BEGIN TRANSACTION
		INSERT INTO PES.DBO.PES_STG_VIN 
			(BL_NBR,
			VIN,
			T_NBR,
			MAN_SEQ_NBR,
			CMD_SEQ_NBR,
			DB_LOAD_NBR,
			RUN_SEQ_NBR,
			INSERT_DT)
			SELECT
				BL_NBR,
				VIN,
				T_NBR,
				MAN_SEQ_NBR,
				CMD_SEQ_NBR,
				DB_LOAD_NBR,
				RUN_SEQ_NBR,
				INSERT_DT
			FROM SCREEN_TEST.DBO.VIN_CACHE 
				WHERE ID IN (SELECT * FROM PES.DBO.SPLIT(@ACCEPT_IDS,','))
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK
				RETURN
			END

		UPDATE SCREEN_TEST.DBO.VIN_CACHE SET STATUS='ACCEPT', OWNER='QA'
			WHERE ID IN (SELECT * FROM PES.DBO.SPLIT(@ACCEPT_IDS,','))
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK
				RETURN
			END
	COMMIT

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
