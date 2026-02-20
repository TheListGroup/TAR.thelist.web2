-- view source_housing_around_station
-- view source_housing_around_express_way
-- view source_housing_factsheet_view
-- view source_housing_fetch_for_map
-- view source_article_housing_fetch_for_map

-- view source_housing_around_station
create or replace view source_housing_around_station as
select Station_Code
    , Station_THName_Display
    , Route_Code
    , Line_Code
    , Housing_Code
    , Distance
from (SELECT mtsmr.Station_Code
            , mtsmr.Station_THName_Display
            , mtsmr.Route_Code
            , mtr.Line_Code
            , mtsmr.Station_Latitude
            , mtsmr.Station_Longitude
            , asok.Station_Latitude as asok_lat
            , asok.Station_Longitude as asok_long
            , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(mtsmr.Station_Latitude - asok.Station_Latitude)) / 2), 2)
                + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(mtsmr.Station_Latitude)) *
                POWER(SIN((RADIANS(mtsmr.Station_Longitude - asok.Station_Longitude)) / 2), 2)))) AS station_distance
            , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(mtsmr.Station_Latitude - asok.Station_Latitude)) / 2), 2)
                                    + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(mtsmr.Station_Latitude)) *
                                    POWER(SIN((RADIANS(mtsmr.Station_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
            , h.Housing_Code
            , h.Housing_Latitude
            , h.Housing_Longitude
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - mtsmr.Station_Latitude)) / 2), 2)
                + COS(RADIANS(mtsmr.Station_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                POWER(SIN((RADIANS(h.Housing_Longitude - mtsmr.Station_Longitude)) / 2), 2 )))) AS Distance
        FROM mass_transit_station_match_route mtsmr
        left join mass_transit_route mtr on mtsmr.Route_Code = mtr.Route_Code
        cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
        cross join (select * from housing where Housing_Status = '1' and Housing_Latitude is not null AND Housing_Longitude is not null) h) aaa  
where aaa.Distance <= aaa.cal_radians;


-- view source_housing_around_express_way
create or replace view source_housing_around_express_way as
select Place_ID
    , Place_Attribute_1
    , Place_Attribute_2
    , Housing_Code
    , Distance
