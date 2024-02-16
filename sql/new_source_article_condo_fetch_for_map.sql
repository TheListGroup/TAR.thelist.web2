CREATE or replace VIEW `source_article_condo_fetch_for_map` AS
SELECT
    `b`.`Condo_ID` AS `Condo_ID`,
    `b`.`Condo_Code` AS `Condo_Code`,
    `b`.`Condo_ENName` AS `Condo_ENName`,
    `b`.`Condo_Name_Search` AS `Condo_Name_Search`,
    `b`.`Condo_ENName_Search` AS `Condo_ENName_Search`,
    `b`.`Condo_Latitude` AS `Condo_Latitude`,
    `b`.`Condo_Longitude` AS `Condo_Longitude`,
    `c`.`ID` AS `ID`,
    `c`.`post_date` AS `post_date`,
    `c`.`post_name` AS `post_name`,
    `c`.`post_title` AS `post_title`,
    `b`.`RealDistrict_Code` AS `RealDistrict_Code`,
    `b`.`RealSubDistrict_Code` AS `RealSubdistrict_Code`,
    `b`.`Province_ID` AS `Province_ID`,
    b.Brand_Code as Brand_Code,
    b.Developer_Code as Developer_Code,
    b.SubDistrict_ID as SubDistrict_ID,
    b.District_ID as District_ID,
    b.Total_Point as Total_Point,
    b.Condo_Around_Station as Condo_Around_Station,
    b.Condo_Bedroom_Type as Condo_Bedroom_Type,
    b.Condo_Room_Size as Condo_Room_Size,
    b.Spotlight_List as Spotlight_List,
    b.Condo_Age as Condo_Age,
    b.Realist_Score as Realist_Score,
    b.Condo_HighRise as Condo_HighRise,
    b.Condo_Segment as Condo_Segment,
    b.Condo_Around_Line as Condo_Around_Line
FROM `condo_fetch_for_map` `b`
left join `wp_postmeta` `a` on `b`.`Condo_Code` = upper(`a`.`meta_value`)
left join `wp_posts` `c` on `a`.`post_id` = `c`.`ID`
WHERE `a`.`meta_key` = 'aaa_condo'
AND `c`.`post_status` = 'publish'
AND `c`.`post_password` = '';

ALTER TABLE `article_condo_fetch_for_map`
ADD `Brand_Code` VARCHAR(10) NULL AFTER `ID_Prime`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Developer_Code` VARCHAR(30) NULL AFTER `Brand_Code`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `SubDistrict_ID` INT NULL AFTER `Developer_Code`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `District_ID` INT NULL AFTER `SubDistrict_ID`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Total_Point` DOUBLE NOT NULL DEFAULT 0 AFTER `District_ID`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_Around_Station` TEXT NULL AFTER `Total_Point`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_Bedroom_Type` TEXT NULL AFTER `Condo_Around_Station`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_Room_Size` TEXT NULL AFTER `Condo_Bedroom_Type`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Spotlight_List` TEXT NULL AFTER `Condo_Room_Size`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_Age` INT NULL AFTER `Spotlight_List`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Realist_Score` FLOAT NULL AFTER `Condo_Age`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_HighRise` SMALLINT UNSIGNED NULL AFTER `Realist_Score`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_Segment` VARCHAR(10) NULL AFTER `Condo_HighRise`;
ALTER TABLE `article_condo_fetch_for_map`
ADD `Condo_Around_Line` TEXT NULL AFTER `Condo_Segment`;


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
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name19 TEXT DEFAULT NULL;
    DECLARE v_name20 TEXT DEFAULT NULL;
    DECLARE v_name21 TEXT DEFAULT NULL;
    DECLARE v_name22 TEXT DEFAULT NULL;
    DECLARE v_name23 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name24 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name25 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name26 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name27 TEXT DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_article_condo_fetch_for_map';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_ID,Condo_Code,Condo_ENName,Condo_Name_Search,Condo_ENName_Search
                                , Condo_Latitude,Condo_Longitude,ID,post_date,post_name,post_title,RealDistrict_Code
                                , RealSubDistrict_Code,Province_ID,Brand_Code,Developer_Code,SubDistrict_ID,District_ID
                                , Total_Point,Condo_Around_Station,Condo_Bedroom_Type,Condo_Room_Size,Spotlight_List
                                , Condo_Age,Realist_Score,Condo_HighRise,Condo_Segment,Condo_Around_Line 
                            FROM source_article_condo_fetch_for_map;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE article_condo_fetch_for_map;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27;

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
                `Province_ID`,
                `Brand_Code`,
                `Developer_Code`,
                `SubDistrict_ID`,
                `District_ID`,
                `Total_Point`,
                `Condo_Around_Station`,
                `Condo_Bedroom_Type`,
                `Condo_Room_Size`,
                `Spotlight_List`,
                `Condo_Age`,
                `Realist_Score`,
                `Condo_HighRise`,
                `Condo_Segment`,
                `Condo_Around_Line`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27);
        
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