/****** Object:  StoredProcedure [dbo].[PES_VIN_INSERT_GOOD_VIN]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CTS>
-- Create date: <4TH AUGUST 2009>
-- Description:	<Inserting all the GOOD VINs>
-- =============================================
CREATE PROCEDURE [dbo].[PES_VIN_INSERT_GOOD_VIN]
	-- Add the parameters for the stored procedure here
	@BLnbr varchar(max),
	@strVIN varchar(max),
	@Tnbr varchar(max),
	@MANSEQnbr varchar(max),
	@CMDSEQnbr varchar(max),
	@LOADnbr varchar(max),
	@RUNSEQnbr varchar(max),
	@MAN_ID INT,
	@RETURN_VALUE INT OUT
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

declare @rec_cnt int
select @rec_cnt=count(*) from pes.dbo.pes_stg_vin  WITH (NOLOCK) 
	where bl_nbr = @BLnbr and
	vin=@strVIN and 
	t_nbr=@Tnbr

if @rec_cnt = 0
	BEGIN
		insert into pes.dbo.PES_STG_VIN
			(bl_nbr,
			vin,
			t_nbr,
			man_seq_nbr,
			cmd_seq_nbr,
			db_load_nbr,
			run_seq_nbr,
			insert_dt,
			MAN_ID)
		values 
			(@BLnbr,
			@strVIN,
			@Tnbr,
			@MANSEQnbr,
			@CMDSEQnbr,
			@LOADnbr,
			@RUNSEQnbr,
			getdate(),
			@MAN_ID)
		
		SET @RETURN_VALUE = 0
	END
ELSE
	BEGIN
		SET @RETURN_VALUE = 1
	END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
