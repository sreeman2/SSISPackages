/****** Object:  StoredProcedure [dbo].[PES_UPDATE_BLANK_REGISTRY]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_UPDATE_BLANK_REGISTRY]          
AS          
IF OBJECT_ID('TEMPREGISTRY') IS NOT NULL           
BEGIN           
    DROP TABLE TEMPREGISTRY          
END           
IF OBJECT_ID('REG_UPDATE') IS NOT NULL           
BEGIN           
    DROP TABLE REG_UPDATE          
END           
BEGIN TRAN          
DECLARE @LOADNUMBER int      
SET @LOADNUMBER = null  
      
-- GET THE LOADNUMBER OF THE CURRENTLY RUNNING FEED.          
SELECT @LOADNUMBER = LOADNUMBER           
FROM PES.DBO.PES_PROGRESS_STATUS P (NOLOCK) ,SCREEN_TEST.DBO.FEEDLOADPRIORITY L (NOLOCK)          
WHERE P.FILENAME = L.FEEDFILENAME          
  AND L.STATUS = 'PICKEDUPBYPES'  
  
PRINT @LOADNUMBER  
  
          
-- FETCH THE RECORDS WITH REGISTRY EXCEPTIONS          
-- FIND THE COUNTRY FOR THESE VESSELS FROM REF_VESSEL TABLE          
SELECT STG.BOL_ID,stg.registry_id,REF.VESSEL_COUNTRY           
INTO TEMPREGISTRY          
FROM PES_STG_BOL STG (NOLOCK),REF_VESSEL REF(NOLOCK)          
WHERE STG.VESSEL_REF_ID = REF.ID          
AND STG.REGISTRY_ID = 0          
AND STG.REF_LOAD_NUM_ID = @LOADNUMBER          
AND ISNULL(IS_DELETED,'') <> 'Y'        
AND STG.RECORD_STATUS IN('CLEANSED','AUTOMATED')         
AND STG.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY')        
AND QC_VALID = 'Y'        
        
-- GET THE COUNTRY ID FROM REF_COUNTRY TABLE        
SELECT REF.COUNTRY_ID,UPD.*           
INTO REG_UPDATE          
FROM TEMPREGISTRY UPD,REF_COUNTRY REF          
WHERE UPD.VESSEL_COUNTRY = COUNTRY          

   
UPDATE STG SET REGISTRY_ID = UPD1.COUNTRY_ID,MODIFY_DATE = GETDATE(),MODIFY_USER = 'US7276'          
--SELECT vessel_ref_id,vessel_name,src_vessel_name,upd1.*        
FROM PES_STG_BOL STG (nolock),REG_UPDATE UPD1 (nolock)         
WHERE STG.BOL_ID = UPD1.BOL_ID         
      
UPDATE CMD SET MODIFY_DATE = GETDATE()      
FROM PES_STG_CMD CMD      
WHERE BOL_ID IN (SELECT BOL_ID FROM TEMPREGISTRY)  
    
        
IF(@@ERROR <> 0)           
BEGIN          
  ROLLBACK TRAN          
  PRINT N'ERROR: BLANK REGISTRY NAMES UPDATE FAILED';          
END          
ELSE          
BEGIN          
        COMMIT TRAN          
  PRINT N'BLANK REGISTRY NAMES UPDATED SUCCESSFULLY';          
            
END
GO
