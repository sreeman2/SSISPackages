
Select Count(*) from PES.dbo.PES_STG_BOL (nolock) where REF_LOAD_NUM_ID=11315001

Select Count(*) from [PES_DW].PESDW. dbo.PES_DW_BOL with (nolock) where LOAD_NUMber=11315001
Select  top 10* from dbo.PES_PROGRESS_STATUS  where LoadNumber in (11319001,
11338001,
11291001,
12007001,
11327001,
11323001,
11359001,
11302001,
12003001,
11271001,
11315001,
12012001,
12016001,
11314001,
11361001,
11365001,
11336001,
11320001,
12005001,
11297001,
12022001,
11301001,
11316001,
11341001,
12018001,
11273001,
11321001,
11313001,
11337001,
11183001,
11285001,
12014001,
11309001,
11350001,
11222001,
11280001,
12004001,
11357001,
12001001,
11318001,
11286001,
11346001,
12010001,
11354001,
11311001,
11360001,
11349001,
11351001,
11299001,
11294001,
11363001,
11279001,
12011001,
11307001,
11344001,
12008001,
11290001,
11328001,
11358001,
11333001,
11364001,
11331001,
11345001,
11305001,
12013001,
11326001,
11334001,
11340001,
11343001,
11281001,
11322001,
12006001,
11325001,
11179001,
11296001,
11308001,
11298001,
11289001,
11277001,
11292001,
12019001,
12021001,
11300001,
11310001,
11288001,
11264001,
11339001,
11282001,
11355001,
11348001,
12020001,
11312001,
11353001,
11303001,
11329001,
11304001,
11172001,
11293001,
11317001,
11324001,
11352001,
11347001,
11335001,
11332001,
12009001,
11295001,
11306001,
11362001,
11356001,
11102001,
11287001,
12017001,
11284001,
12015001,
11330001,
11342001)
order by Load_DT desc 