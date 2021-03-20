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

def getStateAbbreviations():
    cnxn = pyodbc.connect(cnxn_string)
    cursor = cnxn.cursor()
    cursor.execute('SELECT stateAbbrev FROM state')
    state_abbrevs = cursor.fetchall()
    cursor.close()
    cnxn.close()
    return state_abbrevs

def getCountyElectionResults(state_abbrevs):
    columns = ['stateAbbrev', 'countyName', 'candidateFirstName', 'candidateLastName', 'candidateParty', 'voteCount']
    df = pd.DataFrame(columns=columns)
    for state_abbrev in tqdm(state_abbrevs):
        state_abbrev = state_abbrev[0]
        r=requests.get('https://www.usatoday.com/elections/results/race/2020-11-03-presidential-%s-0/' % state_abbrev)
        soup = BS(r.content, 'lxml')
        counties_container = soup.find('div', {'class' : 'results-fips-container'})
        if counties_container:
            county_divs = counties_container.findAll('div', {'class' : 'results-fips-item'})
            for county in county_divs:
                county_name = county.find('h4').text.replace(' County', '').replace(' Parish', '')
                all_candidates = county.findAll('tr', {'class' : 'result-county-table-row'})
                for candidate in all_candidates:
                    td = candidate.findAll('td')
                    if td[0].text == 'None of these candidates (ND)':
                        first_name = 'Other'
                        last_name = 'NULL'
                        party = 'OTH'
                    else:
                        first_name = td[0].text.split('\n')[0]
                        last_name = td[0].text.split('\n')[1].split(' (')[0]
                        party = td[0].text.split('(')[1].split(')')[0]
                    totalVotes = td[1].text.replace(',', '').replace('-', '0')
                    df = df.append({'stateAbbrev' : state_abbrev,
                                'countyName' : county_name,
                                'candidateFirstName' : first_name,
                                'candidateLastName' : last_name,
                                'candidateParty' : party,
                                'voteCount' : totalVotes}, ignore_index=True)
    return df

def insertElectionResults(df):
    cnxn = pyodbc.connect(cnxn_string)
    cursor = cnxn.cursor()
    for index, row in tqdm(df.iterrows(), total=len(df.index)):
        sql = """\
            EXEC election_result_data 
            @StateAbbrev=?, 
            @CountyName=?, 
            @CandidateFirstName=?, 
            @CandidateLastName=?, 
            @CandidateParty=?, 
            @VoteCount=?
            """
        cursor.execute(sql, 
                        row.stateAbbrev, 
                        row.countyName, 
                        row.candidateFirstName, 
                        row.candidateLastName, 
                        row.candidateParty, 
                        row.voteCount)
    cnxn.commit()
    cursor.close()
    cnxn.close()

def main():
    state_abbrevs = getStateAbbreviations()
    df = getCountyElectionResults(state_abbrevs)
    insertElectionResults(df)    

if __name__ == '__main__':
    main()