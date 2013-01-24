/****** Object:  StoredProcedure [dbo].[INSERT_REF_HARMCODES]    Script Date: 01/03/2013 19:47:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CTS - 25th January 2010
--ADDED check to verify the existence of the harm code

-- =============================================
-- Author:		<Nandini>
-- Create date: <10th april 2009>
-- Description:	<procedure to insert custom harm codes>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_REF_HARMCODES]
   @description varchar(max),
   @harmcode varchar(max),
   @modif_by varchar(max),
   @RETURN_VALUE int OUTPUT
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

	SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_HARM_CODES WITH (NOLOCK)
		WHERE HARM_CODE = @harmcode

	IF @RECCOUNT=0
		BEGIN
			INSERT PES.dbo.REF_HARM_CODES(         
				 DESCRIPTION, 
				 HARM_CODE, 
				 DELETED, 
				 MODIFIED_BY, 
				 MODIFIED_DT)
				 VALUES (           
					@description, 
					@harmcode, 
					'N', 
					@modif_by, 
					getdate())
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
