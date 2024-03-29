/****** Object:  View [dbo].[PES_LIB_PORT_NW_FUZZY]    Script Date: 01/03/2013 19:44:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PES_LIB_PORT_NW_FUZZY] AS
SELECT ID,CODE_KEY,CAST(REPLACE(NAME_KEY,' ','') AS VARCHAR(35)) 
AS NAME_KEY,REF_ID,ACTIVE,MODIFY_DATE,MODIFY_USER,IS_US_PORT FROM LIB_PORT WHERE 
IS_US_PORT=0 AND REF_ID IN(SELECT ID FROM REF_PORT WHERE DEEPWATER_FLG='N' AND DELETED='N' 
AND IS_TMP='N' AND IS_US_PORT=0)
GO
