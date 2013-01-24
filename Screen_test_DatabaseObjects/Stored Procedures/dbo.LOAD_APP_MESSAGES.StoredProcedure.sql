/****** Object:  StoredProcedure [dbo].[LOAD_APP_MESSAGES]    Script Date: 01/03/2013 19:47:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LOAD_APP_MESSAGES]
AS
BEGIN
SET NOCOUNT ON;

SELECT [MessageNumber]
      ,[MessageTitle]
      ,[MessageDescription]
      ,[MessageType]
      ,[Priority]
      ,[Severity]
      ,[Required]
      ,[CreatedBy]
      ,[CreatedDate]
  FROM [dbo].[PES_APP_MESSAGES]

END
GO
