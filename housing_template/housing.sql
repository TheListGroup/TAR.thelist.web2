-- Table housing
-- function check null
-- cal totalRai
-- view source_housing_around_station
    -- table housing_around_station
    -- procedure truncateInsert_housing_around_station
-- view source_housing_around_express_way
    -- table housing_around_express_way
    -- procedure truncateInsert_housing_around_express_way
-- view source_housing_factsheet_view
    -- table housing_factsheet_view
    -- procedure truncateInsert_housing_factsheet_view
-- view source_housing_fetch_for_map
    -- table housing_fetch_for_map
    -- procedure truncateInsert_housing_fetch_for_map


-- view source_housing_around_station
create or replace view source_housing_around_station as
select Station_Code
    , Station_THName_Display
    , Route_Code
    , Line_Code
    , Housing_Code
    , Distance
from (SELECT mtsmr.Station_Code
            , mtsmr.Station_THName_Display
            , mtsmr.Route_Code
            , mtr.Line_Code
            , mtsmr.Station_Latitude
            , mtsmr.Station_Longitude
            , asok.Station_Latitude as asok_lat
            , asok.Station_Longitude as asok_long
            , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(mtsmr.Station_Latitude - asok.Station_Latitude)) / 2), 2)
                + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(mtsmr.Station_Latitude)) *
                POWER(SIN((RADIANS(mtsmr.Station_Longitude - asok.Station_Longitude)) / 2), 2)))) AS station_distance
            , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(mtsmr.Station_Latitude - asok.Station_Latitude)) / 2), 2)
                                    + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(mtsmr.Station_Latitude)) *
                                    POWER(SIN((RADIANS(mtsmr.Station_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
            , h.Housing_Code
            , h.Housing_Latitude
            , h.Housing_Longitude
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - mtsmr.Station_Latitude)) / 2), 2)
                + COS(RADIANS(mtsmr.Station_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                POWER(SIN((RADIANS(h.Housing_Longitude - mtsmr.Station_Longitude)) / 2), 2 )))) AS Distance
        FROM mass_transit_station_match_route mtsmr
        left join mass_transit_route mtr on mtsmr.Route_Code = mtr.Route_Code
        cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
        cross join (select * from housing where Housing_Status = '1') h) aaa  
where aaa.Distance <= aaa.cal_radians;

-- table housing_around_station
CREATE TABLE IF NOT EXISTS housing_around_station (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Station_Code VARCHAR(50) NOT NULL,
    Station_THName_Display VARCHAR(200) NULL,
    Route_Code VARCHAR(30) NOT NULL,
    Line_Code VARCHAR(30) NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- procedure truncateInsert_housing_around_station
DROP PROCEDURE IF EXISTS truncateInsert_housing_around_station;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_around_station ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(250) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_around_station';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Station_Code, Station_THName_Display, Route_Code, Line_Code, Housing_Code, Distance
                            FROM source_housing_around_station;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name4);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    housing_around_station;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			housing_around_station(
				Station_Code
                , Station_THName_Display
                , Route_Code
                , Line_Code
                , Housing_Code
                , Distance
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5);
        
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

-- view source_housing_around_express_way
create or replace view source_housing_around_express_way as
select Place_ID
    , Place_Attribute_1
    , Place_Attribute_2
    , Housing_Code
    , Distance
from (SELECT rpe.Place_ID
            , rpe.Place_Attribute_1
            , rpe.Place_Attribute_2
            , rpe.Place_Latitude
            , rpe.Place_Longitude
            , asok.Station_Latitude as asok_lat
            , asok.Station_Longitude as asok_long
            , ( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpe.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpe.Place_Latitude)) *
                POWER(SIN((RADIANS(rpe.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) AS station_distance
            , least(greatest(0.36*( 6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rpe.Place_Latitude - asok.Station_Latitude)) / 2), 2)
                + COS(RADIANS(asok.Station_Latitude)) * COS(RADIANS(rpe.Place_Latitude)) *
                POWER(SIN((RADIANS(rpe.Place_Longitude - asok.Station_Longitude)) / 2), 2)))) - 0.8,1),10) AS cal_radians
            , h.Housing_Code
            , h.Housing_Latitude
            , h.Housing_Longitude
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rpe.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rpe.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                POWER(SIN((RADIANS(h.Housing_Longitude - rpe.Place_Longitude)) / 2), 2 )))) AS Distance
        FROM real_place_express_way rpe
        cross join (select * from mass_transit_station_match_route where Station_Code = 'E4') asok
        cross join (select * from housing where Housing_Status = '1') h) aaa  
