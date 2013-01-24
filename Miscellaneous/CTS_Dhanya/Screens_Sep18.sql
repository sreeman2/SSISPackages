
-- COUNT = 0 
SELECT COUNT(*) FROM PES_STG_BOL (NOLOCK)
WHERE SLINE_REF_ID IN (SELECT ID FROM REF_CARRIER WHERE TYPE = 'UASC') 
AND REF_VENDOR_CODE = 'DIS' AND ISNULL(IS_DELETED,'') <> 'Y' 


SELECT TOP 10 * FROM SCREEN_TEST.DBO.DQA_BL (NOLOCK)
WHERE CARRIER_ID = 328

-- COUNT = 9144
SELECT * FROM SCREEN_TEST.DBO.DQA_BL (NOLOCK)
WHERE LOAD_NBR IN (
SELECT DISTINCT LOAD_NUMBER FROM ARCHIVE_RAW_BOL (NOLOCK)
WHERE CARRIER_CODE = 'UASC' AND VENDOR_CODE = 'DIS')
AND CARRIER_ID = 328


select 



SELECT * FROM REF_CARRIER (NOLOCK) WHERE TYPE = 'UASC'

SELECT TOP 10 * FROM SCREEN_TEST.DBO.DQA_VOYAGE (NOLOCK)



SELECT SERVERPROPERTY(6208)

 select * from sys.sysprocesses



SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext 





where spid>=50 and dbid>0
--	and cpu >= (3600)
and [program_name] = 'Microsoft SQL Server Analysis Services'
order by spid


SELECT [name], starttime, endtime, datediff(ss, starttime, getdate() )/3600.0 as DTS_RUNHRS
FROM sysdtspackagelog 
where endtime is NULL
 --and datediff(ss, starttime, getdate() )/3600.0 >= 4
ORDER BY starttime DESC


SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext 



