/****** Object:  StoredProcedure [dbo].[PES_UPDATE_BLANK_VESSELS]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_UPDATE_BLANK_VESSELS]
AS
IF OBJECT_ID('TEMPUNIQUE') IS NOT NULL 
BEGIN 
    DROP TABLE TEMPUNIQUE
END 
BEGIN TRAN
-- FETCH THE VESSEL NAMES AND THE LATEST VESSEL ID FROM THE REF_VESSEL TABLE
-- FOR THE DISTINCT VESSEL NAMES IN TRANSACTION TABLE FOR TRANSACTION REF ID = 9244
SELECT REF.NAME,MIN(REF.ID) AS ID INTO TEMPUNIQUE
  FROM GTCORE_MASTERDATA.DBO.REF_VESSEL REF,
		(SELECT NAME,MAX(MODIFIED_DT) AS MAXDATE 
           FROM GTCORE_MASTERDATA.DBO.REF_VESSEL 
		  WHERE NAME IN (SELECT ISNULL(VESSEL_NAME,SRC_VESSEL_NAME)  FROM PES.DBO.PES_STG_BOL (NOLOCK)
						  WHERE VESSEL_REF_ID  in (9244,0)
				          GROUP BY ISNULL(VESSEL_NAME,SRC_VESSEL_NAME))
            AND DELETED = 'N'                  
          GROUP BY NAME)SUBQ
WHERE SUBQ.NAME = REF.NAME 
  AND SUBQ.MAXDATE = REF.MODIFIED_DT 
GROUP BY REF.NAME

--SELECT * FROM TEMPUNIQUE (NOLOCK)
-- 46997 ROWS TO BE UPDATED
/*SELECT VESSEL_NAME,COUNT(*) AS CNT
FROM PES.DBO.PES_STG_BOL STG (NOLOCK) , TEMPUNIQUE
WHERE STG.VESSEL_NAME = TEMPUNIQUE.NAME AND VESSEL_REF_ID in (9244,0)
GROUP BY VESSEL_NAME
ORDER BY CNT DESC */

UPDATE STG
SET VESSEL_REF_ID  = ID,MODIFY_DATE = GETDATE()
FROM PES.DBO.PES_STG_BOL STG , TEMPUNIQUE
WHERE STG.VESSEL_NAME = TEMPUNIQUE.NAME AND VESSEL_REF_ID in (9244,0) 
AND STG.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
AND STG.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
AND ISNULL(IS_DELETED,'') <> 'Y' 

-- UPDATE MATCHING THE COMPRESSED VESSEL NAME
/*UPDATE STG
SET VESSEL_REF_ID  = ID,MODIFY_DATE = GETDATE()
FROM PES.DBO.PES_STG_BOL STG , TEMPUNIQUE
WHERE STG.SRC_VESSEL_NAME = TEMPUNIQUE.COMPRESSED_VESSELNAME AND VESSEL_REF_ID in (9244,0) AND ISNULL(IS_DELETED,'') <> 'Y'
*/

IF(@@ERROR <> 0) 
BEGIN
		ROLLBACK TRAN
		PRINT N'ERROR: BLANK VESSEL NAMES UPDATE FAILED';
END
ELSE
BEGIN
        COMMIT TRAN
		PRINT N'VESSEL NAMES UPDATED SUCCESSFULLY';
		
END
GO
