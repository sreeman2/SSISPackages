/****** Object:  View [dbo].[pes_dw_mhr_cntr_view]    Script Date: 01/08/2013 15:00:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[pes_dw_mhr_cntr_view] as select b.* from pes_dw_mhr a, pes_raw.pes.dbo.pes_stg_cntr b where a.bol_id = b.bol_id
GO
