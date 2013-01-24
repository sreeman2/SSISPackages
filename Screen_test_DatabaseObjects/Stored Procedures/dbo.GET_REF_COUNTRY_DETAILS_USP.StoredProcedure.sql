/****** Object:  StoredProcedure [dbo].[GET_REF_COUNTRY_DETAILS_USP]    Script Date: 01/03/2013 19:47:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GET_REF_COUNTRY_DETAILS_USP]
	@COUNTRY		AS VARCHAR(255)	,
	@JOC_CODE		AS NUMERIC(12,0)= 0	,
	@IS_CNTRY_CODE	AS BIT
AS
BEGIN
SET NOCOUNT ON;

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


IF ( @IS_CNTRY_CODE = 1 )
BEGIN
	SELECT	Piers_country, 
			JOC_CODE as country_id 
	FROM PES.dbo.REF_COUNTRY WITH (NOLOCK) 
	WHERE ( JOC_CODE = @JOC_CODE ) --OR PIERS_COUNTRY = @JOC_CODE )
END
ELSE
BEGIN
	SELECT	Piers_country, 
			JOC_CODE as country_id 
	FROM PES.dbo.REF_COUNTRY WITH (NOLOCK) 
	WHERE ( COUNTRY = @COUNTRY OR PIERS_COUNTRY = @COUNTRY )
END

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
