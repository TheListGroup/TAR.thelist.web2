-- source_classified_list_view
-- Table `classified_list_view`
-- Procedure truncateInsert_classified_list_view
-- source_classified_detail_view
-- Table `classified_detail_view`
-- Procedure truncateInsert_classified_detail_view

/*ALTER TABLE `classified_list_view` ADD `User_ID` INT UNSIGNED NULL AFTER `Price_Rent_Sort`;
ALTER TABLE `classified_list_view` ADD `Title_TH` TEXT NULL DEFAULT NULL AFTER `User_ID`
, ADD `Last_Update_Insert_Date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP AFTER `Title_TH`;*/
create or replace view source_classified_list_view as
select c.Classified_ID
    , concat_ws(' ','คอนโด - ',ifnull(if(c.Room_Type='Studio','1 Bed',REPLACE(REPLACE(c.Room_Type,'rooms',''),'room','')),concat(c.BedRoom,' Bed')),concat(c.BathRoom,' Bath'),c.Unit_Floor_Type) as Unit_Type
    , ifnull(ci.Classified_Image_URL,ifnull(fi.Image_URL,ifnull(concat('/realist/condo/uploads/condo/',c.Condo_Code,'/',c.Condo_Code,'-PE-01-Exterior-H-240.webp'),null))) as Classified_Image
    , nun(REPLACE(format(Size, 2),',','')) as Size
    , nun(c.Bedroom) as Bedroom
    , nun(c.BathRoom) as BathRoom
    , nun(format(c.Price_Sale,0)) as Price_Sale
    , nun(format(c.Price_Rent,0)) as Price_Rent 
    , c.Condo_Code as Condo_Code
    , lower(rc.Condo_ENName) as Condo_Name
    , concat(if(length(day(c.Last_Updated_Date))=2,day(c.Last_Updated_Date),concat("0",day(c.Last_Updated_Date))),'/'
        ,if(length(month(c.Last_Updated_Date))=2,month(c.Last_Updated_Date),concat("0",month(c.Last_Updated_Date))),'/'
        ,year(c.Last_Updated_Date)) as Announce_Day
    , date(c.Last_Updated_Date) as Announce_Date
    , c.Size as Size_Sort
    , c.Price_Sale as Price_Sale_Sort
    , c.Price_Rent as Price_Rent_Sort
    , c.User_ID
    , c.Title_TH
    , c.Last_Update_Insert_Date
    , badge_home.Badge_Home as Badge_Home
    , if((spotlight.Spotlight_List like '%PS016%' or spotlight.Spotlight_List like '%PS026%' or spotlight.Spotlight_List like '%PS019%' 
        or spotlight.Spotlight_List like '%CUS032%' or spotlight.Spotlight_List like '%PS006%' or spotlight.Spotlight_List like '%PS003%'
        or DATE(c.Created_Date) >= (CURDATE() - INTERVAL 7 DAY) or badge_home.ID = 9)
        , badge_listing.Badge_Listing
        , badge_home.Badge_Home) as Badge_Listing_or_Template
from classified c
left join real_condo rc on c.Condo_Code = rc.Condo_Code
left join (SELECT Classified_ID
                ,Classified_Image_ID
                ,concat('/realist/condo/uploads/classified/',lpad(Classified_ID,6,0),'/',Classified_Image_URL) as Classified_Image_URL
            FROM (SELECT Classified_ID
                        ,Classified_Image_ID
                        ,Classified_Image_URL
                        , ROW_NUMBER() OVER (PARTITION BY Classified_ID ORDER BY Displayed_Order_in_Classified) AS RowNum
                FROM classified_image
                where Classified_Image_Status = '1'
                and Classified_Image_Type = 1) sub
            WHERE RowNum = 1) ci
on c.Classified_ID = ci.Classified_ID
left join (SELECT Condo_Code
                , concat('/realist/condo/uploads/condo/',Condo_Code,'/',Image_URL) as Image_URL
            FROM (SELECT Condo_Code
                        , Image_URL
                        , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY rand()) AS RowNum
                FROM full_template_section_shortcut_raw_view
                where Section_ID <> 4) sub
            WHERE RowNum = 1) fi 
