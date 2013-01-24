SELECT COUNT(*) FROM PES.DBO.PES_STG_BOL (NOLOCK)
WHERE REGISTRY_ID = 0

-- GET ALL EXCEPTION RECORDS FROM STAGING

SELECT * INTO #REG_EXCPS
FROM PES_STG_BOL STG (NOLOCK)
WHERE STG.REGISTRY_ID = 0

-- FIND THE COUNTRY FOR THESE VESSELS FROM REF_VESSEL TABLE
SELECT REG.BOL_ID,REF.VESSEL_COUNTRY INTO #TMP_UPDATE
FROM #REG_EXCPS REG,REF_VESSEL REF(NOLOCK)
WHERE REG.VESSEL_NAME = REF.NAME

SELECT REF.COUNTRY_ID,UPD.* INTO #TMP_UPDATE1
FROM #TMP_UPDATE UPD,REF_COUNTRY REF
WHERE UPD.VESSEL_COUNTRY = COUNTRY

-- UPDATE STG
FROM PES_STG_BOL STG,#TMP_UPDATE1 UPD1
SET STG.REGISTRY_ID = COUNTRY_ID
WHERE STG.BOL_ID = UPD1.BOL_ID
