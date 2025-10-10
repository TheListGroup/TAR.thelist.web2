-- source_office_around_station
-- source_office_around_express_way
-- source_office_image_all
-- source_office_image_carousel (unit)
-- source_office_image_carousel_random (unit)
-- source_office_unit_carousel_recommend
-- source_office_project_carousel_recommend


-- view source_office_around_station
create or replace view source_office_around_station as
select Station_Code
    , Station_THName_Display
    , Route_Code
    , Line_Code
    , MTran_ShortName
    , Project_ID
    , Distance
from (SELECT mtsmr.Station_Code
            , mtsmr.Station_THName_Display
            , mtsmr.Route_Code
            , mtr.Line_Code
            , mtsmr.Station_Latitude
            , mtsmr.Station_Longitude
            , o.Project_ID
            , o.Latitude
            , o.Longitude
            , mt.MTran_ShortName
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - mtsmr.Station_Latitude)) / 2), 2)
                + COS(RADIANS(mtsmr.Station_Latitude)) * COS(RADIANS(o.Latitude)) *
                POWER(SIN((RADIANS(o.Longitude - mtsmr.Station_Longitude)) / 2), 2 )))) AS Distance
        FROM mass_transit_station_match_route mtsmr
        left join mass_transit_route mtr on mtsmr.Route_Code = mtr.Route_Code
        left join mass_transit_line mtl on mtr.Line_Code = mtl.Line_Code
        left join mass_transit mt on mtl.MTrand_ID = mt.MTran_ID
        cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
where Distance <= 0.8;

-- view source_office_around_express_way
create or replace view source_office_around_express_way as
select Place_ID
    , Place_Type
    , Place_Category
    , Place_Name
    , Place_Latitude
    , Place_Longitude
    , Project_ID
    , Distance
from (SELECT ew.Place_ID 
            , ew.Place_Type
            , ew.Place_Category
            , ew.Place_Name
            , ew.Place_Latitude
            , ew.Place_Longitude
            , o.Project_ID
            , o.Latitude
            , o.Longitude
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - ew.Place_Latitude)) / 2), 2)
                + COS(RADIANS(ew.Place_Latitude)) * COS(RADIANS(o.Latitude)) *
                POWER(SIN((RADIANS(o.Longitude - ew.Place_Longitude)) / 2), 2 )))) AS Distance
        FROM real_place_express_way ew
        cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
where Distance <= 2.0;

-- view source_office_image_all
create or replace view source_office_image_all as
select * from (
                select 'Project_Image' as Image_Type
                    , a.Image_ID
                    , a.Category_ID
                    , b.Category_Name
                    , b.Section
                    , b.Display_Order as Category_Order
                    , a.Ref_ID
                    , a.Image_Name
                    , a.Image_URL
                    , a.Display_Order
                from office_image a
                join office_image_category b on a.Category_ID = b.Category_ID
                where Project_or_Building = 'Project'
                and Image_Status = '1') proj
union all 
select * from (
                select 'Unit_Image' as Image_Type
                , a.Unit_Image_ID as Image_ID
                , a.Unit_Category_ID as Category_ID
                , b.Category_Name
                , b.Section
                , b.Display_Order as Category_Order
                , a.Unit_ID as Ref_ID
                , a.Image_Name
                , a.Image_URL
                , a.Display_Order
                from office_unit_image a
                join office_unit_image_category b on a.Unit_Category_ID = b.Unit_Category_ID
                where Image_Status = '1') unit
union all 
select * from (
                select 'Cover_Project' as Image_Type
                , Cover_ID as Image_ID
                , 0 as Category_ID
                , 'Cover' as Category_Name
                , 'Cover' as Section
                , 0 as Category_Order
                , Ref_ID as Ref_ID
                , 'Cover' as Image_Name
                , Cover_Url
                , 0 as Display_Order
                from office_cover
                where Cover_Status = '1'
                and Project_or_Building = 'Project'
                and Cover_Size = 1440) cover;

