/****** Object:  StoredProcedure [dbo].[USP_PES_BOL_CONTAINER]    Script Date: 01/03/2013 19:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_PES_BOL_CONTAINER] AS
BEGIN

-- [aa] - 11/28/2010
-- Log start time
DECLARE @IdLogOut int, @DbName varchar(100), @SprocName varchar(100), @ParametersIn varchar(MAX)
SELECT @DbName = @@SERVERNAME + '; ' + DB_NAME(), @SprocName = OBJECT_NAME(@@PROCID)
,@ParametersIn = NULL
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsStart
 @DbName = @DbName ,@SprocName = @SprocName ,@Parameters = @ParametersIn ,@IdLog = @IdLogOut OUT


DECLARE @TRANNAME VARCHAR(20),@FILE VARCHAR(500),@FILE_NAME VARCHAR(50)
DECLARE @CMD VARCHAR(1000),@ERROR_MESSAGE VARCHAR(1000),
@ERROR_NUMBER VARCHAR(50),@ERROR_LINE VARCHAR(50),@DATE DATETIME,@TIME INT
SET @TRANNAME = 'MyTransaction'
SELECT @FILE = PATH FROM PES_CONFIGURATION WHERE SOURCE='SP_LOG'
SELECT @FILE_NAME= FILENAME FROM PES_PROGRESS_STATUS WHERE LOADNUMBER=(SELECT TOP 1 LOAD_NUMBER FROM RAW_BOL)
SET @FILE='"'+@FILE+@FILE_NAME+'_LOG.TXT'+'"'

SET @CMD = 'ECHO PROCEDURE BOL_CONTIANER EXECUTION STARTED' + '>>'+ @FILE
EXEC MASTER..XP_CMDSHELL @CMD 

DECLARE @LOADNUMBER NUMERIC(12,0),@BOL_ID INT, 
@CNTR_NBR VARCHAR (14),@VOYAGE_ID INT,@CNTR_MOVEMENT_CNT INT, 
@BOL_CNTRZD_FLG CHAR(1)

BEGIN TRANSACTION @TRANNAME

BEGIN TRY
;
--/*
--Begin Norman 12/03/2010
--PART 1 - Update Existing Containers
with tmp_allcntr as (
select ltrim(rtrim(rc.container)) ContainerNumber,
dbo.ufn_ValidateContainerNumberWithISO6346(ltrim(rtrim(rc.container))) IsISO6346,
case when dbo.ufn_ValidateContainerType(isnull(rc.Container_Type,''))=1
	then rc.Container_Type
	else NULL
	end ContainerType,
dbo.ufn_ValidateContainerType(isnull(rc.Container_Type,'')) IsContainerTypeValid,
case when reflen.Feet is not null
	then reflen.Feet
when isnull(rc.Container_Length,'') in ('02000','04000','04500','04800','05300')
	then substring(rc.Container_Length,2,2)
when isnull(rc.Consize,'') in ('20','40','45','48','53')
	then cast(rc.Consize as int)
	else null
	end ContainerLength,
case when reflen.Feet is not null
	then 'RawContainerType'
when isnull(rc.Container_Length,'') in ('02000','04000','04500','04800','05300')
	then 'RawContainerLength'
when isnull(rc.Consize,'') in ('20','40','45','48','53')
	then 'RawConsize'
	else null
	end ContainerLengthSource,
case when reflen.Feet is not null
	then 1
when isnull(rc.Container_Length,'') in ('02000','04000','04500','04800','05300')
	then 2
when isnull(rc.Consize,'') in ('20','40','45','48','53')
	then 3
	else 4
	end ContainerLengthPriority
from raw_cntr rc
  left outer join pes.dbo.ref_container_length reflen  WITH (NOLOCK) 
    on substring(isnull(rc.Container_Type,'0'),1,1)=reflen.ISOContainerTypeKey and
		dbo.ufn_ValidateContainerType(isnull(rc.Container_Type,''))=1
),
tmp_ranked as
(
select row_number() over (partition by ContainerNumber order by ContainerLengthPriority) Rank,*
from tmp_allcntr
)
--Update existing Containers
update y
set y.ContainerType=
		case when y.IsContainerTypeValid=0 and x.IsContainerTypeValid=1
			then x.ContainerType
			else y.ContainerType
		end,
	y.IsContainerTypeValid=
		case when y.IsContainerTypeValid=0 and x.IsContainerTypeValid=1
			then x.IsContainerTypeValid
			else y.IsContainerTypeValid
		end,
	y.ContainerLength=
		case when y.IsContainerTypeValid=0 and x.IsContainerTypeValid=1
			then x.ContainerLength
		when y.ContainerLength is null
			then x.ContainerLength
			else y.ContainerLength
		end,
	y.ContainerLengthSource=
		case when y.IsContainerTypeValid=0 and x.IsContainerTypeValid=1
			then x.ContainerLengthSource
		when y.ContainerLength is null
			then x.ContainerLengthSource
			else y.ContainerLengthSource
		end,
	y.ModifiedDate=getdate(),
	y.ModifiedBy='PES'
from tmp_ranked x
  join  dbo.REF_CONTAINER_ISO y
    on x.ContainerNumber=y.ContainerNumber and x.ContainerLength is not null and
		 y.IsContainerTypeValid=0 and (x.IsContainerTypeValid=1 or y.ContainerLength is null)
where x.Rank=1;

---PART 2 - Insert New Containers
with tmp_allcntr as (
select ltrim(rtrim(rc.container)) ContainerNumber,
dbo.ufn_ValidateContainerNumberWithISO6346(ltrim(rtrim(rc.container))) IsISO6346,
case when dbo.ufn_ValidateContainerType(isnull(rc.Container_Type,''))=1
	then rc.Container_Type
	else NULL
	end ContainerType,
dbo.ufn_ValidateContainerType(isnull(rc.Container_Type,'')) IsContainerTypeValid,
case when reflen.Feet is not null
	then reflen.Feet
when isnull(rc.Container_Length,'') in ('02000','04000','04500','04800','05300')
	then substring(rc.Container_Length,2,2)
when isnull(rc.Consize,'') in ('20','40','45','48','53')
	then cast(rc.Consize as int)
	else null
	end ContainerLength,
case when reflen.Feet is not null
	then 'RawContainerType'
when isnull(rc.Container_Length,'') in ('02000','04000','04500','04800','05300')
	then 'RawContainerLength'
when isnull(rc.Consize,'') in ('20','40','45','48','53')
	then 'RawConsize'
	else null
	end ContainerLengthSource,
case when reflen.Feet is not null
	then 1
when isnull(rc.Container_Length,'') in ('02000','04000','04500','04800','05300')
	then 2
when isnull(rc.Consize,'') in ('20','40','45','48','53')
	then 3
	else 4
	end ContainerLengthPriority
from raw_cntr rc
  left outer join pes.dbo.ref_container_length reflen  WITH (NOLOCK) 
    on substring(isnull(rc.Container_Type,'0'),1,1)=reflen.ISOContainerTypeKey and
		dbo.ufn_ValidateContainerType(isnull(rc.Container_Type,''))=1
),
tmp_ranked as
(
select row_number() over (partition by ContainerNumber order by ContainerLengthPriority) Rank,*
from tmp_allcntr
)
insert into dbo.REF_CONTAINER_ISO (
	ContainerNumber,
	IsISO6346,
	ContainerType,
	IsContainerTypeValid,
	ContainerLength,
	ContainerLengthSource,
	CreatedDate,
	CreatedBy)
select 
	ContainerNumber,
	IsISO6346,
	ContainerType,
	IsContainerTypeValid,
	ContainerLength,
	ContainerLengthSource,
	getdate() CreatedDate,
	'PES' CreatedBy
from tmp_ranked x
where x.Rank=1 and not exists (
		select 1 from dbo.REF_CONTAINER_ISO y
		where x.ContainerNumber=y.ContainerNumber);

--End Norman 12/03/2010
--*/

	SET @DATE=GETDATE()
	SELECT TOP 1 @LOADNUMBER =LOAD_NUMBER FROM RAW_BOL

	-- CONQTY FOR FEEDS OTHER THAN MMS OR MES
	UPDATE PES_STG_BOL SET CONQTY = T.CNT,BOL_CNTR_CNT=T.CNT FROM
	(SELECT COUNT(DISTINCT CONTAINER) AS CNT,BOL_ID FROM RAW_CNTR WHERE LTRIM(RTRIM(CONTAINER))!='NC' GROUP BY BOL_ID)T,
	PES_STG_BOL A WHERE A.BOL_ID = T.BOL_ID AND A.REF_VENDOR_CODE NOT IN('MMS','MES')

	

