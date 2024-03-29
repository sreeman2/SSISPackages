/****** Object:  StoredProcedure [dbo].[UPDATE_REF_CITYCOUN]    Script Date: 01/03/2013 19:48:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <27th January 2010>
-- Description:	<Updating the CITY COUNTRY Dictionary>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_REF_CITYCOUN]  
	-- Add the parameters for the stored procedure here
	@CITY VARCHAR(MAX),
	@COUNTRY VARCHAR(MAX),
	@MODIFIED_BY VARCHAR(MAX),
	@REF_ID INT,
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

	SELECT @RECCOUNT=COUNT(*) FROM PES.DBO.REF_CITYCOUN
		WHERE M_CITY=@CITY AND M_COUNTRY=@COUNTRY

	IF @RECCOUNT=0
		BEGIN
			UPDATE PES.DBO.REF_CITYCOUN WITH (UPDLOCK)
				SET M_CITY=@CITY,
					M_COUNTRY=@COUNTRY,
					MODIFIED_BY=@MODIFIED_BY,
					MODIFIED_DT=GETDATE()
			WHERE FCCY_ID=@REF_ID
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
