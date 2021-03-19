#! /usr/python

import os, pyodbc, time
from dotenv import load_dotenv
from tqdm import tqdm
import pandas as pd
import numpy as np

def getICUBedsData():
    df = pd.read_csv('data/us_icu_beds_by_county.csv', delimiter=',')
    df = df[['State', 'County', 'ICU Beds']]
    df.rename(columns={'State' : 'state', 'County' : 'county', 'ICU Beds' : 'icu_beds'}, inplace=True)
    return df

def callICUBedsStoredProc(df):
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=%s;DATABASE=%s;UID=%s;PWD=%s' % (os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))
    cursor = cnxn.cursor()
    for index, row in tqdm(df.iterrows()):
        sql = """\
            EXEC icu_beds_data @StateName = ?, @County = ?, @ICUBeds = ?
            """
        cursor.execute(sql, row.state, row.county, row.icu_beds)
    cnxn.commit()
    cursor.close()
    cnxn.close()

def main():
    df = getICUBedsData()
    callICUBedsStoredProc(df)

if __name__ == '__main__':
    main()