/****** Object:  StoredProcedure [dbo].[UNLOCK_LOCKED_BILLS]    Script Date: 01/03/2013 19:48:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Perumal Poopathy
-- Create date: Feb-19-2010
-- Description:	SP to unlcock bills that are locked for more than a day.
-- =============================================
CREATE PROCEDURE [dbo].[UNLOCK_LOCKED_BILLS]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	IF EXISTS ( SELECT * FROM SCREEN_TEST.DBO.dqa_bl WITH (NOLOCK) WHERE locked_by_usr IS NOT NULL 
		AND locked_by_date IS NOT NULL AND locked_by_date < (GETDATE()-1))
	BEGIN
		UPDATE dqa_bl WITH (UPDLOCK) 
		SET locked_by_usr = NULL, locked_by_date = NULL, edit_mode = NULL 
		WHERE t_nbr IN ( SELECT T_NBR FROM SCREEN_TEST.DBO.dqa_bl WITH (NOLOCK) 
				WHERE locked_by_usr IS NOT NULL AND locked_by_date IS NOT NULL  
				AND locked_by_date < (GETDATE()-1)
		)
	END  -- End of begin

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END  -- End of SP
GO
