/****** Object:  StoredProcedure [dbo].[usp_PrioritizeFeedLoad1]    Script Date: 01/03/2013 19:48:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PrioritizeFeedLoad1]
	 @Type varchar(100)
	,@FeedFileName varchar(100) = NULL
	,@Priority varchar(100) = NULL
	,@ModifiedBy varchar(100) = NULL
	--,@ModifiedAt datetime = NULL
	,@Id int = NULL
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

-- [aa] - 12/07/2010 - Remove any special characters from the FeedName
--  Most likely this is coming from the Operator copying and pasting
--  the name of the file on the front-end screen in PESWeb (http://10.23.14.123/PESWeb/admin/admin_1.aspx)
SELECT @FeedFileName = SCREEN_TEST.dbo.ufn_PES_RemoveSpecialCharacters(@FeedFileName)

	IF @Type = 'Select'
	BEGIN
		SELECT * FROM dbo.FeedLoadPriority WHERE Status IS NULL ORDER BY Priority
	END
	ELSE IF @Type = 'Insert'
	BEGIN
		SELECT @Id = NULL
		SELECT @Id = Id FROM dbo.FeedLoadPriority WHERE FeedFileName = @FeedFileName
		IF @Id IS NULL
			INSERT INTO dbo.FeedLoadPriority (FeedFileName,Priority,ModifiedBy) Values (@FeedFileName,@Priority,@ModifiedBy)
		ELSE
			UPDATE dbo.FeedLoadPriority SET FeedFileName=@FeedFileName,Priority=@Priority,Status=NULL,ModifiedBy=@ModifiedBy,ModifiedAt=getdate() WHERE Id=@Id
	END
	ELSE IF @Type = 'Update'
	BEGIN
		UPDATE dbo.FeedLoadPriority SET FeedFileName=@FeedFileName,Priority=@Priority,ModifiedBy=@ModifiedBy,ModifiedAt=getdate() WHERE Id=@Id
	END
	ELSE IF @Type = 'Delete'
	BEGIN
		UPDATE dbo.FeedLoadPriority SET Status='PriorityDeleted',ModifiedBy=@ModifiedBy,ModifiedAt=getdate() WHERE Id=@Id
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