on c.Condo_Code = fi.Condo_Code
left join (select sub.Classified_ID
                    , if(sub.ID <> 9
                        , JSON_ARRAYAGG( JSON_OBJECT('Badge_Name', sub.Badge_Name
                                                , 'Badge_Color', sub.Badge_Color))
                        , if(next_to_station.Condo_Code is not null
                                , JSON_ARRAYAGG( JSON_OBJECT('Badge_Name', concat('ติด', ' ', next_to_station.MTran_ShortName, ' ', next_to_station.Station_THName_Display)
                                                , 'Badge_Color', sub.Badge_Color))
                                , null)) as Badge_Home
                    , sub.ID
            from ( select cbr.Classified_ID, cb.Badge_Name, cb.Badge_Color, cb.ID
                    , ROW_NUMBER() OVER (PARTITION BY cbr.Classified_ID ORDER BY cb.Badge_Order) AS RowNum
                    from classified_condo_badge_relationship cbr
                    left join classified_badge cb on cbr.Badge_Code = cb.ID
                    where cb.Badge_Status = '1') sub
            left join classified c on sub.Classified_ID = c.Classified_ID
            left join (select Condo_Code
                            , Station_THName_Display
                            , Station_Timeline
                            , MTran_ShortName
                            , Distance
                        from (SELECT a.Condo_Code
                                    , b.Station_THName_Display
                                    , b.Station_Timeline
                                    , d.MTran_ShortName
                                    , a.Distance
                                    , ROW_NUMBER() OVER (PARTITION BY a.Condo_Code ORDER BY a.Distance) AS Myorder
                                FROM `condo_around_station` a 
                                join mass_transit_station b on a.Station_Code = b.Station_Code 
                                join mass_transit_line c on a.Line_Code = c.Line_Code 
                                join mass_transit d on c.MTrand_ID = d.MTran_ID 
                                join all_condo_spotlight_relationship e on a.Condo_Code = e.Condo_Code 
                                WHERE (e.CUS001 = 'Y' or e.CUS002 = 'Y') 
                                and b.Station_Timeline = 'Completion') aa
                        where Myorder = 1
                        and Distance <= 0.1) next_to_station
            on c.Condo_Code = next_to_station.Condo_Code
            where sub.RowNum = 1
            group by sub.Classified_ID, sub.ID) badge_home
on c.Classified_ID = badge_home.Classified_ID
left join (select Condo_Code, Spotlight_List
            from classified_condo_fetch_for_map) spotlight
on c.Condo_Code = spotlight.Condo_Code
left join (select Classified_ID
                    , JSON_ARRAYAGG( JSON_OBJECT('Badge_Name',Badge_Name
                                                , 'Badge_Color',Badge_Color)) as Badge_Listing
            from ( select cbr.Classified_ID, cb.Badge_Name, cb.Badge_Color
                    , ROW_NUMBER() OVER (PARTITION BY cbr.Classified_ID ORDER BY cb.Badge_Order) AS RowNum
                    from classified_condo_badge_relationship cbr
                    left join classified_badge cb on cbr.Badge_Code = cb.ID
                    where cb.Badge_Status = '1'
                    and cb.ID in (1,2)) sub
            where sub.RowNum = 1
            group by Classified_ID) badge_listing
on c.Classified_ID = badge_listing.Classified_ID
where c.Classified_Status = '1'
and c.Size is not null
and c.Size > 0
and (c.Price_Sale is not null or c.Price_Rent is not null)
and (c.Price_Sale > 0 or c.Price_Rent > 0);

