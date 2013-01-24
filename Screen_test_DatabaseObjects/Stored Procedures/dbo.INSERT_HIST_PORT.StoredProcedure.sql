/****** Object:  StoredProcedure [dbo].[INSERT_HIST_PORT]    Script Date: 01/03/2013 19:47:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- CTS - 16TH JULY 2009
-- MODIFICATIONS MADE TO THE SP TO IMPOSE A CONSTRAINT ON DUPLICATE ENTRIES
-- DUPLICATE ENTRY FOR THE PERMUTATION NAME AND THE REF_ID CANNOT BE ADDED

CREATE PROCEDURE [dbo].[INSERT_HIST_PORT]  
   @perm varchar(max),
   /*
   *   SSMA warning messages:
   *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
   */

   @ref_id float(53),
   @modif_by varchar(max),
	@RETURN_VALUE INT OUTPUT
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


        -- @compress_value varchar(35)
		DECLARE @RECCOUNT INT

		SELECT @RECCOUNT = COUNT(*) FROM PES.DBO.LIB_PORT WITH (NOLOCK)
		WHERE NAME_KEY = @PERM AND REF_ID = @ref_id
			AND IS_US_PORT = 1

		IF @RECCOUNT = 0
		BEGIN
			INSERT INTO [PES].[dbo].[LIB_PORT]
           ([CODE_KEY]
           ,[NAME_KEY]
           ,[REF_ID]
           ,[ACTIVE]
           ,[MODIFY_DATE]
           ,[MODIFY_USER]
           ,[IS_US_PORT])
			 VALUES
				   (NULL
				   ,@perm
				   ,@ref_id
				   ,'Y'
				   ,GETDATE()
				   ,@modif_by
				   ,1)
			SET @RETURN_VALUE = (select max(id) from PES.dbo.lib_port WITH (NOLOCK))
		END
		ELSE
			SET @RETURN_VALUE = 1

--      SET @compress_value = dbo.GET_KEY(@perm)

	--SET @compress_value =@perm

--      INSERT dbo.HIST_PORT(
--         PORT_KEY, 
--         PORT, 
--         PORT_ID, 
--         MODIFIED_BY, 
--         MODIFIED_DT)
--         VALUES (
--            @compress_value, 
--            @perm, 
--            @id, 
--            @modif_by, 
--            getdate())



--
--      IF @@TRANCOUNT > 0
--         COMMIT WORK 

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

   END
GO
