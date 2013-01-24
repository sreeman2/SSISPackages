/****** Object:  StoredProcedure [dbo].[UPDATE_REF_PORT]    Script Date: 01/03/2013 19:48:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CTS - 7th January 2010
--modifications done to the unique constraint.
--the unique constraint has been changed to (PortCode and Piers Port name)
--LOGIC FOR EDITING THE SELECTED RECORD HAS BEEN CHANGED

-- =============================================
-- Author:		<CTS>
-- Create date: <16th July 2009>
-- Description:	<Updating the PORT MASTER Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_REF_PORT]  
	-- Add the parameters for the stored procedure here
	@port_name varchar(max),
	@piers_port_name varchar(max),
	@port_code varchar(max),
	@piers_port_code varchar(max),
	@state varchar(max),	
	@is_tmp varchar(max),
	@modif_by varchar(max),
	@ID VARCHAR(MAX),
    @UNIQUE_MOD BIT,
	@RETURN_VALUE INT OUTPUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @RECCOUNT INT

	IF @UNIQUE_MOD = 1 --UNIQUE CONSTRAINTS MODIFIED
		BEGIN
			SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_PORT WITH (NOLOCK)
				WHERE CODE=@PORT_CODE AND PIERS_NAME=@PIERS_PORT_NAME 
					--AND IS_US_PORT=1 
			IF @RECCOUNT=0
				BEGIN
					UPDATE PES.DBO.REF_PORT WITH (UPDLOCK) SET 
						CODE = @port_code,
						PORT_NAME = @port_name,
						PIERS_NAME = @piers_port_name,
						PIERS_PORT_CODE = @piers_port_code,
						STATE = @state,
						IS_TMP = @is_tmp,
						MODIFIED_BY = @modif_by,
						MODIFIED_DT = getdate()
						WHERE ID = @ID
					SET @RETURN_VALUE = 0	
				END
			ELSE
				BEGIN
					SET @RETURN_VALUE = 1
				END
		END
	ELSE  --UNIQUE CONSTRAINTS NOT MODIFIED
		BEGIN
			SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_PORT WITH (NOLOCK)
				WHERE CODE=@PORT_CODE AND PORT_NAME=@PORT_NAME
					AND PIERS_NAME=@PIERS_PORT_NAME 
					--AND IS_US_PORT=1 
					AND STATE = @state AND IS_TMP = @is_tmp
			IF @RECCOUNT=0
				BEGIN
					UPDATE PES.DBO.REF_PORT WITH (UPDLOCK) SET 
						CODE = @port_code,
						PORT_NAME = @port_name,
						PIERS_NAME = @piers_port_name,
						PIERS_PORT_CODE = @piers_port_code,
						STATE = @state,
						IS_TMP = @is_tmp,
						MODIFIED_BY = @modif_by,
						MODIFIED_DT = getdate()
						WHERE ID = @ID
						SET @RETURN_VALUE = 0		
				END
			ELSE
				BEGIN
					SET @RETURN_VALUE = 1
				END
		END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
