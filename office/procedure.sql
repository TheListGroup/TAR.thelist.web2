-- procedure truncateInsert_office_around_station
DROP PROCEDURE IF EXISTS truncateInsert_office_around_station;
DELIMITER //

CREATE PROCEDURE truncateInsert_office_around_station ()
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

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_office_around_station';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Station_Code, Station_THName_Display, Route_Code, Line_Code, MTran_ShortName, Project_ID, Distance
                            FROM source_office_around_station;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    office_around_station;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			office_around_station(
				Station_Code
                , Station_THName_Display
                , Route_Code
                , Line_Code
                , MTran_ShortName
                , Project_ID
                , Distance
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6);
        
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

-- procedure truncateInsert_office_around_express_way
DROP PROCEDURE IF EXISTS truncateInsert_office_around_express_way;
DELIMITER //

CREATE PROCEDURE truncateInsert_office_around_express_way ()
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

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_office_around_express_way';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Place_ID, Place_Type, Place_Category, Place_Name, Place_Latitude, Place_Longitude, Project_ID, Distance
                            FROM source_office_around_express_way;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    office_around_express_way;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			office_around_express_way(
				Place_ID
                , Place_Type
                , Place_Category
                , Place_Name
                , Place_Latitude
                , Place_Longitude
                , Project_ID
                , Distance
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7);
        
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


-- procedure truncateInsert_office_unit_carousel_recommend
DROP PROCEDURE IF EXISTS truncateInsert_office_unit_carousel_recommend;
DELIMITER //

CREATE PROCEDURE truncateInsert_office_unit_carousel_recommend ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5 json DEFAULT NULL;
	DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name9 json DEFAULT NULL;
	DECLARE v_name10 json DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_office_unit_carousel_recommend';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Unit_ID, Title, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Rent_Price, Rent_Price_Sqm, Rent_Price_Status, Carousel_Image
							, Carousel_Image_Random
							FROM source_office_unit_carousel_recommend;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name2);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    office_unit_carousel_recommend;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			office_unit_carousel_recommend(
				Unit_ID
                , Title
                , Project_Name
                , Project_Tag_Used
                , Project_Tag_All
                , near_by
                , Rent_Price
                , Rent_Price_Sqm
                , Rent_Price_Status
                , Carousel_Image
                , Carousel_Image_Random
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10);
        
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

-- procedure truncateInsert_office_highlight
DROP PROCEDURE IF EXISTS truncateInsert_office_highlight;
DELIMITER //

