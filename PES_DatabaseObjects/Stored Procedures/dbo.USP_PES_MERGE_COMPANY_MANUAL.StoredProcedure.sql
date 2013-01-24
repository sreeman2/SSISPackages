/****** Object:  StoredProcedure [dbo].[USP_PES_MERGE_COMPANY_MANUAL]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_PES_MERGE_COMPANY_MANUAL]
	@MergeFromCompIdList VARCHAR(8000),
	@MergeIntoComp_Id INT,
	@UserName VARCHAR(25)
AS
BEGIN


	-- [aa] - 11/28/2010
	-- Log start time
	DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
	SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
	,@ParametersIn = NULL
	EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
	 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @SeparatorIndex INT
	DECLARE @MergeFromComp_Id INT
	DECLARE @NextCompIdLength INT
	DECLARE @MergeFromCompIdListSeparator VARCHAR(1)

	SET @MergeFromCompIdListSeparator = ','

	DECLARE @TRANNAME VARCHAR(20),@TRANNAME1 VARCHAR(20), @ERROR_MESSAGE VARCHAR(1000),  
	@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50)  
	SET @TRANNAME = 'MyTransaction'  



			WHILE LEN(@MergeFromCompIdList) > 0
			BEGIN
				SET @NextCompIdLength = (CHARINDEX(@MergeFromCompIdListSeparator,@MergeFromCompIdList)-1)
				IF @NextCompIdLength = -1
					SET @NextCompIdLength = LEN(@MergeFromCompIdList)
					
				SET @MergeFromComp_Id = CAST(SUBSTRING(@MergeFromCompIdList, 1, (@NextCompIdLength)) AS INT)

				SET @MergeFromCompIdList = SUBSTRING(@MergeFromCompIdList, @NextCompIdLength+1, (LEN(@MergeFromCompIdList)-@NextCompIdLength))
				IF @NextCompIdLength = LEN(@MergeFromCompIdList)
					SET @MergeFromCompIdList = ''	
				IF LEFT(@MergeFromCompIdList, LEN(@MergeFromCompIdListSeparator)) = @MergeFromCompIdListSeparator
					SET @MergeFromCompIdList = SUBSTRING(@MergeFromCompIdList, LEN(@MergeFromCompIdListSeparator)+1, (LEN(@MergeFromCompIdList)-LEN(@MergeFromCompIdListSeparator)))


	BEGIN TRY  

		BEGIN TRANSACTION  

				--Step-1 Insert into PES_MERGE_HISTORY Table
				INSERT INTO PES_MERGE_HISTORY  (Comp_ID,Is_UsComp,Comp_Nbr,Duns_Number,Nbr_Shipments,Name,Match_Flag,Address1,City,State,Zip,Country,Verified,Modified_By,Modified_Dt,Created_By,Created_Dt) 
				SELECT Comp_ID,Is_UsComp,Comp_Nbr,Duns_Number,Nbr_Shipments,Name,Match_Flag,Address1,City,State,Zip,Country,Verified,Modified_By,Modified_Dt,Created_By,Created_Dt
				FROM dbo.PES_Ref_Company WITH (NOLOCK) WHERE Comp_Id=@MergeFromComp_Id


				--Step-2 Find Library Records from PES_LIB_COMPANY and Add into PES_MERGE_WORK Table
				INSERT INTO PES_MERGE_WORK(From_Comp_ID,To_Comp_ID,Update_Status,Created_By,Created_Dt) 
				VALUES (@MergeFromComp_Id,@MergeIntoComp_Id,0,@UserName,GETDATE())


				--Step-3 Update PES_LIB_COMPANY table with new Cluster ID 
				UPDATE PES_LIB_COMPANY SET Prev_Cluster_ID=Cluster_ID,Cluster_ID=@MergeIntoComp_Id,
					Verified=1,Modified_By=@UserName,Modified_Dt=GETDATE() WHERE Cluster_ID=@MergeFromComp_Id


				--Step-4 Delete Merged Records from PES_REF_COMPANY 
				DELETE FROM PES_REF_COMPANY WHERE Comp_ID=@MergeFromComp_Id

		COMMIT  

	END TRY
	BEGIN CATCH  
	  SET @ERROR_NUMBER=ERROR_NUMBER()  
	  SET @ERROR_LINE=ERROR_LINE()  
	  SET @ERROR_MESSAGE='Stored Procedure '+@SprocName+' failed with ERROR DESCRIPTION:  '+ERROR_MESSAGE()  
	  
	  IF @@TRANCOUNT > 0
		 ROLLBACK

	  
	  RAISERROR(@ERROR_MESSAGE,5,1) 
	 
	END CATCH

			END
	
	
			--Update Master Records Verfied tag to 1=true
			UPDATE PES_REF_COMPANY SET verified=1 WHERE Comp_ID=@MergeIntoComp_Id

			--Update the PES_REF_COMPANY_DETAIL Table
			UPDATE PES_REF_COMPANY_DETAIL SET MergeAgentId=@UserName,MergeDate=GETDATE() WHERE Comp_ID=@MergeIntoComp_Id 




	
-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
