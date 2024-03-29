/****** Object:  StoredProcedure [dbo].[UPDATE_VESSEL_VOYAGE_DETAILS]    Script Date: 01/03/2013 19:48:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <11th NOV 2010>
-- Description:	<UPDATING THE DQA_VOYAGE TABLE WITH VESSEL VOYAGE DETAILS>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_VESSEL_VOYAGE_DETAILS] 
	-- Add the parameters for the stored procedure here
	@ACT_MANIFEST_NBR CHAR(6),
	@VOYAGE_STATUS VARCHAR(10),
	@ACT_ARRIVAL_DT DATETIME,
	@REMARKS VARCHAR(100),
	@MODIFIED_BY VARCHAR(25),
	@PORT_UNLADING_CD char(4),
	@USPORT_ID NUMERIC,
	@US_PORTNAME VARCHAR(35),
	@VESSEL_NAME CHAR(35),
	@VESSEL_ID NUMERIC,
	@VESSEL_CD CHAR(7),
	@VOYAGE_NBR CHAR(5),
	@SCAC CHAR(4),
	@CARRIER_ID NUMERIC,
	@GLOBAL_UPDATE TINYINT,
	@VOYAGE_ID VARCHAR(MAX)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE DQA_VOYAGE WITH (UPDLOCK) 
		SET ACT_MANIFEST_NBR = @ACT_MANIFEST_NBR,
			VOYAGE_STATUS = @VOYAGE_STATUS,
			ACT_ARRIVAL_DT = convert(varchar(11),@ACT_ARRIVAL_DT,101),
			REMARKS = @REMARKS,
			MODIFIED_BY = @MODIFIED_BY,
			MODIFIED_DT = GETDATE(),
			PORT_UNLADING_CD = @PORT_UNLADING_CD,
			PORT_UNLADING_CD_MOD = @PORT_UNLADING_CD,
			USPORT_ID = @USPORT_ID,
			US_PORTNAME = @US_PORTNAME,
			VESSEL_NAME = @VESSEL_NAME,
			VESSEL_NAME_MOD = @VESSEL_NAME,
			VESSEL_ID = @VESSEL_ID,
			VESSEL_CD = @VESSEL_CD,
			VOYAGE_NBR = @VOYAGE_NBR,
			VOYAGE_NBR_MOD = @VOYAGE_NBR,
			SCAC = @SCAC,
			CARRIER_ID = @CARRIER_ID,
			GLOBAL_UPDATE = CASE WHEN GLOBAL_UPDATE= 2 THEN 2 ELSE 2 END 
	WHERE VOYAGE_ID IN (SELECT [VALUE] FROM PES.DBO.[SPLIT](@VOYAGE_ID,','))

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
