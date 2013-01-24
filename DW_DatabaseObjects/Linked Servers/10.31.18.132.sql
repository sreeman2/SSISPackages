/****** Object:  LinkedServer [10.31.18.132]    Script Date: 01/08/2013 15:06:06 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'10.31.18.132', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'10.31.18.132',@useself=N'False',@locallogin=NULL,@rmtuser=N'appuser',@rmtpassword='########'

GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'collation compatible', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'data access', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'dist', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'pub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'rpc', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'rpc out', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'sub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'connect timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'collation name', @optvalue=null
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'lazy schema validation', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'query timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'10.31.18.132', @optname=N'use remote collation', @optvalue=N'true'