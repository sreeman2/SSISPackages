

SELECT BOL_ID into temp_pes.dbo.DW_Bills_Dec18_upd-- AS 'COUNT'--, BOL_STATUS, RECORD_STATUS, QC_VALID, IS_DELETED, PPMM_FLAG
FROM [dbo].[PES_STG_BOL]WITH(NOLOCK)
WHERE VDATE >= '20120101'
AND (BOL_STATUS = 'LATEMASTER' OR BOL_STATUS = 'READY' OR BOL_STATUS = 'READY FOR RELEASE')
AND (RECORD_STATUS = 'AUTOMATED' OR RECORD_STATUS = 'CLEANSED')
AND (QC_VALID = 'Y' OR QC_VALID = 'P')
AND (IS_DELETED = 'N' OR IS_DELETED IS NULL)
AND (PPMM_FLAG = 'N')
and modify_date > getdate()-2
--GROUP BY BOL_STATUS, RECORD_STATUS, QC_VALID, IS_DELETED, PPMM_FLAG
--COUNT OF BOLID THAT SHOULD HAVE MOVED FROM STG TO DW THAT DIDNT


begin tran
-- count = 44381
update pes_stg_bol set modify_date = getdate(),modify_user = 'TA14605'
from pes_stg_bol stg,temp_pes.dbo.DW_Bills_Dec18_upd upd
where stg.bol_id = upd.bol_id

-- count = 44940
update pes_stg_cmd set modify_date = getdate()
where bol_id in (select bol_id from temp_pes.dbo.DW_Bills_Dec18_upd)
commit tran