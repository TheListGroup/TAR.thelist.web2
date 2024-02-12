/*CREATE TABLE `realist_log` (
    `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `Type` int DEFAULT NULL,
    `SQL_State` varchar(10) NULL DEFAULT NULL,
    `Message` text NULL DEFAULT NULL,
    `Location` varchar(50) NULL DEFAULT NULL,
    `Created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`)) ENGINE=InnoDB;*/

-- -----------------------------------------------------
-- Table `article_condo_fetch_for_map`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `article_condo_fetch_for_map` (
    `Condo_ID` INT NOT NULL,
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Condo_ENName` VARCHAR(150) NULL,
    `Condo_Name_Search` VARCHAR(250) NULL,
    `Condo_ENName_Search` VARCHAR(150) NULL,
    `Condo_Latitude` DOUBLE NULL,
    `Condo_Longitude` DOUBLE NULL,
    `ID` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `post_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `post_name` VARCHAR(200) NOT NULL,
    `post_title` MEDIUMTEXT NOT NULL,
    `RealDistrict_Code` VARCHAR(30) NULL,
    `RealSubdistrict_Code` VARCHAR(30) NULL,
    `Province_ID` INT NULL)
ENGINE = InnoDB;

-- truncateInsert_article_condo_fetch_for_map
DROP PROCEDURE IF EXISTS truncateInsert_article_condo_fetch_for_map;
DELIMITER //

CREATE PROCEDURE truncateInsert_article_condo_fetch_for_map ()
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
    DECLARE v_name10 mediumtext DEFAULT NULL;
    DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_article_condo_fetch_for_map';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT * FROM source_article_condo_fetch_for_map;
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

    TRUNCATE TABLE    article_condo_fetch_for_map;

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
            article_condo_fetch_for_map(
                `Condo_ID`,
                `Condo_Code`,
                `Condo_ENName`,
                `Condo_Name_Search`,
                `Condo_ENName_Search`,
                `Condo_Latitude`,
                `Condo_Longitude`,
                `ID`,
                `post_date`,
                `post_name`,
                `post_title`,
                `RealDistrict_Code`,
                `RealSubdistrict_Code`,
                `Province_ID`
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