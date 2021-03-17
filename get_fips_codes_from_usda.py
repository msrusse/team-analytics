#! /usr/python

import requests, json, os, csv, pyodbc, time
from dotenv import load_dotenv
from tqdm import tqdm
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup as BS

server = '%s,%s' % (os.getenv('database_url'), os.getenv('database_port'))
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;DATABASE=%s;UID=%s;PWD=%s' % (server, os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password')))

def get_usda_html():
    r = requests.get('https://www.nrcs.usda.gov/wps/portal/nrcs/detail/national/home/?cid=nrcs143_013697')
    soup = BS(r.content, 'lxml')
    table_body = soup.find('tbody')
    return table_body

def convert_fips_table(table_body):
    rows_list = []
    for row in table_body.findAll('tr')[1:]:
        columns = row.findAll('td')
        rows_list.append([columns[0].text, columns[1].text, columns[2].text])
    data_array = np.array(rows_list)
    df = pd.DataFrame(data_array, columns = ['FIPS', 'county', 'state'])
    #df.to_csv('data/fips_codes.csv', sep=',', index=False)
    cursor = cnxn.cursor()
    for index, row in tqdm(df.iterrows()):
        sql = """\
            EXEC fips_codes_data
            @FIPS=?,
            @County=?,
            @StateAbbrev=?
            """
        params = (row.FIPS, row.county, row.state)
        retry_count = 0
        retry_flag = True
        while retry_flag:
            try:
                cursor.execute(sql, params)
                retry_flag = False
            except Exception as e:
                retry_count += 1
                if retry_count == 5:
                    exit('Exiting with error: %s' % e)
                time.sleep(1)
    cnxn.commit()
    cursor.close()

def main():
    usda_table_body = get_usda_html()
    convert_fips_table(usda_table_body)

if __name__ == '__main__':
    main()