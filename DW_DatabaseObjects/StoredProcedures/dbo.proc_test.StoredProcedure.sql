/****** Object:  StoredProcedure [dbo].[proc_test]    Script Date: 01/08/2013 14:51:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec proc_test    
   
CREATE procedure [dbo].[proc_test]    
as    
    
declare @pdate DATETIME    
set @pdate= (select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH])    
select @pdate  
declare @rowsPerPage int    
declare @pageNum int    
SET @rowsPerPage = 100000   
SET @pageNum = 1     
    
while @pageNum <= 5    
begin    
;WITH SQLPaging      
AS     
(      
--SELECT TOP(@rowsPerPage * @pageNum)      
--ResultNum = ROW_NUMBER() OVER (ORDER BY VDATE)      
--,VDATE     
--FROM dbo.PES_DW_BOL (nolock)     
    
SELECT TOP(@rowsPerPage * @pageNum)      
    ResultNum = ROW_NUMBER() OVER (ORDER BY YEAR(DW.VDATE) ),     
 YEAR(DW.VDATE) AS YEAR,         
    MONTH(DW.VDATE) AS MTH,         
    DW.DIRECTION,         
    VES.NAME AS VESSEL,          
    DPTPORT.PIERS_NAME AS USPORT,         
    SLINE.SLINE,        
    ( CASE WHEN VENDOR_CODE LIKE '[EI][A-Z][A-Z][A-Z][0-9][0-9]' THEN 'TYPE'         
      WHEN VENDOR_CODE LIKE '%$HSU%' THEN 'HSUD'         
      WHEN VENDOR_CODE LIKE '%$HRZ%' THEN 'HRZN'         
      WHEN VENDOR_CODE LIKE '%$SES%' THEN 'SEST'         
      WHEN VENDOR_CODE LIKE '%$HRZ%' THEN 'HRZN'        
      WHEN LEN(VENDOR_CODE)>8 THEN 'OTHER' ELSE VENDOR_CODE END) AS FEED,         
    SUM(DW.TEU) AS SUMOFTEUS,         
    COUNT(DW.BOL_ID) AS COUNTOFBOLS        
 -- INTO WORKTEMP.DBO.PORTLINEVES        
  FROM PES_DW_BOL DW (NOLOCK)         
  LEFT OUTER JOIN DBO.PES_DW_REF_PORT DPTPORT (NOLOCK) ON DW.PORT_DEPART_REF_ID = DPTPORT.ID        
  LEFT OUTER JOIN DBO.PES_DW_REF_PORT ULTPORT (NOLOCK) ON DW.ULTPORT_REF_ID = ULTPORT.ID        
  LEFT OUTER JOIN DBO.PES_DW_REF_CARRIER SLINE (NOLOCK) ON DW.SLINE_REF_ID = SLINE.ID        
  LEFT OUTER JOIN DBO.PES_DW_REF_VESSEL VES (NOLOCK) ON DW.VESSEL_REF_ID = VES.ID   
  WHERE DW.VDATE> (SELECT DATEADD(YEAR, YEAR(@pdate)-1900, DATEADD(MM, MONTH(@pdate)-7, -1)))         
   AND DW.VDATE< (SELECT DATEADD(YEAR, YEAR(@pdate)-1900, DATEADD(MM, MONTH(@pdate), -1)))         
   AND DW.DIRECTION='E' AND DW.DELETED IS NULL        
   GROUP BY YEAR(DW.VDATE),         
     MONTH(DW.VDATE),         
     DW.DIRECTION,         
     SLINE.SLINE,         
     DPTPORT.PIERS_NAME,         
     VES.NAME,         
     ( CASE WHEN VENDOR_CODE LIKE '[EI][A-Z][A-Z][A-Z][0-9][0-9]' THEN 'TYPE'         
       WHEN VENDOR_CODE LIKE '%$HSU%' THEN 'HSUD'         
       WHEN VENDOR_CODE LIKE '%$HRZ%' THEN 'HRZN'         
       WHEN VENDOR_CODE LIKE '%$SES%' THEN 'SEST'         
       WHEN VENDOR_CODE LIKE '%$HRZ%' THEN 'HRZN'        
       WHEN LEN(VENDOR_CODE)>8 THEN 'OTHER' ELSE VENDOR_CODE END)      
)      
insert into worktemp.dbo.testing      
SELECT *     
FROM SQLPaging      
WHERE ResultNum > ((@pageNum - 1) * @rowsPerPage)    
SET @pageNum = @pageNum + 1    
end
GO
