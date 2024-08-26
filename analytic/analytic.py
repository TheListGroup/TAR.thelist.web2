from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    DateRange,
    Dimension,
    Metric,
    MetricAggregation,
    FilterExpression,
    Filter,
    RunReportRequest,
)
import os
import gspread
from oauth2client.service_account import ServiceAccountCredentials
from datetime import datetime, timedelta
import time

# Set the path explicitly in your script
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"C:\PYTHON\TAR.thelist.web2\analytic\access.json"
client = BetaAnalyticsDataClient()
property_id = "286074701"
print("Access Google Analytic")

def access_ggsheet():
    # Access Google Sheet
    json_file = r"C:\PYTHON\TAR.thelist.web2\analytic\access2.json"
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
    client_gg = gspread.authorize(creds)
    spreadsheet = client_gg.open_by_url('https://docs.google.com/spreadsheets/d/1C2GfogSkNSEFPfdUg5YyNteVfzdMeXqz-5sXPV3yTc4')
    print('Connect to GoogleSheet')
    return spreadsheet

def generate_dates():
    start_date = datetime(2024, 1, 1)
    end_date = datetime.now() - timedelta(days=1)
    #end_date = datetime(2024, 1, 5)
    
    dates = []
    
    while start_date <= end_date:
        dates.append(start_date.strftime('%Y-%m-%d'))
        start_date += timedelta(days=1)
    
    return dates

def sample_run_report(property_id,date):
    def request_and_filter(dimension_filter,date):
        request = RunReportRequest(
            property=f"properties/{property_id}",
            dimensions=[Dimension(name="pagePath")],
            metrics=[Metric(name="screenPageViews"),
                    Metric(name="totalUsers")],
            date_ranges=[DateRange(start_date=date, end_date=date)],
            dimension_filter=dimension_filter,
            #metric_filter=metric_filter,
            #limit=5,
            metric_aggregations=[MetricAggregation.TOTAL],
        )
        response = client.run_report(request)
        if len(response.totals[0].metric_values) > 0:
            for i, metric_value in enumerate(response.totals[0].metric_values):
                append_row.append(metric_value.value)
        else:
            for x in range(0,2):
                append_row.append(0)
        return append_row
        
    append_row = []
    append_row.append(date)
    
    filter_list = ["/realist/blog/","/realist/blog/category/","/realist/blog/([A-z]|[ก-๙])","/realist/condo/","/realist/condo/proj/","/realist/condo/list/"
                , "/realist/classified/", "/realist/condo/unit/", "/realist/housing/", "/realist/housing/proj/", "/realist/housing/list/"]
    for i, page in enumerate(filter_list):
        if i in [0,3,6,8]:
            dimension_filter = FilterExpression(
            filter=Filter(
                field_name="pagePath",
                string_filter=Filter.StringFilter(
                    match_type=Filter.StringFilter.MatchType.EXACT,
                    value=page)))
            append_row = request_and_filter(dimension_filter,date)
        elif i in [1,4,5,7,9,10]:
            dimension_filter = FilterExpression(
            filter=Filter(
                field_name="pagePath",
                string_filter=Filter.StringFilter(
                    match_type=Filter.StringFilter.MatchType.CONTAINS,
                    value=page)))
            append_row = request_and_filter(dimension_filter,date)
        else:
            dimension_filter = FilterExpression(
            filter=Filter(
                field_name="pagePath",
                string_filter=Filter.StringFilter(
                    match_type=Filter.StringFilter.MatchType.PARTIAL_REGEXP,
                    value=page)))
            append_row = request_and_filter(dimension_filter,date)
    return append_row

insert_list = []
dates = generate_dates()
for date in dates:
    insert_list.append(sample_run_report(property_id,date))
    print(date)
print("Data Done")

spreadsheet = access_ggsheet()
sheet = spreadsheet.get_worksheet(0)
for i in range(len(dates)):
    if i % 50 == 0 and i > 0:
        time.sleep(120)
    sheet.append_rows([insert_list[i]])
print("DONE")