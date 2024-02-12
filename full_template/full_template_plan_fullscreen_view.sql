/*  - source_full_template_unit_plan_fullscreen_view
    - Table `full_template_unit_plan_fullscreen_view`
    - truncateInsert_full_template_unit_plan_fullscreen_view
    
    - source_full_template_unit_gallery_fullscreen_view
    - Table `full_template_unit_gallery_fullscreen_view`
    - truncateInsert_full_template_unit_gallery_fullscreen_view
    
    - full_template_floor_plan_fullscreen_vector_raw_view
    - full_template_floor_plan_fullscreen_facilities_image_raw_view
    - source_full_template_floor_plan_fullscreen_view
    - Table `full_template_floor_plan_fullscreen_view
    - truncateInsert_full_template_floor_plan_fullscreen_view
    
    - source_full_template_facilities_gallery_fullscreen_view
    - Table `full_template_facilities_gallery_fullscreen_view`
    - truncateInsert_full_template_facilities_gallery_fullscreen_view */


-- source_full_template_unit_plan_fullscreen_view
create or replace view source_full_template_unit_plan_fullscreen_view as
SELECT  U1.Condo_Code
    ,   U1.Unit_Type_ID
    ,   U3.Unit_Type_Text_Section
    ,   U2.sizes
    ,   U1.Unit_Type_Name
    ,   U3.Room_Type
    ,   engunitsqm(fmat(U1.Size)) as Size
    ,   if(U3.Unit_Type_Image is null,0,1) as Status_1
    ,   concat(U1.Unit_Type_Name,' - ',engunitsqm(format(U1.Size,2))) as size_name
    ,   U3.Room_Type as Unit_Plan_Room_Type
    ,   U1.Unit_Type_Image
    ,	U4.Building_and_Floor_Plan
    ,   U6.Gallery_Cover
    ,   if(U6.Gallery is not null,1,0) as Gallery_Status
