/*  - Table `full_template_element_image_view`
    - truncateInsert_full_template_element_image_view 
    - Table `full_template_credit_view`
    - truncateInsert_full_template_credit_view 
    - truncateInsertViewToTable
    - Table `full_template_facilities_icon_view`
    - truncateInsert_full_template_facilities_icon_view
    - Table `full_template_section_shortcut_view`
    - truncateInsert_full_template_section_shortcut_view  */

-- -----------------------------------------------------
-- Table `full_template_element_image_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_element_image_view` (
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Section_ID` SMALLINT UNSIGNED NOT NULL,
    `Section` VARCHAR(50) NOT NULL,
    `Section_Status` SMALLINT UNSIGNED NOT NULL,
    `Set_ID` INT UNSIGNED NULL DEFAULT NULL,
    `Set_Name` VARCHAR(100) NULL DEFAULT NULL,
    `Set_Order` SMALLINT UNSIGNED NULL DEFAULT NULL,
    `Set_Status` SMALLINT UNSIGNED NULL DEFAULT NULL,
    `Unit_Type` JSON NULL DEFAULT NULL,
    `Element_ID` INT UNSIGNED NOT NULL,
    `Element` VARCHAR(100) NOT NULL,
    `Long_Text` Text NULL DEFAULT NULL,
    `Display_Order_in_Section` SMALLINT UNSIGNED NOT NULL,
    `Element_Status` SMALLINT UNSIGNED NOT NULL,
    `Category_ID` SMALLINT UNSIGNED NOT NULL,
    `Category` VARCHAR(100) NOT NULL,
    `Category_Status` SMALLINT UNSIGNED NOT NULL,
    `Image` JSON NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Section_ID, Section, Section_Status, Set_ID, Set_Name, Set_Order, Set_Status, Unit_Type
                                , Element_ID, Element, Long_Text, Display_Order_in_Section, Element_Status, Category_ID, Category
                                , Category_Status, Image
                            FROM source_full_template_element_image_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_element_image_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17;
        -- more variables here as needed

        -- Check if there are no more records
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
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Table `full_template_credit_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_credit_view` (
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Credit_ID` SMALLINT UNSIGNED NOT NULL,
    `Credit` VARCHAR(50) NOT NULL,
    `Credit_url_ID` INT UNSIGNED NOT NULL,
    `Credit_URL` TEXT NOT NULL,
    `Credit_Logo` VARCHAR(250) NOT NULL,
    `Credit_Order` SMALLINT UNSIGNED NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Credit_ID, Credit, Credit_url_ID, Credit_URL, Credit_Logo, Credit_Order 
                            FROM source_full_template_credit_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_credit_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;
        -- more variables here as needed

        -- Check if there are no more records
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
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Table `full_template_facilities_icon_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_facilities_icon_view` (
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Category_Order` SMALLINT UNSIGNED NOT NULL,
    `Category_ID` SMALLINT UNSIGNED NOT NULL,
    `Category_Name` VARCHAR(100) NOT NULL,
    `Category_Icon` VARCHAR(250) NOT NULL,
    `Image_URL` VARCHAR(100) NULL,
    `Category_Text` JSON NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Category_Order, Category_ID, Category_Name, Category_Icon, Image_URL, Category_Text 
                            FROM source_full_template_facilities_icon_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_facilities_icon_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;
        -- more variables here as needed

        -- Check if there are no more records
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
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Table `full_template_section_shortcut_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_section_shortcut_view` (
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Section_1_shortcut_Name` VARCHAR(50) NULL,
    `Overview_Image` TEXT NULL,
    `Section_2_shortcut_Name` VARCHAR(50) NULL,
    `Exterior_Image` Text NULL,
    `Section_3_shortcut_Name` VARCHAR(50) NULL,
    `Show_Unit_Image` TEXT NULL,
    `Section_4_shortcut_Name` VARCHAR(50) NULL,
    `Spec_Image` TEXT NULL,
    `Section_5_shortcut_Name` VARCHAR(50) NULL,
    `Facilities_Image` Text NULL,
    `Section_Article_shortcut_Name` VARCHAR(50) NULL,
    `Article_Image` TEXT NULL,
    `Status` SMALLINT UNSIGNED NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Section_1_shortcut_Name, Overview_Image, Section_2_shortcut_Name, Exterior_Image
                                , Section_3_shortcut_Name, Show_Unit_Image, Section_4_shortcut_Name, Spec_Image, Section_5_shortcut_Name
                                , Facilities_Image, Section_Article_shortcut_Name, Article_Image, Status
                            FROM source_full_template_section_shortcut_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_section_shortcut_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13;
        -- more variables here as needed

        -- Check if there are no more records
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
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;

-- truncateInsertViewToTable
DROP PROCEDURE IF EXISTS truncateInsertViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertViewToTable ()
BEGIN

	CALL truncateInsert_condo_price_calculate_view ();
	CALL truncateInsert_condo_fetch_for_map ();
	CALL truncateInsert_condo_spotlight_relationship_view ();
	CALL truncateInsert_mass_transit_station_match_route ();
    CALL truncateInsert_full_template_factsheet ();
    CALL truncateInsert_full_template_element_image_view ();
    CALL truncateInsert_full_template_credit_view ();
    CALL truncateInsert_full_template_facilities_icon_view ();
    CALL truncateInsert_full_template_section_shortcut_view ();

END$$
DELIMITER ;