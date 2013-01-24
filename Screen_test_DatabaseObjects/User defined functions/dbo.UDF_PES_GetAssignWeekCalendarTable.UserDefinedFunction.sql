/****** Object:  UserDefinedFunction [dbo].[UDF_PES_GetAssignWeekCalendarTable]    Script Date: 01/03/2013 19:53:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UDF_PES_GetAssignWeekCalendarTable]()
RETURNS @TBL TABLE (CAL_DATE SMALLDATETIME, DISPLAY VARCHAR(20),  CALENDARDAY VARCHAR(10), VALUE VARCHAR(10))
AS
BEGIN
DECLARE @P_STARTYEAR SMALLINT, @P_ENDYEAR SMALLINT, @P_STARTMONTH SMALLINT, @P_ENDMONTH SMALLINT
    -- 2 --
	SELECT  @P_STARTYEAR = MIN(DATEPART(YYYY,VDATE)),
	@P_ENDYEAR = MAX(DATEPART(YYYY,VDATE)),
    @P_STARTMONTH = DATEPART(MM,MIN(VDATE)),
    @P_ENDMONTH = DATEPART(MM,MAX(VDATE))
	FROM DQA_BL WITH (NOLOCK) WHERE VDATE IS NOT NULL ORDER BY 1

	DECLARE @P_START_DATE SMALLDATETIME
	DECLARE @P_END_DATE SMALLDATETIME
    SET @P_START_DATE = CONVERT(SMALLDATETIME, 
						CONVERT(VARCHAR(4),@P_STARTYEAR) + RIGHT('00' + CAST((@P_STARTMONTH) AS VARCHAR(2)), 2) +'01')

	SET @P_END_DATE = CONVERT(SMALLDATETIME,
						CONVERT(VARCHAR(4),@P_ENDYEAR) +RIGHT('00' + CAST((@P_ENDMONTH) AS VARCHAR(2)), 2) + '01')
	SET @P_END_DATE = DATEADD(DD,-1,(DATEADD(MM,1,@P_END_DATE)))
    -- 3 --
    INSERT INTO @TBL
    SELECT DATE,CALENDARDATE,CALENDARDAY,VALUE
      FROM (SELECT 

			@P_START_DATE +
			   N4.NUM * 1000 +
               N3.NUM * 100 +
               N2.NUM * 10 +
               N1.NUM AS DATE,
			CONVERT(VARCHAR(20),@P_START_DATE +
               N4.NUM * 1000 +
               N3.NUM * 100 +
               N2.NUM * 10 +
               N1.NUM,106) AS CALENDARDATE,
			DATENAME(DW,@P_START_DATE +
			   N4.NUM * 1000 +
               N3.NUM * 100 +
               N2.NUM * 10 +
               N1.NUM) AS CALENDARDAY,
			CONVERT(VARCHAR(20),@P_START_DATE +
               N4.NUM * 1000 +
               N3.NUM * 100 +
               N2.NUM * 10 +
               N1.NUM,101) AS VALUE

              FROM (SELECT 0 AS NUM UNION ALL
                    SELECT 1 UNION ALL
                    SELECT 2 UNION ALL
                    SELECT 3 UNION ALL
                    SELECT 4 UNION ALL
                    SELECT 5 UNION ALL
                    SELECT 6 UNION ALL
                    SELECT 7 UNION ALL
                    SELECT 8 UNION ALL
                    SELECT 9) N1
                  ,(SELECT 0 AS NUM UNION ALL
                    SELECT 1 UNION ALL
                    SELECT 2 UNION ALL
                    SELECT 3 UNION ALL
                    SELECT 4 UNION ALL
                    SELECT 5 UNION ALL
                    SELECT 6 UNION ALL
                    SELECT 7 UNION ALL
                    SELECT 8 UNION ALL
                    SELECT 9) N2
                  ,(SELECT 0 AS NUM UNION ALL
                    SELECT 1 UNION ALL
                    SELECT 2 UNION ALL
                    SELECT 3 UNION ALL
                    SELECT 4 UNION ALL
                    SELECT 5 UNION ALL
                    SELECT 6 UNION ALL
                    SELECT 7 UNION ALL
                    SELECT 8 UNION ALL
                    SELECT 9) N3
				   ,(SELECT 0 AS NUM UNION ALL
                    SELECT 1 UNION ALL
                    SELECT 2 UNION ALL
                    SELECT 3 UNION ALL
                    SELECT 4 UNION ALL
                    SELECT 5 UNION ALL
                    SELECT 6 UNION ALL
                    SELECT 7 UNION ALL
                    SELECT 8 UNION ALL
                    SELECT 9) N4
                  ) GENCALENDAR

	WHERE (CALENDARDAY = 'SUNDAY') 
	AND CALENDARDATE <= @P_END_DATE
     ORDER BY 1 DESC

    RETURN
END
GO
