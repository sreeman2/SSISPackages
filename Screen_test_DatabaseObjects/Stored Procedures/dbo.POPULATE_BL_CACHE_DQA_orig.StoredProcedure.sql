/****** Object:  StoredProcedure [dbo].[POPULATE_BL_CACHE_DQA_orig]    Script Date: 01/03/2013 19:48:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[POPULATE_BL_CACHE_DQA_orig]  
    @blcnt float(53)  OUTPUT

AS 

BEGIN

-- Log start time
--DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
--SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
--,@ParametersIn = NULL
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


TRUNCATE TABLE dbo.BL_CACHE_DQA

INSERT INTO dbo.BL_CACHE_DQA (T_NBR, DQA_VOYAGE_ID, BOL_STATUS, VOYAGE_STATUS, LOAD_NBR_CODE)
(
SELECT b.T_NBR, b.DQA_VOYAGE_ID, b.BOL_STATUS, v.VOYAGE_STATUS, b.LOAD_NBR_CODE
FROM dbo.BL_CACHE bc WITH (NOLOCK) JOIN dbo.BL_BL b WITH (NOLOCK) ON b.T_NBR = bc.T_NBR  JOIN dbo.DQA_VOYAGE v WITH (NOLOCK) ON v.VOYAGE_ID = b.DQA_VOYAGE_ID
)



	SELECT @blcnt = @@ROWCOUNT


-- Log end time
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
-- @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
