/****** Object:  StoredProcedure [dbo].[ASSIGN_DQA_TYPIST_LATE]    Script Date: 01/03/2013 19:47:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ASSIGN_DQA_TYPIST_LATE]

( 

 @user_id               varchar(16),

 @sDir                  varchar(16),

 @In_T_NBR                  int,

 @Out_T_NBR             int      OUTPUT

)

As
Begin

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


SELECT     TOP (1) @Out_T_NBR = BL_CACHE.T_NBR
FROM         BL_CACHE  WITH (NOLOCK) 
INNER JOIN BL_BL  WITH (NOLOCK) ON BL_BL.T_NBR = BL_CACHE.T_NBR 
INNER JOIN DQA_VOYAGE  WITH (NOLOCK) ON BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID
WHERE (BL_CACHE.T_NBR <> @In_T_NBR)
		AND (BL_CACHE.DQA_BL_STATUS = 'PENDING') 
		AND (BL_CACHE.DQA_OWNER_ID = @user_id) 
		AND (BL_CACHE.DIR = @sDir) 
		AND (ISNULL(BL_BL.BOL_STATUS, '') NOT IN ('MASTER','TEMPMASTER','HOUSE')) 
		AND (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE')
		AND ISNULL(BL_CACHE.LATE_BOL_FLAG,'') = 'L'
        AND BL_CACHE.T_NBR > @In_T_NBR
ORDER BY BL_CACHE.T_NBR ASC

IF @Out_T_NBR IS NULL 
BEGIN
SELECT     TOP (1) @Out_T_NBR = BL_CACHE.T_NBR
FROM         BL_CACHE  WITH (NOLOCK) 
INNER JOIN BL_BL  WITH (NOLOCK) ON BL_BL.T_NBR = BL_CACHE.T_NBR 
INNER JOIN DQA_VOYAGE  WITH (NOLOCK) ON BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID
WHERE (BL_CACHE.T_NBR <> @In_T_NBR)
		AND (BL_CACHE.DQA_BL_STATUS = 'PENDING') 
		AND (BL_CACHE.DQA_OWNER_ID = 'UNASSIGNED') 
		AND (BL_CACHE.DIR = @sDir) 
		AND (ISNULL(BL_BL.BOL_STATUS, '') NOT IN ('MASTER','TEMPMASTER','HOUSE')) 
		AND (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE')
		AND ISNULL(BL_CACHE.LATE_BOL_FLAG,'') = 'L'
--        AND BL_CACHE.T_NBR > @In_T_NBR
		AND BL_CACHE.T_NBR > 0
ORDER BY BL_CACHE.T_NBR ASC
END

 IF @Out_T_NBR IS NULL
 begin
	SET @Out_T_NBR = 0
 end

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

end
GO