--MODIFIED BY Prabhav on 8TH JUNE 2009
--======================================================================================================================================================================================================
	-- CONQTY FOR FEEDS MMS OR MES

--	UPDATE PES_STG_BOL SET CONQTY=
--	(50+CHARINDEX('SIZE:',M.MAN_DESC))-(50+CHARINDEX('QUANTITY: ',M.MAN_DESC)+10)-1 FROM RAW_MAN M WHERE CHARINDEX('SIZE:',M.MAN_DESC)<>0 AND CHARINDEX('QUANTITY: ',M.MAN_DESC)<>0 AND PES_STG_BOL.BOL_ID=M.BOL_ID AND PES_STG_BOL.REF_VENDOR_CODE IN ('MMS','MES')

	UPDATE PES_STG_BOL SET CONQTY=
	CAST(LTRIM(RTRIM(SUBSTRING(MAN_DESC,CHARINDEX('QUANTITY: ',MAN_DESC)+ 10,
	CHARINDEX('SIZE:',M.MAN_DESC) - CHARINDEX('QUANTITY: ',MAN_DESC)- 10))) AS NUMERIC(12,0)),
	BOL_CNTR_CNT=CAST(LTRIM(RTRIM(SUBSTRING(MAN_DESC,CHARINDEX('QUANTITY: ',MAN_DESC)+ 10,
	CHARINDEX('SIZE:',M.MAN_DESC) - CHARINDEX('QUANTITY: ',MAN_DESC)- 10))) AS NUMERIC(12,0))
	FROM RAW_MAN M ,PES_STG_BOL
	WHERE 
	CHARINDEX('SIZE:',M.MAN_DESC)<>0 AND 
	CHARINDEX('QUANTITY: ',M.MAN_DESC)<>0 
	AND PES_STG_BOL.BOL_ID=M.BOL_ID 
	AND PES_STG_BOL.REF_VENDOR_CODE IN ('MMS','MES')  
