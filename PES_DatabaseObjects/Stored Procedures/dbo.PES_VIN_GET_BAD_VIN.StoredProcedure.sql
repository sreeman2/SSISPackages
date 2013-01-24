/****** Object:  StoredProcedure [dbo].[PES_VIN_GET_BAD_VIN]    Script Date: 01/03/2013 19:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <6TH AUGUST 2009>
-- Description:	<Retreiving top 100 rows for exception correction>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_GET_BAD_VIN]
	-- Add the parameters for the stored procedure here
	@OUT_VIN_EXCP_CNT INT OUTPUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @VIN_EXCP_CNT INT
	SELECT @VIN_EXCP_CNT=COUNT(*) FROM SCREEN_TEST.DBO.VIN_CACHE  WITH (NOLOCK)  WHERE STATUS IS NULL

	IF @VIN_EXCP_CNT > 0
	BEGIN
		select top 100 ROW_NUMBER() OVER (ORDER BY vc.t_nbr) As SNo,' ' as action,
		case when vc.man_seq_nbr!=0 
				then 'M'+STR(man_seq_nbr) 
				else 'C'+STR(cmd_seq_nbr) 
		end as source_t,
		case when vc.man_seq_nbr!=0 
			then (SELECT psm.MAN_DESC from PES_STG_MAN psm  WITH (NOLOCK) 
					where psm.bol_id=vc.t_nbr and psm.man_seq_nbr=vc.man_seq_nbr)
			else (SELECT psc.CMD_DESC from PES_STG_CMD psc  WITH (NOLOCK) 
					WHERE psc.bol_id=vc.t_nbr and psc.cmd_seq_nbr=vc.cmd_seq_nbr) 
		end as text,
		vc.ID,
		(select filename from PES_Progress_status pps  WITH (NOLOCK)  where pps.loadnumber = vc.db_load_nbr) 
			as filename,
		VIN AS VIN,
		BL_NBR as BL_NBR,
		T_NBR as T_NBR,
		INSERT_DT as EXTRACTED,
		cmd_man_desc as CMD_MAN_DESC
		from SCREEN_TEST.DBO.VIN_CACHE vc  WITH (NOLOCK) 
		where status is null

		SET @OUT_VIN_EXCP_CNT=@VIN_EXCP_CNT
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
