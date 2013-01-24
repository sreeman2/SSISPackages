/****** Object:  StoredProcedure [dbo].[GetColumnDistinctValuesAndStats]    Script Date: 01/08/2013 14:51:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jared Guy
-- Create date: 8/24/2009
-- Description:	Defragment all indexes above a certain level of fragmentation
-- =============================================
CREATE PROCEDURE [dbo].[GetColumnDistinctValuesAndStats] 

	@FragmentationLevel decimal = 2.0
AS
BEGIN


    -- Insert statements for procedure here
	--SELECT @FragmentationLevel

/* Declare variables*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @tablename VARCHAR(128);
DECLARE @execstr VARCHAR(512);
DECLARE @objectid INT;
DECLARE @indexid INT;
DECLARE @frag decimal;
--DECLARE @FragmentationLevel decimal;
DECLARE @indexname VARCHAR(255);

DECLARE @tableobjectid INT;
DECLARE @columnname VARCHAR(128);
DECLARE @columnxtype INT;
DECLARE @columnobjectid INT;
DECLARE @distinctcount INT;

/* Decide on the maximum fragmentation to allow for.*/
--SELECT @FragmentationLevel = 20.0;
--SELECT @FragmentationLevel = 2.0;

--SELECT t.name as tableobjectname,t.id as tableobjectid,c.name as columnobjectname,c.id as columnobjectid
--FROM sysobjects t inner join sysobjects c on t.id=c.id
--where t.type='U'
--order by t.name,c.colorder



/* Declare a cursor.*/
DECLARE columns CURSOR FOR
SELECT c.id
FROM sysobjects t inner join syscolumns c on t.id=c.id
where t.type='U'  and c.xtype not in (34,35,36,173,241,231)
order by t.name,c.colorder

--WHERE TABLE_TYPE = 'BASE TABLE';





/* Create the table.*/
CREATE TABLE #collist (
TableObjectName CHAR(255),
TableObjectId INT,
ColumnObjectName char(255),
ColumnObjectId INT,
Columnxtype INT,
ColumnDistinctRowCount INT
);

/* Open the cursor.*/
OPEN columns;

/* Loop through all the tables in the database.*/
FETCH NEXT
FROM columns
INTO @columnobjectid;

WHILE @@FETCH_STATUS = 0
BEGIN;
/* Do the showcontig of all indexes of the table*/
INSERT INTO #collist
EXEC ('
SELECT t.name as tableobjectname,t.id as tableobjectid,c.name as columnobjectname,c.id as columnobjectid
,c.xtype as Columnxtype, -1 as ColumnDistinctRowCount
FROM sysobjects t inner join syscolumns c on t.id=c.id
where c.id = ' + @columnobjectid + '
');
FETCH NEXT
FROM columns
INTO @columnobjectid;
END;




/* Close and deallocate the cursor.*/
CLOSE columns;
DEALLOCATE columns;

/* Declare the cursor for the list of indexes to be defragged.*/
DECLARE indexes CURSOR FOR
SELECT distinct tableobjectname, tableobjectid, columnobjectname, columnobjectid , columnxtype
FROM #collist
;

/* Open the cursor.*/
OPEN indexes;

/* Loop through the indexes.*/
FETCH NEXT
FROM indexes
INTO @tablename, @tableobjectid, @columnname, @columnobjectid, @columnxtype;

WHILE @@FETCH_STATUS = 0
BEGIN;
--PRINT 'Executing DBCC INDEXDEFRAG (0, ' + RTRIM(@tablename) + ',
--' + RTRIM(@indexid) + ') - fragmentation currently '
--+ RTRIM(CONVERT(VARCHAR(15),@frag)) + '%';
--
--SELECT @execstr = 'DBCC INDEXDEFRAG (0, ' + RTRIM(@objectid) + ',
--' + RTRIM(@indexid) + ')';
PRINT GETDATE();
PRINT @tablename + ' ' + @columnname;
 --'Executing -- ALTER INDEX [' + RTRIM(@indexname) + '] ON [' + RTRIM(@tablename) + '] REBUILD WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, SORT_IN_TEMPDB = OFF, ONLINE = OFF ) -- fragmentation currently ' + RTRIM(CONVERT(VARCHAR(15),@frag)) + '%';

--SELECT @execstr = 'ALTER INDEX [' + RTRIM(@indexname) + '] ON [' + RTRIM(@tablename) + '] REBUILD WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, SORT_IN_TEMPDB = OFF, ONLINE = OFF )';

--insert into _ColumnDistinctCountAndStats (TableObjectName,TableObjectId,ColumnObjectName,ColumnObjectId,Columnxtype)
--values (@tablename, @tableobjectid, @columnname, @columnobjectid, @columnxtype);

SELECT @execstr = 'select ''' + @tablename + ''', ''' + @columnname + ''', count(distinct(' + @columnname + ')) from ' + @tablename;

--ALTER INDEX [' + RTRIM(@indexname) + '] ON [' + RTRIM(@tablename) + '] REBUILD WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, SORT_IN_TEMPDB = OFF, ONLINE = OFF )';

--EXEC  @distinctcount = EXEC (@execstr);

--insert into _ColumnDistinctCountAndStats (TableObjectName,TableObjectId,ColumnObjectName,ColumnObjectId,Columnxtype,ColumnDistinctRowCount)
--values (@tablename, @tableobjectid, @columnname, @columnobjectid, @columnxtype,@distinctcount);

EXEC (@execstr);


FETCH NEXT
FROM indexes
INTO @tablename, @tableobjectid, @columnname, @columnobjectid, @columnxtype;
END;

/* Close and deallocate the cursor.*/
CLOSE indexes;
DEALLOCATE indexes;

/* Delete the temporary table.*/
DROP TABLE #collist;



END
GO
