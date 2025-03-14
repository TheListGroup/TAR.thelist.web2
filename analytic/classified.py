from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    DateRange,
    Dimension,
    Metric,
    MetricAggregation,
    FilterExpression,
    Filter,
    RunReportRequest,
    FilterExpressionList,
)
import os
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import datetime as dt
from datetime import datetime
import time
import mysql.connector
import re

host = '159.223.76.99'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\analytic\access.json"
client = BetaAnalyticsDataClient()
property_id = "286074701"
print("Access Google Analytic")

def generate_dates():
    last_year = dt.datetime.now().year - 1
    current_year = dt.datetime.now().year
    year_list = [last_year, current_year]
    
    dates = []
    for year in year_list:
        first_day_of_year = dt.datetime(year, 1, 1)
        first_monday = first_day_of_year + dt.timedelta(days=(7 - first_day_of_year.weekday()) % 7)

        for i in range(53):
            start_date = first_monday + dt.timedelta(weeks=i)
            end_date = start_date + dt.timedelta(days=6)
            
            if end_date > dt.datetime.now():
                break
        
            dates.append(DateRange(start_date=start_date.strftime('%Y-%m-%d'), end_date=end_date.strftime('%Y-%m-%d')))
    return dates

def access_ggsheet():
    json_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\analytic\access2.json"
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
    client_gg = gspread.authorize(creds)
    spreadsheet = client_gg.open_by_url('https://docs.google.com/spreadsheets/d/1C2GfogSkNSEFPfdUg5YyNteVfzdMeXqz-5sXPV3yTc4')
    print('Connect to GoogleSheet')
    return spreadsheet

final_list = []
time_list = []
dates = generate_dates()
sql = False
try:
    connection = mysql.connector.connect(
        host = host,
        user = user,
        password = password,
        database = 'realist2'
    )
    if connection.is_connected():
        print('Connected to MySQL server')
        cursor = connection.cursor()
        sql = True
    
except Exception as e:
    print(f'Error: {e}')

if sql:
    spreadsheet = access_ggsheet()
    sheet = spreadsheet.get_worksheet(5)
    condo_all = sheet.col_values(1)[1:]
    row1 = sheet.row_values(1)
    latest_value = row1[-1] if row1 else None
    try:
        lastest_date = datetime.strptime(latest_value, '%Y-%m-%d')
    except:
        lastest_date = datetime.strptime("2000-01-01", '%Y-%m-%d')
    for a, date in enumerate(dates):
        start_date = datetime.strptime(date.start_date, '%Y-%m-%d')
        if start_date > lastest_date:
            time_list.append(a)
            classified_list = []
            append_row = []
            classified_list.append(date.start_date)
            
            dimension_filter = FilterExpression(
                filter=Filter(
                    field_name="pagePath",
                    string_filter=Filter.StringFilter(
                        match_type=Filter.StringFilter.MatchType.CONTAINS,
                        value="/realist/condo/unit/")))
            request = RunReportRequest(
                        property=f"properties/{property_id}",
                        dimensions=[Dimension(name="pagePath")],
                        metrics=[Metric(name="activeUsers")],
                        date_ranges=[DateRange(start_date=date.start_date, end_date=date.end_date)],
                        dimension_filter=dimension_filter,
                    )
            response = client.run_report(request)
            if len(response.rows) > 0:
                for row in response.rows:
                    dimension_value = row.dimension_values[0].value  # pagePath
                    metric_value = row.metric_values[0].value  # activeUsers
                    try:
                        append_row.append((int(re.sub(r'(/realist/condo/unit/|/)', '', dimension_value)), int(metric_value)))
                    except:
                        pass
            
            summary = {}
            classified_ids = [data[0] for data in append_row]
            if classified_ids:
                placeholders = ','.join(['%s'] * len(classified_ids))
                query = f"SELECT Classified_ID, Condo_Code FROM classified WHERE Classified_ID IN ({placeholders})"
                cursor.execute(query, classified_ids)
                results = cursor.fetchall()
                
                id_to_condo = {row[0]: row[1] for row in results}
                
                for data in append_row:
                    classified_id = data[0]
                    if classified_id in id_to_condo:
                        condo_code = id_to_condo[classified_id]
                        active_users = data[1]
                        summary[condo_code] = summary.get(condo_code, 0) + active_users
            
            for condo_code, value in summary.items():
                classified_list.append((condo_code, value))
            
            final_list.append(classified_list)
            print(f"Classified Data {date.start_date} DONE")
    
    x = 0
    spreadsheet = access_ggsheet()
    sheet = spreadsheet.get_worksheet(5)
    for i, classified_list in enumerate(final_list):
        for j, classified in enumerate(classified_list):
            if j == 0:
                cell_notation = gspread.utils.rowcol_to_a1(1, time_list[i]+3)
                column_letter = ''.join(c for c in cell_notation if c.isalpha())
                next_col_letter = f"{column_letter}1"
                sheet.update(range_name=next_col_letter, values=[[classified]])
                x += 1
            else:
                cell_notation = gspread.utils.rowcol_to_a1(1, time_list[i]+3)
                column_letter = ''.join(c for c in cell_notation if c.isalpha())
                next_col_letter = f"{column_letter}{condo_all.index(classified[0]) + 2}"
                sheet.update(range_name=next_col_letter, values=[[classified[1]]])
                x += 1
            if x % 50 == 0 and x > 0:
                time.sleep(120)
        print(f"Classified UPDATE {classified_list[0]} DONE")

cursor.close()
connection.close()
print('Done -- Connection closed')