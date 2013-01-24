/****** Object:  StoredProcedure [dbo].[PES_UPDATE_COMPANY_DETAIL]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_UPDATE_COMPANY_DETAIL]     

@Comp_ID int,
@Is_UsComp char(1),
@Comp_Nbr varchar(14),
@Duns_Number char(11),
@Nbr_Shipments int,
@Name varchar(150),
@Address1 varchar(125),
@City varchar(125),
@State varchar(9),
@Zip varchar(15),
@Country char(3),
@Verified bit,
@Match_Flag bit,
@Created_By varchar(25),
@Created_Dt datetime,
@Modified_By varchar(25),
@Modified_Dt datetime,

@LastShipmentDate datetime,
@AutoMatchDate datetime,
@AgentMatchDate datetime,
@MatchAgentId varchar(25),
@MergeDate datetime,
@MergeAgentId varchar(25),
@ShipmentCount24Months int,
@ShipmentCount12Months int,
@CompanyUrl varchar(255),
@CompanyEmail varchar(255),
@CompanySic varchar(50),
@CompanyPhone varchar(50),
@CassValidDate datetime,
@ExternalReferenceVerifyDate datetime,
@ExternalReferenceSource varchar(255),
@QualityClassScore int,
@IsPiersCustomer bit,
@IsNvocc bit,
@ScacCode varchar(50),
@IsFreightForwarder bit,

@YearStarted int,
@NumberOfEmployees int,
@IsPublicCompany bit,
@AnnualSalesDollars money,
@NetIncomeDollars money,
@MarketCapDollars money,
@NaicsCode varchar(50),

@FmcLicenseCode varchar (50),
@UNLoCode varchar (50),
@PublicCompanySymbol varchar (50),

@BinaryX bit,
@ValueX int,
@NotesX varchar(255),
@NotesX2 varchar(255),
@NotesX3 varchar(255),

@IsPersonalName bit = 0

AS  
BEGIN  

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @detailComp_id int
SELECT @detailComp_id = COMP_ID FROM [PES_REF_Company_Detail] where Comp_ID=@Comp_ID

IF @detailComp_id is null
BEGIN
	INSERT INTO [PES_REF_Company_Detail] (Comp_ID) values (@Comp_ID)
END

--Begin Transaction
BEGIN TRAN 

update [PES_REF_Company] set

	   [Comp_ID] = @Comp_ID
      ,[Is_UsComp] = @Is_UsComp
      ,[Comp_Nbr] = @Comp_Nbr
      ,[Duns_Number] = @Duns_Number
      ,[Nbr_Shipments] = @Nbr_Shipments
      ,[Name] = @Name
      ,[Address1] = @Address1
      ,[City] = @City
      ,[State] = @State
      ,[Zip] = @Zip
      ,[Country] = @Country
      ,[Verified] = @Verified
      ,[Match_Flag] = @Match_Flag
      ,[Created_By] = @Created_By
      ,[Created_Dt] = @Created_Dt
      ,[Modified_By] = @Modified_By
      ,[Modified_Dt] = GETDATE()
      ,[IsPersonalName] = @IsPersonalName
where [comp_id]=@comp_id




update [PES_REF_Company_Detail] set 
      LastShipmentDate = @LastShipmentDate
      ,AutoMatchDate = @AutoMatchDate
      ,AgentMatchDate = @AgentMatchDate
      ,MatchAgentId = @MatchAgentId
      ,MergeDate = @MergeDate
      ,MergeAgentId = @MergeAgentId
      ,ShipmentCount24Months = @ShipmentCount24Months
      ,ShipmentCount12Months = @ShipmentCount12Months
      ,CompanyUrl = @CompanyUrl
      ,CompanyEmail = @CompanyEmail
      ,CompanySic = @CompanySic
      ,CompanyPhone = @CompanyPhone
      ,CassValidDate = @CassValidDate
      ,ExternalReferenceVerifyDate = @ExternalReferenceVerifyDate
      ,ExternalReferenceSource = @ExternalReferenceSource
      ,QualityClassScore = @QualityClassScore
      ,IsPiersCustomer = @IsPiersCustomer
      ,IsNvocc = @IsNvocc
      ,ScacCode = @ScacCode
      ,IsFreightForwarder = @IsFreightForwarder

	  ,YearStarted = @YearStarted
	  ,NumberOfEmployees = @NumberOfEmployees
	  ,IsPublicCompany = @IsPublicCompany
	  ,AnnualSalesDollars = @AnnualSalesDollars
	  ,NetIncomeDollars = @NetIncomeDollars
	  ,MarketCapDollars = @MarketCapDollars
	  ,NaicsCode = @NaicsCode

	  ,FmcLicenseCode = @FmcLicenseCode
	  ,UNLoCode = @UNLoCode
	  ,PublicCompanySymbol = @PublicCompanySymbol

      ,BinaryX = @BinaryX
      ,ValueX = @ValueX
      ,NotesX = @NotesX
      ,NotesX2 = @NotesX2
      ,NotesX3 = @NotesX3

where [comp_id]=@comp_id

COMMIT TRAN 


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
