/****** Object:  StoredProcedure [dbo].[CHANGE_DEL_STATUS_REF_WEIGHT]    Script Date: 01/03/2013 19:47:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CHANGE_DEL_STATUS_REF_WEIGHT]  
   /*
   *   SSMA warning messages:
   *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
   */

   @Id float(53),
   @modif_by varchar(max),
   @del_status varchar(max)
AS 
   
   /*
   *   Generated by SQL Server Migration Assistant for Oracle.
   *   Contact ora2sql@microsoft.com or visit http://www.microsoft.com/sql/migration for more information.
   */
   BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


      DECLARE
         /*
         *   SSMA warning messages:
         *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
         */

         @WgtId float(53)

      SET @WgtId = @id

      UPDATE PES.dbo.REF_GEN_WEIGHT WITH (UPDLOCK)
         SET 
            DELETED = @del_status, 
            MODIFIED_BY = @modif_by, 
            MODIFIED_DT = getdate()
      WHERE REF_GEN_WEIGHT.ID = @WgtId

      IF @@TRANCOUNT > 0
         COMMIT WORK 

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

   END
GO
