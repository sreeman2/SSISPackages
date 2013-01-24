/****** Object:  StoredProcedure [dbo].[TIUnlimitedLogin_CreateUser]    Script Date: 01/09/2013 18:40:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Object:			StoredProcedure [dbo].[TIUnlimitedLogin_CreateUser]    
-- Created Date:	Oct-26--2011
-- Author:			Harish Sreekumar
-- Description:		This SP will accept @CompanyPrefix (Ex: ITA),@StartNumber (Ex:1),
--                  @EndNumber(Ex:10) as parameters. So this will add ITA1 to ITA10
--                  to table dbo.TIUnlimitedLogin.
-- NOTES:			NONE
-- ============================================================================



CREATE PROCEDURE [dbo].[TIUnlimitedLogin_CreateUser](
      @CompanyPrefix     varchar(100),
      @StartNumber int,
      @EndNumber int
)
AS
BEGIN

DECLARE @UserID varchar(4000),@Counter int
SET @Counter=@StartNumber
WHILE @Counter<=@EndNumber
	BEGIN
		SET @UserID=@CompanyPrefix + CONVERT(varchar(4000),  @Counter)
		INSERT INTO dbo.TIUnlimitedLogin
			SELECT @UserID as UserID,@CompanyPrefix  as CompanyPrefix ,
			'N' as ISLoggedIn,getdate() as ModifiedDate
		SET @Counter=@Counter+1
	END

End
GO
