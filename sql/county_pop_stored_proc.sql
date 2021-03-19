ALTER PROCEDURE county_population_data @FIPS VARCHAR(5) = NULL, @Population INT, @County VARCHAR(30) = NULL, @State CHAR(25) = NULL
AS

DECLARE @ActualFIPS CHAR(5)

IF LEN(@FIPS) = 4
    SET @ActualFIPS = CONVERT(CHAR(5), '0' + @FIPS)
ELSE IF @FIPS <> NULL
    SET @ActualFIPS = CONVERT(CHAR(5), @FIPS)
ELSE 
    SET @ActualFIPS = (
        SELECT FIPSCode
        FROM countyInfo c
        JOIN state s on s.stateAbbrev = c.stateAbbrev
        WHERE s.stateName = @State AND c.countyName = @County
    )

IF @Population < (SELECT totalPopulation FROM countyDemographics WHERE FIPSCode = @ActualFIPS)
    SET @Population = (SELECT totalPopulation FROM countyDemographics WHERE FIPSCode = @ActualFIPS)

IF @ActualFIPS IN (SELECT FIPSCode FROM countyInfo)
    IF @ActualFIPS IN (SELECT FIPSCode FROM countyDemographics)
        UPDATE countyDemographics
        SET totalPopulation = @Population
        WHERE FIPSCode = @ActualFIPS
    ELSE
        INSERT INTO countyDemographics (
            FIPSCode,
            totalPopulation
        ) VALUES (
            @ActualFIPS,
            @Population
        )
GO