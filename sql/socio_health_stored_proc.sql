ALTER PROCEDURE socio_health_data @FIPS VARCHAR(5), @Area DECIMAL, @ViolentCrimeRate DECIMAL, @PercentUnder18 DECIMAL, @PercentOver65 DECIMAL, @PercentBlack DECIMAL, 
                                    @PercentAmericanIndianAlaskaNative DECIMAL, @PercentAsian DECIMAL, @PercentNativeHawaiianPacificIslander DECIMAL, @PercentHispanic DECIMAL, 
                                    @PercentNonHispanicWhite DECIMAL, @PercentFemale DECIMAL, @PercentNoVehicle DECIMAL, @HighSchoolGraduationRate DECIMAL, @PercentSomeCollege DECIMAL, 
                                    @PercentUnemployedCHR DECIMAL, @PercentDriveAloneToWork DECIMAL, @MedianHouseholdIncome DECIMAL, @PerCapitaIncome DECIMAL, @PercentBelowPoverty DECIMAL, 
                                    @PercentUnemployedCDC DECIMAL, @PercentFairOrPoorHealth DECIMAL, @AverageNumberPhysicallyUnhealthyDays DECIMAL, @AverageNumberMentallyUnhealthyDays DECIMAL, 
                                    @PercentLowBirthweight DECIMAL, @PercentSmokers DECIMAL, @PercentObeseAdults DECIMAL, @PercentPhysicallyInactive DECIMAL, @PercentWithExercieOpportunities DECIMAL, 
                                    @PercentExcessiveDrinking DECIMAL, @ChlamydiaRate DECIMAL, @TeenBirthRate DECIMAL, @PercentUninsured DECIMAL, @PrimaryCarePhysiciansRate DECIMAL, 
                                    @PreventableHospitalizationRate DECIMAL, @PercentVaccinated DECIMAL, @LifeExpectancy DECIMAL, @PercentAdultsWithDiabetes DECIMAL, @PercentInsufficientSleep DECIMAL, 
                                    @PercentDisabled DECIMAL, @PercentChildrenInPoverty DECIMAL, @PercentSingleParentHouseholdsCHR DECIMAL, @PercentHomeowners DECIMAL, @PercentRural DECIMAL, 
                                    @PercentMultiUnitHousing DECIMAL, @PercentOvercrowding DECIMAL, @WaterViolationPresent DECIMAL, @PercentFoodInsecure DECIMAL, @PercentHealthyFoodsLimitedAccess DECIMAL
AS
 DECLARE @ActualFIPS CHAR(5)

 IF LEN(@FIPS) = 4
    SET @ActualFIPS = CONVERT(CHAR(5), '0' + @FIPS)
ELSE
    SET @ActualFIPS = CONVERT(CHAR(5), @FIPS)

-- INSERT/UPDATE countyInfo
IF @ActualFIPS IN (SELECT FIPSCode FROM countyInfo)
    UPDATE countyInfo
    SET area = @Area
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyInfo (
        FIPSCode,
        area
    ) VALUES (
        @ActualFIPS,
        @Area
    )

-- INSERT/UPDATE countyDemographics
IF @ActualFIPS IN (SELECT FIPSCode FROM countyDemographics)
    UPDATE countyDemographics
    SET violentCrimeRate = @ViolentCrimeRate,
        percentUnder18 = @PercentUnder18,
        percentOver65 = @PercentOver65,
        percentBlack = @PercentBlack,
        percentAmericanIndianAlaskanNative = @PercentAmericanIndianAlaskaNative,
        percentAsian = @PercentAsian,
        percentNativeHawaiianOtherPacificIslander = @PercentNativeHawaiianPacificIslander,
        percentHispanic = @PercentHispanic,
        percentNonHispanicWhite = @PercentNonHispanicWhite,
        percentFemale = @PercentFemale,
        PercentNoVehicle = @PercentNoVehicle
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyDemographics (
        FIPSCode,
        violentCrimeRate,
        percentUnder18,
        percentOver65,
        percentBlack,
        percentAmericanIndianAlaskanNative,
        percentAsian,
        percentNativeHawaiianOtherPacificIslander,
        percentHispanic,
        percentNonHispanicWhite,
        percentFemale,
        PercentNoVehicle
    ) VALUES (
        @ActualFIPS,
        @ViolentCrimeRate,
        @PercentUnder18,
        @PercentOver65,
        @PercentBlack,
        @PercentAmericanIndianAlaskaNative,
        @PercentAsian,
        @PercentNativeHawaiianPacificIslander,
        @PercentHispanic,
        @PercentNonHispanicWhite,
        @PercentFemale,
        @PercentNoVehicle
    )

-- INSERT/UPDATE countyEducation
IF @ActualFIPS IN (SELECT FIPSCode FROM countyEducation)
    UPDATE countyEducation
    SET highSchoolGraduationRate = @HighSchoolGraduationRate,
        percentSomeCollege = @PercentSomeCollege
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyEducation (
        FIPSCode,
        highSchoolGraduationRate,
        percentSomeCollege
    ) VALUES (
        @ActualFIPS,
        @HighSchoolGraduationRate,
        @PercentSomeCollege
    )