--======================================================================================================================================================================================================


	--CONQTY WHEN CONQTY NOT GREATER THAN 0 FOR MMS OR MES
	UPDATE PES_STG_BOL SET CONQTY=0,BOL_CNTR_CNT=0 WHERE CONQTY IS NULL AND REF_VENDOR_CODE IN('MMS','MES') AND REF_LOAD_NUM_ID=@LOADNUMBER
		
	-- TO SET CONTAINERIZED_SHIPMENT_FLAG
	UPDATE PES_STG_BOL SET BOL_CNTRZD_FLG='N' FROM RAW_CNTR B WHERE PES_STG_BOL.BOL_ID=B.BOL_ID AND 
	(B.CONTAINER IN ('BREAK','BULK','BBUL','NA','NC','ONDECK','RORO') OR 
	B.CONTAINER='ON ' OR B.CONTAINER LIKE 'NC[0-9]' OR B.CONTAINER='NC ' OR B.CONTAINER='NC  NC'
    OR B.CONTAINER LIKE '%BULK%' OR B.CONTAINER LIKE '%RORO%' OR B.CONTAINER LIKE '%BREAK%'
    OR B.CONTAINER LIKE '%ONDECK%')

	--Set CONTAINERZIED_SHIPMENT_FLAG to 'N' when no container available
		UPDATE A SET A.BOL_CNTRZD_FLG='N' FROM PES_STG_BOL A, RAW_BOL B WHERE A.BOL_ID=B.BOL_ID
	    AND A.BOL_ID NOT IN(SELECT DISTINCT BOL_ID FROM RAW_CNTR)
		AND A.REF_VENDOR_CODE NOT IN('MMS','MES')  


	-- CONFLAG FOR FEEDS OTHER THAN MMS OR MES
	UPDATE PES_STG_BOL SET CONFLAG=
	CASE WHEN BOL_CNTRZD_FLG='Y' THEN 'C' ELSE '' END
	WHERE REF_LOAD_NUM_ID = @LOADNUMBER AND REF_VENDOR_CODE NOT IN('MMS','MES')

	
	--CONQTY WHEN CONFLAG IS NOT EQUAL TO C FOR FEED OTHER THAN MMS OR MES
	UPDATE PES_STG_BOL SET CONQTY=0,BOL_CNTR_CNT=0 WHERE CONFLAG<>'C' AND REF_LOAD_NUM_ID=@LOADNUMBER AND REF_VENDOR_CODE NOT IN('MMS','MES')

	-- CONFLAG FOR FEEDS MMS OR MES
	UPDATE PES_STG_BOL SET CONFLAG=
	CASE WHEN CONQTY>0 THEN 'C' 
	ELSE '' END,
	BOL_CNTRZD_FLG=
	CASE WHEN CONQTY>0 THEN 'Y' 
	ELSE 'N' END 
	WHERE REF_LOAD_NUM_ID=@LOADNUMBER AND REF_VENDOR_CODE IN('MMS','MES')

		 
	-- CONLENGTH for AMS
	UPDATE PES_STG_BOL SET 
	CONLENGTH = CONTAINER_LENGTH FROM PES_STG_BOL A, RAW_CNTR B
	WHERE A.BOL_ID NOT IN (
								SELECT BOL_ID FROM (SELECT BOL_ID,COUNT(DISTINCT CONTAINER_LENGTH) AS CNT								FROM RAW_CNTR GROUP BY BOL_ID)A WHERE A.CNT>1) 
	AND A.BOL_ID = B.BOL_ID AND CONTAINER_LENGTH != ' ' AND A.REF_VENDOR_CODE='AMS'

	-- CONLENGTH FOR OTHER FEEDS IS BLANK AND SO NO ANY SETTING IS DONE

	
	UPDATE PES_STG_BOL SET CONLENGTH =NULL WHERE CONLENGTH =' ' AND REF_LOAD_NUM_ID = @LOADNUMBER

	-- CONTAINER_WIDTH
	UPDATE PES_STG_BOL SET CONWIDTH = CONTAINER_WIDTH FROM PES_STG_BOL A, RAW_CNTR B
	WHERE A.BOL_ID NOT IN (
	SELECT BOL_ID FROM (SELECT BOL_ID,COUNT(DISTINCT CONTAINER_WIDTH) AS CNT FROM RAW_CNTR GROUP BY BOL_ID)A
	WHERE A.CNT>1) AND
	A.BOL_ID = B.BOL_ID AND CONTAINER_WIDTH!=' ' AND A.REF_VENDOR_CODE='AMS'

	-- CONWIDTH FOR OTHER FEEDS IS BLANK AND SO NO ANY SETTING IS DONE

	UPDATE PES_STG_BOL SET CONWIDTH=NULL WHERE CONWIDTH=' ' AND REF_LOAD_NUM_ID = @LOADNUMBER

	-- CONTAINER_TYPE
	UPDATE PES_STG_BOL SET CONTYPE = CONTAINER_TYPE FROM PES_STG_BOL A, RAW_CNTR B
	WHERE A.BOL_ID NOT IN (
	SELECT BOL_ID FROM (SELECT BOL_ID,COUNT(DISTINCT CONTAINER_TYPE) AS CNT FROM RAW_CNTR GROUP BY BOL_ID)A
	WHERE A.CNT>1) AND
	A.BOL_ID = B.BOL_ID AND CONTAINER_TYPE!=' ' AND REF_VENDOR_CODE='AMS'

	-- CONTYPE FOR OTHER FEEDS IS BLANK AND SO NO ANY SETTING IS DONE

	UPDATE PES_STG_BOL SET CONTYPE=NULL WHERE CONTYPE=' ' AND REF_LOAD_NUM_ID = @LOADNUMBER

	-- CONSIZE FOR AMS
	UPDATE PES_STG_BOL SET CONSIZE = CASE
	WHEN CONTAINER_LENGTH LIKE '045%' THEN '45'
	WHEN CONTAINER_LENGTH LIKE '040%' THEN '40'
	WHEN CONTAINER_LENGTH LIKE '020%' THEN '20'
	WHEN CONTAINER_LENGTH LIKE '053%' THEN '53'
	WHEN CONTAINER_LENGTH LIKE '048%' THEN '48'
	ELSE
	'ZZ'
	END
	FROM RAW_CNTR A,PES_STG_BOL B WHERE 
	A.BOL_ID = B.BOL_ID AND B.REF_VENDOR_CODE='AMS'

	UPDATE PES_STG_BOL SET CONSIZE='ZZ' WHERE BOL_ID IN 
	(SELECT BOL_ID FROM (SELECT BOL_ID,COUNT(DISTINCT CONTAINER_LENGTH) AS CNT FROM RAW_CNTR GROUP BY BOL_ID)A
	WHERE A.CNT>1) AND PES_STG_BOL.REF_VENDOR_CODE='AMS' 

	--CONSIZE FOR FEEDS OTHER THAN AMS, MES, AND MMS 

	UPDATE PES_STG_BOL SET CONSIZE = CASE
	WHEN A.CONSIZE='45' THEN '45'
	WHEN A.CONSIZE='40' THEN '40'
	WHEN A.CONSIZE='20' THEN '20'
	WHEN A.CONSIZE='53' THEN '53'
	WHEN A.CONSIZE='48' THEN '48'
	ELSE
	'ZZ'
	END
	FROM RAW_CNTR A,PES_STG_BOL B WHERE 
	A.BOL_ID = B.BOL_ID AND B.REF_VENDOR_CODE NOT IN('AMS','MES','MMS')	

	UPDATE PES_STG_BOL SET CONSIZE='ZZ' WHERE BOL_ID IN 
	(SELECT BOL_ID FROM (SELECT BOL_ID,COUNT(DISTINCT CONSIZE) AS CNT FROM RAW_CNTR GROUP BY BOL_ID)A
	WHERE A.CNT>1) AND PES_STG_BOL.REF_VENDOR_CODE NOT IN('AMS','MES','MMS')	

	--CONSIZE WHEN CONFLAG IS NOT EQUAL TO 'C' FOR FEED OTHER THAN MMS AND MES
	UPDATE PES_STG_BOL SET CONSIZE='' WHERE CONFLAG<>'C' AND PES_STG_BOL.REF_LOAD_NUM_ID=@LOADNUMBER AND REF_VENDOR_CODE NOT IN('MES','MMS')

	--CONSIZE FOR MMS AND MES
	UPDATE PES_STG_BOL SET CONSIZE=
	(CASE ISNULL(LTRIM(RTRIM(SUBSTRING(M.MAN_DESC,CHARINDEX('SIZE: ',M.MAN_DESC)+6,2))),'') WHEN ''
	THEN 'ZZ'
	ELSE UPPER(SUBSTRING(M.MAN_DESC,CHARINDEX('SIZE: ',M.MAN_DESC)+6,2)) END) 
	FROM RAW_MAN M 
	WHERE M.BOL_ID=PES_STG_BOL.BOL_ID AND CHARINDEX('SIZE: ',M.MAN_DESC)<>0 
	AND PES_STG_BOL.REF_VENDOR_CODE IN('MMS','MES')

	UPDATE PES_STG_BOL SET CONSIZE='' WHERE (CONQTY=0 OR CONQTY IS NULL) AND REF_VENDOR_CODE IN('MMS','MES')
	AND REF_LOAD_NUM_ID=@LOADNUMBER

	-- CONVOL FOR AMS
	UPDATE PES_STG_BOL SET CONVOL=0 WHERE SCAC IN ('OOLU','ZIMU') AND REF_LOAD_NUM_ID = @LOADNUMBER AND REF_VENDOR_CODE='AMS'

	--CONVOL FOR ALL FEEDS
	UPDATE B SET B.CONVOL =  
	CASE 
	WHEN ROUND((A.MEAS*35.314),0) IN (35,1) OR ROUND((A.MEAS*35.314),0) IS NULL THEN 0
	WHEN A.MEAS_UNITS IN('CF','SS','FF') THEN A.MEAS  
	ELSE ROUND((A.MEAS*35.314),0) END
	FROM RAW_BOL A,PES_STG_BOL B WHERE
	A.BOL_ID=B.BOL_ID


