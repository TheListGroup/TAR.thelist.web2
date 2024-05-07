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
    , h_nun(if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
            , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                , concat(format(a.Housing_Area_min,0),' ตร.ว.')
                , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0),' ตร.ว.'))
            , concat(format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0),' ตร.ว.'))) as Housing_Area
    , h_nun(if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
            , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                , concat(format(a.Housing_Usable_Area_Min,0),' ตร.ม.')
                , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0),' ตร.ม.'))
            , concat(format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0),' ตร.ม.'))) as Usable_Area
    , h_nun(if(a.Bedroom_Min is not null and a.Bedroom_Max is not null
            , if(a.Bedroom_Min=a.Bedroom_Max
                , concat(a.Bedroom_Min,' ห้อง')
                , concat(a.Bedroom_Min,' - ',a.Bedroom_Max,' ห้อง'))
            , concat(ifnull(a.Bedroom_Max,a.Bedroom_Min),' ห้อง'))) as Bedroom
    , h_nun(year(a.Housing_Price_Date)) as Price_Date
    , h_nun(if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
            , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                , concat(format(a.Housing_Price_Min/1000000,1),' ลบ.')
                , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1),' ลบ.'))
            , concat(format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1),' ลบ.'))) as Price
    , h_nun(express_way.Express_Way) as Express_Way
    , h_nun(rd.District_Name) as RealDistrict 
    , h_nun(td.name_th) as District
    , h_nun(tp.name_th) as Province
    , h_nun(concat_ws(', ',if(a.IS_SD=1,'บ้านเดี่ยว',null),if(a.IS_DD=1,'บ้านแฝด',null),if(a.IS_TH=1,'ทาวน์โฮม',null)
                        , if(a.IS_HO=1,'โฮมออฟฟิศ',null), if(a.IS_SH=1,'อาคารพาณิชย์',null))) as Housing_Type
    , h_nun(concat(format(a.Housing_TotalRai,2),' ไร่')) as Housing_TotalRai
    , h_nun(concat(a.Housing_TotalUnit,' หลัง')) as TotalUnit
    , h_nun(year(a.Housing_Built_Start)) as Housing_Built_Start
    , h_nun(year(a.Housing_Sold_Status_Date)) as Housing_Sold_Status_Date
    , h_nun(a.Housing_Sold_Status_Raw_Number) as Housing_Sold_Status
    , h_nun(if(a.Housing_Floor_Min is not null and a.Housing_Floor_Max is not null
            , if(a.Housing_Floor_Min=a.Housing_Floor_Max
                , concat(a.Housing_Floor_Min,' ชั้น')
                , concat(a.Housing_Floor_Min,' - ',a.Housing_Floor_Max,' ชั้น'))
            , concat(ifnull(a.Housing_Floor_Max,a.Housing_Floor_Min),' ชั้น'))) as Floor
    , h_nun(if(a.Bedroom_Min is not null and a.Bedroom_Max is not null
            , if(a.Bedroom_Min=a.Bedroom_Max
                , concat(a.Bedroom_Min,' ห้อง')
                , concat(a.Bedroom_Min,' - ',a.Bedroom_Max,' ห้อง'))
            , concat(ifnull(a.Bedroom_Max,a.Bedroom_Min),' ห้อง'))) as Bedroom_Factsheet
    , h_nun(if(a.Bathroom_Min is not null and a.Bathroom_Max is not null
            , if(a.Bathroom_Min=a.Bathroom_Max
                , concat(a.Bathroom_Min,' ห้อง')
                , concat(a.Bathroom_Min,' - ',a.Bathroom_Max,' ห้อง'))
            , concat(ifnull(a.Bathroom_Max,a.Bathroom_Min),' ห้อง'))) as Bathroom
    , h_nun(if(a.Housing_Parking_Min is not null and a.Housing_Parking_Max is not null
            , if(a.Housing_Parking_Min=a.Housing_Parking_Max
                , concat(a.Housing_Parking_Min,' คัน')
                , concat(a.Housing_Parking_Min,' - ',a.Housing_Parking_Max,' คัน'))
            , concat(ifnull(a.Housing_Parking_Max,a.Housing_Parking_Min),' คัน'))) as Parking_Amount
    , h_nun(year(a.Housing_Price_Date)) as Price_Date_Factsheet
    , h_nun(if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
            , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                , concat(format(a.Housing_Price_Min/1000000,1),' ลบ.')
                , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1),' ลบ.'))
            , concat(format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1),' ลบ.'))) as Price_Factsheet
    , h_nun(if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
            , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                , concat(format(a.Housing_Area_min,0),' ตร.ว.')
                , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0),' ตร.ว.'))
            , concat(format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0),' ตร.ว.'))) as Housing_Area_Factsheet
    , h_nun(if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
            , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                , concat(format(a.Housing_Usable_Area_Min,0),' ตร.ม.')
                , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0),' ตร.ม.'))
            , concat(format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0),' ตร.ม.'))) as Usable_Area_Factsheet
    , h_nun(if(a.Housing_Common_Fee_Min is not null and a.Housing_Common_Fee_Max is not null
            , if(format(a.Housing_Common_Fee_Min,0)=format(a.Housing_Common_Fee_Max,0)
                , concat(format(a.Housing_Common_Fee_Min,0),' บ./ตร.ว./เดือน')
                , concat(format(a.Housing_Common_Fee_Min,0),' - ',format(a.Housing_Common_Fee_Max,0),' บ./ตร.ว./เดือน'))
            , concat(format(ifnull(a.Housing_Common_Fee_Max,a.Housing_Common_Fee_Min),0),' บ./ตร.ว./เดือน'))) as Common_Fee
from housing a
left join realist_district rd on a.RealDistrict_Code = rd.District_Code
left join thailand_district td on a.District_ID = td.district_code
left join thailand_province tp on a.Province_ID = tp.province_code
left join ( select Housing_Code,concat(Place_Attribute_1,' ',Place_Attribute_2) as Express_Way
            from (  select Housing_Code
                            , Place_ID
                            , Place_Attribute_1
                            , Place_Attribute_2
                            , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                    from housing_around_express_way
                    order by Housing_Code) ew
            where ew.RowNum = 1 ) express_way 
on a.Housing_Code = express_way.Housing_Code
where a.Housing_Status = '1'
and a.Housing_Latitude is not null
AND a.Housing_Longitude is not null
and a.Housing_ENName is not null;


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
from housing a 
left join housing_factsheet_view b on a.Housing_Code = b.Housing_Code
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
AND a.Housing_Longitude is not null;

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