FROM full_template_unit_type U1
INNER JOIN
(	SELECT fu.Condo_Code
        ,   fu.Room_Type_ID
        ,   if(min(fu.size)=max(fu.size),engunitsqm(fmat(min(fu.Size))),
                engunitsqm(CONCAT(fmat(min(fu.Size)), '-', fmat(max(fu.Size))))) AS sizes
    FROM full_template_unit_type fu
    WHERE fu.Unit_Type_Status = 1
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
    where u.Unit_Type_Status = 1
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
left join full_template_unit_plan_image_raw U6 
on U1.Unit_Type_ID = U6.Unit_Type_ID
where U1.Unit_Type_Status = 1
order by U1.Condo_Code, U1.Room_Type_ID, U1.Size
        ,if(U1.Unit_Type_Image is null,'zzz',REPLACE(REPLACE(U1.Unit_Type_Image, '[0-9]+-', ''),'.webp','')), U1.Unit_Type_Name;

-- -----------------------------------------------------
-- Table `full_template_unit_plan_fullscreen_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_plan_fullscreen_view` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Unit_Type_Text_Section` VARCHAR(100) NOT NULL,
    `sizes` VARCHAR(100) NOT NULL,
    `Unit_Type_Name` VARCHAR(100) NULL DEFAULT NULL,
    `Room_Type` VARCHAR(50) NOT NULL,
    `Size` VARCHAR(50) NOT NULL,
    `Status_1` SMALLINT UNSIGNED NOT NULL,
    `size_name` TEXT NULL,
    `Unit_Plan_Room_Type` VARCHAR(100) NOT NULL,
    `Unit_Type_Image` TEXT NULL, 
    `Building_and_Floor_Plan` JSON NULL,
    `Gallery_Cover` TEXT NULL,
    `Gallery_Status` SMALLINT UNSIGNED NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- truncateInsert_full_template_unit_plan_fullscreen_view
DROP PROCEDURE IF EXISTS truncateInsert_full_template_unit_plan_fullscreen_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_unit_plan_fullscreen_view ()
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

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_full_template_unit_plan_fullscreen_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code,Unit_Type_ID,Unit_Type_Text_Section,sizes,Unit_Type_Name,Room_Type,Size,Status_1,size_name
                                ,Unit_Plan_Room_Type,Unit_Type_Image,Building_and_Floor_Plan,Gallery_Cover,Gallery_Status 
                            FROM source_full_template_unit_plan_fullscreen_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',concat_ws(' ',v_name,v_name1));
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_unit_plan_fullscreen_view;

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
            full_template_unit_plan_fullscreen_view(
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
                `Gallery_Cover`,
                `Gallery_Status`
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



-- source_full_template_unit_gallery_fullscreen_view
create or replace view source_full_template_unit_gallery_fullscreen_view as
SELECT  U1.Condo_Code
    ,   U1.Unit_Type_ID
    ,   U3.Unit_Type_Text_Section
    ,   U2.sizes
    ,   U1.Unit_Type_Name
    ,   U3.Room_Type
    ,   engunitsqm(fmat(U1.Size)) as Size
    ,   concat(U1.Unit_Type_Name,' - ',engunitsqm(format(U1.Size,2))) as size_name
    ,   U3.Room_Type as Unit_Plan_Room_Type
    ,   U6.Gallery
FROM full_template_unit_type U1
INNER JOIN
(	SELECT fu.Condo_Code
        ,   fu.Room_Type_ID
        ,   if(min(fu.size)=max(fu.size),engunitsqm(fmat(min(fu.Size))),
                engunitsqm(CONCAT(fmat(min(fu.Size)), '-', fmat(max(fu.Size))))) AS sizes
    FROM full_template_unit_type fu
    WHERE fu.Unit_Type_Status = 1
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
    where u.Unit_Type_Status = 1
    and fr.Room_Type_Status = 1
    and ff.Unit_Floor_Type_Status = 1
) U3
on U1.Unit_Type_ID = U3.Unit_Type_ID
left join full_template_unit_plan_image_raw U6 
on U1.Unit_Type_ID = U6.Unit_Type_ID
where U1.Unit_Type_Status = 1
order by U1.Condo_Code, U1.Room_Type_ID, U1.Size;

-- -----------------------------------------------------
-- Table `full_template_unit_gallery_fullscreen_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_gallery_fullscreen_view` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Unit_Type_ID` INT UNSIGNED NOT NULL,
    `Unit_Type_Text_Section` VARCHAR(10) NOT NULL,
    `sizes` VARCHAR(100) NOT NULL,
    `Unit_Type_Name` VARCHAR(100) NULL DEFAULT NULL,
    `Room_Type` VARCHAR(50) NOT NULL,
    `Size` VARCHAR(10) NOT NULL,
    `size_name` TEXT NULL,
    `Unit_Plan_Room_Type` VARCHAR(50) NOT NULL,
    `Gallery` JSON NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Unit_Type_ID, Unit_Type_Text_Section, sizes, Unit_Type_Name, Room_Type, Size, size_name
                                , Unit_Plan_Room_Type, Gallery 
                            FROM source_full_template_unit_gallery_fullscreen_view;
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

    TRUNCATE TABLE    full_template_unit_gallery_fullscreen_view;

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


-- full_template_floor_plan_fullscreen_vector_raw_view
    -- vector type 1,2,3
create or replace view full_template_floor_plan_fullscreen_vector_raw_view as
SELECT      fv.Floor_Plan_ID
        ,   fv.Vector_ID
        ,   fv.Vector_Type
        ,   fv.Ref_ID
        ,   if(fv1.Unit_Type_Name is not null
                , concat(fv1.Unit_Type_Name,' - ',engunitsqm(format(fv1.Size,0)))
                , if(fv2.Element_Name is not null
                    , fv2.Element_Name
                    , if(fv3.Building_Name is not null
                        , concat('Building ',fv3.Building_Name)
                        , null))) as Ref_Name
        ,   if(fv1.Unit_Type_Name is not null
                , if(fv1.Room_Plus = 1
                    , concat(fv1.Room_Type_Name,' Plus')
                    , fv1.Room_Type_Name)
                , if(fv2.Element_Name is not null
                    , fv2.Category_Name
                    , null)) as Ref_Type_Name
        ,   if(fv1.Unit_Type_Image is not null,1
                , if(fv2.Image_URL is not null,1,0)) as Ref_Status
        ,   fv.Polygon
FROM full_template_vector_floor_plan_relationship fv
left join ( select  fv.Floor_Plan_ID
                ,   fv.Ref_ID
                ,   fu.Unit_Type_Name
                ,   fu.Room_Type_ID
                ,   fu.Room_Plus
                ,   fr.Room_Type_Name
                ,   fu.Size
                ,   fu.Unit_Type_Image
                ,   fv.Vector_Type
            from full_template_vector_floor_plan_relationship fv
            left join full_template_unit_type fu on fv.Ref_ID = fu.Unit_Type_ID
            left join full_template_room_type fr on fu.Room_Type_ID = fr.Room_Type_ID
            where fv.Relationship_Status = 1
            and fv.Vector_Type = 1
            and fu.Unit_Type_Status = 1
            and fr.Room_Type_Status = 1
            group by fv.Floor_Plan_ID,fv.Ref_ID
            order by fv.Floor_Plan_ID,fu.Room_Type_ID,fu.Size,fu.Unit_Type_ID ) fv1
on fv.Floor_Plan_ID = fv1.Floor_Plan_ID
and fv.Ref_ID = fv1.Ref_ID
and fv.Vector_Type = fv1.Vector_Type
left join ( select  fv.Floor_Plan_ID
                ,   fv.Ref_ID
                ,   fe.Element_Name
                ,   fe.Category_ID
                ,   fc.Category_Name
                ,   fff.Image_URL
                ,   fv.Vector_Type
            from full_template_vector_floor_plan_relationship fv
            left join full_template_element fe on fv.Ref_ID = fe.Element_ID
            left join full_template_category fc on fe.Category_ID = fc.Category_ID
            left join ( select  Floor_Plan_ID
                            ,   Ref_ID
                            ,   Image_URL
                        from full_template_floor_plan_fullscreen_facilities_image_raw_view
                        where Display_Order_in_Element = 1) fff
            on fv.Floor_Plan_ID = fff.Floor_Plan_ID
            and fv.Ref_ID = fff.Ref_ID
            where fv.Relationship_Status = 1
            and fv.Vector_Type = 2
            and fe.Element_Status = 1
            and fc.Category_Status = 1
            group by fv.Floor_Plan_ID,fv.Ref_ID,fff.Image_URL
            order by fv.Floor_Plan_ID,fe.Display_Order_in_Section ) fv2
on fv.Floor_Plan_ID = fv2.Floor_Plan_ID
and fv.Ref_ID = fv2.Ref_ID
and fv.Vector_Type = fv2.Vector_Type
left join ( select  fv.Floor_Plan_ID
                ,   fv.Ref_ID
                ,   fb.Building_Name
                ,   fv.Vector_Type
            from full_template_vector_floor_plan_relationship fv
            left join full_template_building fb on fv.Ref_ID = fb.Building_ID
            where fv.Relationship_Status = 1
            and fv.Vector_Type = 3
            and fb.Building_Status = 1
            group by fv.Floor_Plan_ID,fv.Ref_ID 
            order by fv.Floor_Plan_ID,fb.Condo_Code,fb.Building_Order ) fv3
on fv.Floor_Plan_ID = fv3.Floor_Plan_ID
and fv.Ref_ID = fv3.Ref_ID
and fv.Vector_Type = fv3.Vector_Type            
where fv.Relationship_Status = 1
and fv.Vector_Type <> 0
order by fv.Floor_Plan_ID,fv.Vector_Type,fv.Ref_ID ;

-- full_template_floor_plan_fullscreen_facilities_image_raw_view
create or replace view full_template_floor_plan_fullscreen_facilities_image_raw_view as
select  fv.Floor_Plan_ID
    ,   fv.Ref_ID
    ,   fe.Element_Name
    ,   fe.Display_Order_in_Section
    ,   fi.Image_ID
    ,   fi.Image_URL
    ,   fi.Image_Caption
    ,	fi.Display_Order_in_Element
    ,   ROW_NUMBER() OVER (PARTITION BY fv.Floor_Plan_ID ORDER BY fe.Display_Order_in_Section
                                                                , fi.Display_Order_in_Element) AS myRowNum 
from full_template_vector_floor_plan_relationship fv
left join full_template_element fe on fv.Ref_ID = fe.Element_ID
left join full_template_image fi on fi.Element_ID = fe.Element_ID
where fv.Vector_Type = 2
and fv.Relationship_Status = 1
and fe.Element_Status = 1
and fi.Image_Status = 1
group by fv.Floor_Plan_ID,fv.Ref_ID,fe.Element_Name,fe.Display_Order_in_Section,fi.Image_ID,fi.Image_URL,fi.Image_Caption,fi.Display_Order_in_Element
order by fv.Floor_Plan_ID,fe.Display_Order_in_Section,fi.Display_Order_in_Element;

-- source_full_template_floor_plan_fullscreen_view
create or replace view source_full_template_floor_plan_fullscreen_view as
SELECT  F1.Condo_Code
    ,   F1.Floor_Plan_ID
    ,   F1.Master_Plan
    ,   F1.Floor_Plan_Name
    ,	F2.Building_ID
    ,   F2.Building_Name
    ,   concat('Building ',F2.Building_Name) as Building_Text
    ,   if(F1.Master_Plan = 0,concat('Floor ',F1.Floor_Plan_Name),null) as Floor_Plan_Text
    ,   F1.Floor_Plan_Image
    ,   F4.Unit_Type 
    ,   F5.Vector
    ,   F6.Facilities_Cover
    ,   if(F6.Facilities_Gallery is not null,1,0) as Facilities_Gallery_Status
from full_template_floor_plan F1
-- floor_plan
left join ( SELECT ff.Floor_Plan_ID,ff.Building_ID, fb.Building_Order, fb.Building_Name
            FROM full_template_floor_plan fp
            left join full_template_floor ff on fp.Floor_Plan_ID = ff.Floor_Plan_ID
            left join full_template_building fb on ff.Building_ID = fb.Building_ID
            where ff.Floor_Status = 1
            and ff.Floor_Plan_ID is not null
            and fb.Building_Status = 1
            and fp.Master_Plan = 0
            and fp.Floor_Plan_Status = 1
            group by ff.Floor_Plan_ID,ff.Building_ID ) F2
on F1.Floor_Plan_ID = F2.Floor_Plan_ID
-- master_plan
left join ( SELECT Floor_plan_ID,Condo_Code
            FROM full_template_floor_plan
            where Floor_Plan_Status = 1
            and Master_Plan = 1
            and Floor_Plan_Order < 1
            group by Floor_Plan_ID,Condo_Code
            order by Condo_Code ) F3
on F1.Floor_Plan_ID = F3.Floor_Plan_ID
left join ( select FUT.Floor_Plan_ID, JSON_ARRAYAGG( JSON_OBJECT( 'Unit_Type_Order', Unit_Type_Order
                                                                , 'Unit_Type_ID',Ref_ID
                                                                , 'Unit_Type_Name', Unit_Type_Name
                                                                , 'Room_Type', Room_Name
                                                                , 'Size',format(Size,2)) ) as Unit_Type
            from ( SELECT DISTINCT   VFPR.Floor_Plan_ID
                                ,   VFPR.Ref_ID
                                ,   fu.Unit_Type_Name
                                ,   fu.Room_Type_ID
                                ,   if(fu.Room_Plus = 1, concat(fr.Room_Type_Name,' Plus'), fr.Room_Type_Name) as Room_Name
                                ,   fu.Size
                                ,	REPLACE(fu.Unit_Type_Image, '[0-9]+-', '')
                                ,   ROW_NUMBER() OVER (PARTITION BY VFPR.Floor_Plan_ID ORDER BY   fu.Room_Type_ID
                                                                                                , fu.Size
                                                                                                , if(fu.Unit_Type_Image is null,'zzz',REPLACE(fu.Unit_Type_Image, '[0-9]+-', ''))
                                                                                                , fu.Unit_Type_Name) AS Unit_Type_Order
                    FROM full_template_vector_floor_plan_relationship VFPR
                    left join full_template_unit_type fu on VFPR.Ref_ID = fu.Unit_Type_ID
                    left join full_template_room_type fr on fu.Room_Type_ID = fr.Room_Type_ID
                    where VFPR.Vector_Type = 1
                    AND VFPR.Relationship_Status = 1
                    and fu.Unit_Type_Status = 1
                    and fr.Room_Type_Status = 1
                    group by VFPR.Floor_Plan_ID,VFPR.Ref_ID,fu.Unit_Type_Name,fu.Room_Type_ID,Room_Name,fu.Size
                    ORDER BY VFPR.Floor_Plan_ID,Unit_Type_Order) FUT
            group by FUT.Floor_Plan_ID ) F4
on F1.Floor_Plan_ID = F4.Floor_Plan_ID
left join ( SELECT Floor_Plan_ID,JSON_ARRAYAGG( JSON_OBJECT(  'Vector_ID', Vector_ID
                                                            , 'Vector_Type',Vector_Type
                                                            , 'Ref_ID', Ref_ID
                                                            , 'Ref_Name', Ref_Name
                                                            , 'Ref_Type_Name', Ref_Type_Name
                                                            , 'Polygon',Polygon
                                                            , 'Ref_Status', Ref_Status )) as Vector
            FROM full_template_floor_plan_fullscreen_vector_raw_view
            group by Floor_Plan_ID) F5 
on F1.Floor_Plan_ID = F5.Floor_Plan_ID
left join ( select  f1.Floor_Plan_ID
                ,   f1.Image_URL as Facilities_Cover
                ,   f2.Facilities_Gallery
            from ( select   Floor_Plan_ID
                        ,   Ref_ID
                        ,   Element_Name
                        ,   Image_URL
                        ,	Image_Caption
                    from full_template_floor_plan_fullscreen_facilities_image_raw_view
                    where myRowNum = 1) f1
            left join ( select  Floor_Plan_ID
                            ,   JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                                        , 'Image_Caption', Image_Caption
                                                        , 'Image_URL',Image_URL 
                                                        , 'Display_Order_in_Section', Display_Order_in_Section
                                                        , 'Display_Order_in_Element', Display_Order_in_Element)) AS Facilities_Gallery
                        from full_template_floor_plan_fullscreen_facilities_image_raw_view
                        group by Floor_Plan_ID) f2
            on f1.Floor_Plan_ID = f2.Floor_Plan_ID) F6