--UPDATE PES_STG_BOL SET Container Fields Nulls If Bill is Not containerized

	UPDATE A  SET
	CONQTY=0,BOL_CNTR_CNT=0,CONFLAG='',CONLENGTH=NULL,CONWIDTH=NULL,CONSIZE='',CONTYPE=NULL
	FROM PES_STG_BOL A WHERE A.REF_LOAD_NUM_ID=@LOADNUMBER AND A.BOL_CNTRZD_FLG='N'  


SET @CMD = 'ECHO PROCEDURE LCL_FLAG EXECUTION STARTED' + '>>'+ @FILE
EXEC MASTER..XP_CMDSHELL @CMD 



--POPULATE LCL_FLAG AND CONSIZE AS LC

	UPDATE A  
		SET CONSIZE='LC', 
		BOL_LCL_FLAG='Y' 
	FROM PES_STG_BOL A JOIN PES_STG_CNTR B 
	ON A.BOL_ID=B.BOL_ID
	WHERE A.REF_LOAD_NUM_ID=@LOADNUMBER 
	AND A.STND_VOYG_ID IS NOT NULL 	
	AND BOL_CNTRZD_FLG = 'Y'
	AND dbo.pes_udf_GetContainerCountforLC(A.BOL_ID,B.CNTR_NBR,A.STND_VOYG_ID,A.BOL_CNTRZD_FLG) > 1

	SET @CMD = 'ECHO LCL_FLAG POPULATION FINISHED' + '>>'+ @FILE
	EXEC MASTER..XP_CMDSHELL @CMD 

