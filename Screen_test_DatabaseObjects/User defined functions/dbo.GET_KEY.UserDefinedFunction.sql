USE [SCREEN_TEST]
GO
/****** Object:  UserDefinedFunction [dbo].[GET_KEY]    Script Date: 01/03/2013 19:53:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GET_KEY](@STRIN VARCHAR(1000))
RETURNS VARCHAR(1000) AS
BEGIN
            DECLARE @TABSTR TABLE (STR1 VARCHAR(100),VAR1 INT);
            DECLARE @CNT NUMERIC,
            @I  INT,
            @J INT,
            @CNT1 NUMERIC,
            @POS NUMERIC,
            @PARTSTR VARCHAR(1000),
            @LEN NUMERIC,
            @STROUT VARCHAR(1000),
            @TMPSTR VARCHAR(1000),
            @TMPSTR1 VARCHAR(1000),
            @TMPSTR2 VARCHAR(1000);
            SET @PARTSTR = @STRIN;
            SET @PARTSTR = REPLACE(@PARTSTR,'''',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'+',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'.',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'\',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'/',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,',',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,';',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'-',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'"',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,':',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'(',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,')',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'   ',' ');
            SET @PARTSTR = REPLACE(@PARTSTR,'  ',' ');
            SET @I = 1;
                  WHILE(@I<100)
                  BEGIN
                        IF ( CHARINDEX (' ',@PARTSTR) > 0 ) 
                              BEGIN
                                    SET @TMPSTR = LTRIM(RTRIM(SUBSTRING(@PARTSTR,1,CHARINDEX(' ',@PARTSTR))));
                                    INSERT @TABSTR(STR1,VAR1) VALUES (@TMPSTR,@I)
                                    SET @PARTSTR = SUBSTRING(@PARTSTR,CHARINDEX(' ',@PARTSTR)+1,LEN(@PARTSTR));    
                              END
                        ELSE
                              BEGIN
                                    SET @PARTSTR = LTRIM(RTRIM(@PARTSTR))
                                    INSERT @TABSTR(STR1,VAR1) VALUES (@PARTSTR,@I)
                                    BREAK
                              END
                        SET @I = @I+1;
                  END;
            SET @J = 1;
            SELECT @CNT = COUNT(*) FROM @TABSTR 
            SET @STROUT = '';
            WHILE(@J<=@CNT)
            BEGIN
                  SELECT @LEN = LEN(STR1) FROM @TABSTR WHERE VAR1=@J;
                  SELECT @TMPSTR1 = RIGHT(STR1,1) FROM @TABSTR WHERE VAR1=@J;
            IF (  (@LEN > 3) AND  (@TMPSTR1 = 'S' ) ) 
                  BEGIN
                        SELECT @TMPSTR2 = SUBSTRING(STR1,1,LEN(STR1)-1) FROM @TABSTR WHERE VAR1=@J;
                        SET @STROUT = @STROUT + @TMPSTR2
                        SET @STROUT = LTRIM(RTRIM(@STROUT))
                  END
                  ELSE
                  BEGIN
                        SELECT @TMPSTR2 = STR1 FROM @TABSTR WHERE VAR1=@J;
                        SET @STROUT = @STROUT + LTRIM(RTRIM(@TMPSTR2))
                  END
            SET @J = @J+1;
            END;
            RETURN LTRIM(RTRIM(@STROUT));
END;
GO
