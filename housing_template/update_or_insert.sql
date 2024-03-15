-- insert housing_spotlight
-- update Spotlight_Description
-- insert housing_popular_carousel
-- real_yarn_main
-- real_yarn_sub
-- thailand_province
-- housing_article

-- insert housing_spotlight
INSERT INTO housing_spotlight (Spotlight_Order, Spotlight_Type, Spotlight_Code, Spotlight_Name, Spotlight_Label, Spotlight_Icon
                                , Spotlight_Inactive, Housing_Count, Housing_Count_SD, Housing_Count_DD, Housing_Count_TH
                                , Housing_Count_HO, Housing_Count_SH , Menu_List, Menu_Price_Order, Spotlight_Cover
                                , Spotlight_Title, Spotlight_Description, Keyword_TH, Keyword_ENG) 
VALUES (0, 'custom', 'CUS001', 'บ้านเดี่ยว', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านเดี่ยว | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS002', 'บ้านแฝด', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านแฝด | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS003', 'ทาวน์โฮม', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมทาวน์โฮม | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS004', 'โฮมออฟฟิศ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโฮมออฟฟิศ | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS005', 'อาคารพาณิชย์', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมอาคารพาณิชย์ | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS006', 'บ้านต่ำล้าน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านต่ำล้าน | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS007', 'โครงการ 1 - 2 ล้านบาท', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 1-2 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS008', 'โครงการ 2 - 5 ล้านบาท', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 2-5 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS009', 'โครงการ 5 - 10 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 5-10 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS010', 'โครงการ 10 - 20 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 10-20 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS011', 'โครงการ 20 - 40 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 20-40 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS012', 'โครงการ 40 - 60 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 40-60 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS013', 'โครงการ 60 - 80 ล้านบาท', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 60-80 ล้านบาท | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS014', 'โครงการ 80 ล้านบาทขึ้นไป', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ 80 ล้านบาทขึ้นไป | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS015', 'โครงการเปิดตัว 2001-2010', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการเปิดตัว 2001-2010 | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS016', 'โครงการเปิดตัว 2011-2020', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการเปิดตัว 2011-2020 | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS017', 'โครงการเปิดตัว 2021', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการเปิดตัว 2021 | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS018', 'โครงการเปิดตัว 2022', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการเปิดตัว 2022 | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS019', 'โครงการเปิดตัว 2023', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการเปิดตัว 2023 | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS020', 'โครงการเปิดตัว 2024', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการเปิดตัว 2024 | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS021', 'โครงการที่กำลังเปิดขาย', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการที่กำลังเปิดขาย | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS022', 'โครงการ Resale', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการ Resale | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS023', 'โครงการพร้อมอยู่', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการพร้อมอยู่ | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS024', 'โครงการใหม่', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการใหม่ | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS025', '16-34 ตร.ว.', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการขนาดที่ดิน 16-34 ตร.ว. | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS026', '34-50 ตร.ว.', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการขนาดที่ดิน 34-50 ตร.ว. | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS027', '50-100 ตร.ว.', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการขนาดที่ดิน 50-100 ตร.ว. | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS028', '100 ตร.ว. ขึ้นไป', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการขนาดที่ดิน 100 ตร.ว. ขึ้นไป | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS029', '2 ห้องนอน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้าน 2 ห้องนอน | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS030', '3 ห้องนอน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้าน 3 ห้องนอน | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS031', '4 ห้องนอน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้าน 4 ห้องนอน | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS032', '5 ห้องนอนขึ้นไป', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้าน 5 ห้องนอนขึ้นไป | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS039', 'บ้านใกล้ ธรรมศาสตร์ รังสิต', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ธรรมศาสตร์ รังสิต | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS040', 'บ้านใกล้ ม.มหิดล ศาลายา', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ม.มหิดล ศาลายา | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS041', 'บ้านใกล้ ม.เกษตร บางเขนฯ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ม.เกษตร บางเขนฯ | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS042', 'บ้านใกล้ ม.กรุงเทพฯ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ม.กรุงเทพฯ | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS043', 'บ้านใกล้ ม.หอการค้าไทย', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ม.หอการค้าไทย | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS044', 'บ้านใกล้ ม.รามคำแหง', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ม.รามคำแหง | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS045', 'บ้านใกล้ ม.ธุรกิจบัณฑิต', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ ม.ธุรกิจบัณฑิต | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS046', 'บ้านใกล้สถานี BTS', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สถานี BTS | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS047', 'บ้านใกล้สถานี MRT', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สถานี MRT | REAL DATA', '', NULL, NULL)
    , (0, 'custom', 'CUS048', 'บ้านใกล้สถานี Airport Link', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สถานี Airport Link | REAL DATA', '', NULL, NULL)
    , (1, 'spotlight', 'PS001', 'บ้านที่ดินใหญ่', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านที่ดินใหญ่ | REAL DATA', '', NULL, NULL)
    , (2, 'spotlight', 'PS002', 'บ้านพื้นที่ใช้สอยเยอะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านพื้นที่ใช้สอยเยอะ | REAL DATA', '', NULL, NULL)
    , (3, 'spotlight', 'PS003', 'โครงการบ้านหรู', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการบ้านหรู | REAL DATA', '', NULL, NULL)
    , (4, 'spotlight', 'PS004', 'โครงการยูนิตน้อย', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมโครงการยูนิตน้อย | REAL DATA', '', NULL, NULL)
    , (5, 'spotlight', 'PS005', 'บ้านใจกลางเมือง', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใจกลางเมือง | REAL DATA', '', NULL, NULL)
    , (6, 'spotlight', 'PS006', 'บ้านใกล้ทางด่วน', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ทางด่วน | REAL DATA', '', NULL, NULL)
    , (7, 'spotlight', 'PS007', 'บ้านใกล้สถานีรถไฟฟ้า', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สถานีรถไฟฟ้า | REAL DATA', '', NULL, NULL)
    , (8, 'spotlight', 'PS008', 'บ้านใกล้สถานี Interchange', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สถานี Interchange | REAL DATA', '', NULL, NULL)
    , (9, 'spotlight', 'PS009', 'บ้านใกล้ศูนย์การค้า', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้ศูนย์การค้า | REAL DATA', '', NULL, NULL)
    , (10, 'spotlight', 'PS010', 'บ้านใกล้โรงเรียน', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้โรงเรียน | REAL DATA', '', NULL, NULL)
    , (11, 'spotlight', 'PS011', 'บ้านใกล้โรงเรียนนานาชาติ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้โรงเรียนนานาชาติ | REAL DATA', '', NULL, NULL)
    , (12, 'spotlight', 'PS012', 'บ้านใกล้มหาวิทยาลัย', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้มหาวิทยาลัย | REAL DATA', '', NULL, NULL)
    , (13, 'spotlight', 'PS013', 'บ้านใกล้สวนสาธารณะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สวนสาธารณะ | REAL DATA', '', NULL, NULL)
    , (14, 'spotlight', 'PS014', 'บ้านใกล้สวนเบญจกิติ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สวนเบญจกิติ | REAL DATA', '', NULL, NULL)
    , (15, 'spotlight', 'PS015', 'บ้านใกล้สวนจตุจักร', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สวนจตุจักร | REAL DATA', '', NULL, NULL)
    , (16, 'spotlight', 'PS016', 'บ้านใกล้สวนหลวงร.9', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สวนหลวงร.9 | REAL DATA', '', NULL, NULL)
    , (17, 'spotlight', 'PS017', 'บ้านใกล้สวนลุม', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สวนลุม | REAL DATA', '', NULL, NULL)
    , (18, 'spotlight', 'PS018', 'บ้านใกล้สนามบินดอนเมือง', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สนามบินดอนเมือง | REAL DATA', '', NULL, NULL)
    , (19, 'spotlight', 'PS019', 'บ้านใกล้สุวรรณภูมิ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้สุวรรณภูมิ | REAL DATA', '', NULL, NULL)
    , (20, 'spotlight', 'PS020', 'บ้านริมน้ำ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านริมน้ำ | REAL DATA', '', NULL, NULL)
    , (21, 'spotlight', 'PS021', 'บ้านที่จอดรถเยอะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านที่จอดรถเยอะ | REAL DATA', '', NULL, NULL)
    , (22, 'spotlight', 'PS022', 'บ้านห้องนอนเยอะ', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านห้องนอนเยอะ | REAL DATA', '', NULL, NULL)
    , (23, 'spotlight', 'PS023', 'บ้านใกล้โรงพยาบาล', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'รวมบ้านใกล้โรงพยาบาล | REAL DATA', '', NULL, NULL);

-- update Spotlight_Description
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านราคาถูก ทั้งบ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ ในราคา 1-2 ล้านบาท ทุกแบรนด์ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS007';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ ในราคา 2-5 ล้านบาท มาพร้อมข้อมูลราคาของแต่ละโซน แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS008';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการใหม่ ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ ทุกระดับราคา ทุกแบรนด์ มาพร้อมข้อมูล แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS024';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้าน ใกล้ ม.ธรรมศาสตร์ ศูนย์รังสิต ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS039';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้าน ใกล้ ม.มหิดล ศาลายา ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS040';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝด ทาวน์โฮม ใกล้สถานีรถไฟฟ้า BTS เดินทางสะดวก มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS046';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ใกล้สถานีรถไฟฟ้า MRT เดินทางสะดวก มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS047';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ใกล้สถานีรถไฟฟ้า Airport Link เดินทางสะดวก มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS048';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ทุกระดับราคา ทุกแบรนด์ ที่มีพื้นที่ใช้สอยมากกว่า 400 ตร.ม. ขึ้นไป พร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS002';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านหรู Luxury ราคา 30 ล้านบาทขึ้นไป บนทำเลศักยภาพ ทั้งโครงการใหม่ และพร้อมอยู่ รวมทุกแบรนด์ พร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS003';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านยูนิตน้อย ให้ความเป็นส่วนตัว และเน้นความ Privacy ตอบโจทย์คนชอบความเงียบสงบ พร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS004';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ใจกลางเมือง โซนกรุงเทพชั้นใน (CBD-Downtown) มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS005';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านทำเลดี ใกล้ทางด่วน เดินทางสะดวก ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS006';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ทำเลดี ใกล้สถานีรถไฟฟ้า BTS, MRT และ Airport Link ทุกสถานี เดินทางสะดวก มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS007';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านทำเลดี ใกล้ศูนย์การค้า ห้างสรรพสินค้า เอาใจสายช้อป ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS009';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ทุกแบรนด์ ทำเลดี ใกล้โรงเรียนนานาชาติชั้นนำ พร้อมข้อมูลราคาทั้งโครงการใหม่ พร้อมอยู่ ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS011';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ทุกแบรนด์ ทำเลดี ใกล้มหาวิทยาลัย พร้อมข้อมูลราคา ทั้งโครงการใหม่ โครงการพร้อมอยู่ ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS012';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมโครงการบ้านเดี่ยว บ้านแฝดและทาวน์โฮม ใกล้สนามบินสุวรรณภูมิ เดินทางสะดวก มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS019';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านที่มีจอดรถเยอะ เอาใจคนรักรถ ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS021';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านหลายห้องนอน (4 ห้องนอนขึ้นไป) ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS022';
update housing_spotlight set Spotlight_Description = 'REAL DATA รวมข้อมูลโครงการบ้านทำเลดี ใกล้โรงพยาบาล ทั้งบ้านเดี่ยว บ้านแฝด ทาวน์โฮม และโฮมออฟฟิศ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS023';

update `housing_spotlight` set Spotlight_Description_Start = 'REAL DATA รวมข้อมูลโครงการ';

update housing_spotlight set Spotlight_Description_End = 'ราคาถูก ในราคา 1-2 ล้านบาท ทุกแบรนด์ ทั้งโครงการใหม่และโครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS007';
update housing_spotlight set Spotlight_Description_End = 'ในราคา 2-5 ล้านบาท ทั้งโครงการใหม่และโครงการพร้อมอยู่ มาพร้อมข้อมูลราคาของแต่ละโซน และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS008';
update housing_spotlight set Spotlight_Description_End = 'เปิดใหม่ล่าสุด ทุกแบรนด์ ทุกระดับราคาของแต่ละโซน มาพร้อมข้อมูล และแผนที่ ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS024';
update housing_spotlight set Spotlight_Description_End = 'ใกล้ ม.ธรรมศาสตร์ ศูนย์รังสิต ทั้งโครงการใหม่และโครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS039';
update housing_spotlight set Spotlight_Description_End = 'ใกล้ ม.มหิดล ศาลายา ทั้งโครงการใหม่และโครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS040';
update housing_spotlight set Spotlight_Description_End = 'ใกล้สถานีรถไฟฟ้า BTS เดินทางสะดวก ทั้งโครงการใหม่ โครงการพร้อมอยู่ พร้อมข้อมูล ราคา ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS046';
update housing_spotlight set Spotlight_Description_End = 'ใกล้สถานีรถไฟฟ้า MRT เดินทางสะดวก ทั้งโครงการใหม่ โครงการพร้อมอยู่ พร้อมข้อมูล ราคา ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS047';
update housing_spotlight set Spotlight_Description_End = 'ใกล้สถานีรถไฟฟ้า Airport Link เดินทางสะดวก ทั้งโครงการใหม่ โครงการพร้อมอยู่ พร้อมข้อมูล ราคา ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'CUS048';
update housing_spotlight set Spotlight_Description_End = 'บ้านใหญ่ ที่มีพื้นที่ใช้สอยมากกว่า 400 ตร.ม. ขึ้นไป ทั้งโครงการใหม่และโครงการพร้อมอยู่ พร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS002';
update housing_spotlight set Spotlight_Description_End = 'หรู สุด Luxury ในราคา 30 ล้านบาทขึ้นไป ทั้งโครงการใหม่และพร้อมอยู่ ทุกแบรนด์ พร้อมข้อมูลราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS003';
update housing_spotlight set Spotlight_Description_End = 'ยูนิตน้อย ให้ความเป็นส่วนตัว และเน้นความ Privacy ตอบโจทย์คนชอบความเงียบสงบ พร้อมข้อมูลราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS004';
update housing_spotlight set Spotlight_Description_End = 'ใจกลางเมือง โซนกรุงเทพชั้นใน (CBD-Downtown) ทั้งโครงการใหม่ โครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS005';
update housing_spotlight set Spotlight_Description_End = 'ทำเลดี ใกล้ทางด่วน เดินทางสะดวก ทั้งโครงการใหม่และโครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS006';
update housing_spotlight set Spotlight_Description_End = 'ทำเลดี เดินทางสะดวก ใกล้สถานีรถไฟฟ้า BTS, MRT และ Airport Link ทุกสถานี มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS007';
update housing_spotlight set Spotlight_Description_End = 'ทำเลดี ใกล้ศูนย์การค้า ห้างสรรพสินค้า เอาใจสายช้อป มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS009';
update housing_spotlight set Spotlight_Description_End = 'ทุกแบรนด์ ทำเลดี ใกล้โรงเรียนนานาชาติชั้นนำ ทุกระดับราคาของแต่ละโซน ทั้งโครงการใหม่ พร้อมอยู่ ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS011';
update housing_spotlight set Spotlight_Description_End = 'ทุกแบรนด์ ทำเลดี ใกล้มหาวิทยาลัย ทุกระดับราคาของแต่ละโซน ทั้งโครงการใหม่ โครงการพร้อมอยู่ ไปจนถึงสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS012';
update housing_spotlight set Spotlight_Description_End = 'ทุกแบรนด์ ใกล้สนามบินสุวรรณภูมิ เดินทางสะดวก ทั้งโครงการใหม่ โครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS019';
update housing_spotlight set Spotlight_Description_End = 'ที่มีจอดรถเยอะ เอาใจคนรักรถ ทั้งโครงการใหม่และโครงการพร้อมอยู่ มาพร้อมข้อมูล ราคา แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS021';
update housing_spotlight set Spotlight_Description_End = 'หลายห้องนอน (4 ห้องนอนขึ้นไป) ทุกแบรนด์ มาพร้อมข้อมูลระดับราคาของแต่ละโซน แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS022';
update housing_spotlight set Spotlight_Description_End = 'ทำเลดี ใกล้โรงพยาบาล ทุกแบรนด์ มาพร้อมข้อมูลระดับราคาของแต่ละโซน แผนที่ และสิ่งอำนวยความสะดวกที่อยู่ใกล้เคียง' where Spotlight_Code = 'PS023';


-- insert housing_popular_carousel
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

-- real_yarn_main
ALTER TABLE real_yarn_main ADD Housing_Count INT NOT NULL AFTER Condo_Count;

-- real_yarn_sub
ALTER TABLE real_yarn_sub ADD Housing_Count INT NOT NULL AFTER Condo_Count;

-- thailand_province
ALTER TABLE thailand_province ADD Housing_Count INT NOT NULL AFTER Condo_Count;

-- housing_article
insert into wp_postmeta (post_id, meta_key, meta_value)
values (4682,'aaa_housing','HP4280'),
        (10940,'aaa_housing','HP4047'),
        (11528,'aaa_housing','HP4303'),
        (12340,'aaa_housing','HP4264'),
        (16745,'aaa_housing','HP3537'),
        (17278,'aaa_housing','HP5062'),
        (17788,'aaa_housing','HP4229'),
        (19740,'aaa_housing','HP5389'),
        (19835,'aaa_housing','HP3989'),
        (19935,'aaa_housing','HP4467'),
        (19974,'aaa_housing','HP4207'),
        (22097,'aaa_housing','HP2256'),
        (22244,'aaa_housing','HP4465'),
        (23587,'aaa_housing','HP1749'),
        (23828,'aaa_housing','HP4394'),
        (24165,'aaa_housing','HP4863'),
        (24383,'aaa_housing','HP4372'),
        (25029,'aaa_housing','HP2506'),
        (26076,'aaa_housing','HP2271'),
        (26724,'aaa_housing','HP1993'),
        (27299,'aaa_housing','HP3808'),
        (28393,'aaa_housing','HP4903'),
        (29073,'aaa_housing','HP4411'),
        (29172,'aaa_housing','HP3286'),
        (29353,'aaa_housing','HP3987'),
        (29752,'aaa_housing','HP2360'),
        (30528,'aaa_housing','HP4129'),
        (31149,'aaa_housing','HP4053'),
        (32288,'aaa_housing','HP4017'),
        (33664,'aaa_housing','HP4457'),
        (36930,'aaa_housing','HP0380'),
        (37589,'aaa_housing','HP3169'),
        (38783,'aaa_housing','HP1676'),
        (39204,'aaa_housing','HP4699'),
        (41913,'aaa_housing','HP3980'),
        (41949,'aaa_housing','HP2199'),
        (42481,'aaa_housing','HP3610'),
        (45453,'aaa_housing','HP4514'),
        (46930,'aaa_housing','HP1319'),
        (53895,'aaa_housing','HP3453'),
        (57220,'aaa_housing','HP3515'),
        (57358,'aaa_housing','HP3839'),
        (58285,'aaa_housing','HP3552'),
        (58548,'aaa_housing','HP4140'),
        (60529,'aaa_housing','HP3584'),
        (60848,'aaa_housing','HP3630'),
        (62316,'aaa_housing','HP4058'),
        (63813,'aaa_housing','HP3852'),
        (65773,'aaa_housing','HP3820'),
        (65797,'aaa_housing','HP4134'),
        (66746,'aaa_housing','HP3451'),
        (67062,'aaa_housing','HP3169'),
        (67419,'aaa_housing','HP4139'),
        (67638,'aaa_housing','HP3370'),
        (70857,'aaa_housing','HP3422'),
        (71576,'aaa_housing','HP1336'),
        (74587,'aaa_housing','HP3855'),
        (76129,'aaa_housing','HP0010'),
        (76181,'aaa_housing','HP3980'),
        (77938,'aaa_housing','HP3305'),
        (79226,'aaa_housing','HP2651'),
        (80591,'aaa_housing','HP3101'),
        (80858,'aaa_housing','HP3380'),
        (82461,'aaa_housing','HP3554'),
        (84314,'aaa_housing','HP3187'),
        (84860,'aaa_housing','HP2075'),
        (85731,'aaa_housing','HP2655'),
        (86464,'aaa_housing','HP1560'),
        (90733,'aaa_housing','HP2912'),
        (90818,'aaa_housing','HP3086'),
        (91138,'aaa_housing','HP2700'),
        (91796,'aaa_housing','HP3169'),
        (91823,'aaa_housing','HP1412'),
        (92727,'aaa_housing','HP1986'),
        (92996,'aaa_housing','HP3215'),
        (95552,'aaa_housing','HP3499'),
        (95703,'aaa_housing','HP3289'),
        (96156,'aaa_housing','HP0227'),
        (96494,'aaa_housing','HP2197'),
        (97046,'aaa_housing','HP3093'),
        (97174,'aaa_housing','HP3067'),
        (97449,'aaa_housing','HP3560'),
        (98215,'aaa_housing','HP2966'),
        (98229,'aaa_housing','HP2943'),
        (98891,'aaa_housing','HP2652'),
        (99003,'aaa_housing','HP2233'),
        (104314,'aaa_housing','HP2349'),
        (108171,'aaa_housing','HP3056'),
        (108657,'aaa_housing','HP2733'),
        (108907,'aaa_housing','HP3551'),
        (109536,'aaa_housing','HP2712'),
        (110060,'aaa_housing','HP4140'),
        (111074,'aaa_housing','HP2691'),
        (111594,'aaa_housing','HP2811'),
        (112006,'aaa_housing','HP2506'),
        (114660,'aaa_housing','HP4004'),
        (115308,'aaa_housing','HP2323'),
        (116374,'aaa_housing','HP2819'),
        (118243,'aaa_housing','HP2199'),
        (118563,'aaa_housing','HP2691'),
        (119136,'aaa_housing','HP3544'),
        (119506,'aaa_housing','HP3499'),
        (121021,'aaa_housing','HP2448'),
        (121368,'aaa_housing','HP1984'),
        (122595,'aaa_housing','HP2342'),
        (123742,'aaa_housing','HP2590'),
        (124210,'aaa_housing','HP3135'),
        (124902,'aaa_housing','HP3283'),
        (125475,'aaa_housing','HP2523'),
        (126747,'aaa_housing','HP2532'),
        (127806,'aaa_housing','HP2407'),
        (128253,'aaa_housing','HP3121'),
        (128395,'aaa_housing','HP2323'),
        (128669,'aaa_housing','HP2312'),
        (129441,'aaa_housing','HP0081'),
        (130421,'aaa_housing','HP1855'),
        (131241,'aaa_housing','HP2312'),
        (131429,'aaa_housing','HP1927'),
        (131553,'aaa_housing','HP1980'),
        (131727,'aaa_housing','HP1953'),
        (131789,'aaa_housing','HP3163'),
        (131884,'aaa_housing','HP5781'),
        (132014,'aaa_housing','HP3931'),
        (132193,'aaa_housing','HP3069'),
        (133144,'aaa_housing','HP4856'),
        (133196,'aaa_housing','HP1466'),
        (133627,'aaa_housing','HP3389'),
        (134518,'aaa_housing','HP1856'),
        (135192,'aaa_housing','HP2832'),
        (135254,'aaa_housing','HP1933'),
        (136157,'aaa_housing','HP2142'),
        (137039,'aaa_housing','HP1214'),
        (137872,'aaa_housing','HP1783'),
        (138389,'aaa_housing','HP1523'),
        (138800,'aaa_housing','HP3089'),
        (139099,'aaa_housing','HP1187'),
        (139660,'aaa_housing','HP5459'),
        (139883,'aaa_housing','HP1406'),
        (139981,'aaa_housing','HP3547'),
        (140119,'aaa_housing','HP3770'),
        (140426,'aaa_housing','HP2120'),
        (140735,'aaa_housing','HP2349'),
        (141368,'aaa_housing','HP0072'),
        (141519,'aaa_housing','HP1754'),
        (142054,'aaa_housing','HP3148'),
        (142505,'aaa_housing','HP1703'),
        (142905,'aaa_housing','HP2320'),
        (143240,'aaa_housing','HP4352'),
        (143402,'aaa_housing','HP0805'),
        (144288,'aaa_housing','HP2424'),
        (144772,'aaa_housing','HP1414'),
        (145524,'aaa_housing','HP1910'),
        (145866,'aaa_housing','HP2650'),
        (146607,'aaa_housing','HP4733'),
        (147209,'aaa_housing','HP3612'),
        (147767,'aaa_housing','HP3391'),
        (148120,'aaa_housing','HP2693'),
        (148480,'aaa_housing','HP3206'),
        (148931,'aaa_housing','HP2072'),
        (149647,'aaa_housing','HP1742'),
        (149819,'aaa_housing','HP2448'),
        (151093,'aaa_housing','HP1280'),
        (151581,'aaa_housing','HP1761'),
        (151970,'aaa_housing','HP2679'),
        (152194,'aaa_housing','HP2010'),
        (152552,'aaa_housing','HP1589'),
        (153342,'aaa_housing','HP2106'),
        (153874,'aaa_housing','HP1630'),
        (154992,'aaa_housing','HP1348'),
        (155499,'aaa_housing','HP3474'),
        (155652,'aaa_housing','HP1545'),
        (155703,'aaa_housing','HP1087'),
        (155973,'aaa_housing','HP1927'),
        (155994,'aaa_housing','HP1769'),
        (156039,'aaa_housing','HP2340'),
        (158262,'aaa_housing','HP1339'),
        (158330,'aaa_housing','HP1287'),
        (158366,'aaa_housing','HP1760'),
        (159364,'aaa_housing','HP3374'),
        (159540,'aaa_housing','HP1419'),
        (160101,'aaa_housing','HP1404'),
        (160173,'aaa_housing','HP1253'),
        (160855,'aaa_housing','HP1400'),
        (160896,'aaa_housing','HP2788'),
        (161750,'aaa_housing','HP2352'),
        (161754,'aaa_housing','HP1847'),
        (161757,'aaa_housing','HP1847'),
        (161767,'aaa_housing','HP2741'),
        (161976,'aaa_housing','HP2436'),
        (162444,'aaa_housing','HP2712'),
        (163218,'aaa_housing','HP1434'),
        (163554,'aaa_housing','HP2842'),
        (164063,'aaa_housing','HP1231'),
        (165135,'aaa_housing','HP1325'),
        (165161,'aaa_housing','HP1767'),
        (165187,'aaa_housing','HP1303'),
        (165204,'aaa_housing','HP3252'),
        (165206,'aaa_housing','HP1325'),
        (165726,'aaa_housing','HP1221'),
        (165763,'aaa_housing','HP1782'),
        (165956,'aaa_housing','HP1285'),
        (165958,'aaa_housing','HP2348'),
        (166353,'aaa_housing','HP1192'),
        (166757,'aaa_housing','HP0796'),
        (167540,'aaa_housing','HP1842'),
        (168223,'aaa_housing','HP1195'),
        (168257,'aaa_housing','HP1348'),
        (168708,'aaa_housing','HP1329'),
        (169981,'aaa_housing','HP0404'),
        (170139,'aaa_housing','HP0811'),
        (170369,'aaa_housing','HP1782'),
        (170389,'aaa_housing','HP1241'),
        (171415,'aaa_housing','HP1110'),
        (171520,'aaa_housing','HP3091'),
        (171547,'aaa_housing','HP1130'),
        (172113,'aaa_housing','HP1770'),
        (172171,'aaa_housing','HP1207'),
        (172205,'aaa_housing','HP0110'),
        (172222,'aaa_housing','HP2424'),
        (172234,'aaa_housing','HP1735'),
        (172355,'aaa_housing','HP1675'),
        (173640,'aaa_housing','HP1575'),
        (173674,'aaa_housing','HP1466'),
        (173911,'aaa_housing','HP1060'),
        (176818,'aaa_housing','HP3135'),
        (176992,'aaa_housing','HP1695'),
        (177448,'aaa_housing','HP1115'),
        (177813,'aaa_housing','HP1466'),
        (177879,'aaa_housing','HP1400'),
        (177961,'aaa_housing','HP2822'),
        (178315,'aaa_housing','HP1119'),
        (178419,'aaa_housing','HP1978'),
        (178904,'aaa_housing','HP1158'),
        (179138,'aaa_housing','HP2418'),
        (179214,'aaa_housing','HP2921'),
        (180133,'aaa_housing','HP1119'),
        (180597,'aaa_housing','HP1032'),
        (180635,'aaa_housing','HP0725'),
        (180797,'aaa_housing','HP1010'),
        (180879,'aaa_housing','HP1700'),
        (181920,'aaa_housing','HP0237'),
        (181968,'aaa_housing','HP0931'),
        (182053,'aaa_housing','HP1111'),
        (182704,'aaa_housing','HP1009'),
        (183123,'aaa_housing','HP1003'),
        (183302,'aaa_housing','HP0999'),
        (183351,'aaa_housing','HP2266'),
        (183397,'aaa_housing','HP0883'),
        (183409,'aaa_housing','HP1560'),
        (183966,'aaa_housing','HP0271'),
        (183969,'aaa_housing','HP0733'),
        (184663,'aaa_housing','HP0110'),
        (185165,'aaa_housing','HP1695'),
        (186104,'aaa_housing','HP0876'),
        (186113,'aaa_housing','HP3122'),
        (186617,'aaa_housing','HP0757'),
        (186639,'aaa_housing','HP0362'),
        (187168,'aaa_housing','HP0874'),
        (187388,'aaa_housing','HP0840'),
        (187692,'aaa_housing','HP1024'),
        (187802,'aaa_housing','HP0699'),
        (188038,'aaa_housing','HP0818'),
        (189035,'aaa_housing','HP0774'),
        (189079,'aaa_housing','HP0242'),
        (189630,'aaa_housing','HP0964'),
        (189740,'aaa_housing','HP0907'),
        (190049,'aaa_housing','HP0926'),
        (190231,'aaa_housing','HP1847'),
        (190256,'aaa_housing','HP0876'),
        (190329,'aaa_housing','HP1984'),
        (190342,'aaa_housing','HP0989'),
        (190915,'aaa_housing','HP1286'),
        (191092,'aaa_housing','HP0876'),
        (191178,'aaa_housing','HP0962'),
        (191402,'aaa_housing','HP1004'),
        (191563,'aaa_housing','HP0600'),
        (191998,'aaa_housing','HP3499'),
        (192230,'aaa_housing','HP0674'),
        (192283,'aaa_housing','HP3091'),
        (192392,'aaa_housing','HP0678'),
        (192458,'aaa_housing','HP0840'),
        (192486,'aaa_housing','HP0760'),
        (192907,'aaa_housing','HP1109'),
        (193528,'aaa_housing','HP0678'),
        (193688,'aaa_housing','HP2477'),
        (193922,'aaa_housing','HP0916'),
        (194502,'aaa_housing','HP0469'),
        (194746,'aaa_housing','HP0269'),
        (194783,'aaa_housing','HP0188'),
        (195112,'aaa_housing','HP0719'),
        (195878,'aaa_housing','HP1026'),
        (195998,'aaa_housing','HP1121'),
        (196069,'aaa_housing','HP0876'),
        (196661,'aaa_housing','HP3097'),
        (196694,'aaa_housing','HP0772'),
        (196935,'aaa_housing','HP0918'),
        (197629,'aaa_housing','HP0399'),
        (198231,'aaa_housing','HP0999'),
        (198430,'aaa_housing','HP0554'),
        (198585,'aaa_housing','HP0510'),
        (198758,'aaa_housing','HP0566'),
        (198950,'aaa_housing','HP0787'),
        (199477,'aaa_housing','HP0269'),
        (199527,'aaa_housing','HP0763'),
        (199660,'aaa_housing','HP3097'),
        (199669,'aaa_housing','HP0373'),
        (200029,'aaa_housing','HP1055'),
        (200157,'aaa_housing','HP1111'),
        (200243,'aaa_housing','HP0678'),
        (200255,'aaa_housing','HP0566'),
        (200471,'aaa_housing','HP0231'),
        (200539,'aaa_housing','HP1026'),
        (200684,'aaa_housing','HP0373'),
        (200786,'aaa_housing','HP0554'),
        (200845,'aaa_housing','HP0189'),
        (200926,'aaa_housing','HP0258'),
        (201450,'aaa_housing','HP0633'),
        (202154,'aaa_housing','HP0685'),
        (202214,'aaa_housing','HP0194'),
        (203084,'aaa_housing','HP0099'),
        (203115,'aaa_housing','HP0522'),
        (203902,'aaa_housing','HP0373'),
        (204600,'aaa_housing','HP0373'),
        (204607,'aaa_housing','HP0469'),
        (204629,'aaa_housing','HP0633'),
        (205046,'aaa_housing','HP0076'),
        (205065,'aaa_housing','HP0182'),
        (205196,'aaa_housing','HP1028'),
        (205452,'aaa_housing','HP0763'),
        (207330,'aaa_housing','HP1700'),
        (207458,'aaa_housing','HP2457'),
        (207913,'aaa_housing','HP1927'),
        (208346,'aaa_housing','HP0469'),
        (208833,'aaa_housing','HP1208'),
        (209237,'aaa_housing','HP0206'),
        (209290,'aaa_housing','HP0297'),
        (209333,'aaa_housing','HP1570'),
        (209632,'aaa_housing','HP2356'),
        (209645,'aaa_housing','HP0064'),
        (209852,'aaa_housing','HP0497'),
        (210114,'aaa_housing','HP1570'),
        (210138,'aaa_housing','HP4470'),
        (210331,'aaa_housing','HP0154'),
        (210826,'aaa_housing','HP0583'),
        (210871,'aaa_housing','HP0293'),
        (211215,'aaa_housing','HP0508'),
        (211393,'aaa_housing','HP0140'),
        (211889,'aaa_housing','HP0469'),
        (211928,'aaa_housing','HP0383'),
        (212416,'aaa_housing','HP0203'),
        (212422,'aaa_housing','HP0009'),
        (212572,'aaa_housing','HP0063'),
        (212919,'aaa_housing','HP0289'),
        (213160,'aaa_housing','HP0002'),
        (213382,'aaa_housing','HP0898'),
        (213626,'aaa_housing','HP0377'),
        (213785,'aaa_housing','HP0271'),
        (213795,'aaa_housing','HP0170'),
        (213877,'aaa_housing','HP0012'),
        (214058,'aaa_housing','HP0646'),
        (214320,'aaa_housing','HP0170'),
        (214637,'aaa_housing','HP0721'),
        (215010,'aaa_housing','HP0721'),
        (86385,'aaa_housing','HP3604'),
        (209570,'aaa_housing','HP0061'),
        (214948,'aaa_housing','HP0825'),
        (11528,'aaa_housing','HP2694'),
        (16745,'aaa_housing','HP4753'),
        (17278,'aaa_housing','HP4339'),
        (17788,'aaa_housing','HP4395'),
        (19740,'aaa_housing','HP1694'),
        (19835,'aaa_housing','HP4339'),
        (19935,'aaa_housing','HP4452'),
        (19974,'aaa_housing','HP4423'),
        (22097,'aaa_housing','HP2258'),
        (22244,'aaa_housing','HP1187'),
        (23587,'aaa_housing','HP1775'),
        (23828,'aaa_housing','HP4257'),
        (24165,'aaa_housing','HP4934'),
        (24383,'aaa_housing','HP4885'),
        (26076,'aaa_housing','HP3421'),
        (29073,'aaa_housing','HP3997'),
        (29172,'aaa_housing','HP5426'),
        (29353,'aaa_housing','HP4394'),
        (29752,'aaa_housing','HP4508'),
        (32288,'aaa_housing','HP3989'),
        (53895,'aaa_housing','HP3590'),
        (76129,'aaa_housing','HP0147'),
        (79226,'aaa_housing','HP2725'),
        (82461,'aaa_housing','HP3589'),
        (84860,'aaa_housing','HP2360'),
        (86464,'aaa_housing','HP3558'),
        (97449,'aaa_housing','HP2842'),
        (108657,'aaa_housing','HP4441'),
        (109536,'aaa_housing','HP2733'),
        (111074,'aaa_housing','HP2719'),
        (112006,'aaa_housing','HP3533'),
        (119136,'aaa_housing','HP2086'),
        (121021,'aaa_housing','HP2423'),
        (121368,'aaa_housing','HP3089'),
        (124210,'aaa_housing','HP2086'),
        (131553,'aaa_housing','HP2691'),
        (133627,'aaa_housing','HP1560'),
        (137039,'aaa_housing','HP1912'),
        (139883,'aaa_housing','HP1491'),
        (140119,'aaa_housing','HP5519'),
        (142505,'aaa_housing','HP1583'),
        (142905,'aaa_housing','HP1716'),
        (144772,'aaa_housing','HP3807'),
        (145866,'aaa_housing','HP2113'),
        (146607,'aaa_housing','HP2394'),
        (147767,'aaa_housing','HP3630'),
        (148931,'aaa_housing','HP2532'),
        (151093,'aaa_housing','HP1325'),
        (151970,'aaa_housing','HP1751'),
        (153342,'aaa_housing','HP3051'),
        (155499,'aaa_housing','HP2356'),
        (155703,'aaa_housing','HP1712'),
        (156039,'aaa_housing','HP1583'),
        (158262,'aaa_housing','HP1434'),
        (160896,'aaa_housing','HP2949'),
        (162444,'aaa_housing','HP2340'),
        (163554,'aaa_housing','HP2810'),
        (165135,'aaa_housing','HP1247'),
        (165204,'aaa_housing','HP1641'),
        (166353,'aaa_housing','HP1345'),
        (168223,'aaa_housing','HP5266'),
        (168708,'aaa_housing','HP2418'),
        (169981,'aaa_housing','HP3073'),
        (170139,'aaa_housing','HP1319'),
        (171520,'aaa_housing','HP2691'),
        (171547,'aaa_housing','HP1853'),
        (172205,'aaa_housing','HP1325'),
        (178904,'aaa_housing','HP1065'),
        (179214,'aaa_housing','HP3135'),
        (180635,'aaa_housing','HP1116'),
        (182704,'aaa_housing','HP0472'),
        (183409,'aaa_housing','HP2691'),
        (184663,'aaa_housing','HP1325'),
        (186104,'aaa_housing','HP0719'),
        (187168,'aaa_housing','HP1704'),
        (190231,'aaa_housing','HP1226'),
        (190329,'aaa_housing','HP1051'),
        (190915,'aaa_housing','HP0627'),
        (191402,'aaa_housing','HP1125'),
        (192283,'aaa_housing','HP1111'),
        (196694,'aaa_housing','HP1128'),
        (198231,'aaa_housing','HP0337'),
        (199527,'aaa_housing','HP0770'),
        (200471,'aaa_housing','HP0508'),
        (200926,'aaa_housing','HP0239'),
        (205452,'aaa_housing','HP0646'),
        (209333,'aaa_housing','HP1184'),
        (209632,'aaa_housing','HP1158'),
        (213877,'aaa_housing','HP0014'),
        (209570,'aaa_housing','HP0346'),
        (16745,'aaa_housing','HP1749'),
        (17278,'aaa_housing','HP5631'),
        (17788,'aaa_housing','HP3962'),
        (19740,'aaa_housing','HP5649'),
        (19835,'aaa_housing','HP4152'),
        (19935,'aaa_housing','HP5702'),
        (22244,'aaa_housing','HP4358'),
        (23587,'aaa_housing','HP4862'),
        (24165,'aaa_housing','HP5343'),
        (24383,'aaa_housing','HP4723'),
        (26076,'aaa_housing','HP1415'),
        (29073,'aaa_housing','HP2257'),
        (29172,'aaa_housing','HP4021'),
        (29353,'aaa_housing','HP4257'),
        (29752,'aaa_housing','HP4320'),
        (53895,'aaa_housing','HP3380'),
        (76129,'aaa_housing','HP3169'),
        (82461,'aaa_housing','HP4358'),
        (84860,'aaa_housing','HP4454'),
        (86464,'aaa_housing','HP3187'),
        (97449,'aaa_housing','HP2912'),
        (108657,'aaa_housing','HP3115'),
        (111074,'aaa_housing','HP1980'),
        (119136,'aaa_housing','HP3135'),
        (121021,'aaa_housing','HP1491'),
        (121368,'aaa_housing','HP2330'),
        (124210,'aaa_housing','HP3544'),
        (131553,'aaa_housing','HP2719'),
        (133627,'aaa_housing','HP2733'),
        (142905,'aaa_housing','HP3271'),
        (144772,'aaa_housing','HP3324'),
        (145866,'aaa_housing','HP2108'),
        (146607,'aaa_housing','HP2392'),
        (147767,'aaa_housing','HP3584'),
        (151093,'aaa_housing','HP1727'),
        (151970,'aaa_housing','HP1768'),
        (153342,'aaa_housing','HP2117'),
        (155499,'aaa_housing','HP1972'),
        (156039,'aaa_housing','HP2712'),
        (160896,'aaa_housing','HP1852'),
        (162444,'aaa_housing','HP2365'),
        (163554,'aaa_housing','HP2427'),
        (165135,'aaa_housing','HP1329'),
        (165204,'aaa_housing','HP1211'),
        (166353,'aaa_housing','HP1716'),
        (168708,'aaa_housing','HP3422'),
        (171520,'aaa_housing','HP1851'),
        (171547,'aaa_housing','HP1704'),
        (172205,'aaa_housing','HP3187'),
        (178904,'aaa_housing','HP1142'),
        (179214,'aaa_housing','HP2086'),
        (180635,'aaa_housing','HP0861'),
        (182704,'aaa_housing','HP0771'),
        (183409,'aaa_housing','HP3091'),
        (184663,'aaa_housing','HP3187'),
        (186104,'aaa_housing','HP0554'),
        (187168,'aaa_housing','HP3058'),
        (190231,'aaa_housing','HP0527'),
        (190329,'aaa_housing','HP1706'),
        (190915,'aaa_housing','HP1279'),
        (192283,'aaa_housing','HP2691'),
        (196694,'aaa_housing','HP1285'),
        (198231,'aaa_housing','HP0861'),
        (199527,'aaa_housing','HP0915'),
        (200926,'aaa_housing','HP0348'),
        (209333,'aaa_housing','HP0394'),
        (209632,'aaa_housing','HP1065'),
        (16745,'aaa_housing','HP4358'),
        (17278,'aaa_housing','HP5502'),
        (19835,'aaa_housing','HP4156'),
        (19935,'aaa_housing','HP3298'),
        (24165,'aaa_housing','HP1749'),
        (26076,'aaa_housing','HP2325'),
        (29073,'aaa_housing','HP4903'),
        (29172,'aaa_housing','HP5763'),
        (29353,'aaa_housing','HP3282'),
        (29752,'aaa_housing','HP5696'),
        (53895,'aaa_housing','HP3389'),
        (84860,'aaa_housing','HP1498'),
        (86464,'aaa_housing','HP3056'),
        (97449,'aaa_housing','HP3365'),
        (111074,'aaa_housing','HP1280'),
        (121021,'aaa_housing','HP2741'),
        (124210,'aaa_housing','HP3297'),
        (133627,'aaa_housing','HP3187'),
        (144772,'aaa_housing','HP3241'),
        (145866,'aaa_housing','HP1855'),
        (146607,'aaa_housing','HP3807'),
        (151093,'aaa_housing','HP3169'),
        (151970,'aaa_housing','HP2418'),
        (153342,'aaa_housing','HP2324'),
        (156039,'aaa_housing','HP1703'),
        (160896,'aaa_housing','HP2326'),
        (162444,'aaa_housing','HP0110'),
        (163554,'aaa_housing','HP3561'),
        (165135,'aaa_housing','HP1247'),
        (165204,'aaa_housing','HP1067'),
        (166353,'aaa_housing','HP2320'),
        (168708,'aaa_housing','HP1751'),
        (171547,'aaa_housing','HP2810'),
        (172205,'aaa_housing','HP0172'),
        (179214,'aaa_housing','HP3297'),
        (180635,'aaa_housing','HP1038'),
        (184663,'aaa_housing','HP1116'),
        (190231,'aaa_housing','HP0940'),
        (190329,'aaa_housing','HP0110'),
        (192283,'aaa_housing','HP1560'),
        (196694,'aaa_housing','HP2853'),
        (198231,'aaa_housing','HP2365'),
        (199527,'aaa_housing','HP0680'),
        (209333,'aaa_housing','HP0585'),
        (209632,'aaa_housing','HP1219'),
        (16745,'aaa_housing','HP1746'),
        (17278,'aaa_housing','HP1279'),
        (24165,'aaa_housing','HP5434'),
        (29073,'aaa_housing','HP4814'),
        (29752,'aaa_housing','HP4152'),
        (53895,'aaa_housing','HP1560'),
        (84860,'aaa_housing','HP4580'),
        (86464,'aaa_housing','HP2719'),
        (97449,'aaa_housing','HP2844'),
        (111074,'aaa_housing','HP1727'),
        (144772,'aaa_housing','HP3575'),
        (146607,'aaa_housing','HP3800'),
        (151970,'aaa_housing','HP3453'),
        (153342,'aaa_housing','HP1742'),
        (156039,'aaa_housing','HP1885'),
        (162444,'aaa_housing','HP3187'),
        (163554,'aaa_housing','HP2327'),
        (165135,'aaa_housing','HP1245'),
        (165204,'aaa_housing','HP1365'),
        (166353,'aaa_housing','HP3194'),
        (168708,'aaa_housing','HP1768'),
        (172205,'aaa_housing','HP1280'),
        (179214,'aaa_housing','HP5525'),
        (180635,'aaa_housing','HP0732'),
        (184663,'aaa_housing','HP1064'),
        (196694,'aaa_housing','HP2049'),
        (198231,'aaa_housing','HP2340'),
        (199527,'aaa_housing','HP0646'),
        (209632,'aaa_housing','HP0069'),
        (16745,'aaa_housing','HP1415'),
        (29073,'aaa_housing','HP2256'),
        (53895,'aaa_housing','HP3560'),
        (84860,'aaa_housing','HP3350'),
        (86464,'aaa_housing','HP3058'),
        (97449,'aaa_housing','HP3056'),
        (144772,'aaa_housing','HP2388'),
        (146607,'aaa_housing','HP4025'),
        (151970,'aaa_housing','HP3422'),
        (156039,'aaa_housing','HP2365'),
        (163554,'aaa_housing','HP2418'),
        (165135,'aaa_housing','HP1130'),
        (165204,'aaa_housing','HP1354'),
        (172205,'aaa_housing','HP0175'),
        (179214,'aaa_housing','HP0404'),
        (180635,'aaa_housing','HP0337'),
        (196694,'aaa_housing','HP0760'),
        (209632,'aaa_housing','HP0316'),
        (29073,'aaa_housing','HP2258'),
        (53895,'aaa_housing','HP3561'),
        (97449,'aaa_housing','HP2712'),
        (146607,'aaa_housing','HP3325'),
        (156039,'aaa_housing','HP3115'),
        (163554,'aaa_housing','HP2590'),
        (165135,'aaa_housing','HP1330'),
        (172205,'aaa_housing','HP0435'),
        (179214,'aaa_housing','HP3255'),
        (180635,'aaa_housing','HP1852'),
        (196694,'aaa_housing','HP0810'),
        (53895,'aaa_housing','HP3283'),
        (97449,'aaa_housing','HP2733'),
        (53895,'aaa_housing','HP2655'),
        (53895,'aaa_housing','HP3558');