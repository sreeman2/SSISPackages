-- ULT_PORT_CODE  = 57400
-- ULTPORT_ID = 302348
-- ULT_PORT_NAME = ULAANBAATAR
SELECT * FROM PES_STG_BOL (NOLOCK)
WHERE BOL_ID = '255156881'

SELECT * FROM REF_PORT (NOLOCK)
WHERE ID = 302348



select top 10 * from base.boldetail_pes (nolock) where cmd_id  = '146506605'

select * from GTCore_MasterData.dbo.ref_port (nolock) where id  = 12158


select * from GTCore_MasterData.dbo.ref_port (nolock) where id  = 302348
Select top 10 * from NewCBMIdb.Base.Port (Nolock) where port_ID=302348 or PortID=302348

Select top 10 * from NewCBMIdb.Base.Port (Nolock) where port_code = '57400'


select max(port_id) from NewCBMIdb.Base.Port (Nolock)

select * from GTCore_MasterData.dbo.ref_port (nolock) where id  = 12158
Select * from NewCBMIdb.Base.Port (Nolock) where port_ID=12158 or PortID=12158 

order by updatedate desc

select * from GTCore_MasterData.dbo.ref_port (nolock) 
order by modified_dt desc

--41602
select count(*) from NewCBMIdb.Base.Port (Nolock) 


select count(*) from GTCore_MasterData.dbo.ref_port (nolock) 
except
select port_id,port_name from NewCBMIdb.Base.Port (Nolock) 




-- 34233
select count(*) from GTCore_MasterData.dbo.ref_port (nolock) 




--Check in PES
--Check the corresponding PortID in GTCoreMaster ref


255156881
255156881



