-- view source_office_around_station
create or replace view source_office_around_station as
select Station_Code
    , Station_THName_Display
    , Route_Code
    , Line_Code
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
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - mtsmr.Station_Latitude)) / 2), 2)
                + COS(RADIANS(mtsmr.Station_Latitude)) * COS(RADIANS(o.Latitude)) *
                POWER(SIN((RADIANS(o.Longitude - mtsmr.Station_Longitude)) / 2), 2 )))) AS Distance
        FROM mass_transit_station_match_route mtsmr
        left join mass_transit_route mtr on mtsmr.Route_Code = mtr.Route_Code
        cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
where Distance <= 1.8;