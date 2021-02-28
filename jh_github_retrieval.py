#! /usr/python

import requests, json, os, csv
from contextlib import closing
from bs4 import BeautifulSoup as BS

def get_github_hrefs():
    r=requests.get('https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series')
    soup = BS(r.content, 'lxml')
    git_table = soup.find('div', {'class' : 'Details-content--hidden-not-important js-navigation-container js-active-navigation-container d-block'})
    table_rows = git_table.findAll('a', href=True)
    return [(a.get('href').replace('/blob', ''), a.text) for a in table_rows if a.text[-4:] == '.csv' and '_US' in a.text]

def get_github_csvs(hrefs):
    for href in hrefs:
        url = 'https://raw.githubusercontent.com/%s' % href[0].replace('/blob', '')
        with open ('data/%s' % href[1], 'wb') as f, requests.get(url, stream=True) as r:
            for line in r.iter_lines():
                f.write(line + '\n'.encode())

def main():
    hrefs = get_github_hrefs()
    get_github_csvs(hrefs)

if __name__ == '__main__':
    main()