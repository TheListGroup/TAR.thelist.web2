-- Table housing_type_function
-- Procedure housing_type_getspotlight_icon
-- Procedure housing_type_update_function
-- housing_full_template_unit_image_raw_view
-- source_housing_full_template_housing_type_image_menu_view
-- Table housing_full_template_housing_type_image_menu_view
-- truncateInsert_truncateInsert_housing_type_image_menu_view
-- source_housing_full_template_master_plan_vector_view
-- Table `housing_full_template_master_plan_vector_view`
-- truncateInsert_housing_full_template_master_plan_vector_view

-- -----------------------------------------------------
-- Table `housing_type_function`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_type_function` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Function_Name` VARCHAR(50) NOT NULL,
    `Function_Icon` TEXT NULL,
    `Function_Order` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- housing_type_getspotlight_icon
DROP PROCEDURE IF EXISTS housing_type_getspotlight_icon;
DELIMITER //

CREATE PROCEDURE housing_type_getspotlight_icon(IN Housing_Typr_ID SMALLINT, OUT finalfunction VARCHAR(3000))
BEGIN

	DECLARE done				BOOLEAN			DEFAULT FALSE;
	DECLARE eachFunction_Name	VARCHAR(250)	DEFAULT NULL;
    DECLARE eachFunction_Icon	VARCHAR(250)	DEFAULT NULL;
	DECLARE eachFunction_Order	VARCHAR(250)	DEFAULT NULL;
	DECLARE queryBase1			VARCHAR(1000)	DEFAULT "SELECT COUNT(1) INTO @functionCount FROM housing_full_template_housing_type WHERE Housing_Type_ID = ";
	DECLARE queryBase2			VARCHAR(100)	DEFAULT " AND ";
	DECLARE queryBase3			VARCHAR(100)	DEFAULT " > 0";
	DECLARE queryFinal			VARCHAR(2000)	DEFAULT NULL;
    DECLARE make_json           VARCHAR(2000)   DEFAULT NULL;
	DECLARE	queryResultCount	INTEGER			DEFAULT 0;
	DECLARE stmt 				VARCHAR(2000);

	DECLARE curfunction
	CURSOR FOR
		SELECT Function_Name, Function_Icon, Function_Order
		FROM housing_type_function
		ORDER BY Function_Order;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET finalfunction = "";
	SET queryBase1 = CONCAT(queryBase1, Housing_Typr_ID, queryBase2);
	
	OPEN curfunction;
	
	functionLoop:LOOP
		FETCH curfunction INTO eachFunction_Name, eachFunction_Icon, eachFunction_Order;
        
        IF done THEN
			LEAVE functionLoop;
		END IF;
		
		SET queryFinal = CONCAT(queryBase1, replace(eachFunction_Name, ' ', '_'), queryBase3);
		-- select queryFinal;
		SET @query = queryFinal;
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET queryResultCount = @functionCount;
		
		IF (queryResultCount > 0) THEN
            set make_json = concat('{"Function_Name":"', eachFunction_Name, '","Function_Icon":"', eachFunction_Icon, '","Function_Order":', eachFunction_Order, '}');
            IF finalfunction <> "" THEN
                SET finalfunction = CONCAT(finalfunction, "," , make_json);
            ELSE
                SET finalfunction = concat(finalfunction,"",make_json);
            END IF;
        --    select queryResultCount,finalfunction,functionCounter;
		END IF;
	END LOOP;
	
    CLOSE curfunction;

    SET finalfunction = TRIM(finalfunction);
	SET finalfunction = concat('[' , finalfunction, ']');

END //
DELIMITER ;

-- housing_type_update_function
DROP PROCEDURE IF EXISTS housing_type_update_function;
DELIMITER //

CREATE PROCEDURE housing_type_update_function ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE house_type	    VARCHAR(50) DEFAULT 0;
    DECLARE myFunction	TEXT;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'housing_type_update_function';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Type_ID FROM source_housing_full_template_housing_type_image_menu_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ', house_type);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    UPDATE housing_full_template_housing_type_image_menu_view
    SET Function_List = null;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO house_type;

        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL housing_type_getspotlight_icon(house_type, myFunction);
        UPDATE housing_full_template_housing_type_image_menu_view
        SET Function_List = myFunction
        WHERE Housing_Type_ID = house_type;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows run in Housing_Type.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;

    UPDATE housing_full_template_housing_type_image_menu_view
    SET Function_List = null
    WHERE TRIM(Function_List) = "[]";

END //
DELIMITER ;


-- housing_full_template_unit_image_raw_view
create or replace view housing_full_template_unit_image_raw_view as
select fte.Housing_Type_ID
    , fte.Element_ID
    , fte.Element_Name
    , fte.Display_Order_in_Section
    , fti.Image_ID
    , fti.Image_Caption
    , fti.Image_URL
    , fti.Display_Order_in_Element
