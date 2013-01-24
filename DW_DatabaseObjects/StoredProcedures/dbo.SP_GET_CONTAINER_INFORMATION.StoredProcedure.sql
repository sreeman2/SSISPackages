/****** Object:  StoredProcedure [dbo].[SP_GET_CONTAINER_INFORMATION]    Script Date: 01/08/2013 14:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Cognizant Technology Solutions>
-- Create date: <14th May 2010>
-- Description:	<Fetch the CONTAINER INFORMATION>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_CONTAINER_INFORMATION] 
	-- Add the parameters for the stored procedure here
	@BOL_ID INT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @COUNT INT
	select @COUNT = count(*) from PES_DW_CMD 
	where CMD_DESC='CONTAINER CARGO' AND BOL_ID = @BOL_ID

	IF @COUNT = 1

	select c.CMD_ID, c.CNTR_QUANTITY, c.CNTR_SIZE, c.CNTR_VOL, c.CNTR_FLAG, 
		c.HAZMAT_FLAG, c.RORO_FLAG, c.REEFER_FLAG
	from PES_DW_CMD c join PES_DW_BOL b 
		on b.BOL_ID = c.BOL_ID
	where b.BOL_ID = '" + txtBoxBolId.Text + "'
		and (b.DELETED is null or b.DELETED <> 'Y')
		and c.CMD_DESC = 'CONTAINER CARGO'

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
