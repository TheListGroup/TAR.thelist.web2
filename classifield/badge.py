import mysql.connector

host = '159.223.76.99'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

sql = False
insert_list = []
success = False
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
        
        query = """select c.Classified_ID
                    , c.Condo_Code
                    , CASE 
                        WHEN c.Price_Sale IS NOT NULL THEN 
                            CASE 
                                WHEN (c.Price_Sale / c.Size) <= sale_price.Price_Sale THEN 1
                                ELSE NULL
                            END
                        ELSE NULL
                    END AS 'Under Market Price Sale'
                    , CASE 
                        WHEN c.Price_Rent IS NOT NULL THEN 
                            CASE 
                                WHEN c.Price_Rent <= rent_price.Price_Rent THEN 2
                                ELSE NULL
                            END
                        ELSE NULL
                    END AS 'Under Market Price Rent'
                    , spotlight.cus032 as 'New_Project'
                    , spotlight.ps026 as 'Private_Lift'
                    , spotlight.ps006 as 'Branded_Residence'
                    , spotlight.ps003 as 'River_View'
                    , spotlight.ps019 as 'Luxury_Unit'
                    , spotlight.ps016 as 'Pet_Friendly'
                    , ifnull(if(spotlight.cus001 is not null
                                , 9
                                , if(spotlight.cus002 is not null
                                    , 9
                                    , NULL)),NULL) as 'Next_to_Station'
                    , if(DATE(c.Created_Date) >= (CURDATE() - INTERVAL 7 DAY), 7, NULL) as 'New_Listing'
                from classified c
                left join (SELECT c.Classified_ID, c.Condo_Code, c.Price_Sale
                            FROM classified c
                            join (SELECT subquery.Condo_Code, subquery.Price_Sale
                                    FROM (SELECT Condo_Code, Classified_ID, Price_Sale, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Price_Sale) AS row_num
                                            FROM classified
                                            WHERE Classified_Status = '1'
                                            AND Sale = 1) AS subquery
                                    join (SELECT Condo_Code, count(*) as total_rows
                                            FROM classified
                                            WHERE Classified_Status = '1'
                                            AND Sale = 1
                                            group by Condo_Code) AS subquery2
                                    on subquery.Condo_Code = subquery2.Condo_Code
                                    where subquery2.total_rows >= 3
                                    and subquery.row_num = FLOOR((subquery2.total_rows - 1) * 0.03) + 1
                                    and subquery.Price_Sale is not null) percentile_values
                            on c.Condo_Code = percentile_values.Condo_Code
                            WHERE c.Classified_Status = '1'
                            AND c.Sale = 1
                            and c.Price_Sale <= percentile_values.Price_Sale) sale_price
                on c.Classified_ID = sale_price.Classified_ID
                left join (SELECT c.Classified_ID, c.Condo_Code, c.Price_Rent
                            FROM classified c
                            join (SELECT subquery.Condo_Code, subquery.Price_Rent
                                    FROM (SELECT Condo_Code, Classified_ID, Price_Rent, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Price_Rent) AS row_num
                                            FROM classified
                                            WHERE Classified_Status = '1'
                                            AND Rent = 1) AS subquery
                                    join (SELECT Condo_Code, count(*) as total_rows
                                            FROM classified
                                            WHERE Classified_Status = '1'
                                            AND Rent = 1
                                            group by Condo_Code) AS subquery2
                                    on subquery.Condo_Code = subquery2.Condo_Code
                                    where subquery2.total_rows >= 3
                                    and subquery.row_num = FLOOR((subquery2.total_rows - 1) * 0.03) + 1
                                    and subquery.Price_Rent is not null) percentile_values
                            on c.Condo_Code = percentile_values.Condo_Code
                            WHERE c.Classified_Status = '1'
                            AND c.Rent = 1
                            and c.Price_Rent <= percentile_values.Price_Rent) rent_price
                on c.Classified_ID = rent_price.Classified_ID
                left join (SELECT Condo_Code
                                , if(PS016 = 'Y',10,NULL) as ps016
                                , if(PS026 = 'Y',3,NULL) as ps026
                                , if(PS019 = 'Y',6,NULL) as ps019
                                , if(CUS032 = 'Y',8,NULL) as cus032
                                , if(CUS001 = 'Y',9,NULL) as cus001
                                , if(CUS002 = 'Y',9,NULL) as cus002
                                , if(PS006 = 'Y',4,NULL) as ps006
                                , if(PS003 = 'Y',5,NULL) as ps003
                            FROM `condo_spotlight_relationship_view`
                            where (PS016 = 'Y' or PS026 = 'Y' or PS019 = 'Y' or CUS032 = 'Y' or CUS001 = 'Y' or CUS002 = 'Y'
                                or PS006 = 'Y' or PS003 = 'Y')) spotlight
                on c.Condo_Code = spotlight.Condo_Code
                left join (select Condo_Code
                                , Station_THName_Display
                                , Station_Timeline
                                , MTran_ShortName
                                , Distance
                            from (SELECT a.Condo_Code
                                        , b.Station_THName_Display
                                        , b.Station_Timeline
                                        , d.MTran_ShortName
                                        , a.Distance
                                        , ROW_NUMBER() OVER (PARTITION BY a.Condo_Code ORDER BY a.Distance) AS Myorder
                                    FROM `condo_around_station` a 
                                    join mass_transit_station b on a.Station_Code = b.Station_Code 
                                    join mass_transit_line c on a.Line_Code = c.Line_Code 
                                    join mass_transit d on c.MTrand_ID = d.MTran_ID 
                                    join all_condo_spotlight_relationship e on a.Condo_Code = e.Condo_Code 
                                    WHERE (e.CUS001 = 'Y' or e.CUS002 = 'Y') 
                                    and b.Station_Timeline = 'Completion') aa
                            where Myorder = 1
                            and Distance <= 0.1) next_to_station
                on c.Condo_Code = next_to_station.Condo_Code
                where c.Classified_Status = '1'"""
        cursor.execute(query)
        result_badge =  cursor.fetchall()
        sql = True

except Exception as e:
    print(f'Error: {e}')

if sql:
    query = """truncate classified_condo_badge_relationship"""
    cursor.execute(query)
    query = """INSERT INTO classified_condo_badge_relationship (Classified_ID, Badge_Code) VALUES (%s, %s)"""
    for data in result_badge:
        for badge in data[2:]:
            if badge is not None:
                classified_id = data[0]
                badge_code = badge
                insert_list.append((classified_id, badge_code))
    
    try:
        cursor.executemany(query, insert_list)
        connection.commit()
        success = True
    except Exception as e:
        print(f'Error: {e}')
    
    if success:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES (%s, %s, %s, %s)"""
        cursor.execute(query, (0, '00000', f'Insert {len(insert_list)} Rows', 'Classified Badge'))
        connection.commit()
        print(f'Insert {len(insert_list)} Rows')
    else:
        query = """INSERT INTO realist_log (Type, Message, Location)
                VALUES (%s, %s, %s)"""
        val = (1, str(e), 'Classified Badge')
        cursor.execute(query,val)
        connection.commit()
    
    cursor.close()
    connection.close()