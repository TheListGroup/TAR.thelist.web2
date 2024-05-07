/* -- Function
        -- ตัวหาร auto_ads
        -- max slot of banner
        -- max slot of billboard
        -- ads_express_way
        -- ads_desktop_billboard
        -- ads_mobile_billboard
        -- ads_banner
    -- Table
        -- ads_base
        -- ads_cal_slot
        -- ads_cal_today
        -- ads_default
        -- ads_log
        -- ads_word
        -- ads_layouts
    -- Insert
        -- ads_word
        -- ads_layouts
    -- View
        -- ads_condo_project
        -- ads_housing_project_view
        -- ads_non_residential_project
        -- ads_event_view
        ** ads_property_view
    -- Procedure
        -- ads_updateday
        -- ads_cal_today
        -- ads_calads
        -- ads_log
        ** ads_CALADSS */

-- ตัวหาร auto_ads
DELIMITER //
CREATE FUNCTION ads_auto_divide()
RETURNS INT
NO SQL
BEGIN
    RETURN 7500;
END;
//
DELIMITER ;

-- max slot of banner
DELIMITER //
CREATE FUNCTION ads_max_ban()
RETURNS INT
NO SQL
BEGIN
    RETURN 3;
END;
//
DELIMITER ;

-- max slot of billboard
DELIMITER //
CREATE FUNCTION ads_max_bill()
RETURNS INT
NO SQL
BEGIN
    RETURN 3;
END;
//
DELIMITER ;

-- ads_express_way
DELIMITER //
CREATE FUNCTION ads_express_way(lat1 DOUBLE, lat2 DOUBLE, long1 DOUBLE, long2 DOUBLE)
RETURNS DOUBLE
NO SQL
BEGIN
    DECLARE distance DOUBLE;
    SET distance = ROUND(6371 * ACOS(COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * COS(RADIANS(long2) 
                        - RADIANS(long1)) + SIN(RADIANS(lat1)) * SIN(RADIANS(lat2))),2);
    RETURN distance;
END;
//
DELIMITER ;

-- ads_desktop_billboard
DELIMITER //
CREATE FUNCTION ads_desktop_billboard(typ VARCHAR(10))
RETURNS VARCHAR(250)
NO SQL
BEGIN
    if typ = 'CD' then
        RETURN "-PE-01-Exterior-H-1920.webp";
    else
        RETURN "-PE-01-Exterior-H-1920.webp";
    end if;
END;
//
DELIMITER ;

-- ads_mobile_billboard
DELIMITER //
CREATE FUNCTION ads_mobile_billboard(typ VARCHAR(10))
RETURNS VARCHAR(250)
NO SQL
BEGIN
    if typ = 'CD' then
        RETURN "-PE-01-Exterior-H-1024.webp";
    else
        RETURN "-PE-01-Exterior-H-1024.webp";
    end if;
END;
//
DELIMITER ;

-- ads_banner
DELIMITER //
CREATE FUNCTION ads_banner(typ VARCHAR(10))
RETURNS VARCHAR(250)
NO SQL
BEGIN
    if typ = 'CD' then
        RETURN "-PE-01-Exterior-H-420.webp";
    else
        RETURN "-PE-01-Exterior-H-420.webp";
    end if;
END;
//
DELIMITER ;

