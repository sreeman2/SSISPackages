/****** Object:  StoredProcedure [dbo].[sp_Audit_Emails]    Script Date: 01/08/2013 14:51:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Berry, Cathleen>
-- Create date: <11/14/2012>
-- Description:	<Runs Export Audit Records and Emails Results>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Audit_Emails]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	BEGIN
		

			--Email
			DECLARE @NEWLINE char(6)
			SET @NEWLINE = '<br>' + CHAR(10) + CHAR(13)
			DECLARE @EMAILBODY varchar(1000)
			DECLARE @EMAILRECIPIENTS varchar(1000)
			DECLARE @EMAILSUBJECT varchar(1000)
			DECLARE @EMAILSUBJECT2 varchar(1000)
			DECLARE @FILENAME varchar(1000)
			DECLARE @FILENAME2 varchar(1000)
			SELECT @EMAILRECIPIENTS='pwheeler@joc.com;ssaad@joc.com;slogan@joc.com;cberry@joc.com;tmclaughlin@joc.com;'--TOADDRESS FROM pes.dbo.METAMAILADDRESS (NOLOCK)
			SELECT @EMAILBODY=  '
<FONT FACE="Arial" SIZE="2">Dear Audit Team,
<BR><BR>Attached are the export records that should be audited this month.
<BR><BR>Please contact Tim McLaughlin with any questions.
<BR><BR>--The PIERS Team<BR></FONT>'
			SELECT @EMAILSUBJECT = 'ESCAN MONTHLY AUDIT SAMPLES'
			SELECT @EMAILSUBJECT2 = 'DIS MONTHLY AUDIT SAMPLES'
			SELECT @FILENAME = 'ESCANAuditSample'+ convert(varchar(8),getdate(),112) +'.csv'
			SELECT @FILENAME2 = 'DISAuditSample'+ convert(varchar(8),getdate(),112) +'.csv'
			EXEC msdb.dbo.sp_send_dbmail
			@recipients=@EMAILRECIPIENTS,  
			@subject =@EMAILSUBJECT,  
			@body =   @EMAILBODY ,
			@profile_name = 'DBMail Profile',
			@body_format = 'HTML' ,
			@execute_query_database = 'pesdw',
			@attach_query_result_as_file = 1,
			@query_result_width = 10000,
			@query_attachment_filename = @FILENAME,
			@query_result_separator = '|',
			@query = 'SET NOCOUNT ON;

--OBTAIN SAMPLES FROM SPECIFIC FEED TYPES--

declare @size int
declare @month varchar(2)
declare @year varchar(4)
declare @type1 varchar(10)
declare @type2 varchar(10)
declare @dir varchar(1)
declare @pdate DATETIME


--ONLY CHANGE THIS SECTION--
set @size="96" --set sample size here
set @pdate= dateadd(m,-2,(select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH]))
set @month=month(@pdate) --(1 to 2 digits)--
set @year=year(@pdate) --(4 digits)--
set @type1="escan" --first type of feed you want to sample--
set @type2="dis" --second type of feed you want to sample--
set @dir="e" --direction you want to sample--
--END CHANGES--

SET ROWCOUNT @size

SELECT bol.bol_id, bol.bill_number, bol.vdate, bol.vendor_code as Feed_Type,  
p1.piers_name as USPORT, p2.piers_name as FPORT, p3.piers_name as ULTPORT, sline.sline as SLINE, ves.name as Vessel_name,
CMP1.NAME AS COMPANY, cast(CMD_DESC as varchar(30)) as CMD_DESC, JOC_CODE, HSCODE, CMD.QTY, cmd.stnd_weight_kg as KG, cast(CMd.STND_WEIGHT_KG*2.20462 as int) as Pounds, bol.CNTR_FLG as CONFLAG, RORO_FLAG, REEFER_FLAG, HAZMAT_FLAG 
FROM PES_DW_BOL bol (nolock)
join PES_DW_REF_PORT p1 (nolock) on port_depart_ref_id=p1.id
join PES_DW_REF_PORT p2 (nolock) on port_arrive_ref_id=p2.id
join PES_DW_REF_PORT p3 (nolock) on ultport_ref_id=p3.id
join PES_DW_REF_VESSEL ves (nolock) on vessel_ref_id=ves.id
join PES_DW_REF_CARRIER sline (nolock) on sline_ref_id=sline.id
join PES_DW_REF_COMPANY CMP1 (NOLOCK) ON SHIPPER_COMP_REF_ID=CMP1.COMP_ID
JOIN PES_DW_CMD CMD (NOLOCK) ON CMD.cmd_ID=(SELECT TOP 1 CMD_ID FROM pes_dw_cmd (NOLOCK) WHERE BOL_ID=BOL.BOL_ID)
WHERE direction=@dir and vendor_code=@type1
and year(vdate)=@year and month(vdate)=@month
and (ABS(CAST((BINARY_CHECKSUM(*) *RAND()) as int)) % 100) < 5
order by ABS(CAST((BINARY_CHECKSUM(*) *RAND()) as int))'

		

			EXEC msdb.dbo.sp_send_dbmail
			@recipients=@EMAILRECIPIENTS,  
			@subject =@EMAILSUBJECT2,  
			@body =   @EMAILBODY ,
			@profile_name = 'DBMail Profile',
			@body_format = 'HTML' ,
			@execute_query_database = 'pesdw',
			@attach_query_result_as_file = 1,
			@query_result_width = 10000,
			@query_attachment_filename = @FILENAME2,
			@query_result_separator = '|',
			@query = 'SET NOCOUNT ON;

--OBTAIN SAMPLES FROM SPECIFIC FEED TYPES--

declare @size int
declare @month varchar(2)
declare @year varchar(4)
declare @type1 varchar(10)
declare @type2 varchar(10)
declare @dir varchar(1)
declare @pdate DATETIME


--ONLY CHANGE THIS SECTION--
set @size="96" --set sample size here
set @pdate= dateadd(m,-2,(select start_dt from [PES_RAW].[SCREEN_TEST].[dbo].[DQA_PROD_MONTH]))
set @month=month(@pdate) --(1 to 2 digits)--
set @year=year(@pdate) --(4 digits)--
set @type1="escan" --first type of feed you want to sample--
set @type2="dis" --second type of feed you want to sample--
set @dir="e" --direction you want to sample--
--END CHANGES--

SET ROWCOUNT @size

SELECT bol.bol_id, bol.bill_number, bol.vdate, bol.vendor_code as Feed_Type,  
p1.piers_name as USPORT, p2.piers_name as FPORT, p3.piers_name as ULTPORT, sline.sline as SLINE, ves.name as Vessel_name,
CMP1.NAME AS COMPANY, cast(CMD_DESC as varchar(30)) as CMD_DESC, JOC_CODE, HSCODE, CMD.QTY, cmd.stnd_weight_kg as KG, cast(CMd.STND_WEIGHT_KG*2.20462 as int) as Pounds, bol.CNTR_FLG as CONFLAG, RORO_FLAG, REEFER_FLAG, HAZMAT_FLAG 
FROM PES_DW_BOL bol (nolock)
join PES_DW_REF_PORT p1 (nolock) on port_depart_ref_id=p1.id
join PES_DW_REF_PORT p2 (nolock) on port_arrive_ref_id=p2.id
join PES_DW_REF_PORT p3 (nolock) on ultport_ref_id=p3.id
join PES_DW_REF_VESSEL ves (nolock) on vessel_ref_id=ves.id
join PES_DW_REF_CARRIER sline (nolock) on sline_ref_id=sline.id
join PES_DW_REF_COMPANY CMP1 (NOLOCK) ON SHIPPER_COMP_REF_ID=CMP1.COMP_ID
JOIN PES_DW_CMD CMD (NOLOCK) ON CMD.cmd_ID=(SELECT TOP 1 CMD_ID FROM pes_dw_cmd (NOLOCK) WHERE BOL_ID=BOL.BOL_ID)
WHERE direction=@dir and vendor_code=@type2
and year(vdate)=@year and month(vdate)=@month
and (ABS(CAST((BINARY_CHECKSUM(*) *RAND()) as int)) % 100) < 5
order by ABS(CAST((BINARY_CHECKSUM(*) *RAND()) as int))'
			--Email Ends
	END

END
GO
