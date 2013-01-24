
-- blank vessels
-- bol ids = 260172561,260172581
select top 10 * from base.boldetail_pes (nolock)
where bol_nbr in 
(
'MSCU0E679086',
'MSCUOE674095'
)


--10.31.18.148 Newcbmidb
select distinct vessel_id from Base.BOLDetail_PES (nolock) where iscurrent=1
except
select vessel_id from Base.Vessel (nolock) where iscurrent=1

