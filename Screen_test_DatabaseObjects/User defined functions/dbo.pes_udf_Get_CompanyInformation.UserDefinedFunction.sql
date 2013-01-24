/****** Object:  UserDefinedFunction [dbo].[pes_udf_Get_CompanyInformation]    Script Date: 01/03/2013 19:53:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cognizant
-- Create date: 31-March-2009
-- Description:	Get Company Information
-- =============================================
CREATE FUNCTION [dbo].[pes_udf_Get_CompanyInformation]
(	
	@BOL_ID		int,
	@Source		char(1)		
)
RETURNS VARCHAR(500)
AS
BEGIN
	declare @Company varchar(max)
	declare @Company_Return varchar(500)

	declare @count int
	select @count=0

	DECLARE @newline char(1)
	select @newline = char(10)

	select @Company = ''
	
	select @count = count(isnull(bol_id,0)) 
	from PES.DBO.PES_Transactions_Exceptions_pty WITH (NOLOCK)
	where BOL_ID = @BOL_ID and source=@Source

	if @count >0
	begin
		---Existence of Company Structure Exceptions		
		--Do not fetch data from PES_Transactions_Exceptions_pty table as it is not needed on UI (current DQA behavior)
			SELECT @Company = (select top 1 '<# '+ cast(str_pty_id as varchar(10)) + '>'+@newline+'<! N>'+@newline+
			'<@ '+ Raw_Name+@newline+Raw_Addr1+@newline+@newline+Raw_Addr2+@newline+Raw_Addr3+@newline+Raw_Addr4+@newline+'>'+@newline+
			'<+ '+ Name +@newline+Addr_1+@newline+Addr_2+@newline+City+@newline+State+@newline+Zip +@newline+'>'+@newline 
			from PES.DBO.[PES_VW_EXCEPTION_COMPANY_INFO] V where V.bol_id=@BOL_ID and V.source=@Source)		
	end
	else if @count = 0
	begin
		-- High/Medium Confidence Company Records & New Company Records
			SELECT @Company =(select top 1 '<#0 >'+@newline+'<! Y>'+@newline+
			 '<@ '+ Raw_Name+@newline+Raw_Addr1+@newline+@newline+Raw_Addr2+@newline+Raw_Addr3+@newline+Raw_Addr4+@newline+'>'+@newline +
			 '<+ '+ Name +@newline+Addr_1+@newline+''+@newline+City+@newline+State+@newline+Zip +@newline+'>'+@newline
			from PES.DBO.[PES_VW_HIGH_MED_CONF_COMPANY_INFO] V where V.bol_id=@BOL_ID and V.source=@Source)		
	end

	select @Company_Return = convert(varchar(500),isnull(@Company,''))
	return @Company_Return
END
GO
