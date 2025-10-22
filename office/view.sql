-- source_office_around_station
-- source_office_around_express_way
-- source_office_image_all
-- source_office_image_carousel (unit)
-- source_office_image_carousel_random (unit)
-- source_office_unit_carousel_recommend
-- source_office_project_carousel_recommend
-- view source_office_project_highlight
-- view source_office_project_highlight_relationship


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
        cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o
        where mtsmr.Route_Timeline = 'Completion') aaa
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
    , concat_ws(' ',concat(format(u.Size,0),' ตร.ม.'), u.Unit_NO, concat('ชั้น ', u.Floor)) as Title
    , p.Name_EN as Project_Name
    , project_tag_used.Tags as Project_Tag_Used
    , project_tag_all.Tags as Project_Tag_All
    , ifnull(station.Station,express_way.Express_Way) as near_by
    , concat(format(u.Rent_Price,0), ' บ./ด.') as Rent_Price
    , concat(format(u.Size,0),' ตร.ม. X ', format((u.Rent_Price/u.Size),0), ' บ./ด.') as Rent_Price_Sqm
    , if(u.Rent_Price is not null,1,0) as Rent_Price_Status
    /*, img_carousel.Image_Set as Carousel_Image
    , img_random.Image_Set as Carousel_Image_Random*/
from office_unit u
join office_building b on u.Building_ID = b.Building_ID
join office_project p on b.Project_ID = p.Project_ID
-- left join source_office_image_carousel img_carousel on u.Unit_ID = img_carousel.Unit_ID
-- left join source_office_image_carousel_random img_random on u.Unit_ID = img_random.Unit_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ';') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            and a.Relationship_Order <= 2
            group by a.Project_ID) project_tag_used
on p.Project_ID = project_tag_used.Project_ID
left join (select Project_ID, concat('[',group_concat(Tags separator ','),']') as Tags
            from (select a.Project_ID, concat('"',b.Tag_Name,'"') as Tags
                    from office_project_tag_relationship a
                    join office_project_tag b on a.Tag_ID = b.Tag_ID
                    where a.Relationship_Status <> '2') a
            group by Project_ID) project_tag_all
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
                FROM source_office_around_station
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
                FROM source_office_around_express_way)
            , distinct_express_way AS (
                SELECT Project_ID, Place_Name, Place_Type, Place_Category, Place_Latitude, Place_Longitude, Distance
                FROM nearest_express_way
                WHERE rn = 1)
            SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Express_Way', CONCAT(REPLACE(Place_Name, 'ทางพิเศษ', Place_Type), ' (', Place_Category, ')'))) as Express_Way
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_express_way) t
            WHERE rn2 <= 1
            group by Project_ID) express_way
on p.Project_ID = express_way.Project_ID
where u.Unit_Status = '1'
and b.Building_Status = '1'
and p.Project_Status = '1';


-- view source_office_project_highlight
create or replace view source_office_project_highlight as
select a.Project_ID
            , 'N' as 'Skywalk'
            , building.Parking_Ratio as 'Parking'
            , if(building.Parking_Ratio >= 120, 'Y', if(building.Parking_Ratio >= 80, 'Y', 'N')) as 'Parking_Ratio'
            , if(building.Typical_Floor_Plate >= 1500, 'Y', 'N') as 'Typical_Floor_Plate'
            , if(a.F_Others_EV = 1, 'Y', 'N') as 'EV_Changers'
            , 'N' as 'Mall_Connect'
            , if(a.F_Others_Gym = 1, 'Y', 'N') as 'Fitness'
            , if(a.F_Retail_Mall_Shop = 1, 'Y', 'N') as 'Mall_Shop'
            , if((a.F_Services_ATM = 1 or a.F_Services_Bank = 1), 'Y', 'N') as 'Bank'
            , if(a.F_Retail_Conv_Store = 1, 'Y', 'N') as 'Seven'
            , if((a.F_Food_Foodcourt = 1 or a.F_Food_Restaurant = 1), 'Y', 'N') as 'Food'
            , if(a.F_Food_Cafe = 1, 'Y', 'N') as 'Cafe'
            , if(a.F_Others_Conf_Meetingroom = 1, 'Y', 'N') as 'Meeting_Room'
            ,if(building.AC <> 'N', 'Y', 'N') as 'AC'
        from office_project a
        left join (select Project_ID
                        , max(SUBSTRING_INDEX(Parking_Ratio, ':', -1)) as Parking_Ratio
                        , greatest(ifnull(max(Typical_Floor_Plate_1),0), greatest(ifnull(max(Typical_Floor_Plate_2),0), ifnull(max(Typical_Floor_Plate_3),0))) as Typical_Floor_Plate
                        , ifnull(max(ifnull(AC_OT_Weekday_by_Hour,ifnull(AC_OT_Weekday_by_Area,ifnull(AC_OT_Weekend_by_Hour,ifnull(AC_OT_Weekend_by_Area,null))))), 'N') as AC
                    from office_building 
                    where Building_Status = '1'
                    group by Project_ID) building
        on a.Project_ID = building.Project_ID
        where a.Project_Status = '1';

