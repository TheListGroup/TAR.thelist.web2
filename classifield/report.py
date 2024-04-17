import pandas as pd
import mysql.connector
from datetime import datetime

xlsx_path = r'C:\PYTHON\TAR.thelist.web2\classifield'
#xlsx_path = r'/home/gitprod/ta_python/classifield'
file_name = "REALDATA_classified_unit_report_"
current_datetime = current_date = datetime.today().strftime('%Y%m%d')
file_path = f"{xlsx_path}\\{file_name}{current_datetime}.xlsx"
#file_path = f"{xlsx_path}//{file_name}{current_datetime}.xlsx"

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

def to_int(value):
    if value != None:
        value = int(value)
    return value

def create_query(value):
    if title_list[i] == "Price_Year_etc":
        value = "select * from (" + value + "\n" + main_value + "\n" + source_list[i] + ") p union select * from (" + segment_query + "\n" + main_value + "\n" + segment_source + ") s"
    else:
        value = value + "\n" + main_value + "\n" + source_list[i]
    return value

def gen_column(first_column, sec, third):
    column_list = [first_column, sec, third, "All Total Unit", "All Sale Total Unit", "All Sale AVG Price\n(MB)", "All Sale AVG Area\n(Bt/sq.m.)", "All Sale AVG Price\n(Bt/sq.m.)" #total
                , "All Rent Total Unit", "All Rent AVG Rent\n(Bt/Mth)", "All Rent AVG Area\n(Bt/sq.m.)", "All Rent AVG Rent\n(Bt/sq.m./Mth)" #total
                , "1 Bed Sale Total Unit", "1 Bed Sale AVG Price\n(MB)", "1 Bed Sale AVG Area\n(Bt/sq.m.)", "1 Bed Sale AVG Price\n(Bt/sq.m.)" #1bed
                , "1 Bed Rent Total Unit", "1 Bed Rent AVG Rent\n(Bt/Mth)", "1 Bed Rent AVG Area\n(Bt/sq.m.)", "1 Bed Rent AVG Rent\n(Bt/sq.m./Mth)" #1bed
                , "2 Bed Sale Total Unit", "2 Bed Sale AVG Price\n(MB)", "2 Bed Sale AVG Area\n(Bt/sq.m.)", "2 Bed Sale AVG Price\n(Bt/sq.m.)" #2bed
                , "2 Bed Rent Total Unit", "2 Bed Rent AVG Rent\n(Bt/Mth)", "2 Bed Rent AVG Area\n(Bt/sq.m.)", "2 Bed Rent AVG Rent\n(Bt/sq.m./Mth)" #2bed
                , "3 Bed Sale Total Unit", "3 Bed Sale AVG Price\n(MB)", "3 Bed Sale AVG Area\n(Bt/sq.m.)", "3 Bed Sale AVG Price\n(Bt/sq.m.)" #3bed
                , "3 Bed Rent Total Unit", "3 Bed Rent AVG Rent\n(Bt/Mth)", "3 Bed Rent AVG Area\n(Bt/sq.m.)", "3 Bed Rent AVG Rent\n(Bt/sq.m./Mth)" #3bed
                , "4+ Bed Sale Total Unit", "4+ Bed Sale AVG Price\n(MB)", "4+ Bed Sale AVG Area\n(Bt/sq.m.)", "4+ Bed Sale AVG Price\n(Bt/sq.m.)" #4bed
                , "4+ Bed Rent Total Unit", "4+ Bed Rent AVG Rent\n(Bt/Mth)", "4+ Bed Rent AVG Area\n(Bt/sq.m.)", "4+ Bed Rent AVG Rent\n(Bt/sq.m./Mth)" #4bed
                ]
    return column_list

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
        #cursor.callproc('truncateInsert_classified_condo_report', args=())
        #cursor.callproc('classified_condo_report_update_spotlight', args=())
        #connection.commit()
        sql = True
    
except Exception as e:
    print(f'Error: {e}')