where aaa.Distance <= aaa.cal_radians;

-- table housing_around_express_way
CREATE TABLE IF NOT EXISTS housing_around_express_way (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Place_ID INT UNSIGNED NOT NULL,
    Place_Attribute_1 VARCHAR(150) NOT NULL,
    Place_Attribute_2 VARCHAR(150) NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- procedure truncateInsert_housing_around_express_way
DROP PROCEDURE IF EXISTS truncateInsert_housing_around_express_way;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_around_express_way ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_around_express_way';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Place_ID, Place_Attribute_1, Place_Attribute_2, Housing_Code, Distance
                            FROM source_housing_around_express_way;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name3);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    housing_around_express_way;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			housing_around_express_way(
				Place_ID
                , Place_Attribute_1
                , Place_Attribute_2
                , Housing_Code
                , Distance
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4);
        
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

-- table housing_spotlight
CREATE TABLE housing_spotlight (
    Spotlight_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Spotlight_Order int NOT NULL,
    Spotlight_Type varchar(20) NOT NULL,
    Spotlight_Code varchar(20) NOT NULL,
    Spotlight_Name varchar(150) NOT NULL,
    Spotlight_Label varchar(200) NOT NULL,
    Spotlight_Icon varchar(200) NOT NULL,
    Spotlight_Inactive int NOT NULL,
    Condo_Count int NOT NULL,
    Menu_List int NOT NULL,
    Menu_Price_Order int NOT NULL,
    Spotlight_Cover int NOT NULL,
    Spotlight_Title varchar(250) NOT NULL,
    Spotlight_Description text NOT NULL,
    Keyword_TH text null,
    Keyword_ENG text null)
ENGINE = InnoDB;

SELECT Housing_Code,Bedroom_Max 
FROM `housing`
where Bedroom_Max >= 4;

SELECT Housing_Code,Housing_Price_Min,Housing_Price_Max 
FROM `housing`
where (Housing_Price_Max < 3000000 and Housing_Price_Min >= 1000000)
or (Housing_Price_Max is null and Housing_Price_Min >= 1000000 and Housing_Price_Min < 3000000);

