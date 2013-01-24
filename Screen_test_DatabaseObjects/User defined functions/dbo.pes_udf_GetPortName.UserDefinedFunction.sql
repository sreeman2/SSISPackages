/****** Object:  UserDefinedFunction [dbo].[pes_udf_GetPortName]    Script Date: 01/03/2013 19:53:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 23-March-2009
-- Description:	Get Port Name corresponding to ID
-- =============================================
CREATE FUNCTION [dbo].[pes_udf_GetPortName]
(	
	@ID int
)
RETURNS varchar(35)
AS
BEGIN
	declare @PortName varchar(35)

	select @PortName = PIERS_NAME 
	FROM PES.DBO.REF_PORT WITH (NOLOCK)
	WHERE ID=@ID

	-- Return the result of the function
	RETURN @PortName
END
GO
