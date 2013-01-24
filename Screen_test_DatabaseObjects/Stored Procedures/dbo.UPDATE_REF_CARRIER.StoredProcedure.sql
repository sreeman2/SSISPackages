/****** Object:  StoredProcedure [dbo].[UPDATE_REF_CARRIER]    Script Date: 01/03/2013 19:48:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <14th July 2009>
-- Description:	<Updating the CARRIER Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_REF_CARRIER]  
	-- Add the parameters for the stored procedure here
   @scac_ varchar(max),
   @sline_ varchar(max),
   @carrier_desc_ varchar(max),
   @is_tmp_ varchar(max),
   @is_nvo_ varchar(max),
   @modif_by_ varchar(max),
   @id varchar(max),
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
	
	SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_CARRIER WITH (NOLOCK)
		WHERE CODE=@SCAC_ AND [TYPE]=@SLINE_
		AND CARRIER_DESC = @carrier_desc_
		AND IS_TMP = @is_tmp_
		AND IS_NVO = @is_nvo_
		

	IF @RECCOUNT=0
		BEGIN
			UPDATE PES.DBO.REF_CARRIER WITH (UPDLOCK) SET 
			CODE = @scac_,
			[TYPE]= @sline_,
			IS_NVO = @is_nvo_,
			CARRIER_DESC = @carrier_desc_,
			IS_TMP = @is_tmp_,
			MODIFIED_BY = @modif_by_,
			MODIFIED_DT = getdate() 
			WHERE ID = @id

			SET @RETURN_VALUE = 0
		END
	ELSE
		BEGIN
			SET @RETURN_VALUE = 1
		END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