from (SELECT rpe.Place_ID
            , rpe.Place_Attribute_1
            , rpe.Place_Attribute_2
            , rpe.Place_Latitude
            , rpe.Place_Longitude
            , asok.Station_Latitude as asok_lat
            , asok.Station_Longitude as asok_long
            , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpe.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpe.Place_Latitude)) *
                POWER(SIN((RADIANS(rpe.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) AS station_distance
            , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpe.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpe.Place_Latitude)) *
                POWER(SIN((RADIANS(rpe.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
            , h.Housing_Code
            , h.Housing_Latitude
            , h.Housing_Longitude
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rpe.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rpe.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                POWER(SIN((RADIANS(h.Housing_Longitude - rpe.Place_Longitude)) / 2), 2 )))) AS Distance
        FROM real_place_express_way rpe
        cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
        cross join (select * from housing where Housing_Status = '1' and Housing_Latitude is not null AND Housing_Longitude is not null) h) aaa  
where aaa.Distance <= aaa.cal_radians;

-- view source_housing_factsheet_view
create or replace view source_housing_factsheet_view as
select a.Housing_Code
    , h_nun(rs.SubDistrict_Name) as RealDistrict
    , h_nun(td.name_th) as District
    , h_nun(tp.name_th) as Province
    , h_nun(express_way.Express_Way) as Express_Way
    , h_nun(station.Station_Name) as Station_Name
    , h_nun(ifnull(housing_type.Housing_Category
        , ifnull(concat_ws(', ',if(a.IS_SD=1,'บ้านเดี่ยว',null),if(a.IS_DD=1,'บ้านแฝด',null),if(a.IS_TH=1,'ทาวน์โฮม',null)
                , if(a.IS_HO=1,'โฮมออฟฟิศ',null), if(a.IS_SH=1,'อาคารพาณิชย์',null))
            , null))) as Housing_Type
    , h_nun(concat(format(a.Housing_TotalRai,2),' ไร่')) as Housing_TotalRai
    , h_nun(ifnull(concat(housing_type.Total_Unit,' หลัง')
                , concat(a.Housing_TotalUnit,' หลัง'))) as TotalUnit
    , h_nun(year(a.Housing_Built_Start)) as Housing_Built_Start
    , h_nun(concat("(",if(month(sold_status.Data_Date)<10
                        , concat('0',month(sold_status.Data_Date),'/',year(sold_status.Data_Date))
                        , concat(month(sold_status.Data_Date),'/',year(sold_status.Data_Date)))
            ,")")) as Housing_Sold_Status_Date
    , h_nun(concat(format(sold_status.Data_Value,0),'% SOLD')) as Housing_Sold_Status
    , h_nun(concat(housing_type.Housing_Type_Count,' แบบ')) as Housing_Type_Count
    , h_nun(if(housing_type.Floor is not null
            , housing_type.Floor
            , if(a.Housing_Floor_Min is not null and a.Housing_Floor_Max is not null
                , if(a.Housing_Floor_Min=a.Housing_Floor_Max
                    , concat(if(mod(a.Housing_Floor_Min,1)=0,round(a.Housing_Floor_Min),a.Housing_Floor_Min),' ชั้น')
                    , concat(if(mod(a.Housing_Floor_Min,1)=0,round(a.Housing_Floor_Min),a.Housing_Floor_Min),' - '
                            ,if(mod(a.Housing_Floor_Max,1)=0,round(a.Housing_Floor_Max),a.Housing_Floor_Max),' ชั้น'))
                , concat(ifnull(if(mod(a.Housing_Floor_Max,1)=0,round(a.Housing_Floor_Max),a.Housing_Floor_Max),
                            if(mod(a.Housing_Floor_Min,1)=0,round(a.Housing_Floor_Min),a.Housing_Floor_Min)),' ชั้น')))) as Floor
    , h_nun(ifnull(housing_type.Bedroom
            , if(a.Bedroom_Min is not null and a.Bedroom_Max is not null
                , if(a.Bedroom_Min=a.Bedroom_Max
                    , concat(a.Bedroom_Min,' ห้อง')
                    , concat(a.Bedroom_Min,' - ',a.Bedroom_Max,' ห้อง'))
                , ifnull(concat(ifnull(a.Bedroom_Max,a.Bedroom_Min),' ห้อง'), null)))) as Bedroom
    , h_nun(ifnull(housing_type.Bathroom
            , if(a.Bathroom_Min is not null and a.Bathroom_Max is not null
                , if(a.Bathroom_Min=a.Bathroom_Max
                    , concat(a.Bathroom_Min,' ห้อง')
                    , concat(a.Bathroom_Min,' - ',a.Bathroom_Max,' ห้อง'))
                , ifnull(concat(ifnull(a.Bathroom_Max,a.Bathroom_Min),' ห้อง'), null)))) as Bathroom
    , h_nun(ifnull(housing_type.Parking
            , if(a.Housing_Parking_Min is not null and a.Housing_Parking_Max is not null
                , if(a.Housing_Parking_Min=a.Housing_Parking_Max
                    , concat(a.Housing_Parking_Min,' คัน')
                    , concat(a.Housing_Parking_Min,' - ',a.Housing_Parking_Max,' คัน'))
                , ifnull(concat(ifnull(a.Housing_Parking_Max,a.Housing_Parking_Min),' คัน'), null)))) as Parking_Amount
    , h_nun(faci.Top_Facilities) as Top_Facilities
    , if(a.Pool = 3
            , "-"
            , if(a.Pool_Width is not null and a.Pool_Length is not null
                , h_nun(concat(a.Pool_Width,' x ',a.Pool_Length,' ม.'))
                , h_nun(concat(COALESCE(a.Pool_Width, a.Pool_Length), ' ม.')))) as 'Pool'
    , h_nun(a.Entrance) as Entrance
    , h_nun(if(a.Main_Road is not null and a.Sub_Road is not null
            , if(a.Main_Road = a.Sub_Road
                , concat(a.Main_Road,' ม.')
                , concat(a.Main_Road,' ม. , ',a.Sub_Road,' ม.'))
            , ifnull(concat(a.Main_Road,' ม.')
                , ifnull(concat(a.Sub_Road,' ม.'), null)))) as Road
    , h_nun(ifnull(housing_type.Price
            , if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
                , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                    , concat(format(a.Housing_Price_Min/1000000,1),' ลบ.')
                    , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1),' ลบ.'))
                , ifnull(concat(format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1),' ลบ.'), null)))) as Price
    , h_nun(ifnull(concat("(",if(month(housing_type.Price_Date)<10
                                , concat('0',month(housing_type.Price_Date),'/',year(housing_type.Price_Date))
                                , concat(month(housing_type.Price_Date),'/',year(housing_type.Price_Date))), ")")
                , ifnull(concat("(",if(month(a.Housing_Price_Date)<10
                                    , concat('0',month(a.Housing_Price_Date),'/',year(a.Housing_Price_Date))
                                    , concat(month(a.Housing_Price_Date),'/',year(a.Housing_Price_Date))), ")"), null))) as Price_Date
    , h_nun(ifnull(concat("(", year(housing_type.Price_Date), ")")
                , ifnull(concat("(", year(a.Housing_Price_Date), ")"), null))) as Year_Price_Date
    , h_nun(ifnull(housing_type.Area
            , if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
                , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                    , concat(format(a.Housing_Area_min,0),' ตร.ว.')
                    , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0),' ตร.ว.'))
                , ifnull(concat(format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0),' ตร.ว.'), null)))) as Housing_Area
    , h_nun(ifnull(housing_type.Usable_Area
            , if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
                , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                    , concat(format(a.Housing_Usable_Area_Min,0),' ตร.ม.')
                    , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0),' ตร.ม.'))
                , ifnull(concat(format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0),' ตร.ม.'), null)))) as Usable_Area
    , concat(h_nun(if(a.Housing_Common_Fee_Min is not null and a.Housing_Common_Fee_Max is not null
            , if(format(a.Housing_Common_Fee_Min,0)=format(a.Housing_Common_Fee_Max,0)
                , format(a.Housing_Common_Fee_Min,0)
                , concat(format(a.Housing_Common_Fee_Min,0),' - ',format(a.Housing_Common_Fee_Max,0)))
            , format(ifnull(a.Housing_Common_Fee_Max,a.Housing_Common_Fee_Min),0))),' บ./ตร.ว./เดือน') as Common_Fee
