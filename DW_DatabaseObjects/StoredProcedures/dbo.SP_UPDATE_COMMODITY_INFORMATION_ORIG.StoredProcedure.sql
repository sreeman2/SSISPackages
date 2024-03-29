/****** Object:  StoredProcedure [dbo].[SP_UPDATE_COMMODITY_INFORMATION_ORIG]    Script Date: 01/08/2013 14:51:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATE_COMMODITY_INFORMATION_ORIG] 
	-- Add the parameters for the stored procedure here
    @CMDID INT,
	@QT INT, 
	@WEIGHT INT,
    @DESCI VARCHAR(2000), 
	@HSCOD VARCHAR(50), 
	@JOCCODE CHAR(7), 
	@UOM VARCHAR(50),
    @CNTRQTY VARCHAR(50),
    @CNTRVOL VARCHAR(50),
    @CNTRSIZE VARCHAR(50),
    @CNTRFLAG VARCHAR(50),
	@MODIFY_BY VARCHAR(255),
	@DELETED varchar(1)
AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

	DECLARE @WEIGHT_IN_POUNDS INT
	DECLARE @BOL_ID INT

	SELECT @BOL_ID = BOL_ID FROM PES_DW_CMD WHERE CMD_ID = @CMDID
	SET @WEIGHT_IN_POUNDS = ROUND(@WEIGHT*2.204622476,0)

	UPDATE PES_DW_CMD WITH (UPDLOCK)
	SET 
		CMD_DESC = @DESCI, 
		JOC_CODE = @JOCCODE, 
		HSCODE = @HSCOD, 
		QTY = @QT, 
		STND_WEIGHT_KG = @WEIGHT,
		QTY_UNIT_REF_ID = (SELECT ID FROM PES_DW_REF_UOM WHERE UM = @UOM),
		CNTR_QUANTITY = @CNTRQTY,
		CNTR_VOL = @CNTRVOL,
		CNTR_SIZE = @CNTRSIZE,
		CNTR_FLAG = @CNTRFLAG,
		MODIFY_BY = @MODIFY_BY, 
		MODIFY_DATE = GETDATE(),
		DELETED = @DELETED
	WHERE CMD_ID = @CMDID; 

	UPDATE PES_DW_BOL WITH (UPDLOCK)
	SET
		WEIGHT = COALESCE(ROUND((SELECT SUM(ISNULL(C.STND_WEIGHT_KG,0)) 
					FROM PES_DW_CMD C WITH (NOLOCK), PES_DW_BOL B WITH (NOLOCK)
					WHERE C.BOL_ID = @BOL_ID
						AND C.BOL_ID = B.BOL_ID 
						AND C.DELETED IS NULL
					GROUP BY C.BOL_ID)*2.204622476,0),0),
		NTERP_STD_WGT = COALESCE((SELECT SUM(ISNULL(C.STND_WEIGHT_KG,0)) 
					FROM PES_DW_CMD C WITH (NOLOCK), PES_DW_BOL B WITH (NOLOCK) 
					WHERE C.BOL_ID = @BOL_ID
						AND C.BOL_ID = B.BOL_ID 
						AND C.DELETED IS NULL
					GROUP BY C.BOL_ID),0),
		MODIFY_DATE = GETDATE()
	WHERE BOL_ID = @BOL_ID


-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
