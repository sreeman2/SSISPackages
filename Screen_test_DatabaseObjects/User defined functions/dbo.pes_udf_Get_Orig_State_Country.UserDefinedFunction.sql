/****** Object:  UserDefinedFunction [dbo].[pes_udf_Get_Orig_State_Country]    Script Date: 01/03/2013 19:53:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 23-March-2009
-- Description:	Get Orig State or Country
-- =============================================
CREATE FUNCTION [dbo].[pes_udf_Get_Orig_State_Country]
(	
	@ORG_DEST_CD	varchar(5),
	@ORG_DEST_COUNST varchar(7),
	@Option varchar(10)
)
RETURNS varchar(7)
AS
BEGIN
	declare @ReturnValue varchar(7)
	declare @ORG_DEST_ST varchar(7)
	declare @ORG_DEST_COUN varchar(7)

	---CHECK DEST COUNTRY OR STATE
	IF LEN(@ORG_DEST_CD)=4
	BEGIN
		SET @ORG_DEST_ST=LTRIM(RTRIM(@ORG_DEST_COUNST))
		SET @ORG_DEST_COUN=NULL
	END
	ELSE IF LEN(@ORG_DEST_CD)=5
	BEGIN
		SET @ORG_DEST_COUN=LTRIM(RTRIM(@ORG_DEST_COUNST))
		SET @ORG_DEST_ST=NULL
	END

	-- Return the result of the function
	if @Option = 'STATE'
		select @ReturnValue= @ORG_DEST_ST
	else if @Option = 'COUNTRY'
		select @ReturnValue= @ORG_DEST_COUN
	else
		select @ReturnValue=''
	
	return @ReturnValue
END
GO
