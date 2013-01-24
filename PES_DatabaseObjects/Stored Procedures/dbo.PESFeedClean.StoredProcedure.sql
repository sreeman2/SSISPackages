/****** Object:  StoredProcedure [dbo].[PESFeedClean]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Harish Sreekumar
-- Create date: Jul 25 2011
-- Description:	 For cleaning PES Feeds
-- =============================================
CREATE PROCEDURE [dbo].[PESFeedClean](
@InputFileName  varchar (100)
)
AS
BEGIN

select  *  from pes.dbo.pes_progress_status  (nolock) 
Where FILENAME=@InputFileName and FILE_PROCESS_STATUS='Complete'
and HUB_PROCESS_STATUS='complete'
IF (@@ROWCOUNT<>0 )
Begin
	Select 'Warning: ' + @InputFileName  +'This file was processed successfully and This cannot be removed' as Warning
	Return
End
select * FROM screen_test.dbo.FeedLoadPriority 
where FeedFileName=@InputFileName and Status='PickedupbyPES'
IF (@@ROWCOUNT=0 )
Begin
	Select 'Warning: ' + @InputFileName  +'is an invalid file for cleaning' as  Warning
	Return
End

exec PES_LOAD_CLEANUP  @InputFileName

delete from pes.dbo.pes_progress_status where filename=@InputFileName

Delete from PES.DBO.HEP_LOG where FileName=@InputFileName

update a set status = null
FROM screen_test.dbo.FeedLoadPriority  a
where feedfilename = @InputFileName

Select 'Success: ' + @InputFileName  +'is cleaned successfully' as  SuccessMessage
END
GO