from housing_full_template_element fte
inner join housing_full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
inner join housing_full_template_section as fts on ftc.Section_ID = fts.Section_ID
inner join housing_full_template_image as fti on fte.Element_ID = fti.Element_ID
where fte.Element_Status = 1
and ftc.Category_Status = 1
and fts.Section_Status = 1
and fts.Section_ID = 2
and fti.Image_Status = 1;

-- source_housing_full_template_housing_type_image_menu_view
create or replace view source_housing_full_template_housing_type_image_menu_view as
select ht.Housing_Code 
    , ht.Housing_Type_ID 
    , ht.Housing_Type_Name
    , ht.Housing_Category
    , round(ht.Housing_Usable_Area) as Housing_Usable_Area 
    , round(ht.Housing_Area_Min) as Housing_Area_Min
    , ht.Bedroom
    , ht.Bathroom
    , ht.Parking
    , ht.Housing_Type_Image_Horizontal
    , ht.Housing_Type_Image_Square
    , fp.Floor_Plan as Floor_Plan_Image
    , if(fp.Floor_Plan is not null,1,0) as Floor_Plan_Status
    , v.View as Show_Unit_Image
    , if(v.View is not null,1,0) as Show_Unit_Status
    , h360.Project_360_Name
    , h360.Project_360_Link
    , if(h360.Project_360_Link is not null,1,0) as Project_360_Status
from housing_full_template_housing_type ht
left join ( SELECT Housing_Type_ID,JSON_ARRAYAGG( JSON_OBJECT(  'Floor_Plan_ID', Floor_Plan_ID 
                                                            , 'Floor_Plan_Name',Floor_Plan_Name
                                                            , 'Floor_Plan_Order', Floor_Plan_Order
                                                            , 'Floor_Plan_Image', Floor_Plan_Image)) as Floor_Plan
            FROM housing_full_template_floor_plan
            where Floor_Plan_Status = 1
            group by Housing_Type_ID) fp
on ht.Housing_Type_ID = fp.Housing_Type_ID
left join ( SELECT Housing_Type_ID,JSON_ARRAYAGG( JSON_OBJECT(  'Image_ID', Image_ID 
                                                            , 'Image_Caption',Image_Caption
                                                            , 'Image_URL', Image_URL
                                                            , 'Element_ID', Element_ID
                                                            , 'Element_Name', Element_Name
                                                            , 'Display_Order_in_Section', Display_Order_in_Section
                                                            , 'Display_Order_in_Element', Display_Order_in_Element)) as View
            FROM housing_full_template_unit_image_raw_view
            group by Housing_Type_ID) v
on ht.Housing_Type_ID = v.Housing_Type_ID
left join ( select Project_360_Name
                , Project_360_Link
                , Housing_Type_ID 
            from housing_full_template_360
            where Project_360_Status = 1) h360 
on ht.Housing_Type_ID = h360.Housing_Type_ID
where ht.Housing_Type_Status = 1
and ht.Housing_Type_Image_Horizontal is not null
and ht.Housing_Type_Image_Square is not null
order by ht.Housing_Category, ht.Housing_Usable_Area desc;

-- -----------------------------------------------------
-- Table `housing_full_template_housing_type_image_menu_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_housing_type_image_menu_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Housing_Type_ID` INT UNSIGNED NOT NULL,
    `Housing_Type_Name` VARCHAR(100) NULL,
    `Housing_Category` TEXT NOT NULL,
    `Housing_Usable_Area` INT UNSIGNED NULL,
    `Housing_Area_Min` INT UNSIGNED NULL,
    `Bedroom` INT UNSIGNED NULL,
    `Bathroom` INT UNSIGNED NULL,
    `Parking` INT UNSIGNED NULL,
    `Housing_Type_Image_Horizontal` TEXT NULL,
    `Housing_Type_Image_Square` TEXT NULL,
    `Floor_Plan_Image` JSON NULL,
    `Floor_Plan_Status` BOOLEAN NOT NULL DEFAULT FALSE,
    `Show_Unit_Image` JSON NULL,
    `Show_Unit_Status` BOOLEAN NOT NULL DEFAULT FALSE,
    `Project_360_Name` VARCHAR(100) NULL,
    `Project_360_Link` TEXT NULL,
    `Project_360_Status` BOOLEAN NOT NULL DEFAULT FALSE,
    `Function_List` JSON NULL,
    PRIMARY KEY (ID),
	INDEX image_menu_house (Housing_Code),
    INDEX image_menu_type (Housing_Type_ID))
ENGINE = InnoDB;

