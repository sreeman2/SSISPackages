/****** Object:  StoredProcedure [dbo].[spTraceDataBaseProceduresAndTSQLTransactions]    Script Date: 01/03/2013 19:48:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		UBMGT
-- Create date: 07/21/2011
-- Description:	Trace database procedure and T-SQL transactions
-- =============================================
CREATE PROCEDURE [dbo].[spTraceDataBaseProceduresAndTSQLTransactions]
	@minutes int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Create a Queue
	declare @rc int
	declare @TraceID int
	declare @maxfilesize bigint
	DECLARE @EndTime datetime
	DECLARE @OutputFileName nvarchar(256)

	SET @MaxFileSize = 100 
	SET @OutputFileName = 'G:\Trace\PESWinPerformanceTrace' 
						+ CONVERT(VARCHAR(20), GETDATE(),112)
						+ REPLACE(CONVERT(VARCHAR(20), GETDATE(),108),':','')
	SET @EndTime = DATEADD(mi,@minutes,getdate())

	EXEC @rc = sp_trace_create @TraceID output, 0, @OutputFileName, @MaxFileSize, @EndTime

	-- Set the events
	declare @on bit
	set @on = 1
	exec sp_trace_setevent @TraceID, 10, 7, @on
	exec sp_trace_setevent @TraceID, 10, 15, @on
	exec sp_trace_setevent @TraceID, 10, 31, @on
	exec sp_trace_setevent @TraceID, 10, 8, @on
	exec sp_trace_setevent @TraceID, 10, 16, @on
	exec sp_trace_setevent @TraceID, 10, 48, @on
	exec sp_trace_setevent @TraceID, 10, 64, @on
	exec sp_trace_setevent @TraceID, 10, 1, @on
	exec sp_trace_setevent @TraceID, 10, 9, @on
	exec sp_trace_setevent @TraceID, 10, 17, @on
	exec sp_trace_setevent @TraceID, 10, 41, @on
	exec sp_trace_setevent @TraceID, 10, 49, @on
	exec sp_trace_setevent @TraceID, 10, 2, @on
	exec sp_trace_setevent @TraceID, 10, 10, @on
	exec sp_trace_setevent @TraceID, 10, 18, @on
	exec sp_trace_setevent @TraceID, 10, 26, @on
	exec sp_trace_setevent @TraceID, 10, 34, @on
	exec sp_trace_setevent @TraceID, 10, 50, @on
	exec sp_trace_setevent @TraceID, 10, 3, @on
	exec sp_trace_setevent @TraceID, 10, 11, @on
	exec sp_trace_setevent @TraceID, 10, 35, @on
	exec sp_trace_setevent @TraceID, 10, 51, @on
	exec sp_trace_setevent @TraceID, 10, 4, @on
	exec sp_trace_setevent @TraceID, 10, 12, @on
	exec sp_trace_setevent @TraceID, 10, 60, @on
	exec sp_trace_setevent @TraceID, 10, 13, @on
	exec sp_trace_setevent @TraceID, 10, 6, @on
	exec sp_trace_setevent @TraceID, 10, 14, @on
	exec sp_trace_setevent @TraceID, 12, 7, @on
	exec sp_trace_setevent @TraceID, 12, 15, @on
	exec sp_trace_setevent @TraceID, 12, 31, @on
	exec sp_trace_setevent @TraceID, 12, 8, @on
	exec sp_trace_setevent @TraceID, 12, 16, @on
	exec sp_trace_setevent @TraceID, 12, 48, @on
	exec sp_trace_setevent @TraceID, 12, 64, @on
	exec sp_trace_setevent @TraceID, 12, 1, @on
	exec sp_trace_setevent @TraceID, 12, 9, @on
	exec sp_trace_setevent @TraceID, 12, 17, @on
	exec sp_trace_setevent @TraceID, 12, 41, @on
	exec sp_trace_setevent @TraceID, 12, 49, @on
	exec sp_trace_setevent @TraceID, 12, 6, @on
	exec sp_trace_setevent @TraceID, 12, 10, @on
	exec sp_trace_setevent @TraceID, 12, 14, @on
	exec sp_trace_setevent @TraceID, 12, 18, @on
	exec sp_trace_setevent @TraceID, 12, 26, @on
	exec sp_trace_setevent @TraceID, 12, 50, @on
	exec sp_trace_setevent @TraceID, 12, 3, @on
	exec sp_trace_setevent @TraceID, 12, 11, @on
	exec sp_trace_setevent @TraceID, 12, 35, @on
	exec sp_trace_setevent @TraceID, 12, 51, @on
	exec sp_trace_setevent @TraceID, 12, 4, @on
	exec sp_trace_setevent @TraceID, 12, 12, @on
	exec sp_trace_setevent @TraceID, 12, 60, @on
	exec sp_trace_setevent @TraceID, 12, 13, @on


	exec sp_trace_setstatus @TraceID, 1

END
GO