-- -----------------------------------------------------
-- Table housing
---- รอเพิ่ม column คะแนน
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS housing (
    Housing_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Name VARCHAR(250) NULL DEFAULT NULL,
    Housing_ENName VARCHAR(250) NULL DEFAULT NULL,
    Brand_Code VARCHAR(10) NULL DEFAULT NULL,
    Developer_Code VARCHAR(30) NULL DEFAULT NULL,
    Housing_Latitude DOUBLE NULL DEFAULT NULL,
    Housing_Longitude DOUBLE NULL DEFAULT NULL,
    Coordinate_Mark SMALLINT NOT NULL,
    Housing_ScopeArea TEXT NULL DEFAULT NULL,
    Road_Name VARCHAR(50) NULL DEFAULT NULL,
    Postal_Code INT NULL DEFAULT NULL,
    SubDistrict_ID INT NULL DEFAULT NULL,
    District_ID INT NULL DEFAULT NULL,
    Province_ID INT NULL DEFAULT NULL,
    Address_Mark SMALLINT NOT NULL, 
    RealSubDistrict_Code VARCHAR(30) NULL DEFAULT NULL,
    RealDistrict_Code VARCHAR(30) NULL DEFAULT NULL,
    Housing_LandRai FLOAT(10,5) NULL DEFAULT NULL,
    Housing_LandNgan FLOAT(10,5) NULL DEFAULT NULL,
    Housing_LandWa FLOAT(10,5) NULL DEFAULT NULL,
    Housing_TotalRai FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Floor_Min INT NULL DEFAULT NULL,
    Housing_Floor_Max INT NULL DEFAULT NULL,
    Housing_TotalUnit INT NULL DEFAULT NULL,
    Housing_Area_Min FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Area_Max FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Usable_Area_Min FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Usable_Area_Max FLOAT(10,5) NULL DEFAULT NULL,
    Bedroom_Min INT NULL DEFAULT NULL,
    Bedroom_Max INT NULL DEFAULT NULL,
    Bathroom_Min INT NULL DEFAULT NULL,
    Bathroom_Max INT NULL DEFAULT NULL,
    Housing_Price_Min INT NULL DEFAULT NULL,
    Housing_Price_Max INT NULL DEFAULT NULL,
    Housing_Price_Date DATE NULL DEFAULT NULL,
    Housing_Built_Start DATE NULL DEFAULT NULL,
    Housing_Built_Finished DATE NULL DEFAULT NULL,
    Housing_Sold_Status_Raw_Number FLOAT NULL DEFAULT NULL,
    Housing_Sold_Status_Date DATE NULL DEFAULT NULL,
    Housing_Parking_Min INT NULL DEFAULT NULL,
    Housing_Parking_Max INT NULL DEFAULT NULL,
    Housing_Common_Fee_Min INT NULL DEFAULT NULL,
    Housing_Common_Fee_Max INT NULL DEFAULT NULL,
    IS_SD BOOLEAN NOT NULL DEFAULT 0,
    IS_DD BOOLEAN NOT NULL DEFAULT 0,
    IS_TH BOOLEAN NOT NULL DEFAULT 0,
    IS_HO BOOLEAN NOT NULL DEFAULT 0,
    IS_SH BOOLEAN NOT NULL DEFAULT 0,
    Housing_Spotlight_1 VARCHAR(250) NULL,
    Housing_Spotlight_2 VARCHAR(250) NULL,
    Realist_Score DECIMAL(44,12) NULL,
    Housing_URL_Tag VARCHAR(200) NULL DEFAULT NULL,
    Housing_Cover BOOLEAN NOT NULL DEFAULT 0,
    Housing_Redirect VARCHAR(10) NULL DEFAULT NULL,
    Housing_Pageviews INT NOT NULL DEFAULT 0,
    Housing_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Housing_ID),
    INDEX housing_admin1 (Created_By),
    INDEX housing_admin2 (Last_Updated_By),
    INDEX housing_housing_code (Housing_Code),
    INDEX housing_lat (Housing_Latitude),
    INDEX housing_long (Housing_Longitude),
    INDEX housing_brand (Brand_Code),
    INDEX housing_dev (Developer_Code),
    INDEX housing_subdistrict (SubDistrict_ID),
    INDEX housing_district (District_ID),
    INDEX housing_province (Province_ID),
    INDEX housing_realsubdistrict (RealSubDistrict_Code),
    INDEX housing_realdistrict (RealDistrict_Code),
    CONSTRAINT home_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT home_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- function check null
