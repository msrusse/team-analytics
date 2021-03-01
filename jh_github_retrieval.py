#! /usr/python

import requests, json, os, csv
from contextlib import closing
from bs4 import BeautifulSoup as BS
import pandas as pd
import numpy as np

def get_github_hrefs():
    r=requests.get('https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series')
    soup = BS(r.content, 'lxml')
    git_table = soup.find('div', {'class' : 'Details-content--hidden-not-important js-navigation-container js-active-navigation-container d-block'})
    table_rows = git_table.findAll('a', href=True)
    return [(a.get('href').replace('/blob', ''), a.text) for a in table_rows if a.text[-4:] == '.csv' and '_US' in a.text]

def get_github_csvs(hrefs):
    for href in hrefs:
        url = 'https://raw.githubusercontent.com/%s' % href[0].replace('/blob', '')
        df = pd.read_csv(url)
        df.drop(columns=['UID', 'iso2', 'iso3', 'code3', 'Country_Region', 'Lat', 'Long_', 'Combined_Key'], inplace=True)
        df.rename(columns={'Admin2' : 'county', 'Province_State' : 'state'}, inplace=True)
        if 'Population' in df.columns:
            pop_df = df[['FIPS', 'county', 'state', 'Population']].copy()
            pop_df.to_csv('data/county_population.csv', sep=',')
            df.drop(columns=['Population'], inplace=True)
        date_columns = list(df.columns[3:])
        df = df.melt(id_vars=['FIPS', 'county', 'state'], value_vars=date_columns)
        df.rename(columns={'variable' : 'date', 'value': 'total'}, inplace=True)
        df.to_csv('data/%s' % href[1], sep=',', index=False)

def main():
    hrefs = get_github_hrefs()
    get_github_csvs(hrefs)

if __name__ == '__main__':
    main()