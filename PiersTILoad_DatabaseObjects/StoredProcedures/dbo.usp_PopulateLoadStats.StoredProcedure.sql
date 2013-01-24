/****** Object:  StoredProcedure [dbo].[usp_PopulateLoadStats]    Script Date: 01/09/2013 18:40:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [dbo].[usp_PopulateLoadStats] 8, 'PopulateProcessedData'
CREATE PROCEDURE [dbo].[usp_PopulateLoadStats]
	 @IdLoadLog int
	,@ProcessName varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NEWLINE char(1)
	SET @NEWLINE = CHAR(10)-- + CHAR(13)

	DECLARE @stgload_TABLE_NAME varchar(100)

	-- Add SUMMARY Records, e.g. Total number of BOLs loaded, etc.
	IF @ProcessName = 'PopulateRawData'
	BEGIN
		SET @stgload_TABLE_NAME = 'stgload_raw'
		;WITH tmpSummary As (
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -30 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_LOADS_IN' As FieldName, 'Total LOADs fetched from PES' As FieldValue, COUNT(LOAD_NBR) As NumRecs
		   FROM dbo.LoadPayLoad WHERE IdLoadLog = CAST(@IdLoadLog As varchar)
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -20 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_BOL_IN' As FieldName, 'Total BOLs fetched from PES' As FieldValue, COUNT(BOL_ID) As NumRecs
		   FROM dbo.raw_bl
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -10 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_BOL_OUT' As FieldName, 'Total BOLs loaded into TI' As FieldValue, COUNT(BOL_ID) As NumRecs
		   FROM dbo.stgload_raw
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -8 As SortOrder, 'SUMMARY' As Type
			,'BOL_WITHOUT_CMD' As FieldName, 'BOLs fetched without CMDs' As FieldValue, COUNT(BOL_ID) As NumRecs
		   FROM dbo.raw_bl WHERE BOL_ID NOT IN (SELECT BOL_ID FROM raw_cmd)
		)
		INSERT INTO dbo.LoadReport (IdLoadLog,Type,FieldName,FieldValue,NumRecs)
		SELECT IdLoadLog,Type,FieldName,FieldValue,NumRecs
		 FROM tmpSummary
		ORDER BY SortOrder ASC, Type DESC, FieldName ASC, NumRecs DESC
	END
	ELSE IF @ProcessName = 'PopulateProcessedData'
	BEGIN
		SET @stgload_TABLE_NAME = 'stgload_processed'
		;WITH tmpSummary As (
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -30 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_BOL_IN' As FieldName, 'Total BOLs fetched from PESDW' As FieldValue, COUNT(DISTINCT(BOL_ID)) As NumRecs
		   FROM dbo.processed_bl
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -20 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_CMD_IN' As FieldName, 'Total CMDs fetched from PESDW' As FieldValue, COUNT(CMD_ID) As NumRecs
		   FROM dbo.processed_cmd
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -16 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_BOL_IN_PRE_PES' As FieldName, 'Total BOLs fetched from PRE_PES' As FieldValue, COUNT(DISTINCT(t_nbr)) As NumRecs
		   FROM dbo.pre_pes_usshipment
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -14 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_CMD_IN_PRE_PES' As FieldName, 'Total CMDs fetched from PRE_PES' As FieldValue, COUNT(t_nbr) As NumRecs
		   FROM dbo.pre_pes_usshipment
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -10 As SortOrder, 'SUMMARY' As Type
			,'TOTAL_BOL_OUT' As FieldName, 'Total BOLs updated into TI' As FieldValue, COUNT(*) As NumRecs
		   FROM dbo.stgload_processed
		 UNION
		  SELECT CAST(@IdLoadLog As varchar) As 'IdLoadLog', -8 As SortOrder, 'SUMMARY' As Type
			,'BOL_WITHOUT_CMD' As FieldName, 'BOLs fetched without CMDs' As FieldValue, COUNT(BOL_ID) As NumRecs
		   FROM dbo.processed_bl WHERE BOL_ID NOT IN (SELECT BOL_ID FROM processed_cmd)
		)
		INSERT INTO dbo.LoadReport (IdLoadLog,Type,FieldName,FieldValue,NumRecs)
		SELECT IdLoadLog,Type,FieldName,FieldValue,NumRecs
		 FROM tmpSummary
		ORDER BY SortOrder ASC, Type DESC, FieldName ASC, NumRecs DESC
	END

	-- Process the Report Fields specified in LoadReportDefinition
	DECLARE @WorkSql varchar(MAX)
	SELECT @WorkSql =
	 COALESCE(@WorkSql + @NEWLINE+' UNION' + @NEWLINE,'')
	 +
	 CASE
		WHEN isc.COLUMN_NAME IS NULL THEN
		-- Invalid column specified
		  ' SELECT ' + CAST(@IdLoadLog As varchar) + ' As IdLoadLog,'''
			 + CAST(lrd.SortOrder As varchar) + ''' As SortOrder,'''
			 + lrd.Type + ''' As Type,'''
			 + lrd.FieldName + ''' As FieldName, ''Invalid FieldName specified in table LoadReportDefinition!'' As FieldValue, NULL As NumRecs'
		WHEN lrd.Type NOT IN ('TOTAL_COUNT','TOP_N_VALUES','VALUE_WATCH','VALUE_WATCH_CONTAINS') THEN
		-- Invalid type specified
		  ' SELECT ' + CAST(@IdLoadLog As varchar) + ' As IdLoadLog,'''
			 + CAST(lrd.SortOrder As varchar) + ''' As SortOrder,'''
			 + lrd.Type + ''' As Type,'''
			 + lrd.FieldName + ''' As FieldName, ''Invalid Type specified in table LoadReportDefinition!'' As FieldValue, NULL As NumRecs'
		ELSE
		CASE WHEN lrd.Type = 'TOP_N_VALUES' THEN
				  ' SELECT * FROM ('
				+ @NEWLINE + '  SELECT TOP ' + CAST(lrd.TopNValues As varchar) + ' '
					 + CAST(@IdLoadLog As varchar) + ' As IdLoadLog, '''
					 + CAST(lrd.SortOrder As varchar) + ''' As SortOrder,'''
					 + lrd.Type + ''' As Type,'''
					 + isc.COLUMN_NAME + ''' As FieldName,'
					 + ' CAST(' + isc.COLUMN_NAME + ' As varchar)' + ' As FieldValue, COUNT(*) As NumRecs'
				+ @NEWLINE + '   FROM ' + isc.TABLE_SCHEMA + '.' + isc.TABLE_NAME
				+ @NEWLINE + '   GROUP BY ' + isc.COLUMN_NAME
				+ @NEWLINE + '   ORDER BY NumRecs DESC'
				+ @NEWLINE + '  ) As t'
			 WHEN lrd.Type = 'TOTAL_COUNT' THEN
				  ' SELECT * FROM ('
				+ @NEWLINE + '  SELECT '
					 + CAST(@IdLoadLog As varchar) + ' As IdLoadLog, '''
					 + CAST(lrd.SortOrder As varchar) + ''' As SortOrder,'''
					 + lrd.Type + ''' As Type,'''
					 + isc.COLUMN_NAME + ''' As FieldName,'
					 + ' CAST(' + isc.COLUMN_NAME + ' As varchar)' + ' As FieldValue, COUNT(*) As NumRecs'
				+ @NEWLINE + '   FROM ' + isc.TABLE_SCHEMA + '.' + isc.TABLE_NAME
				+ @NEWLINE + '   GROUP BY ' + isc.COLUMN_NAME
				+ @NEWLINE + '  ) As t'
			 WHEN lrd.Type = 'VALUE_WATCH' THEN
				  ' SELECT * FROM ('
				+ @NEWLINE + '  SELECT '
					 + CAST(@IdLoadLog As varchar) + ' As IdLoadLog, '''
					 + CAST(lrd.SortOrder As varchar) + ''' As SortOrder,'''
					 + lrd.Type + ''' As Type,'''
					 + isc.COLUMN_NAME + ''' As FieldName,'
					 + ' CAST(t1.Item As varchar)' + ' As FieldValue, COUNT(t2.'+isc.COLUMN_NAME+') As NumRecs'
				+ @NEWLINE + '   FROM (SELECT Item FROM dbo.ufn_SplitString(''' + lrd.ValuesToWatch + ''',''|'')) As t1'
				+ @NEWLINE + '   LEFT OUTER JOIN ' + isc.TABLE_SCHEMA + '.' + isc.TABLE_NAME + ' t2 ON t1.Item = t2.'+isc.COLUMN_NAME
				+ @NEWLINE + '   GROUP BY t1.Item,t2.'+isc.COLUMN_NAME
				+ @NEWLINE + '  ) As t'
			 WHEN lrd.Type = 'VALUE_WATCH_CONTAINS' THEN
				  ' SELECT * FROM ('
				+ @NEWLINE + '  SELECT '
					 + CAST(@IdLoadLog As varchar) + ' As IdLoadLog, '''
					 + CAST(lrd.SortOrder As varchar) + ''' As SortOrder,'''
					 + lrd.Type + ''' As Type,'''
					 + isc.COLUMN_NAME + ''' As FieldName,'
					 + ' CAST(t1.Item As varchar)' + ' As FieldValue, COUNT(t2.'+isc.COLUMN_NAME+') As NumRecs'
				+ @NEWLINE + '   FROM (SELECT Item FROM dbo.ufn_SplitString(''' + lrd.ValuesToWatch + ''',''|'')) As t1'
				+ @NEWLINE + '   LEFT OUTER JOIN ' + isc.TABLE_SCHEMA + '.' + isc.TABLE_NAME + ' t2 ON t2.'+isc.COLUMN_NAME + ' LIKE ''%+t1.Item+%''' 
				+ @NEWLINE + '   GROUP BY t1.Item,t2.'+isc.COLUMN_NAME
				+ @NEWLINE + '  ) As t'
		END
	 END
	FROM dbo.LoadReportDefinition lrd
	LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS isc
	 ON lrd.FieldName = isc.COLUMN_NAME
		AND isc.TABLE_SCHEMA = 'dbo' AND isc.TABLE_NAME = @stgload_TABLE_NAME
	WHERE lrd.ProcessName = @ProcessName
	ORDER BY COLUMN_NAME

	-- Add the INSERT INTO clause
	SET @WorkSql =
	 'WITH tmpDetails As (' + @NEWLINE +
	 @WorkSql + @NEWLINE +
	 ')' + @NEWLINE +
	 'INSERT INTO dbo.LoadReport (IdLoadLog,Type,FieldName,FieldValue,NumRecs)' + @NEWLINE +
	 'SELECT IdLoadLog,Type,FieldName,FieldValue,NumRecs' + @NEWLINE +
	 ' FROM tmpDetails' + @NEWLINE +
	 'ORDER BY SortOrder ASC, Type DESC, FieldName ASC, NumRecs DESC'

--	PRINT '@WorkSql:' + @NEWLINE + @WorkSql
	EXEC (@WorkSql)
END
GO
