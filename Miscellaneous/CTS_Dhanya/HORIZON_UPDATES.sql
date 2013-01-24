  
  
-- =============================================  
-- Author:  UBM Global Trade  
-- Create date: 08/25/2011  
-- Description: Remove duplicate MES and MMS BOL records.  
-- =============================================  
CREATE PROCEDURE [dbo].[spRemoveMESandMMSDuplicateBOLRecords]  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 IF EXISTS (SELECT 1 FROM dbo.RAW_BOL WHERE [VENDOR_CODE] IN ('MES', 'MMS'))  
  BEGIN  
   -- Update Commodities  
   UPDATE A WITH (UPDLOCK)  
   SET [BOL_ID] = B.[MINBOLID]  
   FROM [PES].[dbo].RAW_CMD A  
     INNER JOIN [PES].[dbo].[vwMES_MMS_RAW_BOL] B ON A.BOL_ID = B.BOL_ID  
                    AND A.BOL_NUMBER = B.BOL_NUMBER   
     
   -- Update CNTR  
   UPDATE A WITH (UPDLOCK)  
   SET [BOL_ID] = B.[MINBOLID]  
   FROM [PES].[dbo].RAW_CNTR A  
     INNER JOIN [PES].[dbo].[vwMES_MMS_RAW_BOL] B ON A.BOL_ID = B.BOL_ID  
                    AND A.BOL_NUMBER = B.BOL_NUMBER   
     
   -- Update HZMT  
   UPDATE A WITH (UPDLOCK)  
   SET [BOL_ID] = B.[MINBOLID]  
   FROM [PES].[dbo].RAW_HZMT A  
     INNER JOIN [PES].[dbo].[vwMES_MMS_RAW_BOL] B ON A.BOL_ID = B.BOL_ID  
                    AND A.BOL_NUMBER = B.BOL_NUMBER   
     
   -- Update MAN  
   UPDATE A WITH (UPDLOCK)  
   SET [BOL_ID] = B.[MINBOLID]  
   FROM [PES].[dbo].RAW_MAN A  
     INNER JOIN [PES].[dbo].[vwMES_MMS_RAW_BOL] B ON A.BOL_ID = B.BOL_ID  
                    AND A.BOL_NUMBER = B.BOL_NUMBER   
           
   --Update PES_AUDIT_DETAILS  
   UPDATE A WITH (UPDLOCK)  
   SET [BOL_ID] = B.[MINBOLID]  
   FROM [PES].[dbo].PES_AUDIT_DETAILS A  
     INNER JOIN [PES].[dbo].[vwMES_MMS_RAW_BOL] B ON A.BOL_ID = B.BOL_ID  
                    AND A.LOAD_NUMBER = B.LOAD_NUMBER  
     
   --Update PTY  
   UPDATE A WITH (UPDLOCK)  
   SET [BOL_ID] = B.[MINBOLID]  
   FROM [PES].[dbo].RAW_PTY A  
     INNER JOIN [PES].[dbo].[vwMES_MMS_RAW_BOL] B ON A.BOL_ID = B.BOL_ID  
                    AND A.BOL_NUMBER = B.BOL_NUMBER  
   --Delete Duplicate PTY  
   DELETE  
   FROM [PES].[dbo].RAW_PTY  
   WHERE EXISTS (SELECT 1  
        FROM [PES].dbo.vwMES_MMS_RAW_PTY     
        WHERE [PES].dbo.RAW_PTY.RAW_PTY_ID = RAW_PTY_ID AND [PES].dbo.RAW_PTY.RAW_PTY_ID <> MINRAWPTYID)                                   
     
   --Delete Duplicate BOL  
   DELETE  
   FROM [PES].[dbo].RAW_BOL  
   WHERE EXISTS(SELECT 1   
       FROM [PES].[dbo].[vwMES_MMS_RAW_BOL]   
       WHERE [PES].[dbo].RAW_BOL.BOL_ID = BOL_ID AND [PES].[dbo].RAW_BOL.BOL_ID <> MINBOLID)  
         
   --Update PES_AUDIT  
   UPDATE [PES].[dbo].[PES_AUDIT] WITH (UPDLOCK)  
   SET ROWS_INSERTED = CASE WHEN TABLE_NAME = 'RAW_BOL' THEN (SELECT COUNT(*)   
                    FROM [PES].[dbo].RAW_BOL (NOLOCK)  
                    WHERE LOAD_NUMBER = [PES].[dbo].[PES_AUDIT].LOAD_NUMBER)  
          WHEN TABLE_NAME = 'RAW_PTY' THEN (SELECT COUNT(*)   
                    FROM [PES].[dbo].RAW_PTY (NOLOCK)  
                    WHERE LOAD_NUMBER = [PES].[dbo].[PES_AUDIT].LOAD_NUMBER)                                    
          ELSE ROWS_INSERTED  
        END  
                         
  END   
   
END  
  
   