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

#os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"C:\PYTHON\TAR.thelist.web2\analytic\access.json"
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"/home/gitprod/ta_python/analytic/access.json"
client = BetaAnalyticsDataClient()
property_id = "286074701"
print("Access Google Analytic")

def access_ggsheet():
    #json_file = r"C:\PYTHON\TAR.thelist.web2\analytic\access2.json"
    json_file = r"/home/gitprod/ta_python/analytic/access2.json"
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
    client_gg = gspread.authorize(creds)
    spreadsheet = client_gg.open_by_url('https://docs.google.com/spreadsheets/d/1C2GfogSkNSEFPfdUg5YyNteVfzdMeXqz-5sXPV3yTc4')
    print('Connect to GoogleSheet')
    return spreadsheet

def generate_dates():
    current_year = dt.datetime.now().year
    first_day_of_year = dt.datetime(current_year, 1, 1)
    first_monday = first_day_of_year + dt.timedelta(days=(7 - first_day_of_year.weekday()) % 7)

    dates = []
    for i in range(52):
        start_date = first_monday + dt.timedelta(weeks=i)
        end_date = start_date + dt.timedelta(days=6)
        
        if end_date > dt.datetime.now():
            break
    
        dates.append(DateRange(start_date=start_date.strftime('%Y-%m-%d'), end_date=end_date.strftime('%Y-%m-%d')))
    return dates

def sample_run_report(property_id,date,filter_list):
    def request_and_filter(dimension_filter,date,page):
        if dimension_filter == "":
            request = RunReportRequest(
                property=f"properties/{property_id}",
                dimensions=[Dimension(name="pagePath")],
                metrics=[Metric(name="totalUsers"),
                        Metric(name="userEngagementDuration"),
                        Metric(name="screenPageViews")],
                date_ranges=[DateRange(start_date=date.start_date, end_date=date.end_date)],
                metric_aggregations=[MetricAggregation.TOTAL],
            )
        else:
            if page in [0,1,5,6,10,14]:
                request = RunReportRequest(
                    property=f"properties/{property_id}",
                    dimensions=[Dimension(name="pagePath")],
                    metrics=[Metric(name="totalUsers"),
                            Metric(name="userEngagementDuration"),
                            Metric(name="screenPageViews")],
                    date_ranges=[DateRange(start_date=date.start_date, end_date=date.end_date)],
                    dimension_filter=dimension_filter,
                    metric_aggregations=[MetricAggregation.TOTAL],
                )
            else:
                request = RunReportRequest(
                    property=f"properties/{property_id}",
                    dimensions=[Dimension(name="pagePath")],
                    metrics=[Metric(name="userEngagementDuration"),
                            Metric(name="screenPageViews")],
                    date_ranges=[DateRange(start_date=date.start_date, end_date=date.end_date)],
                    dimension_filter=dimension_filter,
                    metric_aggregations=[MetricAggregation.TOTAL],
                )
        response = client.run_report(request)
        if len(response.totals[0].metric_values) > 0:
            for i, metric_value in enumerate(response.totals[0].metric_values):
                append_row.append(metric_value.value)
        else:
            if page in [0,1,5,6,10,14]:
                for x in range(0,3):
                    append_row.append(0)
            else:
                for x in range(0,2):
                    append_row.append(0)
        return append_row
    
    append_row = []
    append_row.append(date.start_date)
    for i, page in enumerate(filter_list):
        dimension_filter = filter_page(i,page)
        append_row = request_and_filter(dimension_filter,date,i)
    return append_row

def filter_page(i,page):
    if i == 0:
        dimension_filter = ""
    elif i in [2,7,11,15]:
        dimension_filter = FilterExpression(
        filter=Filter(
            field_name="pagePath",
            string_filter=Filter.StringFilter(
                match_type=Filter.StringFilter.MatchType.EXACT,
                value=page)))
    elif i in [1,3,6,8,9,10,13,16,17,18,19]:
        dimension_filter = FilterExpression(
        filter=Filter(
            field_name="pagePath",
            string_filter=Filter.StringFilter(
                match_type=Filter.StringFilter.MatchType.CONTAINS,
                value=page)))
    else:
        dimension_filter = FilterExpression(
        filter=Filter(
            field_name="pagePath",
            string_filter=Filter.StringFilter(
                match_type=Filter.StringFilter.MatchType.PARTIAL_REGEXP,
                value=page)))
    return dimension_filter

def sample_run_report_traffic(property_id,date,filter_list,traffic):
    def request_and_filter_landpage(dimension_filter,date):
        request = RunReportRequest(
            property=f"properties/{property_id}",
            dimensions=[Dimension(name="sessionSourceMedium"),
                        Dimension(name="landingPagePlusQueryString")],
            metrics=[Metric(name="totalUsers")],
            date_ranges=[DateRange(start_date=date.start_date, end_date=date.end_date)],
            dimension_filter=dimension_filter,
            metric_aggregations=[MetricAggregation.TOTAL],
        )
        response = client.run_report(request)
        if len(response.totals[0].metric_values) > 0:
            for i, metric_value in enumerate(response.totals[0].metric_values):
                append_row.append(int(metric_value.value))
        else:
            append_row.append(0)
        return append_row
    
    use_list = []
    append_row = []
    append_row.append(date.start_date)
    for i, page in enumerate(filter_list):
        dimension_filter = filter_landpage(i,page,traffic)
        append_row = request_and_filter_landpage(dimension_filter,date)
    use_list.extend(append_row)
    return use_list

