/****** Object:  StoredProcedure [dbo].[USP_PES_RECNUM_GENERATION]    Script Date: 01/08/2013 14:51:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		COGNIZANT
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_PES_RECNUM_GENERATION] @CMD_ID BIGINT , @RECNUM	CHAR(8) OUT, @ASCII_CHAR INT OUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @ASCII INT
DECLARE @RECNUM_GEN CHAR(8)
DECLARE @CMD_ID_CHAR BIGINT 

SET @CMD_ID_CHAR = RIGHT(@CMD_ID,7)
SELECT @RECNUM_GEN = 
CASE WHEN @CMD_ID > 109999999 THEN 
CHAR(ASCII('A')+ LEFT(@CMD_ID,LEN(@CMD_ID)-7)-10) + 
REPLICATE('0',7-LEN(CAST(@CMD_ID_CHAR - CAST((@CMD_ID_CHAR-1)/9999999 AS INT)*9999999 AS CHAR(7))))+
CAST(@CMD_ID_CHAR - CAST((@CMD_ID_CHAR-1)/9999999 AS INT)*9999999 AS CHAR(7)) 
ELSE 
CHAR(ASCII('A')) + REPLICATE('0',7-LEN(@CMD_ID_CHAR))+ CAST(@CMD_ID_CHAR AS CHAR(7))
END 

SELECT @ASCII = 
CASE WHEN @CMD_ID > 109999999 THEN 
ASCII(CHAR(ASCII('A')+ LEFT(@CMD_ID,LEN(@CMD_ID)-7)-10))
ELSE 
ASCII('A')
END 

SET @RECNUM = @RECNUM_GEN
--SELECT @RECNUM
SET @ASCII_CHAR	= @ASCII   
--SELECT @ASCII_CHAR

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
