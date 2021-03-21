#####################################
#----------Import Libraries---------#
#####################################

library(dbplyr)
library(pastecs)
library(psych)
library(dplyr)

setwd('C:\\Users\\ericl\\Desktop\\Desktop Storage\\OSU MSIS\\2021 Spring\\Programming for Data Science II\\Project\\Data Sets_2_13_2021\\US Counties Weather, Health, & COVID19 Data')
getwd()

# Import population data
totalPop = read.csv('us_county_sociohealth_data.csv', header=T)[,c('fips','total_population')]
colnames(totalPop)[1] = 'FIPSCode'
colnames(totalPop)[2] = 'totalPopulation'

#####################################
#----------Import Libraries---------#
#####################################

library(dotenv)
library(DBI)
setwd('C:\\Users\\ericl\\Desktop\\Desktop Storage\\OSU MSIS\\2021 Spring\\Programming for Data Science II\\Project\\ProjectCode\\team-analytics')
load_dot_env('.env')
db_conn_string = paste('Driver={SQL Server};server=', 
                       Sys.getenv('database_url'),
                       ';server=',
                       Sys.getenv('database_name'),
                       ';database=',
                       Sys.getenv('database_name'),
                       ';uid=',
                       Sys.getenv('database_username'),
                       ';pwd=',
                       Sys.getenv('database_password'), sep='')
con = dbConnect(odbc::odbc(), .connection_string = db_conn_string, timeout = 10)

# Store tables
candidate = dbReadTable(con, 'candidate')
caseinfo = dbReadTable(con, 'caseInfo')
demographics = dbReadTable(con, 'countyDemographics')
education = dbReadTable(con, 'countyEducation')
employment = dbReadTable(con, 'countyEmployment')
health = dbReadTable(con, 'countyHealth')
housing = dbReadTable(con, 'countyHousing')
countyinfo = dbReadTable(con, 'countyInfo')
nutrition = dbReadTable(con, 'countyNutrition')
deathinfo = dbReadTable(con, 'deathInfo')
election = dbReadTable(con, 'electionResult')
icubeds = dbReadTable(con, 'icuBeds')
party = dbReadTable(con, 'party')
state = dbReadTable(con, 'state')
zillow = dbReadTable(con, 'zillowHomeValues')

# Replace TRUE/FALSE with 1/0 in waterViolationPresence for stats
nutrition$waterViolationPresence[nutrition$waterViolationPresence == FALSE] = 0
nutrition$waterViolationPresence[nutrition$waterViolationPresence == TRUE] = 1

# Replace TRUE/FALSE with 1/0 in won for stats
election$won[election$won == FALSE] = 0
election$won[election$won == TRUE] = 1

# Replace totalPopulation with new data (temporary until column is corrected in db)
demographics = subset(demographics, select=-c(totalPopulation))
demographics = merge(demographics,totalPop, by = 'FIPSCode')

# Create summary table
des_stats = describe(candidate) %>%
        rbind(describe(caseinfo)) %>%
        rbind(describe(demographics)) %>%
        rbind(describe(education)) %>%
        rbind(describe(employment)) %>%
        rbind(describe(health)) %>%
        rbind(describe(housing)) %>%
        rbind(describe(countyinfo)) %>%
        rbind(describe(nutrition)) %>%
        rbind(describe(deathinfo)) %>%
        rbind(describe(election)) %>%
        rbind(describe(icubeds)) %>%
        rbind(describe(party)) %>%
        rbind(describe(state)) %>%
        rbind(describe(zillow))


# Get data types
str(candidate)
str(countyinfo)
str(demographics)
str(education)
str(employment)
str(health)
str(housing)
str(countyinfo)
str(nutrition)
str(deathinfo)
str(election)
str(icubeds)
str(party)
str(state)
str(zillow)


#####################################
#--------Histograms and Plots-------#
#####################################

##### Histograms

par(mfrow = c(2,1))

# County Pop

#hist(demographics$totalPopulation)

