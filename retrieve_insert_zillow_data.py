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

def getCasesData():
    url = 'https://files.zillowstatic.com/research/public_v2/zhvi/County_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_mon.csv'
    df = pd.read_csv(url)
    df = df.where(pd.notnull(df), 'NULL')
    county_df = df[['SizeRank', 'Metro', 'StateCodeFIPS', 'MunicipalCodeFIPS']].copy()
    df.drop(columns=['RegionID', 'RegionName', 'StateName', 'RegionType', 'State', 'SizeRank', 'Metro'], inplace=True)
    date_columns = list(df.columns[2:])
    df = df.melt(id_vars=['StateCodeFIPS', 'MunicipalCodeFIPS'], value_vars=date_columns)
    df.rename(columns={'variable' : 'date', 'value': 'medianPrice'}, inplace=True)
    return (df, county_df)

def callZillowCountyInfo(county_df):
    server = '%s,%s' % (os.getenv('database_url'), os.getenv('database_port'))
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;DATABASE=%s;UID=%s;PWD=%s' % (server, os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))
    cursor = cnxn.cursor()
    for index, row in tqdm(county_df.iterrows(), total=len(county_df.index)):
        sql = """\
            EXEC zillow_county_info
            @StateFIPSCode=?,
            @CountyFIPSCode=?,
            @SizeRank=?,
            @Metro=?
            """
        cursor.execute(sql, row.StateCodeFIPS, row.MunicipalCodeFIPS, row.SizeRank, row.Metro)
    cnxn.commit()
    cursor.close()
    cnxn.close()

def writeZillowHomeValueToSQL(df):
    df_array = df.values
    current_sql_file = 1
    split_arrays = np.array_split(df_array, 100)
    for array in tqdm(split_arrays, total=len(split_arrays)):
        with open('sql/zillow_data/zillow_data_%s.sql' % current_sql_file, 'w') as sql_file:
            for row in array:
                sql_file.write('EXEC zillow_home_data @StateFIPSCode=\'%s\', @CountyFIPSCode=\'%s\', @Date=\'%s\', @Price=%s;\n' % (row[0], row[1], row[2], row[3]))
        current_sql_file += 1

def runSQLScripts():
    os.chdir('sql/zillow_data/')
    for file_name in tqdm(glob.glob('*.sql')):
        os.system('sqlcmd -U %s -P %s -S %s,%s -d %s -i "%s" -o "%s_output.txt"' % (os.getenv('database_username'), os.getenv('database_password'), os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), file_name, file_name))

def main():
    dfs = getCasesData()
    callZillowCountyInfo(dfs[1])
    writeZillowHomeValueToSQL(dfs[0])
    runSQLScripts()

if __name__ == '__main__':
    main()