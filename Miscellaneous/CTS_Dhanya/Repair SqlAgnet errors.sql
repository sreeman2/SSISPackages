--To Repair Errors causing by Sql Agent
--turn msdb to single user model.
--and run 

DBCC CHECKDB ('msdb', Repair_ALL) 


