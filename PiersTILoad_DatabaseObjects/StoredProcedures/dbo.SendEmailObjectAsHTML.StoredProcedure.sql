/****** Object:  StoredProcedure [dbo].[SendEmailObjectAsHTML]    Script Date: 01/09/2013 18:40:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Object:			StoredProcedure [dbo].[SendEmailObjectAsHTML]    
-- Created Date:	Oct-12-2011
-- Author:			Harish Sreekumar
-- Description:		This SP can accept SQL objects like Table or View and can convert them to HTML
--					and embed it in email.
-- NOTES:			NONE
-- ============================================================================

CREATE proc [dbo].[SendEmailObjectAsHTML]
    @source_db    sysname,       --  Where the @object_name is resident
    @schema       sysname,       --  Schema name eg.. dbo.
    @object_name  sysname,       --  Table or view to email
    @order_clause nvarchar(max), --  The order by clause eg. x, y, z
    @email        nvarchar(max),  --  Email recipient list
    @subject	  nvarchar(max),
    @profile_name varchar(1000),
    @textBeforeObject varchar(1000),
    @textAfterObject varchar(1000)
as
begin
 
    declare @body    nvarchar(max)
 
    --  Get columns for table headers..
    exec( '
    declare col_cur cursor for
        select name
        from ' + @source_db + '.sys.columns
        where object_id = object_id( ''' + @source_db + '.' + @schema + '.' + @object_name + ''')
        order by column_id
        ' )
 
    open col_cur
 
    declare @col_name sysname
    declare @col_list nvarchar(max)
 
    fetch next from col_cur into @col_name
 
    set @body = N'<table border=1 cellpadding=1 cellspacing=1 style=border-style: solid ><tr>'
 
    while @@fetch_status = 0
    begin
        set @body = cast( @body as nvarchar(max) )
                  + N'<th>' + @col_name + '</th>'
 
        set @col_list = coalesce( @col_list + ',', '' ) + ' td = ' + cast( @col_name as nvarchar(max) ) + ', '''''
 
        fetch next from col_cur into @col_name
 
    end
 
    deallocate col_cur
 
    set @body = cast( @body as nvarchar(max) )
              + '</tr>'
 
    declare @query_result nvarchar(max)
    declare @nsql nvarchar(max)
 
    --  Form the query, use XML PATH to get the HTML
    set @nsql = '
        select @qr =
               cast( ( select ' + cast( @col_list as nvarchar(max) )+ '
                       from ' + @source_db + '.' + @schema + '.' + @object_name + '
                       order by ' + @order_clause + '
                       for xml path( ''tr'' ), type
                       ) as nvarchar(max) )'
 
    exec sp_executesql @nsql, N'@qr nvarchar(max) output', @query_result output
 
    set @body = cast( @body as nvarchar(max) )
              + @query_result
 
    --  Send notification
    set @subject = @subject
 
    set @body = @body + cast( '</table>' as nvarchar(max) )
 
    set @body ='<FONT FACE="Arial" SIZE="2">' + @textBeforeObject  + cast( @body as nvarchar(max) ) + @textAfterObject + '</FONT>'
 
    EXEC msdb.dbo.sp_send_dbmail  @profile_name = @profile_name,
                                  @recipients = @email,
                                  @body = @body,
                                  @body_format = 'HTML',
                                  @subject = @subject
 
end
GO
