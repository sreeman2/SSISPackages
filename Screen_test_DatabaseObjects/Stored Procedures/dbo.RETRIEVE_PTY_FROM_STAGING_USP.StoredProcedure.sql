/****** Object:  StoredProcedure [dbo].[RETRIEVE_PTY_FROM_STAGING_USP]    Script Date: 01/03/2013 19:48:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RETRIEVE_PTY_FROM_STAGING_USP] 
	@BOL_ID AS NUMERIC(12,0)
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


SELECT	BOL_ID		,
		SOURCE		, 
		'' as NAME	, 
		'' as ADDR1	, 
		'' as ADDR2	, 
		'' as CITY	, 
		'' as ST	, 
		'' as COUNTRY	, 
		'' as ZIP	, 
		STG_PTY_ID AS str_pty_id,
		COMP_ID as CompKey  
FROM PES.dbo.PES_STG_PTY WITH (NOLOCK)   
WHERE ( BOL_ID = @BOL_ID )

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
