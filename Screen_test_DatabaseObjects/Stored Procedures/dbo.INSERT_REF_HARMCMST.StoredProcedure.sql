/****** Object:  StoredProcedure [dbo].[INSERT_REF_HARMCMST]    Script Date: 01/03/2013 19:47:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	<Inserting into the HarmCode Dictionary>
-- Modifications: DE1189 | Develop UI features to fix existing Harm and JOC Code entry screens | JSA | 05/04/2011 | Solution: Set compressed value using SCREEN_TEST.dbo.GET_KEY function.
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_REF_HARMCMST]  
   @fullname varchar(max),
   @harmcode varchar(max),
   @modif_by varchar(max),
   /*
   *   SSMA warning messages:
   *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
   */

    @RETURN_VALUE INT OUT
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

DECLARE @RECCOUNT int

--Check to see if the HarmCode already exists.
SELECT @RECCOUNT=count(*) FROM [PES].[dbo].[REF_HARMCMST] WITH (NOLOCK)
WHERE FULL_NAME = LEFT(@fullname, 50) AND HARMCODE  = LEFT(@harmcode, 35)

IF @RECCOUNT=0
BEGIN
      INSERT INTO PES.dbo.REF_HARMCMST(
         COMP_NAME,
         FULL_NAME, 
         HARMCODE, 
         DELETED, 
         MODIFIED_BY, 
         MODIFIED_DT)
         VALUES (
            LEFT(SCREEN_TEST.dbo.GET_KEY(@fullname),40), --Field length 40.
            LEFT(@fullname, 50), --Field length 50.
            LEFT(@harmcode, 35),  --Field length 35. 
            'N', 
            @modif_by, 
            getdate())

	SET @RETURN_VALUE = (select max(id) from PES.dbo.REF_HARMCMST WITH (NOLOCK))
END
ELSE
	SET @RETURN_VALUE = 1

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
