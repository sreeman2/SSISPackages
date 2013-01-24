/****** Object:  View [dbo].[v_DQA_ASSIGN_CMPNY_EXCPTN_2]    Script Date: 01/03/2013 19:51:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_DQA_ASSIGN_CMPNY_EXCPTN_2]
AS
SELECT     tlp.BOL_ID, dbl.VDate, dbl.LOAD_NBR, dbl.DAILY_LOAD_DT, dbl.DIR, tlp.SKIPPED
FROM         PES.dbo.PES_TRANSACTIONS_LIB_PTY AS tlp WITH (NOLOCK) INNER JOIN
                      dbo.DQA_BL AS dbl WITH (NOLOCK) ON tlp.BOL_ID = dbl.T_NBR
WHERE     (tlp.Status = 'PENDING') AND (ISNULL(dbl.LOCKED_BY_USR, '') = '') AND (ISNULL(dbl.IS_DELETED, 'N') = 'N')
GO
