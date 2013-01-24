/****** Object:  StoredProcedure [dbo].[GetRawInfo2_ORIG]    Script Date: 01/03/2013 19:40:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetRawInfo2_ORIG]
	@RawID int,
	@Source char

AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


select name,addr_1, addr_2, Addr_3, addr_4, 
case when b.impexp = 'E' then 
case when Source = 'C' then 'S' else 
case when source = 'S' 
then 'C' else Source end
end
else
source end 
Source
from raw_pty a inner join raw_bol b on a.bol_id = b.bol_id
where a.bol_id = @RawID
and a.Source = @Source


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
