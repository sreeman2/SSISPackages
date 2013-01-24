/****** Object:  StoredProcedure [dbo].[UPDATE_VOYAGE_DETAILS]    Script Date: 01/03/2013 19:48:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <10th Nov 2010>
-- Description:	<Updating the DQA Voyage Details>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_VOYAGE_DETAILS]
	-- Add the parameters for the stored procedure here
	@ACT_MANIFEST_NBR CHAR(6),
	@VOYAGE_STATUS VARCHAR(10),
	@ACT_ARRIVAL_DT DATETIME,
	@REMARKS VARCHAR(100),
	@MODIFIED_BY VARCHAR(25),
	@GLOBAL_UPDATE TINYINT,
	@VOYAGE_ID NUMERIC
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = 'MANIFEST NBR:''' + ( CASE WHEN @ACT_MANIFEST_NBR IS NULL THEN '' ELSE @ACT_MANIFEST_NBR END )+ ''''
	+',@VOYAGE_STATUS:'''+isnull(@VOYAGE_STATUS, '') +'''' 
	+',@ACT_ARRIVAL_DT:'''+CAST(isnull(@ACT_ARRIVAL_DT,'') AS VARCHAR(25))+''''
	+',@REMARKS:'''+ ISNULL(@REMARKS, '') +''''
	+',@MODIFIED_BY:'''+ isnull(@MODIFIED_BY,'') +''''
	+',@GLOBAL_UPDATE:'''+CAST(@GLOBAL_UPDATE AS VARCHAR(10))+''''
	+',@VOYAGE_ID:'''+CAST(@VOYAGE_ID AS VARCHAR(25)) + ''''

EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE DQA_VOYAGE WITH (UPDLOCK) 
	SET ACT_MANIFEST_NBR = CASE WHEN @ACT_MANIFEST_NBR IS NULL THEN '' ELSE @ACT_MANIFEST_NBR END ,  
		VOYAGE_STATUS = @VOYAGE_STATUS,  
		ACT_ARRIVAL_DT = convert(varchar(10),@ACT_ARRIVAL_DT, 101),  
		REMARKS = @REMARKS ,  
		MODIFIED_DT = GETDATE(),  
		MODIFIED_BY = @MODIFIED_BY, 
		GLOBAL_UPDATE = (CASE WHEN GLOBAL_UPDATE = 2 THEN 2 ELSE 1 END ) 
	WHERE VOYAGE_ID = @VOYAGE_ID

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
