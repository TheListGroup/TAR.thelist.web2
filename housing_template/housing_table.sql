-- Table housing
    -- function check null
    -- cal totalRai
    -- table housing_around_station
    -- table housing_around_express_way
    -- table housing_popular_carousel
    -- table housing_spotlight
    -- mass_transit_line
    -- table housing_factsheet_view
    -- table housing_fetch_for_map
    -- table housing_article_fetch_for_map

-- function check null
DELIMITER //
CREATE FUNCTION h_nun(nan VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = if(nan='','N/A',ifnull(nan,'N/A'));
    RETURN unit;
END //

-- table housing_around_station
CREATE TABLE IF NOT EXISTS housing_around_station (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Station_Code VARCHAR(50) NOT NULL,
    Station_THName_Display VARCHAR(200) NULL,
    Route_Code VARCHAR(30) NOT NULL,
    Line_Code VARCHAR(30) NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_around_express_way
CREATE TABLE IF NOT EXISTS housing_around_express_way (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Place_ID INT UNSIGNED NOT NULL,
    Place_Attribute_1 VARCHAR(150) NOT NULL,
    Place_Attribute_2 VARCHAR(150) NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_popular_carousel
CREATE TABLE housing_popular_carousel (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    housing_type ENUM('Home','SD','DD','TH','HO','SH'),
    popular_type VARCHAR(30) NOT NULL,
    popular_Code VARCHAR(30) NOT NULL,
    flipboard_display_list INT NOT NULL,
    PRIMARY KEY (id))
ENGINE = InnoDB;

insert into housing_popular_carousel (housing_type, popular_type, popular_Code, flipboard_display_list)
values ('Home','Custom','CUS007',1)
    , ('Home','Custom','CUS008',2)
    , ('Home','Spotlight','PS005',3)
    , ('Home','Custom','CUS024',4)
    , ('Home','Spotlight','PS003',5)
    , ('Home','Spotlight','PS006',6)
    , ('Home','Spotlight','PS007',7)
    , ('Home','Spotlight','PS013',8)
    , ('Home','Spotlight','PS009',9)
    , ('Home','Spotlight','PS011',10)
    , ('Home','Spotlight','PS002',11)
    , ('Home','Spotlight','PS021',12)
    , ('Home','Spotlight','PS022',13)
    , ('Home','Spotlight','PS004',14)
    , ('Home','Custom','CUS046',15)
    , ('Home','Custom','CUS047',16)
    , ('Home','Custom','CUS048',17)
    , ('Home','Spotlight','PS023',18)
    , ('Home','Custom','CUS039',19)
    , ('Home','Custom','CUS040',20)
    , ('Home','Spotlight','PS019',21)
    , ('SD','Custom','CUS007',1)
    , ('SD','Custom','CUS008',2)
    , ('SD','Spotlight','PS005',3)
    , ('SD','Custom','CUS024',4)
    , ('SD','Spotlight','PS003',5)
    , ('SD','Spotlight','PS006',6)
    , ('SD','Spotlight','PS007',7)
    , ('SD','Spotlight','PS013',8)
    , ('SD','Spotlight','PS009',9)
    , ('SD','Spotlight','PS011',10)
    , ('SD','Spotlight','PS002',11)
    , ('SD','Spotlight','PS021',12)
    , ('SD','Spotlight','PS022',13)
    , ('SD','Spotlight','PS004',14)
    , ('SD','Custom','CUS046',15)
    , ('SD','Custom','CUS047',16)
    , ('SD','Custom','CUS048',17)
    , ('SD','Spotlight','PS023',18)
    , ('SD','Custom','CUS039',19)
    , ('SD','Custom','CUS040',20)
    , ('SD','Spotlight','PS019',21)
    , ('DD','Custom','CUS007',1)
    , ('DD','Custom','CUS008',2)
    , ('DD','Spotlight','PS005',3)
    , ('DD','Custom','CUS024',4)
    , ('DD','Spotlight','PS003',5)
    , ('DD','Spotlight','PS006',6)
    , ('DD','Spotlight','PS007',7)
    , ('DD','Spotlight','PS013',8)
    , ('DD','Spotlight','PS009',9)
    , ('DD','Spotlight','PS011',10)
    , ('DD','Spotlight','PS002',11)
    , ('DD','Spotlight','PS021',12)
    , ('DD','Spotlight','PS022',13)
    , ('DD','Spotlight','PS004',14)
    , ('DD','Custom','CUS046',15)
    , ('DD','Custom','CUS047',16)
    , ('DD','Custom','CUS048',17)
    , ('DD','Spotlight','PS023',18)
    , ('DD','Custom','CUS039',19)
    , ('DD','Custom','CUS040',20)
    , ('DD','Spotlight','PS019',21)
    , ('TH','Custom','CUS007',1)
    , ('TH','Custom','CUS008',2)
    , ('TH','Spotlight','PS005',3)
    , ('TH','Custom','CUS024',4)
    , ('TH','Spotlight','PS003',5)
    , ('TH','Spotlight','PS006',6)
    , ('TH','Spotlight','PS007',7)
    , ('TH','Spotlight','PS013',8)
    , ('TH','Spotlight','PS009',9)
    , ('TH','Spotlight','PS011',10)
    , ('TH','Spotlight','PS002',11)
    , ('TH','Spotlight','PS021',12)
    , ('TH','Spotlight','PS022',13)
    , ('TH','Spotlight','PS004',14)
    , ('TH','Custom','CUS046',15)
    , ('TH','Custom','CUS047',16)
    , ('TH','Custom','CUS048',17)
    , ('TH','Spotlight','PS023',18)
    , ('TH','Custom','CUS039',19)
    , ('TH','Custom','CUS040',20)
    , ('TH','Spotlight','PS019',21)
    , ('HO','Custom','CUS007',1)
    , ('HO','Custom','CUS008',2)
    , ('HO','Spotlight','PS005',3)
    , ('HO','Custom','CUS024',4)
    , ('HO','Spotlight','PS003',5)
    , ('HO','Spotlight','PS006',6)
    , ('HO','Spotlight','PS007',7)
    , ('HO','Spotlight','PS013',8)
    , ('HO','Spotlight','PS009',9)
    , ('HO','Spotlight','PS011',10)
    , ('HO','Spotlight','PS002',11)
    , ('HO','Spotlight','PS021',12)
    , ('HO','Spotlight','PS022',13)
    , ('HO','Spotlight','PS004',14)
    , ('HO','Custom','CUS046',15)
    , ('HO','Custom','CUS047',16)
    , ('HO','Custom','CUS048',17)
    , ('HO','Spotlight','PS023',18)
    , ('HO','Custom','CUS039',19)
    , ('HO','Custom','CUS040',20)
    , ('HO','Spotlight','PS019',21)
    , ('SH','Custom','CUS007',1)
    , ('SH','Custom','CUS008',2)
    , ('SH','Spotlight','PS005',3)
    , ('SH','Custom','CUS024',4)
    , ('SH','Spotlight','PS003',5)
    , ('SH','Spotlight','PS006',6)
    , ('SH','Spotlight','PS007',7)
    , ('SH','Spotlight','PS013',8)
    , ('SH','Spotlight','PS009',9)
    , ('SH','Spotlight','PS011',10)
    , ('SH','Spotlight','PS002',11)
    , ('SH','Spotlight','PS021',12)
    , ('SH','Spotlight','PS022',13)
    , ('SH','Spotlight','PS004',14)
    , ('SH','Custom','CUS046',15)
    , ('SH','Custom','CUS047',16)
    , ('SH','Custom','CUS048',17)
    , ('SH','Spotlight','PS023',18)
    , ('SH','Custom','CUS039',19)
    , ('SH','Custom','CUS040',20)
    , ('SH','Spotlight','PS019',21);

-- table housing_spotlight
CREATE TABLE housing_spotlight (
    Spotlight_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Spotlight_Order int NOT NULL,
    Spotlight_Type varchar(20) NOT NULL,
    Spotlight_Code varchar(20) NOT NULL,
    Spotlight_Name varchar(150) NOT NULL,
    Spotlight_Label varchar(200) NOT NULL,
    Spotlight_Icon varchar(200) NOT NULL,
    Spotlight_Inactive int NOT NULL,
    Housing_Count int NOT NULL,
    Housing_Count_SD int NOT NULL,
    Housing_Count_DD int NOT NULL,
    Housing_Count_TH int NOT NULL,
    Housing_Count_HO int NOT NULL,
    Housing_Count_SH int NOT NULL,
    Menu_List int NOT NULL,
    Menu_Price_Order int NOT NULL,
    Spotlight_Cover int NOT NULL,
    Spotlight_Title varchar(250) NOT NULL,
    Spotlight_Description text NOT NULL,
    Keyword_TH text null,
    Keyword_ENG text null,
    PRIMARY KEY (Spotlight_ID))
ENGINE = InnoDB;

INSERT INTO housing_spotlight (Spotlight_Order, Spotlight_Type, Spotlight_Code, Spotlight_Name, Spotlight_Label, Spotlight_Icon
                                , Spotlight_Inactive, Housing_Count, Housing_Count_SD, Housing_Count_DD, Housing_Count_TH
                                , Housing_Count_HO, Housing_Count_SH , Menu_List, Menu_Price_Order, Spotlight_Cover
                                , Spotlight_Title, Spotlight_Description, Keyword_TH, Keyword_ENG) 
VALUES (0, 'custom', 'CUS001', 'บ้านเดี่ยว', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านเดี่ยว', '', NULL, NULL)
    , (0, 'custom', 'CUS002', 'บ้านแฝด', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านแฝด', '', NULL, NULL)
    , (0, 'custom', 'CUS003', 'ทาวน์โฮม', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'ทาวน์โฮม', '', NULL, NULL)
    , (0, 'custom', 'CUS004', 'โฮมออฟฟิศ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โฮมออฟฟิศ', '', NULL, NULL)
    , (0, 'custom', 'CUS005', 'อาคารพาณิชย์', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'อาคารพาณิชย์', '', NULL, NULL)
    , (0, 'custom', 'CUS006', 'บ้านต่ำล้าน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านต่ำล้าน', '', NULL, NULL)
    , (0, 'custom', 'CUS007', 'โครงการ 1 - 2 ล้านบาท', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 1-2 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS008', 'โครงการ 2 - 5 ล้านบาท', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 2-5 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS009', 'โครงการ 5 - 10 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 5-10 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS010', 'โครงการ 10 - 20 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 10-20 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS011', 'โครงการ 20 - 40 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 20-40 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS012', 'โครงการ 40 - 60 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 40-60 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS013', 'โครงการ 60 - 80 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 60-80 ล้านบาท', '', NULL, NULL)
    , (0, 'custom', 'CUS014', 'โครงการ 80 ล้านบาทขึ้นไป', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ 80 ล้านบาทขึ้นไป', '', NULL, NULL)
    , (0, 'custom', 'CUS015', 'โครงการเปิดตัว 2001-2010', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการเปิดตัว 2001-2010', '', NULL, NULL)
    , (0, 'custom', 'CUS016', 'โครงการเปิดตัว 2011-2020', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการเปิดตัว 2011-2020', '', NULL, NULL)
    , (0, 'custom', 'CUS017', 'โครงการเปิดตัว 2021', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการเปิดตัว 2021', '', NULL, NULL)
    , (0, 'custom', 'CUS018', 'โครงการเปิดตัว 2022', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการเปิดตัว 2022', '', NULL, NULL)
    , (0, 'custom', 'CUS019', 'โครงการเปิดตัว 2023', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการเปิดตัว 2023', '', NULL, NULL)
    , (0, 'custom', 'CUS020', 'โครงการเปิดตัว 2024', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการเปิดตัว 2024', '', NULL, NULL)
    , (0, 'custom', 'CUS021', 'โครงการที่กำลังเปิดขาย', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการที่กำลังเปิดขาย', '', NULL, NULL)
    , (0, 'custom', 'CUS022', 'โครงการ Resale', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการ Resale', '', NULL, NULL)
    , (0, 'custom', 'CUS023', 'โครงการพร้อมอยู่', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการพร้อมอยู่', '', NULL, NULL)
    , (0, 'custom', 'CUS024', 'โครงการใหม่', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการใหม่', '', NULL, NULL)
    , (0, 'custom', 'CUS025', '16-34 ตร.ว.', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '16-34 ตร.ว.', '', NULL, NULL)
    , (0, 'custom', 'CUS026', '34-50 ตร.ว.', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '34-50 ตร.ว.', '', NULL, NULL)
    , (0, 'custom', 'CUS027', '50-100 ตร.ว.', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '50-100 ตร.ว.', '', NULL, NULL)
    , (0, 'custom', 'CUS028', '100 ตร.ว. ขึ้นไป', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '100 ตร.ว. ขึ้นไป', '', NULL, NULL)
    , (0, 'custom', 'CUS029', '2 ห้องนอน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2 ห้องนอน', '', NULL, NULL)
    , (0, 'custom', 'CUS030', '3 ห้องนอน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '3 ห้องนอน', '', NULL, NULL)
    , (0, 'custom', 'CUS031', '4 ห้องนอน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '4 ห้องนอน', '', NULL, NULL)
    , (0, 'custom', 'CUS032', '5 ห้องนอนขึ้นไป', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5 ห้องนอนขึ้นไป', '', NULL, NULL)
    , (0, 'custom', 'CUS039', 'บ้านใกล้ ธรรมศาสตร์ รังสิต', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ธรรมศาสตร์ รังสิต', '', NULL, NULL)
    , (0, 'custom', 'CUS040', 'บ้านใกล้ ม.มหิดล ศาลายา', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ม.มหิดล ศาลายา', '', NULL, NULL)
    , (0, 'custom', 'CUS041', 'บ้านใกล้ ม.เกษตร บางเขนฯ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ม.เกษตร บางเขนฯ', '', NULL, NULL)
    , (0, 'custom', 'CUS042', 'บ้านใกล้ ม.กรุงเทพฯ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ม.กรุงเทพฯ', '', NULL, NULL)
    , (0, 'custom', 'CUS043', 'บ้านใกล้ ม.หอการค้าไทย', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ม.หอการค้าไทย', '', NULL, NULL)
    , (0, 'custom', 'CUS044', 'บ้านใกล้ ม.รามคำแหง', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ม.รามคำแหง', '', NULL, NULL)
    , (0, 'custom', 'CUS045', 'บ้านใกล้ ม.ธุรกิจบัณฑิต', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ ม.ธุรกิจบัณฑิต', '', NULL, NULL)
    , (0, 'custom', 'CUS046', 'บ้านใกล้สถานี BTS', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สถานี BTS', '', NULL, NULL)
    , (0, 'custom', 'CUS047', 'บ้านใกล้สถานี MRT', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สถานี MRT', '', NULL, NULL)
    , (0, 'custom', 'CUS048', 'บ้านใกล้สถานี Airport Link', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สถานี Airport Link', '', NULL, NULL)
    , (1, 'spotlight', 'PS001', 'บ้านที่ดินใหญ่', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านที่ดินใหญ่', '', NULL, NULL)
    , (2, 'spotlight', 'PS002', 'บ้านพื้นที่ใช้สอยเยอะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านพื้นที่ใช้สอยเยอะ', '', NULL, NULL)
    , (3, 'spotlight', 'PS003', 'โครงการบ้านหรู', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการบ้านหรู', '', NULL, NULL)
    , (4, 'spotlight', 'PS004', 'โครงการยูนิตน้อย', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'โครงการยูนิตน้อย', '', NULL, NULL)
    , (5, 'spotlight', 'PS005', 'บ้านใจกลางเมือง', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใจกลางเมือง', '', NULL, NULL)
    , (6, 'spotlight', 'PS006', 'บ้านใกล้ทางด่วน', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ทางด่วน', '', NULL, NULL)
    , (7, 'spotlight', 'PS007', 'บ้านใกล้สถานีรถไฟฟ้า', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สถานีรถไฟฟ้า', '', NULL, NULL)
    , (8, 'spotlight', 'PS008', 'บ้านใกล้สถานี Interchange', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สถานี Interchange', '', NULL, NULL)
    , (9, 'spotlight', 'PS009', 'บ้านใกล้ศูนย์การค้า', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้ศูนย์การค้า', '', NULL, NULL)
    , (10, 'spotlight', 'PS010', 'บ้านใกล้โรงเรียน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้โรงเรียน', '', NULL, NULL)
    , (11, 'spotlight', 'PS011', 'บ้านใกล้โรงเรียนนานาชาติ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้โรงเรียนนานาชาติ', '', NULL, NULL)
    , (12, 'spotlight', 'PS012', 'บ้านใกล้มหาวิทยาลัย', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้มหาวิทยาลัย', '', NULL, NULL)
    , (13, 'spotlight', 'PS013', 'บ้านใกล้สวนสาธารณะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สวนสาธารณะ', '', NULL, NULL)
    , (14, 'spotlight', 'PS014', 'บ้านใกล้สวนเบญจกิติ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สวนเบญจกิติ', '', NULL, NULL)
    , (15, 'spotlight', 'PS015', 'บ้านใกล้สวนจตุจักร', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สวนจตุจักร', '', NULL, NULL)
    , (16, 'spotlight', 'PS016', 'บ้านใกล้สวนหลวงร.9', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สวนหลวงร.9', '', NULL, NULL)
    , (17, 'spotlight', 'PS017', 'บ้านใกล้สวนลุม', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สวนลุม', '', NULL, NULL)
    , (18, 'spotlight', 'PS018', 'บ้านใกล้สนามบินดอนเมือง', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สนามบินดอนเมือง', '', NULL, NULL)
    , (19, 'spotlight', 'PS019', 'บ้านใกล้สุวรรณภูมิ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้สุวรรณภูมิ', '', NULL, NULL)
    , (20, 'spotlight', 'PS020', 'บ้านริมน้ำ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านริมน้ำ', '', NULL, NULL)
    , (21, 'spotlight', 'PS021', 'บ้านที่จอดรถเยอะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านที่จอดรถเยอะ', '', NULL, NULL)
    , (22, 'spotlight', 'PS022', 'บ้านห้องนอนเยอะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านห้องนอนเยอะ', '', NULL, NULL)
    , (23, 'spotlight', 'PS023', 'บ้านใกล้โรงพยาบาล', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'บ้านใกล้โรงพยาบาล', '', NULL, NULL);

-- mass_transit_line
ALTER TABLE mass_transit_line ADD MTrand_ID INT NULL AFTER Line_Name;
update mass_transit_line set MTrand_ID = 1 where Line_Code in ('LINE01','LINE02','LINE11');
update mass_transit_line set MTrand_ID = 2 where Line_Code in ('LINE04','LINE05','LINE06','LINE07','LINE10','LINE12','LINE13');
update mass_transit_line set MTrand_ID = 3 where Line_Code in ('LINE09');

-- -----------------------------------------------------
-- Table housing
---- รอเพิ่ม column คะแนน
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS housing (
    Housing_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Name VARCHAR(250) NULL DEFAULT NULL,
    Housing_ENName VARCHAR(250) NULL DEFAULT NULL,
    Brand_Code VARCHAR(10) NULL DEFAULT NULL,
    Developer_Code VARCHAR(30) NULL DEFAULT NULL,
    Housing_Latitude DOUBLE NULL DEFAULT NULL,
    Housing_Longitude DOUBLE NULL DEFAULT NULL,
    Coordinate_Mark SMALLINT NOT NULL,
    Housing_ScopeArea TEXT NULL DEFAULT NULL,
    Road_Name VARCHAR(50) NULL DEFAULT NULL,
    Postal_Code INT NULL DEFAULT NULL,
    SubDistrict_ID INT NULL DEFAULT NULL,
    District_ID INT NULL DEFAULT NULL,
    Province_ID INT NULL DEFAULT NULL,
    Address_Mark SMALLINT NOT NULL, 
    RealSubDistrict_Code VARCHAR(30) NULL DEFAULT NULL,
    RealDistrict_Code VARCHAR(30) NULL DEFAULT NULL,
    Housing_LandRai FLOAT(10,5) NULL DEFAULT NULL,
    Housing_LandNgan FLOAT(10,5) NULL DEFAULT NULL,
    Housing_LandWa FLOAT(10,5) NULL DEFAULT NULL,
    Housing_TotalRai FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Floor_Min INT NULL DEFAULT NULL,
    Housing_Floor_Max INT NULL DEFAULT NULL,
    Housing_TotalUnit INT NULL DEFAULT NULL,
    Housing_Area_Min FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Area_Max FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Usable_Area_Min FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Usable_Area_Max FLOAT(10,5) NULL DEFAULT NULL,
    Bedroom_Min INT NULL DEFAULT NULL,
    Bedroom_Max INT NULL DEFAULT NULL,
    Bathroom_Min INT NULL DEFAULT NULL,
    Bathroom_Max INT NULL DEFAULT NULL,
    Housing_Price_Min INT NULL DEFAULT NULL,
    Housing_Price_Max INT NULL DEFAULT NULL,
    Housing_Price_Date DATE NULL DEFAULT NULL,
    Housing_Built_Start DATE NULL DEFAULT NULL,
    Housing_Built_Finished DATE NULL DEFAULT NULL,
    Housing_Sold_Status_Raw_Number FLOAT NULL DEFAULT NULL,
    Housing_Sold_Status_Date DATE NULL DEFAULT NULL,
    Housing_Parking_Min INT NULL DEFAULT NULL,
    Housing_Parking_Max INT NULL DEFAULT NULL,
    Housing_Common_Fee_Min INT NULL DEFAULT NULL,
    Housing_Common_Fee_Max INT NULL DEFAULT NULL,
    IS_SD BOOLEAN NOT NULL DEFAULT 0,
    IS_DD BOOLEAN NOT NULL DEFAULT 0,
    IS_TH BOOLEAN NOT NULL DEFAULT 0,
    IS_HO BOOLEAN NOT NULL DEFAULT 0,
    IS_SH BOOLEAN NOT NULL DEFAULT 0,
    Housing_Spotlight_1 VARCHAR(250) NULL,
    Housing_Spotlight_2 VARCHAR(250) NULL,
    Realist_Score DECIMAL(44,12) NULL,
    Housing_URL_Tag VARCHAR(200) NULL DEFAULT NULL,
    Housing_Cover BOOLEAN NOT NULL DEFAULT 0,
    Housing_Redirect VARCHAR(10) NULL DEFAULT NULL,
    Housing_Pageviews INT NOT NULL DEFAULT 0,
    Housing_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Housing_ID),
    INDEX housing_admin1 (Created_By),
    INDEX housing_admin2 (Last_Updated_By),
    INDEX housing_housing_code (Housing_Code),
    INDEX housing_lat (Housing_Latitude),
    INDEX housing_long (Housing_Longitude),
    INDEX housing_brand (Brand_Code),
    INDEX housing_dev (Developer_Code),
    INDEX housing_subdistrict (SubDistrict_ID),
    INDEX housing_district (District_ID),
    INDEX housing_province (Province_ID),
    INDEX housing_realsubdistrict (RealSubDistrict_Code),
    INDEX housing_realdistrict (RealDistrict_Code),
    CONSTRAINT home_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT home_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- cal totalRai
update real_housing
set Housing_TotalRai = (Housing_LandNgan*100) + Housing_LandWa / 400 + Housing_LandRai;

-- table housing_factsheet_view
CREATE TABLE IF NOT EXISTS housing_factsheet_view (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Area VARCHAR(30) NOT NULL,
    Usable_Area VARCHAR(30) NOT NULL,
    Bedroom VARCHAR(20) NOT NULL,
    Price_Date VARCHAR(4) NULL,
    Price VARCHAR(30) NOT NULL,
    Express_Way VARCHAR(250) NOT NULL,
    RealDistrict VARCHAR(150) NOT NULL,
    District VARCHAR(150) NOT NULL,
    Province VARCHAR(150) NOT NULL,
    Housing_Type VARCHAR(70) NOT NULL,
    Housing_TotalRai VARCHAR(20) NOT NULL,
    TotalUnit VARCHAR(10) NOT NULL,
    Housing_Built_Start VARCHAR(4) NOT NULL,
    Housing_Sold_Status_Date VARCHAR(4) NULL,
    Housing_Sold_Status VARCHAR(10) NOT NULL,
    Floor VARCHAR(20) NOT NULL,
    Bedroom_Factsheet VARCHAR(20) NOT NULL,
    Bathroom VARCHAR(20) NOT NULL,
    Parking_Amount VARCHAR(20) NOT NULL,
    Price_Date_Factsheet VARCHAR(4) NULL,
    Price_Factsheet VARCHAR(30) NOT NULL,
    Housing_Area_Factsheet VARCHAR(30) NOT NULL,
    Usable_Area_Factsheet VARCHAR(30) NOT NULL,
    Common_Fee VARCHAR(50) NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_fetch_for_map
CREATE TABLE IF NOT EXISTS housing_fetch_for_map (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_ID INT UNSIGNED NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_ENName VARCHAR(250) NULL,
    Housing_Type VARCHAR(70) NOT NULL,
    Price VARCHAR(30) NOT NULL,
    Housing_Area VARCHAR(30) NOT NULL,
    Usable_Area VARCHAR(30) NOT NULL,
    Housing_Build_Date DATE NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(250) NULL,
    Housing_ScopeArea TEXT NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    Brand_Code VARCHAR(10) NULL,
    Developer_Code VARCHAR(30) NULL,
    RealSubDistrict_Code VARCHAR(30) NULL,
    RealDistrict_Code VARCHAR(30) NULL,
    SubDistrict_ID INT NULL,
    District_ID INT NULL,
    Province_ID INT NULL,
    Housing_URL_Tag VARCHAR(200) NULL,
    Housing_Cover BOOLEAN NOT NULL DEFAULT 0,
    Express_Way Text NULL,
    Station Text NULL,
    Total_Point DOUBLE NOT NULL DEFAULT 0,
    Housing_Age INT NULL,
    Housing_Area_Min FLOAT NULL,
    Housing_Area_Max FLOAT NULL,
    Usable_Area_Min FLOAT NULL,
    Usable_Area_Max FLOAT NULL,
    Price_Min INT NULL,
    Price_Max INT NULL,
    Price_Carousel VARCHAR(30) NULL,
    Housing_Area_Carousel VARCHAR(30) NULL,
    Usable_Area_Carousel VARCHAR(30) NULL,
    Housing_Around_Line TEXT NULL,
    Spotlight_List TEXT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_article_fetch_for_map
CREATE TABLE IF NOT EXISTS housing_article_fetch_for_map (
    ID_Prime INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_ID INT UNSIGNED NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_ENName VARCHAR(250) NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(250) NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    ID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    post_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    post_name VARCHAR(200) NOT NULL,
    post_title MEDIUMTEXT NOT NULL,
    RealDistrict_Code VARCHAR(30) NULL,
    RealSubDistrict_Code VARCHAR(30) NULL,
    Province_ID INT NULL,
    PRIMARY KEY (ID_Prime))
ENGINE = InnoDB;