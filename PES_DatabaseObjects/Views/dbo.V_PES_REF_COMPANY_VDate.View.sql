/****** Object:  View [dbo].[V_PES_REF_COMPANY_VDate]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_PES_REF_COMPANY_VDate]
AS
select COMP_ID as cid, vdate from dbo.PES_STG_BOL
union all
select FCOMP_ID as cid, vdate from dbo.PES_STG_BOL
union all
select NTFCOMP_ID as cid, vdate from dbo.PES_STG_BOL
GO
