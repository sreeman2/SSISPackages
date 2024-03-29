/****** Object:  StoredProcedure [dbo].[PES_Automatic_Add_Lib_Ref_Company]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_Automatic_Add_Lib_Ref_Company]
AS
BEGIN

SET NOCOUNT ON

	DECLARE @Status VARCHAR(50)
	DECLARE @User VARCHAR(50)	 

	SET @Status = 'CLEANSED'
	SET @User = 'dwh'

BEGIN TRY

BEGIN TRAN

	--Insert into #Temp_PES_TRANSACTIONS_LIB_PTY table for the company exception record with the record status as PENDING.
	SELECT DISTINCT 
		A.STR_PTY_ID,
		A.BOL_ID,
		A.Comp_ID,
		NULL Cluster_ID,
		A.Source,
		A.Company_Nbr,
		LTRIM(RTRIM(A.Name)) Name,
		'N' Is_USComp,
		LTRIM(RTRIM(ISNULL(A.Addr_1,''))) Addr_1,
		LTRIM(RTRIM(A.City)) City,
		LTRIM(RTRIM(A.State)) State,
		A.cntry_cd,
		A.Postal_cd 
	INTO #Temp_PES_TRANSACTIONS_LIB_PTY
	FROM PES.DBO.PES_TRANSACTIONS_LIB_PTY A WITH (NOLOCK) 
		INNER JOIN RAW_PTY B WITH (NOLOCK) ON A.BOL_ID=B.BOL_ID
	WHERE A.Comp_ID IS NULL AND LEN(ISNULL(A.Name, '')) > 0 AND A.Status='PENDING'

	CREATE NONCLUSTERED INDEX IDX_Temp_PES_TRANSACTIONS_LIB_PTY ON #Temp_PES_TRANSACTIONS_LIB_PTY 
		(STR_PTY_ID, BOL_ID, Name, Addr_1, City, State, cntry_cd, Postal_cd)
		
	--Update COMP_ID in the #Temp_PES_TRANSACTIONS_LIB_PTY table for the existing company records in PES_LIB_COMPANY table.
	UPDATE A 
		SET A.Comp_ID = B.Comp_ID, A.Cluster_ID = B.Cluster_ID
	FROM #Temp_PES_TRANSACTIONS_LIB_PTY A
		INNER JOIN PES_LIB_Company B ON
			A.Name = B.Name 
			AND A.Addr_1 = LTRIM(RTRIM(ISNULL(B.Address1,'')))
			AND A.City = B.City  
			AND A.State = B.State 
			AND A.Postal_cd = B.zip
			AND A.cntry_cd = B.country
	
	-- Update USCOMP flag as Y, if the country code is 100 otherwise default value N
	UPDATE #Temp_PES_TRANSACTIONS_LIB_PTY SET Is_USComp = 'Y' 
	WHERE cntry_cd = '100'

	--Insert into PES_LIB_COMPANY table for a new company records.
	INSERT INTO [PES].[dbo].[PES_LIB_Company]
	(
	   [Name]		,
	   [Is_USComp]  ,
	   [Address1]	,
	   [City]		,
	   [State]		,
	   [Zip]		,
	   [Country]	,
	   [Verified]	,
	   [Cluster_ID]	,
	   [Created_By]	,
	   [Created_Dt]	,
	   [Modified_By],	
	   [Modified_Dt]
	)
	SELECT DISTINCT Name, Is_USComp, Addr_1, City, State, Postal_cd, cntry_cd, 0, 
		Cluster_ID, @User, GETDATE(), @User, GETDATE() 
	FROM #Temp_PES_TRANSACTIONS_LIB_PTY
	WHERE Comp_ID IS NULL

	--Update the Comp_ID in #Temp_PES_TRANSACTIONS_LIB_PTY table for the existing company records.
	UPDATE A 
	SET A.Comp_ID = B.Comp_ID
	FROM #Temp_PES_TRANSACTIONS_LIB_PTY A
		INNER JOIN PES_LIB_Company B ON
			A.Name = B.Name 
			AND ISNULL(A.Addr_1,'') = ISNULL(B.Address1,'')  
			AND A.City = B.City  
			AND A.State = B.State 
			AND A.Postal_cd = B.zip
			AND A.cntry_cd = B.country
	WHERE A.Comp_ID IS NULL 
	 	
	--Insert into PES_Ref_Company table for a new company records.
	IF EXISTS(SELECT TOP 1 Comp_ID FROM #Temp_PES_TRANSACTIONS_LIB_PTY
				WHERE Comp_ID IS NOT NULL AND Cluster_ID IS NULL)
	BEGIN
		INSERT INTO [PES].[dbo].[PES_Ref_Company]
		(
		   [Comp_ID]		,
		   [Is_USComp]		,
		   [Name]			,
		   [Address1]		,
		   [City]			,
		   [State]			,
		   [Zip]			,
		   [Country]		,
		   [Verified]		,
		   [Created_By]		,
		   [Created_Dt]		,
		   [Modified_By]	,
		   [Modified_Dt]
		)
		SELECT DISTINCT Comp_ID, Is_USComp, Name, Addr_1, City, State, 
			Postal_cd, cntry_cd, 0, @User, GETDATE(), @User, GETDATE() 
		FROM #Temp_PES_TRANSACTIONS_LIB_PTY
		WHERE Comp_ID IS NOT NULL AND Cluster_ID IS NULL
	END

	--Update cluster_Id in the PES_LIB_COMPANY table for a new company records.
	UPDATE PES_LIB_Company SET Cluster_ID = Comp_ID
	WHERE Cluster_ID IS NULL AND Created_By = @User

	--Update Comp_ID, Status=CLEANSED in the PES_TRANSACTIONS_LIB_PTY table for a new and existing company records.
	UPDATE A
		SET A.Comp_ID = B.Comp_ID, Status = @Status, MODIFIED_DT = GETDATE(), MODIFIED_BY = @User 
	FROM PES_TRANSACTIONS_LIB_PTY A 
		INNER JOIN #Temp_PES_TRANSACTIONS_LIB_PTY B ON
			A.STR_PTY_ID = B.STR_PTY_ID
	WHERE B.Comp_ID IS NOT NULL
		
	CREATE NONCLUSTERED INDEX IDX_Temp_PES_TRANSACTIONS_LIB_PTY_Comp_ID ON #Temp_PES_TRANSACTIONS_LIB_PTY (Comp_ID)

	--This is an auto generated match - update the auto match date
	UPDATE A
		SET AutoMatchDate = GETDATE()
	FROM PES_Ref_Company_Detail A
		INNER JOIN #Temp_PES_TRANSACTIONS_LIB_PTY B ON
			A.COMP_ID = B.COMP_ID
	WHERE B.Comp_ID IS NOT NULL AND B.Cluster_ID IS NULL

	DROP TABLE #Temp_PES_TRANSACTIONS_LIB_PTY

	COMMIT TRAN

END TRY
BEGIN CATCH
	--PRINT 'ERROR'
	ROLLBACK TRAN
END CATCH
	
END
GO