-- view source_office_project_highlight_relationship
create or replace view source_office_project_highlight_relationship as
SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Highlight_Name', if(aaa.Highlight = 2, concat(b.Highlight_Name, ' 1:', aaa.Extra_Text), b.Highlight_Name)
                                            , 'Highlight_Order', b.Highlight_Order)) as Highlight
from (SELECT Project_ID, 1 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Skywalk <> 'N'
        UNION ALL
        SELECT Project_ID, 2 AS Highlight, if(Parking >= 120, 120, if(Parking >= 80, 80, NULL)) as Extra_Text
        FROM source_office_project_highlight
        WHERE Parking_Ratio <> 'N'
        UNION ALL
        SELECT Project_ID, 3 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Typical_Floor_Plate <> 'N'
        UNION ALL
        SELECT Project_ID, 4 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE EV_Changers <> 'N'
        UNION ALL
        SELECT Project_ID, 5 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Mall_Connect <> 'N'
        UNION ALL
        SELECT Project_ID, 6 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Fitness <> 'N'
        UNION ALL
        SELECT Project_ID, 7 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Mall_Shop <> 'N'
        UNION ALL
        SELECT Project_ID, 8 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Bank <> 'N'
        UNION ALL
        SELECT Project_ID, 9 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Seven <> 'N'
        UNION ALL
        SELECT Project_ID, 10 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Food <> 'N'
        UNION ALL
        SELECT Project_ID, 11 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Cafe <> 'N'
        UNION ALL
        SELECT Project_ID, 12 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Meeting_Room <> 'N'
        UNION ALL
        SELECT Project_ID, 13 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE AC <> 'N') aaa
join office_highlight b on aaa.Highlight = b.Highlight_ID
where b.Highlight_Status = '1'
group by aaa.Project_ID;

-- view source_office_project_carousel_recommend
create or replace view source_office_project_carousel_recommend as
select a.Project_ID
    , a.Name_EN as Project_Name
    , project_tag_used.Tags as Project_Tag_Used
    , project_tag_all.Tags as Project_Tag_All
    , ifnull(station.Station,express_way.Express_Way) as near_by
    , highlight.Highlight as Highlight
    , concat(building.Rent_Price,' บ./ตร.ม./ด.') as Rent_Price
    , countunit.Unit_Count as Unit_Count
from office_project a
left join source_office_project_highlight_relationship highlight on a.Project_ID = highlight.Project_ID
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
left join (select Project_ID, concat('[',group_concat(Tags separator ','),']') as Tags
            from (select a.Project_ID, concat('"',b.Tag_Name,'"') as Tags
                    from office_project_tag_relationship a
                    join office_project_tag b on a.Tag_ID = b.Tag_ID
                    where a.Relationship_Status <> '2') a
            group by Project_ID) project_tag_all
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
                FROM source_office_around_station
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
                FROM source_office_around_express_way)
            , distinct_express_way AS (
                SELECT Project_ID, Place_Name, Place_Type, Place_Category, Place_Latitude, Place_Longitude, Distance
                FROM nearest_express_way
                WHERE rn = 1)
            SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Express_Way', CONCAT(REPLACE(Place_Name, 'ทางพิเศษ', Place_Type), ' (', Place_Category, ')'))) as Express_Way
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_express_way) t
            WHERE rn2 <= 1
            group by Project_ID) express_way
on a.Project_ID = express_way.Project_ID
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
where a.Project_Status = '1';


create or replace view source_office_project_highlight_relationship_data as
SELECT Project_ID, group_concat(if(aaa.Highlight = 2, concat(b.Highlight_Name, ' 1:', aaa.Extra_Text), b.Highlight_Name) separator '\n') as Highlight
from (SELECT Project_ID, 1 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Skywalk <> 'N'
        UNION ALL
        SELECT Project_ID, 2 AS Highlight, if(Parking >= 120, 120, if(Parking >= 80, 80, NULL)) as Extra_Text
        FROM source_office_project_highlight
        WHERE Parking_Ratio <> 'N'
        UNION ALL
        SELECT Project_ID, 3 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Typical_Floor_Plate <> 'N'
        UNION ALL
        SELECT Project_ID, 4 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE EV_Changers <> 'N'
        UNION ALL
        SELECT Project_ID, 5 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Mall_Connect <> 'N'
        UNION ALL
        SELECT Project_ID, 6 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Fitness <> 'N'
        UNION ALL
        SELECT Project_ID, 7 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Mall_Shop <> 'N'
        UNION ALL
        SELECT Project_ID, 8 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Bank <> 'N'
        UNION ALL
        SELECT Project_ID, 9 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Seven <> 'N'
        UNION ALL
        SELECT Project_ID, 10 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Food <> 'N'
        UNION ALL
        SELECT Project_ID, 11 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Cafe <> 'N'
        UNION ALL
        SELECT Project_ID, 12 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE Meeting_Room <> 'N'
        UNION ALL
        SELECT Project_ID, 13 AS Highlight, NULL as Extra_Text
        FROM source_office_project_highlight
        WHERE AC <> 'N') aaa