from housing a
left join thailand_district td on a.District_ID = td.district_code
left join thailand_province tp on a.Province_ID = tp.province_code
left join real_yarn_main rm on a.RealDistrict_Code = rm.District_Code
left join real_yarn_sub rs on a.RealSubDistrict_Code = rs.SubDistrict_Code
left join ( select Housing_Code,concat(Place_Attribute_1,' ',Place_Attribute_2) as Express_Way
            from (  select Housing_Code
                            , Place_ID
                            , Place_Attribute_1
                            , Place_Attribute_2
                            , Distance
                            , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                    from housing_around_express_way
                    order by Housing_Code) ew
            where ew.RowNum = 1 ) express_way 
on a.Housing_Code = express_way.Housing_Code
left join ( select Housing_Code,Station_THName_Display as Station_Name
            from (  select Housing_Code
                            , Station_Code
                            , Station_THName_Display
                            , Distance
                            , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                    from housing_around_station
                    order by Housing_Code) ew
            where ew.RowNum = 1 ) station 
on a.Housing_Code = station.Housing_Code
left join ( select h.Housing_Code
                , group_concat(DISTINCT h.Housing_Category separator ',') as Housing_Category
                , sum(h.Total_Unit) as Total_Unit
                , count(*) as Housing_Type_Count
                , if(min(h.Floor)=max(h.Floor)
                    , if(round(min(h.Floor),1) = floor(min(h.floor)) + 0.5
                        , concat(round(min(h.Floor),1),' ชั้น')
                        , concat(floor(min(h.Floor)),' ชั้น'))
                    , if((round(min(h.Floor),1) = floor(min(h.floor))+0.5) and (round(max(h.Floor),1) = floor(max(h.floor))+0.5)
                        , concat(round(min(h.Floor),1),' - ',round(max(h.Floor),1),' ชั้น')
                        , if((round(min(h.Floor),1) = floor(min(h.floor))+0.5) and (round(max(h.Floor),1) <> floor(max(h.floor))+0.5)
                            , concat(round(min(h.Floor),1),' - ',floor(max(h.Floor)),' ชั้น')
                            , if((round(min(h.Floor),1) <> floor(min(h.floor))+0.5) and (round(max(h.Floor),1) = floor(max(h.floor))+0.5)
                                , concat(floor(min(h.Floor)),' - ',round(max(h.Floor),1),' ชั้น')
                                , concat(floor(min(h.Floor)),' - ',floor(max(h.Floor)),' ชั้น'))))) as Floor
                , if(min(h.Bedroom)=max(h.Bedroom)
                    , concat(min(h.Bedroom),' ห้อง')
                    , concat(min(h.Bedroom),' - ',max(h.Bedroom),' ห้อง')) as Bedroom
                , if(min(h.Bathroom)=max(h.Bathroom)
                    , concat(min(h.Bathroom),' ห้อง')
                    , concat(min(h.Bathroom),' - ',max(h.Bathroom),' ห้อง')) as Bathroom
                , if(min(h.Parking)=max(h.Parking)
                    , concat(min(h.Parking),' คัน')
                    , concat(min(h.Parking),' - ',max(h.Parking),' คัน')) as Parking
                , if(a.Min_Price = a.Max_Price
                    , concat(format(a.Min_Price/1000000,1), ' ลบ.')
                    , concat(format(a.Min_Price/1000000,1),' - ',format(a.Max_Price/1000000,1),' ลบ.')) as Price
                , a.Price_Date as Price_Date
                , if(format(a.Min_Area,0) = format(a.Max_Area,0)
                    , concat(format(a.Min_Area,0),' ตร.ว.')
                    , concat(format(a.Min_Area,0),' - ',format(a.Max_Area,0),' ตร.ว.')) as Area
                , if(min(h.Housing_Usable_Area)=max(h.Housing_Usable_Area)
                    , concat(round(min(h.Housing_Usable_Area)),' ตร.ม.')
                    , concat(round(min(h.Housing_Usable_Area)),' - ',round(max(h.Housing_Usable_Area)),' ตร.ม.')) as Usable_Area
            from housing_full_template_housing_type h
            left join ( SELECT h.Housing_Code
                            , MIN(Price) AS Min_Price
                            , MAX(Price) AS Max_Price
                            , if((select Price_Date from housing_full_template_housing_type where Housing_Code = Housing_Code and Housing_Type_Status = 1 and Price_Min = MIN(Price) limit 1) is not null
                                and (select Price_Date from housing_full_template_housing_type where Housing_Code = Housing_Code and Housing_Type_Status = 1 and Price_Max = MAX(Price) limit 1) is not null
                                , greatest((select Price_Date from housing_full_template_housing_type where Housing_Code = Housing_Code and Housing_Type_Status = 1 and Price_Min = MIN(Price) limit 1)
                                    , (select Price_Date from housing_full_template_housing_type where Housing_Code = Housing_Code and Housing_Type_Status = 1 and Price_Max = MAX(Price) limit 1))
                                , ifnull((select Price_Date from housing_full_template_housing_type where Housing_Code = Housing_Code and Housing_Type_Status = 1 and Price_Min = MIN(Price) limit 1)
                                    , ifnull((select Price_Date from housing_full_template_housing_type where Housing_Code = Housing_Code and Housing_Type_Status = 1 and Price_Max = MAX(Price) limit 1)
                                        , null))) as Price_Date
                            , MIN(Area) AS Min_Area
                            , MAX(Area) AS Max_Area
                        FROM housing_full_template_housing_type h
                        left join ( SELECT Housing_Code
                                        , Price_Min AS Price
                                        , Price_Date
                                    FROM housing_full_template_housing_type
                                    WHERE Housing_Type_Status = 1 AND Price_Min IS NOT NULL AND Price_Min <> 0
                                    UNION ALL
                                    SELECT Housing_Code
                                        , Price_Max AS Price
                                        , Price_Date
                                    FROM housing_full_template_housing_type
                                    WHERE Housing_Type_Status = 1 AND Price_Max IS NOT NULL AND Price_Max <> 0) AS price_data
                        on h.Housing_Code = price_data.Housing_Code
                        left join ( select Housing_Code
                                        , Housing_Area_Min as Area
                                    from housing_full_template_housing_type
                                    WHERE Housing_Type_Status = 1 and Housing_Area_Min is not null AND Housing_Area_Min <> 0
                                    UNION ALL
                                    select Housing_Code
                                        , Housing_Area_Max as Area
                                    from housing_full_template_housing_type
                                    WHERE Housing_Type_Status = 1 and Housing_Area_Max is not null AND Housing_Area_Max <> 0) area
                        on h.Housing_Code = area.Housing_Code
                        GROUP BY h.Housing_Code) a
            on h.Housing_Code = a.Housing_Code
            WHERE h.Housing_Type_Status = 1
            GROUP BY h.Housing_Code) housing_type
