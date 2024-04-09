import pandas as pd
import mysql.connector

xlsx_path = r'C:\PYTHON\TAR.thelist.web2\classifield\classified_unit_report.xlsx'

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

def to_int(value,final_list):
    if value != None:
        value = int(value)
        if value < 5:
            for column in column_to_delete[x]:
                value = None
                final_list[column] = None
    return value,final_list

def gen_column(first_column):
    column_list = [first_column, "Total_Room_Count_Sale", "Total_Average_Sqm_Sale", "Total_Price_Per_Unit_Sale", "Total_Price_Per_Unit_Sqm_Sale", "Total_Room_Count_Rent"
                    , "Total_Average_Sqm_Rent", "Total_Price_Per_Unit_Rent", "Total_Price_Per_Unit_Sqm_Rent", "Bed1_Room_Count_Sale", "Bed1_Average_Sqm_Sale"
                    , "Bed1_Price_Per_Unit_Sale", "Bed1_Price_Per_Unit_Sqm_Sale", "Bed1_Room_Count_Rent", "Bed1_Average_Sqm_Rent", "Bed1_Price_Per_Unit_Rent"
                    , "Bed1_Price_Per_Unit_Sqm_Rent", "Bed2_Room_Count_Sale", "Bed2_Average_Sqm_Sale", "Bed2_Price_Per_Unit_Sale", "Bed2_Price_Per_Unit_Sqm_Sale"
                    , "Bed2_Room_Count_Rent", "Bed2_Average_Sqm_Rent", "Bed2_Price_Per_Unit_Rent", "Bed2_Price_Per_Unit_Sqm_Rent", "Bed3_Room_Count_Sale", "Bed3_Average_Sqm_Sale"
                    , "Bed3_Price_Per_Unit_Sale", "Bed3_Price_Per_Unit_Sqm_Sale", "Bed3_Room_Count_Rent", "Bed3_Average_Sqm_Rent", "Bed3_Price_Per_Unit_Rent"
                    , "Bed3_Price_Per_Unit_Sqm_Rent", "Bed4_Room_Count_Sale", "Bed4_Average_Sqm_Sale", "Bed4_Price_Per_Unit_Sale", "Bed4_Price_Per_Unit_Sqm_Sale"
                    , "Bed4_Room_Count_Rent", "Bed4_Average_Sqm_Rent", "Bed4_Price_Per_Unit_Rent", "Bed4_Price_Per_Unit_Sqm_Rent"]
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
        cursor.callproc('truncateInsert_classified_condo_report', args=())
        cursor.callproc('classified_condo_report_update_spotlight', args=())
        connection.commit()
        sql = True
    
except Exception as e:
    print(f'Error: {e}')

station_query = """SELECT 
                        ms.Station_THName_Display as Station_Name,
                        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                        sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                        sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                        SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                        sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                        sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                        sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                        sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                        sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                        sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                        sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                        sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                    FROM 
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
                    group by ms.Station_THName_Display"""

line_query = """SELECT 
                    ml.Line_Name as Line_Name,
                    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                    sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                    SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                    SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                    sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                    SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                    SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                    sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                    SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                    SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                    sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                    SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                    SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                    sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                    SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                    SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                    sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                    SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                    SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                    sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                    SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                    SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                    sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                    SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                    SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                    sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                    SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                    SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                    sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                    SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                    SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                FROM 
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
                group by ml.Line_Name"""

spotlight_query = """SELECT 
                        rs.Spotlight_Name as Spotlight_Name,
                        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                        sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                        sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                        SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                        sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                        sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                        sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                        sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                        sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                        sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                        sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                        sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                    FROM 
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
                    group by rs.Spotlight_Name"""

menu_price_query = """SELECT 
                            rs.Spotlight_Name as Spotlight_Name,
                            sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                            sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                            SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                            SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                            sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                            SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                            SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                            sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                            SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                            SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                            sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                            SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                            SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                            sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                            SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                            SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                            sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                            SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                            SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                            sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                            SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                            SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                            sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                            SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                            SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                            sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                            SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                            SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                            sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                            SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                            SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                        FROM 
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
                        group by rs.Spotlight_Name"""

segment_query = """SELECT 
                        rs.Segment_Name as Segment_Name,
                        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                        sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                        sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                        SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                        sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                        sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                        sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                        sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                        sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                        sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                        sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                        sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                    FROM 
                        classified_condo_report cr
                    JOIN 
                        real_condo_segment rs ON cr.Condo_Segment = rs.Segment_Code
                    group by rs.Segment_Name"""

province_query = """SELECT 
                        tp.name_th as Province_Name,
                        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                        sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                        sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                        SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                        sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                        sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                        sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                        sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                        sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                        sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                        sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                        sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                    FROM 
                        classified_condo_report cr
                    JOIN 
                        thailand_province tp ON cr.Province_code = tp.province_code
                    group by tp.name_th"""

district_query = """SELECT 
                        rm.District_Name as District_Name,
                        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                        sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                        sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                        SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                        sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                        sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                        sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                        sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                        sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                        sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                        sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                        sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                    FROM 
                        classified_condo_report cr
                    JOIN 
                        real_yarn_main rm ON cr.District_Code = rm.District_Code
                    group by rm.District_Name"""

