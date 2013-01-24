Select bol_nbr from PES.dbo.PES_STG_BOL A with (nolock) where bol_id in (244241103,
244241104)




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
and A.Bol_id=244240485
-- This query will insure discrepancies between Staging and Data Warehouse will be identified
-- for previous three days by verifing the non-existance of Bol_ID on PESDW.dbo.PES_dw_BOL  
UNION                            
select a.BOL_ID   ,a.Modify_Date 
from   PES.dbo.PES_STG_BOL   a with (nolock) 
join GTCore_MasterData.dbo.ref_carrier   ref on  (a.SLINE_REF_ID=ref.id)
join   PES.dbo.PES_PROGRESS_STATUS ps  with (nolock)  on  (a.ref_load_num_ID= ps.loadnumber
and ps.loadnumber= a.ref_load_num_ID)
where 
MODIFY_DATE >= getdate() -3
and a.bol_id not in  
       (
        select bol_id 
        from PES_DW.PESDW.dbo.PES_dw_BOL  with (nolock)
        where DELETED is null)
            and MODIFIED_DT >= getdate() -3
            And A.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
            AND A.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
            AND ISNULL(IS_DELETED,''
            )
            <> 'Y'


/*
--total 
A.RECORD_STATUS not IN('CLEANSED','AUTOMATED')=196
AND A.BOL_STATUS not IN('LATEMASTER', 'READY FOR RELEASE', 'READY')=4696, 8551
*/

SELECT BOL_ID, RECORD_STATUS, BOL_STATUS, MODIFY_DATE,IS_DELETED
--update A set A.modify_date=getDate()
FROM PES.dbo.PES_STG_BOL A with (nolock) where A.Bol_id in ('244240485',
'244240486',
'244240489',
'244240502',
'244240504',
'244240512',
'244241093',
'244241094',
'244241095',
'244241096',
'244241097',
'244241103',
'244241104',
'244241105',
'244241120',
'244241998',
'244241999',
'244242000',
'244242001',
'244242002',
'244242003',
'244242008',
'244242014',
'244242015',
'244242016',
'244242017',
'244242018',
'244242019',
'244242020',
'244242021',
'244242022',
'244242948')
and 
A.Ref_load_Num_ID=12013001 
--JOIN PES.dbo.PES_PROCESS_DATE B   WITH  (nolock)  on ()
And A.RECORD_STATUS   IN('CLEANSED','AUTOMATED') 
AND A.BOL_STATUS  not IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
AND ISNULL(IS_DELETED,'') <> 'Y' 
--AND A.MODIFY_DATE< ?
--AND B.PROCESS_NAME='STG_DW'

Select 
('244240485',
'244240486',
'244240489',
'244240502',
'244240504',
'244240512',
'244241093',
'244241094',
'244241095',
'244241096',
'244241097',
'244241103',
'244241104',
'244241105',
'244241120',
'244241998',
'244241999',
'244242000',
'244242001',
'244242002',
'244242003',
'244242008',
'244242014',
'244242015',
'244242016',
'244242017',
'244242018',
'244242019',
'244242020',
'244242021',
'244242022',
'244242948')

