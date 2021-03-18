#! /usr/python

import requests, json, os, csv, pyodbc, time, glob
from sys import argv
from datetime import datetime, timedelta
from tqdm import tqdm
from contextlib import closing
from dotenv import load_dotenv
from bs4 import BeautifulSoup as BS
import pandas as pd
import numpy as np

def getDeathsData():
    url = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv'
    df = pd.read_csv(url).dropna()
    df.drop(columns=['UID', 'iso2', 'iso3', 'code3', 'Admin2', 'Province_State', 'Country_Region', 'Lat', 'Long_', 'Combined_Key'], inplace=True)
    pop_df = df[['FIPS', 'Population']].copy()
    date_columns = list(df.columns[3:])
    df = df.melt(id_vars=['FIPS'], value_vars=date_columns)
    df.rename(columns={'variable' : 'date', 'value': 'total'}, inplace=True)
    return (df, pop_df)

def writeResultToSQL(cases_df):
    df_array = cases_df.values
    current_sql_file = 1
    split_arrays = np.array_split(df_array, 75)
    for array in tqdm(split_arrays, total=len(split_arrays)):
        with open('sql/death_data/preload_death_data_%s.sql' % current_sql_file, 'w') as sql_file:
            for row in array:
                sql_file.write('EXEC death_info_data @FIPS=\'%s\', @Date=\'%s\', @TotalDeaths=%s;\n' % (int(row[0]), row[1], row[2]))
        current_sql_file += 1

def runSQLScripts():
    os.chdir('sql/death_data/')
    for file_name in tqdm(glob.glob('*.sql')):
        os.system('sqlcmd -U %s -P %s -S %s,%s -d %s -i "%s" -o "%s_output.txt"' % (os.getenv('database_username'), os.getenv('database_password'), os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), file_name, file_name))

def updateLastFiveDays(deaths_df):
    five_days_ago = (datetime.today() - timedelta(days=2))
    deaths_df['date'] = pd.to_datetime(deaths_df.date)
    filtered_cases_df = deaths_df.loc[(deaths_df.date >= five_days_ago)]
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=%s;DATABASE=%s;UID=%s;PWD=%s' % (os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))
    cursor = cnxn.cursor()
    for index, row in tqdm(filtered_cases_df.iterrows()):
        sql = 'EXEC death_info_data @FIPS=?, @Date=?, @TotalDeaths=?'
        cursor.execute(sql, row.FIPS, row.date, row.total)
    cnxn.commit()
    cursor.close()
    cnxn.close()

def updatePopulationData(pop_df):
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=%s;DATABASE=%s;UID=%s;PWD=%s' % (os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))
    cursor = cnxn.cursor()
    for index, row in tqdm(pop_df.iterrows()):
        sql = 'EXEC county_population_data @FIPS=?, @Population=?'
        cursor.execute(sql, row.FIPS, row.Population)
    cnxn.commit()
    cursor.close()
    cnxn.close()

def main(args):
    cond = False
    if len(args) >= 2:
        cond = bool(args[1])
    dfs = getDeathsData()
    if cond:
        writeResultToSQL(dfs[0])
        runSQLScripts()
    updateLastFiveDays(dfs[0])
    updatePopulationData(dfs[1])

if __name__ == '__main__':
    main(argv)