-- Table ads_base
CREATE TABLE `ads_base` (
    `AD_ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `AD_Code` varchar(10) NULL,
    `Prop_Type` ENUM('CD','HP','NR','EV') NULL,
    `Prop_Code` varchar(10) NULL,
    `Project_Name` varchar(150) NULL,
    `Published_date` timestamp NOT NULL,
    `Auto_AD_Budget` int UNSIGNED NULL,
    `Manual_AD_Day` int UNSIGNED NULL,
    `Size` ENUM('Banner','Billboard') NULL,
    `AD_Type` ENUM('Auto','Manual') NOT NULL DEFAULT 'Auto',
    `Show_Days` int UNSIGNED NOT NULL DEFAULT 0,
    `Left_Days` int UNSIGNED NOT NULL,
    `AD_Rank` int DEFAULT NULL,
    `Project_Name_Manual_Billboard` VARCHAR(250) NULL,
    `Developer_Manual_Billboard` VARCHAR(200) NULL,
    `Description_Manual_Billboard` TEXT NULL,
    `Manual_Desktop_Image` TEXT DEFAULT NULL,
    `Manual_Mobile_Image` TEXT DEFAULT NULL,
    `Link` TEXT DEFAULT NULL,
    `AD_Status` ENUM('0','1','2') NOT NULL DEFAULT '0',
    `Create_Date` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `Create_User` smallint unsigned NOT NULL default 0,
    `Last_Update_Date` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `Last_Update_User` smallint unsigned NOT NULL default 0,
    PRIMARY KEY (`AD_ID`),
    INDEX base_admin1 (Create_User),
    INDEX base_admin2 (Last_Update_User),
    CONSTRAINT base_admin1 FOREIGN KEY (Create_User) REFERENCES user_admin(User_ID),
    CONSTRAINT base_admin2 FOREIGN KEY (Last_Update_User) REFERENCES user_admin(User_ID)
) ENGINE = InnoDB;

-- Table ads_cal_slot
CREATE TABLE `ads_cal_slot` (
    `slot` int NOT NULL,
    `ad_id` varchar(10) NOT NULL,
    `AD_Code` varchar(10) NULL,
    `temp_rank` int NOT NULL,
    PRIMARY KEY (`slot`)
) ENGINE=InnoDB;

-- Table ads_cal_today
CREATE TABLE `ads_cal_today` (
    `AD_ID` varchar(10) NOT NULL,
    `AD_Code` varchar(10) NULL,
    `Prop_Type` ENUM('CD','HP','NR','EV','DF') NOT NULL,
    `Prop_Code` varchar(10) NULL,
    `Published_date` timestamp NOT NULL,
    `Auto_AD_Budget` int UNSIGNED NULL,
    `Manual_AD_Day` int UNSIGNED NULL,
    `Size` enum('Banner','Billboard') NULL,
    `AD_Type` enum('Auto','Manual','Default') NOT NULL,
    `Show_Days` int UNSIGNED NOT NULL,
    `Left_Days` int UNSIGNED NOT NULL,
    `AD_Rank` int NULL,
    `Manual_Desktop_Image` TEXT DEFAULT NULL,
    `Manual_Mobile_Image` TEXT DEFAULT NULL,
    `Link` TEXT DEFAULT NULL,
    `AD_Status` ENUM('0','1','2') NOT NULL,
    `temp_rank` int NOT NULL
) ENGINE=InnoDB;

-- Table ads_default
CREATE TABLE `ads_default` (
    `ID` int unsigned NOT NULL AUTO_INCREMENT,
    `AD_ID` varchar(10) NOT NULL,
    `Prop_Type` ENUM('CD','HP','NR','EV','DF') NULL,
    `Prop_Code` varchar(10) NULL,
    `Auto_AD_Budget` int UNSIGNED NULL,
    `Manual_AD_Day` int UNSIGNED NULL,
    `Size` enum('Banner','Billboard') NULL,
    `AD_Type` enum('Default') NOT NULL DEFAULT 'Default',
    `Show_Days` int UNSIGNED NOT NULL,
    `Left_Days` int UNSIGNED NOT NULL,
    `AD_Rank` int DEFAULT NULL,
    `Project_Name_Manual_Billboard` VARCHAR(250) NULL,
    `Developer_Manual_Billboard` VARCHAR(200) NULL,
    `Description_Manual_Billboard` TEXT NULL,
    `Desktop_Billboard_Image` TEXT DEFAULT NULL,
    `Mobile_Billboard_Image` TEXT DEFAULT NULL,
    `Link` TEXT DEFAULT NULL,
    `Desktop_Banner_Image` TEXT DEFAULT NULL,
    `Mobile_Banner_Image` TEXT DEFAULT NULL,
    `AD_Status` ENUM('0','1','2') NOT NULL DEFAULT '0',
    `Create_Date` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `Create_User` smallint unsigned NOT NULL default 0,
    `Last_Update_Date` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `Last_Update_User` smallint unsigned NOT NULL default 0,
    PRIMARY KEY (`ID`),
    INDEX def_admin1 (Create_User),
    INDEX def_admin2 (Last_Update_User),
    CONSTRAINT def_admin1 FOREIGN KEY (Create_User) REFERENCES user_admin(User_ID),
    CONSTRAINT def_admin2 FOREIGN KEY (Last_Update_User) REFERENCES user_admin(User_ID)
) ENGINE=InnoDB;

-- Table ads_log
CREATE TABLE `ads_log` (
    `ID` int unsigned NOT NULL AUTO_INCREMENT,
    `Log_Date` date NOT NULL,
    `AD_ID` varchar(10) NOT NULL,
    `AD_Code` varchar(10) NULL,
    `Prop_Type` enum('CD','HP','NR','EV','DF') NOT NULL,
    `Prop_Code` varchar(10) NULL,
    `AD_Type` enum('Auto','Manual','Default') NOT NULL,
    `Size` enum('Banner','Billboard') NULL,
    `Project_Name_Manual_Billboard` varchar(250) NULL,
    `Price` varchar(100) NULL,
    `Status` varchar(100) NULL,
    `Word` varchar(100) NULL,
    `Attribute` TEXT NULL,
    `Location` varchar(250) NULL,
    `Surrounding` varchar(250) NULL,
    `Link` TEXT DEFAULT NULL,
    `Desktop_Image` TEXT DEFAULT NULL,
    `Mobile_Image` TEXT DEFAULT NULL,
    `AD_Rank` int DEFAULT NULL,
    `Developer_Manual_Billboard` VARCHAR(200) NULL,
    `Description_Manual_Billboard` TEXT NULL,
    `Desktop_Layout` int unsigned NOT NULL,
    `Mobile_Layout` int unsigned NOT NULL,
    PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

-- ads_word
CREATE TABLE `ads_words` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `word` VARCHAR(250) NOT NULL,
    `word_set` ENUM('1', '2', '3', '4', '5', '6', '7') NOT NULL,
    PRIMARY KEY (`ID`)
) ENGINE = InnoDB;

-- Table ads_layouts
CREATE TABLE `ads_layouts` (
    `Layout_ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `Prop_Type` enum('CDHP','NR','EV') NULL,
    `AD_Type` enum('Auto','Manual','Default') NOT NULL,
    `Size` enum('Banner','Billboard') NOT NULL,
    `Screen_Size` enum('Desktop','Mobile') NOT NULL,
    PRIMARY KEY (`Layout_ID`)
) ENGINE=InnoDB;

insert into ads_layouts (Layout_ID,Prop_Type,AD_Type,Size,Screen_Size)
values  (1,'CDHP','Auto','Banner','Desktop'),
        (2,'CDHP','Auto','Banner','Desktop'),
        (3,'CDHP','Auto','Banner','Desktop'),
        (4,'CDHP','Auto','Banner','Desktop'),
        (5,'CDHP','Auto','Banner','Mobile'),
        (6,'CDHP','Auto','Banner','Mobile'),
        (7,'CDHP','Auto','Banner','Mobile'),
        (8,'CDHP','Auto','Banner','Mobile'),
        (9,'CDHP','Auto','Billboard','Desktop'),
        (10,'CDHP','Auto','Billboard','Desktop'),
        (11,'CDHP','Auto','Billboard','Desktop'),
        (12,'CDHP','Auto','Billboard','Mobile'),
        (14,'CDHP','Auto','Billboard','Mobile'),
        (15,'CDHP','Auto','Billboard','Mobile'),
        (16,'NR','Auto','Banner','Desktop'),
        (17,'NR','Auto','Banner','Desktop'),
        (18,'NR','Auto','Banner','Mobile'),
        (19,'NR','Auto','Banner','Mobile'),
        (20,'NR','Auto','Billboard','Desktop'),
        (21,'NR','Auto','Billboard','Desktop'),
        (22,'NR','Auto','Billboard','Mobile'),
        (23,'NR','Auto','Billboard','Mobile'),
        (24,'NR','Auto','Billboard','Mobile'),
        (25,'EV','Auto','Banner','Desktop'),
        (26,'EV','Auto','Banner','Mobile'),
        (27,'EV','Auto','Billboard','Desktop'),
        (28,'EV','Auto','Billboard','Mobile'),
        (29,NULL,'Default','Banner','Desktop'),
        (30,NULL,'Default','Banner','Mobile'),
        (31,NULL,'Default','Billboard','Desktop'),
        (32,NULL,'Default','Billboard','Mobile');

INSERT INTO `ads_words` (`ID`, `word`, `word_set`) VALUES
(1, 'สุดคุ้ม', '1'),
(2, 'ห้ามพลาด!!', '1'),
(3, 'ซื้อคุ้มกว่าเช่า', '1'),
(4, 'จัดเต็ม', '1'),
(5, 'พิเศษเพื่อคุณ', '2'),
(6, 'คิดมาเพื่อคุณ', '2'),
(7, 'Rare Item', '2'),
(8, 'เหนือระดับ', '2'),
(9, 'สุดคุ้ม', '3'),
(10, 'ห้ามพลาด!!', '3'),
(11, 'พิเศษเพื่อคุณ', '4'),
(12, 'เอกสิทธิ์เฉพาะคุณ', '4'),
(13, 'Rare Item', '4'),
(14, 'เหนือระดับ', '4'),
(15, 'เริ่มต้นธุรกิจ!', '5'),
(16, 'ที่นี่ที่เดียว', '5'),
(17, 'คิดมาเพื่อคุณ', '5'),
(18, 'ไม่ซื้อไม่ได้แล้ว', '6'),
(19, 'พาทัวร์', '7'),
(20, 'เผยโฉม', '7'),
(21, 'ห้ามพลาด!!', '7');

