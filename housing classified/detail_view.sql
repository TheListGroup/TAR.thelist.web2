-- VIEW source_housing_classified_detail_view
-- TABLE housing_classified_detail_view
-- PROCEDURE truncateInsert_housing_classified_detail_view

-- VIEW source_housing_classified_detail_view
create or replace view source_housing_classified_detail_view as
select hc.Classified_ID
    , concat_ws(' ',hc.Housing_Type,' - ',concat(hc.BedRoom,' Bed'),concat(hc.BathRoom,' Bath'),concat(format(hc.Housing_Usable_Area,1),' sq.m.')) as Unit_Type
    , namee.housing_name as Housing_Name
    , hc.Housing_Code as Housing_Code
    , hc.Housing_Type as Housing_Type
    , concat(if(length(day(hc.Last_Updated_Date))=2,day(hc.Last_Updated_Date),concat("0",day(hc.Last_Updated_Date))),'/'
        , if(length(month(hc.Last_Updated_Date))=2,month(hc.Last_Updated_Date),concat("0",month(hc.Last_Updated_Date))),'/'
        , year(hc.Last_Updated_Date)) as Last_Updated_Date
    , if(h.Housing_Cover = 1,concat('/realist/housing/uploads/housing/',hc.Housing_Code,'/',hc.Housing_Code,'-PE-01-Exterior-H-1024.webp'),null) as Cover_Image
    , ifnull(classified_image.Image,null) as Image 
    , ifnull(hc.Price_Sale,null) as Price_Sale
    , ifnull(round((hc.Price_Sale/hc.Housing_Usable_Area),0),null) as Price_Sale_Per_Square
    , ifnull(hc.Price_Rent,null) as Price_Rent
    , ifnull(hc.Min_Rental_Contract,null) as Rental_Contract
    , ifnull(replace(format(hc.Housing_TotalRai,2),',',''),null) as Area
    , ifnull(REPLACE(format(hc.Housing_Usable_Area, 2),',',''),null) as Usable_Area
    , ifnull(hc.Bedroom,1) as Bedroom
    , ifnull(hc.BathRoom,null) as BathRoom
    , ifnull(hc.Furnish,null) as Furnish
    , if(hc.Furnish is not null,1,null) as Furnish_Status
    , ifnull(hc.Housing_Latitude,null) as Housing_Latitude
    , ifnull(hc.Housing_Longitude,null) as Housing_Longitude
    , ifnull(concat('(',format(round(hc.Sale_Reservation),0),' บ.)'),null) as Sub_Sale_Reservation
    , ifnull(concat('เงินทำสัญญา : ',hc.Sale_Contact,' %'),null) as Sale_Contact
    , ifnull(concat('(',format(round(((hc.Sale_Contact/100)*hc.Price_Sale)),0),' บ.)'),null) as Sub_Sale_Contact
    , ifnull(concat('ค่าโอนกรรมสิทธิ์ : ',hc.Sale_Transfer_Fee,' %'),null) as Sale_Transfer_Fee
    , ifnull(concat('(',format(round(((hc.Sale_Transfer_Fee/100)*hc.Price_Sale)),0),' บ.)'),null) as Sub_Sale_Transfer_Fee
    , hc.Sale_with_Tenant
    , ifnull(concat('สัญญาเช่าขั้นต่ำ : ',hc.Min_Rental_Contract,' เดือน'),null) as Min_Rental_Contract
    , ifnull(concat('(',format(round((CAST(CAST(hc.Min_Rental_Contract AS CHAR) AS UNSIGNED)*hc.Price_Rent)),0),' บ.)'),null) as Sub_Min_Rental_Contract
    , ifnull(concat('เงินมัดจำ/ประกัน(เช่า) : ',hc.Rent_Deposit,' เดือน'),null) as Rent_Deposit
    , ifnull(concat('(',format(round((CAST(CAST(hc.Rent_Deposit AS CHAR) AS UNSIGNED)*hc.Price_Rent)),0),' บ.)'),null) as Sub_Rent_Deposit 
    , ifnull(concat('จ่ายล่วงหน้า : ',hc.Advance_Payment,' เดือน'),null) as Advance_Payment
    , ifnull(concat('(',format(round((CAST(CAST(hc.Advance_Payment AS CHAR) AS UNSIGNED)*hc.Price_Rent)),0),' บ.)'),null) as Sub_Advance_Payment
    , hc.Title_TH as Title_TH
    , cu.Profile_Picture
    , cu.Email as Mail
    , cu.First_Name as Agent_Name
    , hc.Classified_Status as Classified_Status
    , td.name_th as District_Name
    , ts.name_th as SubDistrict_Name
    , tp.name_th as Province_Name
    , h.Housing_Latitude as Housing_Latitude_Real
    , h.Housing_Longitude as Housing_Longitude_Real
    , hc.Classified_Type as Classified_Type
    , hc.Descriptions_TH as Descriptions_TH
    , hc.Descriptions_Eng as Descriptions_Eng
    , hc.User_ID
    , hc.Direction
    , hc.Floor
    , hc.Parking_Amount
    , hc.Move_In
