/****** Object:  StoredProcedure [dbo].[PES_DROP_INDEX_RAW_BOL_CNTR_CMD_HZMT_MAN_PTY]    Script Date: 01/03/2013 19:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PES_DROP_INDEX_RAW_BOL_CNTR_CMD_HZMT_MAN_PTY]
AS
BEGIN 

	BEGIN TRY
	
		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_BOL]') AND name = N'IX_RAW_BOL_BOL_ID')
			DROP INDEX [IX_RAW_BOL_BOL_ID] ON [dbo].[RAW_BOL] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_CNTR]') AND name = N'IX_RAW_CNTR_BOL_ID')
			DROP INDEX [IX_RAW_CNTR_BOL_ID] ON [dbo].[RAW_CNTR] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_CNTR]') AND name = N'PK_RAW_CNTR1')
			ALTER TABLE [dbo].[RAW_CNTR] DROP CONSTRAINT [PK_RAW_CNTR1]

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_CMD]') AND name = N'_dta_index_RAW_CMD_c_7_1001106657__K2')
			DROP INDEX [_dta_index_RAW_CMD_c_7_1001106657__K2] ON [dbo].[RAW_CMD] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_CMD]') AND name = N'IX_RAW_CMD_BOL_ID')
			DROP INDEX [IX_RAW_CMD_BOL_ID] ON [dbo].[RAW_CMD] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_CMD]') AND name = N'PK_RAW_CMD1')
			ALTER TABLE [dbo].[RAW_CMD] DROP CONSTRAINT [PK_RAW_CMD1]

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_HZMT]') AND name = N'IX_RAW_HZMT_BOL_ID')
			DROP INDEX [IX_RAW_HZMT_BOL_ID] ON [dbo].[RAW_HZMT] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_HZMT]') AND name = N'PK_RAW_HZMT1')
			ALTER TABLE [dbo].[RAW_HZMT] DROP CONSTRAINT [PK_RAW_HZMT1]

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_MAN]') AND name = N'IX_RAW_MAN_BOL_ID')
			DROP INDEX [IX_RAW_MAN_BOL_ID] ON [dbo].[RAW_MAN] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_MAN]') AND name = N'PK_RAW_MAN1')
			ALTER TABLE [dbo].[RAW_MAN] DROP CONSTRAINT [PK_RAW_MAN1]

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_PTY]') AND name = N'_dta_index_RAW_PTY_21_2000062211__K1_K2_K6_7_8_9_10_11')
			DROP INDEX [_dta_index_RAW_PTY_21_2000062211__K1_K2_K6_7_8_9_10_11] ON [dbo].[RAW_PTY] WITH ( ONLINE = OFF )

		IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RAW_PTY]') AND name = N'_dta_index_RAW_PTY_c_13_38291196__K6_K2')
			DROP INDEX [_dta_index_RAW_PTY_c_13_38291196__K6_K2] ON [dbo].[RAW_PTY] WITH ( ONLINE = OFF )

	END TRY
	BEGIN CATCH
    
	END CATCH;
	
END
GO
