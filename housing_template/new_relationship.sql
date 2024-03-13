-- table `housing_spotlight_relationship`
-- procedure truncateInsert_housing_spotlight
-- procedure updatehousingCountSpotlight

-- table `housing_spotlight_relationship`
CREATE TABLE `housing_spotlight_relationship` (
    `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` varchar(50) NOT NULL,
    `Housing_Type` enum('SD','DD','TH','HO','SH') NOT NULL,
    `Spotlight_Code` varchar(20) NOT NULL,
    PRIMARY KEY (id)) ENGINE=InnoDB;

CREATE TABLE `housing_spotlight_relationship_manual` (
    `id` int UNSIGNED NOT NULL,
    `Housing_Code` varchar(50) NOT NULL,
    `Housing_Type` enum('SD','DD','TH','HO','SH') NOT NULL,
    `Spotlight_Code` varchar(20) NOT NULL,
    PRIMARY KEY (id)) ENGINE=InnoDB;


-- procedure truncateInsert_housing_spotlight
DROP PROCEDURE IF EXISTS truncateInsert_housing_spotlight;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_spotlight()
BEGIN
    -- เปลี่ยนตามจำนวน listing
    DECLARE total_rows INT DEFAULT 0;
    DECLARE y INT DEFAULT 0;
    DECLARE each_type VARCHAR(250);
    DECLARE h_code VARCHAR(250) DEFAULT NULL;
    DECLARE sd INT DEFAULT NULL;
	DECLARE dd INT DEFAULT NULL;
	DECLARE th INT DEFAULT NULL;
    DECLARE ho INT DEFAULT NULL;
	DECLARE sh INT DEFAULT NULL;
	DECLARE cus007 VARCHAR(250) DEFAULT NULL;
    DECLARE cus008 VARCHAR(250) DEFAULT NULL;
    DECLARE cus024 VARCHAR(250) DEFAULT NULL;
    DECLARE cus046 VARCHAR(250) DEFAULT NULL;
    DECLARE cus047 VARCHAR(250) DEFAULT NULL;
    DECLARE cus048 VARCHAR(250) DEFAULT NULL;
    DECLARE ps002 VARCHAR(250) DEFAULT NULL;
    DECLARE ps003 VARCHAR(250) DEFAULT NULL;
    DECLARE ps004 VARCHAR(250) DEFAULT NULL;
    DECLARE ps005 VARCHAR(250) DEFAULT NULL;
    DECLARE ps006 VARCHAR(250) DEFAULT NULL;
    DECLARE ps007 VARCHAR(250) DEFAULT NULL;
    DECLARE ps009 VARCHAR(250) DEFAULT NULL;
    DECLARE ps011 VARCHAR(250) DEFAULT NULL;
    DECLARE ps021 VARCHAR(250) DEFAULT NULL;
    DECLARE ps022 VARCHAR(250) DEFAULT NULL;
    DECLARE ps023 VARCHAR(250) DEFAULT NULL;
    DECLARE house_types VARCHAR(250) DEFAULT NULL;
    DECLARE listing VARCHAR(250) DEFAULT NULL;
    DECLARE each_listing VARCHAR(250) DEFAULT NULL;
    DECLARE listings VARCHAR(250) DEFAULT NULL;
    DECLARE listing_group VARCHAR(250) DEFAULT NULL;
    DECLARE done INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    DECLARE x INT DEFAULT 1;
    DECLARE house_type INT DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_spotlight';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE cur CURSOR FOR select h.Housing_Code, h.IS_SD, h.IS_DD, h.IS_TH, h.IS_HO, h.IS_SH
                                , if((h.Housing_Price_Max < 2000000 and h.Housing_Price_Min >= 1000000)
                                    or (h.Housing_Price_Max is null and h.Housing_Price_Min >= 1000000 and h.Housing_Price_Min < 2000000)
                                        , 'Y'
                                        , 'N') as CUS007
                                , if((h.Housing_Price_Max < 5000000 and h.Housing_Price_Min >= 2000000)
                                    or (h.Housing_Price_Max is null and h.Housing_Price_Min >= 2000000 and h.Housing_Price_Min < 5000000)
                                        , 'Y'
                                        , 'N') as CUS008
                                , if(datediff(curdate(),h.Housing_Built_Start) <= 720
                                    , 'Y' 
                                    , 'N') as CUS024
                                , if(bts.Housing_Code is not null, 'Y', 'N') as CUS046
                                , if(mrt.Housing_Code is not null, 'Y', 'N') as CUS047
                                , if(arl.Housing_Code is not null, 'Y', 'N') as CUS048
                                , if(h.Housing_Usable_Area_Min > 400, 'Y', 'N') as PS002
                                , if(h.Housing_Price_Min > 30000000, 'Y', 'N') as PS003
                                , if(h.Housing_TotalUnit < 20, 'Y', 'N') as PS004
                                , if(h.RealDistrict_Code = 'M11', 'Y', 'N') as PS005
                                , if(express_way.Housing_Code is not null, 'Y', 'N') as PS006
                                , if(station.Housing_Code is not null, 'Y', 'N') as PS007
                                , if(retail.Housing_Code is not null, 'Y', 'N') as PS009
                                , if(inter_school.Housing_Code is not null, 'Y', 'N') as PS011
                                , if(h.Housing_Parking_Max > 4, 'Y', 'N') as PS021
                                , if(h.Bedroom_Max > 4, 'Y', 'N') as PS022
                                , if(hospital.Housing_Code is not null, 'Y', 'N') as PS023
                            from housing h
                            left join ( select Housing_Code
                                        from housing_around_express_way
                                        group by Housing_Code) express_way 
                            on h.Housing_Code = express_way.Housing_Code
                            left join (select Housing_Code
                                        from housing_around_station
                                        group by Housing_Code) station 
                            on h.Housing_Code = station.Housing_Code
                            left join ( select hat.Housing_Code as Housing_Code
                                        from housing_around_station hat
                                        left join mass_transit_line ml on hat.Line_Code = ml.Line_Code
                                        where ml.MTrand_ID = 1
                                        group by hat.Housing_Code) bts
                            on h.Housing_Code = bts.Housing_Code
                            left join ( select hat.Housing_Code as Housing_Code
                                        from housing_around_station hat
                                        left join mass_transit_line ml on hat.Line_Code = ml.Line_Code
                                        where ml.MTrand_ID = 2
                                        group by hat.Housing_Code) mrt
                            on h.Housing_Code = mrt.Housing_Code
                            left join ( select hat.Housing_Code as Housing_Code
                                        from housing_around_station hat
                                        left join mass_transit_line ml on hat.Line_Code = ml.Line_Code
                                        where ml.MTrand_ID = 3
                                        group by hat.Housing_Code) arl
                            on h.Housing_Code = arl.Housing_Code
                            left join (select aaa.Housing_Code
                                        from (SELECT rpt.Place_ID
                                                    , rpt.Place_Code
                                                    , rpt.Place_Name
                                                    , rpt.Place_Latitude
                                                    , rpt.Place_Longitude
                                                    , asok.Station_Latitude as asok_lat
                                                    , asok.Station_Longitude as asok_long
                                                    , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpt.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                                                        + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpt.Place_Latitude)) *
                                                        POWER(SIN((RADIANS(rpt.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) AS retail_distance
                                                    , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpt.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                                                        + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpt.Place_Latitude)) *
                                                        POWER(SIN((RADIANS(rpt.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
                                                    , h.Housing_Code
                                                    , h.Housing_Latitude
                                                    , h.Housing_Longitude
                                                    , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rpt.Place_Latitude)) / 2), 2)
                                                        + COS(RADIANS(rpt.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                                                        POWER(SIN((RADIANS(h.Housing_Longitude - rpt.Place_Longitude)) / 2), 2 )))) AS Distance
                                                FROM real_place_retail rpt
                                                cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
                                                cross join (select * from housing where Housing_Status = '1') h) aaa
                                        where aaa.Distance <= aaa.cal_radians
                                        group by aaa.Housing_Code) retail
                            on h.Housing_Code = retail.Housing_Code
                            left join (select aaa.Housing_Code
                                        from (SELECT rpe.Place_ID
                                                    , rpe.Place_Name
                                                    , rpe.Place_Latitude
                                                    , rpe.Place_Longitude
                                                    , asok.Station_Latitude as asok_lat
                                                    , asok.Station_Longitude as asok_long
                                                    , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpe.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                                                        + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpe.Place_Latitude)) *
                                                        POWER(SIN((RADIANS(rpe.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) AS retail_distance
                                                    , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpe.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                                                        + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpe.Place_Latitude)) *
                                                        POWER(SIN((RADIANS(rpe.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
                                                    , h.Housing_Code
                                                    , h.Housing_Latitude
                                                    , h.Housing_Longitude
                                                    , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rpe.Place_Latitude)) / 2), 2)
                                                        + COS(RADIANS(rpe.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                                                        POWER(SIN((RADIANS(h.Housing_Longitude - rpe.Place_Longitude)) / 2), 2 )))) AS Distance
                                                FROM real_place_education rpe
                                                cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
                                                cross join (select * from housing where Housing_Status = '1') h
                                                where Place_Category = 'โรงเรียนนานาชาติ') aaa
                                        where aaa.Distance <= aaa.cal_radians
                                        group by aaa.Housing_Code) inter_school
                            on h.Housing_Code = inter_school.Housing_Code
                            left join (select aaa.Housing_Code
                                        from (SELECT rph.Place_ID
                                                    , rph.Place_Name
                                                    , rph.Place_Latitude
                                                    , rph.Place_Longitude
                                                    , asok.Station_Latitude as asok_lat
                                                    , asok.Station_Longitude as asok_long
                                                    , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rph.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                                                        + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rph.Place_Latitude)) *
                                                        POWER(SIN((RADIANS(rph.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) AS retail_distance
                                                    , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rph.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                                                        + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rph.Place_Latitude)) *
                                                        POWER(SIN((RADIANS(rph.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
                                                    , h.Housing_Code
                                                    , h.Housing_Latitude
                                                    , h.Housing_Longitude
                                                    , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rph.Place_Latitude)) / 2), 2)
                                                        + COS(RADIANS(rph.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                                                        POWER(SIN((RADIANS(h.Housing_Longitude - rph.Place_Longitude)) / 2), 2 )))) AS Distance
                                                FROM real_place_hospital rph
                                                cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
                                                cross join (select * from housing where Housing_Status = '1') h) aaa
                                        where aaa.Distance <= aaa.cal_radians
                                        group by aaa.Housing_Code) hospital
                            on h.Housing_Code = hospital.Housing_Code
                            where h.Housing_Status = '1'
                            and h.Housing_ENName is not null; -- เปลี่ยนตามจำนวน listing
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',h_code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    TRUNCATE TABLE housing_spotlight_relationship;
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO h_code, sd, dd, th, ho, sh, cus007, cus008, cus024, cus046, cus047, cus048, ps002, ps003, ps004, ps005, ps006, ps007, ps009, ps011, ps021, ps022, ps023; -- เปลี่ยนตามจำนวน listing
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET house_types = CONCAT(sd, dd, th, ho, sh);
        SET listings = concat(cus007,cus008, cus024, cus046, cus047, cus048, ps002, ps003, ps004, ps005, ps006, ps007, ps009, ps011, ps021, ps022, ps023); -- เปลี่ยนตามจำนวน listing
        SET listing_group = concat_ws(',','CUS007','CUS008','CUS024','CUS046','CUS047','CUS048','PS002','PS003','PS004','PS005','PS006','PS007','PS009','PS011','PS021','PS022','PS023'); -- เปลี่ยนตามจำนวน listing
        
        WHILE x <= 17 DO -- เปลี่ยนตามจำนวน listing
            SET listing = SUBSTRING(listings, x, 1);
            IF listing = 'Y' THEN
                SET each_listing = SUBSTRING_INDEX(SUBSTRING_INDEX(listing_group, ',', x), ',', -1);
                
                WHILE i <= 5 DO
                    SET house_type = SUBSTRING(house_types, i, 1);
                    
                    IF house_type = 1 THEN
                        CASE i
                            WHEN 1 THEN SET each_type = 'SD';
                            WHEN 2 THEN SET each_type = 'DD';
                            WHEN 3 THEN SET each_type = 'TH';
                            WHEN 4 THEN SET each_type = 'HO';
                            WHEN 5 THEN SET each_type = 'SH';
                        END CASE;
                        
                        -- SELECT CONCAT(h_code, ',', each_type, ',', each_listing);
                        INSERT INTO housing_spotlight_relationship (Housing_Code, Housing_Type, Spotlight_Code) VALUES (h_code, each_type, each_listing);
                    END IF;
                    
                    SET i = i + 1;
                END WHILE;
                SET i = 1;
            
            END IF;
            SET x = x + 1;
        END WHILE;
        SET x = 1;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
		SET y = y + 1;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows calculated.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;
