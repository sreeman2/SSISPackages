-- look up 1 Match discharge port and source
-- US ports
-- output - target
SELECT top 10 * FROM PES_PORT_CONVERSION WHERE IS_US_PORT='1'

-- look up 2 Match discharge port and source
-- Foreign ports
-- output - target
SELECT * FROM PES_PORT_CONVERSION WHERE IS_US_PORT=0
AND SOURCE  IN(SELECT SOURCE FROM PES_PORT_CONVERSION WHERE IS_US_PORT=0
GROUP BY SOURCE HAVING COUNT(*)=1)

-- look up for discharge port
-- Match the Port Code from Ref table and discharge port 
-- output - id
SELECT * FROM REF_PORT WHERE IS_US_PORT=1 AND IS_TMP='N' AND DELETED='N' 
AND CODE IN(SELECT CODE FROM REF_PORT WHERE IS_US_PORT=1 AND IS_TMP='N' 
AND DELETED='N' GROUP BY CODE HAVING COUNT(*)=1)

-- look up for discharge port
-- Match the Name_Key from Ref table and discharge port 
-- output - Ref_id
SELECT A.NAME_KEY,A.REF_ID FROM LIB_PORT A, REF_PORT B 
WHERE A.REF_ID=B.ID AND A.IS_US_PORT=1 AND B.IS_US_PORT=1 AND B.DELETED='N' AND B.IS_TMP='N' 
AND A.NAME_KEY IN(SELECT NAME_KEY FROM LIB_PORT WHERE IS_US_PORT=1 GROUP BY NAME_KEY HAVING COUNT(*)=1)

-- look up for port of departure 
-- Match the  port of departure and piers_name 
-- Output - ID
SELECT TOP 10 * FROM PES_REF_US_PORT_FUZZY (NOLOCK)

SELECT * FROM REF_PORT WHERE IS_US_PORT=1 AND ID<>0 AND DELETED='N' AND IS_TMP='N'


select * from GTCore_MasterData.dbo.ref_port (nolock)
where id  = 302209
-- Foreign port null
SELECT SOURCE,TARGET FROM PES_PORT_CONVERSION WHERE IS_US_PORT=1

-- Foreign port
SELECT SOURCE,TARGET FROM 
PES_PORT_CONVERSION 
WHERE IS_US_PORT=0



SELECT * FROM REF_PORT WHERE IS_US_PORT=1 AND ID<>0 AND DELETED='N' AND IS_TMP='N'