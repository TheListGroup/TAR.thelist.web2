-- source_full_template_element_image_view
-- housing_full_template_element_image_view
-- truncateInsert_housing_full_template_element_image_view

-- source_full_template_element_image_view
	-- รูปทุกรูปในทุก section ทุก element
CREATE OR REPLACE VIEW source_housing_full_template_element_image_view AS 
select
    fte.Housing_Code AS Housing_Code,
    fts.Section_ID AS Section_ID,
    fts.Section_Name AS Section,
    fts.Section_Status AS Section_Status,
    fte.Element_ID AS Element_ID,
    fte.Element_Name AS Element,
    ftc.Category_Show_Faci as Category_Show_Faci,
    if(fts.Section_ID=2,fte.Housing_Type_ID,null) as Housing_Type_ID,
	fte.Long_Text AS Long_Text,
    fte.Display_Order_in_Section AS Display_Order_in_Section,
    fte.Element_Status AS Element_Status,
    ftc.Category_ID AS Category_ID,
    ftc.Category_Name AS Category,
    ftc.Category_Status AS Category_Status,
    JSON_ARRAYAGG(JSON_OBJECT('Image_ID', fti.Image_ID, 'Image_Caption', fti.Image_Caption, 'Image_URL',fti.Image_URL ,'Date_Taken',fti.Date_Taken, 'Display_Order_in_Element', fti.Display_Order_in_Element, 'Element_ID',fti.Element_ID, 'Image_Type_ID',fti.Image_Type_ID)) AS Image,
    h360.Project_360_Name,
    h360.Project_360_Link
from housing_full_template_element as fte
inner join housing_full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
inner join housing_full_template_section as fts on ftc.Section_ID = fts.Section_ID
inner join housing_full_template_image as fti on fte.Element_ID = fti.Element_ID
left join housing_full_template_housing_type fht on fte.Housing_Type_ID = fht.Housing_Type_ID
left join ( select fte.Element_ID
                    , ft360.ID
                    , ft360.Project_360_Name
                    , ft360.Project_360_Link
            from housing_full_template_360 ft360
            left join housing_full_template_element fte on ft360.Housing_Code = fte.Housing_Code
            left join housing_full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
            left join housing_full_template_section as fts on ftc.Section_ID = fts.Section_ID
            left join housing_full_template_image as fti on fte.Element_ID = fti.Element_ID
            where ft360.Project_360_Status = 1
            and ft360.Housing_Code is not null
            and fte.Element_Status = 1
            and ftc.Category_Status = 1
            and fts.Section_Status = 1
            and fts.Section_ID = 1
            and fti.Image_Status = 1
            order by fte.Element_ID
            limit 1) h360
on fte.Element_ID = h360.Element_ID
where fte.Element_Status = 1
and ftc.Category_Status = 1
and fts.Section_Status = 1
and fti.Image_Status = 1
group by fte.Housing_Code,fts.Section_ID,fte.Element_ID,ftc.Category_ID,h360.ID
ORDER BY fte.Housing_Code,fts.Section_ID,fte.Display_Order_in_Section,fht.Housing_Category,(ifnull(fht.Housing_Area_Min,0)+ifnull(fht.Housing_Area_Max,0)) desc,ftc.Category_Order;


-- -----------------------------------------------------
-- Table `housing_full_template_element_image_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_element_image_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Section_ID` SMALLINT UNSIGNED NOT NULL,
    `Section` VARCHAR(50) NOT NULL,
    `Section_Status` SMALLINT UNSIGNED NOT NULL,
    `Element_ID` INT UNSIGNED NOT NULL,
    `Element` VARCHAR(100) NOT NULL,
    `Category_Show_Faci` SMALLINT UNSIGNED NULL,
    `Housing_Type_ID` INT UNSIGNED NULL,
    `Long_Text` Text NULL,
    `Display_Order_in_Section` SMALLINT UNSIGNED NOT NULL,
    `Element_Status` SMALLINT UNSIGNED NOT NULL,
    `Category_ID` SMALLINT UNSIGNED NULL,
    `Category` VARCHAR(100) NULL,
    `Category_Status` SMALLINT UNSIGNED NOT NULL,
    `Image` JSON NOT NULL,
    `Project_360_Name` Text NULL,
    `Project_360_Link` Text NULL,
    PRIMARY KEY (ID),
    INDEX element_house_code (Housing_Code),
    INDEX element_section (Section_ID),
    INDEX element_id (Element_ID),
    INDEX element_faci (Category_Show_Faci),
    INDEX element_housetype (Housing_Type_ID),
    INDEX element_cate (Category_ID))
ENGINE = InnoDB;


-- truncateInsert_housing_full_template_element_image_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_full_template_element_image_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_full_template_element_image_view ()
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
    DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name14 JSON DEFAULT NULL;
    DECLARE v_name15 TEXT DEFAULT NULL;
    DECLARE v_name16 TEXT DEFAULT NULL;

    DECLARE proc_name       VARCHAR(80) DEFAULT 'truncateInsert_housing_full_template_element_image_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Section_ID, Section, Section_Status, Element_ID, Element, Category_Show_Faci, Housing_Type_ID, Long_Text
                                , Display_Order_in_Section, Element_Status, Category_ID, Category, Category_Status, Image, Project_360_Name
                                , Project_360_Link
                            FROM source_housing_full_template_element_image_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE  housing_full_template_element_image_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_full_template_element_image_view(
                `Housing_Code`,
                `Section_ID`,
                `Section`,
                `Section_Status`,
                `Element_ID`,
                `Element`,
                `Category_Show_Faci`,
                `Housing_Type_ID`,
                `Long_Text`,
                `Display_Order_in_Section`,
                `Element_Status`,
                `Category_ID`,
                `Category`,
                `Category_Status`,
                `Image`,
                `Project_360_Name`,
                `Project_360_Link`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16);
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