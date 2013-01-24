--Total =24296
--Today total=43855 as of July 06,2012
--Today total=52238 as of July 11,2012, 3:32pm
/* get all DIS data for Month 3,4 for the year 2012*/
Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Dtemp
From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='DIS' 
--substring('04172012',1,2), substring('04172012',3,2), substring('04172012',5,4)
and substring(D.Sailing_date,1,2) in ('03','04') and substring(D.Sailing_date,5,4)='2012'

Select * from #Dtemp

--Total=372886
--Today total=372886 as of July 11,2012, 3:32pm
/* get all ESCAN data for Month 3,4 for the year 2012*/
Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Etemp
From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='ESCAN' 
--substring('04172012',1,2), substring('04172012',3,2), substring('04172012',5,4)
and substring(D.Sailing_date,1,2) in ('03','04') and substring(D.Sailing_date,5,4)='2012'

Select top 100 * from #ETemp


Select 
E.bol_ID, E.BOL_NUMBER,E.DISCHARGE_PORT, E.PORT_OF_DESTINATION, E.VOYAGE_NUMBER, E.Sailing_date,
D.bol_ID DIS_BOL_ID, D.BOL_NUMBER DIS_Bill_number,D.DISCHARGE_PORT DIS_DischargePort, D.PORT_OF_DESTINATION DIS_PortOfDestination, D.VOYAGE_NUMBER DIS_VoyageNumber, D.Sailing_date DIS_SailingDate
into TEMP_PES.dbo.DISESCAN_DUP0711_2012
From #Dtemp D join #ETemp E on 
(D.Bol_number=E.Bol_number 
and D.DISCHARGE_PORT=E.DISCHARGE_PORT 
And D.PORT_OF_DESTINATION=E.PORT_OF_DESTINATION
--and D.VOYAGE_NUMBER=E.VOYAGE_NUMBER
and D.Sailing_date=E.Sailing_date)

Select Count(*) From TEMP_PES.dbo.DISESCAN_DUP (nolock)


Select Is_Deleted from PEs.dbo.PES_STG_BOL (nolock) group by  Is_Deleted
--Step1 to delete STG BOL
update  STG
set  STG.is_Deleted='Y',MODIFY_DATE=getDate()
--Select * 
from PES.dbo.PES_STG_BOL  STG   where STG.Bol_ID in 
(select DIS_BOL_ID From TEMP_PES.dbo.DISESCAN_DUP0711_2012  with (nolock))
and STG.REF_VENDOR_CODE='DIS'

--Step2 to delete STG CMD
update  STGCMD
set  STGCMD.is_Delete='Y',MODIFY_DATE=getDate()

--Select * 
from PES.dbo.PES_STG_CMD  STGCMD   where STGCMD.Bol_ID in 
(select DIS_BOL_ID From TEMP_PES.dbo.DISESCAN_DUP0711_2012  with (nolock))

Select top 10 DIS_BOL_ID From TEMP_PES.dbo.DISESCAN_DUP0706_2012 (nolock)

/*[HD] updates without voyage comparision
DISESCAN_DUP0711_2012_new_novoyage_1*/

Select Is_Deleted from PEs.dbo.PES_STG_BOL (nolock) group by  Is_Deleted
--Step1 to delete STG BOL
update  STG
set  STG.is_Deleted='Y',MODIFY_DATE=getDate()
--Select * 
from PES.dbo.PES_STG_BOL  STG   where STG.Bol_ID in 
(select DIS_BOL_ID From TEMP_PES.dbo.DISESCAN_DUP0711_2012_new_novoyage_1  with (nolock))
and STG.REF_VENDOR_CODE='DIS' and STG.is_Deleted<>'Y'
--2349 row(s) affected

--Step2 to delete STG CMD
update  STGCMD
set  STGCMD.is_Delete='Y',MODIFY_DATE=getDate()
--Select * 
from PES.dbo.PES_STG_CMD  STGCMD   where STGCMD.Bol_ID in 
(select DIS_BOL_ID From TEMP_PES.dbo.DISESCAN_DUP0711_2012_new_novoyage_1  with (nolock))
and STGCMD.is_Delete is null
--3233 row(s) affected