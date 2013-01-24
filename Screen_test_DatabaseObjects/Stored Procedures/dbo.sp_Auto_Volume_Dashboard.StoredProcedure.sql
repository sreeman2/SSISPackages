/****** Object:  StoredProcedure [dbo].[sp_Auto_Volume_Dashboard]    Script Date: 01/03/2013 19:48:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[sp_Auto_Volume_Dashboard]
as 
begin
declare @pdate DATETIME
set @pdate= (select start_dt from [SCREEN_TEST].[dbo].[DQA_PROD_MONTH])

IF OBJECT_ID('Work.dbo.PortLineFull') IS NOT NULL DROP TABLE Work.dbo.PortLineFull
Select year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.bol_direction, sline.type, dptport.piers_name as USPort, ultport.country as UltCtry, 
( case when ref_vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when ref_vendor_code like '%$HSU%' then 'HSUD' 
when ref_vendor_code like '%$HRZ%' then 'HRZN' 
when ref_vendor_code like '%$SES%' then 'SEST' 
when ref_vendor_code like '%$HRZ%' then 'HRZN'
when len(ref_vendor_code)>8 then 'OTHER' else ref_vendor_code END) as Feed, 
sum(dw.bol_TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
into Work.dbo.PortLineFull
from PES_STG_BOL dw (nolock) 
left outer join dbo.REF_port dptport (nolock) on dw.port_depart_ref_id = dptport.id
left outer join dbo.REF_port ultport (nolock) on dw.ultport_id = ultport.id
left outer join dbo.REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-4, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.bol_direction='e' and dw.is_deleted is null
group by year(dw.vdate), month(dw.vdate), dw.bol_direction, sline.type, dptport.piers_name, ultport.country, 
( case when ref_vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when ref_vendor_code like '%$HSU%' then 'HSUD' 
when ref_vendor_code like '%$HRZ%' then 'HRZN' 
when ref_vendor_code like '%$SES%' then 'SEST' 
when ref_vendor_code like '%$HRZ%' then 'HRZN'
when len(ref_vendor_code)>8 then 'OTHER' else ref_vendor_code END)

INSERT INTO [Work].[dbo].[PortLineFull]
           ([YEAR]
           ,[MTH]
           ,[bol_direction]
           ,[type]
           ,[USPort]
           ,[UltCtry]
           ,[Feed]
           ,[SumOfTEUs]
           ,[CountOfBOLs])
Select year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.bol_direction, sline.type, 
arvport.piers_name as USPort, ultport.country as UltCtry, 
( case when ref_vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when ref_vendor_code like '%$HSU%' then 'HSUD' 
when ref_vendor_code like '%$HRZ%' then 'HRZN' 
when ref_vendor_code like '%$SES%' then 'SEST' 
when ref_vendor_code like '%$HRZ%' then 'HRZN'
when len(ref_vendor_code)>8 then 'OTHER' else ref_vendor_code END) as Feed, 
sum(dw.BOL_TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
from PES_STG_BOL dw (nolock) 
left outer join dbo.REF_port arvport (nolock) on dw.port_arrive_ref_id = arvport.id
left outer join dbo.REF_port ultport (nolock) on dw.ultport_id = ultport.id
left outer join dbo.REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-4, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.bol_direction='i' and dw.is_deleted is null 
group by year(dw.vdate), month(dw.vdate), dw.bol_direction, sline.type, arvport.piers_name,  ultport.country, 
( case when ref_vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when ref_vendor_code like '%$HSU%' then 'HSUD' 
when ref_vendor_code like '%$HRZ%' then 'HRZN' 
when ref_vendor_code like '%$SES%' then 'SEST' 
when ref_vendor_code like '%$HRZ%' then 'HRZN'
when len(ref_vendor_code)>8 then 'OTHER' else ref_vendor_code END) 

EXEC xp_cmdshell 'bcp "SELECT * FROM Work.dbo.PortLineFull" queryout "G:\PortLineFull.txt" -T -c -t"|"' 
end
GO
