select top 10 * from pes_stg_bol (nolock)
where bol_nbr = 'AMAWA1210350371'


select top 10 * from archive_raw_bol (nolock)
where bol_id = 261039256

-- Foreign_loading_port
select top 10 * from ref_port (nolock) where code = 57047

-- discharge port
select top 10 * from ref_port (nolock) where code = 0005
