Select * 
--step 1 
;WITH CTE as(
SELECT	bol_number,bol_id ,ROW_NUMBER() OVER (partition by BOL_NUMBER order by BOL_NUMBER ) AS RowID
FROM [10.31.18.132].TEMP_PES.dbo.OnlyDISDuplicates_07192012
),tmpa as (
Select * from  CTE 
where RowID>1)


update  DW
set DW.Modify_date=getDate(), DW.Deleted='Y'
--Select DW.*
from dbo.PES_DW_BOL  DW  where DW.Bol_ID in 
(select BOL_ID From tmpa  with (nolock))
--and DW.Vendor_code='DIS'



;WITH CTE as(
SELECT	bol_number,bol_id ,ROW_NUMBER() OVER (partition by BOL_NUMBER order by BOL_NUMBER ) AS RowID
FROM [10.31.18.132].TEMP_PES.dbo.OnlyDISDuplicates_07192012
),tmpa as (
Select * from  CTE 
where RowID>1)

update  DWCMD
set DWCMD.Modify_date=getDate(), DWCMD.Deleted='Y'
--Select distinct top 10  Deleted  
from dbo.PES_DW_CMD  DWCMD (nolock) where DWCMD.Bol_ID in 
(select BOL_ID From tmpa  with (nolock))
--and DW.Vendor_code='DIS'
commit tran;


Select Deleted,* from  PESDW.dbo.PES_DW_BOL where bol_id=253464654

--select DIS_BOL_ID From [10.31.18.132].TEMP_PES.dbo.DISESCAN_DUP0711_2012  with (nolock) where DIS_BOL_ID=252377721

/*[HD-07-13-2012] updates without voyage comparision
PES.TEMP_PES.dbo.DISESCAN_DUP0711_2012_new_novoyage_1*/
begin tran
update  DW
set DW.Modify_date=getDate(), DW.Deleted='Y'
--select *
from dbo.PES_DW_BOL  DW  where DW.Bol_ID in 
(select DIS_BOL_ID From [10.31.18.132].TEMP_PES.dbo.DISESCAN_DUP0711_2012_new_novoyage_1  with (nolock))
and DW.Vendor_code='DIS' and DW.Deleted is null
--2416 row(s) affected

update  DWCMD
set DWCMD.Modify_date=getDate(), DWCMD.Deleted='Y'
--Select * 
from dbo.PES_DW_CMD  DWCMD (nolock) where DWCMD.Bol_ID in 
(select DIS_BOL_ID From [10.31.18.132].TEMP_PES.dbo.DISESCAN_DUP0711_2012_new_novoyage_1  with (nolock))
and DWCMD.Deleted is null
--3197 row(s) affected
