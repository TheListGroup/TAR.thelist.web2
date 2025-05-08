-- -----------------------------------------------------
-- Table `classified_badge`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_badge` (
    `ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Badge_Name` VARCHAR(250) NOT NULL,
    `Badge_Order` SMALLINT UNSIGNED NOT NULL,
    `Badge_Color` TEXT NOT NULL default '#000000',
    `Badge_Status` ENUM('0','1','2') NOT NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- table `classified_condo_badge_relationship`
CREATE TABLE classified_condo_badge_relationship (
    `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` varchar(50) NOT NULL,
    `Badge_Code` varchar(20) NOT NULL,
    PRIMARY KEY (ID),
    INDEX cb_code (Classified_ID),
    INDEX cb_badge (Badge_Code))
ENGINE=InnoDB;

/*-- procedure truncateInsert_classified_badge
DROP PROCEDURE IF EXISTS truncateInsert_classified_badge;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_badge()
BEGIN
    DECLARE total_rows INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE classified_id VARCHAR(50) DEFAULT NULL;
    DECLARE condo_code VARCHAR(50) DEFAULT NULL;
    DECLARE under_market_price_sale VARCHAR(50) DEFAULT NULL;
    DECLARE under_market_price_rent VARCHAR(50) DEFAULT NULL;
    DECLARE new_project VARCHAR(50) DEFAULT NULL;
    DECLARE private_lift VARCHAR(50) DEFAULT NULL;
    DECLARE branded_residence VARCHAR(50) DEFAULT NULL;
    DECLARE river_view VARCHAR(50) DEFAULT NULL;
    DECLARE luxury_unit VARCHAR(50) DEFAULT NULL;
    DECLARE pet_friendly VARCHAR(50) DEFAULT NULL;
    DECLARE next_to_station VARCHAR(50) DEFAULT NULL;
    DECLARE new_listing VARCHAR(50) DEFAULT NULL;
    DECLARE badges VARCHAR(250) DEFAULT NULL;
    DECLARE badge_group VARCHAR(250) DEFAULT NULL;
    DECLARE x INT DEFAULT 1;
    DECLARE badge VARCHAR(250) DEFAULT NULL;
    DECLARE badge_code VARCHAR(250) DEFAULT NULL;
    DECLARE done INT DEFAULT FALSE;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_badge';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE cur CURSOR FOR select c.Classified_ID
                                    , c.Condo_Code
                                    , CASE 
                                        WHEN c.Price_Sale IS NOT NULL THEN 
                                            CASE 
                                                WHEN (c.Price_Sale / c.Size) <= sale_price.Price_Sale THEN 1
                                                ELSE NULL
                                            END
                                        ELSE NULL
                                    END AS 'Under Market Price Sale'
                                    , CASE 
                                        WHEN c.Price_Rent IS NOT NULL THEN 
                                            CASE 
                                                WHEN c.Price_Rent <= rent_price.Price_Rent THEN 2
                                                ELSE NULL
                                            END
                                        ELSE NULL
                                    END AS 'Under Market Price Rent'
                                    , spotlight.cus032 as 'New_Project'
                                    , spotlight.ps026 as 'Private_Lift'
                                    , spotlight.ps006 as 'Branded_Residence'
                                    , spotlight.ps003 as 'River_View'
                                    , spotlight.ps019 as 'Luxury_Unit'
                                    , spotlight.ps016 as 'Pet_Friendly'
                                    , ifnull(if(spotlight.cus001 is not null
                                                , concat('ติด', ' ', next_to_station.MTran_ShortName, ' ', next_to_station.Station_THName_Display)
                                                , if(spotlight.cus002 is not null
                                                    , concat('ติด', ' ', next_to_station.MTran_ShortName, ' ', next_to_station.Station_THName_Display)
                                                    , NULL)),NULL) as 'Next_to_Station'
                                    , if(DATE(c.Created_Date) >= (CURDATE() - INTERVAL 7 DAY), 8, NULL) as 'New_Listing'
                                from classified c
                                left join (SELECT c.Classified_ID, c.Condo_Code, c.Price_Sale
                                            FROM classified c
                                            join (SELECT subquery.Condo_Code, subquery.Price_Sale
                                                    FROM (SELECT Condo_Code, Classified_ID, Price_Sale, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Price_Sale) AS row_num
                                                            FROM classified
                                                            WHERE Classified_Status = '1'
                                                            AND Sale = 1) AS subquery
                                                    join (SELECT Condo_Code, count(*) as total_rows
                                                            FROM classified
                                                            WHERE Classified_Status = '1'
                                                            AND Sale = 1
                                                            group by Condo_Code) AS subquery2
                                                    on subquery.Condo_Code = subquery2.Condo_Code
                                                    where subquery2.total_rows >= 3
                                                    and subquery.row_num = FLOOR((subquery2.total_rows - 1) * 0.03) + 1
                                                    and subquery.Price_Sale is not null) percentile_values
                                            on c.Condo_Code = percentile_values.Condo_Code
                                            WHERE c.Classified_Status = '1'
                                            AND c.Sale = 1
                                            and c.Price_Sale <= percentile_values.Price_Sale) sale_price
                                on c.Classified_ID = sale_price.Classified_ID
                                left join (SELECT c.Classified_ID, c.Condo_Code, c.Price_Rent
                                            FROM classified c
                                            join (SELECT subquery.Condo_Code, subquery.Price_Rent
                                                    FROM (SELECT Condo_Code, Classified_ID, Price_Rent, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Price_Rent) AS row_num
                                                            FROM classified
                                                            WHERE Classified_Status = '1'
                                                            AND Rent = 1) AS subquery
                                                    join (SELECT Condo_Code, count(*) as total_rows
                                                            FROM classified
                                                            WHERE Classified_Status = '1'
                                                            AND Rent = 1
                                                            group by Condo_Code) AS subquery2
                                                    on subquery.Condo_Code = subquery2.Condo_Code
                                                    where subquery2.total_rows >= 3
                                                    and subquery.row_num = FLOOR((subquery2.total_rows - 1) * 0.03) + 1
                                                    and subquery.Price_Rent is not null) percentile_values
                                            on c.Condo_Code = percentile_values.Condo_Code
                                            WHERE c.Classified_Status = '1'
                                            AND c.Rent = 1
                                            and c.Price_Rent <= percentile_values.Price_Rent) rent_price
                                on c.Classified_ID = rent_price.Classified_ID
                                left join (SELECT Condo_Code
                                                , if(PS016 = 'Y',7,NULL) as ps016
                                                , if(PS026 = 'Y',3,NULL) as ps026
                                                , if(PS019 = 'Y',6,NULL) as ps019
                                                , if(CUS032 = 'Y',9,NULL) as cus032
                                                , if(CUS001 = 'Y',10,NULL) as cus001
                                                , if(CUS002 = 'Y',10,NULL) as cus002
                                                , if(PS006 = 'Y',4,NULL) as ps006
                                                , if(PS003 = 'Y',5,NULL) as ps003
                                            FROM `condo_spotlight_relationship_view`
                                            where (PS016 = 'Y' or PS026 = 'Y' or PS019 = 'Y' or CUS032 = 'Y' or CUS001 = 'Y' or CUS002 = 'Y'
                                                or PS006 = 'Y' or PS003 = 'Y')) spotlight
                                on c.Condo_Code = spotlight.Condo_Code
                                left join (select Condo_Code
                                                , Station_THName_Display
                                                , Station_Timeline
                                                , MTran_ShortName
                                                , Distance
                                            from (SELECT a.Condo_Code
                                                        , b.Station_THName_Display
                                                        , b.Station_Timeline
                                                        , d.MTran_ShortName
                                                        , a.Distance
                                                        , ROW_NUMBER() OVER (PARTITION BY a.Condo_Code ORDER BY a.Distance) AS Myorder
                                                    FROM `condo_around_station` a 
                                                    join mass_transit_station b on a.Station_Code = b.Station_Code 
                                                    join mass_transit_line c on a.Line_Code = c.Line_Code 
                                                    join mass_transit d on c.MTrand_ID = d.MTran_ID 
                                                    join all_condo_spotlight_relationship e on a.Condo_Code = e.Condo_Code 
                                                    WHERE (e.CUS001 = 'Y' or e.CUS002 = 'Y') 
                                                    and b.Station_Timeline = 'Completion') aa
                                            where Myorder = 1
                                            and Distance <= 0.1) next_to_station
                                on c.Condo_Code = next_to_station.Condo_Code
                                where c.Classified_Status = '1';
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',classified_id);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    TRUNCATE TABLE classified_condo_badge_relationship;
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO classified_id, condo_code, under_market_price_sale, under_market_price_rent, new_project, private_lift, branded_residence, river_view, luxury_unit, pet_friendly, next_to_station, new_listing;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET badges = concat(under_market_price_sale, under_market_price_rent, new_project, private_lift, branded_residence, river_view, luxury_unit, pet_friendly, next_to_station, new_listing);
        SET badge_group = concat_ws(',',1,2,3,4,5,6,7,8,9,10);
        
        WHILE x <= 10 DO
            SET badge = SUBSTRING(badges, x, 1);
            IF badge is not null THEN
                SET badge_code = SUBSTRING_INDEX(SUBSTRING_INDEX(badge_group, ',', x), ',', -1);
                
                INSERT INTO classified_condo_badge_relationship (Classified_ID, Badge_Code) VALUES (classified_id, badge_code);
                
            END IF;
            SET x = x + 1;
        END WHILE;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
		SET i = i + 1;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows calculated.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;
END //
DELIMITER ;*/