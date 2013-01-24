/****** Object:  View [dbo].[vwREF_HARMCMST]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwREF_HARMCMST] AS
SELECT [ID]
      ,[FILE_ID]
      ,[COMP_NAME]
      ,[RECORD_FLAG]
      ,[FULL_NAME]
      ,[HARMCODE]
      ,[LAST_DATE]
      ,[HIT_COUNT]
      ,[MODIFIED_BY]
      ,[MODIFIED_DT]
      ,[DELETED]
  FROM [GTCore_MasterData].[dbo].[REF_HARMCMST] (NOLOCK)
GO
