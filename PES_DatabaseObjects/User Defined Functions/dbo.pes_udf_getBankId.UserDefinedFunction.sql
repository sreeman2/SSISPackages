/****** Object:  UserDefinedFunction [dbo].[pes_udf_getBankId]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 20-March-2009
-- Description:	Get Bank Name
-- =============================================
CREATE FUNCTION [dbo].[pes_udf_getBankId]
(
	@BANK_NAME	varchar(37)

)
RETURNS int
AS
BEGIN
	DECLARE @BANK_ID int
	SELECT @BANK_ID = NULL

	IF @BANK_NAME IS NOT NULL 
	BEGIN
		SELECT @BANK_ID=BANK_ID FROM REF_BANK WITH (NOLOCK) WHERE DBO.PES_UDF_REMOVE_SPECIAL_CHARACTERS(BANK_NAME)=DBO.PES_UDF_REMOVE_SPECIAL_CHARACTERS(@BANK_NAME)
		
	END 

	RETURN @BANK_ID
END
GO
