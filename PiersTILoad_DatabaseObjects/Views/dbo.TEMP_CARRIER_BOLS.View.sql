/****** Object:  View [dbo].[TEMP_CARRIER_BOLS]    Script Date: 01/09/2013 18:52:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[TEMP_CARRIER_BOLS]  as 
(select * from   TEMP_CARRIER_BOLS_IMPORT
union 
select * from   TEMP_CARRIER_BOLS_EXPORT)
GO
