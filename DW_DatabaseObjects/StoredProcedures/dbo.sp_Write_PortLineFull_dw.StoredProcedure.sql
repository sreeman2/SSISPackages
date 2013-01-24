/****** Object:  StoredProcedure [dbo].[sp_Write_PortLineFull_dw]    Script Date: 01/08/2013 14:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_Write_PortLineFull_dw]
as
--FULL PORT-LINE DW QUERY FOR PRE-RELEASE CHECK --
begin tran
declare @pdate DATETIME
set @pdate= (select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH])

IF OBJECT_ID('WorkTemp.dbo.PortLineFull') IS NOT NULL DROP TABLE WorkTemp.dbo.PortLineFull
Select year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, dptport.piers_name as USPort, ultport.country as UltCtry, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END) as Feed, 
sum(dw.TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
into WorkTemp.dbo.PortLineFull
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port dptport (nolock) on dw.port_depart_ref_id = dptport.id
left outer join dbo.PES_DW_REF_port ultport (nolock) on dw.ultport_ref_id = ultport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-19, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='e' and dw.deleted is null
group by year(dw.vdate), month(dw.vdate), dw.direction, sline.sline, dptport.piers_name, ultport.country, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END)

INSERT INTO [WorkTemp].[dbo].[PortLineFull]
           ([YEAR]
           ,[MTH]
           ,[direction]
           ,[sline]
           ,[USPort]
           ,[UltCtry]
           ,[Feed]
           ,[SumOfTEUs]
           ,[CountOfBOLs])
Select year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, 
arvport.piers_name as USPort, ultport.country as UltCtry, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END) as Feed, 
sum(dw.TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port arvport (nolock) on dw.port_arrive_ref_id = arvport.id
left outer join dbo.PES_DW_REF_port ultport (nolock) on dw.ultport_ref_id = ultport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-19, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='i' and dw.deleted is null 
group by year(dw.vdate), month(dw.vdate), dw.direction, sline.sline, arvport.piers_name,  ultport.country, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END)

EXEC xp_cmdshell 'bcp "SELECT * FROM WorkTemp.dbo.PortLineFull" queryout "G:\PortLine\PortLineFull.txt" -T -c -t"|"' 
commit tran
GO
