/****** Object:  StoredProcedure [dbo].[UPDATE_REF_HARMCMST]    Script Date: 01/03/2013 19:48:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <8th July 2009>
-- Description:	<Updating the HarmCode Dictionary>
-- Modifications: DE1189 | Develop UI features to fix existing Harm and JOC Code entry screens | JSA | 05/04/2011 | Solution: Set compressed value using SCREEN_TEST.dbo.GET_KEY function.
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_REF_HARMCMST]  
	-- Add the parameters for the stored procedure here
    @fullname varchar(max),
    @harmcode varchar(max),
    @modif_by varchar(max),
	@id int,
    @RETURN_VALUE INT OUT
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
	
	--Check to see if the HarmCode already exists.
	SELECT @RECCOUNT=count(*) FROM [PES].[dbo].[REF_HARMCMST] WITH (NOLOCK)
	WHERE FULL_NAME = LEFT(@fullname, 50) AND HARMCODE  = LEFT(@harmcode, 35)

	IF @RECCOUNT=0
		BEGIN
			UPDATE PES.DBO.REF_HARMCMST WITH (UPDLOCK) SET 
			COMP_NAME = LEFT(SCREEN_TEST.dbo.GET_KEY(@fullname),40), --Field length 40.
			FULL_NAME = LEFT(@fullname, 50), --Field length 50.
			HARMCODE  = LEFT(@harmcode, 35), --Field length 35.
			MODIFIED_BY = @modif_by,
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
