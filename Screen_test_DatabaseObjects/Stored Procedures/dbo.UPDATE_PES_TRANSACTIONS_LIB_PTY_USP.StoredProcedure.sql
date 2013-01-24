/****** Object:  StoredProcedure [dbo].[UPDATE_PES_TRANSACTIONS_LIB_PTY_USP]    Script Date: 01/03/2013 19:48:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_PES_TRANSACTIONS_LIB_PTY_USP]
	@COMP_ID AS NUMERIC(12,0)	,
	@STR_PTY_ID AS VARCHAR(MAX),
	@BOL_ID AS NUMERIC(12,0)	,
	@STATUS AS VARCHAR(50)		,
	@USERID AS VARCHAR(50)		
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


DECLARE @COUNT AS INT 
DECLARE @POSITION AS INT
DECLARE @LENTH AS INT
DECLARE @STR_PTY AS NUMERIC(12,0)
DECLARE @GROUP_ID NUMERIC(12,0)

SET @COUNT		= LEN(@STR_PTY_ID)
SET	@POSITION	= 0

DECLARE @STR_PTY_LIST AS TABLE
(
	PTY_ID NUMERIC(12,0)
)

WHILE ( @COUNT > 0 )
BEGIN
	SET @LENTH	= CHARINDEX(',',@STR_PTY_ID)	
	
	IF ( @LENTH <= 0 )
	BEGIN
		INSERT INTO @STR_PTY_LIST
		SELECT @STR_PTY_ID

		BREAK
	END
	ELSE
	BEGIN	
		SET @STR_PTY	= SUBSTRING(@STR_PTY_ID, @POSITION,  @LENTH)	

		INSERT INTO @STR_PTY_LIST
		SELECT @STR_PTY
		
		SET @STR_PTY_ID	= SUBSTRING(@STR_PTY_ID, @LENTH+1, (LEN(@STR_PTY_ID) - (LEN(@STR_PTY)+1)) )
		SET @COUNT			= @COUNT - (LEN(@STR_PTY)+1)
	END 
END

SELECT TOP 1 @GROUP_ID = GROUP_ID 
FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)
WHERE ( BOL_ID = @BOL_ID )
AND ( STR_PTY_ID IN ( 
		SELECT PTY_ID FROM @STR_PTY_LIST 
	)
)

IF ( @GROUP_ID IS NULL )
BEGIN
	UPDATE A 
	SET A.COMP_ID = @COMP_ID		,
		A.STATUS = @STATUS			,
		A.MODIFIED_DT = GETDATE()	, 
		A.MODIFIED_BY = @USERID  
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY AS A WITH (UPDLOCK)
	WHERE ( A.STR_PTY_ID IN ( SELECT PTY_ID FROM @STR_PTY_LIST ) )
END
ELSE
BEGIN
	UPDATE A 
	SET A.COMP_ID = @COMP_ID		,
		A.STATUS = @STATUS			,
		A.MODIFIED_DT = GETDATE()	, 
		A.MODIFIED_BY = @USERID  
	FROM PES.dbo.PES_TRANSACTIONS_LIB_PTY AS A WITH (UPDLOCK)
	WHERE 
	( 
		( A.GROUP_ID = @GROUP_ID )
		AND ( A.STR_PTY_ID IN ( SELECT PTY_ID FROM @STR_PTY_LIST ) ) 
	)
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
