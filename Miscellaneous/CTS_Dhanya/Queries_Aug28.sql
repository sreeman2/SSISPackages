VESSEL_NAME = 'HD. JAKARTA'
SRC_VESSEL_NAME = 'HD. JAKARTA'

-- COMPRESSED
SELECT REPLACE(LTRIM(RTRIM('HD. JAKARTA')),' ','')

COMPRESSED_VESSEL_NAME = 'HD.JAKARTA'

-- INVALID VESSEL_ID = 0
VESSEL_NAME = 'HD. JAKARTA'

-- PES_STG_BOL
select vessel_ref_id,vessel_name,src_vessel_name,STND_VOYG_ID,* from pes_stg_bol(nolock) where bol_id 
IN (253972831,253972832,253972833)

-- LOADING EXCEPTION TABLES
-- vessel_id = PES_STG_BOL.VESSEL_REF_ID
-- vessel_id = 311908
-- vessel_name = HD. JAKARTA
SELECT vessel_id,vessel_name,CARRIER_ID as carrier,USPORT_ID as portid,* FROM [Screen_Test].[dbo].STD_VOYAGE (NOLOCK) 
WHERE t_nbr IN (253972831,253972832,253972833)

-- CTRL_PROCESS_VOYAGE

SELECT [key],* FROM [Screen_Test].[dbo].CTRL_PROCESS_VOYAGE (nolock)
WHERE t_nbr IN (253972831,253972832,253972833) and process_name = 'INVALID VESSEL NAME'
 
-- BL_CACHE
SELECT vessel_name,* FROM [Screen_Test].[dbo].[BL_CACHE] (nolock)
WHERE t_nbr IN (253972831,253972832,253972833)

select vessel_name,vessel_id,* from [Screen_Test].[dbo].dqa_VOYAGE (nolock)
where voyage_id = 678769


select vessel_id,dqa_voyage_id,* from [Screen_Test].[dbo].BL_BL (nolock)
WHERE t_nbr IN (253972831,253972832,253972833)

 select DQA_VOYAGE_ID,
     DAILY_LOAD_DT,  
     MANIFEST_NBR_MOD,
     VOYAGE,
     CARRIER_ID_MOD,
     CARRIER_NAME_MOD,
     VESSEL_ID_MOD,
     VESSEL_NAME_MOD,
     USPORT_ID_MOD,
     USPORT_CODE_MOD,
     USPORT_NAME_MOD,
     MODIFIED_DT ,*
    FROM [Screen_Test].[dbo].DQA_BL B (nolock)
    where t_nbr IN (253972831,253972832,253972833)

select * from [Screen_Test].[dbo].BL_BL B (nolock)
   where t_nbr IN (253972831,253972832,253972833)

select top 1 * from REF_VESSEL_CARRIER (nolock) where vessel_id = 9244

------------------------------------------------------------------------
VALID VESSELS
------------------------------------------------------------------------

VESSEL_NAME = 'VIRGINIA BRIDGE'
SRC_VESSEL_NAME = 'VIRGINIA BRIDGE'

-- COMPRESSED
SELECT REPLACE(LTRIM(RTRIM('HD. JAKARTA')),' ','')

COMPRESSED_VESSEL_NAME = 'VIRGINIABRIDGE'

-- VALID VESSEL_ID = 66560
SELECT * FROM REF_VESSEL WHERE NAME = 'VIRGINIA BRIDGE' AND DELETED = 'N'

-- PES_STG_BOL
select vessel_ref_id,vessel_name,src_vessel_name,STND_VOYG_ID,* from pes_stg_bol(nolock) where bol_id 
IN (255445524,255445525,255445526)


-- LOADING EXCEPTION TABLES
-- vessel_id = PES_STG_BOL.VESSEL_REF_ID
-- vessel_id = 311908
-- vessel_name = HD. JAKARTA
-- NO EXCEPTION AS VESSEL_REF_ID  <> 0 IN PES_STG_BOL
SELECT vessel_id,vessel_name,CARRIER_ID as carrier,USPORT_ID as portid,* FROM [Screen_Test].[dbo].STD_VOYAGE (NOLOCK) 
WHERE t_nbr IN  (255445524,255445525,255445526)

-- CTRL_PROCESS_VOYAGE
-- NO EXCEPTION FOR VESSELS AS VESSEL_REF_ID  <> 0 IN PES_STG_BOL

SELECT [key],* FROM [Screen_Test].[dbo].CTRL_PROCESS_VOYAGE (nolock)
WHERE t_nbr IN (255445524,255445525,255445526) and process_name = 'INVALID VESSEL NAME'
 
-- BL_CACHE
-- NO EXCEPTION FOR VESSELS AS VESSEL_REF_ID  <> 0 IN PES_STG_BOL
SELECT vessel_name,* FROM [Screen_Test].[dbo].[BL_CACHE] (nolock)
WHERE t_nbr IN (255445524,255445525,255445526)

-- CHECK DQA_VOYAGE -- IT IS LOADED FROM DQA_BL
select vessel_name,vessel_id,* from [Screen_Test].[dbo].dqa_VOYAGE (nolock)
where voyage_id = 691554

-- Log table for the modified vessels
SELECT * FROM [SCREEN_TEST].[dbo].[GLOBAL_UPDATE] 
WHERE voyage_id = 691554

select vessel_id,dqa_voyage_id,* from [Screen_Test].[dbo].BL_BL (nolock)
WHERE t_nbr IN (255445524,255445525,255445526)

 select DQA_VOYAGE_ID,
     DAILY_LOAD_DT,  
     MANIFEST_NBR_MOD,
     VOYAGE,
     CARRIER_ID_MOD,
     CARRIER_NAME_MOD,
     VESSEL_ID_MOD,
     VESSEL_NAME_MOD,
     USPORT_ID_MOD,
     USPORT_CODE_MOD,
     USPORT_NAME_MOD,
     MODIFIED_DT ,*
    FROM PES_PURGE.[dbo].ARCHIVE_DQA_BL B (nolock)
    where t_nbr IN (255445524,255445525,255445526)

select * from [Screen_Test].[dbo].BL_BL B (nolock)
   where t_nbr IN (255445524,255445525,255445526)

select * from archive_RAW_BOL 
where bol_id  IN (
254867544,
254868971,
254868972,
254868973,
254868987,
254868988,
254868991
)

SELECT B.BOL_ID,B.REF_LOAD_NUM_ID,ISNULL(B.VOYAGE,''),  
 ISNULL(B.VDATE,''),ISNULL(B.MANIFEST_NUMBER,''),B.BOL_DIRECTION,B.VESSEL_NAME,B.SLINE_REF_ID,  
 B.PORT_DEPART_REF_ID, B.VESSEL_REF_ID,B.BATCH_ID   
 FROM archive_RAW_BOL A  WITH (NOLOCK)  join PES_STG_BOL B   WITH (NOLOCK)   
 on A.BOL_ID=B.BOL_ID   
 WHERE B.SLINE_REF_ID<>0 AND PORT_DEPART_REF_ID<>0 AND VESSEL_REF_ID<>0 
and b.bol_id  IN (
254867544,
254868971,
254868972,
254868973,
254868987,
254868988,
254868991
)


select * from [PES_AUDIT_LOGS_VSL_VYG]
where voyage_id  = 691554




