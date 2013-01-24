/****** Object:  StoredProcedure [dbo].[PES_REMOVE_STG_DIS_DUPLICATES_NEW]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_REMOVE_STG_DIS_DUPLICATES_NEW]       
(       
 @YEAR VARCHAR(20) = '2012',      
 @MONTH VARCHAR(50) = '03,04,05,06,07,08,09,10,11,12',      
 @DIS_VENDOR_CODE VARCHAR(20) = 'DIS',      
 @OTHER_VENDOR_CODE VARCHAR(100) = 'APLU,ESCAN,CRLE,CSCO,EVER,MAEU,MES,OOLU,SBRE,TRBR'      
)      
AS  
  
SET NOCOUNT ON;      
    
BEGIN TRAN     
  
TRUNCATE TABLE TEMP_PES.DBO.DIS_DUPLICATES1      
TRUNCATE TABLE TEMP_PES.DBO.ESCAN_DUPLICATES1      
TRUNCATE TABLE TEMP_PES.DBO.DISESCAN_DUPLICATES1       


PRINT 'TABLE TRUNCATED'

--DROP INDEX IDX_DIS1 ON TEMP_PES.DBO.DIS_DUPLICATES1  
--DROP INDEX IDX_ESCAN1 ON TEMP_PES.DBO.ESCAN_DUPLICATES1  
--DROP INDEX IDX_DISESCAN1 ON TEMP_PES.DBO.DISESCAN_DUPLICATES1  

PRINT 'INDEXES DROPPED'
  
      
SET @MONTH =  REPLACE(@MONTH,',',''',''')       
SET @OTHER_VENDOR_CODE = REPLACE(@OTHER_VENDOR_CODE,',',''',''')      
      
DECLARE @SQL NVARCHAR(500)      
DECLARE @SQL2 NVARCHAR(500)      
DECLARE @SQL3 NVARCHAR(500)      
DECLARE @SQL4 NVARCHAR(500)       
DECLARE @SQL5 NVARCHAR(500)       
DECLARE @SQL6 NVARCHAR(500)  
DECLARE @SENDEMAILOUTPUT VARCHAR(MAX), @SENDEMAILSUCCESS BIT 
   

-- FIND THE DUPLICATE BILL NUMBERS FROM DIS AND OTHER FEEDS     
  
-- SET @SQL2 = 'INSERT INTO  TEMP_PES.DBO.DIS_DUPLICATES SELECT D.BOL_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.SAILING_DATE FROM PES.DBO.ARCHIVE_RAW_BOL D (NOLOCK)  WHERE D.VENDOR_CODE= ''' +@DIS_VENDOR_CODE+ ''' AND SUBSTRING(D.SAILING_DATE,1,2) IN (''' +@MONTH+ ''') AND SUBSTRING(D.SAILING_DATE,5,4)=''' +@YEAR+ ''''      
SET @SQL2 = 'INSERT INTO TEMP_PES.DBO.DIS_DUPLICATES1 SELECT D.BOL_ID, D.BOL_NBR,PORT_DEPART_REF_ID, PORT_ARRIVE_REF_ID,  D.VDATE FROM PES.DBO.PES_STG_BOL D (NOLOCK) WHERE D.REF_VENDOR_CODE = ''' +@DIS_VENDOR_CODE+ ''' AND SUBSTRING(convert(varchar(8),D.VDATE,112),5,2) IN (''' +@MONTH+ ''') AND SUBSTRING(convert(varchar(8),D.VDATE,112),1,4) =''' +@YEAR+ ''' AND ISNULL(IS_DELETED,'''') <> ''Y'''
PRINT 'DIS DATA LOADED'
EXEC (@SQL2)      
      
SET @SQL3 = 'INSERT INTO TEMP_PES.DBO.ESCAN_DUPLICATES1 SELECT D.BOL_ID, D.BOL_NBR,PORT_DEPART_REF_ID, PORT_ARRIVE_REF_ID,  D.VDATE FROM PES.DBO.PES_STG_BOL D (NOLOCK) WHERE D.REF_VENDOR_CODE IN (''' +@OTHER_VENDOR_CODE+ ''') AND SUBSTRING(convert(varchar(8),D.VDATE,112),5,2) IN (''' +@MONTH+ ''') AND SUBSTRING(convert(varchar(8),D.VDATE,112),1,4) =''' +@YEAR+ ''' AND ISNULL(IS_DELETED,'''') <> ''Y'''
PRINT 'ESCAN DATA LOADED'
EXEC (@SQL3)   

-- CREATING INDEXES ON TEMP_PES.DBO.DIS_DUPLICATES & TEMP_PES.DBO.ESCAN_DUPLICATES      
--    
--SET @SQL4 = 'CREATE NONCLUSTERED INDEX IDX_DIS1 ON TEMP_PES.DBO.DIS_DUPLICATES1(BOL_NBR,PORT_DEPART_REF_ID,PORT_ARRIVE_REF_ID,VDATE)'      
--EXEC (@SQL4)      
--PRINT 'DIS INDEX CREATED'      
--    
--SET @SQL5 = 'CREATE NONCLUSTERED INDEX IDX_ESCAN1 ON TEMP_PES.DBO.ESCAN_DUPLICATES1(BOL_NBR,PORT_DEPART_REF_ID,PORT_ARRIVE_REF_ID,VDATE)'      
--EXEC (@SQL5) 
--PRINT 'ESCAN INDEX CREATED' 
   
INSERT INTO TEMP_PES.DBO.DISESCAN_DUPLICATES1       
SELECT  E.BOL_ID, E.BOL_NBR,E.PORT_DEPART_REF_ID, E.PORT_ARRIVE_REF_ID,  E.VDATE,      
       D.BOL_ID DIS_BOL_ID, D.BOL_NBR DIS_BILL_NUMBER,D.PORT_DEPART_REF_ID DIS_DISCHARGEPORT,       
       D.PORT_ARRIVE_REF_ID DIS_PORTOFDESTINATION, D.VDATE DIS_VDATE
FROM TEMP_PES.DBO.DIS_DUPLICATES1 D JOIN TEMP_PES.DBO.ESCAN_DUPLICATES1 E ON       
   (D.BOL_NBR=E.BOL_NBR       
AND D.PORT_DEPART_REF_ID=E.PORT_DEPART_REF_ID       
AND D.PORT_ARRIVE_REF_ID=E.PORT_ARRIVE_REF_ID      
--AND D.VOYAGE_NUMBER=E.VOYAGE_NUMBER      
AND D.VDATE=E.VDATE)   
   
--SET @SQL6 = 'CREATE NONCLUSTERED INDEX IDX_DISESCAN1 ON TEMP_PES.DBO.DISESCAN_DUPLICATES1(DIS_BOL_ID)'      
--EXEC (@SQL6)   
  
     
/* DELETE DIS RECORDS - UPDATING THE STG BOL TABLE FOR THE DUPLICATE DIS ESCAN BOL_NUMBERS*/       
UPDATE  STG      
SET  STG.IS_DELETED='Y',MODIFY_DATE=GETDATE(),MODIFY_USER = 'DATA_DEV_DIS'         
--SELECT COUNT(*) AS DEL_STG_CNT   
FROM PES.DBO.PES_STG_BOL STG WHERE STG.BOL_ID IN       
(SELECT DIS_BOL_ID FROM TEMP_PES.DBO.DISESCAN_DUPLICATES1  WITH (NOLOCK))      
AND STG.REF_VENDOR_CODE=@DIS_VENDOR_CODE      
AND ISNULL(STG.IS_DELETED,'') <> 'Y'      
--AND STG.REF_VENDOR_CODE= 'DIS'      
      
