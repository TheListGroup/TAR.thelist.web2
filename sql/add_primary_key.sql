-- ads_cal_slot_show
-- ads_cal_today
-- ads_cal_today_2
-- article_condo_fetch_for_map
-- condo_price_calculate_view
-- full_template_credit_view
-- truncateInsert_full_template_credit_view
-- full_template_element_image_view
-- full_template_facilities_gallery_fullscreen_view
-- truncateInsert_full_template_facilities_gallery_fullscreen_view
-- full_template_facilities_icon_view
-- truncateInsert_full_template_facilities_icon_view
-- full_template_floor_plan_fullscreen_view
-- truncateInsert_full_template_floor_plan_fullscreen_view
-- full_template_section_shortcut_view
-- truncateInsert_full_template_section_shortcut_view
-- full_template_unit_gallery_fullscreen_view
-- truncateInsert_full_template_unit_gallery_fullscreen_view
-- full_template_unit_plan_facilities_image_raw
-- full_template_unit_plan_fullscreen_view
-- full_template_unit_plan_gallery_raw
-- full_template_unit_plan_image_raw
-- mass_transit_station_match_route

-- ads_cal_slot_show
ALTER TABLE `ads_cal_slot_show` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Day_20`
, ADD PRIMARY KEY (`ID`);

-- ads_cal_today
ALTER TABLE `ads_cal_today` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `temp_rank`
, ADD PRIMARY KEY (`ID`);

-- ads_cal_today_2
ALTER TABLE `ads_cal_today_2` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `temp_rank`
, ADD PRIMARY KEY (`ID`);

-- article_condo_fetch_for_map
ALTER TABLE `article_condo_fetch_for_map` 
ADD `ID_Prime` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Province_ID`
, ADD PRIMARY KEY (`ID_Prime`);

-- condo_price_calculate_view
ALTER TABLE `condo_price_calculate_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Condo_Price_Per_Unit_New`
, ADD PRIMARY KEY (`ID`);

