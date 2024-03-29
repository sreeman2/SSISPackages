/****** Object:  StoredProcedure [dbo].[SP_NEW_COMPANY_INFORMATION]    Script Date: 01/08/2013 14:51:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_NEW_COMPANY_INFORMATION] 
	-- Add the parameters for the stored procedure here
	@COMPID INT OUTPUT, 
	@CNAME VARCHAR(150), 
	@CCITY VARCHAR(150), 
	@CSTATE VARCHAR(250),
	@CADDRESS VARCHAR(250)

AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	SELECT @COMPID = COMP_ID FROM PES_DW_REF_COMPANY 
		WHERE LTRIM(RTRIM(NAME)) = @CNAME 
			AND LTRIM(RTRIM(CITY)) = @CCITY 
			AND LTRIM(RTRIM(STATE)) = @CSTATE
			AND LTRIM(RTRIM(ADDRESS1)) = @CADDRESS;

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
