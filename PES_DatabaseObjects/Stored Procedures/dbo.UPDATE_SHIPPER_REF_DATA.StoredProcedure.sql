/****** Object:  StoredProcedure [dbo].[UPDATE_SHIPPER_REF_DATA]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_SHIPPER_REF_DATA]
	-- Add the parameters for the stored procedure here
	@COMP_ID INT, 
	@CNAME VARCHAR(150), 
	@CCITY VARCHAR(150), 
	@CSTATE VARCHAR(250),
	@CADDRESS VARCHAR(250),
	@USERNAME VARCHAR(150)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	UPDATE PES_REF_COMPANY WITH (UPDLOCK)
	SET [NAME] = @CNAME, 
		CITY = @CCITY,
		STATE = @CSTATE,
		ADDRESS1 = @CADDRESS,
		MODIFIED_BY = @USERNAME,
		MODIFIED_DT = GETDATE()
	WHERE COMP_ID = @COMP_ID

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
