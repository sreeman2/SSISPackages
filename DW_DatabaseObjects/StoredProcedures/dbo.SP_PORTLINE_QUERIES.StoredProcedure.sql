/****** Object:  StoredProcedure [dbo].[SP_PORTLINE_QUERIES]    Script Date: 01/08/2013 14:51:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC PORTLINE_QUERIES

CREATE PROCEDURE [dbo].[SP_PORTLINE_QUERIES]
AS 
BEGIN TRANSACTION
--FULL PORT-LINE DW QUERY FOR PRE-RELEASE CHECK --

declare @pdate DATETIME
set @pdate= (select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH])

IF OBJECT_ID('WorkTemp.dbo.PortLineFull1') IS NOT NULL DROP TABLE WorkTemp.dbo.PortLineFull1
Select 
ROW_NUMBER() OVER (ORDER BY dptport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, dptport.piers_name as USPort, ultport.country as UltCtry, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when len(vendor_code)>8 then 'OTHER' else vendor_code END) as Feed, 
sum(dw.TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
into WorkTemp.dbo.PortLineFull1
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
--when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END)

INSERT INTO [WorkTemp].[dbo].[PortLineFull1]
           ([Rownum]
		   ,[YEAR]
           ,[MTH]
           ,[direction]
           ,[sline]
           ,[USPort]
           ,[UltCtry]
           ,[Feed]
           ,[SumOfTEUs]
           ,[CountOfBOLs])
Select 
ROW_NUMBER() OVER (ORDER BY arvport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, 
arvport.piers_name as USPort, ultport.country as UltCtry, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
--when vendor_code like '%$HRZ%' then 'HRZN'
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
--when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END)

EXEC xp_cmdshell 'bcp "SELECT YEAR,MTH,direction,sline,USPort,UltCtry,Feed,SumOfTEUs,CountOfBOLs FROM WorkTemp.dbo.PortLineFull1" queryout "G:\PortLine\PortLineFull.txt" -T -c -t"|"' 

--VOLUME HIGH LEVEL DASHBOARD CHECK--

--declare @pdate DATETIME
--set @pdate= (select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH])

IF OBJECT_ID('WorkTemp.dbo.PortLineDash') IS NOT NULL DROP TABLE WorkTemp.dbo.PortLineDash
Select 
ROW_NUMBER() OVER (ORDER BY dptport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, dptport.piers_name as USPort, 
sum(dw.TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
into WorkTemp.dbo.PortLineDash
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port dptport (nolock) on dw.port_depart_ref_id = dptport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
where dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='e' and dw.deleted is null
group by year(dw.vdate), month(dw.vdate), dw.direction, sline.sline, dptport.piers_name

INSERT INTO [WorkTemp].[dbo].[PortLineDash]
           ([ROWNUM]
		   ,[YEAR]
           ,[MTH]
           ,[direction]
           ,[sline]
           ,[USPort]
           ,[SumOfTEUs]
           ,[CountOfBOLs])
Select 
ROW_NUMBER() OVER (ORDER BY arvport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, 
arvport.piers_name as USPort,
sum(dw.TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port arvport (nolock) on dw.port_arrive_ref_id = arvport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
where dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='i' and dw.deleted is null 
group by year(dw.vdate), month(dw.vdate), dw.direction, sline.sline, arvport.piers_name

EXEC xp_cmdshell 'bcp "SELECT YEAR,MTH,direction,sline,USPort,SumOfTEUs,CountOfBOLs FROM WorkTemp.dbo.PortLineDash" queryout "G:\PortLine\PortLineDash.txt" -T -c -t"|"' 



-- BULK MODEL CHECK --
--
--declare @pdate DATETIME
--set @pdate= (select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH])

IF OBJECT_ID('WorkTemp.dbo.PortLineBulk') IS NOT NULL DROP TABLE WorkTemp.dbo.PortLineBulk
Select 
ROW_NUMBER() OVER (ORDER BY dptport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, 
dptport.piers_name as USPort, ves.name as Vessel, dw.voyage as Voyage,
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when len(vendor_code)>8 then 'OTHER' else vendor_code END) as Feed, 
dw.nterp_std_wgt/1000 as MTONS, DW.BOL_ID
into WorkTemp.dbo.PortLineBulk
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port dptport (nolock) on dw.port_depart_ref_id = dptport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
left outer join dbo.PES_DW_REF_VESSEL ves (nolock) on dw.vessel_ref_id = ves.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-19, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='e' and dw.deleted is null and cntr_flg<>'c'
and dw.nterp_std_wgt/1000>60000


INSERT INTO [WorkTemp].[dbo].[PortLineBulk]
           ([ROWNUM]
		   ,[YEAR]
           ,[MTH]
           ,[direction]
           ,[sline]
           ,[USPort]
           ,[Vessel]
		   ,[Voyage]
           ,[Feed]
           ,MTONS
           ,BOL_ID)
Select 
ROW_NUMBER() OVER (ORDER BY arvport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, sline.sline, 
arvport.piers_name as USPort, ves.Name as Vessel, dw.voyage as Voyage, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END) as Feed, 
dw.nterp_std_wgt/1000 as MTONS, DW.BOL_ID
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port arvport (nolock) on dw.port_arrive_ref_id = arvport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
left outer join dbo.PES_DW_REF_VESSEL ves (nolock) on dw.vessel_ref_id = ves.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-19, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='i' and dw.deleted is null and cntr_flg<>'c'
and nterp_std_wgt/1000>60000

EXEC xp_cmdshell 'bcp "SELECT  YEAR,MTH,direction,sline,USPort,Vessel,Voyage,Feed,MTONS,BOL_ID FROM WorkTemp.dbo.PortLineBulk" queryout "G:\PortLine\PortLineBulk.txt" -T -c -t"|"' 


-- HIGH LEVEL VESSEL CHECK --

--declare @pdate DATETIME
--set @pdate= (select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH])

IF OBJECT_ID('WorkTemp.dbo.PortLineVes') IS NOT NULL DROP TABLE WorkTemp.dbo.PortLineVes
Select 
ROW_NUMBER() OVER (ORDER BY dptport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, ves.name as VESSEL,  dptport.piers_name as USPort, sline.sline,
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END) as Feed, 
sum(dw.TEU) as SumOfTEUs, COUNT(DW.BOL_ID) AS CountOfBOLs
into WorkTemp.dbo.PortLineVes
from PES_DW_BOL dw (nolock) 
left outer join dbo.PES_DW_REF_port dptport (nolock) on dw.port_depart_ref_id = dptport.id
left outer join dbo.PES_DW_REF_port ultport (nolock) on dw.ultport_ref_id = ultport.id
left outer join dbo.PES_DW_REF_CARRIER sline (nolock) on dw.sline_ref_id = sline.id
left outer join dbo.PES_DW_REF_VESSEL ves (nolock) on dw.vessel_ref_id = ves.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-7, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='e' and dw.deleted is null
group by year(dw.vdate), month(dw.vdate), dw.direction, sline.sline, dptport.piers_name, ves.name, ( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END)

INSERT INTO [WorkTemp].[dbo].[PortLineVes]
           ([ROWNUM]
			,[YEAR]
           ,[MTH]
           ,[direction]
           ,VESSEL
           ,[USPort]
           ,SLINE
	       ,FEED
           ,[SumOfTEUs]
           ,[CountOfBOLs])
Select 
ROW_NUMBER() OVER (ORDER BY arvport.piers_name) AS ROWNUM,
year(dw.vdate) as YEAR, month(dw.vdate) as MTH, dw.direction, 
ves.name as VESSEL,arvport.piers_name as USPort,  sline.sline, 
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
left outer join dbo.PES_DW_REF_VESSEL ves (nolock) on dw.vessel_ref_id = ves.id
where dw.vdate> (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate)-7, -1))) 
and dw.vdate< (SELECT DATEADD(YEAR, year(@pdate)-1900, DATEADD(mm, month(@pdate), -1))) 
and dw.direction='i' and dw.deleted is null 
group by year(dw.vdate), month(dw.vdate), dw.direction, sline.sline, arvport.piers_name,  ves.name, 
( case when vendor_code like '[EI][A-Z][A-Z][A-Z][0-9][0-9]' then 'TYPE' 
when vendor_code like '%$HSU%' then 'HSUD' 
when vendor_code like '%$HRZ%' then 'HRZN' 
when vendor_code like '%$SES%' then 'SEST' 
when vendor_code like '%$HRZ%' then 'HRZN'
when len(vendor_code)>8 then 'OTHER' else vendor_code END) 

EXEC xp_cmdshell 'bcp "SELECT  YEAR,MTH,direction,VESSEL,USPort,SLINE,FEED,SumOfTEUs,CountOfBOLs FROM WorkTemp.dbo.PortLineVes" queryout "G:\PortLine\PortLineVessel.txt" -T -c -t"|"' 

COMMIT TRANSACTION
GO
