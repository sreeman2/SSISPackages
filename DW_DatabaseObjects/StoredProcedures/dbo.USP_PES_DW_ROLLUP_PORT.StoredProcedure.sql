/****** Object:  StoredProcedure [dbo].[USP_PES_DW_ROLLUP_PORT]    Script Date: 01/08/2013 14:51:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_PES_DW_ROLLUP_PORT]
AS 
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

DECLARE @TRANNAME VARCHAR(20), @ERROR_MESSAGE VARCHAR(1000),  
@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50)  
SET @TRANNAME = 'MyTransaction'  

 
BEGIN TRY  

BEGIN TRANSACTION @TRANNAME 
--SAVVIS DATAWAREHOUSE

INSERT INTO PES_DW_PORT_MERGE_WORK
SELECT * FROM PES_RAW.PES.DBO.PES_PORT_MERGE_WORK 

--DELETE FROM PES_DW_REF_PORT
--DELETE FROM PES_DW_REF_PORT WHERE ID IN(SELECT FROM_PORT_ID FROM PES_DW_PORT_MERGE_WORK WITH (NOLOCK))

UPDATE A WITH (UPDLOCK) SET A.PORT_DEPART_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_BOL A 
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.PORT_DEPART_REF_ID=B.FROM_PORT_ID

UPDATE A WITH (UPDLOCK) SET A.PORT_ARRIVE_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_BOL A
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.PORT_ARRIVE_REF_ID=B.FROM_PORT_ID

UPDATE A WITH (UPDLOCK) SET A.ULTPORT_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_BOL A
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.ULTPORT_REF_ID=B.FROM_PORT_ID

UPDATE A WITH (UPDLOCK) SET A.PLACE_OF_RECIEPT_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_BOL A
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.PLACE_OF_RECIEPT_REF_ID=B.FROM_PORT_ID


------
UPDATE A WITH (UPDLOCK) SET A.PORT_DEPART_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_MASTER_BOL A 
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.PORT_DEPART_REF_ID=B.FROM_PORT_ID

UPDATE A WITH (UPDLOCK) SET A.PORT_ARRIVE_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_MASTER_BOL A
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.PORT_ARRIVE_REF_ID=B.FROM_PORT_ID

UPDATE A WITH (UPDLOCK) SET A.ULTPORT_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_MASTER_BOL A
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.ULTPORT_REF_ID=B.FROM_PORT_ID

UPDATE A WITH (UPDLOCK) SET A.PLACE_OF_RECIEPT_REF_ID=B.TO_PORT_ID,A.MODIFY_DATE=GETDATE()
FROM PES_DW_MASTER_BOL A
  JOIN PES_DW_PORT_MERGE_WORK B WITH (NOLOCK) ON 
    A.PLACE_OF_RECIEPT_REF_ID=B.FROM_PORT_ID


TRUNCATE TABLE PES_DW_PORT_MERGE_WORK

COMMIT TRANSACTION @TRANNAME  

END TRY
BEGIN CATCH  
  SET @ERROR_NUMBER=ERROR_NUMBER()  
  SET @ERROR_LINE=ERROR_LINE()  
  SET @ERROR_MESSAGE='Stored Procedure USP_PES_DW_ROLLUP_PORT of Savvis Data Warehouse failed with ERROR DESCRIPTION:  '+ERROR_MESSAGE()

  ROLLBACK TRANSACTION @TRANNAME  
  
  EXEC PES_RAW.PES.DBO.PES_SP_EMAIL 'Port Rollup Process Failed','Port Rollup Process Failed',@ERROR_MESSAGE,@ERROR_LINE,@ERROR_NUMBER
 
  RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG

END CATCH

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
