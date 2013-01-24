/****** Object:  View [dbo].[V_PES_REF_COMPANY_VDate_BOL24]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_PES_REF_COMPANY_VDate_BOL24]
AS
SELECT     cid, COUNT(DISTINCT bol_id) AS NumberOfShipments
FROM         dbo.[V_PES_REF_COMPANY_VDate_BOL]
WHERE     (vdate > DATEADD(MONTH,-24,GETDATE()))
GROUP BY cid
GO
