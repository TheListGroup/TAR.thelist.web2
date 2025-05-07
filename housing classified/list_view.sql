-- view source_housing_classified_list_view
-- table housing_classified_list_view
-- procedure 

-- source_housing_classified_list_view
create or replace view source_housing_classified_list_view as
select hc.Classified_ID
    , concat_ws(' ',hc.Housing_Type,' - ',concat(hc.BedRoom,' Bed'),concat(hc.BathRoom,' Bath')) as Unit_Type
    , ifnull(ci.Classified_Image_URL,ifnull(fi.Image_URL,ifnull(concat('/realist/housing/uploads/housing/',hc.Housing_Code,'/',hc.Housing_Code,'-PE-01-Exterior-H-240.webp'),null))) as Classified_Image
    , nun(REPLACE(format(hc.Housing_TotalRai,2),',','')) as Area
    , nun(REPLACE(format(hc.Housing_Usable_Area, 2),',','')) as Usable_Area
    , nun(hc.Bedroom) as Bedroom
    , nun(hc.BathRoom) as BathRoom
    , nun(format(hc.Price_Sale,0)) as Price_Sale
    , nun(format(hc.Price_Rent,0)) as Price_Rent
    , hc.Housing_Code as Housing_Code
    , lower(h.Housing_ENName) as Housing_Name
    , concat(if(length(day(hc.Last_Updated_Date))=2,day(hc.Last_Updated_Date),concat("0",day(hc.Last_Updated_Date))),'/'
        ,if(length(month(hc.Last_Updated_Date))=2,month(hc.Last_Updated_Date),concat("0",month(hc.Last_Updated_Date))),'/'
        ,year(hc.Last_Updated_Date)) as Announce_Day
    , date(hc.Last_Updated_Date) as Announce_Date
    , hc.Housing_TotalRai as Area_Sort
    , hc.Housing_Usable_Area as Usable_Area_Sort
    , hc.Price_Sale as Price_Sale_Sort
    , hc.Price_Rent as Price_Rent_Sort
    , hc.User_ID
    , hc.Title_TH
    , hc.Last_Update_Insert_Date
    , hc.Housing_Type
from housing_classified hc
left join housing h on hc.Housing_Code = h.Housing_Code
left join (SELECT Classified_ID
                , Classified_Image_ID
                , concat('/realist/housing/uploads/classified/', lpad(Classified_ID,6,0), '/', Classified_Image_URL) as Classified_Image_URL
            FROM (SELECT Classified_ID
                        , Classified_Image_ID
                        , Classified_Image_URL
                        , ROW_NUMBER() OVER (PARTITION BY Classified_ID ORDER BY Classified_Image_Type, Displayed_Order_in_Classified) AS RowNum
                FROM housing_classified_image
                where Classified_Image_Status = '1') sub
            WHERE RowNum = 1) ci
on hc.Classified_ID = ci.Classified_ID
left join (SELECT Housing_Code
                , concat('/realist/condo/uploads/housing/',Housing_Code,'/',Image_URL) as Image_URL
            FROM (SELECT Housing_Code
                        , Image_URL
                        , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY rand()) AS RowNum
                FROM housing_full_template_section_shortcut_raw_view
                where Section_ID <> 3) sub
            WHERE RowNum = 1) fi
on hc.Housing_Code = fi.Housing_Code
where hc.Classified_Status = '1';

-- Table `housing_classified_list_view`
CREATE TABLE IF NOT EXISTS `housing_classified_list_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Unit_Type` VARCHAR(250) NOT NULL,
    `Classified_Image` TEXT NULL,
    `Area` VARCHAR(10) NULL,
    `Usable_Area` VARCHAR(10) NOT NULL,
    `Bedroom` VARCHAR(10) NOT NULL,
    `Bathroom` VARCHAR(10) NOT NULL,
    `Price_Sale` VARCHAR(20) NOT NULL,
    `Price_Rent` VARCHAR(20) NOT NULL,
    `Housing_Code` VARCHAR(10) NOT NULL,
    `Housing_Name` VARCHAR(250) NOT NULL,
    `Announce_Day` VARCHAR(20) NOT NULL,
    `Announce_Date` DATE NOT NULL,
    `Area_Sort` FLOAT(10,5) NULL,
    `Usable_Area_Sort` FLOAT(10,5) NULL,
    `Price_Sale_Sort` INT NULL,
    `Price_Rent_Sort` INT NULL,
    `User_ID` INT UNSIGNED NULL,
    `Title_TH` TEXT NULL,
    `Last_Update_Insert_Date` TIMESTAMP NULL,
    `Housing_Type` ENUM('บ้านเดี่ยว','บ้านแฝด','ทาวน์โฮม','โฮมออฟฟิศ','อาคารพาณิชย์') NOT NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_housing_classified_list_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_classified_list_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_classified_list_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 TEXT DEFAULT NULL;
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
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 TEXT DEFAULT NULL;
    DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name20 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_housing_classified_list_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID, Unit_Type, Classified_Image, Area, Usable_Area, Bedroom, Bathroom, Price_Sale, Price_Rent, Housing_Code, Housing_Name
                                , Announce_Day, Announce_Date, Area_Sort, Usable_Area_Sort, Price_Sale_Sort, Price_Rent_Sort, User_ID, Title_TH, Last_Update_Insert_Date
                                , Housing_Type
                            FROM source_housing_classified_list_view ;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE housing_classified_list_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_classified_list_view(
                `Classified_ID`,
                `Unit_Type`,
                `Classified_Image`,
                `Area`,
                `Usable_Area`,
                `Bedroom`,
                `Bathroom`,
                `Price_Sale`,
                `Price_Rent`,
                `Housing_Code`,
                `Housing_Name`,
                `Announce_Day`,
                `Announce_Date`,
                `Area_Sort`,
                `Usable_Area_Sort`,
                `Price_Sale_sort`,
                `Price_Rent_sort`,
                `User_ID`,
                `Title_TH`,
                `Last_Update_Insert_Date`,
                `Housing_Type`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20);
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