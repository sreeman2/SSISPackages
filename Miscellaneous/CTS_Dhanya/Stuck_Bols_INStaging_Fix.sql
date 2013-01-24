SELECT 
BOL_ID, MODIFY_DATE 
FROM PES.dbo.PES_STG_BOL A with (nolock)
JOIN PES.dbo.PES_PROCESS_DATE B   WITH  (nolock)  
ON A.MODIFY_DATE>=  DateADD(hh, -12, B.LAST_UPD_DATE) --If job past midnight Savvis time, the last updated_date
                                                      -- changes to next date
WHERE
A.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
AND A.BOL_STATUS 
IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
AND ISNULL(IS_DELETED,'') <> 'Y' 
--AND A.MODIFY_DATE< ?
AND B.PROCESS_NAME='STG_DW'
-- This query will insure discrepancies between Staging and Data Warehouse will be identified
-- for previous three days by verifing the non-existance of Bol_ID on PESDW.dbo.PES_dw_BOL  
UNION         

----(203845 row(s) affected)
--41969
Select a.BOL_ID   ,a.Modify_Date, A.RECORD_STATUS,A.BOL_STATUS,a.PPMM_FLAG 
--update A set A.Modify_date=getDate()
FROM PES.dbo.PES_STG_BOL A  where A.bol_id in (
--select  bol_id from #temp where modify_date > '2012-04-01 00:41:51.350' and modify_date <= '2012-07-01 03:41:51.350')
select  bol_id from #temp where modify_date > '2012-07-12 00:41:51.350' --and modify_date <= '2012-07-29 03:41:51.350')

group by modify_date
select month(modify_date) m , count(*) from #temp  where modify_date > '2012-01-01 03:41:51.350' --and modify_date < '2012-04-01 03:41:51.350'  
group by month(modify_date) 
order by m desc 

         
select a.BOL_ID   ,a.Modify_Date  into #temp
from   PES.dbo.PES_STG_BOL   a with (nolock) 
join GTCore_MasterData.dbo.ref_carrier   ref on  (a.SLINE_REF_ID=ref.id)
join   PES.dbo.PES_PROGRESS_STATUS ps  with (nolock)  on  (a.ref_load_num_ID= ps.loadnumber
and ps.loadnumber= a.ref_load_num_ID)
where 
--MODIFY_DATE >= getdate() -3
 a.bol_id not in  
       (
        select bol_id 
        from PES_DW.PESDW.dbo.PES_dw_BOL  with (nolock)
        where DELETED is null)
            --and MODIFIED_DT >= getdate() -3
            And A.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
            AND A.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
            AND ISNULL(IS_DELETED,''
            )
            <> 'Y'