main_value = """sum(cr.Total_Room_Count) as Total_Room_Count,
        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
        round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
        round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),2) as Total_Average_Sqm_Sale,
        round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
        round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
        round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),2) as Total_Average_Sqm_Rent,
        round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
        round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
        round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),2) as Bed1_Average_Sqm_Sale,
        round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
        round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
        round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),2) as Bed1_Average_Sqm_Rent,
        round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
        round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
        round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),2) as Bed2_Average_Sqm_Sale,
        round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
        round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
        round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),2) as Bed2_Average_Sqm_Rent,
        round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
        round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
        round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),2) as Bed3_Average_Sqm_Sale,
        round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
        round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
        round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),2) as Bed3_Average_Sqm_Rent,
        round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
        round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
        round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),2) as Bed4_Average_Sqm_Sale,
        round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
        round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
        round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),2) as Bed4_Average_Sqm_Rent,
        round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent"""

station_query = """SELECT 
                        ms.Station_THName_Display as Station_Name,
                        msr.Route_Name as Route_Name,
                        msr.Line_Name as Line_Name,"""
station_source = """FROM 
                    classified_condo_report cr,
                    JSON_TABLE(
                        cr.Condo_Around_Station,
                        '$[*]'
                        COLUMNS (
                            station_code varchar(100) PATH '$.Station_Code'
                        )
                    ) AS station
                JOIN 
                    mass_transit_station ms ON station.station_code = ms.Station_Code
                join mass_transit_station_match_route msr on ms.station_code = msr.Station_Code
                group by ms.Station_Code,ms.Station_THName_Display,msr.Route_Name,msr.Line_Name
                order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                    , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

line_query = """SELECT 
                    ml.Line_Name as Line_Name,
                    "" as b,
                    "" as c,"""
                    
line_source = """FROM 
                    classified_condo_report cr,
                    JSON_TABLE(
                        cr.Condo_Around_Line,
                        '$[*]'
                        COLUMNS (
                            line_code varchar(100) PATH '$.Line_Code'
                        )
                    ) AS c_line
                JOIN 
                    mass_transit_line ml ON c_line.line_code = ml.Line_Code
                group by ml.Line_Name
                order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                    , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

spotlight_query = """SELECT 
                    rs.Spotlight_Name as Spotlight_Name,
                    "" as b,
                    "" as c,"""
                    
spotlight_source = """FROM 
                        classified_condo_report cr,
                        JSON_TABLE(
                            cr.Spotlight_List,
                            '$[*]'
                            COLUMNS (
                                spotlight_code varchar(100) PATH '$.Spotlight_Code'
                            )
                        ) AS spotlight
                    JOIN 
                        real_condo_spotlight rs ON spotlight.spotlight_code = rs.Spotlight_Code
                    where rs.Menu_List > 0
                    group by rs.Spotlight_Name
                    order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                        , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

menu_price_query = """SELECT 
                        rs.Spotlight_Name as Spotlight_Name,
                        if(rs.Menu_Price_Order < 8
                            , "เรียงตามราคา"
                            , if(rs.Menu_Price_Order < 14
                                , "ปีเปิดตัว"
                                , if(rs.Menu_Price_Order < 16
                                    , "ใหม่ vs พร้อมอยู่"
                                    , if(rs.Menu_Price_Order < 18
                                        , "Freehold VS Leasehold"
                                        , if(rs.Menu_Price_Order < 20
                                            , "Low Rise VS High Rise"
                                            , if(rs.Menu_Price_Order < 22
                                                , "มือหนึ่ง VS รีเซล"
                                                , "")))))) as b,
                        "" as c,"""
                        
menu_price_source = """FROM 
                        classified_condo_report cr,
                        JSON_TABLE(
                            cr.Spotlight_List,
                            '$[*]'
                            COLUMNS (
                                spotlight_code varchar(100) PATH '$.Spotlight_Code'
                            )
                        ) AS spotlight
                    JOIN 
                        real_condo_spotlight rs ON spotlight.spotlight_code = rs.Spotlight_Code
                    where rs.Menu_Price_Order > 0
                    group by rs.Spotlight_Name,rs.Menu_Price_Order
                    order by rs.Menu_Price_Order"""

segment_query = """SELECT 
                    rs.Segment_Name as Segment_Name,
                    "Segment" as b,
                    "" as c,"""
                    
segment_source = """FROM 
                        classified_condo_report cr
                    JOIN 
                        real_condo_segment rs ON cr.Condo_Segment = rs.Segment_Code
                    group by rs.Segment_Name
                    order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                        , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