-- truncateInsert_housing_type_image_menu_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_type_image_menu_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_type_image_menu_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 TEXT DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name9 TEXT DEFAULT NULL;
    DECLARE v_name10 TEXT DEFAULT NULL;
    DECLARE v_name11 JSON DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name13 JSON DEFAULT NULL;
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name16 TEXT DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(80) DEFAULT 'truncateInsert_housing_type_image_menu_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Housing_Type_ID, Housing_Type_Name, Housing_Category, Housing_Usable_Area, Housing_Area_Min, Bedroom, Bathroom, Parking
                                , Housing_Type_Image_Horizontal, Housing_Type_Image_Square, Floor_Plan_Image, Floor_Plan_Status, Show_Unit_Image, Show_Unit_Status
                                , Project_360_Name, Project_360_Link, Project_360_Status
                            FROM source_housing_full_template_housing_type_image_menu_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE  housing_full_template_housing_type_image_menu_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_full_template_housing_type_image_menu_view(
                `Housing_Code`,
                `Housing_Type_ID`,
                `Housing_Type_Name`,
                `Housing_Category`,
                `Housing_Usable_Area`,
                `Housing_Area_Min`,
                `Bedroom`,
                `Bathroom`,
                `Parking`,
                `Housing_Type_Image_Horizontal`,
                `Housing_Type_Image_Square`,
                `Floor_Plan_Image`,
                `Floor_Plan_Status`,
                `Show_Unit_Image`,
                `Show_Unit_Status`,
                `Project_360_Name`,
                `Project_360_Link`,
                `Project_360_Status`
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

-- source_housing_full_template_master_plan_vector_view
create or replace view source_housing_full_template_master_plan_vector_view as
select mp.Housing_Code
    , fv.Master_Plan_ID
    , vmp.Vector_ID
    , vmp.Ref_Type
    , vmp.Ref_ID
    , mre2.Category_ID
    , ifnull(mre1.Housing_Type_Name,mre2.Element_Name) as Ref_Name
    , mp.Master_Plan_Image
    , fv.Polygon
from housing_full_template_vector_master_plan_relationship vmp
inner join housing_full_template_vector fv on vmp.Vector_ID = fv.Vector_ID
inner join housing_full_template_master_plan mp on fv.Master_Plan_ID = mp.Master_Plan_ID
left join ( select vmp.Vector_ID  
                , hv.Master_Plan_ID
                , vmp.Ref_Type
                , vmp.Ref_ID
                , fht.Housing_Type_Name
                , hv.Polygon
            from housing_full_template_vector_master_plan_relationship vmp
            left join housing_full_template_housing_type fht on vmp.Ref_ID = fht.Housing_Type_ID
            left join housing_full_template_vector hv on vmp.Vector_ID = hv.Vector_ID
            where vmp.Relationship_Status = 1
            and vmp.Ref_Type = 1
            and fht.Housing_Type_Status = 1
            and hv.Vector_Status = 1
            order by hv.Master_Plan_ID, fht.Housing_Type_ID ) mre1
on vmp.Vector_ID = mre1.Vector_ID
left join ( select vmp.Vector_ID  
                , hv.Master_Plan_ID
                , vmp.Ref_Type
                , vmp.Ref_ID
                , fte.Element_Name
                , fte.Category_ID
                , hv.Polygon
            from housing_full_template_vector_master_plan_relationship vmp
            left join housing_full_template_element fte on vmp.Ref_ID = fte.Element_ID
            left join housing_full_template_vector hv on vmp.Vector_ID = hv.Vector_ID
            where vmp.Relationship_Status = 1
            and vmp.Ref_Type = 2
            and fte.Element_Status = 1
            and hv.Vector_Status = 1
            order by hv.Master_Plan_ID, fte.Element_ID ) mre2
on vmp.Vector_ID = mre2.Vector_ID
where vmp.Relationship_Status = 1
and fv.Vector_Status = 1;

-- -----------------------------------------------------
-- Table `housing_full_template_master_plan_vector_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_master_plan_vector_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Master_Plan_ID` INT UNSIGNED NOT NULL,
    `Vector_ID` INT UNSIGNED NOT NULL,
    `Ref_Type` SMALLINT UNSIGNED NOT NULL,
    `Ref_ID` INT UNSIGNED NOT NULL,
    `Category_ID` SMALLINT UNSIGNED NULL,
    `Ref_Name` VARCHAR(100) NOT NULL,
    `Master_Plan_Image` VARCHAR(100) NOT NULL,
    `Polygon` TEXT NOT NULL,
    PRIMARY KEY (ID),
	INDEX mpv_house (Housing_Code),
    INDEX mpv_plan (Master_Plan_ID),
    INDEX mpv_vector (Vector_ID),
    INDEX mpv_ref (Ref_ID),
    INDEX mpv_cate (Category_ID))
ENGINE = InnoDB;


-- truncateInsert_housing_full_template_master_plan_vector_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_full_template_master_plan_vector_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_full_template_master_plan_vector_view ()
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

    DECLARE proc_name       VARCHAR(80) DEFAULT 'truncateInsert_housing_full_template_master_plan_vector_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Master_Plan_ID, Vector_ID, Ref_Type, Ref_ID, Category_ID, Ref_Name, Master_Plan_Image, `Polygon`
                            FROM source_housing_full_template_master_plan_vector_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE  housing_full_template_master_plan_vector_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_full_template_master_plan_vector_view(
                `Housing_Code`,
                `Master_Plan_ID`,
                `Vector_ID`,
                `Ref_Type`,
                `Ref_ID`,
                `Category_ID`,
                `Ref_Name`,
                `Master_Plan_Image`,
                `Polygon`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8);
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