--Total =24296
Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Dtemp
From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='DIS' 
--substring('04172012',1,2), substring('04172012',3,2), substring('04172012',5,4)
and substring(D.Sailing_date,1,2) in ('03','04') and substring(D.Sailing_date,5,4)='2012'

Select * from #Dtemp

--Total=372886
Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Etemp
From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='ESCAN' 
--substring('04172012',1,2), substring('04172012',3,2), substring('04172012',5,4)
and substring(D.Sailing_date,1,2) in ('03','04') and substring(D.Sailing_date,5,4)='2012'

Select top 100 * from #ETemp


Select 
E.bol_ID, E.BOL_NUMBER,E.DISCHARGE_PORT, E.PORT_OF_DESTINATION, E.VOYAGE_NUMBER, E.Sailing_date,
D.bol_ID DIS_BOL_ID, D.BOL_NUMBER DIS_Bill_number,D.DISCHARGE_PORT DIS_DischargePort, D.PORT_OF_DESTINATION DIS_PortOfDestination, D.VOYAGE_NUMBER DIS_VoyageNumber, D.Sailing_date DIS_SailingDate
into TEMP_PES.dbo.DISESCAN_DUP
From #Dtemp D join #ETemp E on 
(D.Bol_number=E.Bol_number 
and D.DISCHARGE_PORT=E.DISCHARGE_PORT 
And D.PORT_OF_DESTINATION=E.PORT_OF_DESTINATION
and D.VOYAGE_NUMBER=E.VOYAGE_NUMBER
and D.Sailing_date=E.Sailing_date)