END //
DELIMITER ;


-- procedure updatehousingCountSpotlight
DROP PROCEDURE IF EXISTS updatehousingCountSpotlight;
DELIMITER //

CREATE PROCEDURE updatehousingCountSpotlight ()
BEGIN
    DECLARE listing_group   VARCHAR(250) DEFAULT NULL;
    DECLARE x               INT DEFAULT 1;
    DECLARE each_listing    VARCHAR(250) DEFAULT NULL;
    DECLARE proc_name       VARCHAR(50) DEFAULT 'updatehousingCountSpotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;

    SET listing_group = concat_ws(',','CUS007','CUS008','CUS024','CUS046','CUS047','CUS048','PS002','PS003','PS004','PS005','PS006','PS007','PS009','PS011','PS021','PS022','PS023'); -- เปลี่ยนตามจำนวน listing

    WHILE x <= 17 DO -- เปลี่ยนตามจำนวน listing
        SET each_listing = SUBSTRING_INDEX(SUBSTRING_INDEX(listing_group, ',', x), ',', -1);
        UPDATE housing_spotlight SET Housing_Count = (SELECT COUNT(1) FROM  housing_spotlight_relationship where Spotlight_Code = each_listing) WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_SD = (SELECT COUNT(1) FROM  housing_spotlight_relationship where Spotlight_Code = each_listing and Housing_Type = 'SD') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_DD = (SELECT COUNT(1) FROM  housing_spotlight_relationship where Spotlight_Code = each_listing and Housing_Type = 'DD') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_TH = (SELECT COUNT(1) FROM  housing_spotlight_relationship where Spotlight_Code = each_listing and Housing_Type = 'TH') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_HO = (SELECT COUNT(1) FROM  housing_spotlight_relationship where Spotlight_Code = each_listing and Housing_Type = 'HO') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_SH = (SELECT COUNT(1) FROM  housing_spotlight_relationship where Spotlight_Code = each_listing and Housing_Type = 'SH') WHERE Spotlight_Code = each_listing;
        SET x = x + 1;
    END WHILE;

    SET x = 1;
    SET listing_group = concat_ws(',','CUS039','CUS040','PS013','PS019');

    WHILE x <= 4 DO
        SET each_listing = SUBSTRING_INDEX(SUBSTRING_INDEX(listing_group, ',', x), ',', -1);
        UPDATE housing_spotlight SET Housing_Count = (SELECT COUNT(1) FROM  housing_spotlight_relationship_manual where Spotlight_Code = each_listing) WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_SD = (SELECT COUNT(1) FROM  housing_spotlight_relationship_manual where Spotlight_Code = each_listing and Housing_Type = 'SD') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_DD = (SELECT COUNT(1) FROM  housing_spotlight_relationship_manual where Spotlight_Code = each_listing and Housing_Type = 'DD') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_TH = (SELECT COUNT(1) FROM  housing_spotlight_relationship_manual where Spotlight_Code = each_listing and Housing_Type = 'TH') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_HO = (SELECT COUNT(1) FROM  housing_spotlight_relationship_manual where Spotlight_Code = each_listing and Housing_Type = 'HO') WHERE Spotlight_Code = each_listing;
        UPDATE housing_spotlight SET Housing_Count_SH = (SELECT COUNT(1) FROM  housing_spotlight_relationship_manual where Spotlight_Code = each_listing and Housing_Type = 'SH') WHERE Spotlight_Code = each_listing;
        SET x = x + 1;
    END WHILE;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT('No count for update (too many updates).');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;
END //
DELIMITER ;