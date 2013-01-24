/****** Object:  StoredProcedure [dbo].[PES_SP_Data_Flow_Tasks]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_Data_Flow_Tasks]
@PkgName VARCHAR(50),@SrcName VARCHAR(50)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @CNT INT

SELECT @CNT=COUNT(*) FROM PES_Data_Flow_Tasks WHERE Pname=@PkgName AND SourceName=@SrcName

IF @CNT <1
INSERT INTO PES.DBO.PES_Data_Flow_Tasks
VALUES (@PkgName,@SrcName)


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
