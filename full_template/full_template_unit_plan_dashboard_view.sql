/*  - rename Room_Type_Name
    - function
        - function format Size
        - function ใส่หน่วยไทย
        - function ใส่หน่วยอิง
        - function format
    - full_template_unit_plan_floor_plan_raw_view
        - table full_template_unit_plan_floor_plan_raw
        - truncateInsert_full_template_unit_plan_floor_plan_raw
    - full_template_unit_plan_gallery_raw_view
    - full_template_unit_plan_facilities_image_raw_view
    - full_template_unit_plan_image_raw_view
    - source_full_template_unit_plan_dashboard_view
    - Table `full_template_unit_plan_dashboard_view`
    - truncateInsert_full_template_unit_plan_dashboard_view */

-- rename Room_Type_Name
UPDATE `full_template_room_type` 
SET `Room_Type_Name` = 'Studio' 
WHERE `full_template_room_type`.`Room_Type_ID` = 1;

UPDATE `full_template_room_type` 
SET `Room_Type_Name` = '1 Bedroom' 
WHERE `full_template_room_type`.`Room_Type_ID` = 2;

UPDATE `full_template_room_type` 
SET `Room_Type_Name` = '2 Bedroom' 
WHERE `full_template_room_type`.`Room_Type_ID` = 4;

UPDATE `full_template_room_type` 
SET `Room_Type_Name` = '3 Bedroom' 
WHERE `full_template_room_type`.`Room_Type_ID` = 5;

UPDATE `full_template_room_type` 
SET `Room_Type_Name` = '4 Bedroom' 
WHERE `full_template_room_type`.`Room_Type_ID` = 6;

