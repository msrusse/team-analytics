ALTER PROCEDURE zillow_home_data @StateFIPSCode VARCHAR(2), @CountyFIPSCode VARCHAR(3), @Date DATE, @Price INT
AS
DECLARE @ActualFIPS CHAR(5)

IF LEN(@StateFIPSCode) = 1
    SET @StateFIPSCode = '0' + @StateFIPSCode

IF LEN(@CountyFIPSCode) = 1
    SET @CountyFIPSCode = '00' + @CountyFIPSCode
ELSE IF LEN(@CountyFIPSCode) =2 
    SET @CountyFIPSCode = '0' + @CountyFIPSCode

SET @ActualFIPS = CONVERT(CHAR(5), @StateFIPSCode+@CountyFIPSCode)

IF @Date IN (SELECT priceRecordedDate FROM zillowHomeValues WHERE FIPSCode=@ActualFIPS)
    UPDATE zillowHomeValues
    SET medianHousingPrice = @Price
    WHERE FIPSCode = @ActualFIPS
    AND priceRecordedDate = @Date
ELSE 
    INSERT INTO zillowHomeValues
    VALUES (@ActualFIPS, @Date, @Price)
GO