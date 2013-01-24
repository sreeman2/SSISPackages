/****** Object:  StoredProcedure [dbo].[USP_GENERATE_EXPERIAN]    Script Date: 01/08/2013 14:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GENERATE_EXPERIAN] 
@YYYYMM	CHAR(6)

AS
BEGIN

-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


	--Truncate the table TEMP_VIN_EXPERIAN
   TRUNCATE TABLE TEMP_VIN_EXPERIAN
	
	INSERT INTO [PESDW].[dbo].[TEMP_VIN_EXPERIAN]
           ([VIN_NBR]
           ,[EXPORT_DATE]
           ,[USCODE]
           ,[CTRYCODE]
		   ,[BOL_NBR]
           ,[INDICATOR])           
              
	SELECT DISTINCT V.VIN_NUMBER,
    REPLACE (CONVERT(CHAR(10),B.VDATE,101), '/' , '' ) AS 'EXPORT_DATE',			

	(
	SELECT TOP 1 ISNULL(CODE,'')
	FROM PES_DW_REF_PORT P WITH (NOLOCK) 
	WHERE P.ID = B.PORT_DEPART_REF_ID
	)
	
	 AS 'USCODE',	
    
    (SELECT TOP 1 ISNULL(CTRY_CODE,'') 
	FROM PES_DW_REF_COUNTRY C WITH (NOLOCK)
	WHERE C.CTRY_CODE = B.CTRYCODE
	) AS CTRYCODE,

	V.BILL_NUMBER AS 'BOL_NBR',
    
  case when (c.CMD_DESC like '%NEW TIRES%' or
             c.CMD_DESC like '%NEWSPRINT%' OR 
             c.CMD_DESC like '%NEW CAR PTS%'or
             c.CMD_DESC like '%NEW YORKER%' or
             c.CMD_DESC like '%NEW SHOES%' OR 
             c.CMD_DESC like '%NEWMAR%'  or
             c.CMD_DESC like '%NEW YORK%' OR 
             c.CMD_DESC like '%NEW PORT%' or
             c.CMD_DESC like '%NEWPORT%' OR 
             c.CMD_DESC like '%W USED HH%'  or
             c.CMD_DESC like '%USED&%' OR 
             c.CMD_DESC like '%NEW&%'  or
             c.CMD_DESC like '%USED & NEW%' OR 
             c.CMD_DESC like '%NEW & USED%'  or
             c.CMD_DESC like '%USED& NEW%' OR 
             c.CMD_DESC like '%NEW& USED%'  or
             c.CMD_DESC like '%NEW AND USED%'  or
             c.CMD_DESC like '%USED AND NEW%' OR 
             c.CMD_DESC like '%NEWYORKER%'  or
             c.CMD_DESC like '%NEWPOWER%' OR 
             c.CMD_DESC like '%NEWSPAPER%'  or            
             c.CMD_DESC like '%NEW WHEELS%'  or
             c.CMD_DESC like '%NEW SNOW TIRES%')             
    then 'UN' 
       else 
  case  when  (c.CMD_DESC like 'NEW%')  then 'NE' --NEW
       else
       'US'										   --USED
       END 
  END  INDICATOR  
    

	FROM PES_DW_VIN V WITH (NOLOCK)
	JOIN PES_DW_BOL B WITH (NOLOCK)
    ON V.BOL_ID=B.BOL_ID
    
    JOIN PES_DW_CMD C WITH (NOLOCK)
    ON V.BOL_ID=C.BOL_ID 
    
	WHERE CONVERT(CHAR(6),V.VDATE,112) = @YYYYMM	
	AND V.DIR = 'E'

-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