def create_filter_expression(traffic, exclude_traffic=False):
    if exclude_traffic:
        return FilterExpression(
            not_expression=FilterExpression(
                or_group=FilterExpressionList(
                    expressions=[
                        FilterExpression(
                            filter=Filter(
                                field_name="sessionSourceMedium",
                                string_filter=Filter.StringFilter(
                                    match_type=Filter.StringFilter.MatchType.PARTIAL_REGEXP,
                                    value="cpc"))),
                        FilterExpression(
                            filter=Filter(
                                field_name="sessionSourceMedium",
                                string_filter=Filter.StringFilter(
                                    match_type=Filter.StringFilter.MatchType.PARTIAL_REGEXP,
                                    value="organic")))])))
    else:
        return FilterExpression(
            filter=Filter(
                field_name="sessionSourceMedium",
                string_filter=Filter.StringFilter(
                    match_type=Filter.StringFilter.MatchType.PARTIAL_REGEXP,
                    value=traffic)))

def filter_landpage(i,page,traffic):
    if traffic == "(organic|cpc)":
        exclude_traffic = True
    else:
        exclude_traffic = False

    if i == 0:
        dimension_filter = create_filter_expression(traffic, exclude_traffic)
    elif i in [2, 7, 11, 15]:
        dimension_filter = FilterExpression(
            and_group=FilterExpressionList(
                expressions=[
                    FilterExpression(
                        filter=Filter(
                            field_name="landingPagePlusQueryString",
                            string_filter=Filter.StringFilter(
                                match_type=Filter.StringFilter.MatchType.EXACT,
                                value=page))),
                    create_filter_expression(traffic, exclude_traffic)]))
    elif i in [1, 3, 6, 8, 9, 10, 13, 16, 17, 18, 19]:
        dimension_filter = FilterExpression(
            and_group=FilterExpressionList(
                expressions=[
                    FilterExpression(
                        filter=Filter(
                            field_name="landingPagePlusQueryString",
                            string_filter=Filter.StringFilter(
                                match_type=Filter.StringFilter.MatchType.CONTAINS,
                                value=page))),
                    create_filter_expression(traffic, exclude_traffic)]))
    else:
        dimension_filter = FilterExpression(
            and_group=FilterExpressionList(
                expressions=[
                    FilterExpression(
                        filter=Filter(
                            field_name="landingPagePlusQueryString",
                            string_filter=Filter.StringFilter(
                                match_type=Filter.StringFilter.MatchType.PARTIAL_REGEXP,
                                value=page))),
                    create_filter_expression(traffic, exclude_traffic)]))
    return dimension_filter

filter_list = ["The List","/realist/blog/","/realist/blog/","/realist/blog/category/","/realist/blog/([A-z]|[ก-๙])","/realist/condo|housing|classified/"
                , "/realist/condo/", "/realist/condo/", "/realist/condo/list/", "/realist/condo/proj/", "/realist/housing/", "/realist/housing/"
                , "/realist/housing(/list/|/single-detached-house/list/|/semi-detached-house/list/|/townhome/list/|/home-office/list/|/shophouse/list/)"
                , "/realist/housing/proj/", "/realist/(classified/|condo/unit/)", "/realist/classified/", "/realist/classified/comparison/"
                , "/realist/classified/bookmark/", "/realist/classified/u/", "/realist/condo/unit/"]

insert_list,organic_list,cpc_list,other_list = [],[],[],[]
dates = generate_dates()
spreadsheet = access_ggsheet()
sheets = spreadsheet.worksheets()
sheet_count = len(sheets)
for count in range(sheet_count-1):
    sheet = spreadsheet.get_worksheet(count)
    data_all = sheet.col_values(1)
    try:
        lastest_date = datetime.strptime(data_all[-1], '%Y-%m-%d')
    except:
        lastest_date = datetime.strptime("2000-01-01", '%Y-%m-%d')
    for date in dates:
        start_date = datetime.strptime(date.start_date, '%Y-%m-%d')
        if start_date > lastest_date:
            if count == 0:
                insert_list.append(sample_run_report(property_id,date,filter_list))
            elif count == 1:
                organic_values = sample_run_report_traffic(property_id,date,filter_list,"organic")
                organic_list.append(organic_values)
            elif count == 2:
                cpc_values = sample_run_report_traffic(property_id,date,filter_list,"cpc")
                cpc_list.append(cpc_values)
            elif count == 3:
                other_values = sample_run_report_traffic(property_id,date,filter_list,"(organic|cpc)")
                other_list.append(other_values)
            print(f"{sheet.title} Work at {date}")
print("Data Done")

insert_data_list = []
for data_set in insert_list:
    data_list = []
    for i in range(len(data_set)):
        data_list.append(0)
    x,y = 1,3
    for i in range(len(data_set)):
        if i in [1,2,3,4,5,12,13,14,15,16,17,24,25,26,33,34,35,46]:
            data_list[i] = int(data_set[i])
        elif i == 0:
            data_list[i] = data_set[i]
        elif i in [6,7,8,18,19,20,27,28,29,36,37,38,39,40]:
            if i in [18,27,36]:
                x = 1
            data_list[i] = int(data_set[i+x])
            x += 1
        elif i in [9,10,11,21,22,23,30,31,32,41,42,43,44,45]:
            if i in [21,30]:
                y = 3
            elif i == 41:
                y = 5
            data_list[i] = int(data_set[i-y])
            y -= 1
    insert_data_list.append(data_list)

insert = [insert_data_list,organic_list,cpc_list,other_list]
spreadsheet = access_ggsheet()
for x in range(len(insert)):
    sheet = spreadsheet.get_worksheet(x)
    print(f"{sheet.title} DONE")
    for i in range(len(insert[x])):
        if i % 50 == 0 and i > 0:
            time.sleep(120)
        sheet.append_rows([insert[x][i]])
    if x < 3:
        time.sleep(120)
print("DONE")