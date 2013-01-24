/****** Object:  StoredProcedure [dbo].[USP_PES_ResetMaxWeight]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_PES_ResetMaxWeight]
(
	@iLOADNUMBER AS INT = NULL 
)
AS
BEGIN
/*
	Set maximum weight for non-containerized bills

	Parameters:
	@iLOADNUMBER INT - e.g. 12318018. If NULL, it default value as current processed load number

	Input: PES.dbo.PES_STG_BOL, PES.DBO.PES_PROGRESS_STATUS, [10.31.18.147].[Shipdata].[dbo].[Vessel]
	Final Output: PES.dbo.PES_STG_BOL, SCREEN_TEST.DBO.CTRL_PROCESS_VOYAGE

	1. Get non containerized BOLs
	2. Set BOL_WGT = Vessel_Capacity WHERE BOL weight greater than actual vessel capacity
	3. The vessel capacity number is in metric tons.  To convert to pounds we need to multiply times 2204.62.
		e.g. 1 metric ton = 2204.62 pounds 
	4. Insert maximum NC weight exception records into screen test exception table

	Usage: EXEC [PES].[dbo].[USP_PES_ResetMaxWeight] @iLOADNUMBER = '12318018'
	Usage: EXEC [PES].[dbo].[USP_PES_ResetMaxWeight]
*/
SET NOCOUNT ON

BEGIN TRY
BEGIN TRAN

	DECLARE @ERRORSTATUS AS VARCHAR(MAX)
	DECLARE @MailSubject  VARCHAR(100)
	DECLARE @NEWLINE CHAR(2)

	IF @iLOADNUMBER IS NULL
	BEGIN
		SELECT TOP 1 @iLOADNUMBER = LOADNUMBER FROM PES.DBO.PES_PROGRESS_STATUS WITH (NOLOCK)
		ORDER BY LOAD_DT DESC
	END

	SELECT 
		PSB.BOL_ID, 
		PSB.BOL_DIRECTION,
		PSB.BOL_WGT, 
		CONVERT(NUMERIC,REPLACE(LTRIM(RTRIM(SV.Vessel_Capacity)),',',''))*2204.62 AS VESSEL_CAPACITY
	INTO #Temp_ResetMaxWeight
	FROM PES.DBO.PES_STG_BOL PSB WITH (NOLOCK)
		INNER JOIN [PES].[dbo].[Vessel] SV WITH (NOLOCK) ON
			LTRIM(RTRIM(PSB.VESSEL_NAME)) = SV.VESSEL_NAME
	WHERE PSB.REF_LOAD_NUM_ID = @iLOADNUMBER 
		AND PSB.BOL_CNTRZD_FLG = 'N'
		AND PSB.BOL_WGT > CONVERT(NUMERIC,REPLACE(LTRIM(RTRIM(SV.Vessel_Capacity)),',',''))*2204.62
		AND LTRIM(RTRIM(ISNULL(SV.Vessel_Capacity,''))) NOT IN ('','N/A')

	CREATE NONCLUSTERED INDEX IDX_Temp_ResetMaxWeight ON #Temp_ResetMaxWeight(BOL_ID)

	UPDATE PSB 
		SET PSB.BOL_WGT = FLOOR(TRSMW.VESSEL_CAPACITY),
			PSB.MODIFY_USER = 'dwh'
	FROM PES.DBO.PES_STG_BOL PSB  WITH (NOLOCK) 
		INNER JOIN #Temp_ResetMaxWeight TRSMW  WITH (NOLOCK) ON
			PSB.BOL_ID = TRSMW.BOL_ID 

	INSERT INTO SCREEN_TEST.DBO.CTRL_PROCESS_VOYAGE (T_NBR, DIR, PROCESS_NAME, MODIFIED_DT, COMPLETE_STATUS)  
	SELECT DISTINCT 
		BOL_ID, 
		BOL_DIRECTION, 
		'Maximum NC Weight Exception', 
		GETDATE(),
		'1' 
	FROM #Temp_ResetMaxWeight

	DROP TABLE #Temp_ResetMaxWeight

END TRY
BEGIN CATCH

	ROLLBACK TRAN
	
	SET @ERRORSTATUS='STORED PROCEDURE USP_PES_ResetMaxWeight FAILED AT LINE NUMBER:  ' + LTRIM(RTRIM(STR(ERROR_LINE()))) + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
	SET @MailSubject = 'PES Reset Max Weight failed' +' - Load Number: ' + CONVERT(VARCHAR(25), @iLOADNUMBER)

	SET @NEWLINE = CHAR(13) + CHAR(10)	
	SET @ERRORSTATUS = @NEWLINE + @ERRORSTATUS + @NEWLINE
	
	DECLARE @SendEmailOutput varchar(MAX), @SendEmailSuccess bit
	EXEC PES.dbo.usp_SendEmail
	  @To		= 'gmurugiah@joc.com'
	 ,@From		= 'PIERS-NoReply@piers.com'
	 ,@Subject	= @MailSubject 
	 ,@Body		= @ERRORSTATUS
	 ,@Success	= @SendEmailSuccess OUT
	 ,@Output	= @SendEmailOutput OUT

	--SELECT @SendEmailSuccess, @SendEmailOutput
	--RAISERROR (@ERRORSTATUS, 16, 1 );

	RETURN 
END CATCH

COMMIT TRAN
END
GO
