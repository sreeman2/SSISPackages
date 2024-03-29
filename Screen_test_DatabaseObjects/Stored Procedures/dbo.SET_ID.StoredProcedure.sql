/****** Object:  StoredProcedure [dbo].[SET_ID]    Script Date: 01/03/2013 19:48:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SET_ID]  
	@inT_NBR varchar(max),
	@ID INT,
	@groupFlg INT,
	@histFlg INT,
	@processName varchar(max),
	@strValue varchar(max),
	@st_id INT,
	@strUsername varchar(max),
	@voyage_number varchar(max),
	@ref_name varchar(max),
	@recCount INT  OUTPUT
	AS 
BEGIN

---- [aa] - 11/02/2010
---- Log start time
--DECLARE @IdLogOut int
--DECLARE @ParametersIn varchar(MAX)
--SET @ParametersIn =
--'@inT_NBR='''+@inT_NBR+''''
--+', @ID='++LTRIM(RTRIM(STR(@ID)))
--+', @groupFlg='++LTRIM(RTRIM(STR(@groupFlg)))
--+', @histFlg='++LTRIM(RTRIM(STR(@histFlg)))
--+', @processName='''+@processName+''''
--+', @strValue='''+@strValue+''''
--+', @st_id='++LTRIM(RTRIM(STR(@st_id)))
--+', @strUsername='''+@strUsername+''''
--+', @voyage_number='''+@voyage_number+''''
--+', @ref_name='''+@ref_name+''''
--EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
--@SprocName = 'SET_ID'
--,@Parameters = @ParametersIn
--,@IdLog = @IdLogOut OUT

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = '@inT_NBR='''+@inT_NBR+''''
+', @ID='++LTRIM(RTRIM(STR(@ID)))
+', @groupFlg='++LTRIM(RTRIM(STR(@groupFlg)))
+', @histFlg='++LTRIM(RTRIM(STR(@histFlg)))
+', @processName='''+@processName+''''
+', @strValue='''+@strValue+''''
+', @st_id='++LTRIM(RTRIM(STR(@st_id)))
+', @strUsername='''+@strUsername+''''
+', @voyage_number='''+@voyage_number+''''
+', @ref_name='''+@ref_name+''''
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT



	DECLARE @in_tnbr_ID varchar(10),
	@Pos int,
	@RowIndex INT,
	@DQL_BL_ROWCOUNT INT,
	@STD_VOYAGE_ROWCOUNT INT,
	@CTRL_PROCESS_VOYAGE_ROWCOUNT  INT

	--Cursor Variable
	declare @tmpT_NBR int

	DECLARE
		@TNBR_TEMP_RESULT TABLE (TNBR INT, POS INT);
		SET @inT_NBR = LTRIM(RTRIM(@inT_NBR))+ ','
		SET @Pos = CHARINDEX(',', @inT_NBR, 1)
	
	DECLARE @TotalRecordCount int
	select @TotalRecordCount=0

	SET @RowIndex = 1

	IF REPLACE(@inT_NBR, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @in_tnbr_ID = LTRIM(RTRIM(LEFT(@inT_NBR, @Pos - 1)))
			IF @in_tnbr_ID <> ''
			BEGIN
				INSERT INTO @TNBR_TEMP_RESULT VALUES (CAST(@in_tnbr_ID AS int),@RowIndex)
				SET @RowIndex = @RowIndex +1
			END
			SET @inT_NBR = RIGHT(@inT_NBR, LEN(@inT_NBR) - @Pos)
			SET @Pos = CHARINDEX(',', @inT_NBR, 1)
		END
	END	

		DECLARE
		@TEMP_RESULT TABLE (TNBR INT,POS INT);
		DECLARE @T_NBR INT,
		@v_tnbr INT

		IF ( @strValue <> '' )
		BEGIN
			INSERT @TEMP_RESULT (TNBR) 
			SELECT DISTINCT S.T_NBR
			FROM dbo.CTRL_PROCESS_VOYAGE  AS C WITH (NOLOCK) join dbo.STD_VOYAGE  AS S WITH (NOLOCK) 
			on C.T_NBR = S.T_NBR 
			WHERE C.COMPLETE_STATUS = 1 
			AND S.STD_ID = @st_id
			AND C.PROCESS_NAME = @processName 
			AND dbo.GET_KEY(C.[KEY]) = dbo.GET_KEY(@strValue) 	
		END
		ELSE
		BEGIN			
			INSERT @TEMP_RESULT (TNBR)
			SELECT DISTINCT S.T_NBR
			FROM dbo.CTRL_PROCESS_VOYAGE  AS C WITH (NOLOCK) join dbo.STD_VOYAGE  AS S WITH (NOLOCK) 
			on C.T_NBR = S.T_NBR 
			WHERE C.COMPLETE_STATUS = 1 
			AND S.STD_ID = @st_id
			AND C.PROCESS_NAME = @processName 
			AND dbo.GET_KEY(C.[KEY]) IS NULL
		END

		select @recCount = 0

		IF (@groupFlg = 1)
		BEGIN
			UPDATE C WITH (UPDLOCK)
			SET COMPLETE_STATUS=0, 
				OWNER_ID = @strUsername 
			FROM CTRL_PROCESS_VOYAGE C 
			WHERE PROCESS_NAME=@processName
			AND C.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)

			IF (@processName='INVALID CARRIER') 
			BEGIN
				UPDATE S WITH (UPDLOCK)
				SET CARRIER_ID = @ID, 
					MODIFIED_BY = @strUsername, 
					MODIFIED_DT = GETDATE(),
					VOYAGE_NBR= @voyage_number 
				FROM STD_VOYAGE S WHERE S.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)

				-- Cursor is used here taking into account the trigger UPD_STD_VOYAGE declared on DQA_BL table
				declare curTNBR cursor for
				SELECT TNBR FROM @TEMP_RESULT

				open curTNBR
				fetch next from curTNBR into @tmpT_NBR

				while @@fetch_status=0
				begin
					UPDATE B WITH (UPDLOCK)
					SET CARRIER_ID_MOD=@ID 
					FROM DQA_BL B 
					WHERE B.T_NBR = @tmpT_NBR
				fetch next from curTNBR into @tmpT_NBR
				end
				
				close curTNBR
				deallocate curTNBR

				UPDATE B WITH (UPDLOCK)
				SET CARRIER_NAME_MOD=C.[CODE] 
				FROM DQA_BL B JOIN PES.DBO.REF_CARRIER C WITH (NOLOCK)
				ON B.CARRIER_ID_MOD=C.ID
				WHERE CARRIER_ID_MOD= @ID 
				AND B.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)
			END
			IF (@processName='INVALID VESSEL NAME') 
			BEGIN
				UPDATE S WITH (UPDLOCK)
				SET VESSEL_ID = @ID, 
					MODIFIED_BY = @strUsername, 
					MODIFIED_DT = GETDATE(),
					VOYAGE_NBR= @voyage_number 
				FROM STD_VOYAGE S WHERE S.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)

			-- Cursor is used here taking into account the trigger UPD_STD_VOYAGE declared on DQA_BL table
				declare curTNBR cursor for
				SELECT TNBR FROM @TEMP_RESULT

				open curTNBR
				fetch next from curTNBR into @tmpT_NBR

				while @@fetch_status=0
				begin
					UPDATE B WITH (UPDLOCK)
					SET VESSEL_ID_MOD=@ID 
					FROM DQA_BL B 
					WHERE B.T_NBR = @tmpT_NBR
				fetch next from curTNBR into @tmpT_NBR
				end
				
				close curTNBR
				deallocate curTNBR

				UPDATE B WITH (UPDLOCK)
				SET VESSEL_NAME_MOD=V.[NAME] 
				FROM DQA_BL B JOIN PES.DBO.REF_VESSEL V WITH (NOLOCK)
				ON B.VESSEL_ID_MOD=V.ID
				WHERE VESSEL_ID_MOD= @ID 
				AND B.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)
			END
			 IF (@processName='INVALID USPORT') 
			BEGIN
				UPDATE S WITH (UPDLOCK)
				SET USPORT_ID=@ID, 
					MODIFIED_BY = @strUsername, 
					MODIFIED_DT = GETDATE(),
					VOYAGE_NBR= @voyage_number  
				FROM STD_VOYAGE S WHERE S.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)

				-- Cursor is used here taking into account the trigger UPD_STD_VOYAGE declared on DQA_BL table
				declare curTNBR cursor for
				SELECT TNBR FROM @TEMP_RESULT

				open curTNBR
				fetch next from curTNBR into @tmpT_NBR

				while @@fetch_status=0
				begin
					UPDATE B WITH (UPDLOCK)
					SET USPORT_ID_MOD=@ID 
					FROM DQA_BL B 
					WHERE B.T_NBR = @tmpT_NBR
				fetch next from curTNBR into @tmpT_NBR
				end
				
				close curTNBR
				deallocate curTNBR
				
				UPDATE B WITH (UPDLOCK)
				SET USPORT_CODE_MOD=P.CODE,
				USPORT_NAME_MOD=P.[PIERS_NAME] 
				FROM DQA_BL B JOIN PES.DBO.REF_PORT P WITH (NOLOCK)
				ON B.USPORT_ID_MOD=P.ID
				WHERE USPORT_ID_MOD= @ID 
				AND B.T_NBR IN (SELECT TNBR FROM @TEMP_RESULT)
			END 
			select @TotalRecordCount= count(TNBR) from @TEMP_RESULT
			select @recCount = @recCount + @TotalRecordCount
		END 
		ELSE
		BEGIN
			UPDATE C WITH (UPDLOCK)
			SET COMPLETE_STATUS=0, 
				OWNER_ID = @strUsername 
			FROM CTRL_PROCESS_VOYAGE C 
			WHERE PROCESS_NAME=@processName
			AND C.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT);

			IF (@processName='INVALID CARRIER') 
			BEGIN
				UPDATE S WITH (UPDLOCK)
				SET CARRIER_ID = @ID, 
					MODIFIED_BY = @strUsername, 
					MODIFIED_DT = GETDATE(),
					VOYAGE_NBR= @voyage_number 
				FROM STD_VOYAGE S WHERE S.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT)

				-- Cursor is used here taking into account the trigger UPD_STD_VOYAGE declared on DQA_BL table
				declare curTNBR cursor for
				SELECT TNBR FROM @TNBR_TEMP_RESULT

				open curTNBR
				fetch next from curTNBR into @tmpT_NBR

				while @@fetch_status=0
				begin
					UPDATE B WITH (UPDLOCK)
					SET CARRIER_ID_MOD=@ID 
					FROM DQA_BL B 
					WHERE B.T_NBR = @tmpT_NBR
				fetch next from curTNBR into @tmpT_NBR
				end
				
				close curTNBR
				deallocate curTNBR

				UPDATE B WITH (UPDLOCK)
				SET CARRIER_NAME_MOD=C.[CODE] 
				FROM DQA_BL B JOIN PES.DBO.REF_CARRIER C WITH (NOLOCK)
				ON B.CARRIER_ID_MOD=C.ID
				WHERE CARRIER_ID_MOD= @ID 
				AND B.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT)
		END
		IF (@processName='INVALID VESSEL NAME') 
		BEGIN
			UPDATE S WITH (UPDLOCK)
			SET VESSEL_ID = @ID, 
				MODIFIED_BY = @strUsername, 
				MODIFIED_DT = GETDATE(),
				VOYAGE_NBR= @voyage_number 
			FROM STD_VOYAGE S WHERE S.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT)

			-- Cursor is used here taking into account the trigger UPD_STD_VOYAGE declared on DQA_BL table
			declare curTNBR cursor for
			SELECT TNBR FROM @TNBR_TEMP_RESULT

			open curTNBR
			fetch next from curTNBR into @tmpT_NBR

			while @@fetch_status=0
			begin
				UPDATE B WITH (UPDLOCK)
				SET VESSEL_ID_MOD=@ID 
				FROM DQA_BL B 
				WHERE B.T_NBR = @tmpT_NBR
			fetch next from curTNBR into @tmpT_NBR
			end
			
			close curTNBR
			deallocate curTNBR

			UPDATE B WITH (UPDLOCK)
			SET VESSEL_NAME_MOD=V.[NAME] 
			FROM DQA_BL B JOIN PES.DBO.REF_VESSEL V WITH (NOLOCK)
			ON B.VESSEL_ID_MOD=V.ID
			WHERE VESSEL_ID_MOD= @ID 
			AND B.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT)
		END
		IF (@processName='INVALID USPORT') 
		BEGIN
			UPDATE S WITH (UPDLOCK)
			SET USPORT_ID=@ID, 
				MODIFIED_BY = @strUsername, 
				MODIFIED_DT = GETDATE(),
				VOYAGE_NBR= @voyage_number  
			FROM STD_VOYAGE S WHERE S.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT)

			-- Cursor is used here taking into account the trigger UPD_STD_VOYAGE declared on DQA_BL table
			declare curTNBR cursor for
			SELECT TNBR FROM @TNBR_TEMP_RESULT

			open curTNBR
			fetch next from curTNBR into @tmpT_NBR

			while @@fetch_status=0
			begin
				UPDATE B WITH (UPDLOCK)
				SET USPORT_ID_MOD=@ID 
				FROM DQA_BL B 
				WHERE B.T_NBR = @tmpT_NBR
			fetch next from curTNBR into @tmpT_NBR
			end
			
			close curTNBR
			deallocate curTNBR

			UPDATE B WITH (UPDLOCK)
			SET USPORT_CODE_MOD=P.CODE,
				USPORT_NAME_MOD=P.[PIERS_NAME] 
			FROM DQA_BL B JOIN PES.DBO.REF_PORT P WITH (NOLOCK)
			ON B.USPORT_ID_MOD=P.ID
			WHERE USPORT_ID_MOD= @ID 
			AND B.T_NBR IN (SELECT TNBR FROM @TNBR_TEMP_RESULT)
		END 

		select @TotalRecordCount= count(TNBR) from @TNBR_TEMP_RESULT
		select @recCount = @recCount + @TotalRecordCount		
	END 
	
	IF (@histFlg = 1) 
	BEGIN
	   IF (@processName = 'INVALID CARRIER') 
		BEGIN
			IF NOT EXISTS (SELECT * FROM [PES].[dbo].[LIB_CARRIER] WITH (NOLOCK) WHERE [CODE_KEY] =  @strValue )
				INSERT INTO [PES].[dbo].[LIB_CARRIER] ([CODE_KEY],[NAME_KEY],[REF_ID], [ACTIVE],[MODIFY_USER], [MODIFY_DATE]) 
                                   VALUES(dbo.GET_KEY(@strValue), @strValue,@ID,'Y',@strUsername, GETDATE());
		END
	   IF (@processName = 'INVALID VESSEL NAME') 
		BEGIN
--			IF NOT EXISTS (SELECT * FROM [PES].[dbo].[LIB_VESSEL] (NOLOCK) WHERE [NAME_KEY] =  @strValue )
--				INSERT INTO [PES].[dbo].[LIB_VESSEL] ([CODE_KEY],[NAME_KEY],[REF_ID], [ACTIVE],[MODIFY_USER], [MODIFY_DATE]) 
--						VALUES(NULL,@strValue,@ID, 'Y',@strUsername, GETDATE());
			IF NOT EXISTS (SELECT * FROM [PES].[dbo].[LIB_VESSEL] WITH (NOLOCK) WHERE [NAME_KEY] =  @strValue )
				INSERT INTO [PES].[dbo].[LIB_VESSEL] ([CODE_KEY],[NAME_KEY],[REF_NAME], [ACTIVE],[MODIFY_USER], [MODIFY_DATE]) 
						VALUES(NULL,@strValue,@REF_NAME, 'Y',@strUsername, GETDATE());
		END
	   IF (@processName = 'INVALID USPORT') 
		BEGIN
			IF NOT EXISTS (SELECT * FROM [PES].[dbo].[LIB_PORT] WITH (NOLOCK) WHERE [CODE_KEY] =  @strValue )
				INSERT INTO [PES].[dbo].[LIB_PORT] ([CODE_KEY],[NAME_KEY],[REF_ID], [ACTIVE],[MODIFY_USER], [MODIFY_DATE],[IS_US_PORT])
							VALUES(NULL,@strValue,@ID,'Y',@strUsername, GETDATE(),1);
		END
	END

	

-- [aa] - 11/03/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
@Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT


END
GO
