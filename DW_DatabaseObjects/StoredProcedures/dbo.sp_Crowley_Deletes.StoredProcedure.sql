/****** Object:  StoredProcedure [dbo].[sp_Crowley_Deletes]    Script Date: 01/08/2013 14:51:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Berry, Cathleen>
-- Create date: <11/14/2012>
-- Description:	<Runs Crowley Deletes File and Emails Results>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Crowley_Deletes]

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
			DECLARE @FILENAME varchar(1000)
			SELECT @EMAILRECIPIENTS='marketing@crowley.com;abourey@joc.com;cberry@joc.com'--TOADDRESS FROM pes.dbo.METAMAILADDRESS (NOLOCK)
			SELECT @EMAILBODY=  '<FONT FACE="Arial" SIZE="2">Dear Crowley Team,<BR><BR> Attached are the record numbers that should be deleted from your system this week.<BR><BR>Please contact us with any questions.<BR><BR>--The PIERS Team<BR></FONT>'
			SELECT @EMAILSUBJECT = 'CROWLEY DELETES'
			SELECT @FILENAME = 'CRLSDeletes'+ convert(varchar(8),getdate(),112) +'.csv'
			EXEC msdb.dbo.sp_send_dbmail
			@recipients=@EMAILRECIPIENTS,  
			@subject =@EMAILSUBJECT,  
			@body =   @EMAILBODY ,
			@profile_name = 'DBMail Profile',
			@body_format = 'HTML' ,
			@execute_query_database = 'pesdw',
			@attach_query_result_as_file = 1,
			@query_attachment_filename = @FILENAME,
			@query_result_separator = '|',
			@query = 'SET NOCOUNT ON;

SELECT
direction AS DIR,
(case left(cmd_id,2) 
when "10" then "A"
when "11" then "B"
when "12" then "C"
when "13" then "D"
when "14" then "E"
END ) + right(cmd_id,7) AS RECNUM, bill_number AS BOL_NBR, vdate AS VDATE, cmd.teu AS TEUS
from PES_DW_BOL dw (nolock)
join PES_DW_CMD cmd (nolock) on dw.bol_id=cmd.bol_id
join PES_DW_REF_PORT port1 (nolock) on dw.port_depart_ref_id=port1.id
join PES_DW_REF_PORT port2 (nolock) on dw.port_arrive_ref_id=port2.id
where year(dw.vdate)="2012" 
AND CMD.MODIFY_DATE>(select max(log_date) from worktemp.dbo.CrowleyDeletesLog)   

and cmd.deleted="Y"
and ( (CTRYCODE between "200" and "399") or (ctrycode in ("911","903")) 
or (port1.code between "20000" and "39999") or (port1.code between "91100" and "91199") or (port1.code between "90300" and "90399")
or (port2.code between "20000" and "39999") or (port2.code between "91100" and "91199")or (port2.code between "90300" and "90399"))
order by direction,vdate'
			--Email Ends
	END

INSERT INTO WorkTemp.dbo.CrowleyDeletesLog ([log_date],[description])
SELECT getdate(), 'Mail titled "' + @EMAILsubject + '" was sent to ' + @EMAILrecipients


END
GO
