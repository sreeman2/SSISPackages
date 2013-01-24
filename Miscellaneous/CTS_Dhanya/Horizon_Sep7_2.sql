  
  
CREATE VIEW [dbo].[vwMES_MMS_RAW_PTY] AS  
SELECT MINRAWPTYID  
      ,[RAW_PTY_ID]  
      ,[BOL_ID]  
      ,[BOL_Number]  
      ,[Pty_seq_nbr]  
      ,[Load_Number]  
FROM  
(  
 SELECT MIN(P.[RAW_PTY_ID]) OVER (PARTITION BY P.BOL_ID, P.LOAD_NUMBER) MINRAWPTYID  
    ,P.[RAW_PTY_ID]  
    ,P.[BOL_ID]  
    ,P.[BOL_Number]  
    ,P.[Pty_seq_nbr]  
    ,P.[Load_Number] into temp_pes.dbo.hor_pty_sep7 
 FROM [PES].[dbo].[RAW_PTY] P   
    INNER JOIN [PES].[dbo].[RAW_BOL] B ON P.BOL_ID = B.BOL_ID   
            AND P.LOAD_NUMBER = B.LOAD_NUMBER  
 WHERE B.bol_number = 'MAEU557681502'
) PTY  
  
select * from temp_pes.dbo.hor_pty_sep7 

begin tran

DELETE  
   FROM temp_pes.dbo.hor_pty_sep7 
   WHERE EXISTS (SELECT 1  
        FROM temp_pes.dbo.hor_pty_sep7 hor,  [PES].[dbo].ARCHIVE_RAW_PTY   
        WHERE [PES].dbo.archive_RAW_PTY.RAW_PTY_ID = hor.RAW_PTY_ID AND [PES].dbo.archive_RAW_PTY.RAW_PTY_ID <> hor.MINRAWPTYID)


SELECT *
   FROM [PES].[DBO].ARCHIVE_RAW_PTY  (NOLOCK)
   WHERE EXISTS (SELECT 1  
        FROM TEMP_PES.DBO.HOR_PTY_SEP7   (NOLOCK) 
        WHERE [PES].DBO.ARCHIVE_RAW_PTY.RAW_PTY_ID = RAW_PTY_ID AND [PES].DBO.ARCHIVE_RAW_PTY.RAW_PTY_ID <> MINRAWPTYID)
          AND ISNULL(PTY_SEQ_NBR,0) = 0 )  

select * from pes.dbo.archive_raw_bol (nolock) where bol_id = 257397515

select * from pes.dbo.archive_raw_pty (nolock) where bol_id = 257397515


  


  select top 1 * from [PES].dbo.archive_RAW_PTY (nolock)
  