SELECT     
            f.filename,
            d.PROCESS_NAME AS Exception   ,
                  COUNT(B.T_NBR) AS Total      
            
      FROM CTRL_PROCESS_DEFINITION AS d WITH (NOLOCK)
      JOIN CTRL_PROCESS_VOYAGE AS v WITH (NOLOCK) ON d.PROCESS_NAME = v.PROCESS_NAME
      JOIN DQA_BL AS b WITH (NOLOCK) ON b.T_NBR = v.T_NBR
      join PES.dbo.PES_PROGRESS_STATUS (nolock) f
            on b.load_nbr=f.loadnumber   
      JOIN CTRL_QC_MODIFY c WITH (NOLOCK) ON D.PROCESS_NAME = C.[KEY]
      WHERE
      (          
            (
                  b.LOAD_NBR IS NOT NULL       
            )
            --AND ( v.dir = 'E' )
                  AND filename='AMS131018.DAT'
            AND
            ( 
                  EXISTS
                  (
                        SELECT BL_BL.T_NBR FROM BL_BL  WITH (NOLOCK) JOIN DQA_VOYAGE WITH (NOLOCK)
                        ON BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID
                        WHERE (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE') 
AND ( BL_BL.DQA_BL_STATUS = 'PENDING' )
                        AND( ISNULL(BL_BL.BOL_STATUS, '') NOT IN('MASTER','TEMPMASTER',' HOUSE') )  
--AND ( BL_BL.T_NBR = b.T_NBR )
                  )
            )
      )
 
      GROUP BY f.filename,d.PROCESS_NAME
      ORDER BY 3 desc,d.PROCESS_NAME


-- 466
SELECT * FROM BL_BL (NOLOCK) WHERE LOAD_NBR  = 13291001


SELECT  *  FROM DQA_BL (NOLOCK) WHERE LOAD_NBR  = 13291001


select D.DQA_VOYAGE_ID
from DQA_BL d (NOLOCK),BL_BL b (NOLOCK)
where d.t_nbr = b.t_nbr
and d.LOAD_NBR  = 13291001


select * from dqa_voyage (nolock)
where voyage_id in (
select D.DQA_VOYAGE_ID
from DQA_BL d (NOLOCK),BL_BL b (NOLOCK)
where d.t_nbr = b.t_nbr
and d.LOAD_NBR  = 13291001)


SP_HELPTEXT 