/****** Object:  UserDefinedFunction [dbo].[pes_udf_GetContainerCountforLC]    Script Date: 01/03/2013 19:42:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Cognizant, Bangalore
-- Create date: 23-March-2009
-- Description:	Container Count for LC Logic
-- =============================================
CREATE FUNCTION [dbo].[pes_udf_GetContainerCountforLC]
(
	@BOL_ID INT,
	@CNTR_NBR VARCHAR (14),
	@VOYAGE_ID INT,
	@BOL_CNTRZD_FLG CHAR(1)
)
RETURNS INT
AS
BEGIN
	DECLARE @CNTR_MOVEMENT_CNT INT

	if @BOL_CNTRZD_FLG = 'Y'
	BEGIN
		IF @CNTR_NBR LIKE '*#*%'
			SET @CNTR_MOVEMENT_CNT=1 -- cntrnbr is Blank, movement cannot be determined, assume	1		
		ELSE IF (@CNTR_NBR IS NULL OR LTRIM(RTRIM(@CNTR_NBR))='') 
			SET @CNTR_MOVEMENT_CNT=1		
		ELSE 
		BEGIN
			SET @CNTR_MOVEMENT_CNT=(
					SELECT COUNT(DISTINCT isnull(A.BOL_ID,0)) 
					FROM PES_STG_CNTR A WITH (NOLOCK) JOIN PES_STG_BOL B WITH (NOLOCK)
					ON A.BOL_ID=B.BOL_ID 
					WHERE A.CNTR_NBR=@CNTR_NBR 
					AND B.STND_VOYG_ID=@VOYAGE_ID 
					AND B.BOL_STATUS<>'MASTER' 
					AND (B.MST_BOL_TYPE<>'M' OR LTRIM(RTRIM(ISNULL(B.MST_BOL_TYPE,'')))=''))		

			  IF @CNTR_MOVEMENT_CNT=0 OR @CNTR_MOVEMENT_CNT IS NULL 
					SET @CNTR_MOVEMENT_CNT=1	
		END		
	END
	ELSE
		SELECT @CNTR_MOVEMENT_CNT=0	
		
	-- Return the result of the function
	RETURN @CNTR_MOVEMENT_CNT

END
GO