-- ads_condo_project
CREATE OR REPLACE VIEW ads_condo_project AS
select cpc.Condo_Code as Prop_Code
    , rc.Condo_Latitude as Latitude
    , rc.Condo_Longitude as Longitude
    , rc.Condo_ENName as Project_Name
    , if(cpc.Condo_Price_Per_Unit_Text='ราคาเริ่มต้น'
        ,concat('เริ่มต้น ',format((cpc.Condo_Price_Per_Unit/1000000),2),' ลบ.')
        ,null) as Price
    , if(rcp.Condo_Built_Finished is not null,
        if(year(curdate()) - year(rcp.Condo_Built_Finished) > 0
            ,'คอนโด พร้อมอยู่'
            ,'คอนโด ใหม่')
        ,if(rcp.Condo_Built_Start is not null
            ,if(rc.Condo_HighRise = 1
                ,if(year(curdate()) - (year(rcp.Condo_Built_Start) + 4) > 0
                    ,'คอนโด พร้อมอยู่'
                    ,'คอนโด ใหม่')
                ,if(year(curdate()) - (year(rcp.Condo_Built_Start) + 3) > 0
                    ,'คอนโด พร้อมอยู่'
                    ,'คอนโด ใหม่'))
            ,null)) as Project_Status
    , if(cpc.Condo_Age_Status_Square_Text='ราคาเฉลี่ย'
        ,if(cpc.Condo_Price_Per_Square <= 200000
            ,(select word from ads_words where `word_set` = '1' order by rand() limit 1)
            ,if(cpc.Condo_Price_Per_Square > 200000
                ,(select word from ads_words where `word_set` = '2' order by rand() limit 1)
                ,null))
        ,NULL) as Word
    , if(csv.Top_Spotlight <> '',csv.Top_Spotlight,null) as Attribute
    , rsd.SubDistrict_Name as Location
    , ifnull(concat('รฟฟ สถานี ',sr.Station),ifnull((SELECT concat(Place_Type,' ',Place_Attribute_2) FROM `real_place_express_way` 
        where ads_express_way(Place_Latitude, rc.Condo_Latitude, Place_Longitude, rc.Condo_Longitude) <= 10
        order by ads_express_way(Place_Latitude, rc.Condo_Latitude, Place_Longitude, rc.Condo_Longitude) 
        limit 1),null)) as Surrounding
    , ifnull(link.post_name,concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',cpc.Condo_Code)) as Link
    , concat(cpc.Condo_Code,"/",cpc.Condo_Code,ads_desktop_billboard('CD')) as Desktop_Billboard_Image
    , concat(cpc.Condo_Code,"/",cpc.Condo_Code,ads_mobile_billboard('CD')) as Mobile_Billboard_Image
    , concat(cpc.Condo_Code,"/",cpc.Condo_Code,ads_banner('CD')) as Banner_Image
from all_condo_price_calculate as cpc
inner join real_condo as rc on cpc.Condo_Code = rc.Condo_Code
left join real_condo_price rcp on cpc.Condo_Code = rcp.Condo_Code
left join real_yarn_sub rsd on rc.RealSubDistrict_Code = rsd.SubDistrict_Code
left join all_condo_spotlight_relationship csv on cpc.Condo_Code = csv.Condo_Code
left join (select Condo_Code,Station_THName_Display as Station
            from (  select cv.Condo_Code
                            , ms.Station_THName_Display
                            , ROW_NUMBER() OVER (PARTITION BY cv.Condo_Code ORDER BY cv.Distance) AS RowNum
                    from condo_around_station as cv 
                    inner join mass_transit_station as ms on cv.Station_Code = ms.Station_Code
                    where cv.Distance <= 3) a
            where a.RowNum = 1) sr
on cpc.Condo_Code = sr.Condo_Code
left join (select post_id
                , meta_value
                , concat('https://thelist.group/realist/blog/',post_name) as post_name
            from (SELECT me.post_id, me.meta_value, po.post_date, po.post_name, ROW_NUMBER() OVER (PARTITION BY me.meta_value ORDER BY po.post_date desc) AS RowNum
                    FROM `wp_postmeta` me
                    left join wp_posts po on me.post_id = po.ID
                    where me.meta_key = 'aaa_condo'
                    and po.post_status = 'publish'
                    order by me.meta_value, po.post_date desc) post
            where RowNum = 1) link
on cpc.Condo_Code = link.meta_value
order by cpc.Condo_Code;

-- ads_housing_project_view
CREATE OR REPLACE VIEW ads_housing_project_view AS
select h.Housing_Code as Prop_Code
	, h.Housing_Latitude as Latitude
    , h.Housing_Longitude as Longitude
    , h.Housing_ENName as Project_Name
    , concat('เริ่มต้น ',format((h.Housing_Price_Min/1000000),2),' ลบ.') as Price
    , if(h.Housing_Built_Finished is not null
        , if(year(curdate()) - year(h.Housing_Built_Finished) > 0
            , if(h.IS_SD + h.IS_DD + h.IS_TH + h.IS_HO + h.IS_SH > 0
                , 'โครงการ พร้อมอยู่'
                , if(h.IS_SD
                    , 'บ้านเดี่ยว พร้อมอยู่'
                    , if(h.IS_DD
                        , 'บ้านแฝด พร้อมอยู่'
                        , if(h.IS_TH
                            , 'ทาวน์โฮม พร้อมอยู่'
                            , if(h.IS_HO
                                , 'โฮมออฟฟิศ พร้อมอยู่'
                                , if(h.IS_SH
                                    , 'อาคารพาณิชย์ พร้อมอยู่'
                                    , null))))))
            , if(h.IS_SD + h.IS_DD + h.IS_TH + h.IS_HO + h.IS_SH > 0
                , 'โครงการ ใหม่'
                , if(h.IS_SD
                    , 'บ้านเดี่ยว ใหม่'
                    , if(h.IS_DD
                        , 'บ้านแฝด ใหม่'
                        , if(h.IS_TH
                            , 'ทาวน์โฮม ใหม่'
                            , if(h.IS_HO
                                , 'โฮมออฟฟิศ ใหม่'
                                , if(h.IS_SH
                                    , 'อาคารพาณิชย์ ใหม่'
                                    , null)))))))
        , if(h.Housing_Built_Start is not null
            , if(year(curdate()) - (year(h.Housing_Built_Start) + 3) > 0
                , if(h.IS_SD + h.IS_DD + h.IS_TH + h.IS_HO + h.IS_SH > 0
                    , 'โครงการ พร้อมอยู่'
                    , if(h.IS_SD
                        , 'บ้านเดี่ยว พร้อมอยู่'
                        , if(h.IS_DD
                            , 'บ้านแฝด พร้อมอยู่'
                            , if(h.IS_TH
                                , 'ทาวน์โฮม พร้อมอยู่'
                                , if(h.IS_HO
                                    , 'โฮมออฟฟิศ พร้อมอยู่'
                                    , if(h.IS_SH
                                        , 'อาคารพาณิชย์ พร้อมอยู่'
                                        , null))))))
                , if(h.IS_SD + h.IS_DD + h.IS_TH + h.IS_HO + h.IS_SH > 0
                    , 'โครงการ ใหม่'
                    , if(h.IS_SD
                        , 'บ้านเดี่ยว ใหม่'
                        , if(h.IS_DD
                            , 'บ้านแฝด ใหม่'
                            , if(h.IS_TH
                                , 'ทาวน์โฮม ใหม่'
                                , if(h.IS_HO
                                    , 'โฮมออฟฟิศ ใหม่'
                                    , if(h.IS_SH
                                        , 'อาคารพาณิชย์ ใหม่'
                                        , null)))))))
            , null)) as Project_Status
    , if(h.IS_SD or h.IS_DD or h.IS_TH
        , if(h.Housing_Price_Min <= 15000000
            , (select word from ads_words where `word_set` = '3' order by rand() limit 1)
            , if(h.Housing_Price_Min > 15000000
                , (select word from ads_words where `word_set` = '4' order by rand() limit 1)
                , null))
        , if(h.IS_HO
            , (select word from ads_words where `word_set` = '5' order by rand() limit 1)
            , if(h.IS_SH
                , (select word from ads_words where `word_set` = '6' order by rand() limit 1)
                , null))) as Word
    , ifnull(h.Housing_Top_Spotlight,null) as Attribute
    , rs.SubDistrict_Name as Location
    , concat(express.Place_Type, ' ', express.Place_Attribute_2) as Surrounding
    , ifnull(link.post_name,concat('https://thelist.group/realist/housing/proj/',h.Housing_URL_Tag)) as Link
    , concat(h.Housing_Code,"/",h.Housing_Code,ads_desktop_billboard('HP')) as Desktop_Billboard_Image
    , concat(h.Housing_Code,"/",h.Housing_Code,ads_mobile_billboard('HP')) as Mobile_Billboard_Image
    , concat(h.Housing_Code,"/",h.Housing_Code,ads_banner('HP')) as Banner_Image
from housing h
left join real_yarn_sub rs on h.RealSubDistrict_Code = rs.SubDistrict_Code
left join (select post_id
                , meta_value
                , concat('https://thelist.group/realist/blog/',post_name) as post_name
            from (SELECT me.post_id, me.meta_value, po.post_date, po.post_name, ROW_NUMBER() OVER (PARTITION BY me.meta_value ORDER BY po.post_date desc) AS RowNum
                    FROM `wp_postmeta` me
                    left join wp_posts po on me.post_id = po.ID
                    where me.meta_key = 'aaa_housing'
                    and po.post_status = 'publish'
                    order by me.meta_value, po.post_date desc) post
            where RowNum = 1) link
on h.Housing_Code = link.meta_value
left join (select Housing_Code
                , Place_Type
                , Place_Attribute_2 
            from (select Housing_Code
                    , Place_Type
                    , Place_Attribute_2
                    , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                from (SELECT rpe.Place_Type
                            , rpe.Place_Attribute_2
                            , h.Housing_Code
                            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(h.Housing_Latitude - rpe.Place_Latitude)) / 2), 2)
                                + COS(RADIANS(rpe.Place_Latitude)) * COS(RADIANS(h.Housing_Latitude)) *
                                POWER(SIN((RADIANS(h.Housing_Longitude - rpe.Place_Longitude)) / 2), 2 )))) AS Distance
                        FROM real_place_express_way rpe
                        cross join (select * from housing where Housing_Status = '1' and Housing_Latitude is not null AND Housing_Longitude is not null) h) aaa  
                where aaa.Distance <= 10) aaaa
            where aaaa.RowNum = 1) express
