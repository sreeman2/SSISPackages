/****** Object:  StoredProcedure [dbo].[CHANGE_DEL_STATUS_REF_HARMCODES]    Script Date: 01/03/2013 19:47:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Nandini>
-- Create date: <10th april 2009>
-- Description:	<procedure to DELETE custom harm codes>
-- =============================================
CREATE PROCEDURE [dbo].[CHANGE_DEL_STATUS_REF_HARMCODES]
   @id float(53),
   @modif_by varchar(max),
   @del_status varchar(max)
AS 
   BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


      UPDATE PES.dbo.REF_HARM_CODES WITH (UPDLOCK)
         SET 
            DELETED = @del_status, 
            MODIFIED_BY = @modif_by, 
            MODIFIED_DT = getdate()
      WHERE REF_HARM_CODES.HARM_CODE = @id
      IF @@TRANCOUNT > 0
         COMMIT WORK 

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

   END
GO