--UPDATE CONFLAG AND CONQUANTITY AT BILL LEVEL
UPDATE PES_STG_BOL SET CONQTY=0, CONFLAG='C' WHERE CONSIZE='LC' AND REF_LOAD_NUM_ID=@LOADNUMBER

	--/*
	--Begin Norman 12/14/2010
	;
	--Get Container Statistics
	with tmp_load as (
	select top 1 load_number
	from raw_bol  WITH (NOLOCK) 
	)
	,tmp_bol_count as (
	select count(*) bol_count from raw_bol  WITH (NOLOCK) 
	)
	,tmp_zzcount as (
	select count(*) zzcount
	from pes_stg_bol a  WITH (NOLOCK) 
	  join raw_bol b  WITH (NOLOCK) 
	    on a.bol_id=b.bol_id and a.consize='ZZ'
	)
	,tmp_zzconsize as (
	select a.bol_id,count(*) cnt
	from raw_cntr  A WITH (NOLOCK)
	  join pes_stg_bol  B WITH (NOLOCK)
	    on a.bol_id=b.bol_id
	where b.consize='ZZ'
	group by a.bol_id
	)
	,tmp_updatecount as (
	select count(*) updatecount
	from pes_stg_bol a
	  join tmp_zzconsize b
	    on a.bol_id=b.bol_id
	  join raw_cntr c  WITH (NOLOCK) 
	    on a.bol_id=c.bol_id
	  join ref_container_iso d  WITH (NOLOCK) 
	    on c.container=d.ContainerNumber
			--and d.IsISO6346=1
			and d.ContainerLength is not null
			and d.ContainerLength in (20,40,45,48,53)
	where b.cnt=1
	)
	,tmp_consizecnt as (
	select a.bol_id,c.ContainerLength,count(*) consizecnt
	from tmp_zzconsize a
	  join raw_cntr b  WITH (NOLOCK) 
	    on a.bol_id=b.bol_id
	  join ref_container_iso c  WITH (NOLOCK) 
	    on b.container=c.ContainerNumber
	where a.cnt<>1
	group by a.bol_id,c.ContainerLength
	)
	,tmp_groupedbol as (
	select a.bol_id,count(*) cnt
	from tmp_consizecnt a
	group by a.bol_id
	)
	,tmp_multiupdcount as (
	select count(*) multiupdcount
	from  pes_stg_bol a
	  join tmp_groupedbol b
	    on a.bol_id=b.bol_id
	  join tmp_consizecnt c
	    on b.bol_id=c.bol_id
			and b.cnt=1
			and c.ContainerLength is not null
			and c.ContainerLength in (20,40,45,48,53)
	)
	,tmp_onecont as (
	select a.bol_id,count(*) cnt
	from pes_stg_bol a  WITH (NOLOCK) 
	  join raw_cntr b  WITH (NOLOCK) 
	    on a.bol_id=b.bol_id
	where a.consize='ZZ' and a.conflag='C'
	group by a.bol_id
	having count(*)=1
	)
    ,tmp_yycount as (
    select count(*) yycount
	from pes_stg_bol a
	  join tmp_onecont b
	    on a.bol_id=b.bol_id
	where a.consize='ZZ'
	)
	insert into Container_Size_Stats 
		(Load_Number,BOL_Count,ZZ_Count,Update_Count,MultiUpdate_Count,YY_Count)
	select load_number,bol_count,zzcount,updatecount,multiupdcount,yycount
	from tmp_load,tmp_bol_count,tmp_zzcount,tmp_updatecount,tmp_multiupdcount,tmp_yycount;

	--Single Container - COnsize Update
	with tmp_zzconsize as (
	select a.bol_id,count(*) cnt
	from raw_cntr  A WITH (NOLOCK)
	  join pes_stg_bol  B WITH (NOLOCK)
	    on a.bol_id=b.bol_id
	where b.consize='ZZ'
	group by a.bol_id
	)
	update a set a.consize=d.ContainerLength
	from pes_stg_bol a
	  join tmp_zzconsize b
	    on a.bol_id=b.bol_id
	  join raw_cntr c  WITH (NOLOCK) 
	    on a.bol_id=c.bol_id
	  join ref_container_iso d  WITH (NOLOCK) 
	    on c.container=d.ContainerNumber
			--and d.IsISO6346=1  
			and d.ContainerLength is not null
			and d.ContainerLength in (20,40,45,48,53)
	where b.cnt=1;

	--End Norman 12/14/2010
	--*/

	--/*
	--Begin Norman 12/16/2010

	--Multiple Containers
	with tmp_zzconsize as (
	select a.bol_id,count(*) cnt
	from raw_cntr  A WITH (NOLOCK)
	  join pes_stg_bol  B WITH (NOLOCK)
	    on a.bol_id=b.bol_id
	where b.consize='ZZ'
	group by a.bol_id
	)
	,tmp_consizecnt as (
	select a.bol_id,c.ContainerLength,count(*) consizecnt
	from tmp_zzconsize a
	  join raw_cntr b  WITH (NOLOCK) 
	    on a.bol_id=b.bol_id
	  join ref_container_iso c  WITH (NOLOCK) 
	    on b.container=c.ContainerNumber
	where a.cnt<>1
	group by a.bol_id,c.ContainerLength
	)
	,tmp_groupedbol as (
	select a.bol_id,count(*) cnt
	from tmp_consizecnt a
	group by a.bol_id
	)
	update a set a.consize=c.ContainerLength
	from  pes_stg_bol a
	  join tmp_groupedbol b
	    on a.bol_id=b.bol_id
	  join tmp_consizecnt c
	    on b.bol_id=c.bol_id
			and b.cnt=1
			and c.ContainerLength is not null
			and c.ContainerLength in (20,40,45,48,53);

	/* Norman 1/25/2011 - Disabled the YY update
	--Update single BOL consize to YY for single containers
	with tmp_onecont as (
	select a.bol_id,count(*) cnt
	from pes_stg_bol a  WITH (NOLOCK) 
	  join raw_cntr b  WITH (NOLOCK) 
	    on a.bol_id=b.bol_id
	where a.consize='ZZ' and a.conflag='C'
	group by a.bol_id
	having count(*)=1
	)
	update a set a.consize='YY'
	from pes_stg_bol a
	  join tmp_onecont b
	    on a.bol_id=b.bol_id
	where a.consize='ZZ';
	*/

	--End Norman 12/16/2010
	--*/
	

	/* Norman 1/25/2011 - Disabled the YY update (This is added in the stats insert)
	-- Added - JG - 01/14/2011

	UPDATE Container_Size_Stats SET Container_Size_Stats.YY_Count = 
	(
		SELECT    COUNT(*) AS YY_Count
		FROM         RAW_BOL INNER JOIN
					 PES_STG_BOL ON RAW_BOL.BOL_ID = PES_STG_BOL.BOL_ID
		WHERE     (PES_STG_BOL.CONSIZE = 'YY') AND RAW_BOL.LOAD_NUMBER=@LOADNUMBER
	)
	WHERE Container_Size_Stats.LOAD_NUMBER = @LOADNUMBER;

	-- End - JG - 01/14/2011
	*/

