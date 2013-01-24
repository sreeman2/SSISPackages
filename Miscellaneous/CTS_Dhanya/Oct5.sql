select bol_id,modify_date into temp_pes.dbo.pes_stg_upd_oct5  from pes_stg_bol A(nolock)
where bol_id not in 
(
       select bol_id 
        from PES_DW.PESDW.dbo.PES_dw_BOL  with (nolock)
        where DELETED is null
)
 -- AND year(modify_date) = '2012'
 AND A.RECORD_STATUS IN('CLEANSED','AUTOMATED') 
 AND A.BOL_STATUS IN('LATEMASTER', 'READY FOR RELEASE', 'READY') 
 AND ISNULL(IS_DELETED,'') <> 'Y'

begin tran 
-- 291221 rows
UPDATE STG SET STG.MODIFY_DATE=GETDATE() 
--SELECT count(*)
FROM PES.DBO.PES_STG_BOL STG, temp_pes.dbo.pes_stg_upd_oct5 upd 
WHERE STG.bol_id=upd.bol_id 
and year(upd.modify_date) = '2012'
 
-- 302396 rows 
UPDATE STGCMD 
SET STGCMD.MODIFY_DATE=GETDATE() 
--SELECT COUNT(*) 
FROM PES.DBO.PES_STG_CMD STGCMD WHERE STGCMD.BOL_ID IN 
(SELECT BOL_ID FROM temp_pes.dbo.pes_stg_upd_oct5
where year(modify_date) = '2012')

commit tran
