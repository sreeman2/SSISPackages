/****** Object:  StoredProcedure [dbo].[z_CompareTables]    Script Date: 01/08/2013 14:51:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC z_CompareTables 'PES_DW_REF_STATE_CONV', 'PES_DW_REF_STATE_CONV_golive'
CREATE PROCEDURE [dbo].[z_CompareTables](
  @table1 varchar(100)
 ,@table2 Varchar(100)
-- ,@T1ColumnList varchar(1000)
-- ,@T2ColumnList varchar(1000) = ''
)
AS
 
-- Table1, Table2 are the tables or views to compare.
-- T1ColumnList is the list of columns to compare, from table1.
-- Just list them comma-separated, like in a GROUP BY clause.
-- If T2ColumnList is not specified, it is assumed to be the same
-- as T1ColumnList.  Otherwise, list the columns of Table2 in
-- the same order as the columns in table1 that you wish to compare.
--
-- The result is all rows from either table that do NOT match
-- the other table in all columns specified, along with which table that
-- row is from.


DECLARE @T1ColumnList varchar(MAX), @T2ColumnList varchar(MAX)
SELECT @T1ColumnList = COALESCE(@T1ColumnList + ', ', '') + isc.COLUMN_NAME
 FROM INFORMATION_SCHEMA.COLUMNS isc
WHERE isc.TABLE_NAME = @table1
 AND isc.COLUMN_NAME NOT IN  ('MODIFIED_DT','MODIFIED_BY')

SELECT @T2ColumnList = @T1ColumnList
--SELECT @T1ColumnList, @T2ColumnList
 
declare @SQL varchar(8000);
 
--IF @t2ColumnList = '' SET @T2ColumnList = @T1ColumnList
 
set @SQL = 'SELECT ''' + @table1 + ''' AS TableName, ' + @t1ColumnList +
 ' FROM ' + @Table1 + ' UNION ALL SELECT ''' + @table2 + ''' As TableName, ' +
 @t2ColumnList + ' FROM ' + @Table2
 
set @SQL = 'SELECT Max(TableName) as TableName, ' + @t1ColumnList +
 ' FROM (' + @SQL + ') A GROUP BY ' + @t1ColumnList +
 ' HAVING COUNT(*) = 1' +
 ' ORDER BY 2, 1'
 
PRINT @SQL
--SELECT @SQL
exec ( @SQL)
GO
