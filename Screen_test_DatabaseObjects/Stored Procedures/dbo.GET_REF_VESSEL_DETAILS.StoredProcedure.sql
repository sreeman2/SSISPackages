/****** Object:  StoredProcedure [dbo].[GET_REF_VESSEL_DETAILS]    Script Date: 01/03/2013 19:47:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <8TH NOV 2010>
-- Description:	<Get the REF VESSEL details>
-- =============================================
CREATE PROCEDURE [dbo].[GET_REF_VESSEL_DETAILS]
	-- Add the parameters for the stored procedure here
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	SELECT ID AS ID,STND_VESSEL,NAME,VESSEL_COUNTRY, IMO_CODE, 
		CASE IS_TMP WHEN NULL THEN 'N' ELSE IS_TMP END AS IS_TMP,
		ISNULL(MODIFIED_BY,'TEST') AS MODIFIED_BY,MODIFIED_DT,
		CASE DELETED WHEN 'Y' THEN 'deleted'WHEN 'N' THEN ''ELSE ''END AS DELETED 
	FROM PES.dbo.REF_VESSEL WITH (NOLOCK) ORDER BY 2

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
