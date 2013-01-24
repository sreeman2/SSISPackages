/****** Object:  View [dbo].[vwMES_MMS_RAW_PTY]    Script Date: 01/03/2013 19:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwMES_MMS_RAW_PTY] AS
SELECT MINRAWPTYID
      ,[RAW_PTY_ID]
      ,[BOL_ID]
      ,[BOL_Number]
      ,[Pty_seq_nbr]
      ,[Load_Number]
FROM
(
	SELECT MIN(P.[RAW_PTY_ID]) OVER (PARTITION BY P.BOL_ID, P.LOAD_NUMBER) MINRAWPTYID
		  ,P.[RAW_PTY_ID]
		  ,P.[BOL_ID]
		  ,P.[BOL_Number]
		  ,P.[Pty_seq_nbr]
		  ,P.[Load_Number]
	FROM [PES].[dbo].[RAW_PTY] P 
	   INNER JOIN [PES].[dbo].[RAW_BOL] B ON P.BOL_ID = B.BOL_ID 
											 AND P.LOAD_NUMBER = B.LOAD_NUMBER
	WHERE B.VENDOR_CODE IN ('MES', 'MMS')
) PTY
GO
