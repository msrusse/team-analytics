#! /usr/python

import os, pyodbc, time
from dotenv import load_dotenv
from tqdm import tqdm
import pandas as pd
import numpy as np

def getSocioHealthData():
    df = pd.read_csv('data/us_county_sociohealth_data.csv', delimiter=',', index_col=0)
    df = df[['area_sqmi', 
            'violent_crime_rate',
            'percent_65_and_over', 
            'percent_less_than_18_years_of_age', 
            'percent_black', 
            'percent_american_indian_alaska_native', 
            'percent_asian',
            'percent_native_hawaiian_other_pacific_islander',
            'percent_hispanic',
            'percent_non_hispanic_white',
            'percent_female',
            'percent_no_vehicle',
            'high_school_graduation_rate',
            'percent_some_college',
            'percent_unemployed_CHR',
            'percent_drive_alone_to_work',
            'median_household_income',
            'per_capita_income',
            'percent_below_poverty',
            'percent_unemployed_CDC',
            'percent_fair_or_poor_health',
            'average_number_of_physically_unhealthy_days',
            'average_number_of_mentally_unhealthy_days',
            'percent_low_birthweight',
            'percent_smokers',
            'percent_adults_with_obesity',
            'percent_physically_inactive',
            'percent_with_access_to_exercise_opportunities',
            'percent_excessive_drinking',
            'chlamydia_rate',
            'teen_birth_rate',
            'percent_uninsured',
            'primary_care_physicians_rate',
            'preventable_hospitalization_rate',
            'percent_vaccinated',
            'life_expectancy',
            'percent_adults_with_diabetes',
            'percent_insufficient_sleep',
            'percent_disabled',
            'percent_children_in_poverty',
            'percent_single_parent_households_CHR',
            'percent_homeowners',
            'percent_rural',
            'percent_multi_unit_housing',
            'percent_overcrowding',
            'presence_of_water_violation',
            'percent_food_insecure',
            'percent_limited_access_to_healthy_foods']]
    df = df.where(pd.notnull(df), None)
    df = df.drop('KSC').drop('NYC')
    return df

def executeSocioHealth(socio_health_df):
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=%s;DATABASE=%s;UID=%s;PWD=%s' % (os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))
    cursor = cnxn.cursor()
    for index, row in tqdm(socio_health_df.iterrows()):
        sql = """\
                EXEC socio_health_data 
                @FIPS = ?, @Area = ?, 
                @ViolentCrimeRate = ?, @PercentUnder18 = ?, 
                @PercentOver65 = ?, @PercentBlack = ?,
                @PercentAmericanIndianAlaskaNative = ?, @PercentAsian = ?, 
                @PercentNativeHawaiianPacificIslander = ?, @PercentHispanic = ?, 
                @PercentNonHispanicWhite = ?, @PercentFemale = ?, 
                @PercentNoVehicle = ?, @HighSchoolGraduationRate = ?, 
                @PercentSomeCollege = ?, @PercentUnemployedCHR = ?, 
                @PercentDriveAloneToWork = ?, @MedianHouseholdIncome = ?, 
                @PerCapitaIncome = ?, @PercentBelowPoverty = ?, 
                @PercentUnemployedCDC = ?, @PercentFairOrPoorHealth = ?, 
                @AverageNumberPhysicallyUnhealthyDays = ?, @AverageNumberMentallyUnhealthyDays = ?, 
                @PercentLowBirthweight = ?, @PercentSmokers = ?, 
                @PercentObeseAdults = ?, @PercentPhysicallyInactive = ?, 
                @PercentWithExercieOpportunities = ?, @PercentExcessiveDrinking = ?, 
                @ChlamydiaRate = ?, @TeenBirthRate = ?, 
                @PercentUninsured = ?, @PrimaryCarePhysiciansRate = ?, 
                @PreventableHospitalizationRate = ?, @PercentVaccinated = ?, 
                @LifeExpectancy = ?, @PercentAdultsWithDiabetes = ?, 
                @PercentInsufficientSleep = ?, @PercentDisabled = ?, 
                @PercentChildrenInPoverty = ?, @PercentSingleParentHouseholdsCHR = ?, 
                @PercentHomeowners = ?, @PercentRural = ?, 
                @PercentMultiUnitHousing = ?, @PercentOvercrowding = ?, 
                @WaterViolationPresent = ?, @PercentFoodInsecure = ?, 
                @PercentHealthyFoodsLimitedAccess = ?\
            """
        cursor.execute(sql, index, row.area_sqmi, row.violent_crime_rate, row.percent_less_than_18_years_of_age,
                        row.percent_65_and_over, row.percent_black, row.percent_american_indian_alaska_native,
                        row.percent_asian, row.percent_native_hawaiian_other_pacific_islander, row.percent_hispanic,
                        row.percent_non_hispanic_white, row.percent_female, row.percent_no_vehicle, row.high_school_graduation_rate,
                        row.percent_some_college, row.percent_unemployed_CHR, row.percent_drive_alone_to_work,
                        row.median_household_income, row.per_capita_income, row.percent_below_poverty, row.percent_unemployed_CDC,
                        row.percent_fair_or_poor_health, row.average_number_of_physically_unhealthy_days, row.average_number_of_mentally_unhealthy_days,
                        row.percent_low_birthweight, row.percent_smokers, row.percent_adults_with_obesity, row.percent_physically_inactive,
                        row.percent_with_access_to_exercise_opportunities, row.percent_excessive_drinking, row.chlamydia_rate,
                        row.teen_birth_rate, row.percent_uninsured, row.primary_care_physicians_rate, row.preventable_hospitalization_rate,
                        row.percent_vaccinated, row.life_expectancy, row.percent_adults_with_diabetes, row.percent_insufficient_sleep,
                        row.percent_disabled, row.percent_children_in_poverty, row. percent_single_parent_households_CHR, row.percent_homeowners,
                        row.percent_rural, row.percent_multi_unit_housing, row.percent_overcrowding, row.presence_of_water_violation,
                        row.percent_food_insecure, row.percent_limited_access_to_healthy_foods)
    cnxn.commit()
    cursor.close()
    cnxn.close()

def main():
    socio_health_df = getSocioHealthData()
    executeSocioHealth(socio_health_df)

if __name__ == '__main__':
    main()