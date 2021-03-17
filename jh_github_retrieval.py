#! /usr/python

import requests, json, os, csv, pyodbc, time, glob
from sqlalchemy import create_engine
from tqdm import tqdm
from contextlib import closing
from dotenv import load_dotenv
from bs4 import BeautifulSoup as BS
import pandas as pd
import numpy as np

server = '%s,%s' % (os.getenv('database_url'), os.getenv('database_port'))
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;DATABASE=%s;UID=%s;PWD=%s' % (server, os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))
#conn_string = 'mssql://%s:%s@%s:%s/%s' % (os.getenv('database_username'), os.getenv('database_password'), os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'))
#engine = create_engine(conn_string)
#conn=engine.connect()

def get_github_hrefs():
    r=requests.get('https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series')
    soup = BS(r.content, 'lxml')
    git_table = soup.find('div', {'class' : 'Details-content--hidden-not-important js-navigation-container js-active-navigation-container d-block'})
    table_rows = git_table.findAll('a', href=True)
    return [(a.get('href').replace('/blob', ''), a.text) for a in table_rows if a.text[-4:] == '.csv' and '_US' in a.text]

def get_github_csvs(hrefs):
    for href in tqdm(hrefs):
        url = 'https://raw.githubusercontent.com/%s' % href[0].replace('/blob', '')
        df = pd.read_csv(url)
        df.drop(columns=['UID', 'iso2', 'iso3', 'code3', 'Country_Region', 'Lat', 'Long_', 'Combined_Key'], inplace=True)
        df.rename(columns={'Admin2' : 'county', 'Province_State' : 'state'}, inplace=True)
        if 'Population' in df.columns:
            pop_df = df[['FIPS', 'county', 'state', 'Population']].copy()
            pop_df.to_csv('data/county_population.csv', sep=',')
            df.drop(columns=['Population'], inplace=True)
        date_columns = list(df.columns[3:])
        df = df.melt(id_vars=['FIPS', 'county', 'state'], value_vars=date_columns).dropna()
        df.rename(columns={'variable' : 'date', 'value': 'total'}, inplace=True)
        df = df.drop(columns=['county', 'state'])
        df_array = df.values
        # for row in tqdm(df_array, total=len(df_array)):
        #     continue
        #     if 'confirmed' in href[1].lower():
        #         sql = """\
        #             EXEC case_info_data
        #             @FIPS=?,
        #             @Date=?,
        #             @TotalCases=?
        #             """
        #     else:
        #         sql = """\
        #             EXEC death_info_data
        #             @FIPS=?,
        #             @Date=?,
        #             @TotalDeaths=?
        #             """
        #     params = (row[0], row[3], row[4])
        #     retry_count = 0
        #     retry_flag = True
        #     while retry_flag:
        #         try:
        #             cursor.execute(sql, params)
        #             retry_flag = False
        #         except Exception as e:
        #             retry_count += 1
        #             if retry_count == 5:
        #                 exit('Exiting with error: %s' % e)
        #             time.sleep(1) 
        #         #df.to_csv('data/%s' % href[1], sep=',', index=False)
        # if 'confirmed' in href[1].lower():
        #     store_proc_statement = f'EXEC case_info_data @FIPS=?, @Date=?, @TotalCases=?'
        # else:
        #     store_proc_statement = f'EXEC death_info_date @FIPS=?, @Date=?, @TotalCases=?'
        # cursor = cnxn.cursor()
        # cursor.fast_executemany=True
        # for split_df in tqdm(np.array_split(df, 2000)):
        #     cursor.executemany(store_proc_statement, split_df.values.tolist())
        # cnxn.commit()
        # cursor.close()
        # cursor.callproc()

def getCasesData():
    url = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv'
    df = pd.read_csv(url).dropna()
    df.drop(columns=['UID', 'iso2', 'iso3', 'code3', 'Admin2', 'Province_State', 'Country_Region', 'Lat', 'Long_', 'Combined_Key'], inplace=True)
    date_columns = list(df.columns[3:])
    df = df.melt(id_vars=['FIPS'], value_vars=date_columns)
    df.rename(columns={'variable' : 'date', 'value': 'total'}, inplace=True)
    df_array = df.values
    current_sql_file = 1
    split_arrays = np.array_split(df_array, 75)
    for array in tqdm(split_arrays, total=len(split_arrays)):
        with open('sql/case_data/preload_case_data_%s.sql' % current_sql_file, 'w') as sql_file:
            for row in array:
                sql_file.write('EXEC case_info_data @FIPS=\'%s\', @Date=\'%s\', @TotalCases=%s;\n' % (int(row[0]), row[1], row[2]))
        current_sql_file += 1
    # cursor = cnxn.cursor()
    # for index, row in tqdm(df.iterrows(), total=len(df_array)):
    #     sql = """\
    #         EXEC case_info_data
    #         @FIPS=?,
    #         @Date=?,
    #         @TotalCases=?
    #         """
    #     cursor.execute(sql, row.FIPS, row.date, row.total)
    # cnxn.commit()
    # cursor.close()

def runSQLScripts():
    os.chdir('sql/case_data/')
    for file_name in tqdm(glob.glob('*.sql')):
        os.system('sqlcmd -U %s -P %s -S %s,%s -d %s -i "%s" -o "sql_load_output.txt"' % (os.getenv('database_username'), os.getenv('database_password'), os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), file_name))

def main():
    getCasesData()
    runSQLScripts()

if __name__ == '__main__':
    main()