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

cnxn_string = 'DRIVER={SQL Server};SERVER=%s;PORT=%s;DATABASE=%s;UID=%s;PWD=%s' % (os.getenv('database_url'), os.getenv('database_port'), os.getenv('database_name'), os.getenv('database_username'), os.getenv('database_password'))

def getPartyIDs():
    party_list = []
    r=requests.get('https://www.washingtonpost.com/wp-srv/onpolitics/elections/2001/results/parties.htm')
    soup = BS(r.content, 'lxml')
    parties = soup.findAll('table')[1].findAll('tr')
    for party in tqdm(parties):
        td = party.findAll('td')
        if td:
            party_id = td[0].text.strip()
            party_name = td[1].text.strip().replace('\'', "\'\'")
            party_list.append([party_id, party_name])
    return party_list

def insertParties(party_list):
    cnxn = pyodbc.connect(cnxn_string)
    cursor = cnxn.cursor()
    for party in tqdm(party_list):
        sql = 'INSERT INTO party VALUES (\'%s\', \'%s\')' % (party[0], party[1])
        cursor.execute(sql)
    cnxn.commit()
    cursor.close()
    cnxn.close()


def main():
    party_list = getPartyIDs()
    insertParties(party_list)

if __name__ == '__main__':
    main()