-- view source_office_image_carousel
create or replace view source_office_image_carousel as
select 
    u.Unit_ID
    , if(unit_image_count.Unit_Image_Count >= 4
        , concat('[',concat_ws(',', group_concat(DISTINCT gallery4.Unit_Gallery SEPARATOR ', '), group_concat(DISTINCT proj_gallery1.Project_Image SEPARATOR ', ')),']')
        , if(unit_image_count.Unit_Image_Count = 3
            , concat('[',concat_ws(',', group_concat(DISTINCT gallery3.Unit_Gallery SEPARATOR ', '), group_concat(DISTINCT proj_gallery2.Project_Image SEPARATOR ', ')),']')
            , if(unit_image_count.Unit_Image_Count = 2
                , concat('[',concat_ws(',', group_concat(DISTINCT gallery2.Unit_Gallery SEPARATOR ', '), group_concat(DISTINCT proj_gallery3.Project_Image SEPARATOR ', ')),']')
                , if(unit_image_count.Unit_Image_Count = 1
                    , concat('[',concat_ws(',', group_concat(DISTINCT gallery1.Unit_Gallery SEPARATOR ', '), group_concat(DISTINCT proj_gallery4.Project_Image SEPARATOR ', ')),']')
                    , concat('[',group_concat(DISTINCT proj_gallery5.Project_Image SEPARATOR ', '), ']'))))) as Image_Set
from office_unit u
join office_building b on u.Building_ID = b.Building_ID
join office_project p on b.Project_ID = p.Project_ID
left join (select Ref_ID, count(*) as Unit_Image_Count
            from source_office_image_all
            where Image_Type = 'Unit_Image'
            group by Ref_ID) unit_image_count
on u.Unit_ID = unit_image_count.Ref_ID
left join (select Ref_ID 
        , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                    , concat('"Image_Name": "', Image_Name,'"')
                    , concat('"Category_Order": ', Category_Order)
                    , concat('"Display_Order": ', Display_Order)
                    , concat('"Image_URL": "', Image_URL,'"')
                    , concat('"Image_Type": "', Image_Type,'"')), '}') as Unit_Gallery
        from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                    , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                from source_office_image_all 
                where Image_Type = 'Unit_Image') a 
        where row_num <= 4) gallery4
on u.Unit_ID = gallery4.Ref_ID
left join (select Ref_ID 
            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                        , concat('"Image_Name": "', Image_Name,'"')
                        , concat('"Category_Order": ', Category_Order)
                        , concat('"Display_Order": ', Display_Order)
                        , concat('"Image_URL": "', Image_URL,'"')
                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num = 1) proj_gallery1
on p.Project_ID = proj_gallery1.Ref_ID
left join (select Ref_ID 
        , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                    , concat('"Image_Name": "', Image_Name,'"')
                    , concat('"Category_Order": ', Category_Order)
                    , concat('"Display_Order": ', Display_Order)
                    , concat('"Image_URL": "', Image_URL,'"')
                    , concat('"Image_Type": "', Image_Type,'"')), '}') as Unit_Gallery
        from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                    , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                from source_office_image_all 
                where Image_Type = 'Unit_Image') a 
        where row_num <= 3) gallery3
on u.Unit_ID = gallery3.Ref_ID
left join (select Ref_ID 
            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                        , concat('"Image_Name": "', Image_Name,'"')
                        , concat('"Category_Order": ', Category_Order)
                        , concat('"Display_Order": ', Display_Order)
                        , concat('"Image_URL": "', Image_URL,'"')
                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num <= 2) proj_gallery2
