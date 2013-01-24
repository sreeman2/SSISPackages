/****** Object:  StoredProcedure [dbo].[SP_FOREIGN_INFORMATION]    Script Date: 01/08/2013 14:51:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ISSUE#4425
-- MODIFICATIONS - CHANGED THE COUNTRY COLUMN TO PIERS_COUNTRY COLUMN OF THE PES_DW_REF_COUNTRY TABLE 
-- 05-05-2010 



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FOREIGN_INFORMATION] 
	-- Add the parameters for the stored procedure here
   @COMPID  INT OUTPUT, @FNAME VARCHAR(150), @FCITY VARCHAR(150), @FCOUNTRY VARCHAR(250)

AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


--	SELECT @COMPID = COMP_ID FROM PES_DW_NEW_COMPANY 
--	WHERE LTRIM(RTRIM(NAME)) = @FNAME 
--	AND LTRIM(RTRIM(CITY)) = @FCITY 
--	AND LTRIM(RTRIM(CNTRY_CD)) = (SELECT CTRY_CODE FROM PES_DW_REF_COUNTRY WHERE PIERS_COUNTRY = @FCOUNTRY);
  
--IF ( @COMPID = NULL )
--BEGIN
    SELECT @COMPID = COMP_ID FROM PES_DW_REF_COMPANY 
    WHERE 
	( 
		( LTRIM(RTRIM(NAME)) = @FNAME )
		AND ( LTRIM(RTRIM(CITY)) = @FCITY )
		AND 
		( 
			LTRIM(RTRIM(COUNTRY_CD)) = ( SELECT CTRY_CODE FROM PES_DW_REF_COUNTRY WHERE PIERS_COUNTRY = @FCOUNTRY ) 
		)
	)
--END 


-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END;
GO