DELIMITER //
CREATE FUNCTION h_nun(nan VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = if(nan='','N/A',ifnull(nan,'N/A'));
    RETURN unit;
END //

-- cal totalRai
update real_housing
set Housing_TotalRai = (Housing_LandNgan*100) + Housing_LandWa / 400 + Housing_LandRai;

-- view source_housing_factsheet_view
create or replace view source_housing_factsheet_view as
select a.Housing_Code
    , h_nun(if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
            , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                , concat(format(a.Housing_Area_min,0),' ตร.ว.')
                , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0),' ตร.ว.'))
            , concat(format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0),' ตร.ว.'))) as Housing_Area
    , h_nun(if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
            , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                , concat(format(a.Housing_Usable_Area_Min,0),' ตร.ม.')
                , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0),' ตร.ม.'))
            , concat(format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0),' ตร.ม.'))) as Usable_Area
    , h_nun(if(a.Bedroom_Min is not null and a.Bedroom_Max is not null
            , if(a.Bedroom_Min=a.Bedroom_Max
                , concat(a.Bedroom_Min,' ห้อง')
                , concat(a.Bedroom_Min,' - ',a.Bedroom_Max,' ห้อง'))
            , concat(ifnull(a.Bedroom_Max,a.Bedroom_Min),' ห้อง'))) as Bedroom
    , h_nun(year(a.Housing_Price_Date)) as Price_Date
    , h_nun(if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
            , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                , concat(format(a.Housing_Price_Min/1000000,1),' ลบ.')
                , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1),' ลบ.'))
            , concat(format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1),' ลบ.'))) as Price
    , h_nun(express_way.Express_Way) as Express_Way
    , h_nun(rd.District_Name) as RealDistrict 
    , h_nun(td.name_th) as District
    , h_nun(tp.name_th) as Province
    , h_nun(concat_ws(', ',if(a.IS_SD=1,'บ้านเดี่ยว',null),if(a.IS_DD=1,'บ้านแฝด',null),if(a.IS_TH=1,'ทาวน์โฮม',null)
                        , if(a.IS_HO=1,'โฮมออฟฟิศ',null), if(a.IS_SH=1,'อาคารพาณิชย์',null))) as Housing_Type
    , h_nun(concat(format(a.Housing_TotalRai,2),' ไร่')) as Housing_TotalRai
    , h_nun(concat(a.Housing_TotalUnit,' หลัง')) as TotalUnit
    , h_nun(year(a.Housing_Built_Start)) as Housing_Built_Start
    , h_nun(year(a.Housing_Sold_Status_Date)) as Housing_Sold_Status_Date
    , h_nun(a.Housing_Sold_Status_Raw_Number) as Housing_Sold_Status
    , h_nun(if(a.Housing_Floor_Min is not null and a.Housing_Floor_Max is not null
            , if(a.Housing_Floor_Min=a.Housing_Floor_Max
                , concat(a.Housing_Floor_Min,' ชั้น')
                , concat(a.Housing_Floor_Min,' - ',a.Housing_Floor_Max,' ชั้น'))
            , concat(ifnull(a.Housing_Floor_Max,a.Housing_Floor_Min),' ชั้น'))) as Floor
    , h_nun(if(a.Bedroom_Min is not null and a.Bedroom_Max is not null
            , if(a.Bedroom_Min=a.Bedroom_Max
                , concat(a.Bedroom_Min,' ห้อง')
                , concat(a.Bedroom_Min,' - ',a.Bedroom_Max,' ห้อง'))
            , concat(ifnull(a.Bedroom_Max,a.Bedroom_Min),' ห้อง'))) as Bedroom_Factsheet
    , h_nun(if(a.Bathroom_Min is not null and a.Bathroom_Max is not null
            , if(a.Bathroom_Min=a.Bathroom_Max
                , concat(a.Bathroom_Min,' ห้อง')
                , concat(a.Bathroom_Min,' - ',a.Bathroom_Max,' ห้อง'))
            , concat(ifnull(a.Bathroom_Max,a.Bathroom_Min),' ห้อง'))) as Bathroom
    , h_nun(if(a.Housing_Parking_Min is not null and a.Housing_Parking_Max is not null
            , if(a.Housing_Parking_Min=a.Housing_Parking_Max
                , concat(a.Housing_Parking_Min,' คัน')
                , concat(a.Housing_Parking_Min,' - ',a.Housing_Parking_Max,' คัน'))
            , concat(ifnull(a.Housing_Parking_Max,a.Housing_Parking_Min),' คัน'))) as Parking_Amount
    , h_nun(year(a.Housing_Price_Date)) as Price_Date_Factsheet
    , h_nun(if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
            , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                , concat(format(a.Housing_Price_Min/1000000,1),' ลบ.')
                , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1),' ลบ.'))
            , concat(format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1),' ลบ.'))) as Price_Factsheet
    , h_nun(if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
            , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                , concat(format(a.Housing_Area_min,0),' ตร.ว.')
                , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0),' ตร.ว.'))
            , concat(format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0),' ตร.ว.'))) as Housing_Area_Factsheet
    , h_nun(if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
            , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                , concat(format(a.Housing_Usable_Area_Min,0),' ตร.ม.')
                , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0),' ตร.ม.'))
            , concat(format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0),' ตร.ม.'))) as Usable_Area_Factsheet
    , h_nun(if(a.Housing_Common_Fee_Min is not null and a.Housing_Common_Fee_Max is not null
            , if(format(a.Housing_Common_Fee_Min,0)=format(a.Housing_Common_Fee_Max,0)
                , concat(format(a.Housing_Common_Fee_Min,0),' บ./ตร.ว./เดือน')
                , concat(format(a.Housing_Common_Fee_Min,0),' - ',format(a.Housing_Common_Fee_Max,0),' บ./ตร.ว./เดือน'))
            , concat(format(ifnull(a.Housing_Common_Fee_Max,a.Housing_Common_Fee_Min),0),' บ./ตร.ว./เดือน'))) as Common_Fee
