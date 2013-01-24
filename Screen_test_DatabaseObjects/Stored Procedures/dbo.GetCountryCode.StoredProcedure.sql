/****** Object:  StoredProcedure [dbo].[GetCountryCode]    Script Date: 01/03/2013 19:47:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCountryCode]  
	-- Add the parameters for the stored procedure here
@In_Country  VARCHAR(100), 
@Out_Country_Code VARCHAR(2) OUT 
AS

BEGIN
set nocount on

---- [aa] - 09/24/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
-- '@In_Country='''+@In_Country+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
-- @SprocName = 'GetCountryCode'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@In_Country='''+@In_Country+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	declare @Country varchar(32)
	declare @TempCountry varchar(32)
	declare @SingleCount int
	declare @MultiCount int

	declare @CountryCode varchar(2)	

	select @TempCountry=''
	select @SingleCount=0
	select @MultiCount=0

	set @Country = @In_Country

	--First check the count of records in REF_COUNTRY where PIERS_COUNTRY matches input country
	select @SingleCount = isnull(count(@Country),0) from PES.DBO.ref_country WITH (NOLOCK)
	where piers_country =  @Country

	if @SingleCount=1
	begin
		set @Out_Country_Code = (select [ISO ALPHA-2 code]
		from PES.DBO.ref_country WITH (NOLOCK)
		where piers_country =  @Country)
	end
	else if @SingleCount>1
	begin
		select @TempCountry = @Country+'%'

		select @MultiCount=isnull(count(country),0) 
		from PES.DBO.ref_country WITH (NOLOCK)
		where country like  @TempCountry 
		and piers_country =  @Country

		if @MultiCount = 0
		begin
			set @Out_Country_Code = (select top 1 [ISO ALPHA-2 code]
			from PES.DBO.ref_country WITH (NOLOCK)
			where piers_country =  @Country
			and isnull([ISO ALPHA-2 code],'') <> '')
		end
		else if @MultiCount > 0
		begin
			set @Out_Country_Code =(select top 1 [ISO ALPHA-2 code]
			from PES.DBO.ref_country WITH (NOLOCK)
			where country like  @TempCountry 
			and piers_country =  @Country
			and isnull([ISO ALPHA-2 code],'') <> ''
			)
		end
		
	end
	else if isnull(@SingleCount,0) =0
	begin
		set @Out_Country_Code='YY'
	end

-- [aa] - 09/24/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
