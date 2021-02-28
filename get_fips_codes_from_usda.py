#! /usr/python

import requests, json, os, csv
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup as BS

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
    df.to_csv('data/fips_codes.csv', sep=',', index=False)

def main():
    usda_table_body = get_usda_html()
    convert_fips_table(usda_table_body)

if __name__ == '__main__':
    main()