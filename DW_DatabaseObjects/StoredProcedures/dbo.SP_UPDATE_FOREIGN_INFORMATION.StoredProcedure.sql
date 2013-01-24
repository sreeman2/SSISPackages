/****** Object:  StoredProcedure [dbo].[SP_UPDATE_FOREIGN_INFORMATION]    Script Date: 01/08/2013 14:51:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATE_FOREIGN_INFORMATION] 
	-- Add the parameters for the stored procedure here
	@FNAME VARCHAR(50), @FCITY VARCHAR(50), @FCOUNTRY VARCHAR(50), @FADDR VARCHAR(150),
    @BOLID INT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	
 UPDATE PES_DW_REF_COMPANY SET
  NAME = @FNAME,
  CITY = @FCITY,  
  ADDRESS1 = @FADDR
  WHERE COMP_ID = (SELECT SHIPPER_COMP_REF_ID FROM PES_DW_BOL WHERE BOL_ID = @BOLID);

  UPDATE PES_DW_REF_COUNTRY  SET 
  COUNTRY = @FCOUNTRY
  WHERE CTRY_CODE = (SELECT COUNTRY_CD FROM PES_DW_REF_COMPANY WHERE COMP_ID = 
                     (SELECT SHIPPER_COMP_REF_ID FROM PES_DW_BOL WHERE BOL_ID = @BOLID));

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
