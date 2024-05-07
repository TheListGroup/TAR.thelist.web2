DROP PROCEDURE IF EXISTS updateHousingPoint;
DELIMITER //

CREATE PROCEDURE updateHousingPoint ()
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'updateHousingPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE price_weight    INTEGER     DEFAULT 20;
    DECLARE price_min       INTEGER     DEFAULT 5;
    DECLARE price_max       INTEGER     DEFAULT 50;
    DECLARE price_score_min INTEGER     DEFAULT 5;
    DECLARE price_score_max INTEGER     DEFAULT 10;
    DECLARE price_m         FLOAT       DEFAULT 0;
    DECLARE price_b         FLOAT       DEFAULT 0;

    DECLARE unit_weight    INTEGER     DEFAULT 20;
    DECLARE unit_min       INTEGER     DEFAULT 50;
    DECLARE unit_max       INTEGER     DEFAULT 500;
    DECLARE unit_score_min INTEGER     DEFAULT 5;
    DECLARE unit_score_max INTEGER     DEFAULT 10;
    DECLARE unit_m         FLOAT       DEFAULT 0;
    DECLARE unit_b         FLOAT       DEFAULT 0;

    DECLARE age_weight    INTEGER     DEFAULT 20;
    DECLARE age_min       INTEGER     DEFAULT 10;
    DECLARE age_max       INTEGER     DEFAULT 2;
    DECLARE age_score_min INTEGER     DEFAULT 5;
    DECLARE age_score_max INTEGER     DEFAULT 10;
    DECLARE age_m         FLOAT       DEFAULT 0;
    DECLARE age_b         FLOAT       DEFAULT 0;

    DECLARE list_weight    INTEGER     DEFAULT 20;
    DECLARE list_min       INTEGER     DEFAULT 0;
    DECLARE list_max       INTEGER     DEFAULT 1;
    DECLARE list_score_min INTEGER     DEFAULT 5;
    DECLARE list_score_max INTEGER     DEFAULT 10;
    DECLARE list_m         FLOAT       DEFAULT 0;
    DECLARE list_b         FLOAT       DEFAULT 0;

    DECLARE station_weight    INTEGER     DEFAULT 20;
    DECLARE station_min       INTEGER     DEFAULT 2000;
    DECLARE station_max       INTEGER     DEFAULT 100;
    DECLARE station_score_min INTEGER     DEFAULT 5;
    DECLARE station_score_max INTEGER     DEFAULT 10;
    DECLARE station_m         FLOAT       DEFAULT 0;
    DECLARE station_b         FLOAT       DEFAULT 0;

    DECLARE expressway_weight    INTEGER     DEFAULT 20;
    DECLARE expressway_min       INTEGER     DEFAULT 10000;
    DECLARE expressway_max       INTEGER     DEFAULT 2000;
    DECLARE expressway_score_min INTEGER     DEFAULT 5;
    DECLARE expressway_score_max INTEGER     DEFAULT 10;
    DECLARE expressway_m         FLOAT       DEFAULT 0;
    DECLARE expressway_b         FLOAT       DEFAULT 0;

    DECLARE rs_weight    INTEGER     DEFAULT 20;
    DECLARE rs_min       INTEGER     DEFAULT 1;
    DECLARE rs_max       INTEGER     DEFAULT 10;
    DECLARE rs_score_min INTEGER     DEFAULT 1;
    DECLARE rs_score_max INTEGER     DEFAULT 10;
    DECLARE rs_m         FLOAT       DEFAULT 0;
    DECLARE rs_b         FLOAT       DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    CREATE TABLE housing_around_station2 AS 
    select Housing_Code
        , min(Distance) as Distance
    from (SELECT mtsmr.Station_Code
                , mtsmr.Station_THName_Display
                , mtsmr.Route_Code
                , mtr.Line_Code
                , mtsmr.Station_Latitude
                , mtsmr.Station_Longitude
                , h.Housing_Code
                , h.Housing_Latitude
                , h.Housing_Longitude
                , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - mtsmr.Station_Latitude)) / 2), 2)
                    + COS(RADIANS(mtsmr.Station_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                    POWER(SIN((RADIANS(h.Housing_Longitude - mtsmr.Station_Longitude)) / 2), 2 )))) AS Distance
                , mtr.Route_Timeline
            FROM mass_transit_station_match_route mtsmr
            left join mass_transit_route mtr on mtsmr.Route_Code = mtr.Route_Code
            cross join (select * from housing where Housing_Status = '1') h) aaa  
    where aaa.Distance <= 2
    and aaa.Route_Timeline <> 'Planning'
    group by aaa.Housing_Code;

    CREATE TABLE housing_around_express_way2 AS
    select Housing_Code
        , min(Distance) as Distance
    from (SELECT rpe.Place_ID
                , rpe.Place_Attribute_1
                , rpe.Place_Attribute_2
                , rpe.Place_Latitude
                , rpe.Place_Longitude
                , h.Housing_Code
                , h.Housing_Latitude
                , h.Housing_Longitude
                , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rpe.Place_Latitude)) / 2), 2)
                    + COS(RADIANS(rpe.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                    POWER(SIN((RADIANS(h.Housing_Longitude - rpe.Place_Longitude)) / 2), 2 )))) AS Distance
            FROM real_place_express_way rpe
            cross join (select * from housing where Housing_Status = '1') h) aaa  
    where aaa.Distance <= 10
    group by aaa.Housing_Code;

    SET price_m = (price_score_min - price_score_max) / (price_min - price_max);
    SET price_b = price_score_min - price_m * price_min;

    SET unit_m = (unit_score_min - unit_score_max) / (unit_min - unit_max);
    SET unit_b = unit_score_min - unit_m * unit_min;

    SET age_m = (age_score_min - age_score_max) / (age_min - age_max);
    SET age_b = age_score_min - age_m * age_min;

    SET list_m = (list_score_min - list_score_max) / (list_min - list_max);
    SET list_b = list_score_min - list_m * list_min;

    SET station_m = (station_score_min - station_score_max) / (station_min - station_max);
    SET station_b = station_score_min - station_m * station_min;

    SET expressway_m = (expressway_score_min - expressway_score_max) / (expressway_min - expressway_max);
    SET expressway_b = expressway_score_min - expressway_m * expressway_min;

    SET rs_m = (rs_score_min - rs_score_max) / (rs_min - rs_max);
    SET rs_b = rs_score_min - rs_m * rs_min;
    
    UPDATE  housing h
    left join condo_developer cd on h.Developer_Code  = cd.Developer_Code
    left join housing_around_station2 h2 on h.Housing_Code = h2.Housing_Code
    left join housing_around_express_way2 ew on h.Housing_Code = ew.Housing_Code
    left join housing_realist_score hs on h.Housing_Code = hs.Housing_Code
    SET	    h.Price_Min_Point              = ROUND(GREATEST(LEAST((ifnull((h.Housing_Price_Min / 1000000), price_min) * price_m+price_b) * price_weight, price_weight * price_score_max) ,price_weight * price_score_min), 1),
            h.NO_of_Unit_Point             = ROUND(GREATEST(LEAST((ifnull(h.Housing_TotalUnit, unit_min) * unit_m + unit_b) * unit_weight, unit_weight * unit_score_max), unit_weight * unit_score_min), 1),
            h.Age_Point                    = ROUND(GREATEST(LEAST((ifnull(if(h.Housing_Built_Finished is not null
                                                                            , year(curdate()) - year(h.Housing_Built_Finished)
                                                                            , if(h.Housing_Built_Start is not null
                                                                                , year(curdate()) - year(h.Housing_Built_Start)
                                                                                , null)),age_min) * age_m + age_b) * age_weight, age_weight * age_score_max), age_weight * age_score_min), 1),
            h.ListCompany_Point            = ROUND(GREATEST(LEAST((ifnull(cd.Developer_ListedCompany, list_min) * list_m + list_b) * list_weight, list_weight * list_score_max), list_weight * list_score_min), 1),
            h.DistanceFromStation_Point    = ROUND(GREATEST(LEAST((ifnull(h2.Distance*1000, station_min) * station_m + station_b) * station_weight, station_weight * station_score_max), station_weight * station_score_min), 1),
            h.DistanceFromExpressway_Point = ROUND(GREATEST(LEAST((ifnull(ew.Distance*1000, expressway_min) * expressway_m + expressway_b) * expressway_weight, expressway_weight * expressway_score_max), expressway_weight * expressway_score_min), 1),
            h.Realist_Score                = ROUND(GREATEST(LEAST((ifnull(hs.Realist_Score, rs_min) * rs_m + rs_b) * rs_weight, rs_weight * rs_score_max), rs_weight * rs_score_min), 1);

    if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT('Success');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    DROP TABLE housing_around_station2;
    DROP TABLE housing_around_express_way2;
END //
DELIMITER ;