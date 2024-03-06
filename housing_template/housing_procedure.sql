-- procedure truncateInsert_housing_around_station
-- procedure truncateInsert_housing_around_express_way
-- procedure truncateInsert_housing_factsheet_view
-- procedure truncateInsert_housing_fetch_for_map
-- procedure truncateInsert_housing_article_fetch_for_map
-- procedure updateHousingCountProvince
-- procedure updateHousingCountYarnMain
-- procedure updateHousingCountYarnSub
-- procedure truncateInsertHousingViewToTable

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
    DECLARE v_name36 TEXT DEFAULT NULL;
	DECLARE v_name37 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name38 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name39 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name40 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name41 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name42 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name43 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name44 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name45 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name46 VARCHAR(250) DEFAULT NULL;

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
                                , Housing_Area_Carousel, Usable_Area_Carousel, Housing_Around_Line, Spotlight_List, TotalUnit
								, TotalRai, Common_Fee_Min, Common_Fee_Max, Bedroom_Min, Bedroom_Max, Bathroom_Min, Bathroom_Max
								, Parking_Min, Parking_Max
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
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46;
        
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
                , Spotlight_List
				, TotalUnit
				, TotalRai
				, Common_Fee_Min
				, Common_Fee_Max
				, Bedroom_Min
				, Bedroom_Max
				, Bathroom_Min
				, Bathroom_Max
				, Parking_Min
				, Parking_Max
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46);
        
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


-- procedure updateHousingCountProvince
DROP PROCEDURE IF EXISTS updateHousingCountProvince;
DELIMITER //

CREATE PROCEDURE updateHousingCountProvince ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachProvince VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateHousingCountProvince';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curProvince CURSOR FOR SELECT province_code FROM thailand_province;

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;

    OPEN curProvince;

	updateCondoCount: LOOP
		FETCH curProvince INTO eachProvince;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_province
        SET	    Housing_Count = ( SELECT  COUNT(HFRM.Housing_Code) 
                                FROM    housing_fetch_for_map HFRM
								WHERE   HFRM.Province_ID = eachProvince)
        WHERE   province_code = eachProvince;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(rowCount,' rows changed.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE curProvince;
END//
DELIMITER ;


-- procedure updateHousingCountYarnMain
DROP PROCEDURE IF EXISTS updateHousingCountYarnMain;
DELIMITER //

CREATE PROCEDURE updateHousingCountYarnMain ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachYarnMain VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateHousingCountYarnMain';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curYarnMain CURSOR FOR SELECT District_Code FROM real_yarn_main;

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curYarnMain;

	updateCondoCount: LOOP
		FETCH curYarnMain INTO eachYarnMain;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  real_yarn_main
        SET	    Condo_Count = ( SELECT  COUNT(HFRM.Housing_Code) 
                                FROM    housing_fetch_for_map HFRM
								WHERE   HFRM.RealDistrict_Code = eachYarnMain)
        WHERE   District_Code = eachYarnMain;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(rowCount,' rows changed.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curYarnMain;
END//
DELIMITER ;


-- procedure updateHousingCountYarnSub
DROP PROCEDURE IF EXISTS updateHousingCountYarnSub;
DELIMITER //

CREATE PROCEDURE updateHousingCountYarnSub ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachYarnSub VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateHousingCountYarnSub';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curYarnSub CURSOR FOR SELECT SubDistrict_Code FROM real_yarn_sub;

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curYarnSub;

	updateCondoCount: LOOP
		FETCH curYarnSub INTO eachYarnSub;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  real_yarn_sub
        SET	    Condo_Count = ( SELECT  COUNT(HFRM.Condo_Code) 
                                FROM    housing_fetch_for_map HFRM
								WHERE   HFRM.RealSubDistrict_Code = eachYarnSub)
        WHERE   SubDistrict_Code = eachYarnSub;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(rowCount,' rows changed.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curYarnSub;
END//
DELIMITER ;


-- truncateInsertHousingViewToTable
DROP PROCEDURE IF EXISTS truncateInsertHousingViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertHousingViewToTable ()
BEGIN

	CALL truncateInsert_housing_around_station();
    CALL truncateInsert_housing_around_express_way();
    CALL truncateInsert_housing_spotlight();
    CALL truncateInsert_housing_factsheet_view();
    CALL truncateInsert_housing_fetch_for_map();
    CALL truncateInsert_housing_article_fetch_for_map();

END$$
DELIMITER ;

--
DROP PROCEDURE IF EXISTS UpdateHousingCount;
DELIMITER $$

CREATE PROCEDURE UpdateHousingCount ()
BEGIN

	CALL updatehousingCountSpotlight();
	CALL updateHousingCountProvince();
	CALL updateHousingCountYarnMain();
	CALL updateHousingCountYarnSub();

END$$
DELIMITER ;

--
DROP PROCEDURE IF EXISTS HousingUpdate;
DELIMITER $$

CREATE PROCEDURE HousingUpdate ()
BEGIN

	CALL updateHousing5Point();
	CALL UpdateHousingCount();
	CALL truncateInsertHousingViewToTable();

END$$
DELIMITER ;