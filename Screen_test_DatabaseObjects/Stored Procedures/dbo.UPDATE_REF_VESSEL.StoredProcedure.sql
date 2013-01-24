/****** Object:  StoredProcedure [dbo].[UPDATE_REF_VESSEL]    Script Date: 01/03/2013 19:48:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CTS-MODIFICATIONS DONE ON 01-13-2010
--VESSEL MIGRATION CHANGES

-- =============================================
-- Author:		<CTS>
-- Create date: <15th July 2009>
-- Description:	<Updating the VESSEL MASTER Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_REF_VESSEL]  
	-- Add the parameters for the stored procedure here
   @STND_VESSEL varchar(max),
   --@piers_vessel varchar(max),
   @COUNTRY varchar(max),
   @IMO varchar(max),
   @is_tmp varchar(max),
   @modified_by varchar(max),
   @TEU_CAPACITY int,
   @id varchar(max),
   @UNIQUE_MOD BIT,
   @RETURN_VALUE int OUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @RECCOUNT int
	
	IF @UNIQUE_MOD = 1 --UNIQUE CONSTRAINTS MODIFIED
		BEGIN
			SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_VESSEL WITH (NOLOCK)
				WHERE STND_VESSEL=@STND_VESSEL AND VESSEL_COUNTRY=@COUNTRY
			IF @RECCOUNT=0
				BEGIN
					UPDATE PES.DBO.REF_VESSEL WITH (UPDLOCK) SET 
						STND_VESSEL = @STND_VESSEL,
						[NAME]= @STND_VESSEL,
						VESSEL_COUNTRY = @COUNTRY,
						IMO_CODE = @IMO,
						IS_TMP = @is_tmp,
						TEU_CAPACITY = @TEU_CAPACITY,
						MODIFIED_BY = @modified_by,
						MODIFIED_DT = getdate() 
						WHERE ID = @id
					SET @RETURN_VALUE = 0
				END
			ELSE
				BEGIN
					SET @RETURN_VALUE = 1
				END
		END
	ELSE  --UNIQUE CONSTRAINTS NOT MODIFIED
		BEGIN
			SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_VESSEL WITH (NOLOCK)
				WHERE STND_VESSEL=@STND_VESSEL AND VESSEL_COUNTRY=@COUNTRY
				AND IMO_CODE=@IMO AND IS_TMP=@is_tmp
			IF @RECCOUNT=0
				BEGIN
					UPDATE PES.DBO.REF_VESSEL WITH (UPDLOCK) SET 
						STND_VESSEL = @STND_VESSEL,
						[NAME]= @STND_VESSEL,
						VESSEL_COUNTRY = @COUNTRY,
						IMO_CODE = @IMO,
						IS_TMP = @is_tmp,
						TEU_CAPACITY = @TEU_CAPACITY,
						MODIFIED_BY = @modified_by,
						MODIFIED_DT = getdate() 
						WHERE ID = @id
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
