-- housing_full_template_facilities_raw_view
-- source_housing_full_template_facilities_icon_view
-- housing_full_template_facilities_icon_view
-- truncateInsert_housing_full_template_facilities_icon_view

-- view ใช้ทำเรื่อง icon (รวมทุก element ที่อยู่ใน section facility)
	-- sort ตาม Housing_Code, Category_Order, Display_Order_in_Section, Display_Order_in_Element
CREATE OR REPLACE VIEW housing_full_template_facilities_raw_view AS
select fte.Housing_Code
	,	 ftc.Category_Order
	,    ftc.Category_ID
	,    ftc.Category_Name
	,    ftc.Category_Icon
	,	fte.Display_Order_in_Section
	,	fte.Element_ID
	,	fte.Element_Name
	,	fti.Display_Order_in_Element
	,	fti.Image_Id
	,	fti.Image_URL
    ,   fti.Image_Caption
    ,   fti.Date_Taken
    ,   fti.Image_Type_ID
	,   fti.Image_Status
    ,   ROW_NUMBER() OVER (PARTITION BY fte.Housing_Code ORDER BY fte.Display_Order_in_Section,fti.Display_Order_in_Element) AS RowNum
	from housing_full_template_element AS fte
		inner join housing_full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
		inner join housing_full_template_section as fts on ftc.Section_ID = fts.Section_ID
		left join housing_full_template_image as fti on fte.Element_ID = fti.Element_ID
	where fts.Section_ID = 1
	and fte.Element_Status = 1
	and ftc.Category_Status = 1
	ORDER BY fte.Housing_Code, ftc.Category_Order, fte.Display_Order_in_Section, fti.Display_Order_in_Element;


-- source_housing_full_template_facilities_icon_view
	-- facility ไหนโชว์รูป ไหนโชว์ text
CREATE OR REPLACE VIEW source_housing_full_template_facilities_icon_view AS
SELECT 	Housing_Code
	,	Category_Order
	,	Category_ID
	,	Category_Name
	,	Category_Icon
	,	Image_URL
	,	Category_Text
    ,   Image
FROM	(SELECT  Housing_Code
			,	 Category_Order
			,	 Category_ID
			,	 Category_Name
			,	 Category_Icon
		FROM	 housing_full_template_facilities_raw_view
		GROUP BY Housing_Code, Category_ID
		ORDER BY Housing_Code, Category_Order) AS main
		LEFT JOIN 
			(	SELECT Housing_Code AS Housing_Code2,
								Category_ID as Category_ID2,
				Image_URL as Image_URL
				FROM (SELECT Housing_Code
						, Category_ID
						, Image_URL
						, ROW_NUMBER() OVER (PARTITION BY Housing_Code,Category_ID ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
						FROM housing_full_template_facilities_raw_view
						where Image_Status = 1) sub
				WHERE RowNum = 1
			) AS sub_image
			ON	main.Housing_Code = sub_image.Housing_Code2
			AND main.Category_ID = sub_image.Category_ID2
		LEFT JOIN
		-- ทุก text ของทุก element ในแต่ละ category
			(	SELECT   Housing_Code		AS Housing_Code3
					,   Category_ID	AS Category_ID3
					,   JSON_ARRAYAGG(JSON_OBJECT('text' , Element_Name, 'Order', Display_Order_in_Section)) AS Category_Text
				FROM   housing_full_template_facilities_raw_view
				WHERE 	 Image_ID IS NULL
				GROUP BY Housing_Code3, Category_ID3
			) AS sub_text
			ON	main.Housing_Code = sub_text.Housing_Code3
			AND main.Category_ID = sub_text.Category_ID3
        left join (select Housing_Code as Housing_Code4
                        , Category_ID as Category_ID4
                        , JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID, 'Image_Caption', Image_Caption, 'Image_URL',Image_URL ,'Date_Taken',Date_Taken, 'Display_Order_in_Element', Display_Order_in_Element, 'Element_ID',Element_ID, 'Image_Type_ID',Image_Type_ID)) AS Image
                    from housing_full_template_facilities_raw_view
                    where Image_ID is not null
                    group by Housing_Code,Category_ID) image_set
            on main.Housing_Code = image_set.Housing_Code4
            and main.Category_ID = image_set.Category_ID4
-- sort ตาม Housing_Code, Category_Order
ORDER BY Housing_Code, Category_Order;


-- -----------------------------------------------------
-- Table `housing_full_template_facilities_icon_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_facilities_icon_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`Housing_Code` VARCHAR(50) NOT NULL,
    `Category_Order` SMALLINT UNSIGNED NOT NULL,
    `Category_ID` SMALLINT UNSIGNED NOT NULL,
    `Category_Name` VARCHAR(100) NOT NULL,
    `Category_Icon` VARCHAR(250) NOT NULL,
    `Image_URL` VARCHAR(100) NULL,
    `Category_Text` JSON NULL,
    `Image` JSON NULL,
    PRIMARY KEY (ID),
    INDEX icon_code (Housing_Code),
    INDEX icon_cate (Category_ID))
ENGINE = InnoDB;


-- truncateInsert_housing_full_template_facilities_icon_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_full_template_facilities_icon_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_full_template_facilities_icon_view ()
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
    DECLARE v_name7 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(80) DEFAULT 'truncateInsert_housing_full_template_facilities_icon_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Category_Order, Category_ID, Category_Name, Category_Icon, Image_URL, Category_Text, Image
                            FROM source_housing_full_template_facilities_icon_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE	housing_full_template_facilities_icon_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_full_template_facilities_icon_view(
                `Housing_Code`,
                `Category_Order`,
                `Category_ID`,
                `Category_Name`,
                `Category_Icon`,
                `Image_URL`,
                `Category_Text`,
                `Image`
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