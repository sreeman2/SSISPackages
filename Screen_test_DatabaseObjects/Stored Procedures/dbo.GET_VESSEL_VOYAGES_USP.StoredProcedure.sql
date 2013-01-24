/****** Object:  StoredProcedure [dbo].[GET_VESSEL_VOYAGES_USP]    Script Date: 01/03/2013 19:47:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_VESSEL_VOYAGES_USP]
	@VOYAGE_ID AS NUMERIC(12,0)	,
	@DIR	AS VARCHAR(1)
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


SELECT 
	D.VOYAGE_ID, 
	D.VOYAGE_STATUS,
	ISNULL((CASE D.PORT_UNLADING_CD_MOD WHEN ' ' THEN NULL ELSE D.PORT_UNLADING_CD_MOD END),D.PORT_UNLADING_CD) as PORT_UNLADING_CD , 
	D.SCAC, 
	ISNULL((CASE D.VESSEL_NAME_MOD WHEN ' ' THEN NULL ELSE D.VESSEL_NAME_MOD END),D.VESSEL_NAME) as NAME, ISNULL((CASE D.VOYAGE_NBR_MOD WHEN ' ' THEN NULL ELSE D.VOYAGE_NBR_MOD END),
	D.VOYAGE_NBR) as VOYAGE_NBR,
	RTRIM(LTRIM(D.MANIFEST_NBR)) AS MANIFEST_NBR,convert(varchar(10),ISNULL((CASE D.ACT_ARRIVAL_DT_MOD WHEN ' ' THEN NULL ELSE D.ACT_ARRIVAL_DT_MOD END),
	D.ACT_ARRIVAL_DT),101) as ACT_ARRIVAL_DT, 
	D.ACT_ARRIVAL_DT, 
	D.EST_ARRIVAL_DT, 
	D.EARLIEST_TAPE_DT, 
	D.REMARKS as REMARKS, 
	D.PENDING_CNT, 
	D.SKIPPED_CNT, 
	D.CLEANSED_CNT, 
	D.PPMM_CNT, 
	D.DELETED_CNT, 
	D.TOTAL_CNT, 
	D.LATE_BILLS_FLG, 
	D.ACT_ARRIVAL_DT AS ACT_ARRIVAL_DT_FOR_CALC, 
	RTRIM(LTRIM(ACT_MANIFEST_NBR)) AS ACT_MANIFEST_NBR , 
	D.VESSEL_CD ,
	D.VOYAGE_ID as V_ID , 
	ISNULL(D.VESSEL_NAME,'') as OLDNAME   
FROM dbo.DQA_VOYAGE AS D WITH (NOLOCK) 
WHERE ( 
	( D.VOYAGE_STATUS <> 'INPROCESS' ) 
	AND ( DIR = @DIR  )
	AND ( D.VOYAGE_ID =  @VOYAGE_ID )
)
ORDER BY D.ACT_ARRIVAL_DT


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
