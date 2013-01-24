/****** Object:  StoredProcedure [dbo].[PES_SP_STANDARDIZATIONREVIEWREPORT]    Script Date: 01/03/2013 19:48:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_SP_STANDARDIZATIONREVIEWREPORT]
     @USERNAME VARCHAR(MAX),
     @FROMDATE VARCHAR(25),
     @TODATE VARCHAR(25),
     @DIRECTION VARCHAR(1)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

---------------------------------------------VARIABLES--------------------------------------------------------------------
    DECLARE @FRMDATE DATETIME,
            @TOODATE DATETIME,
            @USERXML XML,
            @BOL_ID INT,
            @STATUS VARCHAR(50),
            @MODIFIED_BY VARCHAR(50),
            @COUNT INT       

	DECLARE @TOTALBILLSREVIEWED INT
	DECLARE @TOTALBILLSDELETED INT  

	DECLARE @COMPANYEXCEPTIONS TABLE 
	(
		BOL_ID INT,
        STATUS VARCHAR(50),
		MODIFIED_BY VARCHAR(50)
	)  
    DECLARE @REVIEWREPORT TABLE
	(
		EXCEPTIONNAME VARCHAR(50),
        REVIEWED INT,
        SKIPPED INT,       
        TOTAL INT
	)
    DECLARE @BILLSTATUS TABLE 
	(
		STATUS VARCHAR(50),
        MODIFIED_BY VARCHAR(50)
	)

	SELECT @FRMDATE = CONVERT(DATETIME, @FROMDATE)
	SELECT @TOODATE = CONVERT(DATETIME, @TODATE)

	-- CALL XMLOFUSERS FUNCTION TO RETRIEVE THE USERNAMES IN THE FORM OF XML
    SELECT @USERXML = DBO.XMLOFUSERS(@USERNAME)

    SELECT @TOTALBILLSREVIEWED=0
	SELECT @TOTALBILLSDELETED=0
---------------------------------------------COMPANY EXCEPTIONS BEGIN-----------------------------------------------------
INSERT INTO @COMPANYEXCEPTIONS(BOL_ID,STATUS,MODIFIED_BY) 
SELECT DISTINCT BOL_ID,STATUS,MODIFIED_BY 
FROM PES.DBO.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)

DECLARE CURCOMPANY CURSOR FOR  
	SELECT BOL_ID FROM PES.DBO.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK) 
	GROUP BY BOL_ID 
	HAVING COUNT(DISTINCT STATUS) > 1  
OPEN CURCOMPANY  
FETCH NEXT FROM CURCOMPANY INTO @BOL_ID  
WHILE @@FETCH_STATUS=0  
BEGIN  
	SELECT @STATUS=''  
	SELECT @MODIFIED_BY =''  
	DELETE FROM @BILLSTATUS  
	DELETE FROM @COMPANYEXCEPTIONS WHERE BOL_ID=@BOL_ID
  
	INSERT INTO @BILLSTATUS(STATUS, MODIFIED_BY)  
	SELECT STATUS, ISNULL(MODIFIED_BY,'')  FROM PES.DBO.PES_TRANSACTIONS_LIB_PTY WITH (NOLOCK)  WHERE BOL_ID = @BOL_ID  
			IF EXISTS(SELECT STATUS FROM @BILLSTATUS WHERE UPPER(STATUS) = 'PENDING')
  			SELECT @STATUS = 'PENDING'  	
			ELSE IF EXISTS(SELECT STATUS FROM @BILLSTATUS WHERE UPPER(STATUS) = 'CLEANSED')
     		SELECT @STATUS = 'CLEANSED'
			SELECT @MODIFIED_BY = MODIFIED_BY FROM @BILLSTATUS
  
	INSERT INTO @COMPANYEXCEPTIONS(BOL_ID,STATUS,MODIFIED_BY)
	SELECT @BOL_ID,@STATUS,@MODIFIED_BY  
	FETCH NEXT FROM CURCOMPANY INTO @BOL_ID  
END  
	CLOSE CURCOMPANY  
    DEALLOCATE CURCOMPANY  

INSERT INTO @REVIEWREPORT(EXCEPTIONNAME, REVIEWED, SKIPPED, TOTAL)
	SELECT 'COMPANY EXCEPTIONS',
	(
	  ISNULL(SUM(CASE LTRIM(RTRIM(UPPER(B.REVIEWED_BY)))  
        WHEN ISNULL(LTRIM(RTRIM(UPPER(B.REVIEWED_BY))),'') THEN 1 ELSE 0 END), 0)
	),
	0,
--	(
--	 SUM(CASE LTRIM(RTRIM(UPPER(B.REVIEWED_BY)))  WHEN ISNULL(LTRIM(RTRIM(UPPER(B.REVIEWED_BY))),'') THEN 0 ELSE 1 END)
--	),
	(
	 COUNT(*)
	)
	FROM DQA_BL B WITH (NOLOCK)
	JOIN ( SELECT BOL_ID,STATUS,MODIFIED_BY	FROM @COMPANYEXCEPTIONS)P 
	ON B.T_NBR=P.BOL_ID WHERE T_NBR IN 
		( 
		 SELECT T_NBR FROM BL_BL  WITH (NOLOCK), DQA_VOYAGE  WITH (NOLOCK)  
		 WHERE BL_BL.DQA_VOYAGE_ID = DQA_VOYAGE.VOYAGE_ID  
		 AND DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE'  
		 AND ISNULL(BL_BL.BOL_STATUS,'') 
		 NOT IN('MASTER','TEMPMASTER','HOUSE'))
	AND ISNULL(B.IS_DELETED, 'N') <> 'Y'  
	AND B.DIR = @DIRECTION 
	AND CONVERT(DATETIME,CONVERT(VARCHAR(11), B.REVIEWED_DT)) BETWEEN @FRMDATE AND @TOODATE  
	AND B.REVIEWED_BY IN (SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I))

---------------------------------------------QC RULES BEGIN---------------------------------------------------------------   
-- EXCEPTION NAME
INSERT INTO @REVIEWREPORT(EXCEPTIONNAME, TOTAL)
SELECT D.PROCESS_NAME, COUNT(V.T_NBR) 
 FROM CTRL_PROCESS_DEFINITION D WITH (NOLOCK) , CTRL_PROCESS_VOYAGE V WITH (NOLOCK), DQA_BL B WITH (NOLOCK)
 WHERE D.PROCESS_NAME = V.PROCESS_NAME
  AND B.T_NBR = V.T_NBR
--  AND V.COMPLETE_STATUS =0 
  AND V.DIR = @DIRECTION 
  AND B.REVIEWED_BY IN (SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I))
--  AND ISNULL(B.IS_DELETED, 'N') <> 'Y'
  AND CONVERT(DATETIME,CONVERT(VARCHAR(11), B.REVIEWED_DT)) BETWEEN @FRMDATE AND @TOODATE  
  AND (
		B.T_NBR IN 
		(
		  SELECT BL_BL.T_NBR FROM BL_BL  WITH (NOLOCK) 
		  INNER JOIN DQA_VOYAGE WITH (NOLOCK) ON BL_BL.DQA_VOYAGE_ID = 
		  DQA_VOYAGE.VOYAGE_ID WHERE (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE') 
		  AND (ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' ) AND(ISNULL(BL_BL.BOL_STATUS, '') 
		  NOT IN('MASTER','TEMPMASTER','HOUSE'))
		)
      )
  GROUP BY D.PROCESS_NAME

--REVIEWED
UPDATE R
SET REVIEWED = ISNULL(C.REVIEWED_COUNT,0)
FROM @REVIEWREPORT R
LEFT OUTER JOIN
(
	SELECT PROCESS_NAME,
           SUM(CASE LTRIM(RTRIM(UPPER(B.REVIEWED_BY))) WHEN ISNULL(LTRIM(RTRIM(UPPER(B.REVIEWED_BY))),'') 
               THEN 1 ELSE 0 END) AS REVIEWED_COUNT
           FROM DQA_BL B, CTRL_PROCESS_VOYAGE V
           WHERE B.T_NBR = V.T_NBR
                 AND B.REVIEWED_BY IN (SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I))
                 AND ISNULL(B.IS_DELETED, 'N') <> 'Y' 
--                 AND V.COMPLETE_STATUS =0
				 AND B.DIR = @DIRECTION
				 AND CONVERT(DATETIME,CONVERT(VARCHAR(11), B.REVIEWED_DT)) BETWEEN @FRMDATE AND @TOODATE  
--                 AND  B.DAILY_LOAD_DT IS NOT NULL 
                 AND (
						B.T_NBR IN 
						(
						  SELECT BL_BL.T_NBR FROM BL_BL  WITH (NOLOCK) 
						  INNER JOIN DQA_VOYAGE WITH (NOLOCK) ON BL_BL.DQA_VOYAGE_ID = 
						  DQA_VOYAGE.VOYAGE_ID WHERE (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE') 
						  AND (ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' ) AND(ISNULL(BL_BL.BOL_STATUS, '') 
						  NOT IN('MASTER','TEMPMASTER','HOUSE'))
						)
					)
     GROUP BY PROCESS_NAME   
)C
ON R.EXCEPTIONNAME = C.PROCESS_NAME
WHERE  R.EXCEPTIONNAME <> 'COMPANY EXCEPTIONS'

--SKIPPED
UPDATE @REVIEWREPORT
SET SKIPPED = 0

--REVOKED
--UPDATE R
--SET REVOKED = ISNULL(C.REVOKED_COUNT,0)
--FROM @REVIEWREPORT R
--LEFT OUTER JOIN
--(
--	SELECT PROCESS_NAME,
--           SUM(CASE LTRIM(RTRIM(UPPER(B.REVIEWED_BY))) WHEN ISNULL(LTRIM(RTRIM(UPPER(B.REVIEWED_BY))),'') 
--               THEN 0 ELSE 1 END) AS REVOKED_COUNT
--           FROM DQA_BL B, CTRL_PROCESS_VOYAGE V
--           WHERE B.T_NBR = V.T_NBR
--                 AND V.OWNER_ID IN (SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I))
--                 AND ISNULL(B.IS_DELETED, 'N') <> 'Y' 
--                 AND V.COMPLETE_STATUS =0
--				 AND V.DIR = @DIRECTION
--				 AND CONVERT(DATETIME,CONVERT(VARCHAR(11), B.DAILY_LOAD_DT)) BETWEEN @FRMDATE AND @TOODATE  
----                 AND  B.DAILY_LOAD_DT IS NOT NULL 
--                 AND (
--						B.T_NBR IN 
--						(
--						  SELECT BL_BL.T_NBR FROM BL_BL  (NOLOCK) 
--						  INNER JOIN DQA_VOYAGE (NOLOCK) ON BL_BL.DQA_VOYAGE_ID = 
--						  DQA_VOYAGE.VOYAGE_ID WHERE (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE') 
--						  AND (ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' ) AND(ISNULL(BL_BL.BOL_STATUS, '') 
--						  NOT IN('MASTER','TEMPMASTER','HOUSE'))
--						)
--					)
--     GROUP BY PROCESS_NAME   
--)C
--ON R.EXCEPTIONNAME = C.PROCESS_NAME
--WHERE  R.EXCEPTIONNAME <> 'COMPANY EXCEPTIONS'

--TOTAL
--UPDATE R
--SET TOTAL = ISNULL(C.TOTAL_COUNT,0)
--FROM @REVIEWREPORT R
--LEFT OUTER JOIN
--(
--	SELECT PROCESS_NAME,
--           COUNT(V.T_NBR) AS TOTAL_COUNT
----           SUM(CASE V.COMPLETE_STATUS WHEN '0' THEN 1 ELSE 0 END) AS TOTAL_COUNT
--           FROM DQA_BL B, CTRL_PROCESS_VOYAGE V
--           WHERE B.T_NBR = V.T_NBR
--                 AND B.REVIEWED_BY IN (SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I))
--                 AND ISNULL(B.IS_DELETED, 'N') <> 'Y' 
--                 AND V.COMPLETE_STATUS =0
--				 AND B.DIR = @DIRECTION
--				 AND CONVERT(DATETIME,CONVERT(VARCHAR(11), B.REVIEWED_DT)) BETWEEN @FRMDATE AND @TOODATE  
----                 AND  B.DAILY_LOAD_DT IS NOT NULL 
--                 AND (
--						B.T_NBR IN 
--						(
--						  SELECT BL_BL.T_NBR FROM BL_BL  (NOLOCK) 
--						  INNER JOIN DQA_VOYAGE (NOLOCK) ON BL_BL.DQA_VOYAGE_ID = 
--						  DQA_VOYAGE.VOYAGE_ID WHERE (DQA_VOYAGE.VOYAGE_STATUS = 'AVAILABLE') 
--						  AND (ISNULL(BL_BL.DQA_BL_STATUS,'') = 'PENDING' ) AND(ISNULL(BL_BL.BOL_STATUS, '') 
--						  NOT IN('MASTER','TEMPMASTER','HOUSE'))
--						)
--					)
--     GROUP BY PROCESS_NAME   
--)C
--ON R.EXCEPTIONNAME = C.PROCESS_NAME
--WHERE  R.EXCEPTIONNAME <> 'COMPANY EXCEPTIONS'
-------------------------------------------------------------Bill Wise Counts---------------------------------------------
	SELECT @TOTALBILLSREVIEWED = ISNULL(COUNT(REVIEWED),0) 	
	FROM
	(
		SELECT DISTINCT T_NBR  AS REVIEWED
		FROM DQA_BL B WITH (NOLOCK)
		WHERE B.REVIEWED_BY IN (SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I))
		AND CONVERT(DATETIME,CONVERT(VARCHAR(11), B.REVIEWED_DT)) BETWEEN @FRMDATE AND @TOODATE
		--AND COMPLETE_STATUS=0
		AND DIR=@DIRECTION		

		UNION	
        
        SELECT Distinct REVIEWED --SUM(CASE REVIEWED WHEN 0 THEN 0 ELSE 1 END) AS 'REVIEWED'
        FROM @REVIEWREPORT 
        WHERE EXCEPTIONNAME='COMPANY EXCEPTIONS'
        AND REVIEWED > 0

--		SELECT SUM(CASE REVIEWED WHEN '0' THEN 0 ELSE 1 END) FROM @REVIEWREPORT 
--        WHERE EXCEPTIONNAME='COMPANY EXCEPTIONS'
	)A
	
---------------------------------------------EXCEPTION TABLE--------------------------------------------------------------   

SELECT EXCEPTIONNAME AS 'EXCEPTIONNAME',  REVIEWED AS 'REVIEWED', SKIPPED AS 'SKIPPED', TOTAL AS 'TOTAL'
FROM @REVIEWREPORT

SELECT @TOTALBILLSREVIEWED AS 'CORRECTEDBILLCOUNT'

SELECT @TOTALBILLSDELETED AS 'DELETEDBILLCOUNT'

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
