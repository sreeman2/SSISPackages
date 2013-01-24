select psb.bol_id into temp_pes.dbo.vessel_upd_dec12
from pes.dbo.pes_stg_bol psb (nolock)
join pes.dbo.archive_raw_bol arb (nolock) on psb.bol_id = arb.bol_id
where psb.ref_load_num_id = 12330007 and arb.VESSEL_NAME = 'CAP STEWART'


select * from SCREEN_TEST.DBO.DQA_BL (nolock)
where t_nbr in (select bol_id from temp_pes.dbo.vessel_upd_dec12)

begin tran
update stg 
set vessel_ref_id = 310505,vessel_name = 'CAP STEWART',modify_date = getdate(),modify_user = 'data_dev_7172'
-- select vessel_ref_id,vessel_name,src_vessel_name
from pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id

commit tran

select vessel_ref_id,vessel_name,* from  pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
and vessel_ref_id <> 310505

select * from screen_test.dbo.dqa_voyage (nolock)
where voyage_id in 
(
777117,
777225,
777305
)

select * from ref_vessel (nolock) where id  = 310505

select * from screen_test.dbo.dqa_bl (nolock)
where t_nbr in (select stg.bol_id from pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
and vessel_ref_id <> 310505)

begin tran
update screen_test.dbo.dqa_bl set vessel_id = 310505
where t_nbr in (select stg.bol_id from pes.dbo.pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
and vessel_ref_id <> 310505)

commit tran

begin tran
update pes_stg_bol set vessel_ref_id = 310505,vessel_name = 'CAP STEWART',
       modify_date = getdate(),modify_user = 'data_dev_7172'
from  pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
and vessel_ref_id <> 310505 

update pes_stg_cmd set modify_date = getdate()
where bol_id in 
(select bol_id from temp_pes.dbo.vessel_upd_dec12)

commit tran

select distinct vessel_id from dqa_bl (nolock)
where t_nbr in (select stg.bol_id from pes.dbo.pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
)

select distinct vessel_id from dqa_voyage (nolock)
where voyage_id in (select distinct stnd_voyg_id from pes.dbo.pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
)

select vessel_id,vessel_name,* from bl_bl (nolock)
where t_nbr in (select stg.bol_id from pes.dbo.pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
)

begin tran
update screen_test.dbo.bl_bl set vessel_id = 310505,vessel_name = 'CAP STEWART'
where t_nbr in (select stg.bol_id from pes.dbo.pes_stg_bol stg (nolock),temp_pes.dbo.vessel_upd_dec12 upd
where stg.bol_id = upd.bol_id
)

commit tran




