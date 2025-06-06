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

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

#os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\analytic\access.json"
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"/home/gitprod/ta_python/analytic/access.json"
client = BetaAnalyticsDataClient()
property_id = "286074701"
print("Access Google Analytic")

def access_ggsheet():
    #json_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\analytic\access2.json"
    json_file = r"/home/gitprod/ta_python/analytic/access2.json"
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
    client_gg = gspread.authorize(creds)
    spreadsheet = client_gg.open_by_url('https://docs.google.com/spreadsheets/d/1C2GfogSkNSEFPfdUg5YyNteVfzdMeXqz-5sXPV3yTc4')
    print('Connect to GoogleSheet')
    return spreadsheet

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

def create_floorplan_query(condition):
    merge_query = floorplan_query + "\n" + condition
    cursor.execute(merge_query)
    result = cursor.fetchall()
    count_data = result[0][0]
    return count_data

filter_list = ["The List","/realist/blog/","/realist/blog/","/realist/blog/category/","/realist/blog/([A-z]|[ก-๙])","/realist/condo|housing|classified/"
                , "/realist/condo/", "/realist/condo/", "/realist/condo/list/", "/realist/condo/proj/", "/realist/housing/", "/realist/housing/"
                , "/realist/housing(/list/|/single-detached-house/list/|/semi-detached-house/list/|/townhome/list/|/home-office/list/|/shophouse/list/)"
                , "/realist/housing/proj/", "/realist/(classified/|condo/unit/)", "/realist/classified/", "/realist/classified/comparison/"
                , "/realist/classified/bookmark/", "/realist/classified/u/", "/realist/condo/unit/"]