on p.Project_ID = proj_gallery2.Ref_ID
left join (select Ref_ID 
        , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                    , concat('"Image_Name": "', Image_Name,'"')
                    , concat('"Category_Order": ', Category_Order)
                    , concat('"Display_Order": ', Display_Order)
                    , concat('"Image_URL": "', Image_URL,'"')
                    , concat('"Image_Type": "', Image_Type,'"')), '}') as Unit_Gallery
        from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                    , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                from source_office_image_all 
                where Image_Type = 'Unit_Image') a 
        where row_num <= 2) gallery2
on u.Unit_ID = gallery2.Ref_ID
left join (select Ref_ID 
            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                        , concat('"Image_Name": "', Image_Name,'"')
                        , concat('"Category_Order": ', Category_Order)
                        , concat('"Display_Order": ', Display_Order)
                        , concat('"Image_URL": "', Image_URL,'"')
                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num <= 3) proj_gallery3
on p.Project_ID = proj_gallery3.Ref_ID
left join (select Ref_ID 
        , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                    , concat('"Image_Name": "', Image_Name,'"')
                    , concat('"Category_Order": ', Category_Order)
                    , concat('"Display_Order": ', Display_Order)
                    , concat('"Image_URL": "', Image_URL,'"')
                    , concat('"Image_Type": "', Image_Type,'"')), '}') as Unit_Gallery
        from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                    , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                from source_office_image_all 
                where Image_Type = 'Unit_Image') a 
        where row_num = 1) gallery1
on u.Unit_ID = gallery1.Ref_ID
left join (select Ref_ID 
            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                        , concat('"Image_Name": "', Image_Name,'"')
                        , concat('"Category_Order": ', Category_Order)
                        , concat('"Display_Order": ', Display_Order)
                        , concat('"Image_URL": "', Image_URL,'"')
                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num <= 4) proj_gallery4
on p.Project_ID = proj_gallery4.Ref_ID
left join (select Ref_ID 
            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                        , concat('"Image_Name": "', Image_Name,'"')
                        , concat('"Category_Order": ', Category_Order)
                        , concat('"Display_Order": ', Display_Order)
                        , concat('"Image_URL": "', Image_URL,'"')
                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num <= 5) proj_gallery5
on p.Project_ID = proj_gallery5.Ref_ID
where u.Unit_Status = '1'
and b.Building_Status = '1'
and p.Project_Status = '1'
GROUP BY u.Unit_ID;

-- view source_office_image_carousel_random
create or replace view source_office_image_carousel_random as
select 
    u.Unit_ID
    , if(unit_image_count.Unit_Image_Count >= 4
        , concat('[', group_concat(DISTINCT image_set1.Image_Set SEPARATOR ', '),']')
        , if(unit_image_count.Unit_Image_Count = 3
            , concat('[', group_concat(DISTINCT image_set2.Image_Set SEPARATOR ', '),']')
            , if(unit_image_count.Unit_Image_Count = 2
                , concat('[', group_concat(DISTINCT image_set3.Image_Set SEPARATOR ', '),']')
                , if(unit_image_count.Unit_Image_Count = 1
                    , concat('[', group_concat(DISTINCT image_set4.Image_Set SEPARATOR ', '),']')
                    , concat('[',group_concat(DISTINCT proj_gallery5.Image_Set SEPARATOR ', '), ']'))))) as Image_Set
from office_unit u
join office_building b on u.Building_ID = b.Building_ID
join office_project p on b.Project_ID = p.Project_ID
left join (select Ref_ID, count(*) as Unit_Image_Count
            from source_office_image_all
            where Image_Type = 'Unit_Image'
            group by Ref_ID) unit_image_count
on u.Unit_ID = unit_image_count.Ref_ID
left join (select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type = 'Unit_Image') a 
                            where row_num <= 4) gallery4
            union all 
            select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
                            where row_num = 1) proj_gallery1) image_set1
ON (u.Unit_ID = image_set1.Ref_ID AND image_set1.Image_Type = 'Unit_Image')
    OR (p.Project_ID = image_set1.Ref_ID AND image_set1.Image_Type in ('Project_Image', 'Cover_Project'))
