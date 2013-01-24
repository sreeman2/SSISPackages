/****** Object:  View [dbo].[vwREF_CMMCST]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwREF_CMMCST] AS
SELECT [MODIFIED_BY]
      ,[MODIFIED_DT]
      ,[DELETED]
      ,[ID]
      ,[FILE_ID]
      ,[COMP_NAME]
      ,[RECORD_FLAG]
      ,[FULL_NAME]
      ,[LAST_DATE]
      ,[HIT_COUNT]
      ,[TSUSA]
  FROM [GTCore_MasterData].[dbo].[REF_CMMCST] (NOLOCK)
GO
