select a.Building_Name, a.Building_Latitude, a.Building_Longitude
    , b.Station_THName_Display as First_Station, b.Train_Type as First_Type, b.Distance as First_Distance
    , c.Station_THName_Display as Second_Station, c.Train_Type as Second_Type, c.Distance as Second_Distance
    , d.Station_THName_Display as Third_Station, d.Train_Type as Third_Type, d.Distance as Third_Distance
    , e.Station_THName_Display as Fourth_Station, e.Train_Type as Fourth_Type, e.Distance as Fourth_Distance
    , ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                        point(100.5366402, 13.7296375))/1000 AS Silom
    , ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                        point(100.5610116, 13.7363986))/1000 AS Asok
from bangkok_office a
join (select a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
            , b.Station_THName_Display, b.Train_Type, b.Distance
        FROM bangkok_office a 
        join (SELECT a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
                    , b.Station_THName_Display , b.Train_Type
                    , ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                        point(b.Station_Longitude, b.Station_Latitude))/1000 AS Distance
                    , ROW_NUMBER() OVER (PARTITION BY a.Building_Name ORDER BY ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                                                                                point(b.Station_Longitude, b.Station_Latitude))) as rownum
                FROM bangkok_office a
                join ( select mr.Station_Code, mr.Station_THName_Display, mr.Station_Latitude, mr.Station_Longitude, ifnull(m.MTran_ShortName,ml.Line_Name) as Train_Type
                            from mass_transit_station_match_route mr
                            left join mass_transit_route mtr on mr.Route_Code = mtr.Route_Code
                            left join mass_transit_line ml on mtr.Line_Code = ml.Line_Code
                            left join mass_transit m on ml.MTrand_ID = m.MTran_ID
                            where mtr.Route_Timeline = 'Completion') b
                on 1 = 1) b
        on a.ID = b.ID
        where b.rownum = 1) b
on a.ID = b.ID
join (select a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
            , b.Station_THName_Display, b.Train_Type, b.Distance
        FROM bangkok_office a 
        join (SELECT a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
                    , b.Station_THName_Display , b.Train_Type
                    , ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                        point(b.Station_Longitude, b.Station_Latitude))/1000 AS Distance
                    , ROW_NUMBER() OVER (PARTITION BY a.Building_Name ORDER BY ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                                                                                point(b.Station_Longitude, b.Station_Latitude))) as rownum
                FROM bangkok_office a
                join ( select mr.Station_Code, mr.Station_THName_Display, mr.Station_Latitude, mr.Station_Longitude, ifnull(m.MTran_ShortName,ml.Line_Name) as Train_Type
                            from mass_transit_station_match_route mr
                            left join mass_transit_route mtr on mr.Route_Code = mtr.Route_Code
                            left join mass_transit_line ml on mtr.Line_Code = ml.Line_Code
                            left join mass_transit m on ml.MTrand_ID = m.MTran_ID
                            where mtr.Route_Timeline = 'Completion') b
                on 1 = 1) b
        on a.ID = b.ID
        where b.rownum = 2) c
on a.ID = c.ID
join (select a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
            , b.Station_THName_Display, b.Train_Type, b.Distance
        FROM bangkok_office a 
        join (SELECT a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
                    , b.Station_THName_Display , b.Train_Type
                    , ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                        point(b.Station_Longitude, b.Station_Latitude))/1000 AS Distance
                    , ROW_NUMBER() OVER (PARTITION BY a.Building_Name ORDER BY ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                                                                                point(b.Station_Longitude, b.Station_Latitude))) as rownum
                FROM bangkok_office a
                join ( select mr.Station_Code, mr.Station_THName_Display, mr.Station_Latitude, mr.Station_Longitude, ifnull(m.MTran_ShortName,ml.Line_Name) as Train_Type
                            from mass_transit_station_match_route mr
                            left join mass_transit_route mtr on mr.Route_Code = mtr.Route_Code
                            left join mass_transit_line ml on mtr.Line_Code = ml.Line_Code
                            left join mass_transit m on ml.MTrand_ID = m.MTran_ID
                            where mtr.Route_Timeline = 'Completion') b
                on 1 = 1) b
        on a.ID = b.ID
        where b.rownum = 3) d
on a.ID = d.ID
join (select a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
            , b.Station_THName_Display, b.Train_Type, b.Distance
        FROM bangkok_office a 
        join (SELECT a.ID, a.Building_Name, a.Building_Latitude, a.Building_Longitude
                    , b.Station_THName_Display , b.Train_Type
                    , ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                        point(b.Station_Longitude, b.Station_Latitude))/1000 AS Distance
                    , ROW_NUMBER() OVER (PARTITION BY a.Building_Name ORDER BY ST_Distance_Sphere(point(a.Building_Longitude, a.Building_Latitude),
                                                                                                point(b.Station_Longitude, b.Station_Latitude))) as rownum
                FROM bangkok_office a
                join ( select mr.Station_Code, mr.Station_THName_Display, mr.Station_Latitude, mr.Station_Longitude, ifnull(m.MTran_ShortName,ml.Line_Name) as Train_Type
                            from mass_transit_station_match_route mr
                            left join mass_transit_route mtr on mr.Route_Code = mtr.Route_Code
                            left join mass_transit_line ml on mtr.Line_Code = ml.Line_Code
                            left join mass_transit m on ml.MTrand_ID = m.MTran_ID
                            where mtr.Route_Timeline = 'Completion') b
                on 1 = 1) b
        on a.ID = b.ID
        where b.rownum = 4) e
on a.ID = e.ID;