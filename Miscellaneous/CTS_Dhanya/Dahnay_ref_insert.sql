begin tran
SET IDENTITY_INSERT [GTCore_MasterData].[dbo].[REF_CARRIER] ON
select max(id)+1 from [GTCore_MasterData].[dbo].[REF_CARRIER] (nolock)
INSERT INTO [GTCore_MasterData].[dbo].[REF_CARRIER]
           ([ID]
            ,[TYPE]
           ,[CODE]
           ,[NAME]
           ,[ACTIVE]
           ,[IS_NVO]
           ,[DELETED]
           ,[IS_TMP]
           ,[MODIFIED_DT]
           ,[MODIFIED_BY]
           ,[CARRIER_DESC])
     VALUES
           (20882
		   ,'DLPD'
           ,'DLPD'
           , NULL
           ,'Y'
           ,'Y'
           ,'N'
           ,'N'
           ,GETDATE()
           ,'DBO'
           ,'DAHNAY LOGISTICS')


commit tran






