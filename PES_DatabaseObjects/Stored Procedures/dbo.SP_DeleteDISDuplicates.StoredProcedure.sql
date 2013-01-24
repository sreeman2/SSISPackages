/****** Object:  StoredProcedure [dbo].[SP_DeleteDISDuplicates]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DeleteDISDuplicates] @sdate as varchar (16)
AS
BEGIN
	Select  D.bol_ID, D.BOL_NUMBER,DISCHARGE_PORT, PORT_OF_DESTINATION, VOYAGE_NUMBER, D.Sailing_date into #Dtemp
    From PES.dbo.ARCHIVE_RAW_BOL D (nolock)  where D.Vendor_code='DIS' and substring(D.Sailing_date,1,2)=@sdate
select top 100* from #Dtemp(nolock)

END
GO