join office_highlight b on aaa.Highlight = b.Highlight_ID
where b.Highlight_Status = '1'
group by aaa.Project_ID;

create or replace view source_office_project_data as
select u.Unit_ID
    , u.Unit_NO
    , u.Rent_Price as Unit_Rent_Price
    , u.Size as Unit_Size
    , u.Available as Unit_Available
    , u.Furnish_Condition as Unit_Furnish_Condition
    , u.Combine_Divide as Unit_Combine_Divide
    , u.Min_Divide_Size as Unit_Min_Divide_Size
    , u.Floor_Zone as Unit_Floor_Zone
    , u.Floor as Unit_Floor
    , u.View_N as Unit_View_N
    , u.View_E as Unit_View_E
    , u.View_S as Unit_View_S
    , u.View_W as Unit_View_W
    , u.Ceiling_Dropped as Unit_Ceiling_Dropped
    , u.Ceiling_Full_Structure as Unit_Ceiling_Full_Structure
    , u.Column_InUnit as Unit_Column_InUnit
    , u.AC_Split_Type as Unit_AC_Split_Type
    , u.Pantry_InUnit as Unit_Pantry_InUnit
    , u.Bathroom_InUnit as Unit_Bathroom_InUnit
    , u.Rent_Term as Unit_Rent_Term
    , u.Rent_Deposit as Unit_Rent_Deposit
    , u.Rent_Advance as Unit_Rent_Advance
    , a.Project_ID
    , a.Name_EN as Project_Name
    , c.name_th as Province
    , d.name_th as District
    , e.name_th as Subdistrict
    , project_tag_all.Tags
    , station.Station
    , express_way.Express_Way
    , highlight.Highlight
    , a.Project_Description
    , concat(rent_price.Rent_Price, ' บาท / ตร.ม.') as Rent_Price
    , concat(area.Area, ' ตร.ม.') as Area
    , concat(building.Floor, ' ชั้น') as Floor
    , concat(format(building.Total_Building_Area,0), ' ตร.ม.') as Total_Building_Area
    , concat(format(a.Office_Lettable_Area,0), ' ตร.ม.') as Office_Lettable_Area
    , building.Year_Built_Complete
    , building.Year_Last_Renovate
    , concat(format(if(building.Typical_Floor_Plate=0, null, building.Typical_Floor_Plate),0), ' ตร.ม.') as Typical_Floor_Plate
    , concat(building.Ceiling, ' ม.') as Ceiling
    , concat(building.Total_Lift, ' ตัว') as Total_Lift
    , building.AC_System
    , concat(format(a.Parking_Amount,0), ' คัน') as Parking_Amount
    , nullif(concat_ws('\n', if(a.F_Services_ATM=1, "ตู้เอทีเอ็ม", null)
                , if(a.F_Services_Bank=1, "ธนาคาร", null)
                , if(a.F_Food_Cafe=1, "คาเฟ่", null)
                , if(a.F_Food_Restaurant=1, "ร้านอาหาร", null)
                , if(a.F_Food_Foodcourt=1, "ศูนย์อาหาร", null)
                , if(a.F_Food_Market=1, "ตลาดนัด", null)
                , if(a.F_Retail_Mall_Shop=1, "ร้านค้า", null)
                , if(a.F_Retail_Conv_Store=1, "ร้านสะดวกซื้อ", null)
                , if(a.F_Retail_Supermarket=1, "ซุปเปอร์มาเก็ต", null)
                , if(a.F_Services_Pharma_Clinic=1, "ร้านขายยา/คลินิก", null)
                , if(a.F_Services_Hair_Salon=1, "ร้านทำผม", null)
                , if(a.F_Services_Spa_Beauty=1, "สปา/ร้านเสริมสวย", null)
                , if(a.F_Others_Gym=1, "ฟิตเนส", null)
                , if(a.F_Others_EV=1, "EV Charger", null)
                , if(a.F_Others_Valet=1, "Valet Parking", null)
                , if(a.F_Others_Conf_Meetingroom=1, "ห้องประชุม", null)), '') as Amenities
