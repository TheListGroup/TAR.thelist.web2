-- Table `estimate_price_index`
-- insert estimate_price_index
-- Table `condo_surrounding`
-- Table `condo_station_surrounding`
-- Table `estimate_condo_price`
-- procedure Station_Condo_Surrounding
-- procedure Condo_Surrounding
-- procedure Estimate_Condo_Price

-- -----------------------------------------------------
-- Table `estimate_price_index`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estimate_price_index` (
    `ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Year_Start` year NOT NULL,
    `Index_Values` INT NOT NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- insert estimate_price_index
insert into estimate_price_index (Year_Start,Index_Values) values
(2024,200), (2023,191), (2022,182), (2021,178), (2020,168), (2019,161), (2018,162), (2017,155), (2016,151), (2015,135), (2014,124), (2013,110), (2012,103), (2011,100),
(2010,96), (2009,93), (2008,88), (2007,89), (2006,89), (2005,85), (2004,79), (2003,75), (2002,73), (2001,72), (2000,73), (1999,70), (1998,78), (1997,80),
(1996,75), (1995,73), (1994,69), (1993,69), (1992,63), (1991,55), (1990,52), (1989,45), (1988,42), (1987,39), (1986,37), (1985,34), (1984,31), (1983,28),
(1982,25), (1981,22), (1980,19), (1979,16), (1978,13), (1977,10), (1976,7), (1975,4);

-- -----------------------------------------------------
-- Table `condo_surrounding`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `condo_surrounding` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_CodeX` varchar(50) NOT NULL,
    `Condo_Code2` varchar(50) NOT NULL,
    `Price` INT UNSIGNED NOT NULL,
    `Station_Distance1` DOUBLE NULL,
    `Station_Distance2` DOUBLE NULL,
    `Built_Started` YEAR NOT NULL,
    `PriceX` INT UNSIGNED NULL,
    `Station_DistanceX1` DOUBLE NULL,
    `Station_DistanceX2` DOUBLE NULL,
    `Built_StartedX` YEAR NOT NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `condo_station_surrounding`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `condo_station_surrounding` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_Code` varchar(50) NOT NULL,
    `Station_Distance1` DOUBLE NULL,
    `Station_Distance2` DOUBLE NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `estimate_condo_price`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estimate_condo_price` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_Code` varchar(50) NOT NULL,
    `Price` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;


-- procedure Station_Condo_Surrounding
DROP PROCEDURE IF EXISTS Station_Condo_Surrounding;
DELIMITER //

CREATE PROCEDURE Station_Condo_Surrounding ()
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'Station_Condo_Surrounding';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE i           INTEGER     DEFAULT 0;
	DECLARE total_rows  INTEGER     DEFAULT 0;
    DECLARE nrows       INTEGER     DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    truncate table condo_station_surrounding;

    insert into condo_station_surrounding (Condo_Code, Station_Distance1, Station_Distance2)
    select a.Condo_Code
        , station1.Station_Distance as Station_Distance1
        , station2.Station_Distance as Station_Distance2
    from real_condo a
    left join (select Condo_Code, Station_Distance
                from (select Condo_Code, Station_Distance, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Station_Distance) AS Myorder
                        from (select rc.Condo_Code
                                    , 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - ms.Station_Latitude)) / 2), 2)
                                        + COS(RADIANS(ms.Station_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                                        POWER(SIN((RADIANS(rc.Condo_Longitude - ms.Station_Longitude)) / 2), 2 ))) as Station_Distance
                                from real_condo rc
                                cross join mass_transit_station ms
                                where rc.Condo_Status = 1
                                and rc.Condo_Latitude is not null
                                and rc.Condo_Longitude is not null
                                order by rc.Condo_Code) order_distance) aaa
                where Myorder = 1) station1
    on a.Condo_Code = station1.Condo_Code
    left join (select Condo_Code, Station_Distance
                from (select Condo_Code, Station_Distance, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Station_Distance) AS Myorder
                        from (select rc.Condo_Code
                                    , 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - ms.Station_Latitude)) / 2), 2)
                                        + COS(RADIANS(ms.Station_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                                        POWER(SIN((RADIANS(rc.Condo_Longitude - ms.Station_Longitude)) / 2), 2 ))) as Station_Distance
                                from real_condo rc
                                cross join mass_transit_station ms
                                where rc.Condo_Status = 1
                                and rc.Condo_Latitude is not null
                                and rc.Condo_Longitude is not null
                                order by rc.Condo_Code) order_distance) aaa
                where Myorder = 2) station2
    on a.Condo_Code = station2.Condo_Code
    where a.Condo_Status = 1
    and a.Condo_Latitude is not null
    and a.Condo_Longitude is not null
    order by a.Condo_Code;

    GET DIAGNOSTICS nrows = ROW_COUNT;
    SET total_rows = total_rows + nrows;
    SET i = i + 1;

    if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(total_rows, ' rows_insert');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

END //
DELIMITER ;


-- procedure Condo_Surrounding
DROP PROCEDURE IF EXISTS Condo_Surrounding;
DELIMITER //

CREATE PROCEDURE Condo_Surrounding ()
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'Condo_Surrounding';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE finished        INTEGER     DEFAULT 0;
    DECLARE eachcondo       VARCHAR(20) DEFAULT NULL;
    DECLARE eachprice       INTEGER     DEFAULT 0;
    DECLARE eachdistance    DOUBLE      DEFAULT 0;
    DECLARE eachdistance2   DOUBLE      DEFAULT 0;
    DECLARE eachyear        YEAR        DEFAULT NULL;
    
    DECLARE eachradius      FLOAT       DEFAULT 1.8;
    DECLARE eachlimit       INTEGER     DEFAULT 10;

    DECLARE i           INTEGER     DEFAULT 0;
	DECLARE total_rows  INTEGER     DEFAULT 0;
    DECLARE nrows       INTEGER     DEFAULT 0;

    DEClARE cur CURSOR FOR select a.Condo_Code
                                , use_price.Price
                                , station.Station_Distance1
                                , station.Station_Distance2
                                , year(b.Condo_Date_Calculate) as Built_Started
                            from real_condo a
                            left join all_condo_price_calculate b on a.Condo_Code = b.Condo_Code
                            left join (select Condo_Code, Price
                                        from (select Condo_Code
                                                    , Price,ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date) AS Myorder
                                                FROM all_price_view ap
                                                left join price_source ps on ap.Price_Source = ps.ID
                                                where ps.Head in ('Online Survey','Developer','Company Presentation')
                                                and ap.Price_Type = 'บ/ตรม'
                                                and ap.Start_or_AVG = 'เฉลี่ย'
                                                and ap.Resale = '0') avg_price
                                        where Myorder = 1) use_price
                            on a.Condo_Code = use_price.Condo_Code
                            left join condo_station_surrounding station on a.Condo_Code = station.Condo_Code
                            where a.Condo_Status = 1
                            and a.Condo_Latitude is not null
                            and a.Condo_Longitude is not null
                            and use_price.Price is null
                            and b.Condo_Date_Calculate is not null
                            order by a.Condo_Code;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    truncate table condo_surrounding;

    OPEN cur;
    nearcondo: LOOP
		FETCH cur INTO eachcondo, eachprice, eachdistance, eachdistance2, eachyear;
		IF finished = 1 THEN 
			LEAVE nearcondo;
		END IF;

        CREATE TEMPORARY TABLE temp_table AS
        select aa.Condo_Code as Condo_CodeX, aa.Condo_Code2, use_price.Price as Price, station.Station_Distance1 as Station_Distance1
            , station.Station_Distance2 as Station_Distance2, year(b.Condo_Date_Calculate) as Built_Started
            , eachprice as PriceX, eachdistance as DistanceX1, eachdistance2 as DistanceX2, eachyear as Built_StartedX
        from (select rc.Condo_Code
                , rc2.Condo_Code as Condo_Code2
                , 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rc2.Condo_Latitude)) / 2), 2)
                    + COS(RADIANS(rc2.Condo_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                    POWER(SIN((RADIANS(rc.Condo_Longitude - rc2.Condo_Longitude)) / 2), 2 ))) as Distance
                from real_condo rc
                cross join real_condo rc2
                where rc.Condo_Status = 1
                and rc.Condo_Code = eachcondo
                and rc2.Condo_Code <> eachcondo
                and rc2.Condo_Latitude is not null
                and rc2.Condo_Longitude is not null) aa
        left join all_condo_price_calculate b on aa.Condo_Code2 = b.Condo_Code
        left join (select Condo_Code, Price
                    from (select Condo_Code
                                , Price,ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date) AS Myorder
                            FROM all_price_view ap
                            left join price_source ps on ap.Price_Source = ps.ID
                            where ps.Head in ('Online Survey','Developer','Company Presentation')
                            and ap.Price_Type = 'บ/ตรม'
                            and ap.Start_or_AVG = 'เฉลี่ย'
                            and ap.Resale = '0') avg_price
                    where Myorder = 1) use_price
        on aa.Condo_Code2 = use_price.Condo_Code
        left join condo_station_surrounding station on aa.Condo_Code2 = station.Condo_Code
        where aa.Distance <= eachradius
        and use_price.Price is not null
        and b.Condo_Date_Calculate is not null
        order by aa.Distance
        limit eachlimit;

        insert into condo_surrounding (Condo_CodeX, Condo_Code2, Price, Station_Distance1, Station_Distance2, Built_Started, PriceX, Station_DistanceX1
        , Station_DistanceX2, Built_StartedX)
        SELECT Condo_CodeX, Condo_Code2, Price, Station_Distance1, Station_Distance2, Built_Started, PriceX, DistanceX1, DistanceX2, Built_StartedX FROM temp_table;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;

        DROP TEMPORARY TABLE IF EXISTS temp_table;
    
    END LOOP nearcondo;
    CLOSE cur;

    if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(total_rows, ' rows_insert');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

END //
DELIMITER ;


-- procedure Estimate_Condo_Price
DROP PROCEDURE IF EXISTS Estimate_Condo_Price;
DELIMITER //

CREATE PROCEDURE Estimate_Condo_Price ()
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'Estimate_Condo_Price';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

	DECLARE total_rows  INTEGER     DEFAULT 0;
    DECLARE nrows       INTEGER     DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    truncate table estimate_condo_price;

    insert into estimate_condo_price (Condo_Code, Price)
    select Condo_CodeX as Conco_Code
        , round(avg(final_cal)) as Price
    from (select cs.Condo_CodeX, cs.Built_StartedX, cs.Station_DistanceX1, cs.Station_DistanceX2, ei1.Index_Values as Index_ValuesX, cs.Condo_Code2, cs.Built_Started, cs.Station_Distance1, cs.Station_Distance2, ei2.Index_Values, cs.Price
                , cs.Price/ei2.Index_Values*ei1.Index_Values as Year_Price
                , (cs.Price/ei2.Index_Values*ei1.Index_Values)*ABS((cs.Station_Distance1+cs.Station_Distance2)-(cs.Station_DistanceX1+cs.Station_DistanceX2))*(if(ABS((cs.Station_Distance1+cs.Station_Distance2)-(cs.Station_DistanceX1+cs.Station_DistanceX2))>0.1,-0.2,-0.1)) as cal
                , (cs.Price/ei2.Index_Values*ei1.Index_Values) + ((cs.Price/ei2.Index_Values*ei1.Index_Values)*ABS((cs.Station_Distance1+cs.Station_Distance2)-(cs.Station_DistanceX1+cs.Station_DistanceX2))*(if(ABS((cs.Station_Distance1+cs.Station_Distance2)-(cs.Station_DistanceX1+cs.Station_DistanceX2))>0.1,-0.2,-0.1))) as Distance_Price
                , if(cs.Station_DistanceX1>5,cs.Price/ei2.Index_Values*ei1.Index_Values,(cs.Price/ei2.Index_Values*ei1.Index_Values) + ((cs.Price/ei2.Index_Values*ei1.Index_Values)*ABS((cs.Station_Distance1+cs.Station_Distance2)-(cs.Station_DistanceX1+cs.Station_DistanceX2))*(if(ABS((cs.Station_Distance1+cs.Station_Distance2)-(cs.Station_DistanceX1+cs.Station_DistanceX2))>0.1,-0.2,-0.1)))) as final_cal
            from condo_surrounding cs
            left join estimate_price_index ei1 on cs.Built_StartedX = ei1.Year_Start
            left join estimate_price_index ei2 on cs.Built_Started = ei2.Year_Start) aa
    group by Condo_CodeX
    order by Condo_CodeX;

    GET DIAGNOSTICS nrows = ROW_COUNT;
	SET total_rows = total_rows + nrows;

    if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(total_rows, ' rows_insert');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

END //
DELIMITER ;


-- procedure Estimate_Condo_Price_all
DROP PROCEDURE IF EXISTS Estimate_Condo_Price_all;
DELIMITER //
CREATE PROCEDURE Estimate_Condo_Price_all ()
BEGIN

    CALL Station_Condo_Surrounding ();
    CALL Condo_Surrounding ();
    CALL Estimate_Condo_Price ();

END //
DELIMITER ;