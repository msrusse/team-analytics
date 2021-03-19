ALTER PROCEDURE icu_beds_data @StateName VARCHAR(25), @County VARCHAR(30), @ICUBeds INT
AS

DECLARE @ActualFIPS CHAR(5)

SET @ActualFIPS = (SELECT FIPSCode FROM countyInfo ci
                    JOIN state s ON s.stateAbbrev = ci.stateAbbrev
                    WHERE countyName LIKE @County
                    AND stateName LIKE @StateName)

IF @ActualFIPS IN (SELECT FIPSCode FROM icuBeds)
    UPDATE icuBeds
    SET icuBedCount = @ICUBeds
    WHERE FIPSCode = @ActualFIPS
ELSE 
    INSERT INTO icuBeds (
        FIPSCode,
        icuBedCount
    ) VALUES (
        @ActualFIPS,
        @ICUBeds
    )