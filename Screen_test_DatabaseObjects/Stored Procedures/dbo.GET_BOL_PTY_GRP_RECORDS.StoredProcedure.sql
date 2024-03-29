/****** Object:  StoredProcedure [dbo].[GET_BOL_PTY_GRP_RECORDS]    Script Date: 01/03/2013 19:47:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_BOL_PTY_GRP_RECORDS]
	@T_NBR NUMERIC(12,0),
	@SOURCE CHAR(1)
AS
BEGIN
SET NOCOUNT ON;

DECLARE @STR_PTY_ID NUMERIC(12,0)
DECLARE @GROUP_ID NUMERIC(12,0)

---- [aa] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@T_NBR='''+CAST(@T_NBR AS VARCHAR(100))+''''
--+', @SOURCE='''+@SOURCE+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'GET_BOL_PTY_GRP_RECORDS'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT


-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@T_NBR='''+CAST(@T_NBR AS VARCHAR(100))+''''
+', @SOURCE='''+@SOURCE+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


SELECT @STR_PTY_ID = STR_PTY_ID , @GROUP_ID = GROUP_ID
FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK) 
WHERE 
( 
	( BOL_ID = @T_NBR ) 
	AND ( SOURCE = @SOURCE ) 
)

	SELECT DISTINCT 
		BOL_ID, 
		STR_PTY_ID, 
		COMP_ID, 
		company_nbr, 
		NAME, 
		ADDR_1, 
		ADDR_2,
		CITY, 
		STATE as St, 
		POSTAL_CD as Zip, 
		b.PIERS_COUNTRY as Country 
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY  WITH (NOLOCK) 
	LEFT OUTER JOIN PES.dbo.REF_COUNTRY AS b WITH (NOLOCK) ON ( CNTRY_CD = CAST(b.JOC_CODE AS VARCHAR(10)) ) AND ( b.IS_MASTER = 'Y' ) 
	WHERE 
	( 
		( GROUP_ID = @GROUP_ID )
		AND ( STATUS = 'PENDING' )
		AND STR_PTY_ID NOT IN ( @STR_PTY_ID )
	)

--			SELECT main.GROUP_ID FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY AS main WITH (NOLOCK) 
--			WHERE 
--			( 
--				( main.BOL_ID = @T_NBR )
--				AND ( main.SOURCE = @SOURCE )
--			)
--		)

		--STR_PTY_ID NOT IN ( 
--		NOT EXISTS 
--		(
--			SELECT sub.STR_PTY_ID 
--			FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY AS sub WITH (NOLOCK) 
--			WHERE 
--			( 
--				( sub.bol_id = @T_NBR ) 
--				AND ( Source = @SOURCE ) 
--				AND ( sub.STR_PTY_ID = STR_PTY_ID )
--			)
--		) 


-- [aa] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