-- INSERT/UPDATE countyEmployment
IF @ActualFIPS IN (SELECT FIPSCode FROM countyEmployment)
    UPDATE countyEmployment
    SET percentUnemployedCHR = @PercentUnemployedCHR,
        percentDriveAloneToWork = @PercentDriveAloneToWork,
        medianHouseholdIncome = @MedianHouseholdIncome,
        perCapitaIncome = @PerCapitaIncome,
        percentBelowPoverty = @PercentBelowPoverty,
        percentUnemployedCDC = @PercentUnemployedCDC
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyEmployment (
        FIPSCode,
        percentUnemployedCHR,
        percentDriveAloneToWork,
        medianHouseholdIncome,
        perCapitaIncome,
        percentBelowPoverty,
        percentUnemployedCDC
    ) VALUES (
        @ActualFIPS,
        @PercentUnemployedCHR,
        @PercentDriveAloneToWork,
        @MedianHouseholdIncome,
        @PerCapitaIncome,
        @PercentBelowPoverty,
        @PercentUnemployedCDC
    )

-- INSERT/UPDATE countyHealth
IF @ActualFIPS IN (SELECT FIPSCode FROM countyHealth)
    UPDATE countyHealth
    SET percentFairPoorHealth = @PercentFairOrPoorHealth,
        averagePhysicallyUnhealthyDays = @AverageNumberPhysicallyUnhealthyDays,
        averageMentallyUnhealthyDays = @AverageNumberMentallyUnhealthyDays,
        percentLowBirthweight = @PercentLowBirthweight,
        percentSmokers = @PercentSmokers,
        percentAdultsObese = @PercentObeseAdults,
        percentPhysicallyInactive = @PercentPhysicallyInactive,
        percentExerciseAccessOpportunities = @PercentWithExercieOpportunities,
        percentExcessiveDrinking = @PercentExcessiveDrinking,
        chlamydiaRate = @ChlamydiaRate,
        teenBirthRate = @TeenBirthRate,
        percentUninsured = @PercentUninsured,
        primaryCarePhysiciansRate = @PrimaryCarePhysiciansRate,
        preventableHospitalizationRate = @PreventableHospitalizationRate,
        percentVaccinated = @PercentVaccinated,
        lifeExpectancy = @LifeExpectancy,
        percentDiabeticAdults = @PercentAdultsWithDiabetes,
        percentInsufficientSleep = @PercentInsufficientSleep,
        percentDisabled = @PercentDisabled
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyHealth (
        FIPSCode,
        percentFairPoorHealth,
        averagePhysicallyUnhealthyDays,
        averageMentallyUnhealthyDays,
        percentLowBirthweight,
        percentSmokers,
        percentAdultsObese,
        percentPhysicallyInactive,
        percentExerciseAccessOpportunities,
        percentExcessiveDrinking,
        chlamydiaRate,
        teenBirthRate,
        percentUninsured,
        primaryCarePhysiciansRate,
        preventableHospitalizationRate,
        percentVaccinated,
        lifeExpectancy,
        percentDiabeticAdults,
        percentInsufficientSleep,
        percentDisabled
    ) VALUES (
        @ActualFIPS,
        @PercentFairOrPoorHealth,
        @AverageNumberPhysicallyUnhealthyDays,
        @AverageNumberMentallyUnhealthyDays,
        @PercentLowBirthweight,
        @PercentSmokers,
        @PercentObeseAdults,
        @PercentPhysicallyInactive,
        @PercentWithExercieOpportunities,
        @PercentExcessiveDrinking,
        @ChlamydiaRate,
        @TeenBirthRate,
        @PercentUninsured,
        @PrimaryCarePhysiciansRate,
        @PreventableHospitalizationRate,
        @PercentVaccinated,
        @LifeExpectancy,
        @PercentAdultsWithDiabetes,
        @PercentInsufficientSleep,
        @PercentDisabled
    )

-- INSERT/UPDATE countyHousing
IF @ActualFIPS IN (SELECT FIPSCode FROM countyHousing)
    UPDATE countyHousing
    SET percentChildrenInPoverty = @PercentChildrenInPoverty,
        percentSingleParentHouseholdsCHR = @PercentSingleParentHouseholdsCHR,
        percentHomeowners = @PercentHomeowners,
        percentRural = @PercentRural,
        percentMultiUnitHousing = @PercentMultiUnitHousing,
        percentOvercrowding = @PercentOvercrowding
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyHousing (
        FIPSCode,
        percentChildrenInPoverty,
        percentSingleParentHouseholdsCHR,
        percentHomeowners,
        percentRural,
        percentMultiUnitHousing,
        percentOvercrowding
    ) VALUES (
        @ActualFIPS,
        @PercentChildrenInPoverty,
        @PercentSingleParentHouseholdsCHR,
        @PercentHomeowners,
        @PercentRural,
        @PercentMultiUnitHousing,
        @PercentOvercrowding
    )

-- INSERT/UPDATE countyNutrition
IF @ActualFIPS IN (SELECT FIPSCode FROM countyNutrition)
    UPDATE countyNutrition
    SET waterViolationPresence = @WaterViolationPresent,
        percentFoodInsecure = @PercentFoodInsecure,
        percentHealthyFoodsLimitedAccess = @PercentHealthyFoodsLimitedAccess
    WHERE FIPSCode = @ActualFIPS
ELSE
    INSERT INTO countyNutrition (
        FIPSCode,
        waterViolationPresence,
        percentFoodInsecure,
        percentHealthyFoodsLimitedAccess
    ) VALUES (
        @ActualFIPS,
        @WaterViolationPresent,
        @PercentFoodInsecure,
        @PercentHealthyFoodsLimitedAccess
    )