--COMMITTING THE TRANSACTIONS IF NO ERROR OCCURRED
	COMMIT TRANSACTION @TRANNAME

SET @TIME= DATEDIFF(N,GETDATE(),@DATE)
	SET @cmd = 'ECHO PROCEDURE BOL_CONTIANER EXECUTED SUCCESSFULLY'+ CAST(@TIME AS VARCHAR(20)) + ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD

END TRY

BEGIN CATCH
	SET @ERROR_NUMBER=ERROR_NUMBER()
	SET @ERROR_LINE=ERROR_LINE()
	SET @ERROR_MESSAGE='STORED PROCEDURE BOL_CONTIANER FAILED AT LINE NUMBER:  ' + @ERROR_LINE + ' WITH ERROR DESCRIPTION:  '+ERROR_MESSAGE()
	
	SET @CMD = 'ECHO ERROR_MESSAGE-- '+@ERROR_MESSAGE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
    SET @CMD = 'ECHO ERROR_NUMBER-- '+@ERROR_NUMBER+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	SET @CMD = 'ECHO ERROR_LINE-- '+@ERROR_LINE+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	
	
	SET @CMD = 'ECHO TRANSACTIONS ROLLBACKED'+ ' >> '+ @FILE
	EXEC master..xp_cmdshell @CMD 
	RAISERROR(@ERROR_MESSAGE,21,1) WITH LOG

	ROLLBACK TRANSACTION @TRANNAME
END CATCH

	
	


-- [aa] - 11/28/2010
-- Log end time
EXEC SCREEN_TEST.dbo.usp_LogSProcCallsEnd
 @Id = @IdLogOut ,@RowsAffected = @@ROWCOUNT

END
GO
