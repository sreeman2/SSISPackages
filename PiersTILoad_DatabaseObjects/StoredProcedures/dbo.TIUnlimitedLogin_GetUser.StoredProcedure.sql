/****** Object:  StoredProcedure [dbo].[TIUnlimitedLogin_GetUser]    Script Date: 01/09/2013 18:40:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Object:			StoredProcedure [dbo].[TIUnlimitedLogin_GetUser]    
-- Created Date:	Oct-27--2011
-- Author:			Harish Sreekumar
-- Description:		This SP will accept @CompanyPrefix (Ex: ITA) as parameter. 
--					and gives back a UserId, which will be used for login.
-- NOTES:			NONE
-- ============================================================================



CREATE PROCEDURE [dbo].[TIUnlimitedLogin_GetUser](
      @CompanyPrefix     varchar(100),
      @Location     varchar(1000)
)
AS
BEGIN

	DECLARE @UserID varchar(4000)
	SELECT  TOP 1 @UserID= UserID FROM TIUnlimitedLogin WHERE IsLoggedIn='N'
	IF @@Rowcount=0 
	BEGIN
		SELECT  TOP 1 @UserID= UserID FROM TIUnlimitedLogin WHERE
		ModifiedDate=(SELECT min(ModifiedDate) FROM TIUnlimitedLogin)--As per logic we have to knock 1 user out and assign the userId to new request
	END
UPDATE TIUnlimitedLogin SET IsLoggedIn='Y',ModifiedDate=GetDate() WHERE UserID=@UserID
INSERT INTO  TIUnlimitedLogin_Location 
SELECT @UserID AS UserID,@Location  as Location,GETDATE() as ModifiedDate-- Inserting in Location table to track logins
SELECT @UserID AS UserID
End
GO