province_query = """SELECT 
                        tp.name_th as Province_Name,
                        "" as b,
                        "" as c,"""
                        
province_source = """FROM 
                        classified_condo_report cr
                    JOIN 
                        thailand_province tp ON cr.Province_code = tp.province_code
                    group by tp.name_th
                    order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                        , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

district_query = """SELECT 
                        rm.District_Name as District_Name,
                        "" as b,
                        "" as c,"""
                        
district_source = """FROM 
                        classified_condo_report cr
                    JOIN 
                        real_yarn_main rm ON cr.District_Code = rm.District_Code
                    group by rm.District_Name
                    order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                        , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

subdistrict_query = """SELECT 
                            rs.SubDistrict_Name as SubDistrict_Name,
                            "" as b,
                            "" as c,"""
                            
subdistrict_source = """FROM 
                            classified_condo_report cr
                        JOIN 
                            real_yarn_sub rs ON cr.SubDistrict_Code = rs.SubDistrict_Code
                        group by rs.SubDistrict_Name
                        order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                            , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

developer_query = """SELECT 
                        cd.Developer_Name as Developer_Name,
                        "" as b,
                        "" as c,"""
                        
developer_source = """FROM 
                        classified_condo_report cr
                    JOIN 
                        condo_developer cd ON cr.Developer_Code = cd.Developer_Code
                    group by cd.Developer_Name
                    order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                        , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

brand_query = """SELECT 
                    b.Brand_Name as Brand_Name,
                    "" as b,
                    "" as c,"""
                    
brand_source = """FROM 
                    classified_condo_report cr
                JOIN 
                    brand b ON cr.Brand_Code = b.Brand_Code
                group by b.Brand_Name
                order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
                    , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC"""

query_list = [station_query, line_query,spotlight_query,menu_price_query,province_query,district_query,subdistrict_query,developer_query,brand_query]
source_list = [station_source, line_source,spotlight_source,menu_price_source,province_source,district_source,subdistrict_source,developer_source,brand_source]
title_list = ['Station','Line','Spotlight','Price_Year_etc','Province','District','SubDistrict','Developer','Brand']
gen_column_list = ["Station Name","Line Name","Spotlight Name","Menu Price Name","Province Name","District Name","SubDistrict Name","Developer Name","Brand Name"]
station_list,line_list,spotlight_list,menu_price_list,province_list,district_list,subdistrict_list,developer_list,brand_list = [],[],[],[],[],[],[],[],[]
report_list = [station_list,line_list,spotlight_list,menu_price_list,province_list,district_list,subdistrict_list,developer_list,brand_list]
column_to_int = [3,4,8,12,16,20,24,28,32,36,40]

if sql:
    try:
        for i, query in enumerate(query_list):
            query = create_query(query)
            cursor.execute(query)
            result = cursor.fetchall()
            if gen_column_list[i] == "Station Name":
                column_list = gen_column(gen_column_list[i], "Route Name", "Line Name")
            else:
                column_list = gen_column(gen_column_list[i], "a", "b")
            
            for x, idx in enumerate(column_to_int):
                for j in range(len(result)):
                    if idx < len(result[j]):
                        tup_list = list(result[j])
                        tup_list[idx] = to_int(tup_list[idx])
                        result[j] = tuple(tup_list)
            
            for data in result:
                data_dict = dict(zip(column_list, data))
                report_list[i].append(data_dict)
        
        with pd.ExcelWriter(file_path, engine='openpyxl') as writer:
            for k, use_list in enumerate(report_list):
                df = pd.DataFrame(use_list)
                df.to_excel(writer, sheet_name=title_list[k], index=False)
                
                workbook = writer.book
                worksheet = writer.sheets[title_list[k]]
                for column in worksheet.columns:
                    max_length = 0
                    column_letter = column[0].column_letter
                    for cell in column:
                        try:
                            if len(str(cell.value)) > max_length:
                                max_length = len(cell.value)
                        except:
                            pass
                    adjusted_width = (max_length + 2) * 1.2
                    worksheet.column_dimensions[column_letter].width = adjusted_width
    except Exception as e:
        print(f'Error: {e} at {title_list[k]} Query')

cursor.close()
connection.close()
print('Done -- Connection closed')