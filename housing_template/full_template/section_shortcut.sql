-- housing_full_template_section_shortcut_raw_view
-- source_housing_full_template_section_shortcut_view
-- housing_full_template_section_shortcut_view
-- truncateInsert_housing_full_template_section_shortcut_view


-- view ใช้ทำเรื่อง shortcut (ทุก element ที่มีรูป)
CREATE OR REPLACE VIEW housing_full_template_section_shortcut_raw_view AS
select fte.Housing_Code
    ,   fts.Section_ID
    ,   fts.Section_Name    
	,	ftc.Category_Order
	,   ftc.Category_ID
	,   ftc.Category_Name
	,   ftc.Category_Icon
	,	fte.Display_Order_in_Section
	,	fte.Element_ID
	,	fte.Element_Name
	,	fti.Display_Order_in_Element
	,	fti.Image_Id
	,	fti.Image_URL
	from housing_full_template_element AS fte
		inner join housing_full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
		inner join housing_full_template_section as fts on ftc.Section_ID = fts.Section_ID
		inner join housing_full_template_image as fti on fte.Element_ID = fti.Element_ID
	where fte.Element_Status = 1
	and ftc.Category_Status = 1
	and fti.Image_Status = 1
    and fts.Section_Status = 1
	ORDER BY fte.Housing_Code, fts.Section_ID,ftc.Category_Order, fte.Display_Order_in_Section, fti.Display_Order_in_Element;


-- source_housing_full_template_section_shortcut_view
	-- ชื่อ section, รูปแรกของ element แรก
CREATE OR REPLACE VIEW source_housing_full_template_section_shortcut_view AS
select Housing_Code
	,	Section_1_shortcut_Name
	,	Facilities_Image
	,	Section_2_shortcut_Name
	,	Show_Unit_Image
	,	if(Spec_Image is not null,'SPECIFICATION',null) as Section_3_shortcut_Name 
	,	Spec_Image
    ,	if(Article_Image is null,null,'Article') as Section_Article_shortcut_Name 
	,	if(File_Type = 'jpg'
			, replace(Article_Image,'.jpg','.webp')
			, if(File_Type = 'png'
				, replace(Article_Image,'.png','.webp')
				, if(File_Type = 'jpeg'
					, replace(Article_Image,'.jpeg','.webp')
					, Article_Image))) as Article_Image
	,	if(if(Facilities_Image is not null,1,0) + if(Show_Unit_Image is not null,1,0) + if(Article_Image is not null,1,0) + if(Spec_Image is not null,1,0)>1,1,0) as 'Status'
from (select Housing_Code 
		from housing_full_template_section_shortcut_raw_view
		GROUP BY Housing_Code) as main
left join ( SELECT Housing_Code AS Housing_Code1,
				Image_URL as Facilities_Image,
				Section_Name as Section_1_shortcut_Name
			FROM (  SELECT Housing_Code
					, Section_Name
					, Image_URL
					, ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
					FROM housing_full_template_section_shortcut_raw_view
					where Section_ID = 1) sub
			WHERE RowNum = 1) as faci
on main.Housing_Code = faci.Housing_Code1
left join ( SELECT Housing_Code AS Housing_Code2,
				Image_URL as Show_Unit_Image,
				Section_Name as Section_2_shortcut_Name
			FROM (	SELECT Housing_Code
						, Section_Name
						, Image_URL
						, ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
					FROM housing_full_template_section_shortcut_raw_view
					where Section_ID = 2) sub
			WHERE RowNum = 1) as show_unit
on main.Housing_Code = show_unit.Housing_Code2
left join (select Housing_Code as Housing_Code4, 
					if(Image_URL_2 is not null,ifnull(Image_URL_1,ifnull(Image_URL_2,null)),null) as Spec_Image
			from (select Housing_Code 
					from housing_full_template_section_shortcut_raw_view
					WHERE Section_ID = 3
					group by Housing_Code) as spec_main
			LEFT JOIN (SELECT Housing_Code AS Housing_Code4_1
								, Image_URL AS Image_URL_1 
						FROM (SELECT Housing_Code
								, Section_ID
								, Image_URL
								, Display_Order_in_Section
								, Display_Order_in_Element
								, ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
								FROM housing_full_template_section_shortcut_raw_view
								where Section_ID = 2) sub
						WHERE RowNum = 2) as con1
            on spec_main.Housing_Code = con1.Housing_Code4_1
			left join (	SELECT Housing_Code AS Housing_Code4_2,
								Image_URL as Image_URL_2
						FROM (SELECT Housing_Code
								, Image_URL
								, ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
								FROM housing_full_template_section_shortcut_raw_view
								where Section_ID = 3) sub
						WHERE RowNum = 1) as own_spec
			on spec_main.Housing_Code = own_spec.Housing_Code4_2
			order by Housing_Code) as spec
on main.Housing_Code = spec.Housing_Code4
left join ( select Housing_Code as Housing_Code6
				, meta_value as Article_Image
				, REVERSE(SUBSTRING_INDEX(REVERSE(meta_value), '.', 1)) AS File_Type
			from (	select ss.Housing_Code
					,	wm.meta_value
					,	ROW_NUMBER() OVER (PARTITION BY ss.Housing_Code ORDER BY am.post_date desc) AS RowNum
					from housing_full_template_section_shortcut_raw_view ss
					left join housing_article_fetch_for_map am on ss.Housing_Code = am.Housing_Code
					left join wp_postmeta wm on am.ID = wm.post_id
					where wm.meta_key = '_yoast_wpseo_opengraph-image'
					order by ss.Housing_Code ) a
			where RowNum = 1) as article
on main.Housing_Code = article.Housing_Code6
order by Housing_Code;


-- -----------------------------------------------------
-- Table `housing_full_template_section_shortcut_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_section_shortcut_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Section_1_shortcut_Name` VARCHAR(50) NULL,
    `Facilities_Image` TEXT NULL,
    `Section_2_shortcut_Name` VARCHAR(50) NULL,
    `Show_Unit_Image` Text NULL,
    `Section_3_shortcut_Name` VARCHAR(50) NULL,
    `Spec_Image` TEXT NULL,
    `Section_Article_shortcut_Name` VARCHAR(50) NULL,
    `Article_Image` TEXT NULL,
    `Status` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (ID),
	INDEX ss_house (Housing_Code))
ENGINE = InnoDB;


-- truncateInsert_housing_full_template_section_shortcut_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_full_template_section_shortcut_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_full_template_section_shortcut_view ()
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

    DECLARE proc_name       VARCHAR(80) DEFAULT 'truncateInsert_housing_full_template_section_shortcut_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Section_1_shortcut_Name, Facilities_Image, Section_2_shortcut_Name, Show_Unit_Image
                                , Section_3_shortcut_Name, Spec_Image, Section_Article_shortcut_Name, Article_Image, Status
                            FROM source_housing_full_template_section_shortcut_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE  housing_full_template_section_shortcut_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_full_template_section_shortcut_view(
                `Housing_Code`,
                `Section_1_shortcut_Name`,
                `Facilities_Image`,
                `Section_2_shortcut_Name`,
                `Show_Unit_Image`,
                `Section_3_shortcut_Name`,
                `Spec_Image`,
                `Section_Article_shortcut_Name`,
                `Article_Image`,
                `Status`
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