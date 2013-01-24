select bol_id into temp_pes.dbo.clams_upd
from PES_STG_BOL bol (nolock)
where year(vdate)='2012' 
and bol_nbr like 'CLAM%'
and PPMM_flag='N'
and bol_status='READY'
and record_status<>'PENDING'
and isnull(is_deleted,'N')<>'Y'
and mst_bol_type not in ('H','M')
order by modify_date

begin tran 
-- 307 rows
UPDATE STG SET STG.MODIFY_DATE=GETDATE() 
--SELECT count(*)
FROM PES.DBO.PES_STG_BOL STG, temp_pes.dbo.clams_upd upd 
WHERE STG.bol_id=upd.bol_id 
 
-- 400 rows 
UPDATE STGCMD 
SET STGCMD.MODIFY_DATE=GETDATE() 
--SELECT COUNT(*) 
FROM PES.DBO.PES_STG_CMD STGCMD WHERE STGCMD.BOL_ID IN 
(SELECT BOL_ID FROM temp_pes.dbo.clams_upd)

commit tran



