/****** Object:  StoredProcedure [dbo].[USP_GENERATE_VIN_REPORT_CARFAX_z]    Script Date: 01/08/2013 14:51:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GENERATE_VIN_REPORT_CARFAX_z] 
@YYYYMM	CHAR(6),
@DIRECTION CHAR(1)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	--Truncate the table TEMP_VIN_REPORT_CARFAX
	TRUNCATE TABLE TEMP_VIN_REPORT_CARFAX
	
	INSERT INTO [PESDW].[dbo].[TEMP_VIN_REPORT_CARFAX]
           ([VIN]
           ,[CTRY_CD]
           ,[TRADE_REGION]
           ,[USPORT]
           ,[ACT_ARR_DT]
           ,[BL_NBR]
           ,[DIR])    
	SELECT V.VIN_NUMBER,

			(
				SELECT TOP 1 ISNULL(ISO_ALPHA_2_CODE,'') 
				FROM PES_DW_REF_COUNTRY C WITH (NOLOCK)
				WHERE C.CTRY_CODE = B.CTRYCODE
			) AS CTRY_CD,

	'' AS 'TRADE_REGION', -- We do not have this information in PES now,

	CASE @DIRECTION
	WHEN 'I' THEN (
					SELECT TOP 1 ISNULL(CODE,'')
				    FROM PES_DW_REF_PORT P WITH (NOLOCK) 
					WHERE P.ID = B.PORT_ARRIVE_REF_ID
					)
	WHEN 'E' THEN (
					SELECT TOP 1 ISNULL(CODE,'')
				    FROM PES_DW_REF_PORT P WITH (NOLOCK) 
					WHERE P.ID = B.PORT_DEPART_REF_ID
					)
	ELSE ''
	END AS 'USPORT',	

	CONVERT(CHAR(8),B.VDATE,112) AS 'ACTUAL_ARRIVAL_DT',

	V.BILL_NUMBER,
	V.DIR

	FROM PES_DW_VIN V WITH (NOLOCK)
	JOIN PES_DW_BOL B WITH (NOLOCK)
	ON V.BOL_ID=B.BOL_ID
	WHERE CONVERT(CHAR(6),V.VDATE,112) = @YYYYMM	
	AND V.DIR = @DIRECTION

	--Update Trade Region Information in the table
	UPDATE [TEMP_VIN_REPORT_CARFAX]
	SET TRADE_REGION = DBO.PESDW_UDF_GET_TRADE_REGION(CTRY_CD)


-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
