/****** Object:  View [dbo].[V_PES_REF_COMPANY_VDateMax]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_PES_REF_COMPANY_VDateMax]
AS
SELECT     cid, MAX(vdate) AS vdate
FROM         dbo.[V_PES_REF_COMPANY_VDate]
GROUP BY cid
GO
