ALTER PROCEDURE fips_codes_data @FIPS VARCHAR(5), @County VARCHAR(30), @StateAbbrev CHAR(2) = NULL, @StateName VARCHAR(25) = NULL
AS
DECLARE
    @StateFIPS CHAR(2),
    @CountyFIPS CHAR(3),
    @ActualFIPS CHAR(5)

IF LEN(@FIPS) = 4
    SET @ActualFIPS = CONVERT(CHAR(5), '0' + @FIPS)
ELSE
    SET @ActualFIPS = CONVERT(CHAR(5), @FIPS)

SET @StateFIPS = LEFT(@ActualFIPS, 2)
SET @CountyFIPS = RIGHT(@ActualFIPS, 3)

IF @StateAbbrev IS NULL
    SET @StateAbbrev = (SELECT stateAbbrev FROM [state] WHERE stateName = @StateName)

IF @ActualFIPS IN (SELECT FIPSCode FROM countyInfo)
    UPDATE countyInfo
    SET stateFIPS = @StateFIPS,
        countyFIPS = @CountyFIPS,
        stateAbbrev = @StateAbbrev,
        countyName = @County
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyInfo (
        FIPSCode,
        stateFIPS,
        countyFIPS,
        countyName,
        stateAbbrev
    ) VALUES (
        @ActualFIPS,
        @StateFIPS,
        @CountyFIPS,
        @County,
        @StateAbbrev
    )
GO