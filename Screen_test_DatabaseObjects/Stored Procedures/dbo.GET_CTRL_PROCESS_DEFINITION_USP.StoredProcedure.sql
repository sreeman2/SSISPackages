/****** Object:  StoredProcedure [dbo].[GET_CTRL_PROCESS_DEFINITION_USP]    Script Date: 01/03/2013 19:47:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_CTRL_PROCESS_DEFINITION_USP]
	@p_ExceptionName VARCHAR(50),
	@p_Direction VARCHAR(10)
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

IF ( @p_Direction = 'I' )
BEGIN

	SELECT 
		d.process_name	,
		d.grouping_flg	,
		d.history_flg	,
		d.change_fields	,
		m.description	,
		m.sqlmatch 
	FROM ctrl_process_definition d WITH (NOLOCK) JOIN ctrl_qc_modify m  WITH (NOLOCK) 
	ON d.[Process_name] = m.[KEY]
	WHERE UPPER(LTRIM(RTRIM(d.process_name))) = UPPER(LTRIM(RTRIM(@p_ExceptionName))) 
	--AND UPPER(LTRIM(RTRIM(m.[KEY]))) = UPPER(LTRIM(RTRIM('" & strExcpName.Trim() & "')))

END
ELSE
BEGIN 
	IF @p_ExceptionName = 'PORT EXCEPTIONS' OR @p_ExceptionName = 'N/W EXCEPTIONS'
	BEGIN
		SELECT 
			d.process_name	,
			d.grouping_flg	,
			d.history_flg	,
			'ULPRT,FRPRT' As change_fields , --RCPRT removed
			m.description	,
			m.sqlmatch 
		FROM ctrl_process_definition d WITH (NOLOCK) JOIN ctrl_qc_modify m  WITH (NOLOCK) 
		ON d.[Process_name] = m.[KEY]
		WHERE UPPER(LTRIM(RTRIM(d.process_name))) = UPPER(LTRIM(RTRIM(@p_ExceptionName))) 
	END
	ELSE
	BEGIN	
		SELECT 
			d.process_name	,
			d.grouping_flg	,
			d.history_flg	,
			change_fields	,
			m.description	,
			m.sqlmatch 
		FROM ctrl_process_definition d WITH (NOLOCK) JOIN ctrl_qc_modify m  WITH (NOLOCK) 
		ON d.[Process_name] = m.[KEY]
		WHERE UPPER(LTRIM(RTRIM(d.process_name))) = UPPER(LTRIM(RTRIM(@p_ExceptionName))) 
	END
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
