USE [SCREEN_TEST]
GO
/****** Object:  View [dbo].[_dta_mv_2]    Script Date: 01/03/2013 19:49:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[_dta_mv_2]  
 AS 
SELECT  [dbo].[DQA_VOYAGE].[VOYAGE_STATUS] as _col_1,  [dbo].[BL_BL].[T_NBR] as _col_2,  [dbo].[BL_BL].[DQA_VOYAGE_ID] as _col_3,  [dbo].[BL_BL].[BOL_STATUS] as _col_4,  [dbo].[DQA_VOYAGE].[VOYAGE_ID] as _col_5 FROM  [dbo].[BL_BL],  [dbo].[DQA_VOYAGE]   WHERE  [dbo].[BL_BL].[DQA_VOYAGE_ID] = [dbo].[DQA_VOYAGE].[VOYAGE_ID]
GO
