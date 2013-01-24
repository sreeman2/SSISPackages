/****** Object:  StoredProcedure [dbo].[usp_ProcessRestrictedCompanies1]    Script Date: 01/09/2013 18:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProcessRestrictedCompanies1]
	@Direction char(1)
AS
	DECLARE RESTRICTED_LIST_CURSOR CURSOR FOR
	 SELECT COMPANY
	  FROM dbo.restricted_company
	 WHERE (DIR = @Direction OR Dir = 'B')
	  AND EXPIRATION_DATE > getdate()
		
	DECLARE @Company varchar(500)
	
	OPEN RESTRICTED_LIST_CURSOR;

	FETCH NEXT FROM RESTRICTED_LIST_CURSOR INTO @Company;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.usp_ProcessRestrictedCompanies1_iter @Company, @Direction
		FETCH NEXT FROM RESTRICTED_LIST_CURSOR INTO @Company;
	END

	CLOSE RESTRICTED_LIST_CURSOR;
	DEALLOCATE RESTRICTED_LIST_CURSOR;
GO
