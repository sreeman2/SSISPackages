/****** Object:  StoredProcedure [dbo].[ASSIGN_DQA_TYPIST_NEW]    Script Date: 01/03/2013 19:47:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--ADDED THE PARAMETERS FOR THE PRODUCTION DATE FILTERS
-- CTS - 17TH JULY 2009
CREATE PROCEDURE [dbo].[ASSIGN_DQA_TYPIST_NEW] ( 
 @user_id               varchar(16),
 @sDir                  varchar(16),
 @In_T_NBR                  int,
 @Prod_Start                  datetime,
 @Prod_End                    datetime,
 @Out_T_NBR             int               OUTPUT
)
As
Begin
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@user_id='''+@user_id+''''
+', @sDir='''+@sDir+''''
+', @In_T_NBR='+LTRIM(RTRIM(STR(@In_T_NBR)))
+', @Prod_Start='+CONVERT(varchar(10),@Prod_Start,101) 
+', @Prod_End='+CONVERT(varchar(10),@Prod_End,101) 
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT
/*
SELECT  TOP (1) @Out_T_NBR = BL_CACHE.T_NBR
FROM  dbo.[BL_CACHE] WITH (NOLOCK) 
JOIN dbo.[BL_CACHE_DQA_B] WITH (NOLOCK) ON BL_CACHE_DQA_B.T_NBR = BL_CACHE.T_NBR 
WHERE 
(
 (BL_CACHE_DQA_B.[STATUS_VALUE] = 1) 
 AND	(BL_CACHE_DQA_B.[IS_HIGH_PRIORITY] = 1)
	
	AND
	
	  ((BL_CACHE.DQA_OWNER_ID IN ( @user_id, 'UNASSIGNED' )) 
      AND ( BL_CACHE.DIR = @sDir ) 
      AND ( BL_CACHE.DQA_BL_STATUS = 'PENDING') )
)

--AND BL_CACHE_DQA.LOAD_NBR_CODE IN ('002','007','012','013','016','017')
ORDER BY 
--BL_CACHE_DQA_B.[IS_HIGH_PRIORITY] desc,
BL_CACHE.ACT_ARRIVAL_DT 


IF ( @Out_T_NBR IS NULL )

BEGIN

*/
      SELECT  TOP (1) @Out_T_NBR = BL_CACHE.T_NBR
		FROM  dbo.[BL_CACHE] WITH (NOLOCK) 
JOIN dbo.[BL_CACHE_DQA_B] WITH (NOLOCK) ON BL_CACHE_DQA_B.T_NBR = BL_CACHE.T_NBR 
WHERE 
(
 (BL_CACHE_DQA_B.[STATUS_VALUE] = 1) 
	
			AND
			
			  (BL_CACHE.T_NBR > @In_T_NBR)
			  
			AND
			
			  ((BL_CACHE.DQA_OWNER_ID IN ( @user_id, 'UNASSIGNED' )) 
			  AND ( BL_CACHE.DIR = @sDir ) 
			  AND ( BL_CACHE.DQA_BL_STATUS = 'PENDING') )
		)

      ORDER BY 
      BL_CACHE_DQA_B.[IS_HIGH_PRIORITY] desc,
BL_CACHE.ACT_ARRIVAL_DT 

/*
END
*/
IF ( @Out_T_NBR IS NULL )
BEGIN
      SELECT  TOP (1) @Out_T_NBR = BL_CACHE.T_NBR
		FROM  dbo.[BL_CACHE] WITH (NOLOCK) 
JOIN dbo.[BL_CACHE_DQA_B] WITH (NOLOCK) ON BL_CACHE_DQA_B.T_NBR = BL_CACHE.T_NBR 
WHERE 
(
 (BL_CACHE_DQA_B.[STATUS_VALUE] = 1) 
				
			AND
			
			  (BL_CACHE.T_NBR < @In_T_NBR)
			  
			AND
			
			  ((BL_CACHE.DQA_OWNER_ID IN ( @user_id, 'UNASSIGNED' )) 
			  AND ( BL_CACHE.DIR = @sDir ) 
			  AND ( BL_CACHE.DQA_BL_STATUS = 'PENDING') )
		)

      ORDER BY 
      BL_CACHE_DQA_B.[IS_HIGH_PRIORITY] desc,
BL_CACHE.ACT_ARRIVAL_DT 

END

IF @Out_T_NBR IS NULL
      SET @Out_T_NBR = 0

-- [aa] - 09/18/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