left join (select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type = 'Unit_Image') a 
                            where row_num <= 3) gallery3
            union all 
            select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
                            where row_num <= 2) proj_gallery2) image_set2
ON (u.Unit_ID = image_set2.Ref_ID AND image_set2.Image_Type = 'Unit_Image')
    OR (p.Project_ID = image_set2.Ref_ID AND image_set2.Image_Type in ('Project_Image', 'Cover_Project'))
left join (select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type = 'Unit_Image') a 
                            where row_num <= 2) gallery2
            union all 
            select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
                            where row_num <= 3) proj_gallery3) image_set3
ON (u.Unit_ID = image_set3.Ref_ID AND image_set3.Image_Type = 'Unit_Image')
    OR (p.Project_ID = image_set3.Ref_ID AND image_set3.Image_Type in ('Project_Image', 'Cover_Project'))
left join (select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type = 'Unit_Image') a 
                            where row_num <= 1) gallery1
            union all 
            select * from (select Ref_ID, Image_Type
                            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                                        , concat('"Image_Name": "', Image_Name,'"')
                                        , concat('"Category_Order": ', Category_Order)
                                        , concat('"Display_Order": ', Display_Order)
                                        , concat('"Image_URL": "', Image_URL,'"')
                                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
                            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                                    from source_office_image_all 
                                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
                            where row_num <= 4) proj_gallery4) image_set4
ON (u.Unit_ID = image_set4.Ref_ID AND image_set4.Image_Type = 'Unit_Image')
    OR (p.Project_ID = image_set4.Ref_ID AND image_set4.Image_Type in ('Project_Image', 'Cover_Project'))
left join (select Ref_ID 
            , concat('{',concat_ws(', ', concat('"Image_ID": ', Image_ID)
                        , concat('"Image_Name": "', Image_Name,'"')
                        , concat('"Category_Order": ', Category_Order)
                        , concat('"Display_Order": ', Display_Order)
                        , concat('"Image_URL": "', Image_URL,'"')
                        , concat('"Image_Type": "', Image_Type,'"')), '}') as Image_Set
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by rand()) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num <= 5) proj_gallery5
on p.Project_ID = proj_gallery5.Ref_ID
where u.Unit_Status = '1'
and b.Building_Status = '1'
and p.Project_Status = '1'
GROUP BY u.Unit_ID;


-- view source_office_unit_carousel_recommend
create or replace view source_office_unit_carousel_recommend as
select u.Unit_ID
    , concat_ws(' ',concat(u.Size,' ตร.ม.'), u.Unit_NO, concat('ชั้น ', u.Floor)) as Title
    , p.Name_EN as Project_Name
    , project_tag_used.Tags as Project_Tag_Used
    , project_tag_all.Tags as Project_Tag_All
    , ifnull(station.Station,express_way.Express_Way) as near_by
    , concat(format(u.Rent_Price,0), ' บ./ด.') as Rent_Price
    , concat(format(u.Size,0),' ตร.ม. X ', format((u.Rent_Price/u.Size),0), ' บ./ด.') as Rent_Price_Sqm
    , if(u.Rent_Price is not null,1,0) as Rent_Price_Status
    , img_carousel.Image_Set as Carousel_Image
    , img_random.Image_Set as Carousel_Image_Random
from office_unit u
join office_building b on u.Building_ID = b.Building_ID
join office_project p on b.Project_ID = p.Project_ID
left join source_office_image_carousel img_carousel on u.Unit_ID = img_carousel.Unit_ID
left join source_office_image_carousel_random img_random on u.Unit_ID = img_random.Unit_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ';') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            and a.Relationship_Order <= 2
            group by a.Project_ID) project_tag_used
