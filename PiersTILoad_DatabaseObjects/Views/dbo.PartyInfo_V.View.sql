/****** Object:  View [dbo].[PartyInfo_V]    Script Date: 01/09/2013 18:52:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PartyInfo_V] AS
(
	SELECT  raw_pty.BOL_ID,
			raw_pty.SOURCE,
			raw_pty.PTY_SEQ_NBR,
			stg_pty.ID
	FROM dbo.raw_pty (NOLOCK)
	LEFT OUTER JOIN dbo.stg_pty (NOLOCK)  ON
	 COALESCE(raw_pty.NAME,'NullValue') = COALESCE(stg_pty.name,'NullValue')
	 AND COALESCE(raw_pty.ADDR_1,'NullValue') = COALESCE(stg_pty.addr1,'NullValue')
	 AND COALESCE(raw_pty.ADDR_2,'NullValue') = COALESCE(stg_pty.addr2,'NullValue')
	 AND COALESCE(raw_pty.ADDR_3,'NullValue') = COALESCE(stg_pty.addr3,'NullValue')
	 AND COALESCE(raw_pty.ADDR_4,'NullValue') = COALESCE(stg_pty.addr4,'NullValue')
)
GO
