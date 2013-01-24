/****** Object:  UserDefinedFunction [dbo].[PES_UDF_GET_OLD_PORT_CODE]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:		Cognizant
-- Create date: 28-Jan-2010
-- Description:	Get Old Port Code 
-- ================================================================
CREATE FUNCTION [dbo].[PES_UDF_GET_OLD_PORT_CODE](@PortCode varchar(5))
RETURNS VARCHAR(5)
AS
BEGIN
	declare @OldPortCode VARCHAR(5)

	SELECT @OldPortCode = (
			SELECT TOP 1 SOURCE 
			FROM PES.DBO.PES_PORT_CONVERSION
			WHERE TARGET = @PortCode)

	IF @OldPortCode IS NULL SELECT @OldPortCode=@PortCode

	RETURN @OldPortCode

END
GO