on h.Housing_Code = express.Housing_Code
where h.Housing_Status = '1'
and h.Housing_Latitude is not null
and h.Housing_Longitude is not null
and h.Housing_ENName is not null
order by h.Housing_Code;

-- ads_non_residential_project
CREATE OR REPLACE VIEW ads_non_residential_project AS
select nr.NR_Code as Prop_Code
    , nr.NR_Latitude as Latitude
    , nr.NR_Longitude as Longitude
    , nr.NR_ENName as Project_Name
    , concat('เริ่มต้น ',format((nr.Price_Start_Unit/1000000),2),' ลบ.') as Price -- text
    , if(nr.NR_Build_Finish is not null
        ,if(year(curdate()) - year(nr.NR_Build_Finish) > 0
            ,if(non3.Prop_Code is not null
                ,'มิกซ์ยูส เปิดใหม่'
                ,if(non1.Prop_Code is not null
                    ,'ออฟฟิศ เปิดใหม่'
                    ,if(non2.Prop_Code is not null
                        ,'Retail ห้าง เปิดใหม่'
                        ,null)))
            ,if(non3.Prop_Code is not null
                ,'มิกซ์ยูส ใหม่'
                ,if(non1.Prop_Code is not null
                    ,'ออฟฟิศ ใหม่'
                    ,if(non2.Prop_Code is not null
                        ,'Retail ห้าง ใหม่'
                        ,null))))
        ,if(nr.NR_Build_Start is not null
            ,if(year(curdate()) - (year(nr.NR_Build_Start) + 3) > 0
                ,if(non3.Prop_Code is not null
                    ,'มิกซ์ยูส เปิดใหม่'
                    ,if(non1.Prop_Code is not null
                        ,'ออฟฟิศ เปิดใหม่'
                        ,if(non2.Prop_Code is not null
                            ,'Retail ห้าง เปิดใหม่'
                            ,null)))
                ,if(non3.Prop_Code is not null
                    ,'มิกซ์ยูส ใหม่'
                    ,if(non1.Prop_Code is not null
                        ,'ออฟฟิศ ใหม่'
                        ,if(non2.Prop_Code is not null
                            ,'Retail ห้าง ใหม่'
                            ,null))))
            ,null)) as Project_Status -- ระยะเวลาสร้าง
    , (select word from ads_words where `word_set` = '7' order by rand() limit 1) as Word
    , concat_ws('\n',nr.NR_Spotlight_1,nr.NR_Spotlight_2) as Attribute
    , rsd.SubDistrict_Name as Location
    , ifnull((select concat('รฟฟ สถานี ',Station_THName_Display)
            from mass_transit_station 
            where ads_express_way(Station_Latitude, nr.NR_Latitude, Station_Longitude, nr.NR_Longitude) <= 3
                order by ads_express_way(Station_Latitude, nr.NR_Latitude, Station_Longitude, nr.NR_Longitude) 
                limit 1)
        ,ifnull((SELECT concat(Place_Type,' ',Place_Attribute_2) FROM `real_place_express_way` 
                where ads_express_way(Place_Latitude, nr.NR_Latitude, Place_Longitude, nr.NR_Longitude) <= 10
                order by ads_express_way(Place_Latitude, nr.NR_Latitude, Place_Longitude, nr.NR_Longitude) 
                limit 1)
            ,null)) as Surrounding
    , 'Link' as Link
    , concat(nr.NR_Code,"/",nr.NR_Code,ads_desktop_billboard('NR')) as Desktop_Billboard_Image
    , concat(nr.NR_Code,"/",nr.NR_Code,ads_mobile_billboard('NR')) as Mobile_Billboard_Image
    , concat(nr.NR_Code,"/",nr.NR_Code,ads_banner('NR')) as Banner_Image