on a.Housing_Code = housing_type.Housing_Code
left join (SELECT a.Housing_Code
                , SUBSTRING_INDEX(GROUP_CONCAT(Element_Name SEPARATOR ', '), ', ', 2) AS Top_Facilities
            FROM housing_full_template_facilities_raw_view a
            inner join (SELECT Housing_Code, Show_Faci_order, MIN(RowNum) as RowNum
                        FROM housing_full_template_facilities_raw_view
                        WHERE Show_Faci_order > 1
                        GROUP BY Housing_Code, Show_Faci_order) b
            on a.Housing_Code = b.Housing_Code and a.Show_Faci_order = b.Show_Faci_order and a.RowNum = b.RowNum
            group by a.Housing_Code) faci
on a.Housing_Code = faci.Housing_Code
left join (SELECT Housing_Code, Data_Date, Data_Attribute, Data_Value, Data_Note, Price_Source, Full_Price_Source
            from (select Housing_Code
                    , Data_Date
                    , Data_Attribute
                    , Data_Value
                    , Data_Note
                    , Price_Source
                    , Full_Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Data_Date desc) AS Myorder
                    from (	select * from (	select rc561.Condo_Code as Housing_Code
                                                , rc561.Data_Date
                                                , rc561.Data_Attribute
                                                , rc561.Data_Value
                                                , rc561.Data_Note
                                                , ps.Head as Price_Source
                                                , ps.Sub as Full_Price_Source
                                            from real_condo_561 rc561
                                            cross join (select ID, Head, Sub from price_source where Sub = 'Company Presentation - 56-1') ps
                                            where rc561.Data_Status = 1
                                            and rc561.Data_Attribute = 'sold_percent'
                                            and rc561.Condo_Code LIKE 'HP%') order_561_mb
                            union all select * from (select Housing_Code
                                                    , Housing_Sold_Status_Date as Data_Date
                                                    , 'sold_percent' as Data_Attribute
                                                    , Housing_Sold_Status_Raw_Number as Data_Value
                                                    , '' as Data_Note
                                                    , '' as Price_Source
                                                    , '' as Full_Price_Source
                                                    from housing
                                                    where Housing_Sold_Status_Date is not null) sold_status_housing) all_sold) sold
            where Myorder = 1) sold_status
