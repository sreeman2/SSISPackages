select top 10 * from screen_test.dbo.ctrl_process_voyage (nolock)
where process_name like '%REGISTRY%'

-- Check the exception criteria
select top 10 * from screen_test.dbo.ctrl_qc_modify (nolock)
where [key] like '%REGISTRY%'

select top 10 * from screen_test.dbo.ctrl_process_definition (nolock)
where process_name like '%REGISTRY%'

-- PA
SELECT * FROM REF_COUNTRY WHERE [ISO ALPHA-2 CODE] IS NOT NULL
AND COUNTRY = 'PANAMA'



SELECT * FROM ARCHIVE_RAW_BOL (NOLOCK)
WHERE BOL_ID IN (
261061071,
261061072,
261061073
)