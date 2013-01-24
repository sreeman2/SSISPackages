/****** Object:  StoredProcedure [dbo].[SAVE_SLINE_BILL_DATA_USP]    Script Date: 01/03/2013 19:48:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SAVE_SLINE_BILL_DATA_USP]
	@T_NBR AS NUMERIC(12,0)	,
	@SCAC_CD AS VARCHAR(4)	,
	@CARRIER_ID AS NUMERIC(12,0),	
	@DB_TYPE AS VARCHAR(10) = 'EXCEPTION'
AS
BEGIN
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	
IF ( @DB_TYPE = 'EXCEPTION' OR @DB_TYPE = 'CURRENT' )
BEGIN
	UPDATE dbo.[BL_BL] WITH (UPDLOCK) 
	SET CARRIER_ID = @CARRIER_ID , SCAC = @SCAC_CD 
	WHERE ( T_NBR = @T_NBR )
END
ELSE IF ( @DB_TYPE = 'ARCHIVE' )
BEGIN
	UPDATE PES_PURGE.dbo.[ARCHIVE_BL_BL] WITH (UPDLOCK) 
	SET CARRIER_ID = @CARRIER_ID , SCAC = @SCAC_CD 
	WHERE ( T_NBR = @T_NBR )
END
ELSE
BEGIN
	BEGIN TRY
		BEGIN TRAN
		IF EXISTS ( SELECT 1 FROM dbo.[BL_BL] WHERE ( T_NBR = @T_NBR ) ) 
		BEGIN
			UPDATE dbo.[BL_BL] WITH (UPDLOCK) 
			SET CARRIER_ID = @CARRIER_ID , SCAC = @SCAC_CD 
			WHERE ( T_NBR = @T_NBR )
		END

		IF EXISTS ( SELECT 1 FROM PES_PURGE.dbo.[ARCHIVE_BL_BL] WHERE ( T_NBR = @T_NBR ) ) 
		BEGIN	
			UPDATE PES_PURGE.dbo.[ARCHIVE_BL_BL] WITH (UPDLOCK) 
			SET CARRIER_ID = @CARRIER_ID , SCAC = @SCAC_CD 
			WHERE ( T_NBR = @T_NBR )
		END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
	END CATCH
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
