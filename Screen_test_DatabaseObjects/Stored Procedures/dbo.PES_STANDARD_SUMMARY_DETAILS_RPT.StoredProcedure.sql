/****** Object:  StoredProcedure [dbo].[PES_STANDARD_SUMMARY_DETAILS_RPT]    Script Date: 01/03/2013 19:48:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PES_STANDARD_SUMMARY_DETAILS_RPT]
	@FROM_DATE	DATETIME	,
	@TO_DATE	DATETIME	,
	@DIR		VARCHAR(1)	,
	@VENDOR_GRP	XML =  NULL,
	@PES_USERS	VARCHAR(MAX) =  NULL,
	@RPT_OWNER_ID VARCHAR(10)= NULL	
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


DECLARE @USERXML XML
DECLARE @TOTAL_BILLS_DELETED INT
DECLARE @QC_BILL_DELETED INT
DECLARE @CMPNY_BILL_DELETED INT
DECLARE @SUMMARY_DATA_TBL TABLE(DELETED_BILL INT, EXCEPTION_TYPE VARCHAR(100))

IF ( @PES_USERS IS NOT NULL  )
BEGIN    
	SELECT @USERXML = DBO.XMLOFUSERS(@PES_USERS)
END

IF ( @VENDOR_GRP IS NOT NULL )
BEGIN
		INSERT INTO @SUMMARY_DATA_TBL
		SELECT COUNT(alog.BILL_DELETED) , alog.EXCEPTION_TYPE
		FROM  dbo.[PES_AUDIT_LOGS] alog WITH (NOLOCK) JOIN dbo.[DQA_BL] bl WITH (NOLOCK) ON ( alog.T_NBR = bl.T_NBR )
		WHERE ( MODIFY_DATE BETWEEN @FROM_DATE AND @TO_DATE )
		AND (bl.DIR = @DIR )
		AND (alog.BILL_DELETED = 1)
		AND 
		( 
			alog.MODIFY_BY IN 
			( 
				SELECT usr.[USER_NAME] 
				FROM dbo.[PEA_USER_VENDOR_GRP] AS uvg WITH (NOLOCK) JOIN  dbo.[PEA_VENDOR_GROUP] AS vg WITH (NOLOCK)			
				ON ( vg.VendorGroupId = uvg.VendorGroupId ) JOIN dbo.[PEA_USER] AS usr ON usr.[USER_ID] = uvg.[USERID]
				WHERE 
				( 
					vg.VendorGroupName IN ( 
						SELECT Vendor.Groups.value('.', 'VARCHAR(100)') 
						FROM @VENDOR_GRP.nodes('//Groups') AS Vendor(Groups)  
					) 
				)				
			)
		)
		GROUP BY alog.EXCEPTION_TYPE

		
END
ELSE
BEGIN
		INSERT INTO @SUMMARY_DATA_TBL
		SELECT COUNT(alog.BILL_DELETED) , alog.EXCEPTION_TYPE
		FROM  dbo.[PES_AUDIT_LOGS] alog WITH (NOLOCK) JOIN dbo.[DQA_BL] bl WITH (NOLOCK) ON ( alog.T_NBR = bl.T_NBR )
		WHERE ( MODIFY_DATE BETWEEN @FROM_DATE AND @TO_DATE )
		AND (bl.DIR = @DIR )
		AND (alog.BILL_DELETED = 1)
		AND ( alog.MODIFY_BY IN(SELECT X.I.value('.', 'VARCHAR(50)') FROM @USERXML.nodes('//I') AS X(I)) )	
		GROUP BY alog.EXCEPTION_TYPE
END

SELECT  @CMPNY_BILL_DELETED = SUM(DELETED_BILL) FROM @SUMMARY_DATA_TBL 
WHERE EXCEPTION_TYPE = 'COMPANY EXCEPTIONS'

SELECT  @QC_BILL_DELETED = SUM(DELETED_BILL) FROM @SUMMARY_DATA_TBL 
WHERE EXCEPTION_TYPE NOT IN ('COMPANY EXCEPTIONS')

SELECT  @TOTAL_BILLS_DELETED = @CMPNY_BILL_DELETED + @QC_BILL_DELETED


SELECT	@CMPNY_BILL_DELETED 'COMPANY_EXP_DELETED', 
		@QC_BILL_DELETED AS 'QC_EXP_DELETED',
		@TOTAL_BILLS_DELETED AS 'TOTAL_DELETED'

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