on p.Project_ID = project_tag_used.Project_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ';') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            group by a.Project_ID) project_tag_all
on p.Project_ID = project_tag_all.Project_ID
left join (WITH nearest_station AS (
                SELECT 
                    Project_ID,
                    Route_Code,
                    Line_Code,
                    Station_Code,
                    Station_THName_Display,
                    MTran_ShortName,
                    Distance,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID, Station_THName_Display 
                        ORDER BY Distance ASC
                    ) AS rn
                FROM office_around_station
                WHERE MTran_ShortName is not null)
            , distinct_station AS (
                SELECT Project_ID, Route_Code, Line_Code, Station_Code, Station_THName_Display, MTran_ShortName, Distance
                FROM nearest_station
                WHERE rn = 1)
            SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Route_Code', Route_Code
                                                        , 'Line_Code', Line_Code
                                                        , 'Station_Code', Station_Code
                                                        , 'MTran_ShortName', MTran_ShortName
                                                        , 'Station_THName_Display', Station_THName_Display
                                                        , 'Distance', Distance)) as Station
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_station) t
            WHERE rn2 <= 2
            group by Project_ID) station
on p.Project_ID = station.Project_ID
left join (WITH nearest_express_way AS (
                SELECT 
                    Project_ID,
                    Place_Name,
                    Place_Type,
                    Place_Category,
                    Place_Latitude,
                    Place_Longitude,
                    Distance,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID, Place_Name 
                        ORDER BY Distance ASC
                    ) AS rn
                FROM office_around_express_way)
            , distinct_express_way AS (
                SELECT Project_ID, Place_Name, Place_Type, Place_Category, Place_Latitude, Place_Longitude, Distance
                FROM nearest_express_way
                WHERE rn = 1)
            SELECT Project_ID, concat('[{"Express_Way": "', group_concat(concat(replace(Place_Name ,'ทางพิเศษ', Place_Type), ' (', Place_Category, ')') SEPARATOR ';') , '"}]') as Express_Way
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_express_way) t
            WHERE rn2 <= 2
            group by Project_ID) express_way
on p.Project_ID = express_way.Project_ID
where u.Unit_Status = '1'
and b.Building_Status = '1'
and p.Project_Status = '1';



-- view source_office_project_carousel_recommend
create or replace view source_office_project_carousel_recommend as
select a.Project_ID
    , a.Name_EN as Project_Name
    , project_tag_used.Tags as Project_Tag_Used
    , project_tag_all.Tags as Project_Tag_All
    , ifnull(station.Station,express_way.Express_Way) as near_by
    , highlight.Highlight as Highlight
    , concat(building.Rent_Price,' บ./ตร.ม./ด.') as Rent_Price
    , proj_gallery5.Project_Image as Project_Image
    , countunit.Unit_Count as Unit_Count
    , proj_gallery_all.Project_Image as Project_Image_All
from office_project a
left join (select a.Project_ID, count(u.Unit_ID) as Unit_Count
            from office_project a
            left join office_building b on a.Project_ID = b.Project_ID
            left join office_unit u on b.Building_ID = u.Building_ID
            where u.Unit_Status = '1'
            and b.Building_Status = '1'
            and a.Project_Status <> '2'
            group by a.Project_ID) countunit
on a.Project_ID = countunit.Project_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ';') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            and a.Relationship_Order <= 2
            group by a.Project_ID) project_tag_used
on a.Project_ID = project_tag_used.Project_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ';') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            group by a.Project_ID) project_tag_all
on a.Project_ID = project_tag_all.Project_ID
left join (WITH nearest_station AS (
                SELECT 
                    Project_ID,
                    Route_Code,
                    Line_Code,
                    Station_Code,
                    Station_THName_Display,
                    MTran_ShortName,
                    Distance,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID, Station_THName_Display 
                        ORDER BY Distance ASC
                    ) AS rn
                FROM office_around_station
                WHERE MTran_ShortName is not null)
            , distinct_station AS (
                SELECT Project_ID, Route_Code, Line_Code, Station_Code, Station_THName_Display, MTran_ShortName, Distance
                FROM nearest_station
                WHERE rn = 1)
            SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Route_Code', Route_Code
                                                        , 'Line_Code', Line_Code
                                                        , 'Station_Code', Station_Code
                                                        , 'MTran_ShortName', MTran_ShortName
                                                        , 'Station_THName_Display', Station_THName_Display
                                                        , 'Distance', Distance)) as Station
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_station) t
            WHERE rn2 <= 2
            group by Project_ID) station
