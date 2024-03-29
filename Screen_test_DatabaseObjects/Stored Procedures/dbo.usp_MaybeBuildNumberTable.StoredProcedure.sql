/****** Object:  StoredProcedure [dbo].[usp_MaybeBuildNumberTable]    Script Date: 01/03/2013 19:48:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MaybeBuildNumberTable]
@size INT=10000
AS
BEGIN
SET NOCOUNT ON

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

IF NOT EXISTS (SELECT * FROM dbo.sysobjects
  WHERE id = OBJECT_ID(N'[dbo].[Numbers]')
   AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
    BEGIN
    CREATE TABLE [dbo].[Numbers](
     [number] [int],
    CONSTRAINT [Index_Numbers] PRIMARY KEY CLUSTERED
    (
     [number] ASC
    ) ON [PRIMARY]
    ) ON [PRIMARY]

    DECLARE @ii INT
    SELECT @ii=1
    WHILE (@ii<=@size)
     BEGIN
     INSERT INTO NUMBERS(NUMBER) SELECT @II
     SELECT @II=@II+1
     END
    END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
