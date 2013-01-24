/****** Object:  StoredProcedure [dbo].[SP_REF_COMPANY_INFORMATION]    Script Date: 01/08/2013 14:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<COGNIZANT TECHNOLOGY SOLUTIONS>
-- Create date: <20TH MAY 2010>
-- Description:	<FETCH THE COMPANY ID FROM THE REF COMPANY TABLE>
-- =============================================
CREATE PROCEDURE [dbo].[SP_REF_COMPANY_INFORMATION] 
	-- Add the parameters for the stored procedure here
	@COMPID INT OUTPUT, 
	@CNAME VARCHAR(150), 
	@CCITY VARCHAR(150), 
	@CSTATE VARCHAR(250),
	@CADDRESS VARCHAR(250),
	@DIRECTION CHAR(1)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	IF @DIRECTION = 'I'
	BEGIN
		SELECT @COMPID = COMP_ID FROM PES_DW_REF_COMPANY 
		WHERE LTRIM(RTRIM(NAME)) = @CNAME 
			AND LTRIM(RTRIM(CITY)) = @CCITY 
			AND LTRIM(RTRIM(STATE)) = @CSTATE
			AND LTRIM(RTRIM(ADDRESS1)) = @CADDRESS
	END
	ELSE IF @DIRECTION = 'E'
	BEGIN
		SELECT @COMPID = COMP_ID FROM PES_DW_REF_COMPANY 
		WHERE LTRIM(RTRIM(NAME)) = @CNAME 
			AND LTRIM(RTRIM(CITY)) = @CCITY 
			AND COUNTRY_CD = (SELECT CTRY_CODE FROM PES_DW_REF_COUNTRY WHERE PIERS_COUNTRY = @CSTATE)
			AND LTRIM(RTRIM(ADDRESS1)) = @CADDRESS
	END



--	SELECT @COMPID = COMP_ID FROM PES_RAW.PES.DBO.PES_REF_COMPANY 
--	WHERE LTRIM(RTRIM(NAME)) = @CNAME 
--		AND LTRIM(RTRIM(CITY)) = @CCITY 
--		AND LTRIM(RTRIM(STATE)) = @CSTATE
--		AND LTRIM(RTRIM(ADDRESS1)) = @CADDRESS

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