on a.Project_ID = station.Project_ID
left join (WITH nearest_express_way AS (
                SELECT 
                    Project_ID,
                    Place_Name,
                    Place_Type,
                    Place_Category,
                    Place_Latitude,
                    Place_Longitude,
                    Distance,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID, Place_Name 
                        ORDER BY Distance ASC
                    ) AS rn
                FROM office_around_express_way)
            , distinct_express_way AS (
                SELECT Project_ID, Place_Name, Place_Type, Place_Category, Place_Latitude, Place_Longitude, Distance
                FROM nearest_express_way
                WHERE rn = 1)
            SELECT Project_ID, concat('[{"Express_Way": "', group_concat(concat(replace(Place_Name ,'ทางพิเศษ', Place_Type), ' (', Place_Category, ')') SEPARATOR ';') , '"}]') as Express_Way
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_express_way) t
            WHERE rn2 <= 2
            group by Project_ID) express_way
on a.Project_ID = express_way.Project_ID
left join (select a.Ref_ID, JSON_ARRAYAGG(JSON_OBJECT('Highlight_Name', if(b.Highlight_ID = 2, concat(b.Highlight_Name, ' 1:', a.Extra_Text), b.Highlight_Name)
                                                        , 'Highlight_Order', b.Highlight_Order)) as Highlight
            from office_highlight_relationship a
            join office_highlight b on a.Highlight_ID = b.Highlight_ID
            where a.Data_Type = 'Project'
            group by a.Ref_ID) highlight
on a.Project_ID = highlight.Ref_ID
left join (select Project_ID
                , if(min(Price)=max(Price)
                    , format(min(Price),0)
                    , concat(format(min(Price),0),' - ',format(max(Price),0))) as Rent_Price
            from (select * from (select Project_ID, Rent_Price_Min as Price
                                from office_building
                                where Building_Status = '1'
                                and Rent_Price_Min is not null) min_price
                    union all
                    select * from (select Project_ID, Rent_Price_Max as Price
                                    from office_building
                                    where Building_Status = '1'
                                    and Rent_Price_Max is not null) max_price) a
            group by Project_ID) building
on a.Project_ID = building.Project_ID
left join (select Ref_ID 
            , JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                        , 'Image_Name', Image_Name
                                        , 'Category_Order', Category_Order
                                        , 'Display_Order', Display_Order
                                        , 'Image_URL', Image_URL
                                        , 'Image_Type', Image_Type)) as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            where row_num <= 5
            group by Ref_ID) proj_gallery5
on a.Project_ID = proj_gallery5.Ref_ID
left join (select Ref_ID 
            , JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                        , 'Image_Name', Image_Name
                                        , 'Category_Order', Category_Order
                                        , 'Display_Order', Display_Order
                                        , 'Image_URL', Image_URL
                                        , 'Image_Type', Image_Type)) as Project_Image
            from (select Ref_ID, Image_URL, Image_ID, Image_Name, Category_Order, Display_Order, Image_Type
                        , row_number() over (partition by Ref_ID order by Category_Order, Display_Order) as row_num 
                    from source_office_image_all 
                    where Image_Type in ('Project_Image', 'Cover_Project') and Section <> 'Floor Plan') b
            group by Ref_ID) proj_gallery_all
on a.Project_ID = proj_gallery_all.Ref_ID
where a.Project_Status = '1';