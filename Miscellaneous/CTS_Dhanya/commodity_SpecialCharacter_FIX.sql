
--after finding the Commodity description which has the special character, use the below query to check

Select top 10 * From SCREEN_TEST.dbo.DQA_CMDS (nolock) where t_nbr=258385811

--Update screen_test.dbo.dqa_cmds set DQA_DESC= 'COLOR PDP LCD TV PARTS E' where t_nbr=258385811
-- next , update wit the below query  removing the special charater.
--update dbo.DQA_CMDS set DQA_DESC='TOOL BOX E' 

--Select * From dbo.DQA_CMDS set DQA_DESC='TOOL BOX E' 
where t_nbr=242131384

Select * from PES.dbo.PES_PROCESS_STATUS
---update PES.dbo.PES_PROCESS_STATUS set status='READY' where Status='INPROGRESS'

Select top 10 * from dbo.CTRL_PROCESS_VOYAGE With (nolock) where T_NBR=248601357

Select top 100 * from PEs.dbo.PES_STG_BOL_DQA with (NOLOCK) where BOL_ID=248601357
exec PES.dbo.PESFeedClean 'MES120416.DAT'