CREATE PROCEDURE truncateInsert_office_highlight()
BEGIN
    -- เปลี่ยนตามจำนวน highlight
    DECLARE total_rows INT DEFAULT 0;
    DECLARE y INT DEFAULT 0;
    DECLARE proj_id 	VARCHAR(250) DEFAULT NULL;
	DECLARE skywalk 	VARCHAR(250) DEFAULT NULL;
    DECLARE park_cal 	VARCHAR(250) DEFAULT NULL;
    DECLARE park_ratio 	VARCHAR(250) DEFAULT NULL;
    DECLARE floor_plate VARCHAR(250) DEFAULT NULL;
    DECLARE ev 			VARCHAR(250) DEFAULT NULL;
    DECLARE mall_connect VARCHAR(250) DEFAULT NULL;
    DECLARE fitness 	VARCHAR(250) DEFAULT NULL;
    DECLARE mall 		VARCHAR(250) DEFAULT NULL;
    DECLARE bank 		VARCHAR(250) DEFAULT NULL;
    DECLARE seven 		VARCHAR(250) DEFAULT NULL;
    DECLARE food 		VARCHAR(250) DEFAULT NULL;
    DECLARE cafe 		VARCHAR(250) DEFAULT NULL;
    DECLARE meeting_room VARCHAR(250) DEFAULT NULL;
    DECLARE ac 			VARCHAR(250) DEFAULT NULL;
    DECLARE highlight 	VARCHAR(250) DEFAULT NULL;
    DECLARE each_highlight VARCHAR(250) DEFAULT NULL;
    DECLARE highlights 	VARCHAR(250) DEFAULT NULL;
    DECLARE highlight_group VARCHAR(250) DEFAULT NULL;
	
    DECLARE done INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    DECLARE x INT DEFAULT 1;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_office_highlight';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE cur CURSOR FOR
	select a.Project_ID
		, 'N' as 'Skywalk'
		, building.Parking_Ratio as 'Parking'
		, if(building.Parking_Ratio >= 120, 'Y', if(building.Parking_Ratio >= 80, 'Y', 'N')) as 'Parking_Ratio'
		, if(building.Typical_Floor_Plate >= 1500, 'Y', 'N') as 'Typical_Floor_Plate'
		, if(a.F_Others_EV = 1, 'Y', 'N') as 'EV_Changers'
		, 'N' as 'Mall_Connect'
		, if(a.F_Others_Gym = 1, 'Y', 'N') as 'Fitness'
		, if(a.F_Retail_Mall_Shop = 1, 'Y', 'N') as 'Mall_Shop'
		, if((a.F_Services_ATM = 1 or a.F_Services_Bank = 1), 'Y', 'N') as 'Bank'
		, if(a.F_Retail_Conv_Store = 1, 'Y', 'N') as 'Seven'
		, if((a.F_Food_Foodcourt = 1 or a.F_Food_Restaurant = 1), 'Y', 'N') as 'Food'
		, if(a.F_Food_Cafe = 1, 'Y', 'N') as 'Cafe'
		, if(a.F_Others_Conf_Meetingroom = 1, 'Y', 'N') as 'Meeting_Room'
		,if(building.AC <> 'N', 'Y', 'N') as 'AC'
	from office_project a
	left join (select Project_ID
					, max(SUBSTRING_INDEX(Parking_Ratio, ':', -1)) as Parking_Ratio
					, greatest(ifnull(max(Typical_Floor_Plate_1),0), greatest(ifnull(max(Typical_Floor_Plate_2),0), ifnull(max(Typical_Floor_Plate_3),0))) as Typical_Floor_Plate
					, ifnull(max(ifnull(AC_OT_Weekday_by_Hour,ifnull(AC_OT_Weekday_by_Area,ifnull(AC_OT_Weekend_by_Hour,ifnull(AC_OT_Weekend_by_Area,null))))), 'N') as AC
				from office_building 
				where Building_Status = '1'
				group by Project_ID) building
	on a.Project_ID = building.Project_ID
	where a.Project_Status = '1';

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',proj_id);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    TRUNCATE TABLE office_highlight_relationship;
    OPEN cur;
	
	read_loop: LOOP
        FETCH cur INTO proj_id, skywalk, park_cal, park_ratio, floor_plate, ev, mall_connect, fitness, mall, bank, seven, food, cafe, meeting_room, ac;
        IF done THEN
            LEAVE read_loop;
        END IF;

		SET highlights = concat(skywalk, park_ratio, floor_plate, ev, mall_connect, fitness, mall, bank, seven, food, cafe, meeting_room, ac); -- เปลี่ยนตามจำนวน listing
        SET highlight_group = concat_ws(',','1','2','3','4','5','6','7','8','9','10','11','12','13'); -- เปลี่ยนตามจำนวน listing
        
		WHILE x <= 13 DO
			SET highlight = SUBSTRING(highlights, x, 1);
			IF highlight = 'Y' THEN
                SET each_highlight = SUBSTRING_INDEX(SUBSTRING_INDEX(highlight_group, ',', x), ',', -1);

				INSERT INTO office_highlight_relationship (Data_Type, Ref_ID, Highlight_ID, Extra_Text)
				VALUES ('Project', proj_id, each_highlight, IF(each_highlight = '2', IF(park_cal >= 120, 120, IF(park_cal >= 80, 80, NULL)), NULL));
			
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

-- procedure truncateInsert_office_project_carousel_recommend
DROP PROCEDURE IF EXISTS truncateInsert_office_project_carousel_recommend;
DELIMITER //

CREATE PROCEDURE truncateInsert_office_project_carousel_recommend ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 json DEFAULT NULL;
	DECLARE v_name5 json DEFAULT NULL;
	DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name7 json DEFAULT NULL;
	DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name9 json DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_office_project_carousel_recommend';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Project_ID, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Highlight, Rent_Price, Project_Image, Unit_Count
								, Project_Image_All
							FROM source_office_project_carousel_recommend;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name4);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    office_project_carousel_recommend;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			office_project_carousel_recommend(
				Project_ID
                , Project_Name
                , Project_Tag_Used
                , Project_Tag_All
                , near_by
                , Highlight
                , Rent_Price
                , Project_Image
                , Unit_Count
				, Project_Image_All
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9);
        
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