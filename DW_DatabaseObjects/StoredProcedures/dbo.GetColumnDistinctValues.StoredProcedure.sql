/****** Object:  StoredProcedure [dbo].[GetColumnDistinctValues]    Script Date: 01/08/2013 14:51:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jared Guy
-- Create date: 02/18/2011
-- Description:	Calculate the distinct number of values in each column of each table
-- =============================================
CREATE PROCEDURE [dbo].[GetColumnDistinctValues] 

	@MaximumDistinctValueCount INT = 100
AS
BEGIN


    -- Insert statements for procedure here
	--SELECT @FragmentationLevel

/* Declare variables*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @tablename VARCHAR(255);
DECLARE @execstr VARCHAR(8000);
DECLARE @objectid INT;
DECLARE @indexid INT;
DECLARE @frag decimal;
--DECLARE @FragmentationLevel decimal;
DECLARE @indexname VARCHAR(255);

DECLARE @tableobjectid INT;
DECLARE @columnname VARCHAR(255);
DECLARE @columnxtype INT;
DECLARE @columnobjectid INT;
DECLARE @distinctcount INT;

DECLARE @distinctvalue VARCHAR(8000);

DECLARE @ColumnDistinctCount_Id INT;
DECLARE @TableObjectName VARCHAR(255);
DECLARE @ColumnObjectName VARCHAR(255);
DECLARE @DistinctValueCount BIGINT;

DECLARE @RepresentedValue VARCHAR(8000);
DECLARE @RepresentedValueCount INT;


--SELECT t.name as tableobjectname,t.id as tableobjectid,c.name as columnobjectname,c.id as columnobjectid
--FROM sysobjects t inner join sysobjects c on t.id=c.id
--where t.type='U'
--order by t.name,c.colorder


/* Create the table.*/

CREATE TABLE #collist (
ColumnDistinctCount_Id INT,
TableObjectName VARCHAR(255),
ColumnObjectName VARCHAR(255),
RepresentedValue VARCHAR(8000),
RepresentedValueCount INT
);


/* Declare a cursor.*/
DECLARE columns CURSOR FOR
SELECT DISTINCT ColumnDistinctCount_Id,TableObjectName,ColumnObjectName,DistinctValueCount
FROM dbo._ColumnDistinctCount
where DistinctValueCount<=@MaximumDistinctValueCount
order by TableObjectName,ColumnObjectName



/* Open the cursor.*/
OPEN columns;

/* Loop through all the tables in the database.*/
FETCH NEXT
FROM columns
INTO @ColumnDistinctCount_Id,@TableObjectName,@ColumnObjectName,@DistinctValueCount;

WHILE @@FETCH_STATUS = 0
BEGIN;


PRINT GETDATE();
PRINT @TableObjectName + ' ' + @ColumnObjectName;


--SELECT 64 AS ColumnDistinctCount_Id,'PES_DW_BOL' AS TableObjectName,'CNTR_FLG' AS ColumnObjectName, [CNTR_FLG] AS RepresentedValue, COUNT(*) AS RepresentedValueCount FROM [PES_DW_BOL] 
--GROUP BY  [CNTR_FLG]
--ORDER BY [CNTR_FLG]

SELECT @execstr = '
SELECT '+cast(@ColumnDistinctCount_Id as varchar)+' AS ColumnDistinctCount_Id,'''+@TableObjectName+''' AS TableObjectName,'''+@ColumnObjectName+''' AS ColumnObjectName, ['+@ColumnObjectName+'] AS RepresentedValue, COUNT(*) AS RepresentedValueCount FROM ['+@TableObjectName+'] 
GROUP BY  ['+@ColumnObjectName+']
ORDER BY COUNT(['+@ColumnObjectName+']) DESC
';


print @execstr;
print '';


/* Do the showcontig of all indexes of the table*/
INSERT INTO #collist
EXEC (@execstr);


--PRINT GETDATE();
--PRINT @TableObjectName + ' ' + @ColumnObjectName;

----SELECT @execstr = 'select ''' + @tablename + ''', ''' + @columnname + ''', count(distinct(' + @columnname + ')) from ' + @tablename;

--SELECT @execstr = 'insert into _ColumnDistinctValues (ColumnDistinctCount_Id,TableObjectName,ColumnObjectName,DistinctValueCount) select ''' + @tablename + ''', ''' + @columnname + ''', (select count(distinct([' + @columnname + '])) from [' + @tablename + '])';

--print @execstr;
--print '';

--EXEC (@execstr);

FETCH NEXT
FROM columns
INTO @ColumnDistinctCount_Id,@TableObjectName,@ColumnObjectName,@DistinctValueCount;
END;




/* Close and deallocate the cursor.*/
CLOSE columns;
DEALLOCATE columns;

/* Declare the cursor for the list of indexes to be defragged.*/
DECLARE indexes CURSOR FOR
SELECT distinct ColumnDistinctCount_Id, TableObjectName, ColumnObjectName, RepresentedValue, RepresentedValueCount
FROM #collist
;

/* Open the cursor.*/
OPEN indexes;

/* Loop through the indexes.*/
FETCH NEXT
FROM indexes
INTO @ColumnDistinctCount_Id, @TableObjectName, @ColumnObjectName, @RepresentedValue, @RepresentedValueCount;

WHILE @@FETCH_STATUS = 0
BEGIN;

PRINT GETDATE();
PRINT cast(@ColumnDistinctCount_Id as varchar) + ' ' + @TableObjectName + ' ' + @ColumnObjectName + ' = ' + isnull(@RepresentedValue,'NULL') + ' :: ' + cast(@RepresentedValueCount as varchar);

--SELECT @execstr = 'select ''' + @tablename + ''', ''' + @columnname + ''', count(distinct(' + @columnname + ')) from ' + @tablename;

SELECT @execstr = 'insert into _ColumnDistinctValues (ColumnDistinctCount_Id,RepresentedValue,RepresentedValueCount) 
values (' + cast(@ColumnDistinctCount_Id as varchar) + ', ''' + replace(isnull(@RepresentedValue,'NULL'),'''','''''') + ''', ' + cast(@RepresentedValueCount as varchar) + ')';
--values (' + cast(@ColumnDistinctCount_Id as varchar) + ', ''' + replace(@TableObjectName,'''','''''') + ''', ''' + replace(@ColumnObjectName,'''','''''') + ''', ''' + replace(@RepresentedValue,'''','''''') + ''', ' + cast(@RepresentedValueCount as varchar) + ')';
--select ' + @ColumnDistinctCount_Id + ', ''' + replace(@TableObjectName,'''','''''') + ''', ''' + replace(@ColumnObjectName,'''','''''') + ''', ''' + replace(@RepresentedValue,'''','''''') + ''', ' + @RepresentedValueCount;


print @execstr;
print '';

EXEC (@execstr);




FETCH NEXT
FROM indexes
INTO @ColumnDistinctCount_Id, @TableObjectName, @ColumnObjectName, @RepresentedValue, @RepresentedValueCount;
END;

/* Close and deallocate the cursor.*/
CLOSE indexes;
DEALLOCATE indexes;

/* Delete the temporary table.*/
DROP TABLE #collist;



END
GO
