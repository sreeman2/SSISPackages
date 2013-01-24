/****** Object:  StoredProcedure [dbo].[PES_VIN_GET_TNBRs]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <5TH AUGUST 2009>
-- Modified Date : <12th NOVEMBER 2009>
-- Description:	<Retreiving the T_NBRs for VIN Extraction>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_GET_TNBRs]
	-- Add the parameters for the stored procedure here
	@strLoadNbr varchar(max)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	declare @iLoadNumber int
	select @iLoadNumber = convert(int,@strLoadNbr)

	SELECT b.bol_id,b.bol_number,b.load_number,
		convert(varchar(max),c.SequenceNo) seq_nbr,'C' type,c.Commodity_Desc workstring,
		c.cmd_id ID
	FROM pes.dbo.archive_raw_bol b  WITH (NOLOCK) , pes.dbo.archive_raw_cmd c  WITH (NOLOCK) 
	where b.load_number=@iLoadNumber
	and b.bol_id=c.bol_id
	union all
	SELECT b.bol_id,b.bol_number,b.load_number,
	--m.cntr_nbr seq_nbr,
	(
		select sm.man_seq_nbr 
		from  pes_stg_man sm  WITH (NOLOCK) 
		where m.man_id = sm.man_id and m.bol_id= sm.bol_id
	) as seq_nbr,
	'M' type,
	m.man_desc workstring,
	m.man_id ID
	FROM pes.dbo.archive_raw_bol b  WITH (NOLOCK) join pes.dbo.archive_raw_man m  WITH (NOLOCK) 
	on b.bol_id=m.bol_id
	where b.load_number=@iLoadNumber
	order by bol_id,type,seq_nbr

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
