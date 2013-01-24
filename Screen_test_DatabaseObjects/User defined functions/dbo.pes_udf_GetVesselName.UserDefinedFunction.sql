/****** Object:  UserDefinedFunction [dbo].[pes_udf_GetVesselName]    Script Date: 01/03/2013 19:53:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 23-March-2009
-- Description:	Get Vessel Name corresponding to ID
-- =============================================
CREATE FUNCTION [dbo].[pes_udf_GetVesselName]
(	
	@ID int
)
RETURNS varchar(35)
AS
BEGIN
	declare @VesselName varchar(35)

	select @VesselName = [NAME] 
	FROM PES.DBO.REF_VESSEL WITH (NOLOCK)
	WHERE ID=@ID

	-- Return the result of the function
	RETURN @VesselName
END
GO
