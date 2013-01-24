/****** Object:  View [dbo].[tiref_ppmm_ports_view]    Script Date: 01/09/2013 18:52:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[tiref_ppmm_ports_view] 
AS
 SELECT CAST(PORT_NAME AS VARCHAR(25)) AS PORT_NAME
,CAST(PORT AS VARCHAR(25)) AS PORT
,CAST(COUNTRY AS VARCHAR(7)) AS COUNTRY
,CAST(JOC_CODE AS VARCHAR(5)) AS JOC_CODE
 FROM dbo.tiref_ppmm_ports
GO
