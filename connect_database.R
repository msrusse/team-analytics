library(dotenv)
library(DBI)
setwd('D:\\msis5223\\team-analytics-1')
load_dot_env('.env')
db_conn_string = paste('Driver={SQL Server};server=', 
                       Sys.getenv('database_url'),
                       ';server=',
                       Sys.getenv('database_name'),
                       ';database=',
                       Sys.getenv('database_name'),
                       ';uid=',
                       Sys.getenv('database_username'),
                       ';pwd=',
                       Sys.getenv('database_password'), sep='')
con = dbConnect(odbc::odbc(), .connection_string = db_conn_string, timeout = 10)
res = dbReadTable(con, 'party')