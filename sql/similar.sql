CREATE TABLE `condo_similar` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_Code` varchar(50) not NULL,
    `Condo_ENName` varchar(150) NULL,
    `Condo_Code2` varchar(50) not NULL,
    `Condo_ENName2` varchar(150) NULL,
    `price_point` float UNSIGNED not null,
    `age_point` float UNSIGNED not null,
    `location_point` float UNSIGNED not null,
    `station_point` float UNSIGNED not null,
    `score_point` float UNSIGNED not null,
    `highrise_point` int UNSIGNED not null,
    `Total_point` float UNSIGNED not null,
    PRIMARY KEY (`ID`),
    INDEX similar_code1 (Condo_Code),
    INDEX similar_code2 (Condo_Code2)
) ENGINE = InnoDB;

CREATE TABLE `condo_similar2` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_Code` varchar(50) not NULL,
    `Condo_ENName` varchar(150) NULL,
    `Condo_Code2` varchar(50) not NULL,
    `Condo_ENName2` varchar(150) NULL,
    `price_point` float UNSIGNED not null,
    `age_point` float UNSIGNED not null,
    `location_point` float UNSIGNED not null,
    `station_point` float UNSIGNED not null,
    `score_point` float UNSIGNED not null,
    `highrise_point` int UNSIGNED not null,
    `Total_point` float UNSIGNED not null,
    PRIMARY KEY (`ID`),
    INDEX similar_code21 (Condo_Code),
    INDEX similar_code22 (Condo_Code2)
) ENGINE = InnoDB;





DROP PROCEDURE IF EXISTS update_Condo_SimilarPoint;
DELIMITER //

