/****** Object:  StoredProcedure [dbo].[CREATETMPID]    Script Date: 01/03/2013 19:47:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CREATETMPID] 
@strValue varchar(max),
@TableID int,
@modified_by varchar(max),
@TmpId int OUTPUT
AS 
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT

SET @TmpId = 0
DECLARE
@str1 varchar(100), 
@tmpoID int;
SET @tmpoID = 0
IF (@TableID = 1)
	BEGIN
	IF (len(@strValue) <= 4)
		BEGIN
--			SELECT @tmpoID=MaxValue from PEA_SEQUENCE WHERE TableName='REF_CARRIER'
--			SET @tmpoID=@tmpoID+1
--			UPDATE PEA_SEQUENCE SET MaxValue=@tmpoID WHERE TableName='REF_CARRIER'
--			INSERT PES.dbo.REF_CARRIER(ID,CODE,[TYPE],CARRIER_DESC,IS_NVO,IS_TMP) VALUES(@TmpoID,@strValue,@strValue,'Temporary Carrier','N','Y')
			INSERT PES.dbo.REF_CARRIER(CODE,[TYPE],CARRIER_DESC,IS_NVO,IS_TMP) VALUES(@strValue,@strValue,'Temporary Carrier','N','Y')
			SELECT @tmpoID =MAX(ID) FROM PES.DBO.REF_CARRIER WITH (NOLOCK)
			UPDATE PEA_SEQUENCE WITH (UPDLOCK) SET MaxValue=@tmpoID WHERE TableName='REF_CARRIER'
		END
	END
ELSE 
IF (@TableID = 3)
	BEGIN
		IF (len(@strValue) <= 35)
		BEGIN
			SET @str1 = @strValue
--			IF (len(@str1) > 17)
--			SET @str1 = substring(@str1, 1, 17)
--			SELECT @tmpoID=MaxValue from PEA_SEQUENCE WHERE TableName='REF_VESSEL'
--			SET @tmpoID=@tmpoID+1
--			UPDATE PEA_SEQUENCE SET MaxValue=@tmpoID WHERE TableName='REF_VESSEL'
--			INSERT PES.dbo.REF_VESSEL(ID, STND_VESSEL, NAME, IS_TMP)	VALUES (@TmpoID, @strValue, @str1, 'Y')

			declare @reccount int
			select @reccount = count(*) from pes.dbo.ref_vessel WITH (NOLOCK)
				where stnd_vessel = @strValue
					and vessel_country = ' '
			if @reccount > 0
				begin	
					SELECT @tmpoID = id from pes.dbo.ref_vessel WITH (NOLOCK)
						where stnd_vessel = @strvalue
							and vessel_country = ' '
				end
			else
				begin
					INSERT PES.dbo.REF_VESSEL
						(STND_VESSEL, 
							[NAME], 
							IS_TMP, 
							vessel_country,
							modified_by, 
							modified_dt)	
					VALUES 
						(@strValue, 
							@str1, 
							'Y', 
							' ',
							@modified_by, 
							GETDATE())
					SELECT @tmpoID = SCOPE_IDENTITY() 
				end

--			INSERT PES.dbo.REF_VESSEL(STND_VESSEL, NAME, IS_TMP)	VALUES (@strValue, @str1, 'Y')
--			SELECT @tmpoID =MAX(ID) FROM PES.DBO.REF_VESSEL
			UPDATE PEA_SEQUENCE WITH (UPDLOCK) SET MaxValue=@tmpoID WHERE TableName='REF_VESSEL'

		END
	END
SET @tmpID = @tmpoID

-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
