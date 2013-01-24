/****** Object:  StoredProcedure [dbo].[SP_UPDATECOMMODITYINFORMATION]    Script Date: 01/08/2013 14:51:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Changes by CTS - 31st March 2010
--UOM needs to be updated in the table, PES_DW_CMD
--UOM should not be updated in the reference table, PES_DW_REF_UOM

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATECOMMODITYINFORMATION] 
	-- Add the parameters for the stored procedure here
    @CMDID INT,
	@QT INT, 
	@WEIGHT INT,
    @DESCI VARCHAR(2000), 
	@HSCOD VARCHAR(50), 
	@JOCCODE CHAR(7), 
	@UOM VARCHAR(50),
	@MODIFY_BY VARCHAR(255)	
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
		MODIFY_BY = @MODIFY_BY, 
		MODIFY_DATE = GETDATE()
	WHERE CMD_ID = @CMDID; 

	UPDATE PES_DW_BOL WITH (UPDLOCK)
	SET
		WEIGHT = ROUND((SELECT SUM(ISNULL(C.STND_WEIGHT_KG,0)) 
					FROM PES_DW_CMD C WITH (NOLOCK), PES_DW_BOL B WITH (NOLOCK)
					WHERE C.BOL_ID = @BOL_ID
						AND C.BOL_ID = B.BOL_ID 
						AND C.DELETED IS NULL
					GROUP BY C.BOL_ID)*2.204622476,0),
		NTERP_STD_WGT = (SELECT SUM(ISNULL(C.STND_WEIGHT_KG,0)) 
					FROM PES_DW_CMD C WITH (NOLOCK), PES_DW_BOL B WITH (NOLOCK) 
					WHERE C.BOL_ID = @BOL_ID
						AND C.BOL_ID = B.BOL_ID 
						AND C.DELETED IS NULL
					GROUP BY C.BOL_ID),
		MODIFY_DATE = GETDATE()
	WHERE BOL_ID = @BOL_ID




--  UPDATE PES_DW_REF_UOM  SET 
--  UM = @UOM
--  WHERE ID = (SELECT QTY_UNIT_REF_ID FROM PES_DW_CMD WHERE CMD_ID = @CMDID);   

-- [aa] - 11/28/2010
-- Log end time
EXEC PES_RAW.SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END;
GO