on a.Housing_Code = sold_status.Housing_Code
where a.Housing_Status = '1'
and a.Housing_Latitude is not null
AND a.Housing_Longitude is not null
and a.Housing_ENName is not null
order by a.Housing_Code;


-- view source_housing_fetch_for_map
create or replace view source_housing_fetch_for_map as
select a.Housing_ID as Housing_ID
    , a.Housing_Code as Housing_Code
    , a.Housing_ENName as Housing_ENName
    , b.Housing_Type
    , b.Price
    , b.Housing_Area
    , b.Usable_Area
    , if(a.Housing_Built_Start is null
        , if(a.Housing_Built_Finished is null
            , NULL
            , a.Housing_Built_Finished)
        , a.Housing_Built_Start) AS Housing_Build_Date
    , replace(replace(replace(replace(replace(a.Housing_Name, '\n', ''), '-', ''),'(',''),')',''),' ','') AS Housing_Name_Search
    , replace(replace(replace(replace(replace(a.Housing_ENName, '\n', ''), '-', ''),'(',''),')',''),' ','') AS Housing_ENName_Search
    , a.Housing_ScopeArea
    , a.Housing_Latitude
    , a.Housing_Longitude
    , a.Brand_Code AS Brand_Code
    , a.Developer_Code AS Developer_Code
    , a.RealSubDistrict_Code AS RealSubDistrict_Code
    , a.RealDistrict_Code AS RealDistrict_Code
    , a.SubDistrict_ID AS SubDistrict_ID
    , a.District_ID AS District_ID
    , a.Province_ID AS Province_ID
    , a.Housing_URL_Tag AS Housing_URL_Tag
    , a.Housing_Cover AS Housing_Cover
    , express_way.Housing_around_express_way as Express_Way
    , station.Housing_around_station as Station
    , ifnull(a.Price_Min_Point, 0) + ifnull(a.No_of_Unit_Point, 0) + ifnull(a.Age_Point, 0) + ifnull(a.ListCompany_Point, 0)
        + ifnull(a.DistanceFromStation_Point, 0) + ifnull(a.DistanceFromExpressway_Point , 0)
        + ifnull(a.Realist_Score, 0) as Total_Point
    , if(a.Housing_Built_Start is null
        , if(a.Housing_Built_Finished is null
            , NULL
            , year(curdate()) - year(a.Housing_Built_Finished))
        , year(curdate()) - year(a.Housing_Built_Start)) as Housing_Age
    , a.Housing_Area_Min as Housing_Area_Min
    , a.Housing_Area_Max as Housing_Area_Max
    , a.Housing_Usable_Area_Min as Usable_Area_Min
    , a.Housing_Usable_Area_Max as Usable_Area_Max
    , a.Housing_Price_Min as Price_Min
    , a.Housing_Price_Max as Price_Max
    , if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
                , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                    , format(a.Housing_Price_Min/1000000,1)
                    , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1)))
                , format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1)) as Price_Carousel
    , if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
                , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                    , format(a.Housing_Area_min,0)
                    , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0)))
                , format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0)) as Housing_Area_Carousel
    , if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
                , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                    , format(a.Housing_Usable_Area_Min,0)
                    , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0)))
                , format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0)) as Usable_Area_Carousel
    , housing_line.Housing_Around_Line as Housing_Around_Line
    , concat_ws('', housing_spotlight.Spotlight_List, housing_spotlight_manual.Spotlight_List)  as Spotlight_List
    , a.Housing_TotalUnit as TotalUnit
    , a.Housing_TotalRai as TotalRai
    , a.Housing_Common_Fee_Min as Common_Fee_Min
    , a.Housing_Common_Fee_Max as Common_Fee_Max
    , a.Bedroom_Min as Bedroom_Min
    , a.Bedroom_Max as Bedroom_Max
    , a.Bathroom_Min as Bathroom_Min
    , a.Bathroom_Max as Bathroom_Max
    , a.Housing_Parking_Min as Parking_Min
    , a.Housing_Parking_Max as Parking_Max
    , concat_ws(' ', replace(a.Housing_ENName, '\n', ' '), concat('(', replace(a.Housing_Name, '\n', ' '), ')'), '| REAL DATA') as Housing_Title
    , concat_ws(' ', replace(a.Housing_ENName, '\n', ' ')
        , CASE 
            WHEN (LENGTH(b.Housing_Type) - LENGTH(REPLACE(b.Housing_Type, ', ', ''))) < 3
            THEN REPLACE(b.Housing_Type, ', ', 'และ') 
            ELSE CONCAT(SUBSTRING_INDEX(b.Housing_Type, ', ', (LENGTH(b.Housing_Type) - LENGTH(REPLACE(b.Housing_Type, ', ', ''))) / 2), 'และ', 
            SUBSTRING_INDEX(b.Housing_Type, ', ', -1))
            END
        , if(a.Province_ID = 10
            , concat('ย่าน', rs.SubDistrict_Name )
            , concat('เขต', td.name_th, ' ในจังหวด', tp.name_th))
        , concat('จำนวน ', a.Housing_TotalUnit, ' หลัง')
        , concat('ราคาเริ่มต้น ', replace(replace(b.Price, ' ลบ.', ''), ' ', ''), ' ลบ.')
        , concat('พื้นที่ใช้สอย ', replace(replace(b.Usable_Area, ' ตร.ม.', ''), ' ', ''), ' ตร.ม.')
        , ifnull(concat('ใกล้ทางด่วน', express_way2.Express_Way)
            , concat('มี '
                , if(a.Bedroom_Min is not null and a.Bedroom_Max is not null
                    , concat(a.Bedroom_Min, '-', a.Bedroom_Max)
                    , a.Bedroom_Min), ' ห้องนอน '
                , if(a.Bathroom_Min is not null and a.Bathroom_Max is not null
                    , concat(a.Bathroom_Min, '-', a.Bathroom_Max)
                    , a.Bathroom_Min), ' ห้องน้ำ'))) as Housing_Description