from housing a
left join realist_district rd on a.RealDistrict_Code = rd.District_Code
left join thailand_district td on a.District_ID = td.district_code
left join thailand_province tp on a.Province_ID = tp.province_code
left join ( select Housing_Code,concat(Place_Attribute_1,' ',Place_Attribute_2) as Express_Way
            from (  select Housing_Code
                            , Place_ID
                            , Place_Attribute_1
                            , Place_Attribute_2
                            , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                    from housing_around_express_way
                    order by Housing_Code) ew
            where ew.RowNum = 1 ) express_way 
on a.Housing_Code = express_way.Housing_Code
where a.Housing_Status = '1';

-- table housing_factsheet_view
CREATE TABLE IF NOT EXISTS housing_factsheet_view (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Area VARCHAR(30) NOT NULL,
    Usable_Area VARCHAR(30) NOT NULL,
    Bedroom VARCHAR(20) NOT NULL,
    Price_Date VARCHAR(4) NULL,
    Price VARCHAR(30) NOT NULL,
    Express_Way VARCHAR(250) NOT NULL,
    RealDistrict VARCHAR(150) NOT NULL,
    District VARCHAR(150) NOT NULL,
    Province VARCHAR(150) NOT NULL,
    Housing_Type VARCHAR(70) NOT NULL,
    Housing_TotalRai VARCHAR(20) NOT NULL,
    TotalUnit VARCHAR(10) NOT NULL,
    Housing_Built_Start VARCHAR(4) NOT NULL,
    Housing_Sold_Status_Date VARCHAR(4) NULL,
    Housing_Sold_Status VARCHAR(10) NOT NULL,
    Floor VARCHAR(20) NOT NULL,
    Bedroom_Factsheet VARCHAR(20) NOT NULL,
    Bathroom VARCHAR(20) NOT NULL,
    Parking_Amount VARCHAR(20) NOT NULL,
    Price_Date_Factsheet VARCHAR(4) NULL,
    Price_Factsheet VARCHAR(30) NOT NULL,
    Housing_Area_Factsheet VARCHAR(30) NOT NULL,
    Usable_Area_Factsheet VARCHAR(30) NOT NULL,
    Common_Fee VARCHAR(50) NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- procedure truncateInsert_housing_factsheet_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_factsheet_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_factsheet_view ()
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
	DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name22 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name23 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name24 VARCHAR(250) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_factsheet_view';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Housing_Area, Usable_Area, Bedroom, Price_Date, Price, Express_Way
                                , RealDistrict, District, Province, Housing_Type, Housing_TotalRai, TotalUnit, Housing_Built_Start
                                , Housing_Sold_Status_Date, Housing_Sold_Status, Floor, Bedroom_Factsheet, Bathroom, Parking_Amount
                                , Price_Date_Factsheet, Price_Factsheet, Housing_Area_Factsheet, Usable_Area_Factsheet, Common_Fee
                            FROM source_housing_factsheet_view;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    housing_factsheet_view;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			housing_factsheet_view(
				Housing_Code
                , Housing_Area
                , Usable_Area
                , Bedroom
                , Price_Date
                , Price
                , Express_Way                                
                , RealDistrict
                , District
                , Province
                , Housing_Type
                , Housing_TotalRai
                , TotalUnit
                , Housing_Built_Start
                , Housing_Sold_Status_Date
                , Housing_Sold_Status
                , Floor
                , Bedroom_Factsheet
                , Bathroom
                , Parking_Amount
                , Price_Date_Factsheet
                , Price_Factsheet
                , Housing_Area_Factsheet
                , Usable_Area_Factsheet
                , Common_Fee
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24);
        
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

-- view source_housing_fetch_for_map
create or replace view source_housing_fetch_for_map as
select a.Housing_ID as Housing_ID
    , a.Housing_Code as Housing_Code
    , a.Housing_ENName as Housing_ENName
    , b.Housing_Type
    , b.Price
    , b.Housing_Area
    , b.Usable_Area
    , if(a.Housing_Built_Start is null
        , if(a.Housing_Built_Finished is null
            , NULL
            , a.Housing_Built_Finished)
        , a.Housing_Built_Start) AS Housing_Build_Date
    , replace(replace(replace(replace(replace(a.Housing_Name, '\n', ''), '-', ''),'(',''),')',''),' ','') AS Housing_Name_Search
    , replace(replace(replace(replace(replace(a.Housing_ENName, '\n', ''), '-', ''),'(',''),')',''),' ','') AS Housing_ENName_Search
    , a.Housing_ScopeArea
    , a.Housing_Latitude
    , a.Housing_Longitude
    , a.Brand_Code AS Brand_Code
    , a.Developer_Code AS Developer_Code
    , a.RealSubDistrict_Code AS RealSubDistrict_Code
    , a.RealDistrict_Code AS RealDistrict_Code
    , a.SubDistrict_ID AS SubDistrict_ID
    , a.District_ID AS District_ID
    , a.Province_ID AS Province_ID
    , a.Housing_URL_Tag AS Housing_URL_Tag
    , a.Housing_Cover AS Housing_Cover
    , express_way.Housing_around_express_way as Express_Way
    , station.Housing_around_station as Station
    , ROUND(1 + RAND() * 49, 1) as Total_Point
    , if(a.Housing_Built_Start is null
        , if(a.Housing_Built_Finished is null
            , NULL
            , year(curdate()) - year(a.Housing_Built_Finished))
        , year(curdate()) - year(a.Housing_Built_Start)) as Housing_Age
    , a.Housing_Area_Min as Housing_Area_Min
    , a.Housing_Area_Max as Housing_Area_Max
    , a.Housing_Usable_Area_Min as Usable_Area_Min
    , a.Housing_Usable_Area_Max as Usable_Area_Max
    , a.Housing_Price_Min as Price_Min
    , a.Housing_Price_Max as Price_Max
    , if(a.Housing_Price_Min is not null and a.Housing_Price_Max is not null
                , if(format(a.Housing_Price_Min/1000000,1)=format(a.Housing_Price_Max/1000000,1)
                    , format(a.Housing_Price_Min/1000000,1)
                    , concat(format(a.Housing_Price_Min/1000000,1),' - ',format(a.Housing_Price_Max/1000000,1)))
                , format(ifnull(a.Housing_Price_Max/1000000,a.Housing_Price_Min/1000000),1)) as Price_Carousel
    , if(a.Housing_Area_Min is not null and a.Housing_Area_max is not null
                , if(format(a.Housing_Area_min,0)=format(a.Housing_Area_max,0)
                    , format(a.Housing_Area_min,0)
                    , concat(format(a.Housing_Area_min,0),' - ',format(a.Housing_Area_max,0)))
                , format(ifnull(a.Housing_Area_max,a.Housing_Area_min),0)) as Housing_Area_Carousel
    , if(a.Housing_Usable_Area_Min is not null and a.Housing_Usable_Area_Max is not null
                , if(format(a.Housing_Usable_Area_Min,0)=format(a.Housing_Usable_Area_Max,0)
                    , format(a.Housing_Usable_Area_Min,0)
                    , concat(format(a.Housing_Usable_Area_Min,0),' - ',format(a.Housing_Usable_Area_Max,0)))
                , format(ifnull(a.Housing_Usable_Area_Max,a.Housing_Usable_Area_Min),0)) as Usable_Area_Carousel
    , housing_line.Housing_Around_Line as Housing_Around_Line
from housing a 
left join housing_factsheet_view b on a.Housing_Code = b.Housing_Code
left join (select housing_around_station.Housing_Code AS Housing_Code,
                group_concat(
                    '[',
                    housing_around_station.Station_Code,
                    ']' separator ''
                ) AS Housing_around_station
            from
                housing_around_station
            group by
                housing_around_station.Housing_Code) station 
on a.Housing_Code = station.Housing_Code
left join (select housing_around_express_way.Housing_Code AS Housing_Code,
                group_concat(
                    '[',
                    housing_around_express_way.Place_ID,
                    ']' separator ''
                ) AS Housing_around_express_way
            from
                housing_around_express_way
            group by
                housing_around_express_way.Housing_Code) express_way 
on a.Housing_Code = express_way.Housing_Code
left join ( select Housing_Code
                , group_concat('[',Line_Code,']' separator '') AS `Housing_Around_Line`
            from ( SELECT Housing_Code
                        , Line_Code
                    FROM `housing_around_station`
                    group by Housing_Code,Line_Code) h_line
            group by Housing_Code) housing_line
on b.Housing_Code = housing_line.Housing_Code
where a.Housing_Status = '1';

-- table housing_fetch_for_map
CREATE TABLE IF NOT EXISTS housing_fetch_for_map (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_ID INT UNSIGNED NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_ENName VARCHAR(250) NULL,
    Housing_Type VARCHAR(70) NOT NULL,
    Price VARCHAR(30) NOT NULL,
    Housing_Area VARCHAR(30) NOT NULL,
    Usable_Area VARCHAR(30) NOT NULL,
    Housing_Build_Date DATE NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(250) NULL,
    Housing_ScopeArea TEXT NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    Brand_Code VARCHAR(10) NULL,
    Developer_Code VARCHAR(30) NULL,
    RealSubDistrict_Code VARCHAR(30) NULL,
    RealDistrict_Code VARCHAR(30) NULL,
    SubDistrict_ID INT NULL,
    District_ID INT NULL,
    Province_ID INT NULL,
    Housing_URL_Tag VARCHAR(200) NULL,
    Housing_Cover BOOLEAN NOT NULL DEFAULT 0,
    Express_Way Text NULL,
    Station Text NULL,
    Total_Point DOUBLE NOT NULL DEFAULT 0,
    Housing_Age INT NULL,
    Housing_Area_Min FLOAT NULL,
    Housing_Area_Max FLOAT NULL,
    Usable_Area_Min FLOAT NULL,
    Usable_Area_Max FLOAT NULL,
    Price_Min INT NULL,
    Price_Max INT NULL,
    Price_Carousel VARCHAR(30) NULL,
    Housing_Area_Carousel VARCHAR(30) NULL,
    Usable_Area_Carousel VARCHAR(30) NULL,
    Housing_Around_Line TEXT NULL,
    Spotlight_List TEXT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- procedure truncateInsert_housing_fetch_for_map
DROP PROCEDURE IF EXISTS truncateInsert_housing_fetch_for_map;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_fetch_for_map ()
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
	DECLARE v_name10 TEXT DEFAULT NULL;
	DECLARE v_name11 DOUBLE DEFAULT NULL;
	DECLARE v_name12 DOUBLE DEFAULT NULL;
	DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name22 TEXT DEFAULT NULL;
	DECLARE v_name23 TEXT DEFAULT NULL;
	DECLARE v_name24 DOUBLE DEFAULT NULL;
    DECLARE v_name25 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name26 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name27 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name28 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name29 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name30 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name31 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name32 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name33 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name34 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name35 TEXT DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_fetch_for_map';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_ID, Housing_Code, Housing_ENName, Housing_Type, Price, Housing_Area, Usable_Area
                                , Housing_Build_Date, Housing_Name_Search, Housing_ENName_Search, Housing_ScopeArea, Housing_Latitude
                                , Housing_Longitude, Brand_Code, Developer_Code, RealSubDistrict_Code, RealDistrict_Code, SubDistrict_ID
                                , District_ID, Province_ID, Housing_URL_Tag, Housing_Cover, Express_Way, Station, Total_Point, Housing_Age
                                , Housing_Area_Min, Housing_Area_Max, Usable_Area_Min, Usable_Area_Max, Price_Min, Price_Max, Price_Carousel
                                , Housing_Area_Carousel, Usable_Area_Carousel, Housing_Around_Line
                            FROM source_housing_fetch_for_map;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name1);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    housing_fetch_for_map;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			housing_fetch_for_map(
				Housing_ID
                , Housing_Code
                , Housing_ENName
                , Housing_Type
                , Price
                , Housing_Area
                , Usable_Area
                , Housing_Build_Date
                , Housing_Name_Search
                , Housing_ENName_Search
                , Housing_ScopeArea
                , Housing_Latitude
                , Housing_Longitude
                , Brand_Code
                , Developer_Code
                , RealSubDistrict_Code
                , RealDistrict_Code
                , SubDistrict_ID
                , District_ID
                , Province_ID
                , Housing_URL_Tag
                , Housing_Cover
                , Express_Way
                , Station
                , Total_Point
                , Housing_Age
                , Housing_Area_Min
                , Housing_Area_Max
                , Usable_Area_Min
                , Usable_Area_Max
                , Price_Min
                , Price_Max
                , Price_Carousel
                , Housing_Area_Carousel
                , Usable_Area_Carousel
                , Housing_Around_Line
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35);
        
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

-- view source_article_housing_fetch_for_map
create or replace view source_article_housing_fetch_for_map as
SELECT
    `b`.`Housing_ID` AS `Housing_ID`,
    `b`.`Housing_Code` AS `Housing_Code`,
    `b`.`Housing_ENName` AS `Housing_ENName`,
    `b`.`Housing_Name_Search` AS `Housing_Name_Search`,
    `b`.`Housing_ENName_Search` AS `Housing_ENName_Search`,
    `b`.`Housing_Latitude` AS `Housing_Latitude`,
    `b`.`Housing_Longitude` AS `Housing_Longitude`,
    `c`.`ID` AS `ID`,
    `c`.`post_date` AS `post_date`,
    `c`.`post_name` AS `post_name`,
    `c`.`post_title` AS `post_title`,
    `b`.`RealDistrict_Code` AS `RealDistrict_Code`,
    `b`.`RealSubDistrict_Code` AS `RealSubdistrict_Code`,
    `b`.`Province_ID` AS `Province_ID`
FROM
    (
        (
            `wp_postmeta` `a`
            join `housing_fetch_for_map` `b` on((upper(`a`.`meta_value`) = `b`.`Housing_Code`))
        )
        join `wp_posts` `c` on((`a`.`post_id` = `c`.`ID`))
    )
WHERE
    (
        (`a`.`meta_key` = 'aaa_housing')
        AND (`c`.`post_status` = 'publish')
        AND (`c`.`post_password` = '')
    );

-- table housing_article_fetch_for_map
CREATE TABLE IF NOT EXISTS housing_article_fetch_for_map (
    ID_Prime INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_ID INT UNSIGNED NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_ENName VARCHAR(250) NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(250) NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    ID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    post_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    post_name VARCHAR(200) NOT NULL,
    post_title MEDIUMTEXT NOT NULL,
    RealDistrict_Code VARCHAR(30) NULL,
    RealSubDistrict_Code VARCHAR(30) NULL,
    Province_ID INT NULL,
    PRIMARY KEY (ID_Prime))
ENGINE = InnoDB;

-- procedure truncateInsert_housing_article_fetch_for_map
DROP PROCEDURE IF EXISTS truncateInsert_housing_article_fetch_for_map;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_article_fetch_for_map ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name6 DOUBLE DEFAULT NULL;
	DECLARE v_name7 DOUBLE DEFAULT NULL;
	DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name13 VARCHAR(250) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_article_fetch_for_map';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_ID, Housing_Code, Housing_ENName, Housing_Name_Search, Housing_ENName_Search
                                , Housing_Latitude, Housing_Longitude, ID, post_date, post_name, post_title, RealDistrict_Code
                                , RealSubDistrict_Code, Province_ID
                            FROM source_article_housing_fetch_for_map;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name7);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    housing_article_fetch_for_map;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			housing_article_fetch_for_map(
				Housing_ID
                , Housing_Code
                , Housing_ENName
                , Housing_Name_Search
                , Housing_ENName_Search
                , Housing_Latitude
                , Housing_Longitude
                , ID
                , post_date
                , post_name
                , post_title
                , RealDistrict_Code
                , RealSubDistrict_Code
                , Province_ID
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13);
        
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

-- truncateInsertHousingViewToTable
DROP PROCEDURE IF EXISTS truncateInsertHousingViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertHousingViewToTable ()
BEGIN

	CALL truncateInsert_housing_around_station();
    CALL truncateInsert_housing_around_express_way();
    CALL truncateInsert_housing_factsheet_view();
    CALL truncateInsert_housing_fetch_for_map();
    CALL truncateInsert_housing_article_fetch_for_map();

END$$
DELIMITER ;