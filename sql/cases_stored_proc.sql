ALTER PROCEDURE case_info_data @FIPS VARCHAR(5), @Date DATE, @TotalCases INT
AS

DECLARE @ActualFIPS CHAR(5)
    
IF LEN(@FIPS) = 4
    SET @ActualFIPS = CONVERT(CHAR(5), '0' + @FIPS)

ELSE
    SET @ActualFIPS = CONVERT(CHAR(5), @FIPS)

IF @Date IN (SELECT recordedDate FROM caseInfo WHERE FIPSCode = @ActualFIPS)
    UPDATE caseInfo
    SET totalToDate = @TotalCases, amountChange = @TotalCases - (
            SELECT totalToDate
            FROM caseInfo
            WHERE FIPSCode = @ActualFIPS AND recordedDate = DATEADD(DAY, -1, @Date)
        )
    WHERE FIPSCode = @ActualFIPS AND recordedDate = @Date
ELSE
    INSERT INTO caseInfo (
        FIPSCode,
        recordedDate,
        totalToDate,
        amountChange
    )
    VALUES (
        @ActualFIPS,
        @Date,
        @TotalCases,
        @TotalCases - (
            SELECT totalToDate
            FROM caseInfo
            WHERE FIPSCode = @ActualFIPS AND recordedDate = DATEADD(DAY, -1, @Date)
        )
    )
GO