hist(demographics$totalPopulation, 
     main="Histogram for Population", 
     xlab="Population Counts", 
     border="blue", 
     col="green",
     xlim=c(0,500000),
     las=1, 
     breaks=200, 
     prob = TRUE)

lines(density(demographics$totalPopulation))



# ICU Beds

#hist(icubeds$icuBedCount)

hist(icubeds$icuBedCount, 
     main="Histogram for ICU Bed Count", 
     xlab="Bed Counts", 
     border="blue", 
     col="green",
     xlim = c(0,200),
     las=1, 
     breaks=100, 
     prob = TRUE)

lines(density(icubeds$icuBedCount))


# Deaths to date

# Create new df for target variables
to_date_deaths = deathinfo[deathinfo$recordedDate == '2021-03-01',] %>%
          subset(select=-c(amountChange, recordedDate))
colnames(to_date_deaths)[2] = 'deathsToDate'
to_date_cases = caseinfo[caseinfo$recordedDate == '2021-03-01',] %>%
           subset(select=-c(amountChange, recordedDate))
colnames(to_date_cases)[2] = 'totalToDate'
to_date = merge(to_date_deaths, to_date_cases, by = 'FIPSCode')
to_date = merge(to_date, totalPop, by = 'FIPSCode')



##### Plots

# Create target variables
to_date_plot = subset(to_date, select=-c(FIPSCode))
to_date_plot$casesPerCapita = to_date_plot$totalToDate/to_date_plot$totalPopulation
to_date_plot$deathRate = (to_date_plot$deathsToDate/to_date_plot$totalPopulation)/to_date_plot$casesPerCapita
# NaN is produced when dividing by 0. The death rate truely is 0 when there are no deaths.
to_date_plot$deathRate[is.nan(to_date_plot$deathRate)] = 0

plot(to_date_plot, panel=panel.smooth)

#to_date_percap = subset(to_date_plot, select=c(casesPerCapita))
#to_date_rate = subset(to_date_plot, select=c(deathRate))
#boxplot(to_date_percap)
#boxplot(to_date_rate)

par(mfrow = c(1,1))

to_date_box1 = subset(to_date_plot, select=c(casesPerCapita,deathRate))
boxplot(to_date_box1, main = 'Boxplot of Target Variables')

# To be added to Descriptive Stats
des_stats = describe(subset(to_date_plot, select=c(casesPerCapita,deathRate))) %>%
        rbind(des_stats)

# Write table to CSV
write.csv(des_stats,'C:\\Users\\ericl\\Desktop\\Desktop Storage\\OSU MSIS\\2021 Spring\\Programming for Data Science II\\Project\\Other\\des_stats_export.csv',row.names = TRUE)



par(mfrow = c(2,1))

# Histogram for target variables

# casesPerCapita
hist(to_date_plot$casesPerCapita, 
     main="Histogram for Cases Per Capita", 
     xlab="Population Counts", 
     border="blue", 
     col="green",
     las=1, 
     breaks=100, 
     prob = TRUE)

lines(density(to_date_plot$casesPerCapita))


# deathRate
hist(na.omit(to_date_plot$deathRate), 
     main="Histogram for Death Rate", 
     xlab="Population Counts", 
     border="blue", 
     col="green",
     las=1, 
     breaks=100, 
     prob = TRUE)

lines(density(na.omit(to_date_plot$deathRate)))


# QQ Plots
par(mfrow = c(2,1))

# casesPerCapita
qqnorm(to_date_plot$casesPerCapita, main = 'Normal Q-Q Plot: Cases Per Capita')
qqline(to_date_plot$casesPerCapita, lty=2)

# deathRate
qqnorm(to_date_plot$deathRate, main = 'Normal Q-Q Plot: Death Rate')
qqline(to_date_plot$casesPerCapita, lty=2)


# Shapiro Test

shapiro.test(to_date_plot$deathRate)
shapiro.test(to_date_plot$casesPerCapita)