insert_list,organic_list,cpc_list,other_list = [],[],[],[]
dates = generate_dates()
spreadsheet = access_ggsheet()
for count in range(4):
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
    blog = """SELECT count(wp.ID) as Article
            FROM wp_posts wp
            where wp.post_status = 'publish'"""
    
    client_blog = """select count(*)
                    from (select wpr.object_id 
                            from wp_term_relationships wpr
                            left join wp_term_taxonomy wtt on wpr.term_taxonomy_id = wtt.term_taxonomy_id
                            left join wp_terms wt on wtt.term_id = wt.term_id
                            left join wp_posts wp on wpr.object_id = wp.ID
                            where wtt.term_id <> 461
                            and wp.post_status = 'publish'
                            group by wpr.object_id) a"""
    
    realist_post = """select count(*)
                    from (select wpr.object_id 
                            from wp_term_relationships wpr
                            left join wp_term_taxonomy wtt on wpr.term_taxonomy_id = wtt.term_taxonomy_id
                            left join wp_terms wt on wtt.term_id = wt.term_id
                            left join wp_posts wp on wpr.object_id = wp.ID
                            where wtt.term_id = 461
                            and wp.post_status = 'publish'
                            group by wpr.object_id) a"""
    
    all_condo = """select count(*)
                from real_condo
                where Condo_Status in (1,3)"""
    
    condo_short = """SELECT count(*)
                    FROM real_condo rc
                    left join (select Condo_Code
                            , count(Floor_Plan_ID) as 'Floor_Plan'
                            from full_template_floor_plan
                            where Floor_Plan_Status = 1
                            group by Condo_Code) fp
                    on rc.Condo_Code = fp.Condo_Code
                    left join (select Condo_Code
                                    , sum(Vector) as Vector
                            from (select fp.Condo_Code
                                    , fp.Floor_Plan_ID
                                    , count(vr.Vector_ID) as Vector
                            from full_template_floor_plan fp
                            left join full_template_vector_floor_plan_relationship vr on fp.Floor_Plan_ID = vr.Floor_Plan_ID
                            where fp.Floor_Plan_Status = 1
                            and vr.Relationship_Status = 1
                            group by fp.Condo_Code, fp.Floor_Plan_ID) a
                            group by Condo_Code) v
                    on rc.Condo_Code = v.Condo_Code
                    left join (select Condo_Code
                                    , count(Element_ID) as 'Element'
                            from full_template_element_image_view
                            group by Condo_Code) fi
                    on rc.Condo_Code = fi.Condo_Code
                    where rc.Condo_Status = 1
                    and fp.Floor_Plan is null
                    and v.Vector is null
                    and fi.Element is null"""
    
    floorplan_query = """select count(*)
                        from (select rc.Condo_Code
                            , fb.Total_Building
                            , f.Floors as Total_Floor
                            , floor_plan.Total_Floor_Plan
                            , (floor_plan.Total_Floor_Plan * 100)/f.Floors as Floor_Plan_Cal
                            , rc.Condo_TotalUnit
                            , ifnull(v.Vectors,0) as Total_Vector
                            , ifnull((v.Vectors * 100)/ rc.Condo_TotalUnit,0) as Vector_Cal
                        from real_condo rc
                        inner join (select Condo_Code
                                        , count(Building_ID) as Total_Building
                                    from full_template_building
                                    where Building_Status = 1
                                    group by Condo_Code) fb 
                        on rc.Condo_Code = fb.Condo_Code
                        left join (select fb.Condo_Code
                                        , count(ff.Floor_ID) as Floors
                                    from full_template_floor ff
                                    left join full_template_building fb on ff.Building_ID = fb.Building_ID
                                    where ff.Floor_Status = 1
                                    and fb.Building_Status = 1
                                    group by fb.Condo_Code) f
                        on fb.Condo_Code = f.Condo_Code
                        left join (select Condo_Code
                                        , count(Floor_Plan_ID) as Total_Floor_Plan
                                    from (select  fb.Condo_Code
                                                , ff.Floor_ID
                                                , ifnull(fp.Floor_Plan_ID,fp2.Floor_Plan_ID) as Floor_Plan_ID
                                            from full_template_floor ff
                                            left join full_template_building fb on ff.Building_ID = fb.Building_ID
                                            left join (select Condo_Code
                                                            , Floor_Plan_ID
                                                        from full_template_floor_plan
                                                        where Floor_Plan_Status = 1) fp
                                            on ff.Floor_Plan_ID = fp.Floor_Plan_ID
                                            left join (select Condo_Code
                                                            , Floor_Plan_ID 
                                                        from (select Condo_Code
                                                                    , Floor_Plan_ID
                                                                    , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Floor_Plan_Order) AS RowNum
                                                                from full_template_floor_plan
                                                                where Floor_Plan_Status = 1
                                                                and Master_Plan = 1) a
                                                        where RowNum = 1) fp2
                                            on fb.Condo_Code = fp2.Condo_Code
                                            where ff.Floor_Status = 1
                                            and fb.Building_Status = 1) a
                                    group by Condo_Code) floor_plan
                        on fb.Condo_Code = floor_plan.Condo_Code
                        left join (select Condo_Code
                                        , sum(Vectors) as Vectors
                                    from (SELECT fp.Condo_Code
                                                , vr.Floor_Plan_ID
                                                , count(vr.Ref_ID) * ifnull(count_floor.Floor,1) as Vectors
                                            FROM full_template_vector_floor_plan_relationship vr
                                            left join full_template_unit_type fu on vr.Ref_ID = fu.Unit_Type_ID and vr.Vector_Type = 1
                                            left join full_template_floor_plan fp on vr.Floor_Plan_ID = fp.Floor_Plan_ID
                                            left join (select Floor_Plan_ID
                                                            , count(Floor_ID) as Floor
                                                        from full_template_floor
                                                        where Floor_Status = 1
                                                        group by Floor_Plan_ID) count_floor
                                            on vr.Floor_Plan_ID = count_floor.Floor_Plan_ID
                                            where vr.Relationship_Status = 1
                                            and vr.Vector_Type = 1  
                                            and fu.Unit_Type_Status = 1
                                            and fp.Floor_Plan_Status = 1
                                            group by fp.Condo_Code, vr.Floor_Plan_ID, count_floor.Floor) a
                                    group by Condo_Code
                                    order by Condo_Code) v
                        on fb.Condo_Code = v.Condo_Code
                        where rc.Condo_Status = 1
                        order by rc.Condo_Code) aaaa"""
    
    agent = """select count(*)
            from classified_user
            where User_Status = '1'
            and User_Type = 'Agent'"""
    
    agent_room = """select count(*)
                from classified c
                left join classified_user cu on c.User_ID = cu.User_ID
                where c.Classified_Status = '1'
                and cu.User_Status = '1'
                and cu.User_Type = 'Agent'"""
    
    member = """select count(*)
            from classified_user
            where User_Status = '1'
            and User_Type = 'Member'"""
    
    member_room = """select count(*)
                    from classified c
                    left join classified_user cu on c.User_ID = cu.User_ID
                    where c.Classified_Status = '1'
                    and cu.User_Status = '1'
                    and cu.User_Type = 'Member'"""
    
    condo_classified = """select count(Condo_Code)
                        from (select Condo_Code
                                from classified
                                where Classified_Status = '1'
                                group by Condo_Code) a"""
    
    bc_classified_update = """SELECT count(*)
                            FROM `classified_all_logs`
                            where Type = 'update'
                            and User_ID = 1
                            and DATE(Insert_Day) BETWEEN %s and %s"""
    
    bc_classified_insert = """SELECT count(*)
                            FROM `classified_all_logs`
                            where Type = 'insert'
                            and User_ID = 1
                            and DATE(Insert_Day) BETWEEN %s and %s"""
    
    bc_classified_sold_or_delete = """SELECT count(*)
                                    FROM `classified_all_logs`
                                    where Type = 'status'
                                    and User_ID = 1
                                    and DATE(Insert_Day) BETWEEN %s and %s"""
    
    ag_classified_update = """SELECT count(*)
                            FROM `classified_all_logs`
                            where Type = 'update'
                            and User_ID = 2
                            and DATE(Insert_Day) BETWEEN %s and %s"""
    
    ag_classified_insert = """SELECT count(*)
                            FROM `classified_all_logs`
                            where Type = 'insert'
                            and User_ID = 2
                            and DATE(Insert_Day) BETWEEN %s and %s"""
    
    ag_classified_sold_or_delete = """SELECT count(*)
                                    FROM `classified_all_logs`
                                    where Type = 'status'
                                    and User_ID = 2
                                    and DATE(Insert_Day) BETWEEN %s and %s"""
    
    serve_classified_update = """SELECT count(*)
                            FROM `classified_all_logs`
                            where Type = 'update'
                            and User_ID = 4
                            and DATE(Insert_Day) BETWEEN %s and %s"""
    
    serve_classified_insert = """SELECT count(*)
                            FROM `classified_all_logs`
                            where Type = 'insert'
                            and User_ID = 4
                            and DATE(Insert_Day) BETWEEN %s and %s"""
    
    serve_classified_sold_or_delete = """SELECT count(*)
                                    FROM `classified_all_logs`
                                    where Type = 'status'
                                    and User_ID = 4
                                    and DATE(Insert_Day) BETWEEN %s and %s"""
    
    classified_contact_form = """SELECT count(*)
                                FROM `real_contact_form`
                                where Contact_Type = 'classified'
                                and Contact_Date BETWEEN %s and %s"""
    
    condo_dev_email = """SELECT count(a.Condo_Code)
                        FROM `real_contact_condo_send_to_who` a
                        left join real_contact_dev_agent b on a.Dev_Agent_Contact_ID = b.Dev_Agent_Contact_ID
                        where b.Dev_or_Agent = 'D'"""
    
    condo_not_dev_email = """select count(aa.Condo_Code) - (SELECT count(a.Condo_Code) as condo_count
                                                            FROM `real_contact_condo_send_to_who` a
                                                            left join real_contact_dev_agent b on a.Dev_Agent_Contact_ID = b.Dev_Agent_Contact_ID
                                                            where b.Dev_or_Agent = 'D')
                            from all_condo_price_calculate aa"""
    
    condo_contact_form = """SELECT count(*)
                            FROM `real_contact_form`
                            where Contact_Type = 'contact'
                            and Contact_Date BETWEEN %s and %s"""
    
    condo_from_contact_form = """select sum(Condo_Code)
                                from (SELECT Contact_ID,Count(Condo_Code) as Condo_Code 
                                        FROM `real_contact_email_log`
                                        where Dev_or_Agent = 'D'
                                        and Contact_Sent_Date BETWEEN %s and %s
                                        group by Contact_ID) aaa"""
    
    agent_email = """SELECT count(*)  
                    FROM `real_contact_email_log` 
                    WHERE `Dev_or_Agent` = 'A'
                    and Contact_Sent_Date BETWEEN %s and %s"""
    
    developer_email = """select sum(Condo_Code)
                        from (SELECT Contact_ID,count(Condo_Code) as Condo_Code
                                FROM `real_contact_email_log`
                                where Dev_or_Agent = 'D'
                                and Contact_Sent_Date BETWEEN %s and %s
                                group by Contact_ID) aaa"""
    
    developer_email_success = """SELECT count(*)  
                                FROM `real_contact_email_log`
                                where Dev_or_Agent = 'D'
                                and Contact_Sent = 'Y'
                                and Contact_Sent_Date BETWEEN %s and %s"""
    
    developer_email_not_success = """SELECT count(*)  
                                    FROM `real_contact_email_log`
                                    where Dev_or_Agent = 'D'
                                    and Contact_Sent = 'N'
                                    and Contact_Sent_Date BETWEEN %s and %s"""
    
    spreadsheet = access_ggsheet()
    sheet = spreadsheet.get_worksheet(4)
    data_all = sheet.col_values(1)
    query_list = [blog, client_blog, realist_post, all_condo, condo_short, floorplan_query, agent, agent_room, member, member_room, condo_classified
                , bc_classified_update, bc_classified_insert, bc_classified_sold_or_delete, ag_classified_update, ag_classified_insert
                , ag_classified_sold_or_delete, serve_classified_update, serve_classified_insert, serve_classified_sold_or_delete
                , condo_dev_email, condo_not_dev_email]
    contact_query_list = [classified_contact_form, condo_contact_form,condo_from_contact_form,agent_email,developer_email,developer_email_success,developer_email_not_success]
    event_list = ["Click-classified","click-classified-bookmark","submitform_classified_appear","submitform_classified_fill","submitform_classified_submit"
                    ,"submitform_condo_appear","submitform_condo_fill","click-to-submitfrom","click-button-atricle","click-to-blog"]
    try:
        lastest_date = datetime.strptime(data_all[-1], '%Y-%m-%d')
    except:
        lastest_date = datetime.strptime("2000-01-01", '%Y-%m-%d')
    for date in dates:
        start_date = datetime.strptime(date.start_date, '%Y-%m-%d')
        if start_date > lastest_date:
            web_data_list = []
            web_data_list.append(date.start_date)
            for i, query in enumerate(query_list):
                if i == 5:
                    web_data_list.append(create_floorplan_query(" where Floor_Plan_Cal >= 80"))
                    web_data_list.append(create_floorplan_query(" where Floor_Plan_Cal < 80 and Floor_Plan_Cal > 0"))
                    web_data_list.append(create_floorplan_query(" where Vector_Cal >= 80"))
                    web_data_list.append(create_floorplan_query(" where Vector_Cal < 80 and Vector_Cal > 0"))
                elif i >= 11 and i <= 19:
                    val = (datetime.strptime(f"{date.start_date} {'00:10:00'}", '%Y-%m-%d %H:%M:%S'), datetime.strptime(f"{date.end_date} {'00:10:00'}", '%Y-%m-%d %H:%M:%S'))
                    cursor.execute(query,val)
                    result = cursor.fetchall()
                    count_data = int(result[0][0])
                    web_data_list.append(count_data)
                else:
                    cursor.execute(query)
                    result = cursor.fetchall()
                    count_data = result[0][0]
                    web_data_list.append(count_data)
            
            for i, query in enumerate(contact_query_list):
                val = (datetime.strptime(f"{date.start_date} {'00:10:00'}", '%Y-%m-%d %H:%M:%S'), datetime.strptime(f"{date.end_date} {'00:10:00'}", '%Y-%m-%d %H:%M:%S'))
                cursor.execute(query,val)
                result = cursor.fetchall()
                try:
                    count_data = int(result[0][0])
                except:
                    count_data = 0
                web_data_list.append(count_data)

            request = RunReportRequest(
                property=f"properties/{property_id}",
                dimensions=[Dimension(name="eventName")],
                metrics=[Metric(name="eventCount")],
                date_ranges=[DateRange(start_date=date.start_date, end_date=date.end_date)],
                metric_aggregations=[MetricAggregation.TOTAL],
            )
            response = client.run_report(request)
            for i, event in enumerate(event_list):
                found = False
                for x, event_name in enumerate(response.rows):
                    if event == event_name.dimension_values[0].value:
                        web_data_list.append(int(event_name.metric_values[0].value))
                        found = True
                        break
                if not found:
                    web_data_list.append(0)
            print(f"Database Data Work at {date}")
            sheet.append_rows([web_data_list])
        
    #classified progress
    final_list = []
    time_list = []
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

    cursor.close()
    connection.close()
    print('Done -- Connection closed')

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

if len(final_list) > 0:
    x = 0
    spreadsheet = access_ggsheet()
    sheet = spreadsheet.get_worksheet(5)
    for i, classified_list in enumerate(final_list):
        for j, classified in enumerate(classified_list):
            if j == 0:
                cell_notation = gspread.utils.rowcol_to_a1(1, time_list[i]+7)
                column_letter = ''.join(c for c in cell_notation if c.isalpha())
                next_col_letter = f"{column_letter}1"
                sheet.update(range_name=next_col_letter, values=[[classified]])
                x += 1
            else:
                cell_notation = gspread.utils.rowcol_to_a1(1, time_list[i]+7)
                column_letter = ''.join(c for c in cell_notation if c.isalpha())
                next_col_letter = f"{column_letter}{condo_all.index(classified[0]) + 2}"
                sheet.update(range_name=next_col_letter, values=[[classified[1]]])
                x += 1
            if x % 50 == 0 and x > 0:
                time.sleep(120)
        print(f"Classified UPDATE {classified_list[0]} DONE")

print("DONE")