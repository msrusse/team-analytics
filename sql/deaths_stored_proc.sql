ALTER PROCEDURE death_info_data @FIPS VARCHAR(5), @Date DATE, @TotalDeaths INT
AS

DECLARE @ActualFIPS CHAR(5)
    
IF LEN(@FIPS) = 4
    SET @ActualFIPS = CONVERT(CHAR(5), '0' + @FIPS)
ELSE
    SET @ActualFIPS = CONVERT(CHAR(5), @FIPS)

IF @ActualFIPS IN (SELECT FIPSCode FROM countyInfo)
    IF @Date IN (SELECT recordedDate FROM deathInfo WHERE FIPSCode = @ActualFIPS)
        UPDATE deathInfo
        SET totalToDate = @TotalDeaths, amountChange = @TotalDeaths - ISNULL((
                SELECT totalToDate
                FROM caseInfo
                WHERE FIPSCode = @ActualFIPS AND recordedDate = DATEADD(DAY, -1, @Date)
            ),0)
        WHERE FIPSCode = @ActualFIPS AND recordedDate = @Date
    ELSE
        INSERT INTO deathInfo (
            FIPSCode,
            recordedDate,
            totalToDate,
            amountChange
        )
        VALUES (
            @ActualFIPS,
            @Date,
            @TotalDeaths,
            @TotalDeaths - ISNULL((
                SELECT totalToDate
                FROM caseInfo
                WHERE FIPSCode = @ActualFIPS AND recordedDate = DATEADD(DAY, -1, @Date)
            ),0)
        )
GO