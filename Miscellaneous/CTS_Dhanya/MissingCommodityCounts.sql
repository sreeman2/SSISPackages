Select * from Screen_test.dbo.FeedLoadPriority (Nolock) where feedFileName='AMS121025.DAT'

12299001
Select top 100 * from hep_log (nolock) where FileName='AMS121025.DAT'
--Raw

--FlatFile Information
/*
  Bol Total=23750
  CMD Total=38627
  CNTR Total=12597
*/
--Archieve Raw tables
Select Count(*)  from  dbo.ARCHIVE_RAW_BOL (Nolock) where Load_Number=12299001
Select BOL_ID into #temp from  dbo.ARCHIVE_RAW_BOL (Nolock) where Load_Number=12299001
Select count(*)  from  dbo.ARCHIVE_RAW_CMD (Nolock) where bol_id in (select bol_id from #temp)
--Staging Information
--Total BOLs= 8544
Select count(*)  from  dbo.PES_STG_BOL (Nolock) where Ref_load_Num_ID=12299001
Select BOL_ID into #tempSTG from  dbo.PES_STG_BOL (Nolock) where Ref_load_Num_ID=12299001

Select Top 100 *   from  dbo.PES_STG_CMD (Nolock) where bol_id in (select bol_id from #tempSTG)



SELECT  distinct bol_ID  FROM HCS_COMMODITY (NOLOCK) WHERE BOL_ID in (select bol_id from #tempSTG) 
and DQA_CMDS_STATUS='UNCODED' AND STG_CMD_FLAG = 'N'


Select Count(*)  from Screen_test.dbo.bl_bl (nolock) where Load_nbr=12299001
Select  *  from Screen_test.dbo.dqa_cmds (nolock) where t_nbr in (Select BOL_ID from #tempSTG)

















--BolID with commodity records =174 (#validBol)
Select stgcmd.bol_id,stgcmd.cmd_id  into #validBol1 from  dbo.PES_STG_CMD  stgcmd (Nolock)  join #tempSTG  on (stgcmd.bol_id=#tempSTG.bol_id)

Select bol_id   from #tempSTG where bol_id=260414313
minus 
Select bol_id,cmd_id from #validBol1 where bol_id=260414313


Select stgbol.bol_id  --into #InvalidBol 
from  #tempSTG  stgbol (Nolock)   join #validBol  on (stgbol.bol_id!=#validBol.bol_id)
 --where stgbol.Ref_load_Num_ID=12299001




Select count(*)  from  dbo.PES_STG_CMD (Nolock) where bol_id in (select bol_id from #tempSTG)



