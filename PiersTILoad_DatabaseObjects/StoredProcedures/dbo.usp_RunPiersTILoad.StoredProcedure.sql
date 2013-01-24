/****** Object:  StoredProcedure [dbo].[usp_RunPiersTILoad]    Script Date: 01/09/2013 18:40:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_RunPiersTILoad]
WITH 
EXECUTE AS CALLER
AS
BEGIN

-- Send load started email
EXEC msdb.dbo.sp_send_dbmail
 @recipients='ksauer@joc.com;alerts@joc.com;esloan@joc.com',  
 @subject ='PiersTILoad load started',  
 @body = 'TI Load started.  *NOTE: EXPORT ONLY PER KEVIN SAUER 12172012

-- Job: PiersTILoad; Server: 10.31.18.134 (PES DW)',
 @profile_name = 'Piers TI Mail Profile',
 @body_format = 'TEXT' 


EXECUTE PiersTILoad.dbo.usp_PopulateRawData 'E'
--SELECT COUNT(*) FROM dbo.stgload_raw
--SELECT COUNT(*) FROM dbo.TI_Export_MasterData

EXECUTE PiersTILoad.dbo.usp_PopulateProcessedData 'E'
--SELECT COUNT(*) FROM dbo.stgload_processed
--SELECT COUNT(*) FROM dbo.TI_Export_MasterData

EXECUTE PiersTILoad.dbo.usp_PopulateDeletedData 'E'
--SELECT COUNT(*) FROM dbo.TI_Export_MasterData

--TEMPORARILY PULLED IMPORTS OFF 
--EXECUTE PiersTILoad.dbo.usp_PopulateRawData 'I'
--SELECT COUNT(*) FROM dbo.stgload_raw
--SELECT COUNT(*) FROM dbo.TI_Import_MasterData

--EXECUTE PiersTILoad.dbo.usp_PopulateProcessedData 'I'
--SELECT COUNT(*) FROM dbo.stgload_processed
--SELECT COUNT(*) FROM dbo.TI_Import_MasterData

--EXECUTE PiersTILoad.dbo.usp_PopulateDeletedData 'I'
--SELECT COUNT(*) FROM dbo.TI_Import_MasterData

-- Send load completed email
EXEC msdb.dbo.sp_send_dbmail
 --@recipients='AAwasthi@piers.com;SKasi@piers.com;cokeefe@piers.com;eglazman@piers.com;cwigand@piers.com;', 
 -- Ram 2/1/2011
 @recipients='ksauer@joc.com;alerts@joc.com;esloan@joc.com', 
 @subject ='PiersTILoad load completed',  
 @body = 'TI Load completed.
-- Job: PiersTILoad; Server: 10.31.18.134 (PES DW)',  
--@query='SELECT * FROM whatever',
  @profile_name = 'Piers TI Mail Profile',
  @body_format = 'TEXT' 

END
GO
