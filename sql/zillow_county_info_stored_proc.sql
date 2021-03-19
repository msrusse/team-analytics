CREATE PROCEDURE zillow_county_info @StateFIPSCode VARCHAR(2), @CountyFIPSCode VARCHAR(3), @SizeRank INT, @Metro VARCHAR(75)
AS

DECLARE @ActualFIPS CHAR(5)

IF LEN(@StateFIPSCode) = 1
    SET @StateFIPSCode = '0' + @StateFIPSCode

IF LEN(@CountyFIPSCode) = 1
    SET @CountyFIPSCode = '00' + @CountyFIPSCode
ELSE IF LEN(@CountyFIPSCode) =2 
    SET @CountyFIPSCode = '0' + @CountyFIPSCode

SET @ActualFIPS = CONVERT(CHAR(5), @StateFIPSCode+@CountyFIPSCode)

IF @ActualFIPS IN (SELECT FIPSCode FROM countyInfo)
    UPDATE countyInfo
    SET sizeRank = @SizeRank+1,
        metroAreaName = @Metro
    WHERE FIPSCode = @ActualFIPS
GO