CREATE PROCEDURE update_Condo_SimilarPoint ()
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_Condo_SimilarPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE finished        INTEGER     DEFAULT 0;
    DECLARE eachcondo       VARCHAR(20) DEFAULT NULL;

    DECLARE price_weight    INTEGER     DEFAULT 30;
    DECLARE price_min       INTEGER     DEFAULT 100000;
    DECLARE price_max       INTEGER     DEFAULT 0;
    DECLARE price_score_min INTEGER     DEFAULT 0;
    DECLARE price_score_max INTEGER     DEFAULT 10;
    DECLARE price_default   INTEGER     DEFAULT 0;
    DECLARE price_m         FLOAT       DEFAULT 0;
    DECLARE price_b         FLOAT       DEFAULT 0;

    DECLARE age_weight    INTEGER     DEFAULT 20;
    DECLARE age_min       INTEGER     DEFAULT 5;
    DECLARE age_max       INTEGER     DEFAULT 0;
    DECLARE age_score_min INTEGER     DEFAULT 0;
    DECLARE age_score_max INTEGER     DEFAULT 10;
    DECLARE age_default   INTEGER     DEFAULT 0;
    DECLARE age_m         FLOAT       DEFAULT 0;
    DECLARE age_b         FLOAT       DEFAULT 0;

    DECLARE location_weight    INTEGER     DEFAULT 30;
    DECLARE location_min       INTEGER     DEFAULT 5;
    DECLARE location_max       INTEGER     DEFAULT 0;
    DECLARE location_score_min INTEGER     DEFAULT 0;
    DECLARE location_score_max INTEGER     DEFAULT 10;
    DECLARE location_default   INTEGER     DEFAULT 0;
    DECLARE location_m         FLOAT       DEFAULT 0;
    DECLARE location_b         FLOAT       DEFAULT 0;

    DECLARE station_weight    INTEGER     DEFAULT 10;
    DECLARE station_min       INTEGER     DEFAULT 1;
    DECLARE station_max       INTEGER     DEFAULT 0;
    DECLARE station_score_min INTEGER     DEFAULT 0;
    DECLARE station_score_max INTEGER     DEFAULT 10;
    DECLARE station_default   INTEGER     DEFAULT 0;
    DECLARE station_m         FLOAT       DEFAULT 0;
    DECLARE station_b         FLOAT       DEFAULT 0;

    DECLARE rs_weight    INTEGER     DEFAULT 10;
    DECLARE rs_min       INTEGER     DEFAULT 0;
    DECLARE rs_max       INTEGER     DEFAULT 20;
    DECLARE rs_score_min INTEGER     DEFAULT 0;
    DECLARE rs_score_max INTEGER     DEFAULT 10;
    DECLARE rs_default   INTEGER     DEFAULT 0;
    DECLARE rs_m         FLOAT       DEFAULT 0;
    DECLARE rs_b         FLOAT       DEFAULT 0;

    DECLARE hl_weight    INTEGER     DEFAULT 10;
    DECLARE hl_min       INTEGER     DEFAULT 0;
    DECLARE hl_max       INTEGER     DEFAULT 1;
    DECLARE hl_score_min INTEGER     DEFAULT 0;
    DECLARE hl_score_max INTEGER     DEFAULT 10;
    DECLARE hl_default   INTEGER     DEFAULT 0;
    DECLARE hl_m         FLOAT       DEFAULT 0;
    DECLARE hl_b         FLOAT       DEFAULT 0;

    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;

    DEClARE cur CURSOR FOR SELECT Condo_Code FROM all_condo_price_calculate where ID <= 10;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    SET price_m = (price_score_min - price_score_max) / (price_min - price_max);
    SET price_b = price_score_min - price_m * price_min;

    SET age_m = (age_score_min - age_score_max) / (age_min - age_max);
    SET age_b = age_score_min - age_m * age_min;

    SET location_m = (location_score_min - location_score_max) / (location_min - location_max);
    SET location_b = location_score_min - location_m * location_min;

    SET station_m = (station_score_min - station_score_max) / (station_min - station_max);
    SET station_b = station_score_min - station_m * station_min;

    SET rs_m = (rs_score_min - rs_score_max) / (rs_min - rs_max);
    SET rs_b = rs_score_min - rs_m * rs_min;

    SET hl_m = (hl_score_min - hl_score_max) / (hl_min - hl_max);
    SET hl_b = hl_score_min - hl_m * hl_min;

    truncate table condo_similar;
    truncate table condo_similar2;

    OPEN cur;
    similarCondo: LOOP
		FETCH cur INTO eachcondo;
		IF finished = 1 THEN 
			LEAVE similarCondo;
		END IF;
    
        insert into condo_similar (Condo_Code, Condo_ENName, Condo_Code2, Condo_ENName2, price_point, age_point, location_point, station_point, score_point, highrise_point, Total_Point)
        select Condo_Code, Condo_ENName, Condo_Code2, Condo_ENName2, price_point, age_point, location_point, station_point, score_point, highrise_point, 
            price_point + age_point + location_point + station_point + score_point + highrise_point as Total_Point
        from (select acpc.Condo_Code, rc.Condo_ENName, acpc2.Condo_Code as Condo_Code2, rc2.Condo_ENName as Condo_ENName2
                , round(GREATEST(LEAST((ifnull(abs(acpc.Condo_Price_Per_Square_Cal - acpc2.Condo_Price_Per_Square_Cal), price_min) * price_m + price_b) * price_weight, price_weight * price_score_max) ,price_weight * price_score_min), 1) as price_point
                , round(GREATEST(LEAST((ifnull(abs(ifnull(acpc.Condo_Built_Date,ifnull(acpc2.Condo_Built_Date+age_min,age_min)) - ifnull(acpc2.Condo_Built_Date,ifnull(acpc.Condo_Built_Date+age_min,0))), age_min) * age_m + age_b) * age_weight, age_weight * age_score_max) ,age_weight * age_score_min), 1) as age_point
                , round(GREATEST(LEAST((ifnull(abs((6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rc2.Condo_Latitude)) / 2), 2)
                                                    + COS(RADIANS(rc2.Condo_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                                                    POWER(SIN((RADIANS(rc.Condo_Longitude - rc2.Condo_Longitude)) / 2), 2 ))))), location_min) * location_m + location_b) * location_weight, location_weight * location_score_max) ,location_weight * location_score_min), 1) as location_point
                , ROUND(GREATEST(LEAST((ifnull(abs(station1.Distance - station2.Distance), station_min) * station_m + station_b) * station_weight, station_weight * station_score_max) ,station_weight * station_score_min), 1) as station_point
                , ROUND(GREATEST(LEAST((ifnull(rs.Realist_Score, rs_min) * rs_m + rs_b) * rs_weight, rs_weight * rs_score_max) ,rs_weight * rs_score_min), 1) as score_point
                , round(GREATEST(LEAST((ifnull(if(rc.Condo_HighRise = rc2.Condo_HighRise, hl_max, hl_min), hl_min) * hl_m + hl_b) * hl_weight, hl_weight * hl_score_max) ,hl_weight * hl_score_min), 1) as highrise_point
                from all_condo_price_calculate acpc
                left join real_condo rc on acpc.Condo_Code = rc.Condo_Code
                left join (select Condo_Code
                                , min(Distance) as Distance
                            from condo_around_station_view
                            where Total_Point < 100
                            group by Condo_Code) station1
                on acpc.Condo_Code = station1.Condo_Code
                cross join all_condo_price_calculate acpc2
                left join realist_score rs on acpc2.Condo_Code = rs.Condo_Code
                left join real_condo rc2 on acpc2.Condo_Code = rc2.Condo_Code
                left join (select Condo_Code
                                , min(Distance) as Distance
                            from condo_around_station_view
                            where Total_Point < 100
                            group by Condo_Code) station2
                on acpc2.Condo_Code = station2.Condo_Code) aaa
        where Condo_Code = eachcondo
        and Condo_Code2 <> eachcondo
        order by price_point + age_point + location_point + station_point + score_point + highrise_point desc
        limit 10;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;

        insert into condo_similar2 (Condo_Code, Condo_ENName, Condo_Code2, Condo_ENName2, price_point, age_point, location_point, station_point, score_point, highrise_point, Total_Point)
        select Condo_Code, Condo_ENName, Condo_Code2, Condo_ENName2, price_point, age_point, location_point, station_point, score_point, highrise_point, 
            price_point + age_point + location_point + station_point + score_point + highrise_point as Total_Point
        from (select acpc.Condo_Code, rc.Condo_ENName, acpc2.Condo_Code as Condo_Code2, rc2.Condo_ENName as Condo_ENName2
                , round(GREATEST(LEAST((ifnull(abs(acpc.Condo_Price_Per_Square - acpc2.Condo_Price_Per_Square), price_min) * price_m + price_b) * price_weight, price_weight * price_score_max) ,price_weight * price_score_min), 1) as price_point
                , round(GREATEST(LEAST((ifnull(abs(ifnull(acpc.Condo_Built_Date,ifnull(acpc2.Condo_Built_Date+age_min,age_min)) - ifnull(acpc2.Condo_Built_Date,ifnull(acpc.Condo_Built_Date+age_min,0))), age_min) * age_m + age_b) * age_weight, age_weight * age_score_max) ,age_weight * age_score_min), 1) as age_point
                , round(GREATEST(LEAST((ifnull(abs((6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rc2.Condo_Latitude)) / 2), 2)
                                                    + COS(RADIANS(rc2.Condo_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                                                    POWER(SIN((RADIANS(rc.Condo_Longitude - rc2.Condo_Longitude)) / 2), 2 ))))), location_min) * location_m + location_b) * location_weight, location_weight * location_score_max) ,location_weight * location_score_min), 1) as location_point
                , ROUND(GREATEST(LEAST((ifnull(abs(station1.Distance - station2.Distance), station_min) * station_m + station_b) * station_weight, station_weight * station_score_max) ,station_weight * station_score_min), 1) as station_point
                , ROUND(GREATEST(LEAST((ifnull(rs.Realist_Score, rs_min) * rs_m + rs_b) * rs_weight, rs_weight * rs_score_max) ,rs_weight * rs_score_min), 1) as score_point
                , round(GREATEST(LEAST((ifnull(if(rc.Condo_HighRise = rc2.Condo_HighRise, hl_max, hl_min), hl_min) * hl_m + hl_b) * hl_weight, hl_weight * hl_score_max) ,hl_weight * hl_score_min), 1) as highrise_point
                from all_condo_price_calculate acpc
                left join real_condo rc on acpc.Condo_Code = rc.Condo_Code
                left join (select Condo_Code
                                , min(Distance) as Distance
                            from condo_around_station_view
                            where Total_Point < 100
                            group by Condo_Code) station1
                on acpc.Condo_Code = station1.Condo_Code
                cross join all_condo_price_calculate acpc2
                left join realist_score rs on acpc2.Condo_Code = rs.Condo_Code
                left join real_condo rc2 on acpc2.Condo_Code = rc2.Condo_Code
                left join (select Condo_Code
                                , min(Distance) as Distance
                            from condo_around_station_view
                            where Total_Point < 100
                            group by Condo_Code) station2
                on acpc2.Condo_Code = station2.Condo_Code) aaa
        where Condo_Code = eachcondo
        and Condo_Code2 <> eachcondo
        order by price_point + age_point + location_point + station_point + score_point + highrise_point desc
        limit 10;
    
    END LOOP similarCondo;
    CLOSE cur;

    if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(total_rows, ' rows_insert from ', total_rows/10, ' condo');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

END //
DELIMITER ;