from housing a 
left join housing_factsheet_view b on a.Housing_Code = b.Housing_Code
left join thailand_district td on a.District_ID = td.district_code
left join real_yarn_sub rs on a.RealSubDistrict_Code = rs.SubDistrict_Code
left join thailand_province tp on a.Province_ID = tp.province_code
left join ( select Housing_Code,concat(Place_Attribute_1,' ',Place_Attribute_2) as Express_Way
            from (  select Housing_Code
                            , Place_ID
                            , Place_Attribute_1
                            , Place_Attribute_2
                            , Distance
                            , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                    from housing_around_express_way
                    order by Housing_Code) ew
            where ew.RowNum = 1 ) express_way2
on a.Housing_Code = express_way2.Housing_Code
left join (select housing_around_station.Housing_Code AS Housing_Code,
                group_concat(
                    '[',
                    housing_around_station.Station_Code,
                    ']' separator ''
                ) AS Housing_around_station
            from
                housing_around_station
            group by
                housing_around_station.Housing_Code) station 
on a.Housing_Code = station.Housing_Code
left join (select housing_around_express_way.Housing_Code AS Housing_Code,
                group_concat(
                    '[',
                    housing_around_express_way.Place_ID,
                    ']' separator ''
                ) AS Housing_around_express_way
            from
                housing_around_express_way
            group by
                housing_around_express_way.Housing_Code) express_way 
