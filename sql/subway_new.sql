create or replace view source_mass_transit_station_match_route as
select mtl.Line_Order
    , mtl.Line_Name
    , mtl.Line_Color
    , mtr.Route_Code
    , mtr.Route_Order
    , mtr.Route_Name
    , mtr.Route_Timeline
    , mts.Station_ID
    , mts.Station_Code
    , mts.Station_THName_Display
    , mts.Station_Latitude
    , mts.Station_Longitude
    , mts.Station_Boundary
    , mts.Station_Timeline
    , mts.Station_Order
    , (mts.Station_Status_Cal_Point + mts.Station_Junction_Cal_Point + mts.Place_Distance_From_Center_Point) as Total_Point
from mass_transit_route mtr
left join mass_transit_line mtl on mtl.Line_Code = mtr.Line_Code
left join mass_transit_station mts on mts.Route_Code = mtr.Route_Code
where mts.Station_ID is not null
order by mtl.Line_Order, mts.Station_Timeline, mts.Station_Order, mtr.Route_Order;

CREATE TABLE IF NOT EXISTS `mass_transit_station_match_route` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Line_Order INT NOT NULL,
    Line_Name VARCHAR(50) NOT NULL,
    Line_Color VARCHAR(50) NOT NULL,
    Route_Code VARCHAR(30) NULL,
    Route_Order INT NOT NULL,
    Route_Name VARCHAR(250) NOT NULL,
    Route_Timeline VARCHAR(150) NULL,
    Station_ID INT NOT NULL,
    Station_Code VARCHAR(100) NULL,
    Station_THName_Display VARCHAR(200) NOT NULL,
    Station_Latitude DOUBLE NULL,
    Station_Longitude DOUBLE NULL,
    Station_Boundary TEXT NULL,
    Station_Timeline ENUM('Completion','Under Construction','Planning') NULL,
    Station_Order INT NOT NULL,
    Total_Point DOUBLE NULL DEFAULT 0,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

DROP PROCEDURE IF EXISTS truncateInsert_mass_transit_station_match_route;
DELIMITER //

CREATE PROCEDURE truncateInsert_mass_transit_station_match_route ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name10 DOUBLE DEFAULT NULL;
	DECLARE v_name11 DOUBLE DEFAULT NULL;
	DECLARE v_name12 TEXT DEFAULT NULL;
	DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name15 DOUBLE DEFAULT NULL;

	DECLARE proc_name       VARCHAR(60) DEFAULT 'truncateInsert_mass_transit_station_match_route';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Line_Order, Line_Name, Line_Color, Route_Code, Route_Order, Route_Name, Route_Timeline
                                , Station_ID, Station_Code, Station_THName_Display, Station_Latitude, Station_Longitude
                                , Station_Boundary, Station_Timeline, Station_Order, Total_Point
                            FROM source_mass_transit_station_match_route;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name7);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE mass_transit_station_match_route;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			mass_transit_station_match_route(
				Line_Order
                , Line_Name
                , Line_Color
                , Route_Code
                , Route_Order
                , Route_Name
                , Route_Timeline
                , Station_ID
                , Station_Code
                , Station_THName_Display
                , Station_Latitude
                , Station_Longitude
                , Station_Boundary
                , Station_Timeline
                , Station_Order
                , Total_Point
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15);
        
		GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
		SET i = i + 1;
    END LOOP;

	if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

	
    CLOSE cur;
END //
DELIMITER ;