from housing_classified hc
left join housing h on hc.Housing_Code = h.Housing_Code
left join classified_user cu on hc.User_ID = cu.User_ID
left join thailand_district td on h.District_ID = td.district_code
left join thailand_subdistrict ts on h.SubDistrict_ID = ts.subdistrict_code
left join thailand_province tp on h.Province_ID = tp.province_code
left join ( SELECT h.Housing_Code, 
                if(Housing_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_ENName1,'\n',1),' ',SUBSTRING_INDEX(Housing_ENName1,'\n',-1))
                    , Housing_ENName2) as housing_name
            FROM housing AS h
            left JOIN ( select Housing_Code as Housing_Code1
                            ,   Housing_ENName as Housing_ENName1
                        from housing
                        where Housing_ENName LIKE '%\n%') housing1
            on h.Housing_Code = housing1.Housing_Code1
            left JOIN ( select Housing_Code as Housing_Code2
                            ,   Housing_ENName as Housing_ENName2
                        from housing
                        WHERE Housing_ENName NOT LIKE '%\n%' 
                        AND Housing_ENName NOT LIKE '%\r%') housing2
            on h.Housing_Code = housing2.Housing_Code2
            where h.Housing_Status in ('1','3')
            ORDER BY h.Housing_Code ) namee
on hc.Housing_Code = namee.Housing_Code
left join (select Classified_ID,JSON_ARRAYAGG( JSON_OBJECT(  'Classified_Image_ID',Classified_Image_ID
                                                            , 'Classified_Image_Type',Classified_Image_Type
                                                            , 'Classified_Image_Caption',Classified_Image_Caption
                                                            , 'Classified_Image_URL',concat('/realist/housing/uploads/classified/',lpad(Classified_ID,6,0),'/',Classified_Image_URL)
                                                            , 'Displayed_Order_in_Classified',Displayed_Order_in_Classified)) as Image
            from housing_classified_image
            where Classified_Image_Status = '1'
            group by Classified_ID) classified_image
on hc.Classified_ID = classified_image.Classified_ID
where hc.Classified_Status = '1'
or hc.Classified_Status = '3'
order by hc.Classified_ID;

-- Table `housing_classified_detail_view`
CREATE TABLE IF NOT EXISTS `housing_classified_detail_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Unit_Type` VARCHAR(250) NOT NULL,
    `Housing_Name` VARCHAR(250) NOT NULL,
    `Housing_Code` VARCHAR(10) NOT NULL,
    `Housing_Type` ENUM('บ้านเดี่ยว','บ้านแฝด','ทาวน์โฮม,','โฮมออฟฟิศ','อาคารพาณิชย์') NOT NULL,
    `Last_Updated_Date` VARCHAR(20) NOT NULL,
    `Cover_Image` TEXT NULL,
    `Image` JSON NULL,
    `Price_Sale` INT UNSIGNED NULL,
    `Price_Sale_Per_Square` VARCHAR(10) NULL,
    `Price_Rent` INT UNSIGNED NULL,
    `Rental_Contract` SMALLINT UNSIGNED NULL,
    `Area` FLOAT(7,2) NOT NULL,
    `Usable_Area` FLOAT(7,2) NOT NULL,
    `Bedroom` VARCHAR(10) NOT NULL,
    `BathRoom` VARCHAR(10) NULL,
    `Furnish` ENUM('Bareshell','Non Furnished','Fully Fitted','Fully Furnished') NULL,
    `Furnish_Status` SMALLINT UNSIGNED NULL,
    `Housing_Latitude` DOUBLE NULL,
    `Housing_Longitude` DOUBLE NULL,
    `Sub_Sale_Reservation` VARCHAR(100) NULL,
    `Sale_Contact` VARCHAR(100) null,
    `Sub_Sale_Contact` VARCHAR(100) null,
    `Sale_Transfer_Fee` VARCHAR(150) NULL,
    `Sub_Sale_Transfer_Fee` VARCHAR(150) NULL,
    `Sale_with_Tenant` BOOLEAN NOT NULL,
    `Min_Rental_Contract` VARCHAR(150) NULL,
    `Sub_Min_Rental_Contract` VARCHAR(150) NULL,
    `Rent_Deposit` VARCHAR(150) NULL,
    `Sub_Rent_Deposit` VARCHAR(150) NULL,
    `Advance_Payment` VARCHAR(150) NULL,
    `Sub_Advance_Payment` VARCHAR(150) NULL,
    `Title_TH` TEXT NULL,
    `Profile_Picture` TEXT NULL,
    `Mail` varchar(100) NULL,
    `Agent_Name` varchar(100) NULL,
    `Classified_Status` ENUM('0','1','2','3') NULL,
    `District_Name` VARCHAR(150) NULL,
    `SubDistrict_Name` VARCHAR(150) NULL,
    `Province_Name` VARCHAR(150) NULL,
    `Housing_Latitude_Real` DOUBLE NULL,
    `Housing_Longitude_Real` DOUBLE NULL,
    `Classified_Type` ENUM('เช่า','ขาย','เช่าและขาย') NOT NULL,
    `Descriptions_TH` TEXT NULL,
    `Descriptions_ENG` TEXT NULL,
    `User_ID` INT UNSIGNED NULL,
    `Direction` ENUM('หันหน้าทิศเหนือ','หันหน้าทิศใต้','หันหน้าทิศตะวันตก','หันหน้าทิศตะวันออก','หันหน้าทิศตะวันตกเฉียงเหนือ','หันหน้าทิศตะวันตกเฉียงใต้','หันหน้าทิศตะวันออกเฉียงเหนือ','หันหน้าทิศตะวันออกเฉียงใต้') NULL,
    `Floor` ENUM('1','2','2.5','3','3.5','4','4.5','5','6+') NULL,
    `Parking_Amount` ENUM('0','1','2','3','4','5+') NULL,
    `Move_In` ENUM('พร้อมให้เข้าอยู่', 'ภายใน 1 - 3 เดือน') NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_housing_classified_detail_view