-- Table `classified_list_view`
CREATE TABLE IF NOT EXISTS `classified_list_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Unit_Type` VARCHAR(250) NOT NULL,
    `Classified_Image` TEXT NULL,
    `Size` VARCHAR(10) NOT NULL,
    `Bedroom` VARCHAR(10) NOT NULL,
    `Bathroom` VARCHAR(10) NOT NULL,
    `Price_Sale` VARCHAR(20) NOT NULL,
    `Price_Rent` VARCHAR(20) NOT NULL,
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Condo_Name` VARCHAR(250) NOT NULL,
    `Announce_Day` VARCHAR(20) NOT NULL,
    `Announce_Date` DATE NOT NULL,
    `Size_Sort` FLOAT(8,3) UNSIGNED NOT NULL,
    `Price_Sale_Sort` INT NULL,
    `Price_Rent_Sort` INT NULL,
    `User_ID` INT UNSIGNED NULL,
    `Title_TH` TEXT NULL,
    `Last_Update_Insert_Date` TIMESTAMP NULL,
    `Badge_Home` JSON NULL,
    `Badge_Listing_or_Template` JSON NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_classified_list_view
DROP PROCEDURE IF EXISTS truncateInsert_classified_list_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_list_view ()
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
    DECLARE v_name16 TEXT DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 JSON DEFAULT NULL;
    DECLARE v_name19 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_classified_list_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID,Unit_Type,Classified_Image,Size,Bedroom,Bathroom,Price_Sale
                            ,Price_Rent,Condo_Code,Condo_Name,Announce_Day,Announce_Date,Size_Sort,Price_Sale_Sort
                            ,Price_Rent_Sort,User_ID,Title_TH,Last_Update_Insert_Date,Badge_Home,Badge_Listing_or_Template
                            FROM source_classified_list_view ;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE classified_list_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            classified_list_view(
                `Classified_ID`,
                `Unit_Type`,
                `Classified_Image`,
                `Size`,
                `Bedroom`,
                `Bathroom`,
                `Price_Sale`,
                `Price_Rent`,
                `Condo_Code`,
                `Condo_Name`,
                `Announce_Day`,
                `Announce_Date`,
                `Size_Sort`,
                `Price_Sale_sort`,
                `Price_Rent_sort`,
                `User_ID`,
                `Title_TH`,
                `Last_Update_Insert_Date`,
                `Badge_Home`,
                `Badge_Listing_or_Template`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19);
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

create or replace view source_classified_detail_view as
select c.Classified_ID 
    , concat_ws(' ','คอนโด - ',ifnull(if(c.Room_Type='Studio','1 Bed',REPLACE(REPLACE(c.Room_Type,'rooms',''),'room','')),concat(c.BedRoom,' Bed')),concat(c.BathRoom,' Bath'),c.Unit_Floor_Type,concat(format(c.Size,1),' sq.m.')) as Unit_Type
    , namee.condo_name as Condo_Name
    , c.Condo_Code as Condo_Code
    , concat(if(length(day(c.Last_Updated_Date))=2,day(c.Last_Updated_Date),concat("0",day(c.Last_Updated_Date))),'/'
        ,if(length(month(c.Last_Updated_Date))=2,month(c.Last_Updated_Date),concat("0",month(c.Last_Updated_Date))),'/'
        ,year(c.Last_Updated_Date)) as Last_Updated_Date
    , if(rc.Condo_Cover = 1,concat('/realist/condo/uploads/condo/',c.Condo_Code,'/',c.Condo_Code,'-PE-01-Exterior-H-1024.webp'),null) as Cover_Image
    , ifnull(classified_image.Image,null) as Image
    , ifnull(c.Price_Sale,null) as Price_Sale
    , ifnull(round((c.Price_Sale/c.Size),-3),null) as Price_Sale_Per_Square
    , ifnull(c.Price_Rent,null) as Price_Rent
    , ifnull(c.Min_Rental_Contract,null) as Rental_Contract
    , ifnull(REPLACE(format(Size, 2),',',''),null) as Unit_Size
    , ifnull(c.Bedroom,1) as Bedroom
    , ifnull(c.BathRoom,null) as BathRoom
    , ifnull(c.Furnish,null) as Furnish
    , if(c.Furnish is not null,1,null) as Furnish_Status
    , ifnull(classified_fac.fac_room,null) as Facilities
    , c.Title_TH as Title_TH
    , ifnull(concat('ค่าโอนกรรมสิทธิ์ : ',c.Sale_Transfer_Fee,' %'),null) as Sale_Transfer_Fee
    , ifnull(concat('(',format(round(((c.Sale_Transfer_Fee/100)*c.Price_Sale)),0),' บ.)'),null) as Sub_Sale_Transfer_Fee
    , ifnull(concat('เงินมัดจำ(ซื้อ) : ',c.Sale_Deposit,' %'),null) as Sale_Deposit
    , ifnull(concat('(',format(round(((c.Sale_Deposit/100)*c.Price_Sale)),0),' บ.)'),null) as Sub_Sale_Deposit
    , ifnull(concat('ค่าจดจำนอง : ',c.Sale_Mortgage_Costs,' %'),null) as Sale_Mortgage_Costs
    , ifnull(concat('(',format(round(((c.Sale_Mortgage_Costs/100)*c.Price_Sale)),0),' บ.)'),null) as Sub_Sale_Mortgage_Costs
    , ifnull(concat('ค่าส่วนกลาง : ',rcp.Condo_Common_Fee,' บ./ตร.ม./เดือน'),null) as Condo_Common_Fee
    , ifnull(concat('(',format((rcp.Condo_Common_Fee*c.Size),2),' บ.)'),null) as Sub_Condo_Common_Fee
    , ifnull(concat('สัญญาเช่าขั้นต่ำ : ',c.Min_Rental_Contract,' เดือน'),null) as Min_Rental_Contract
    , ifnull(concat('(',format(round((CAST(CAST(c.Min_Rental_Contract AS CHAR) AS UNSIGNED)*c.Price_Rent)),0),' บ.)'),null) as Sub_Min_Rental_Contract
    , ifnull(concat('เงินมัดจำ/ประกัน(เช่า) : ',c.Rent_Deposit,' เดือน'),null) as Rent_Deposit
    , ifnull(concat('(',format(round((CAST(CAST(c.Rent_Deposit AS CHAR) AS UNSIGNED)*c.Price_Rent)),0),' บ.)'),null) as Sub_Rent_Deposit 
    , ifnull(concat('จ่ายล่วงหน้า : ',c.Advance_Payment,' เดือน'),null) as Advance_Payment
    , ifnull(concat('(',format(round((CAST(CAST(c.Advance_Payment AS CHAR) AS UNSIGNED)*c.Price_Rent)),0),' บ.)'),null) as Sub_Advance_Payment
    , cu.Email as Mail
    , c.Classified_Status as Classified_Status
    , ifnull(cu.First_Name, cu.User_Code) as Agent_Name
    , td.name_th as District_Name
    , ts.name_th as SubDistrict_Name
    , tp.name_th as Province_Name
    , rc.Condo_Latitude as Condo_Latitude
    , rc.Condo_Longitude as Condo_Longitude
    , c.Sale as Sale
    , c.Rent as Rent
    , concat_ws(' ' ,if(c.Sale = 1 and c.Rent = 1
                        , 'ขายและให้เช่าคอนโด'
                        , if(c.Sale = 1
                            , 'ขายคอนโด'
                            , if(c.Rent = 1 
                                , 'ให้เช่าคอนโด'
                                , null)))
                , namee.condo_name, concat(c.BedRoom,'นอน')
                , concat(c.BathRoom,'น้ำ'), concat('[REAL DATA ',c.Classified_ID,']')) as Classified_Title
    , concat_ws(' ', if(c.Price_Sale is not null and c.Price_Rent is not null
                        , concat_ws(' ', concat('ขาย ',round(c.Price_Sale/1000000,1), ' ลบ.'), concat('เช่า ', format(c.Price_Rent,0), ' บ./เดือน'))
                        , if(c.Price_Sale is not null
                            , concat('ขาย ',round(c.Price_Sale/1000000,1), ' ลบ.')
                            , if(c.Price_Rent is not null
                                , concat('เช่า ', format(c.Price_Rent,0), ' บ./เดือน')
                                , null)))
                    , concat(round(c.Size), ' ตร.ม.'), concat(c.BedRoom,'นอน'), concat(c.BathRoom,'น้ำ')
                    , if(ym.District_Name is not null and sub_station.Station is not null
                        , concat('คอนโดย่าน', ym.District_Name, ' ใกล้รฟฟ.สถานี', sub_station.Station)
                        , if(ym.District_Name is not null
                            , concat('คอนโดย่าน', ym.District_Name)
                            , if(sub_station.Station is not null
                                , concat('คอนโดใกล้รฟฟ.สถานี', sub_station.Station)
                                , concat('คอนโด ', namee.condo_name))))
                    , '| REAL DATA รวมข้อมูลคอนโด ประกาศขายเช่า') as Classified_Description
    , c.User_ID as User_ID
    , c.Floor as Floor
    , c.Direction as Direction
    , c.Move_In as Move_In
    , c.Parking as Parking
    , c.Unit_Floor_Type as Unit_Floor_Type
    , c.Sale_with_Tenant as Sale_with_Tenant
    , c.Title_ENG as Title_ENG
    , c.Descriptions_TH as Descriptions_TH
    , c.Descriptions_Eng as Descriptions_Eng
    , c.Parking_Amount as Parking_Amount
    , badge_home.Badge_Home as Badge
from classified c
left join ( SELECT rc.Condo_Code, 
                if(Condo_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
                    , Condo_ENName2) as condo_name
            FROM real_condo AS rc
            left JOIN ( select Condo_Code as Condo_Code1
                            ,   Condo_ENName as Condo_ENName1
                        from real_condo
                        where Condo_ENName LIKE '%\n%') real_condo1
            on rc.Condo_Code = real_condo1.Condo_Code1
            left JOIN ( select Condo_Code as Condo_Code2
                            ,   Condo_ENName as Condo_ENName2
                        from real_condo
                        WHERE Condo_ENName NOT LIKE '%\n%' 
                        AND Condo_ENName NOT LIKE '%\r%') real_condo2
            on rc.Condo_Code = real_condo2.Condo_Code2
            where rc.Condo_Status in (1,3)
            ORDER BY rc.Condo_Code ) namee
on c.Condo_Code = namee.Condo_Code
left join (select Classified_ID,JSON_ARRAYAGG( JSON_OBJECT(  'Classified_Image_ID',Classified_Image_ID
                                                            , 'Classified_Image_Type',Classified_Image_Type
                                                            , 'Classified_Image_Caption',Classified_Image_Caption
                                                            , 'Classified_Image_URL',concat('/realist/condo/uploads/classified/',lpad(Classified_ID,6,0),'/',Classified_Image_URL)
                                                            , 'Displayed_Order_in_Classified',Displayed_Order_in_Classified)) as Image
            from classified_image
            where Classified_Image_Status = '1'
            group by Classified_ID) classified_image
on c.Classified_ID = classified_image.Classified_ID
left join (select Classified_ID,JSON_ARRAYAGG( JSON_OBJECT(  'Relationship_ID', Relationship_ID
                                                            , 'Furniture_ID',Furniture_ID
                                                            , 'Furniture_Name', Furniture_Name
                                                            , 'Furniture_Category_Order', Furniture_Category_Order
                                                            , 'Furniture_Order', Furniture_Order)) as fac_room
            from (SELECT r.Classified_ID,r.Relationship_ID,r.Furniture_ID,cc.Furniture_Category_Name,cf.Furniture_Name,cc.Furniture_Category_Order,cf.Furniture_Order
                FROM `classified_furniture_category_relationships` r
                left join classified_furniture cf on r.Furniture_ID = cf.Furniture_ID
                left join classified_furniture_category cc on cf.Furniture_Category_ID = cc.Furniture_Category_ID
                where r.Relationship_Status = '1'
                and cf.Furniture_Status = '1'
                and cc.Furniture_Category_Status = '1'
                order by cc.Furniture_Category_Order,cf.Furniture_Order) fac
            group by Classified_ID) classified_fac
on c.Classified_ID = classified_fac.Classified_ID
left join real_condo_price rcp on c.Condo_Code = rcp.Condo_Code
left join classified_user cu on c.User_ID = cu.User_ID
left join real_condo rc on c.Condo_Code = rc.Condo_Code
left join thailand_district td on rc.District_ID = td.district_code
left join thailand_subdistrict ts on rc.SubDistrict_ID = ts.subdistrict_code
left join thailand_province tp on rc.Province_ID = tp.province_code
left join real_yarn_main ym on rc.RealDistrict_Code = ym.District_Code
left join ( select Condo_Code,Station_THName_Display as Station
            from (  select cv.Condo_Code
                            , ms.Station_THName_Display
                            , ROW_NUMBER() OVER (PARTITION BY cv.Condo_Code ORDER BY cv.Total_Point) AS RowNum
                    from condo_around_station_view as cv 
                    inner join mass_transit_station as ms on cv.Station_Code = ms.Station_Code
                    order by cv.Condo_Code) a
            where a.RowNum = 1) as sub_station
on rc.Condo_Code = sub_station.Condo_Code
left join (select sub.Classified_ID
                    , if(sub.ID <> 9
                        , JSON_ARRAYAGG( JSON_OBJECT('Badge_Name', sub.Badge_Name
                                                , 'Badge_Color', sub.Badge_Color))
                        , if(next_to_station.Condo_Code is not null
                                , JSON_ARRAYAGG( JSON_OBJECT('Badge_Name', concat('ติด', ' ', next_to_station.MTran_ShortName, ' ', next_to_station.Station_THName_Display)
                                                , 'Badge_Color', sub.Badge_Color))
                                , null)) as Badge_Home
            from ( select cbr.Classified_ID, cb.Badge_Name, cb.Badge_Color, cb.ID
                    , ROW_NUMBER() OVER (PARTITION BY cbr.Classified_ID ORDER BY cb.Badge_Order) AS RowNum
                    from classified_condo_badge_relationship cbr
                    left join classified_badge cb on cbr.Badge_Code = cb.ID
                    where cb.Badge_Status = '1') sub
            left join classified c on sub.Classified_ID = c.Classified_ID
            left join (select Condo_Code
                            , Station_THName_Display
                            , Station_Timeline
                            , MTran_ShortName
                            , Distance
                        from (SELECT a.Condo_Code
                                    , b.Station_THName_Display
                                    , b.Station_Timeline
                                    , d.MTran_ShortName
                                    , a.Distance
                                    , ROW_NUMBER() OVER (PARTITION BY a.Condo_Code ORDER BY a.Distance) AS Myorder
                                FROM `condo_around_station` a 
                                join mass_transit_station b on a.Station_Code = b.Station_Code 
                                join mass_transit_line c on a.Line_Code = c.Line_Code 
                                join mass_transit d on c.MTrand_ID = d.MTran_ID 
                                join all_condo_spotlight_relationship e on a.Condo_Code = e.Condo_Code 
                                WHERE (e.CUS001 = 'Y' or e.CUS002 = 'Y') 
                                and b.Station_Timeline = 'Completion') aa
                        where Myorder = 1
                        and Distance <= 0.1) next_to_station
            on c.Condo_Code = next_to_station.Condo_Code
            where sub.RowNum = 1
            group by sub.Classified_ID, sub.ID) badge_home
on c.Classified_ID = badge_home.Classified_ID
where (c.Classified_Status = '1' or c.Classified_Status = '3')
and c.Size is not null
and c.Size > 0
and (c.Price_Sale is not null or c.Price_Rent is not null)
and (c.Price_Sale > 0 or c.Price_Rent > 0)
order by c.Classified_ID;

/*ALTER TABLE classified_detail_view ADD District_Name VARCHAR(150) NULL AFTER Agent_Name;
ALTER TABLE classified_detail_view ADD SubDistrict_Name VARCHAR(150) NULL AFTER District_Name;
ALTER TABLE classified_detail_view ADD Province_Name VARCHAR(150) NULL AFTER SubDistrict_Name;
ALTER TABLE classified_detail_view ADD Condo_Latitude DOUBLE NULL AFTER Province_Name;
ALTER TABLE classified_detail_view ADD Condo_Longitude DOUBLE NULL AFTER Condo_Latitude;
ALTER TABLE classified_detail_view ADD Sale BOOLEAN NULL AFTER Condo_Longitude;
ALTER TABLE classified_detail_view ADD Rent BOOLEAN NULL AFTER Sale;
ALTER TABLE classified_detail_view ADD Classified_Title TEXT NULL AFTER Rent;
ALTER TABLE classified_detail_view ADD Classified_Description TEXT NULL AFTER Classified_Title;
ALTER TABLE classified_detail_view ADD User_ID INT UNSIGNED NULL AFTER Classified_Description;
ALTER TABLE classified_detail_view ADD Floor SMALLINT UNSIGNED NULL AFTER User_ID;
ALTER TABLE classified_detail_view ADD Direction ENUM('ทิศเหนือ','ทิศใต้','ทิศตะวันออก','ทิศตะวันตก','ทิศตะวันออกเฉียงเหนือ','ทิศตะวันออกเฉียงใต้','ทิศตะวันตกเฉียงเหนือ','ทิศตะวันตกเฉียงใต้') NULL AFTER Floor;
ALTER TABLE classified_detail_view ADD Move_In enum('พร้อมให้เข้าอยู่', 'ภายใน 1 - 3 เดือน') NULL AFTER Direction;
ALTER TABLE classified_detail_view ADD Parking BOOLEAN NULL AFTER Move_In;
ALTER TABLE classified_detail_view ADD Unit_Floor_Type enum('Loft', 'Simplex', 'Duplex', 'Triplex') NULL AFTER Parking;
ALTER TABLE classified_detail_view ADD Sale_with_Tenant BOOLEAN NULL AFTER Unit_Floor_Type;
ALTER TABLE classified_detail_view CHANGE Description Title_TH TEXT NULL;
ALTER TABLE classified_detail_view ADD Title_ENG TEXT NULL AFTER Sale_with_Tenant;
ALTER TABLE classified_detail_view ADD Descriptions_Eng TEXT NULL AFTER Title_ENG;
ALTER TABLE classified_detail_view ADD Descriptions_TH TEXT NULL AFTER Descriptions_Eng;
ALTER TABLE classified_detail_view ADD Parking_Amount SMALLINT UNSIGNED NULL AFTER Descriptions_TH;*/

-- Table `classified_detail_view`
CREATE TABLE IF NOT EXISTS `classified_detail_view` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Unit_Type` VARCHAR(250) NULL,
    `Condo_Name` VARCHAR(250) NOT NULL,
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Last_Updated_Date` VARCHAR(20) NOT NULL,
    `Cover_Image` TEXT NULL,
    `Image` JSON NULL,
    `Price_Sale` INT UNSIGNED NULL,
    `Price_Sale_Per_Square` VARCHAR(10) NULL,
    `Price_Rent` INT UNSIGNED NULL,
    `Rental_Contract` SMALLINT UNSIGNED NULL,
    `Unit_Size` FLOAT(7,2) NULL,
    `Bedroom` VARCHAR(4) NOT NULL,
    `Bathroom` SMALLINT UNSIGNED NULL,
    `Furnish` ENUM('Bareshell','Non Furnished','Fully Fitted','Fully Furnished') NULL,
    `Furnish_Status` SMALLINT UNSIGNED NULL,
    `Facilities` JSON NULL,
    `Title_TH` TEXT NULL,
    `Sale_Transfer_Fee` VARCHAR(150) NULL,
    `Sub_Sale_Transfer_Fee` VARCHAR(150) NULL,
    `Sale_Deposit` VARCHAR(150) NULL,
    `Sub_Sale_Deposit` VARCHAR(150) NULL,
    `Sale_Mortgage_Costs` VARCHAR(150) NULL,
    `Sub_Sale_Mortgage_Costs` VARCHAR(150) NULL,
    `Condo_Common_Fee` VARCHAR(150) NULL,
    `Sub_Condo_Common_Fee` VARCHAR(150) NULL,
    `Min_Rental_Contract` VARCHAR(150) NULL,
    `Sub_Min_Rental_Contract` VARCHAR(150) NULL,
    `Rent_Deposit` VARCHAR(150) NULL,
    `Sub_Rent_Deposit` VARCHAR(150) NULL,
    `Advance_Payment` VARCHAR(150) NULL,
    `Sub_Advance_Payment` VARCHAR(150) NULL,
    `Mail` VARCHAR(100) NULL,
    `Classified_Status` ENUM('1','3') NULL,
    `Agent_Name` VARCHAR(50) NOT NULL,
    `District_Name` VARCHAR(150) NULL,
    `SubDistrict_Name` VARCHAR(150) NULL,
    `Province_Name` VARCHAR(150) NULL,
    `Condo_Latitude` DOUBLE NULL,
    `Condo_Longitude` DOUBLE NULL,
    `Sale` BOOLEAN NULL,
    `Rent` BOOLEAN NULL,
    `Classified_Title` TEXT NULL,
    `Classified_Description` TEXT NULL,
    `User_ID` INT UNSIGNED NULL,
    `Floor` SMALLINT UNSIGNED NULL,
    `Direction` ENUM('ทิศเหนือ','ทิศใต้','ทิศตะวันออก','ทิศตะวันตก','ทิศตะวันออกเฉียงเหนือ','ทิศตะวันออกเฉียงใต้','ทิศตะวันตกเฉียงเหนือ','ทิศตะวันตกเฉียงใต้') NULL,
    `Move_In` enum('พร้อมให้เข้าอยู่', 'ภายใน 1 - 3 เดือน') NULL,
    `Parking` BOOLEAN NULL,
    `Unit_Floor_Type` enum('Loft', 'Simplex', 'Duplex', 'Triplex') NULL,
    `Sale_with_Tenant` BOOLEAN NULL,
    `Title_ENG` TEXT NULL,
    `Descriptions_Eng` TEXT NULL,
    `Descriptions_TH` TEXT NULL,
    `Parking_Amount` SMALLINT UNSIGNED NULL,
    `Badge` JSON NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_classified_detail_view
DROP PROCEDURE IF EXISTS truncateInsert_classified_detail_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_detail_view ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 TEXT DEFAULT NULL;
    DECLARE v_name6 JSON DEFAULT NULL;
    DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name16 JSON DEFAULT NULL;
    DECLARE v_name17 TEXT DEFAULT NULL;
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
    DECLARE v_name32 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name33 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name34 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name35 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name36 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name37 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name38 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name39 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name40 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name41 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name42 TEXT DEFAULT NULL;
    DECLARE v_name43 TEXT DEFAULT NULL;
    DECLARE v_name44 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name45 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name46 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name47 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name48 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name49 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name50 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name51 TEXT DEFAULT NULL;
    DECLARE v_name52 TEXT DEFAULT NULL;
    DECLARE v_name53 TEXT DEFAULT NULL;
    DECLARE v_name54 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name55 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_classified_detail_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR  SELECT Classified_ID,Unit_Type,Condo_Name,Condo_Code,Last_Updated_Date,Cover_Image,Image,Price_Sale
                                    ,Price_Sale_Per_Square,Price_Rent,Rental_Contract,Unit_Size,Bedroom,Bathroom,Furnish,Furnish_Status
                                    ,Facilities,Title_TH,Sale_Transfer_Fee,Sub_Sale_Transfer_Fee,Sale_Deposit,Sub_Sale_Deposit
                                    ,Sale_Mortgage_Costs,Sub_Sale_Mortgage_Costs,Condo_Common_Fee,Sub_Condo_Common_Fee,Min_Rental_Contract
                                    ,Sub_Min_Rental_Contract,Rent_Deposit,Sub_Rent_Deposit,Advance_Payment,Sub_Advance_Payment,Mail
                                    ,Classified_Status,Agent_Name,District_Name,SubDistrict_Name,Province_Name,Condo_Latitude
                                    ,Condo_Longitude,Sale,Rent,Classified_Title,Classified_Description,User_ID,Floor,Direction,Move_In
                                    ,Parking,Unit_Floor_Type,Sale_with_Tenant,Title_ENG,Descriptions_Eng,Descriptions_TH,Parking_Amount,Badge
                            FROM source_classified_detail_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE classified_detail_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54,v_name55;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            classified_detail_view(
                `Classified_ID`,
                `Unit_Type`,
                `Condo_Name`,
                `Condo_Code`,
                `Last_Updated_Date`,
                `Cover_Image`,
                `Image`,
                `Price_Sale`,
                `Price_Sale_Per_Square`,
                `Price_Rent`,
                `Rental_Contract`,
                `Unit_Size`,
                `Bedroom`,
                `Bathroom`,
                `Furnish`,
                `Furnish_Status`,
                `Facilities`,
                `Title_TH`,
                `Sale_Transfer_Fee`,
                `Sub_Sale_Transfer_Fee`,
                `Sale_Deposit`,
                `Sub_Sale_Deposit`,
                `Sale_Mortgage_Costs`,
                `Sub_Sale_Mortgage_Costs`,
                `Condo_Common_Fee`,
                `Sub_Condo_Common_Fee`,
                `Min_Rental_Contract`,
                `Sub_Min_Rental_Contract`,
                `Rent_Deposit`,
                `Sub_Rent_Deposit`,
                `Advance_Payment`,
                `Sub_Advance_Payment`,
                `Mail`,
                `Classified_Status`,
                `Agent_Name`,
                `District_Name`,
                `SubDistrict_Name`,
                `Province_Name`,
                `Condo_Latitude`,
                `Condo_Longitude`,
                `Sale`,
                `Rent`,
                `Classified_Title`,
                `Classified_Description`,
                `User_ID`,
                `Floor`,
                `Direction`,
                `Move_In`,
                `Parking`,
                `Unit_Floor_Type`,
                `Sale_with_Tenant`,
                `Title_ENG`,
                `Descriptions_Eng`,
                `Descriptions_TH`,
                `Parking_Amount`,
                `Badge`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54,v_name55);
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