-- create function format Size
DELIMITER //
CREATE FUNCTION roundSize(size FLOAT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE columnSize VARCHAR(10);
    CASE
        WHEN size % 1 = 0 THEN SET columnSize = FORMAT(size, 0);
        WHEN (CAST(size AS DECIMAL(10,2))*10) % 1 = 0 THEN SET columnSize = FORMAT(size, 1);
        ELSE SET columnSize = FORMAT(size, 2);
    END CASE;
    RETURN columnSize;
END //
DELIMITER ;

-- function ใส่หน่วยไทย
DELIMITER //
CREATE FUNCTION unitsqm(letter VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(100);
    SET unit = CONCAT(letter, ' ตร.ม.');
    RETURN unit;
END //
DELIMITER ;

-- function ใส่หน่วยอิง
DELIMITER //
CREATE FUNCTION engunitsqm(letter VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(100);
    SET unit = CONCAT(letter, ' sq.m.');
    RETURN unit;
END //
DELIMITER ;

-- function format
DELIMITER //
CREATE FUNCTION fmat(size FLOAT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE fsize VARCHAR(10);
    SET fsize = round(cast(size as decimal(10,2)));
    RETURN fsize;
END //
DELIMITER ;

-- full_template_unit_plan_floor_plan_raw_view (รวบรวม floor_plan)
create or replace view full_template_unit_plan_floor_plan_raw_view as
select Condo_Code
    , Unit_Type_ID
    , Floor_Displayed_Name
    , Building_Name
    , Floor_Plan_ID
    , Floor_Plan_Image from (
                select U1.Condo_Code
                    ,   U1.Unit_Type_ID
                    ,   if(U5.Floor_Plan_Image is not null
                            ,U5.Floor_Displayed_Name
                            ,if(U6.Floor_Plan_Image is not null
                                ,'Master Plan'
                                ,if(U7.Floor_Plan_Image is not null,U7.Floor_Displayed_Name,null))) as Floor_Displayed_Name
                    ,   if(U5.Floor_Plan_Image is not null
                            ,U5.Building_Name
                            ,if(U6.Floor_Plan_Image is not null
                                ,null
                                ,if(U7.Floor_Plan_Image is not null,U7.Building_Name,null))) as Building_Name
                    ,   ifnull(U5.Floor_Plan_ID,ifnull(U6.Floor_Plan_ID,ifnull(U7.Floor_Plan_ID,null))) as Floor_Plan_ID
                    ,   ifnull(U5.Floor_Plan_Image,ifnull(U6.Floor_Plan_Image,ifnull(U7.Floor_Plan_Image,null))) as Floor_Plan_Image
                from full_template_unit_type U1
                -- ข้อ1 ข้อ2
                left join (SELECT all_units.Ref_ID, 
                                all_units.Floor_Displayed_Name,
                                all_units.Building_Name,
                                all_units.Floor_Plan_ID,
                                all_units.Floor_Plan_Image
                            FROM (
                            SELECT 
                                VFPR.Ref_ID, 
                                COUNT(VFPR.Vector_ID) as units_on_floor, 
                                Fl.Floor_Order, 
                                concat('Floor ',Fl.Floor_Displayed_Name) as Floor_Displayed_Name,
                                Fl.Building_ID,
                                FB.Building_Order,
                                concat('Building ',FB.Building_Name) as Building_Name,
                                VFPR.Floor_Plan_ID,
                                FP.Floor_Plan_Image,
                                ROW_NUMBER() OVER (PARTITION BY VFPR.Ref_ID ORDER BY COUNT(VFPR.Vector_ID) DESC, Fl.Floor_Order, FB.Building_Order) AS myRowNum 
                            FROM full_template_vector_floor_plan_relationship VFPR 
                            join full_template_floor Fl on Fl.Floor_Plan_ID = VFPR.Floor_Plan_ID
                            join full_template_building FB on FB.Building_ID = Fl.Building_ID
                            join full_template_floor_plan FP on VFPR.Floor_Plan_ID = FP.Floor_Plan_ID
                            WHERE VFPR.Vector_Type = 1 
                            and VFPR.Relationship_Status = 1
                            and Fl.Floor_Status = 1
                            and FB.Building_Status = 1
                            and FP.Floor_Plan_Status = 1
                            and Fl.Floor_Order > 0
                            GROUP BY VFPR.Ref_ID, VFPR.Floor_Plan_ID, Fl.Floor_Displayed_Name, Fl.Floor_Order, Fl.Building_ID, FB.Building_Order, FB.Building_Name
                            order by VFPR.Ref_ID, units_on_floor DESC, Fl.Floor_Order, Fl.Floor_Displayed_Name, Fl.Building_ID, FB.Building_Order, FB.Building_Name
                            ) AS all_units
                            WHERE myRowNum = 1) U5
                on U1.Unit_Type_ID = U5.REf_ID
                -- ข้อ3
                left join ( SELECT fp.Floor_Plan_ID
                                ,   fp.Condo_Code
                                ,   fp.Floor_Plan_Image 
                            FROM `full_template_floor_plan` fp 
                            where fp.Floor_Plan_Status = 1
                            and fp.Master_Plan = 1
                            group by fp.Floor_Plan_ID, fp.Condo_Code
                            order by fp.Floor_Plan_ID ) U6
                on U1.Condo_Code = U6.Condo_Code
                -- ข้อ4
                left join (select  typical.Condo_Code,
                                    typical.Floor_Plan_ID,
                                    concat('Floor ',typical.Floor_Displayed_Name) as Floor_Displayed_Name,
                                    concat('Building ',typical.Building_Name) as Building_Name,
                                    typical.Floor_Plan_Image
                            from (select U1.Floor_Plan_ID
                                    ,   U1.Condo_Code
                                    ,   U1.floors_on_floor_plan
                                    ,   U2.Floor_ID
                                    ,   U2.Floor_Displayed_Name
                                    ,   U2.Floor_Order
                                    ,   U2.Building_ID
                                    ,   U2.Building_Name
                                    ,   U2.Building_Order
                                    ,   U1.Floor_Plan_Image
                                    ,   ROW_NUMBER() OVER (PARTITION BY U1.Condo_Code ORDER BY U1.floors_on_floor_plan DESC, U2.Floor_Order, U2.Building_Order) AS myRowNum 
                                from (SELECT ff.Floor_Plan_ID
                                                ,   count(ff.Floor_ID) as floors_on_floor_plan 
                                                ,	fp.Condo_Code
                                                ,   fp.Floor_Plan_Image
                                            FROM full_template_floor ff
                                            left join full_template_floor_plan fp on ff.Floor_Plan_ID = fp.Floor_Plan_ID
                                            where ff.Floor_Status = 1
                                            and ff.Floor_Plan_ID is not null
                                            and fp.Floor_Plan_Status = 1
                                            and ff.Floor_Order > 0
                                            group by ff.Floor_Plan_ID
                                            order by floors_on_floor_plan desc) U1 -- หา floor_plan ที่คลุมชั้นเยอะที่สุดในโครงการ
                                left join (select ff.Floor_Plan_ID,ff.Floor_ID,ff.Floor_Displayed_Name,ff.Floor_Order,fb.Building_ID,fb.Building_Name,fb.Building_Order
                                            FROM full_template_floor ff
                                            left join full_template_building fb on ff.Building_ID = fb.Building_ID
                                            where ff.Floor_Status = 1
                                            and ff.Floor_Plan_ID is not null
                                            and fb.Building_Status = 1
                                            and ff.Floor_Order > 0
                                            order by ff.Floor_Plan_ID,ff.Floor_Order,fb.Building_Order) U2 -- เอาชื่อชั้น ชื่อตึก ลำดับชั้น ลำดับตึก
                                on U1.Floor_Plan_ID = U2.Floor_Plan_ID
                                order by U1.Condo_Code,U1.floors_on_floor_plan desc, U2.Floor_Order, U2.Building_Order) typical
                            WHERE myRowNum = 1) U7
                on U1.Condo_Code = U7.Condo_Code
                where U1.Unit_Type_Status <> 2
                order by U1.Condo_Code, U1.Unit_Type_ID) unit_floor_plan
where (Floor_Displayed_Name is not null
or Building_Name is not null
or Floor_Plan_ID is not null
or Floor_Plan_Image is not null);

-- table full_template_unit_plan_floor_plan_raw
CREATE TABLE IF NOT EXISTS `full_template_unit_plan_floor_plan_raw` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_Code` varchar(50) NOT NULL,
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Floor_Displayed_Name` varchar(20) null,
    `Building_Name` varchar(100) null,
    `Floor_Plan_ID` int UNSIGNED null,
    `Floor_Plan_Image` varchar(100) null,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- truncateInsert_full_template_unit_plan_floor_plan_raw
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_plan_floor_plan_raw;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_plan_floor_plan_raw ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_plan_floor_plan_raw';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR select Condo_Code, Unit_Type_ID, Floor_Displayed_Name, Building_Name, Floor_Plan_ID, Floor_Plan_Image
                            FROM full_template_unit_plan_floor_plan_raw_view;
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

    TRUNCATE TABLE full_template_unit_plan_floor_plan_raw;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_unit_plan_floor_plan_raw(
                Condo_Code
                , Unit_Type_ID
                , Floor_Displayed_Name
                , Building_Name
                , Floor_Plan_ID
                , Floor_Plan_Image
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5);
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

-- full_template_unit_image_view
create or replace view full_template_unit_plan_gallery_raw_view as
SELECT  fu.Unit_Type_ID
    ,   fu.Room_Type_ID
    ,   fu.Condo_Code
    ,   fsur.Set_ID
    ,   fs.Set_Name
    ,   fs.Display_Order_in_Condo
    ,   fe.Element_ID
    ,   fe.Element_Name
    ,   fe.Display_Order_in_Section
    ,   fi.Image_ID
    ,   fi.Image_Caption
    ,   fi.Image_URL
    ,   fi.Display_Order_in_Element
    ,   ROW_NUMBER() OVER (PARTITION BY fu.Unit_Type_ID ORDER BY fs.Display_Order_in_Condo, fe.Display_Order_in_Section, fi.Display_Order_in_Element) AS myRowNum 
FROM full_template_set_unit_type_relationship fsur
inner join full_template_unit_type fu on fsur.Unit_Type_ID = fu.Unit_Type_ID
inner join full_template_set fs on fsur.Set_ID = fs.Set_ID
inner join full_template_element fe on fs.Set_ID = fe.Set_ID
inner join full_template_image fi on fe.Element_ID = fi.Element_ID
where fu.Unit_Type_Status <> 2
and fsur.Relationship_Status = 1
and fs.Set_Status = 1
and fe.Element_Status = 1
and fi.Image_Status = 1
order by fu.Condo_Code,fs.Display_Order_in_Condo,fe.Display_Order_in_Section,fi.Display_Order_in_Element;

-- -----------------------------------------------------
-- Table `full_template_unit_plan_gallery_raw`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_plan_gallery_raw` (
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Room_Type_ID` SMALLINT UNSIGNED NOT NULL,
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Set_ID` INT UNSIGNED NOT NULL,
    `Set_Name` VARCHAR(100) NOT NULL,
    `Display_Order_in_Condo` SMALLINT UNSIGNED NOT NULL,
    `Element_ID` INT UNSIGNED NOT NULL,
    `Element_Name` VARCHAR(100) NOT NULL,
    `Display_Order_in_Section` SMALLINT UNSIGNED NULL,
    `Image_ID` INT UNSIGNED NOT NULL,
    `Image_Caption` VARCHAR(100) NULL,
    `Image_URL` VARCHAR(100) NOT NULL,
    `Display_Order_in_Element` SMALLINT UNSIGNED NOT NULL,
    `myRowNum` BIGINT UNSIGNED NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- truncateInsert_full_template_unit_plan_gallery_raw
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_plan_gallery_raw;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_plan_gallery_raw ()
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

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_plan_gallery_raw';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Unit_Type_ID,Room_Type_ID,Condo_Code,Set_ID,Set_Name,Display_Order_in_Condo,Element_ID,Element_Name
                                , Display_Order_in_Section,Image_ID,Image_Caption,Image_URL,Display_Order_in_Element,myRowNum 
                            FROM full_template_unit_plan_gallery_raw_view;
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

    TRUNCATE TABLE full_template_unit_plan_gallery_raw;

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
            full_template_unit_plan_gallery_raw(
                `Unit_Type_ID`,
                `Room_Type_ID`,
                `Condo_Code`,
                `Set_ID`,
                `Set_Name`,
                `Display_Order_in_Condo`,
                `Element_ID`,
                `Element_Name`,
                `Display_Order_in_Section`,
                `Image_ID`,
                `Image_Caption`,
                `Image_URL`,
                `Display_Order_in_Element`,
                `myRowNum`
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


-- full_template_unit_plan_facilities_image_raw_view
create or replace view full_template_unit_plan_facilities_image_raw_view as
select  fur.Unit_Type_ID
    ,   fur.Floor_Plan_ID
    ,   fv.Ref_ID
    ,   fe.Element_Name
    ,   fe.Display_Order_in_Section
    ,   fi.Image_ID
    ,   fi.Image_URL
    ,   fi.Image_Caption
    ,	fi.Display_Order_in_Element
    ,   ROW_NUMBER() OVER (PARTITION BY fur.Unit_Type_ID ORDER BY fe.Display_Order_in_Section
                                                                , fi.Display_Order_in_Element) AS myRowNum 
from full_template_unit_plan_floor_plan_raw fur
left join full_template_vector_floor_plan_relationship fv on fur.Floor_Plan_ID = fv.Floor_Plan_ID
left join full_template_element fe on fv.Ref_ID = fe.Element_ID
left join full_template_image fi on fe.Element_ID = fi.Element_ID
where fv.Vector_Type = 2
and fv.Relationship_Status = 1
and fe.Element_Status = 1
and fi.Image_Status = 1
order by fur.Unit_Type_ID,fe.Display_Order_in_Section,fi.Display_Order_in_Element;

-- -----------------------------------------------------
-- Table `full_template_unit_plan_facilities_image_raw`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_plan_facilities_image_raw` (
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Floor_Plan_ID` BIGINT UNSIGNED NULL,
    `Ref_ID` INT UNSIGNED NULL,
    `Element_Name` VARCHAR(100) NULL,
    `Display_Order_in_Section` SMALLINT UNSIGNED NULL,
    `Image_ID` INT UNSIGNED NOT NULL,
    `Image_URL` VARCHAR(100) NULL,
    `Image_Caption` VARCHAR(100) NULL,
    `Display_Order_in_Element` SMALLINT UNSIGNED NULL,
    `myRowNum` BIGINT UNSIGNED NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- truncateInsert_full_template_unit_plan_facilities_image_raw
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_plan_facilities_image_raw;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_plan_facilities_image_raw ()
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

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_plan_facilities_image_raw';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Unit_Type_ID,Floor_Plan_ID,Ref_ID,Element_Name,Display_Order_in_Section,Image_ID,Image_URL,Image_Caption
                                , Display_Order_in_Element,myRowNum 
                            FROM full_template_unit_plan_facilities_image_raw_view;
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

    TRUNCATE TABLE full_template_unit_plan_facilities_image_raw;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_unit_plan_facilities_image_raw(
                `Unit_Type_ID`,
                `Floor_Plan_ID`,
                `Ref_ID`,
                `Element_Name`,
                `Display_Order_in_Section`,
                `Image_ID`,
                `Image_URL`,
                `Image_Caption`,
                `Display_Order_in_Element`,
                `myRowNum`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9);
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

-- full_template_unit_plan_image_raw_view
create or replace view full_template_unit_plan_image_raw_view as
select * from (select  main.Unit_Type_ID
                    ,   main.Condo_Code
                    ,   gallery.Gallery_Cover as Gallery_Cover
                    ,   gallery.Gallery as Gallery
                    ,   facilities.Facilities_Cover as Facilities_Cover
                    ,   facilities.Facilities_Gallery as Facilities_Gallery
                from full_template_unit_type main
                left join ( select  I6.Unit_Type_ID
                                ,   I6.Condo_Code
                                ,   I6.Image_ID
                                ,   I6.Image_Caption
                                ,   I6.Image_URL as Gallery_Cover
                                ,   I7.Image as Gallery
                            from (  select  Unit_Type_ID
                                        ,   Condo_Code
                                        ,   Image_ID
                                        ,   Image_Caption
                                        ,   Image_URL
                                    FROM   full_template_unit_plan_gallery_raw
                                    where myRowNum = 1) I6 -- Gallery_Cover
                            left join ( SELECT  Unit_Type_ID
                                            ,   JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                                                        , 'Image_Caption', Image_Caption
                                                                        , 'Image_URL', Image_URL
                                                                        , 'Element_ID', Element_ID
                                                                        , 'Element_Name', Element_Name
                                                                        , 'Display_Order_in_Condo', Display_Order_in_Condo
                                                                        , 'Display_Order_in_Section', Display_Order_in_Section
                                                                        , 'Display_Order_in_Element', Display_Order_in_Element)) AS Image
                                        FROM   full_template_unit_plan_gallery_raw
                                        GROUP BY Unit_Type_ID ) I7 -- Gallery
                            on I6.Unit_Type_ID = I7.Unit_Type_ID ) gallery
                on main.Unit_Type_ID = gallery.Unit_Type_ID
                left join ( select  f1.Unit_Type_ID
                                ,   f1.Floor_Plan_ID
                                ,   f1.Ref_ID
                                ,   f1.Element_Name
                                ,   f1.Image_URL as Facilities_Cover
                                ,   f2.Image as Facilities_Gallery
                            from (  select  Unit_Type_ID
                                        ,   Floor_Plan_ID
                                        ,   Ref_ID
                                        ,   Element_Name
                                        ,   Image_URL
                                    from full_template_unit_plan_facilities_image_raw
                                    where myRowNum = 1  ) f1 -- Facilities_Cover
                            left join ( select  Unit_Type_ID
                                            ,   JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                                                        , 'Image_Caption', Image_Caption
                                                                        , 'Image_URL',Image_URL 
                                                                        , 'Element_ID',Ref_ID
                                                                        , 'Element_Name', Element_Name
                                                                        , 'Display_Order_in_Section', Display_Order_in_Section
                                                                        , 'Display_Order_in_Element', Display_Order_in_Element)) AS Image
                                        from full_template_unit_plan_facilities_image_raw
                                        group by Unit_Type_ID ) f2 -- Facilities_Gallery
                            on f1.Unit_Type_ID = f2.Unit_Type_ID ) facilities
                on main.Unit_Type_ID = facilities.Unit_Type_ID
                where main.Unit_Type_Status <> 2
                order by main.Condo_Code, main.Room_Type_ID, main.Size) aaa
where Gallery_Cover is not null
or Facilities_Cover is not null;

-- -----------------------------------------------------
-- Table `full_template_unit_plan_image_raw`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_plan_image_raw` (
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Gallery_Cover` VARCHAR(100) NULL,
    `Gallery` JSON NULL,
    `Facilities_Cover` VARCHAR(100) NULL,
    `Facilities_Gallery` JSON NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- truncateInsert_full_template_unit_plan_image_raw
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_plan_image_raw;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_plan_image_raw ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 JSON DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_plan_image_raw';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Unit_Type_ID,Condo_Code,Gallery_Cover,Gallery,Facilities_Cover,Facilities_Gallery
                            FROM full_template_unit_plan_image_raw_view;
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

    TRUNCATE TABLE full_template_unit_plan_image_raw;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_unit_plan_image_raw(
                `Unit_Type_ID`,
                `Condo_Code`,
                `Gallery_Cover`,
                `Gallery`,
                `Facilities_Cover`,
                `Facilities_Gallery`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5);
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

-- main view source_full_template_unit_plan_dashboard_view
create or replace view source_full_template_unit_plan_dashboard_view as
SELECT  U1.Condo_Code
    ,   U1.Unit_Type_ID
    ,   U3.Unit_Type_Text_Section -- หัวข้อฝั่งซ้าย
    ,   U2.sizes -- ขนาดข้างๆ หัวช้อฝั่งซ้าย
    ,   U1.Unit_Type_Name -- ชื่อฝั่งซ้าย
    ,   U3.Room_Type -- ประเภทห้องฝั่งซ้าย
    ,   engunitsqm(fmat(U1.Size)) as Size -- ปัดขนาดฝั่งซ้าย
    ,   if(U3.Unit_Type_Image is null,0,1) as Status_1
    ,   concat(U1.Unit_Type_Name,' - ',engunitsqm(format(U1.Size,2))) as size_name -- ซ้ายบน main display
    ,   U3.Room_Type as Unit_Plan_Room_Type -- ซ้ายบน main display
    ,   U1.Unit_Type_Image
    ,	U4.Building_and_Floor_Plan -- ขวาบน main display
    ,   U5.Floor_Displayed_Name -- ซ้ายบน sub display floor_plan
    ,   U5.Building_Name -- ซ้ายบน sub display floor_plan
    ,   U5.Floor_Plan_ID
    ,   U5.Floor_Plan_Image 
    ,   if(U6.Gallery is not null
            ,concat(U1.Unit_Type_Name,' - ',engunitsqm(format(U1.Size,2)))
            ,if(U6.Facilities_Gallery is not null
                ,concat(U5.Floor_Displayed_Name," 's Facilities Gallery")
                ,null)) as Gallery_Section_Text -- ซ้ายบน Gallery
    ,   if(U6.Gallery is not null
            ,U3.Room_Type
            ,if(U6.Facilities_Gallery is not null
                ,U5.Building_Name
                ,null)) as Gallery_Section_subText -- ซ้ายบน Gallery
    ,   if(U6.Gallery is not null
            ,U6.Gallery_Cover
            ,if(U6.Facilities_Gallery is not null
                ,U6.Facilities_Cover
                ,concat(U1.Condo_Code,'-PE-01-Exteriror-H-1920.jpg'))) as Gallery_Cover
    ,   if(U6.Gallery is not null
            ,'1'
            ,if(U6.Facilities_Gallery is not null
                ,'2'
                ,null)) as Gallery_Cover_Type
    ,   ifnull(U6.Gallery,ifnull(U6.Facilities_Gallery,null)) as Gallery
    ,   if(U6.Gallery is not null
            ,1
            ,if(U6.Facilities_Gallery is not null,1,0)) as Gallery_Status
FROM full_template_unit_type U1
INNER JOIN
(	SELECT fu.Condo_Code
        ,   fu.Room_Type_ID
        ,   if(min(fu.size)=max(fu.size),engunitsqm(fmat(min(fu.Size))),
                engunitsqm(CONCAT(fmat(min(fu.Size)), '-', fmat(max(fu.Size))))) AS sizes
    FROM full_template_unit_type fu
    WHERE fu.Unit_Type_Status <> 2
    GROUP BY fu.Condo_Code, fu.Room_Type_ID
) U2
ON U1.Room_Type_ID = U2.Room_Type_ID
and U1.Condo_Code = U2.Condo_Code
left JOIN 
(   select u.Condo_Code 
        , u.Unit_Type_ID
        , u.Room_Type_ID
        , u.Unit_Floor_Type_ID
        , u.Room_Plus
        , u.BathRoom
        , u.Unit_Type_Image
        ,   if(u.Unit_Floor_Type_ID<>1,
                if(u.Room_Plus=1,
                    if(u.BathRoom is not null
                        ,concat_ws(' ',fr.Room_Type_Name,'Plus',ff.Unit_Floor_Type_Name,u.BathRoom,'Bathroom')
                        ,concat_ws(' ',fr.Room_Type_Name,'Plus',ff.Unit_Floor_Type_Name))
                    ,if(u.BathRoom is not null
                        ,concat_ws(' ',fr.Room_Type_Name,ff.Unit_Floor_Type_Name,u.BathRoom,'Bathroom')
                        ,concat_ws(' ',fr.Room_Type_Name,ff.Unit_Floor_Type_Name)))
                ,if(u.Room_Plus=1,
                    if(u.BathRoom is not null
                        ,concat_ws(' ',fr.Room_Type_Name,'Plus',u.BathRoom,'Bathroom')
                        ,concat_ws(' ',fr.Room_Type_Name,'Plus'))
                    ,if(u.BathRoom is not null
                        ,concat_ws(' ',fr.Room_Type_Name,u.BathRoom,'Bathroom')
                        ,fr.Room_Type_Name))) as Room_Type
        ,   if(u.Room_Type_ID = 1,'Studio',
                if(u.Room_Type_ID = 2,'1 Bedroom',
                    if(u.Room_Type_ID = 4,'2 Bedroom',
                        if(u.Room_Type_ID = 5,'3 Bedroom',
                            if(u.Room_Type_ID = 6,'4 Bedroom',null))))) as Unit_Type_Text_Section
    from full_template_unit_type u
    inner join full_template_unit_floor_type ff on u.Unit_Floor_Type_ID = ff.Unit_Floor_Type_ID
    inner join full_template_room_type fr on u.Room_Type_ID = fr.Room_Type_ID
    where u.Unit_Type_Status <> 2
    and fr.Room_Type_Status = 1
    and ff.Unit_Floor_Type_Status = 1
) U3
on U1.Unit_Type_ID = U3.Unit_Type_ID
left join (select UT2.Ref_ID
                    , JSON_ARRAYAGG( JSON_OBJECT('Building_ID',Building_ID
                                                , 'Building_Name', Building_Name
                                                , 'Building_Order',Building_Order
                                                , 'Floor_Plan',floor ) ) as Building_and_Floor_Plan
            from
            (SELECT UT.Ref_ID
                , UT.Building_ID
                , UT.Building_Name
                , UT.Building_Order
                , JSON_ARRAYAGG( JSON_OBJECT('Floor_Plan_ID',Floor_Plan_ID
                                            , 'Floor_Plan_Name', Floor_Plan_Name
                                            , 'Floor_Plan_Order',Floor_Plan_Order) ) as floor
            FROM
            (
            SELECT DISTINCT  VFPR.Ref_ID
                            , FF.Building_ID
                            , FB.Building_Name
                            , FB.Building_Order
                            , VFPR.Floor_Plan_ID
                            , FP.Floor_Plan_Name
                            , FP.Floor_Plan_Order
                FROM full_template_vector_floor_plan_relationship VFPR
                left join full_template_floor FF on VFPR.Floor_Plan_ID = FF.Floor_Plan_ID
                left join full_template_building FB on FB.Building_ID = FF.Building_ID
                left join full_template_floor_plan FP on VFPR.Floor_Plan_ID = FP.Floor_Plan_ID
                where VFPR.Vector_Type = 1
                AND VFPR.Relationship_Status = 1
                AND FF.Floor_Status = 1
                AND FP.Floor_Plan_Status = 1
                ORDER BY VFPR.Ref_ID
            ) AS UT    
            GROUP BY UT.Ref_ID, UT.Building_ID, UT.Building_Name, UT.Building_Order) as UT2
            group by UT2.Ref_ID) U4
on U1.Unit_Type_ID = U4.Ref_ID
left join full_template_unit_plan_floor_plan_raw_view U5 
on U1.Unit_Type_ID = U5.Unit_Type_ID
left join full_template_unit_plan_image_raw_view U6 
on U1.Unit_Type_ID = U6.Unit_Type_ID
where U1.Unit_Type_Status <> 2
order by U1.Condo_Code, U1.Room_Type_ID, U1.Size;


-- -----------------------------------------------------
-- Table `full_template_unit_plan_dashboard_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_plan_dashboard_view` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Unit_Type_Text_Section` VARCHAR(10) NOT NULL,
    `sizes` VARCHAR(100) NOT NULL,
    `Unit_Type_Name` VARCHAR(100) NULL DEFAULT NULL,
    `Room_Type` VARCHAR(50) NOT NULL,
    `Size` VARCHAR(10) NOT NULL,
    `Status_1` SMALLINT UNSIGNED NOT NULL,
    `size_name` TEXT NULL,
    `Unit_Plan_Room_Type` VARCHAR(50) NOT NULL,
    `Unit_Type_Image` TEXT NULL, 
    `Building_and_Floor_Plan` JSON NULL,
    `Floor_Displayed_Name` TEXT NULL,
    `Building_Name` VARCHAR(100) NULL,
    `Floor_Plan_ID` INT UNSIGNED NULL,
    `Floor_Plan_Image` TEXT NULL,
    `Gallery_Section_Text` TEXT NULL,
    `Gallery_Section_subText` TEXT NULL,
    `Gallery_Cover` TEXT NOT NULL,
    `Gallery_Cover_Type` SMALLINT UNSIGNED NULL,
    `Gallery` JSON NULL,
    `Gallery_Status` SMALLINT UNSIGNED NOT NULL)
ENGINE = InnoDB;

ALTER TABLE `realist_log` 
CHANGE `Location` `Location` VARCHAR(70) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL;

-- truncateInsert_full_template_unit_plan_dashboard_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_plan_dashboard_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_plan_dashboard_view ()
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
    DECLARE v_name10 TEXT DEFAULT NULL;
    DECLARE v_name11 JSON DEFAULT NULL;
    DECLARE v_name12 TEXT DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 TEXT DEFAULT NULL;
    DECLARE v_name16 TEXT DEFAULT NULL;
    DECLARE v_name17 TEXT DEFAULT NULL;
    DECLARE v_name18 TEXT DEFAULT NULL;
    DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name20 JSON DEFAULT NULL;
    DECLARE v_name21 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_plan_dashboard_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT * FROM source_full_template_unit_plan_dashboard_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name1);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_unit_plan_dashboard_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_unit_plan_dashboard_view(
                `Condo_Code`,
                `Unit_Type_ID`,
                `Unit_Type_Text_Section`,
                `sizes`,
                `Unit_Type_Name`,
                `Room_Type`,
                `Size`,
                `Status_1`,
                `size_name`,
                `Unit_Plan_Room_Type`,
                `Unit_Type_Image`, 
                `Building_and_Floor_Plan`,
                `Floor_Displayed_Name`,
                `Building_Name`,
                `Floor_Plan_ID`,
                `Floor_Plan_Image`,
                `Gallery_Section_Text`,
                `Gallery_Section_subText`,
                `Gallery_Cover`,
                `Gallery_Cover_Type`,
                `Gallery`,
                `Gallery_Status`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21);
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