DROP PROCEDURE IF EXISTS truncateInsert_housing_classified_detail_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_classified_detail_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 TEXT DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 TEXT DEFAULT NULL;
    DECLARE v_name7 JSON DEFAULT NULL;
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
    DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name22 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name23 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name24 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name25 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name26 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name27 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name28 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name29 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name30 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name31 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name32 TEXT DEFAULT NULL;
    DECLARE v_name33 TEXT DEFAULT NULL;
    DECLARE v_name34 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name35 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name36 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name37 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name38 TEXT DEFAULT NULL;
    DECLARE v_name39 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name40 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name41 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name42 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name43 TEXT DEFAULT NULL;
    DECLARE v_name44 TEXT DEFAULT NULL;
    DECLARE v_name45 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name46 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name47 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name48 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name49 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_housing_classified_detail_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID, Unit_Type, Housing_Name, Housing_Code, Housing_Type, Last_Updated_Date, Cover_Image, Image, Price_Sale
                                , Price_Sale_Per_Square, Price_Rent, Rental_Contract, Area, Usable_Area, Bedroom, BathRoom, Furnish, Furnish_Status, Housing_Latitude
                                , Housing_Longitude, Sub_Sale_Reservation, Sale_Contact, Sub_Sale_Contact, Sale_Transfer_Fee, Sub_Sale_Transfer_Fee, Sale_with_Tenant
                                , Min_Rental_Contract, Sub_Min_Rental_Contract, Rent_Deposit, Sub_Rent_Deposit, Advance_Payment, Sub_Advance_Payment, Title_TH
                                , Profile_Picture, Mail, Agent_Name, Classified_Status, District_Name, SubDistrict_Name, Province_Name, Housing_Latitude_Real
                                , Housing_Longitude_Real, Classified_Type, Descriptions_TH, Descriptions_Eng, User_ID, Direction, Floor, Parking_Amount, Move_In
                            FROM source_housing_classified_detail_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE housing_classified_detail_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_classified_detail_view(
                Classified_ID
                , Unit_Type
                , Housing_Name
                , Housing_Code
                , Housing_Type
                , Last_Updated_Date
                , Cover_Image
                , Image
                , Price_Sale
                , Price_Sale_Per_Square
                , Price_Rent
                , Rental_Contract
                , Area
                , Usable_Area
                , Bedroom
                , BathRoom
                , Furnish
                , Furnish_Status
                , Housing_Latitude
                , Housing_Longitude
                , Sub_Sale_Reservation
                , Sale_Contact
                , Sub_Sale_Contact
                , Sale_Transfer_Fee
                , Sub_Sale_Transfer_Fee
                , Sale_with_Tenant
                , Min_Rental_Contract
                , Sub_Min_Rental_Contract
                , Rent_Deposit
                , Sub_Rent_Deposit
                , Advance_Payment
                , Sub_Advance_Payment
                , Title_TH
                , Profile_Picture
                , Mail
                , Agent_Name
                , Classified_Status
                , District_Name
                , SubDistrict_Name
                , Province_Name
                , Housing_Latitude_Real
                , Housing_Longitude_Real
                , Classified_Type
                , Descriptions_TH
                , Descriptions_Eng
                , User_ID
                , Direction
                , Floor
                , Parking_Amount
                , Move_In)
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49);
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