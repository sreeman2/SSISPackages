/****** Object:  StoredProcedure [dbo].[PES_DELETE_DW_BILLS_BY_LOADNBR]    Script Date: 01/08/2013 14:51:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- AUTHOR:		<DHANYA K S>
-- CREATE DATE: <24 DEC 2012>
-- DESCRIPTION:	<DELETES THE BILLS FROM DW BASED ON LOAD NUMBER>
-- PES_DELETE_DW_BILLS_BY_LOADNBR '9072001'
-- =====================================================================
CREATE PROCEDURE [dbo].[PES_DELETE_DW_BILLS_BY_LOADNBR]
	@LOADNUMBER INT = 0
AS
BEGIN
	-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
	-- INTERFERING WITH SELECT STATEMENTS.
	SET NOCOUNT ON;

DECLARE @SENDEMAILOUTPUT VARCHAR(MAX), @SENDEMAILSUCCESS BIT
   
BEGIN TRAN

update PESDW.DBO.pes_dw_bol set deleted = 'Y',modify_date = getdate(),modify_by = 'TA14903'

where load_number = @LOADNUMBER

update PESDW.DBO.pes_dw_cmd set deleted = 'Y',modify_date = getdate(),modify_by = 'TA14903'

where bol_id in ( select bol_id from PESDW.DBO.pes_dw_bol (nolock) where load_number = @LOADNUMBER)

IF(@@ERROR <> 0)   
BEGIN  
  ROLLBACK TRAN  
  PRINT N'ERROR: TRANSACTION ROLLED BACK BILLS DELETE FAILED';  
END  
ELSE  
BEGIN  
        COMMIT TRAN  
        PRINT N'BILLS DELETED SUCCESSFULLY ON DATAWAREHOUSE';  
    
END  
  

END
GO