-- full_template_credit_view
ALTER TABLE `full_template_credit_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Credit_Order`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_credit_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_credit_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_credit_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 TEXT DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_full_template_credit_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Credit_ID, Credit, Credit_url_ID, Credit_URL, Credit_Logo, Credit_Order 
                            FROM source_full_template_credit_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_credit_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_credit_view(
                `Condo_Code`,
                `Credit_ID`,
                `Credit`,
                `Credit_url_ID`,
                `Credit_URL`,
                `Credit_Logo`,
                `Credit_Order`
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

-- full_template_element_image_view
ALTER TABLE `full_template_element_image_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Image`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_element_image_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_element_image_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_element_image_view ()
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
    DECLARE v_name8 JSON DEFAULT NULL;
    DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name11 TEXT DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name17 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_full_template_element_image_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Section_ID, Section, Section_Status, Set_ID, Set_Name, Set_Order, Set_Status, Unit_Type
                                , Element_ID, Element, Long_Text, Display_Order_in_Section, Element_Status, Category_ID, Category
                                , Category_Status, Image
                            FROM source_full_template_element_image_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_element_image_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_element_image_view(
                `Condo_Code`,
                `Section_ID`,
                `Section`,
                `Section_Status`,
                `Set_ID`,
                `Set_Name`,
                `Set_Order`,
                `Set_Status`,
                `Unit_Type`,
                `Element_ID`,
                `Element`,
                `Long_Text`,
                `Display_Order_in_Section`,
                `Element_Status`,
                `Category_ID`,
                `Category`,
                `Category_Status`,
                `Image`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17);
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

-- full_template_facilities_gallery_fullscreen_view
ALTER TABLE `full_template_facilities_gallery_fullscreen_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Facilities_Gallery`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_facilities_gallery_fullscreen_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_facilities_gallery_fullscreen_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_facilities_gallery_fullscreen_view ()
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
    DECLARE v_name7 TEXT DEFAULT NULL;
    DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name9 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_facilities_gallery_fullscreen_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Floor_Plan_ID, Master_Plan, Floor_Plan_Name, Building_ID, Building_Name, Building_Text
                                , Floor_Plan_Text, Floor_Plan_Section_Text, Facilities_Gallery
                            FROM source_full_template_facilities_gallery_fullscreen_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name1);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_facilities_gallery_fullscreen_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_facilities_gallery_fullscreen_view(
                `Condo_Code`,
                `Floor_Plan_ID`,
                `Master_Plan`,
                `Floor_Plan_Name`,
                `Building_ID`,
                `Building_Name`,
                `Building_Text`,
                `Floor_Plan_Text`,
                `Floor_Plan_Section_Text`,
                `Facilities_Gallery`
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

-- full_template_facilities_icon_view
ALTER TABLE `full_template_facilities_icon_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Category_Text`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_facilities_icon_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_facilities_icon_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_facilities_icon_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 TEXT DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_full_template_facilities_icon_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Category_Order, Category_ID, Category_Name, Category_Icon, Image_URL, Category_Text 
                            FROM source_full_template_facilities_icon_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_facilities_icon_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_facilities_icon_view(
                `Condo_Code`,
                `Category_Order`,
                `Category_ID`,
                `Category_Name`,
                `Category_Icon`,
                `Image_URL`,
                `Category_Text`
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

-- full_template_floor_plan_fullscreen_view
ALTER TABLE `full_template_floor_plan_fullscreen_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Facilities_Gallery_Status`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_floor_plan_fullscreen_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_floor_plan_fullscreen_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_floor_plan_fullscreen_view ()
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
    DECLARE v_name8 TEXT DEFAULT NULL;
    DECLARE v_name9 JSON DEFAULT NULL;
    DECLARE v_name10 JSON DEFAULT NULL;
    DECLARE v_name11 TEXT DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_floor_plan_fullscreen_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Floor_Plan_ID, Master_Plan, Floor_Plan_Name, Building_ID, Building_Name, Building_Text
                                , Floor_Plan_Text, Floor_Plan_Image, Unit_Type, Vector, Facilities_Cover, Facilities_Gallery_Status
                            FROM source_full_template_floor_plan_fullscreen_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name1);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_floor_plan_fullscreen_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_floor_plan_fullscreen_view(
                `Condo_Code`,
                `Floor_Plan_ID`,
                `Master_Plan`,
                `Floor_Plan_Name`,
                `Building_ID`,
                `Building_Name`,
                `Building_Text`,
                `Floor_Plan_Text`,
                `Floor_Plan_Image`,
                `Unit_Type`,
                `Vector`, 
                `Facilities_Cover`,
                `Facilities_Gallery_Status`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12);
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

-- full_template_section_shortcut_view
ALTER TABLE `full_template_section_shortcut_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Status`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_section_shortcut_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_section_shortcut_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_section_shortcut_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 TEXT DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 TEXT DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 TEXT DEFAULT NULL;
    DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name8 TEXT DEFAULT NULL;
    DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name10 TEXT DEFAULT NULL;
    DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name12 TEXT DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_full_template_section_shortcut_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Section_1_shortcut_Name, Overview_Image, Section_2_shortcut_Name, Exterior_Image
                                , Section_3_shortcut_Name, Show_Unit_Image, Section_4_shortcut_Name, Spec_Image, Section_5_shortcut_Name
                                , Facilities_Image, Section_Article_shortcut_Name, Article_Image, Status
                            FROM source_full_template_section_shortcut_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_section_shortcut_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_section_shortcut_view(
                `Condo_Code`,
                `Section_1_shortcut_Name`,
                `Overview_Image`,
                `Section_2_shortcut_Name`,
                `Exterior_Image`,
                `Section_3_shortcut_Name`,
                `Show_Unit_Image`,
                `Section_4_shortcut_Name`,
                `Spec_Image`,
                `Section_5_shortcut_Name`,
                `Facilities_Image`,
                `Section_Article_shortcut_Name`,
                `Article_Image`,
                `Status`
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

-- full_template_unit_gallery_fullscreen_view
ALTER TABLE `full_template_unit_gallery_fullscreen_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Gallery`
, ADD PRIMARY KEY (`ID`);

-- truncateInsert_full_template_unit_gallery_fullscreen_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_gallery_fullscreen_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_gallery_fullscreen_view ()
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
    DECLARE v_name7 TEXT DEFAULT NULL;
    DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name9 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_gallery_fullscreen_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Unit_Type_ID, Unit_Type_Text_Section, sizes, Unit_Type_Name, Room_Type, Size, size_name
                                , Unit_Plan_Room_Type, Gallery 
                            FROM source_full_template_unit_gallery_fullscreen_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name1);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_unit_gallery_fullscreen_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_unit_gallery_fullscreen_view(
                `Condo_Code`,
                `Unit_Type_ID`,
                `Unit_Type_Text_Section`,
                `sizes`,
                `Unit_Type_Name`,
                `Room_Type`,
                `Size`,
                `size_name`,
                `Unit_Plan_Room_Type`,
                `Gallery`
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

-- full_template_unit_plan_facilities_image_raw
ALTER TABLE `full_template_unit_plan_facilities_image_raw` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `myRowNum`
, ADD PRIMARY KEY (`ID`);

-- full_template_unit_plan_fullscreen_view
ALTER TABLE `full_template_unit_plan_fullscreen_view` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Gallery_Status`
, ADD PRIMARY KEY (`ID`);

-- full_template_unit_plan_gallery_raw
ALTER TABLE `full_template_unit_plan_gallery_raw` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `myRowNum`
, ADD PRIMARY KEY (`ID`);

-- full_template_unit_plan_image_raw
ALTER TABLE `full_template_unit_plan_image_raw` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Facilities_Gallery`
, ADD PRIMARY KEY (`ID`);

-- mass_transit_station_match_route
ALTER TABLE `mass_transit_station_match_route` 
ADD `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT AFTER `Total_Point`
, ADD PRIMARY KEY (`ID`);