on F1.Floor_Plan_ID = F6.Floor_Plan_ID
where F1.Floor_Plan_Status = 1
order by Condo_Code,F2.Building_Order,F1.Floor_Plan_Order;

-- -----------------------------------------------------
-- Table `full_template_floor_plan_fullscreen_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_floor_plan_fullscreen_view` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Floor_Plan_ID` INT UNSIGNED NOT NULL,
    `Master_Plan` BOOLEAN NOT NULL DEFAULT FALSE,
    `Floor_Plan_Name` VARCHAR(100) NOT NULL,
    `Building_ID` INT UNSIGNED NULL,
    `Building_Name` VARCHAR(50) NULL,
    `Building_Text` VARCHAR(100) NULL,
    `Floor_Plan_Text` VARCHAR(100) NULL,
    `Floor_Plan_Image` TEXT NOT NULL,
    `Unit_Type` JSON NULL,
    `Vector` JSON NULL, 
    `Facilities_Cover` TEXT NULL,
    `Facilities_Gallery_Status` SMALLINT UNSIGNED NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Floor_Plan_ID, Master_Plan, Floor_Plan_Name, Building_ID, Building_Name, Building_Text
                                , Floor_Plan_Text, Floor_Plan_Image, Unit_Type, Vector, Facilities_Cover, Facilities_Gallery_Status
                            FROM source_full_template_floor_plan_fullscreen_view;
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

    TRUNCATE TABLE    full_template_floor_plan_fullscreen_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12;
        -- more variables here as needed

        -- Check if there are no more records
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

-- source_full_template_facilities_gallery_fullscreen_view
create or replace view source_full_template_facilities_gallery_fullscreen_view as
SELECT  F1.Condo_Code
    ,   F1.Floor_Plan_ID
    ,   F1.Master_Plan
    ,   F1.Floor_Plan_Name
    ,	F2.Building_ID
    ,   F2.Building_Name
    ,   concat('Building ',F2.Building_Name) as Building_Text
    ,   if(F1.Master_Plan = 0,concat('Floor ',F1.Floor_Plan_Name),null) as Floor_Plan_Text
    ,   concat('Floor ',F1.Floor_Plan_Name," 's Facilities Gallery") as Floor_Plan_Section_Text
    ,   F6.Facilities_Gallery
from full_template_floor_plan F1
-- floor_plan
left join ( SELECT ff.Floor_Plan_ID,ff.Building_ID, fb.Building_Order, fb.Building_Name
            FROM full_template_floor_plan fp
            left join full_template_floor ff on fp.Floor_Plan_ID = ff.Floor_Plan_ID
            left join full_template_building fb on ff.Building_ID = fb.Building_ID
            where ff.Floor_Status = 1
            and ff.Floor_Plan_ID is not null
            and fb.Building_Status = 1
            and fp.Master_Plan = 0
            and fp.Floor_Plan_Status = 1
            group by ff.Floor_Plan_ID,ff.Building_ID ) F2
on F1.Floor_Plan_ID = F2.Floor_Plan_ID
-- master_plan
left join ( SELECT Floor_plan_ID,Condo_Code
            FROM full_template_floor_plan
            where Floor_Plan_Status = 1
            and Master_Plan = 1
            and Floor_Plan_Order < 1
            group by Floor_Plan_ID,Condo_Code
            order by Condo_Code ) F3
on F1.Floor_Plan_ID = F3.Floor_Plan_ID
left join ( select  f1.Floor_Plan_ID
                ,   f1.Image_URL as Facilities_Cover
                ,   f2.Facilities_Gallery
            from ( select   Floor_Plan_ID
                        ,   Ref_ID
                        ,   Element_Name
                        ,   Image_URL
                        ,	Image_Caption
                    from full_template_floor_plan_fullscreen_facilities_image_raw_view
                    where myRowNum = 1) f1
            left join ( select  Floor_Plan_ID
                            ,   JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                                        , 'Image_Caption', Image_Caption
                                                        , 'Image_URL',Image_URL 
                                                        , 'Element_ID',REf_ID
                                                        , 'Display_Order_in_Section', Display_Order_in_Section
                                                        , 'Display_Order_in_Element', Display_Order_in_Element)) AS Facilities_Gallery
                        from full_template_floor_plan_fullscreen_facilities_image_raw_view
                        group by Floor_Plan_ID) f2
            on f1.Floor_Plan_ID = f2.Floor_Plan_ID) F6
on F1.Floor_Plan_ID = F6.Floor_Plan_ID
where F1.Floor_Plan_Status = 1
order by Condo_Code,F2.Building_Order,F1.Floor_Plan_Order;

-- -----------------------------------------------------
-- Table `full_template_facilities_gallery_fullscreen_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_facilities_gallery_fullscreen_view` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Floor_Plan_ID` INT UNSIGNED NOT NULL,
    `Master_Plan` BOOLEAN NOT NULL DEFAULT FALSE,
    `Floor_Plan_Name` VARCHAR(100) NOT NULL,
    `Building_ID` INT UNSIGNED NULL,
    `Building_Name` VARCHAR(50) NULL,
    `Building_Text` VARCHAR(100) NULL,
    `Floor_Plan_Text` VARCHAR(100) NULL,
    `Floor_Plan_Section_Text` VARCHAR(100) NULL,
    `Facilities_Gallery` JSON NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

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

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Floor_Plan_ID, Master_Plan, Floor_Plan_Name, Building_ID, Building_Name, Building_Text
                                , Floor_Plan_Text, Floor_Plan_Section_Text, Facilities_Gallery
                            FROM source_full_template_facilities_gallery_fullscreen_view;
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

    TRUNCATE TABLE    full_template_facilities_gallery_fullscreen_view;

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
	CALL truncateInsert_condo_spotlight_relationship_view ();
    CALL truncateInsert_condo_fetch_for_map ();
	CALL truncateInsert_mass_transit_station_match_route ();
    CALL truncateInsert_full_template_factsheet ();
    CALL truncateInsert_full_template_element_image_view ();
    CALL truncateInsert_full_template_credit_view ();
    CALL truncateInsert_full_template_facilities_icon_view ();
    CALL truncateInsert_full_template_section_shortcut_view ();
    -- CALL truncateInsert_full_template_unit_plan_dashboard_view ();
    CALL truncateInsert_full_template_unit_plan_fullscreen_view ();
    CALL truncateInsert_full_template_unit_gallery_fullscreen_view ();
    CALL truncateInsert_full_template_floor_plan_fullscreen_view ();
    CALL truncateInsert_full_template_facilities_gallery_fullscreen_view ();

END$$
DELIMITER ;