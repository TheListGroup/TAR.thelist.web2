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
where Distance <= 1.8;



WITH nearest_station AS (
    SELECT 
        Project_ID,
        Station_THName_Display,
        MTran_ShortName,
        Distance,
        ROW_NUMBER() OVER (
            PARTITION BY Project_ID, Station_THName_Display 
            ORDER BY Distance ASC
        ) AS rn
    FROM office_around_station
)
, distinct_station AS (
    SELECT Project_ID, Station_THName_Display, MTran_ShortName, Distance
    FROM nearest_station
    WHERE rn = 1   -- keep only the nearest per station
)
SELECT Project_ID, Station_THName_Display, MTran_ShortName, Distance
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Project_ID ORDER BY Distance ASC
           ) AS rn2
    FROM distinct_station
) t
WHERE rn2 <= 2;


select u.Unit_ID
    , concat_ws(' ',concat(u.Size,' ตร.ม.'), u.Unit_NO, concat('ชั้น ', u.Floor)) as Title
    , p.Name_EN as Project_Name
    , project_tag_used.Tags as Project_Tag_Used
    , project_tag_all.Tags as Project_Tag_All
    , concat(u.Rent_Price, ' บ./ด.') as Rent_Price
    , concat(u.Size,' ตร.ม. X ', (u.Rent_Price/u.Size), ' บ./ด.') as Rent_Price_Sqm
    , if(u.Rent_Price is not null,1,0) as Rent_Price_Status
from office_unit u
join office_building b on u.Building_ID = b.Building_ID
join office_project p on b.Project_ID = p.Project_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ' ') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            and a.Relationship_Order <= 2
            group by a.Project_ID) project_tag_used
on p.Project_ID = project_tag_used.Project_ID
left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ' ') as Tags
            from office_project_tag_relationship a
            join office_project_tag b on a.Tag_ID = b.Tag_ID
            where a.Relationship_Status <> '2'
            group by a.Project_ID) project_tag_all
on p.Project_ID = project_tag_all.Project_ID
where u.Unit_Status = '1'
and b.Building_Status = '1'
and p.Project_Status = '1'