from ads_non_residential nr
left join real_yarn_sub rsd on nr.RealSubDistrict_Code = rsd.SubDistrict_Code
left join ( select Prop_Code
            from property_type_relationship
            where Property_Type_ID = 8) non1
on nr.NR_Code = non1.Prop_Code
left join ( select Prop_Code
            from property_type_relationship
            where Property_Type_ID in (9,10)) non2
on nr.NR_Code = non2.Prop_Code
left join (select Prop_Code 
            from (SELECT Prop_Code,COUNT(ID) as pt 
                FROM property_type_relationship
                group by Prop_Code) nrr
            where pt > 1) non3
on nr.NR_Code = non3.Prop_Code
where nr.NR_Status = '1'
group by nr.NR_Code,nr.NR_Latitude,nr.NR_Longitude,nr.NR_ENName,nr.Price_Start_Unit,nr.NR_Build_Finish,nr.NR_Build_Start
        ,nr.NR_Spotlight_1,nr.NR_Spotlight_2,rsd.SubDistrict_Name;

-- ads_event_view
CREATE OR REPLACE VIEW ads_event_view AS
select ev.EV_Code as Prop_Code
    , 0.00000000000 as Latitude
    , 0.00000000000 as Longitude  
    , ev.EV_Name as Project_Name
    , '--' as Price
    , '--' as Project_Status
    , '--' as Word 
    , concat_ws(' ',ev.EV_Spotlight_1,ev.EV_Spotlight_2) as Attribute
    , '--' as Location
    , '--' as Surrounding
    , 'Link' as Link
    , concat(ev.EV_Code,"/",ev.EV_Code,ads_desktop_billboard('EV')) as Desktop_Billboard_Image
    , concat(ev.EV_Code,"/",ev.EV_Code,ads_mobile_billboard('EV')) as Mobile_Billboard_Image
    , concat(ev.EV_Code,"/",ev.EV_Code,ads_banner('EV')) as Banner_Image
from ads_event ev
where ev.EV_Status = '1';

-- ads_property_view
CREATE OR REPLACE VIEW ads_property_view AS
select * from (select Prop_Code,Latitude,Longitude,Project_Name,Price COLLATE utf8mb4_general_ci as Price,Project_Status,Word,Attribute,Location
                ,Surrounding,Link COLLATE utf8mb4_general_ci as Link,Desktop_Billboard_Image,Mobile_Billboard_Image,Banner_Image from ads_condo_project) cd
union select * from (select Prop_Code,Latitude,Longitude,Project_Name,Price COLLATE utf8mb4_general_ci as Price,Project_Status,Word,Attribute,Location
                    ,Surrounding,Link COLLATE utf8mb4_general_ci as Link,Desktop_Billboard_Image,Mobile_Billboard_Image,Banner_Image from ads_housing_project_view) hr
union select * from (select Prop_Code,Latitude,Longitude,Project_Name,Price COLLATE utf8mb4_general_ci as Price,Project_Status,Word,Attribute,Location
                    ,Surrounding,Link COLLATE utf8mb4_general_ci as Link,Desktop_Billboard_Image,Mobile_Billboard_Image,Banner_Image from ads_non_residential_project) nr
union select * from (select Prop_Code,Latitude,Longitude,Project_Name,Price COLLATE utf8mb4_general_ci as Price,Project_Status,Word,Attribute,Location
                    ,Surrounding,Link COLLATE utf8mb4_general_ci as Link,Desktop_Billboard_Image,Mobile_Billboard_Image,Banner_Image from ads_event_view) ev ;


-- ads_updateday
DROP PROCEDURE IF EXISTS ads_updateday;
DELIMITER //

CREATE PROCEDURE ads_updateday (OUT success BOOLEAN)
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_updateday_main';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    set success = FALSE;
	
    UPDATE ads_base
    SET Show_Days = IF(AD_Rank <= ads_max_ban() + ads_max_bill(), Show_Days + 1, Show_Days),
        Left_Days = IF(AD_Rank <= ads_max_ban() + ads_max_bill(), Left_Days - 1, Left_Days),
        Last_Update_Date = IF(AD_Rank <= ads_max_ban() + ads_max_bill(),CURRENT_TIMESTAMP,Last_Update_Date);

    if errorcheck then
		SET code    = '00000';
		SET msg     = 'Update Success';
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    set success = TRUE;

END //
DELIMITER ;

-- insert ads_cal_today
DROP PROCEDURE IF EXISTS ads_update_adds;
DELIMITER //

