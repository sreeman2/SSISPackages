/****** Object:  View [dbo].[v_Xecute_SProc_Log]    Script Date: 01/03/2013 19:49:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_Xecute_SProc_Log]
AS
SELECT * FROM dbo.Xecute_SProc_Log
UNION
SELECT * FROM PES_PURGE.dbo.Xecute_SProc_Log_Archive
GO