/* UPDATING THE STG CMD TABLE FOR THE DUPLICATE DIS ESCAN BOL_NUMBERS*/       
      
UPDATE  STGCMD      
SET  STGCMD.IS_DELETE='Y',MODIFY_DATE=GETDATE(),MODIFY_USER = 'DATA_DEV_DIS'         
--SELECT COUNT(*) AS DEL_CMD_CNT    
FROM PES.DBO.PES_STG_CMD STGCMD WHERE STGCMD.BOL_ID IN       
(SELECT DIS_BOL_ID FROM TEMP_PES.DBO.DISESCAN_DUPLICATES1  WITH (NOLOCK))      
AND ISNULL(STGCMD.IS_DELETE,'') <> 'Y'      
 

IF(@@ERROR <> 0)       
BEGIN      
  ROLLBACK TRAN      
  PRINT N'ERROR: TRANSACTION ROLLED BACK DUPLICATES DELETE FAILED';      
END      
ELSE      
BEGIN      
        COMMIT TRAN      
  PRINT N'DUPLICATES DELETED SUCCESSFULLY';   
  EXEC dbo.usp_SendEmail
  @To		= 'dpanicker@joc.com;SKasi@joc.com;qstenger@joc.com;'
 ,@From		= 'PIERS-NoReply@piers.com'
 ,@Subject	= 'DIS Duplicates deletion - step 2'
 ,@Body		= 'The DIS duplicates in PES Staging is deleted successfully'
 ,@Success	= @SendEmailSuccess OUT
 ,@Output	= @SendEmailOutput OUT
SELECT @SendEmailSuccess, @SendEmailOutput
        
END
GO