from office_unit u
join office_building ob on u.Building_ID = ob.Building_ID
join office_project a on ob.Project_ID = a.Project_ID
left join (select Project_ID, group_concat(Tags separator '\n') as Tags
            from (select a.Project_ID, b.Tag_Name as Tags
                    from office_project_tag_relationship a
                    join office_project_tag b on a.Tag_ID = b.Tag_ID
                    where a.Relationship_Status <> '2') a
            group by Project_ID) project_tag_all
on a.Project_ID = project_tag_all.Project_ID
left join thailand_province c on a.Province_ID = c.province_code
left join thailand_district d on a.District_ID = d.district_code
left join thailand_subdistrict e on a.Subdistrict_ID = e.subdistrict_code
left join source_office_project_highlight_relationship_data highlight on a.Project_ID = highlight.Project_ID
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
                FROM source_office_around_station
                WHERE MTran_ShortName is not null)
            , distinct_station AS (
                SELECT Project_ID, Route_Code, Line_Code, Station_Code, Station_THName_Display, MTran_ShortName, Distance
                FROM nearest_station
                WHERE rn = 1)
            SELECT Project_ID, group_concat(concat(MTran_ShortName, ' ', Station_THName_Display, ' - ', round(Distance,2), ' km') separator '\n') as Station
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
                FROM source_office_around_express_way)
            , distinct_express_way AS (
                SELECT Project_ID, Place_Name, Place_Type, Place_Category, Place_Latitude, Place_Longitude, Distance
                FROM nearest_express_way
                WHERE rn = 1)
            SELECT Project_ID, group_concat(CONCAT(REPLACE(Place_Name, 'ทางพิเศษ', Place_Type), ' (', Place_Category, ')', ' - ', round(Distance,2), ' km') separator '\n') as Express_Way
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY Project_ID ORDER BY Distance ASC
                    ) AS rn2
                FROM distinct_express_way) t
            WHERE rn2 <= 1
            group by Project_ID) express_way
on a.Project_ID = express_way.Project_ID
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
            group by Project_ID) rent_price
on a.Project_ID = rent_price.Project_ID
left join (select Project_ID
                , if(min(Area)=max(Area)
                    , format(min(Area),0)
                    , concat(format(min(Area),0),' - ',format(max(Area),0))) as Area
            from (select * from (select Project_ID, Unit_Size_Min as Area
                                from office_building
                                where Building_Status = '1'
                                and Unit_Size_Min is not null) min_area
                    union all
                    select * from (select Project_ID, Unit_Size_Max as Area
                                    from office_building
                                    where Building_Status = '1'
                                    and Unit_Size_Max is not null) max_area) a
            group by Project_ID) area
on a.Project_ID = area.Project_ID
left join (SELECT a.Project_ID
                , if(min(Floor_above)=max(Floor_above)
                    , min(Floor_above)
                    , concat(min(Floor_above),' - ',max(Floor_above))) as Floor
                , sum(a.Total_Building_Area) as Total_Building_Area
                , max(YEAR(a.Built_Complete)) as Year_Built_Complete
                , max(YEAR(a.Last_Renovate)) as Year_Last_Renovate
                , greatest(ifnull(max(a.Typical_Floor_Plate_1),0), ifnull(max(a.Typical_Floor_Plate_2),0), ifnull(max(a.Typical_Floor_Plate_3),0)) as Typical_Floor_Plate
                , if(min(a.Ceiling_Avg) = max(a.Ceiling_Avg)
                    , if(mod(round(min(a.Ceiling_Avg), 1), 1) = 0
                        , format(round(min(a.Ceiling_Avg), 0), 0)
                        , format(round(min(a.Ceiling_Avg), 1), 1))
                    , if(mod(round(max(a.Ceiling_Avg), 1), 1) = 0
                        , concat(format(round(min(a.Ceiling_Avg), 0), 0), ' - ', format(round(max(a.Ceiling_Avg), 0), 0))
                        , concat(format(round(min(a.Ceiling_Avg), 1), 1), ' - ', format(round(max(a.Ceiling_Avg), 1), 1)))) as Ceiling
                , if(sum(a.Total_Lift)=0, null, sum(a.Total_Lift)) as Total_Lift
                , group_concat(distinct a.AC_System separator '\n') as AC_System
            FROM office_building a
            WHERE a.Building_Status = '1'
            group by a.Project_ID) building
on a.Project_ID = building.Project_ID
where a.Project_Status = '1'
and ob.Building_Status = '1'
and u.Unit_Status = '1';