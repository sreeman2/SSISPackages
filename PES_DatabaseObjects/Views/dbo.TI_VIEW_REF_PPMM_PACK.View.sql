/****** Object:  View [dbo].[TI_VIEW_REF_PPMM_PACK]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TI_VIEW_REF_PPMM_PACK]
AS

SELECT ID,AMSUM,UM,MODIFIED_BY,MODIFIED_DT,DELETED
--IS_TMP		--Commented by Cognizant, 1-Dec-2009
FROM 
(
	SELECT RANK() OVER(PARTITION BY AMSUM ORDER BY ID) AS RANK,*
	FROM PES.DBO.PES_PPMM_PACK  WITH (NOLOCK) 
)P
WHERE RANK=1
GO
