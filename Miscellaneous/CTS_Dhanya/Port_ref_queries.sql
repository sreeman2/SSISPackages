-- look up ref_port
-- Match the discharge_port (from file) and source (from ref data below) 
-- output USPORT_TARGET = target (from ref data below)
SELECT * FROM PES_PORT_CONVERSION WHERE IS_US_PORT='1'

-- look up foreign port
-- Match the foreign_loading_port(from file) and source (from ref data below)
-- output FPORT_TARGET = target (from ref data below)
SELECT * FROM PES_PORT_CONVERSION WHERE IS_US_PORT=0
AND SOURCE  IN(SELECT SOURCE FROM PES_PORT_CONVERSION WHERE IS_US_PORT=0
GROUP BY SOURCE HAVING COUNT(*)=1)

-- look up discharge port
-- Match discharge_port and code 
-- output ID
SELECT * FROM REF_PORT WHERE IS_US_PORT=1 AND IS_TMP='N' AND DELETED='N' 
AND CODE IN(SELECT CODE FROM REF_PORT 
			 WHERE IS_US_PORT=1 AND IS_TMP='N' AND DELETED='N' 
             GROUP BY CODE HAVING COUNT(*)=1)

-- INVALID DISCHARGE PORT
-- look up for discharge_port
-- match discharge_port with the name_key 
-- output = REF_ID
SELECT A.NAME_KEY,A.REF_ID FROM LIB_PORT A, REF_PORT B 
WHERE A.REF_ID=B.ID AND A.IS_US_PORT=1 AND B.IS_US_PORT=1 
AND B.DELETED='N' AND B.IS_TMP='N' AND A.NAME_KEY 
IN(SELECT NAME_KEY FROM LIB_PORT WHERE IS_US_PORT=1 GROUP BY NAME_KEY HAVING COUNT(*)=1)

-- fuzzy look up 2
-- Ref table = PES_REF_US_PORT_FUZZY
-- Match PORT_OF_DEPARTURE AND PIERS_NAME 
-- Output = ID
SELECT * FROM PES_REF_US_PORT_FUZZY (NOLOCK) 

-- fuzzy look up
-- Match PORT_OF_DEPARTURE AND NAME_KEY
-- Output = REF_ID
SELECT * FROM PES_LIB_US_PORT_FUZZY (NOLOCK) 

-- match id and lkp_discharge_port
-- look up ref_port
-- output = pires_name,code
SELECT * FROM REF_PORT WHERE IS_US_PORT=1 AND ID<>0 
AND DELETED='N' AND IS_TMP='N'

-- Look up for foreign port
SELECT SOURCE,TARGET FROM PES_PORT_CONVERSION WHERE IS_US_PORT=0

-- Look up for us port
SELECT SOURCE,TARGET FROM PES_PORT_CONVERSION WHERE IS_US_PORT=1