subdistrict_query = """SELECT 
                            rs.SubDistrict_Name as SubDistrict_Name,
                            sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                            sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                            SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                            SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                            sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                            SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                            SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                            sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                            SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                            SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                            sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                            SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                            SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                            sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                            SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                            SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                            sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                            SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                            SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                            sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                            SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                            SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                            sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                            SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                            SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                            sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                            sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                            SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                            SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                            sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                            sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                            SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                            SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                        FROM 
                            classified_condo_report cr
                        JOIN 
                            real_yarn_sub rs ON cr.SubDistrict_Code = rs.SubDistrict_Code
                        group by rs.SubDistrict_Name"""

developer_query = """SELECT 
                        cd.Developer_Name as Developer_Name,
                        sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                        sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                        sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                        SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                        SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                        sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                        sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                        SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                        sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                        sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                        SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                        sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                        sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                        SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                        sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                        sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                        sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                        sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                        SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                    FROM 
                        classified_condo_report cr
                    JOIN 
                        condo_developer cd ON cr.Developer_Code = cd.Developer_Code
                    group by cd.Developer_Name"""

brand_query = """SELECT 
                    b.Brand_Name as Brand_Name,
                    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
                    sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale) as Total_Average_Sqm_Sale,
                    SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sale,
                    SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale) as Total_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
                    sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent) as Total_Average_Sqm_Rent,
                    SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Rent,
                    SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent) as Total_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
                    sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale) as Bed1_Average_Sqm_Sale,
                    SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sale,
                    SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale) as Bed1_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
                    sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent) as Bed1_Average_Sqm_Rent,
                    SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Rent,
                    SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent) as Bed1_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
                    sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale) as Bed2_Average_Sqm_Sale,
                    SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sale,
                    SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale) as Bed2_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
                    sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent) as Bed2_Average_Sqm_Rent,
                    SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Rent,
                    SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent) as Bed2_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
                    sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale) as Bed3_Average_Sqm_Sale,
                    SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sale,
                    SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale) as Bed3_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
                    sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent) as Bed3_Average_Sqm_Rent,
                    SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Rent,
                    SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent) as Bed3_Price_Per_Unit_Sqm_Rent,
                    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
                    sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale) as Bed4_Average_Sqm_Sale,
                    SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sale,
                    SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale) as Bed4_Price_Per_Unit_Sqm_Sale,
                    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
                    sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent) as Bed4_Average_Sqm_Rent,
                    SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Rent,
                    SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent) as Bed4_Price_Per_Unit_Sqm_Rent
                FROM 
                    classified_condo_report cr
                JOIN 
                    brand b ON cr.Brand_Code = b.Brand_Code
                group by b.Brand_Name"""

query_list = [station_query, line_query,spotlight_query,menu_price_query,segment_query,province_query,district_query,subdistrict_query,developer_query,brand_query]
title_list = ['Station','Line','Spotlight','Menu_Price','Segment','Province','District','SubDistrict','Developer','Brand']
gen_column_list = ["Station_Name","Line_Name","Spotlight_Name","Menu_Price_Name","Segment_Name","Province_Name","District_Name","SubDistrict_Name","Developer_Name","Brand_Name"]
station_list,line_list,spotlight_list,menu_price_list,segment_list,province_list,district_list,subdistrict_list,developer_list,brand_list = [],[],[],[],[],[],[],[],[],[]
report_list = [station_list,line_list,spotlight_list,menu_price_list,segment_list,province_list,district_list,subdistrict_list,developer_list,brand_list]
column_to_int = [1,5,9,13,17,21,25,29,33,37]
column_to_delete = [(2,3,4),(6,7,8),(10,11,12),(14,15,16),(18,19,20),(22,23,24),(26,27,28),(30,31,32),(34,35,36),(38,39,40)]

if sql:
    try:
        for i, query in enumerate(query_list):
            cursor.execute(query)
            result = cursor.fetchall()
            column_list = gen_column(gen_column_list[i])
            
            for x, idx in enumerate(column_to_int):
                for j in range(len(result)):
                    if idx < len(result[j]):
                        tup_list = list(result[j])
                        tup_list[idx],tup_list = to_int(tup_list[idx],tup_list)
                        result[j] = tuple(tup_list)
            
            for data in result:
                data_dict = dict(zip(column_list, data))
                report_list[i].append(data_dict)
        
        with pd.ExcelWriter(xlsx_path) as writer:
            for k, use_list in enumerate(report_list):
                df = pd.DataFrame(use_list)
                df = df.dropna(subset=df.columns.difference([df.columns[0]]), how='all')
                df = df.sort_values(by=[df.columns[1],df.columns[5]], ascending=[False,False])
                df.to_excel(writer, sheet_name=title_list[k], index=False)  
    except Exception as e:
        print(f'Error: {e} at {title_list[i]} Query')

cursor.close()
connection.close()
print('Done -- Connection closed')