on a.Housing_Code = express_way.Housing_Code
left join ( select Housing_Code
                , group_concat('[',Line_Code,']' separator '') AS `Housing_Around_Line`
            from ( SELECT Housing_Code
                        , Line_Code
                    FROM `housing_around_station`
                    group by Housing_Code,Line_Code) h_line
            group by Housing_Code) housing_line
on b.Housing_Code = housing_line.Housing_Code
left join ( select Housing_Code
                , group_concat('[',Spotlight_Code,']' separator '') AS `Spotlight_List`
            from ( SELECT Housing_Code
                        , Spotlight_Code
                    FROM `housing_spotlight_relationship`
                    group by Housing_Code,Spotlight_Code) h_spotlight
            group by Housing_Code) housing_spotlight
on b.Housing_Code = housing_spotlight.Housing_Code
left join ( select Housing_Code
                , group_concat('[',Spotlight_Code,']' separator '') AS `Spotlight_List`
            from ( SELECT Housing_Code
                        , Spotlight_Code
                    FROM `housing_spotlight_relationship_manual`
                    group by Housing_Code,Spotlight_Code) h_spotlight
            group by Housing_Code) housing_spotlight_manual
on b.Housing_Code = housing_spotlight_manual.Housing_Code
where a.Housing_Status = '1'
and a.Housing_ENName is not null
and a.Housing_Latitude is not null
AND a.Housing_Longitude is not null
order by a.Housing_ID;

-- view source_article_housing_fetch_for_map
create or replace view source_article_housing_fetch_for_map as
SELECT
    `b`.`Housing_ID` AS `Housing_ID`,
    `b`.`Housing_Code` AS `Housing_Code`,
    `b`.`Housing_ENName` AS `Housing_ENName`,
    `b`.`Housing_Name_Search` AS `Housing_Name_Search`,
    `b`.`Housing_ENName_Search` AS `Housing_ENName_Search`,
    `b`.`Housing_Latitude` AS `Housing_Latitude`,
    `b`.`Housing_Longitude` AS `Housing_Longitude`,
    `c`.`ID` AS `ID`,
    `c`.`post_date` AS `post_date`,
    `c`.`post_name` AS `post_name`,
    `c`.`post_title` AS `post_title`,
    `b`.`RealDistrict_Code` AS `RealDistrict_Code`,
    `b`.`RealSubDistrict_Code` AS `RealSubdistrict_Code`,
    `b`.`Province_ID` AS `Province_ID`,
    b.Housing_Type as Housing_Type,
    b.Spotlight_List as Spotlight_List
FROM
    (
        (
            `wp_postmeta` `a`
            join `housing_fetch_for_map` `b` on((upper(`a`.`meta_value`) = `b`.`Housing_Code`))
        )
        join `wp_posts` `c` on((`a`.`post_id` = `c`.`ID`))
    )
WHERE
    (
        (`a`.`meta_key` = 'aaa_housing')
        AND (`c`.`post_status` = 'publish')
        AND (`c`.`post_password` = '')
    );