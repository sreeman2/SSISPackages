--Total =24296
--Today total=43855 as of July 06,2012
--step 0
Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Dtemp
From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='DIS' 
--substring('04172012',1,2), substring('04172012',3,2), substring('04172012',5,4)
and substring(D.Sailing_date,1,2) in ('03','04','05') and substring(D.Sailing_date,5,4)='2012'



--Step 1
Select BOL_NUMBER, count(*)  cnt into #dupTemp   from #Dtemp
group by BOL_NUMBER
having count(*) > 1
order by cnt desc


--step 2
Select *  into TEMP_PES.dbo.OnlyDISDuplicates_07192012 from   #Dtemp 
where bol_number in (Select bol_number from #dupTemp)
order by bol_number 

--Step 3
------------------------------
;WITH CTE as(
SELECT	bol_number,bol_id ,ROW_NUMBER() OVER (partition by BOL_NUMBER order by BOL_NUMBER ) AS RowID
FROM TEMP_PES.dbo.OnlyDISDuplicates_07192012
),tmpa as (
Select * from  CTE 
where RowID>1)

/*
update  STG
set  MODIFY_DATE=getDate(),Is_Deleted='Y'
--Select *  -- total duplicates marked deleted=14631
from PES.dbo.PES_STG_BOL  STG   where STG.Bol_ID in 
(Select bol_ID from tmpa)   */
--and STG.REF_VENDOR_CODE='DIS'

--Step4 to delete STG CMD
update  STGCMD
set  MODIFY_DATE=getDate()
--Select * 
from PES.dbo.PES_STG_CMD  STGCMD   where STGCMD.Bol_ID in 
(Select bol_ID from tmpa)

---------------------------------------------






where  bol_id in(Select )





Select * from #Dtemp where bol_number='KUABD9K00'

--total=73305


with tmpx as (select * from #DTemp order by

SELECT Bol_ID, BOL_NUMBER
FROM CTE
WHERE RowID = 1











--Total=372886
Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Etemp
From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='ESCAN' 
--substring('04172012',1,2), substring('04172012',3,2), substring('04172012',5,4)
and substring(D.Sailing_date,1,2) in ('03','04') and substring(D.Sailing_date,5,4)='2012'

Select top 100 * from #ETemp


Select 
E.bol_ID, E.BOL_NUMBER,E.DISCHARGE_PORT, E.PORT_OF_DESTINATION, E.VOYAGE_NUMBER, E.Sailing_date,
D.bol_ID DIS_BOL_ID, D.BOL_NUMBER DIS_Bill_number,D.DISCHARGE_PORT DIS_DischargePort, D.PORT_OF_DESTINATION DIS_PortOfDestination, D.VOYAGE_NUMBER DIS_VoyageNumber, D.Sailing_date DIS_SailingDate
into TEMP_PES.dbo.DISESCAN_DUP0706_2012
From #Dtemp D join #ETemp E on 
(D.Bol_number=E.Bol_number 
and D.DISCHARGE_PORT=E.DISCHARGE_PORT 
And D.PORT_OF_DESTINATION=E.PORT_OF_DESTINATION
and D.VOYAGE_NUMBER=E.VOYAGE_NUMBER
and D.Sailing_date=E.Sailing_date)

Select Count(*) From TEMP_PES.dbo.DISESCAN_DUP (nolock)



--Step1 to delete STG BOL
update  STG
set  MODIFY_DATE=getDate(),Is_Deleted='Y'

--Select * 
from PES.dbo.PES_STG_BOL  STG   where STG.Bol_ID in 
(Select bol_ID from #temp)
and STG.REF_VENDOR_CODE='DIS'

--Step2 to delete STG CMD
update  STGCMD
set  MODIFY_DATE=getDate()
--Select * 
from PES.dbo.PES_STG_CMD  STGCMD   where STGCMD.Bol_ID in 
(Select bol_ID from #temp)

Select * from 
Select * into #temp from [PESDW].workTemp.dbo.shreeTemp



Select top 10 DIS_BOL_ID From TEMP_PES.dbo.DISESCAN_DUP0706_2012 (nolock)