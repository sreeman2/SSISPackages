/****** Object:  View [dbo].[TEMP_COMMODITY_BOLS_V]    Script Date: 01/09/2013 18:52:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[TEMP_COMMODITY_BOLS_V] as (select * from  TEMP_COMMODITY_BOLS_IMPORT
union 
select * from  TEMP_COMMODITY_BOLS_EXPORT)
GO
