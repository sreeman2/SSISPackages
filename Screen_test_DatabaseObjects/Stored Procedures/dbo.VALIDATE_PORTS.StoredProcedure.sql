/****** Object:  StoredProcedure [dbo].[VALIDATE_PORTS]    Script Date: 01/03/2013 19:48:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Cognizant Technology Solutions>
-- Create date: <13th May 2010>
-- Description:	<Procedure to validate the Ports - UltPort, Foreign Port or Receipt City>
-- =============================================

CREATE PROCEDURE [dbo].[VALIDATE_PORTS]
	-- Add the parameters for the stored procedure here
	@PortId int, 
	@PortType varchar(max),
	@RETURN_VALUE INT OUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @STR_PORT_TYPE VARCHAR(MAX)
	--DECLARE @PORT_SLINE_EXISTS BIT
	SET @STR_PORT_TYPE = @PortType

	DECLARE @STR_SLINE_REF_ID VARCHAR(MAX)

	--STEP 1 - FETCH THE SLINE_REF_ID FROM THE PES_STG_BOL TABLE
	SELECT @STR_SLINE_REF_ID = 
	(CASE @STR_PORT_TYPE
		WHEN 'FPORT_ID' THEN
			(SELECT TOP 1 SLINE_REF_ID FROM PES.DBO.PES_STG_BOL WITH (NOLOCK) WHERE PORT_ARRIVE_REF_ID = @PortId)
		WHEN 'ULTPORT_ID' THEN 
			(SELECT TOP 1 SLINE_REF_ID FROM PES.DBO.PES_STG_BOL WITH (NOLOCK) WHERE ULTPORT_ID = @PortId)
		WHEN 'RCPT_ID' THEN
			(SELECT TOP 1 SLINE_REF_ID FROM PES.DBO.PES_STG_BOL WITH (NOLOCK) WHERE RECEIPT_ID = @PortId)
	END)

	--STEP 2 - FETCH THE CARRIER_ID_MOD FROM THE DQA_BL TABLE IN CASE THE SLINE_REF_IF IS 0
	IF @STR_SLINE_REF_ID = 0
		(SELECT @STR_SLINE_REF_ID = 
		(CASE @STR_PORT_TYPE 
			WHEN 'FPORT_ID' THEN
				(SELECT TOP 1 CARRIER_ID_MOD FROM DQA_BL WITH (NOLOCK) WHERE FPORT_ID = @PortId AND CARRIER_ID_MOD IS NOT NULL)
			WHEN 'ULTPORT_ID' THEN 
				(SELECT TOP 1 CARRIER_ID_MOD FROM DQA_BL WITH (NOLOCK) WHERE ULTPORT_ID = @PortId AND CARRIER_ID_MOD IS NOT NULL)
			WHEN 'RCPT_ID' THEN
				(SELECT TOP 1 CARRIER_ID_MOD FROM DQA_BL WITH (NOLOCK) WHERE RCPT_ID = @PortId AND CARRIER_ID_MOD IS NOT NULL)
		END	))

	--STEP 3 - CHECK IF THE COMBINATION ALREADY EXISTS IN PES_STG_BOL TABLE EARLIER
--	Check whether the ID which user has selected and the SLINE_REF_ID combination exists in any of the records 
--earlier in PES_STG_BOL table.  If it is ULTPORT, check for ULTPORT_ID and SLINE_REF_ID.  
--If it is Foreign Port, check for PORT_ARRIVE_REF_ID and SLINE_REF_ID.  
--If it is Receipt city, RECEIPT_ID and SLINE_REF_ID.   
	IF @PortType = 'FPORT_ID'
		BEGIN
			IF EXISTS (SELECT 1 FROM PES.DBO.PES_STG_BOL WITH (NOLOCK) WHERE PORT_ARRIVE_REF_ID = @PortId
						AND SLINE_REF_ID = @STR_SLINE_REF_ID)
					SET @RETURN_VALUE = 1
			ELSE
				SET @RETURN_VALUE = 0
		END
	ELSE IF @PortType = 'ULTPORT_ID'
		BEGIN
			IF EXISTS (SELECT 1 FROM PES.DBO.PES_STG_BOL WITH (NOLOCK) WHERE ULTPORT_ID = @PortId
						AND SLINE_REF_ID = @STR_SLINE_REF_ID)
				BEGIN
					SET @RETURN_VALUE = 1
				END
			ELSE
				SET @RETURN_VALUE = 0	
		END
	ELSE IF @PortType = 'RCPT_ID'
		BEGIN	
			IF EXISTS (SELECT 1 FROM PES.DBO.PES_STG_BOL WITH (NOLOCK) WHERE RECEIPT_ID = @PortId
						AND SLINE_REF_ID = @STR_SLINE_REF_ID)
				BEGIN
					SET @RETURN_VALUE = 1
				END
			ELSE
				SET @RETURN_VALUE = 0	
		END	

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