CREATE PROCEDURE ads_update_adds (OUT success BOOLEAN)
BEGIN
    DECLARE each_id             VARCHAR(250) DEFAULT NULL;
    DECLARE each_adcode         VARCHAR(250) DEFAULT NULL;
    DECLARE each_proptype       VARCHAR(250) DEFAULT NULL;
    DECLARE each_code           VARCHAR(250) DEFAULT NULL;
    DECLARE each_pubdate        TIMESTAMP DEFAULT NULL;
    DECLARE each_autobudget     INTEGER DEFAULT NULL;
    DECLARE each_manualday      INTEGER DEFAULT NULL;
    DECLARE each_size           VARCHAR(250) DEFAULT NULL;
    DECLARE each_adstype        VARCHAR(250) DEFAULT NULL;
    DECLARE each_showdays       INTEGER DEFAULT 0;
    DECLARE each_leftdays       INTEGER DEFAULT 0;
    DECLARE each_adrank         INTEGER DEFAULT 0;
    DECLARE each_desktopimage   TEXT DEFAULT NULL;
    DECLARE each_mobileimage    TEXT DEFAULT NULL;
    DECLARE each_link           TEXT DEFAULT NULL;
    DECLARE each_status         VARCHAR(10) DEFAULT '0';
    DECLARE each_temprank       INTEGER DEFAULT 0;
    DECLARE done                INTEGER DEFAULT FALSE;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_update_adds_main';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE total_rows INT DEFAULT 0;

    DECLARE cur_ADS CURSOR FOR 
        SELECT * FROM (
            SELECT AD_ID
                , AD_Code
                , Prop_Type
                , Prop_Code
                , Published_date
                , Auto_AD_Budget
                , Manual_AD_Day
                , Size
                , AD_Type
                , Show_Days
                , Left_Days
                , AD_Rank
                , Manual_Desktop_Image
                , Manual_Mobile_Image
                , Link
                , AD_Status
                , IF ( @r_bann < ads_max_ban() , @r_bann := @r_bann + 1, @r_bann := 200) as temp_rank
            FROM ads_base a
            , (SELECT @r_bann := 0) as t
            WHERE Size = 'Banner'
            and Published_date <= CURDATE()
            and Left_days > 0
            and AD_Status = '1'
            ORDER BY Published_date
        ) as bann
        UNION
        SELECT * FROM (
            SELECT AD_ID
                , AD_Code
                , Prop_Type
                , Prop_Code
                , Published_date
                , Auto_AD_Budget
                , Manual_AD_Day
                , Size
                , AD_Type
                , Show_Days
                , Left_Days
                , AD_Rank
                , Manual_Desktop_Image
                , Manual_Mobile_Image
                , Link
                , AD_Status
                , IF ( @r_bill < ads_max_ban() + ads_max_bill() , @r_bill := @r_bill + 1,@r_bill := 200) as temp_rank
            FROM ads_base a
            , (SELECT @r_bill := ads_max_ban()) as t
            WHERE Size = 'Billboard'
            and Published_date <= CURDATE()
            and Left_days > 0
            and AD_Status = '1'
            ORDER BY Published_date
        ) as bill
        UNION
        select * from (SELECT AD_ID, AD_Code, Prop_Type, Prop_Code, Published_date, Auto_AD_Budget, Manual_AD_Day, Size, AD_Type, Show_Days, Left_Days, AD_Rank, Manual_Desktop_Image, Manual_Mobile_Image, Link, AD_Status, 100 as temp_rank 
                        FROM ads_base 
                        WHERE AD_Type = 'Auto' 
                        and Published_date <= CURDATE()
                        and Left_days > 0 
                        and AD_Status = '1'
                        order by Published_date) as auto
        UNION
        select * from (SELECT AD_ID,'AD_Code' as AD_Code,Prop_Type,Prop_Code, CURDATE() as Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days,Left_Days,AD_Rank,Desktop_Billboard_Image,Mobile_Billboard_Image,Link,AD_Status,150 as temp_rank 
                        FROM ads_default 
                        where AD_Status = '1'
                        order by rand()) as def;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT_WS(' ',msg,'AT',each_code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    set success = FALSE;

    TRUNCATE TABLE ads_cal_today;

    OPEN cur_ADS;

    read_loop: LOOP
        FETCH cur_ADS INTO each_id,each_adcode,each_proptype,each_code,each_pubdate,each_autobudget,each_manualday,each_size,each_adstype,each_showdays,each_leftdays,each_adrank,each_desktopimage,each_mobileimage,each_link,each_status,each_temprank;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            ads_cal_today(
                `AD_ID`,
                `AD_Code`,
                `Prop_Type`,
                `Prop_Code`,
                `Published_date`,
                `Auto_AD_Budget`,
                `Manual_AD_Day`,
                `Size`,
                `AD_Type`,
                `Show_Days`,
                `Left_Days`,
                `AD_Rank`,
                `Manual_Desktop_Image`,
                `Manual_Mobile_Image`,
                `Link`,
                `AD_Status`,
                `temp_rank`
                )
        VALUES(each_id,each_adcode,each_proptype,each_code,each_pubdate,each_autobudget,each_manualday,each_size,each_adstype,each_showdays,each_leftdays,each_adrank,each_desktopimage,each_mobileimage,each_link,each_status,each_temprank);
        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    set success = TRUE;

    CLOSE cur_ADS;
END //
DELIMITER ;

-- ads_calads
DROP PROCEDURE IF EXISTS ads_calads;
DELIMITER //
CREATE PROCEDURE ads_calads (OUT success BOOLEAN)
BEGIN
	DECLARE totalRows	INTEGER		DEFAULT 0;
	DECLARE counter		INTEGER     DEFAULT 1;
	DECLARE id_found	INTEGER		DEFAULT NULL;
    DECLARE code_found	VARCHAR(250)		DEFAULT NULL;
    DECLARE each_id		VARCHAR(250)		DEFAULT NULL;
    DECLARE each_adcode VARCHAR(250)		DEFAULT NULL;
    DECLARE each_rank	INTEGER		DEFAULT 0;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_calads_main';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE total_rows      INT DEFAULT 0;
    DECLARE done                INTEGER DEFAULT FALSE;
		
	DECLARE curAd_ExtraSlot
	CURSOR FOR 
		SELECT AD_ID, AD_Code, IF (same_condo2 > 1, 400, temp_rank) as new_temp_rank
        FROM (SELECT a3.AD_ID, a3.AD_Code, a3.Prop_Type, a3.Prop_Code, a3.Published_date, a3.Auto_AD_Budget, a3.Manual_AD_Day, a3.Size, a3.AD_Type, a3.Show_Days, a3.Left_Days, a3.temp_rank, IF(a3.AD_Type = 'Manual', 1,a3.same_condo) same_condo2 
                from (select * 
                        from (SELECT *, row_number() over (PARTITION by Prop_Code ORDER BY temp_rank, published_date) as same_condo
                                FROM ads_cal_today
                                where AD_Type <> 'Default'
                                order by same_condo, temp_rank, Published_date, AD_ID) a
                        union 
                        select * 
                        from (SELECT *, 1 as same_condo
                                FROM ads_cal_today
                                where AD_Type = 'Default'
                                order by rand()) b) a3 order by same_condo2,published_date) a4
        where IF (same_condo2 > 1, 400, temp_rank) >= 100;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = if(id_found is not null,CONCAT(msg,' AT ',id_found),CONCAT(msg,' AT ',ad_id));
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    set success = FALSE;

	TRUNCATE TABLE ads_cal_slot;

	OPEN curAd_ExtraSlot;
	
	SELECT COUNT(1) INTO totalRows FROM ads_cal_today;	
	SET counter = 1;
	WHILE counter <= totalRows DO
		SELECT AD_ID INTO id_found FROM ads_cal_today WHERE temp_rank = counter;
        SELECT AD_Code INTO code_found FROM ads_cal_today WHERE temp_rank = counter;
        IF id_found IS NOT NULL THEN
            INSERT INTO ads_cal_slot ( slot, ad_id, AD_Code, temp_rank)
			VALUES (counter, id_found, code_found, counter );
        ELSE
            FETCH curAd_ExtraSlot INTO each_id, each_adcode, each_rank;
            INSERT INTO ads_cal_slot ( slot, ad_id, AD_Code, temp_rank)
			VALUES (counter, each_id, each_adcode, each_rank );
        END IF;
		SET counter = counter + 1;
        SET id_found = NULL;
        SET code_found = NULL;
        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
	END WHILE;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    set success = TRUE;

    CLOSE curAd_ExtraSlot;

END //
DELIMITER ;

-- insert ads_log
DROP PROCEDURE IF EXISTS ads_log;
DELIMITER //

CREATE PROCEDURE ads_log (OUT success BOOLEAN)
BEGIN
    DECLARE each_date           DATE DEFAULT NULL;
    DECLARE each_id             VARCHAR(250) DEFAULT NULL;
    DECLARE each_adcode         VARCHAR(250) DEFAULT NULL;
    DECLARE each_slot           INTEGER DEFAULT 0;
    DECLARE each_proptype       VARCHAR(250) DEFAULT NULL;
    DECLARE each_code           VARCHAR(250) DEFAULT NULL;
    DECLARE each_adstype        VARCHAR(250) DEFAULT NULL;
    DECLARE each_size           VARCHAR(250) DEFAULT NULL;
    DECLARE each_name           VARCHAR(250) DEFAULT NULL;
    DECLARE each_dev            VARCHAR(250) DEFAULT NULL;
    DECLARE each_des            TEXT DEFAULT NULL;
    DECLARE each_price          VARCHAR(250) DEFAULT NULL;
    DECLARE each_status         VARCHAR(250) DEFAULT NULL;
    DECLARE each_word           VARCHAR(250) DEFAULT NULL;
    DECLARE each_attribute      TEXT DEFAULT NULL;
    DECLARE each_location       VARCHAR(250) DEFAULT NULL;
    DECLARE each_surrounding    VARCHAR(250) DEFAULT NULL;
    DECLARE each_link           TEXT DEFAULT NULL;
    DECLARE each_desktopimage   TEXT DEFAULT NULL;
    DECLARE each_mobileimage    TEXT DEFAULT NULL;
    DECLARE each_desktoplayout  INTEGER DEFAULT 0;
    DECLARE each_mobilelayout   INTEGER DEFAULT 0;
    DECLARE done                INTEGER DEFAULT FALSE;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_log_main';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE total_rows      INT DEFAULT 0;

    DECLARE cur_ADSLOG CURSOR FOR 
        SELECT * FROM (select CURDATE() as Today
                        , acs.ad_id
                        , acs.AD_Code
                        , acs.slot
                        , ab.Prop_Type
                        , ab.Prop_Code
                        , ab.AD_Type
                        , ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) as Size
                        , if(ab.AD_Type <> 'Auto',ab.Project_Name_Manual_Billboard,ap.Project_Name) as Project_Name
                        , if(ab.AD_Type <> 'Auto',ab.Developer_Manual_Billboard,null) as Developer
                        , if(ab.AD_Type <> 'Auto',ab.Description_Manual_Billboard,null) as Description
                        , if(ab.AD_Type <> 'Auto',null,ap.Price) as Price
                        , if(ab.AD_Type <> 'Auto',null,ap.Project_Status) as Status
                        , if(ab.AD_Type <> 'Auto',null,ap.Word) as Word
                        , if(ab.AD_Type <> 'Auto',null,ap.Attribute) as Attribute
                        , if(ab.AD_Type <> 'Auto',null,ap.Location) as Location
                        , if(ab.AD_Type <> 'Auto',null,ap.Surrounding) as Surrounding
                        , ifnull(ab.Link,ap.Link) as Link
                        , if(ab.AD_Type = 'Manual'
                            ,ab.Manual_Desktop_Image
                            ,if(ab.AD_Type = 'Default'
                                ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                    ,def.Desktop_Banner_Image
                                    ,def.Desktop_Billboard_Image)
                                ,if(if(acs.slot <= ads_max_ban(),'Banner','Billboard') = 'Banner'
                                    ,ap.Banner_Image
                                    ,ap.Desktop_Billboard_Image))) as Desktop_Image
                        , if(ab.AD_Type = 'Manual'
                            ,ab.Manual_Mobile_Image
                            ,if(ab.AD_Type = 'Default'
                                ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                    ,def.Mobile_Banner_Image
                                    ,def.Mobile_Billboard_Image)
                                ,if(if(acs.slot <= ads_max_ban(),'Banner','Billboard') = 'Banner'
                                    ,ap.Banner_Image
                                    ,ap.Mobile_Billboard_Image))) as Mobile_Image
                        , if(ab.AD_Type = 'Auto'
                            ,if((ab.Prop_Type = 'CD' or ab.Prop_Type = 'HP')
                                ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                    ,(select Layout_ID from ads_layouts where Prop_Type like 'CD%' and AD_Type = 'Auto' and Size = 'Banner' and Screen_Size = 'Desktop' order by rand() limit 1)
                                    ,(select Layout_ID from ads_layouts where Prop_Type like 'CD%' and AD_Type = 'Auto' and Size = 'Billboard' and Screen_Size = 'Desktop' order by rand() limit 1))
                                ,if(ab.Prop_Type = 'NR'
                                    ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                        ,(select Layout_ID from ads_layouts where Prop_Type = 'NR' and AD_Type = 'Auto' and Size = 'Banner' and Screen_Size = 'Desktop' order by rand() limit 1)
                                        ,(select Layout_ID from ads_layouts where Prop_Type = 'NR' and AD_Type = 'Auto' and Size = 'Billboard' and Screen_Size = 'Desktop' order by rand() limit 1))
                                    ,if(ab.Prop_Type = 'EV'
                                        ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                            ,(select Layout_ID from ads_layouts where Prop_Type = 'EV' and AD_Type = 'Auto' and Size = 'Banner' and Screen_Size = 'Desktop')
                                            ,(select Layout_ID from ads_layouts where Prop_Type = 'EV' and AD_Type = 'Auto' and Size = 'Billboard' and Screen_Size = 'Desktop'))
                                        ,'00')))
                            ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                ,(select Layout_ID from ads_layouts where AD_Type <> 'Auto' and Size = 'Banner' and Screen_Size = 'Desktop')
                                ,(select Layout_ID from ads_layouts where AD_Type <> 'Auto' and Size = 'Billboard' and Screen_Size = 'Desktop'))) as Desktop_Layout
                        , if(ab.AD_Type = 'Auto'
                            ,if((ab.Prop_Type = 'CD' or ab.Prop_Type = 'HP')
                                ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                    ,(select Layout_ID from ads_layouts where Prop_Type like 'CD%' and AD_Type = 'Auto' and Size = 'Banner' and Screen_Size = 'Mobile' order by rand() limit 1)
                                    ,(select Layout_ID from ads_layouts where Prop_Type like 'CD%' and AD_Type = 'Auto' and Size = 'Billboard' and Screen_Size = 'Mobile' order by rand() limit 1))
                                ,if(ab.Prop_Type = 'NR'
                                    ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                        ,(select Layout_ID from ads_layouts where Prop_Type = 'NR' and AD_Type = 'Auto' and Size = 'Banner' and Screen_Size = 'Mobile' order by rand() limit 1)
                                        ,(select Layout_ID from ads_layouts where Prop_Type = 'NR' and AD_Type = 'Auto' and Size = 'Billboard' and Screen_Size = 'Mobile' order by rand() limit 1))
                                    ,if(ab.Prop_Type = 'EV'
                                        ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                            ,(select Layout_ID from ads_layouts where Prop_Type = 'EV' and AD_Type = 'Auto' and Size = 'Banner' and Screen_Size = 'Mobile')
                                            ,(select Layout_ID from ads_layouts where Prop_Type = 'EV' and AD_Type = 'Auto' and Size = 'Billboard' and Screen_Size = 'Mobile'))
                                        ,'000')))
                            ,if(ifnull(ab.Size,if(acs.slot <= ads_max_ban(),'Banner','Billboard')) = 'Banner'
                                ,(select Layout_ID from ads_layouts where AD_Type <> 'Auto' and Size = 'Banner' and Screen_Size = 'Mobile')
                                ,(select Layout_ID from ads_layouts where AD_Type <> 'Auto' and Size = 'Billboard' and Screen_Size = 'Mobile'))) as Mobile_Layout
                    from ads_cal_slot acs
                    left join ( select *
                                from (  select AD_ID,Prop_Type,Prop_Code,Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days
                                            ,Left_Days,AD_Rank,Project_Name_Manual_Billboard,Developer_Manual_Billboard,Description_Manual_Billboard
                                            ,Manual_Desktop_Image,Manual_Mobile_Image,Link
                                        from ads_base ) as a 
                                union 
                                select *
                                from (  select AD_ID,Prop_Type,Prop_Code,CURDATE() as Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days
                                            ,Left_Days,AD_Rank,Project_Name_Manual_Billboard,Developer_Manual_Billboard,Description_Manual_Billboard
                                            ,Desktop_Billboard_Image,Mobile_Billboard_Image,Link
                                        from ads_default ) as b ) as ab
                    on acs.ad_id = ab.AD_ID
                    left join ads_property_view ap on ab.Prop_Code = ap.Prop_Code
                    left join (select AD_ID,Prop_Type,Prop_Code,CURDATE() as Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days
                                    ,Left_Days,AD_Rank,Project_Name_Manual_Billboard,Developer_Manual_Billboard,Description_Manual_Billboard
                                    ,Desktop_Billboard_Image,Mobile_Billboard_Image,Link,Desktop_Banner_Image,Mobile_Banner_Image
                                from ads_default) def
                    on acs.ad_id = def.AD_ID
                    where acs.slot <= ads_max_ban() + ads_max_bill()
                    order by acs.slot) as insert_ads;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT_WS(' ',msg,'AT',each_code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    set success = FALSE;

    OPEN cur_ADSLOG;

    read_loop: LOOP
        FETCH cur_ADSLOG INTO each_date,each_id,each_adcode,each_slot,each_proptype,each_code,each_adstype,each_size,each_name,each_dev,each_des,each_price,each_status,each_word,each_attribute,each_location,each_surrounding,each_link,each_desktopimage,each_mobileimage,each_desktoplayout,each_mobilelayout;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            ads_log(
                `Log_Date`,
                `AD_ID`,
                `AD_Code`,
                `Prop_Type`,
                `Prop_Code`,
                `AD_Type`,
                `Size`,
                `Project_Name_Manual_Billboard`,
                `Price`,
                `Status`,
                `Word`,
                `Attribute`,
                `Location`,
                `Surrounding`,
                `Link`,
                `Desktop_Image`,
                `Mobile_Image`,
                `AD_Rank`,
                `Developer_Manual_Billboard`,
                `Description_Manual_Billboard`,
                `Desktop_Layout`,
                `Mobile_Layout`
                )
        VALUES(each_date,each_id,each_adcode,each_proptype,each_code,each_adstype,each_size,each_name,each_price,each_status,each_word,each_attribute,each_location,each_surrounding,each_link,each_desktopimage,each_mobileimage,each_slot,each_dev,each_des,each_desktoplayout,each_mobilelayout);
        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    set success = TRUE;

    CLOSE cur_ADSLOG;

    update ads_base
    set AD_Rank = null;

    update ads_base
    join ads_cal_slot on ads_base.AD_ID = ads_cal_slot.ad_id
    set ads_base.AD_Rank = ads_cal_slot.slot,
        ads_base.Last_Update_Date = CURRENT_TIMESTAMP
    where ads_cal_slot.temp_rank <= 100;

END //
DELIMITER ;

-- CALADSS
DROP PROCEDURE IF EXISTS ads_nightly_gen_new_ads;
DELIMITER $$

CREATE PROCEDURE ads_nightly_gen_new_ads ()
BEGIN
    DECLARE check_success BOOLEAN DEFAULT FALSE;

    CALL ads_updateday (check_success) ; -- update show_day,left_day ใน ads_base
    if check_success then
        CALL ads_update_adds (check_success) ; -- เอาทั้งหมดที่ผ่านตัวกรองไปเข้าการคำนวณคิว
    end if;
    if check_success then
        CALL ads_calads (check_success) ; -- คำนวณคิว
    end if;
    if check_success then
        CALL ads_log (check_success) ; -- บันทึกคิวลง log
    end if;

    update ads_base
    left join ads_property_view on ads_base.Prop_Code = ads_property_view.Prop_Code  
    set ads_base.Project_Name = ads_property_view.Project_Name;

END$$
DELIMITER ;

-- manual
DROP PROCEDURE IF EXISTS ads_manually_gen_new_ads;
DELIMITER $$

CREATE PROCEDURE ads_manually_gen_new_ads ()
BEGIN
    DECLARE check_success BOOLEAN DEFAULT FALSE;

    CALL ads_update_adds (check_success) ; -- เอาทั้งหมดที่ผ่านตัวกรองไปเข้าการคำนวณคิว
    CALL ads_calads (check_success) ; -- คำนวณคิว

    delete from ads_log
    where Log_Date = curdate() ;

    CALL ads_log (check_success) ; -- บันทึกคิวลง log

    update ads_base
    left join ads_property_view on ads_base.Prop_Code = ads_property_view.Prop_Code  
    set ads_base.Project_Name = ads_property_view.Project_Name;

END$$
DELIMITER ;