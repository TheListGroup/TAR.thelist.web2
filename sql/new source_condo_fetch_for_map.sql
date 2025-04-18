DELIMITER //
CREATE FUNCTION ThaiMonth(monthNumber INT) 
RETURNS VARCHAR(20)
NO SQL
BEGIN
    CASE monthNumber
        WHEN 1 THEN RETURN 'ม.ค.'; -- January
        WHEN 2 THEN RETURN 'ก.พ.'; -- February
        WHEN 3 THEN RETURN 'มี.ค.'; -- March
        WHEN 4 THEN RETURN 'เม.ย.'; -- April
        WHEN 5 THEN RETURN 'พ.ค.'; -- May
        WHEN 6 THEN RETURN 'มิ.ย.'; -- June
        WHEN 7 THEN RETURN 'ก.ค.'; -- July
        WHEN 8 THEN RETURN 'ส.ค.'; -- August
        WHEN 9 THEN RETURN 'ก.ย.'; -- September
        WHEN 10 THEN RETURN 'ต.ค.'; -- October
        WHEN 11 THEN RETURN 'พ.ย.'; -- November
        WHEN 12 THEN RETURN 'ธ.ค.'; -- December
        ELSE RETURN 'Invalid Month';
    END CASE;
END//
DELIMITER ;

CREATE OR REPLACE VIEW `source_condo_fetch_for_map` AS
SELECT a.Condo_ID
	, a.Condo_Code
    , sub_distance.Distance as Distance
    , b.Condo_Price_Per_Square as Condo_Price_Per_Square
    , year(b.Condo_Price_Per_Square_Date) AS Condo_Price_Per_Square_Date
    , b.Condo_Built_Text AS Condo_Built_Text
    , b.Condo_Built_Date AS Condo_Built_Date
    , b.Condo_Age_Status_Square_Text AS Condo_Age_Status_Square_Text
    , b.Condo_Price_Per_Unit_Text AS Condo_Price_Per_Unit_Text
    , b.Condo_Price_Per_Unit AS Condo_Price_Per_Unit
    , year(b.Condo_Price_Per_Unit_Date) AS Condo_Price_Per_Unit_Date 
    , b.Condo_Sold_Status_Show_Value AS Condo_Sold_Status_Show_Value
    , year(b.Condo_Sold_Status_Date) as Condo_Sold_Status_Show_Value_Date
    , b.Condo_Date_Calculate AS Condo_Date_Calculate
    , a.Condo_ENName as Condo_ENName
    , replace(replace(replace(replace(replace(a.Condo_Name, '\n', ''), '-', ''),'(',''),')',''),' ','') AS Condo_Name_Search
    , replace(replace(replace(replace(replace(a.Condo_ENName, '\n', ''), '-', ''),'(',''),')',''),' ','') AS Condo_ENName_Search
    , a.Condo_ScopeArea AS Condo_ScopeArea
    , a.Condo_Latitude AS Condo_Latitude
    , a.Condo_Longitude AS Condo_Longitude
    , a.Brand_Code AS Brand_Code
    , a.Developer_Code AS Developer_Code
    , a.RealSubDistrict_Code AS RealSubDistrict_Code
    , a.RealDistrict_Code AS RealDistrict_Code
    , a.SubDistrict_ID AS SubDistrict_ID
    , a.District_ID AS District_ID
    , a.Province_ID AS Province_ID
    , a.Condo_URL_Tag AS Condo_URL_Tag
    , a.Condo_Cover AS Condo_Cover
    , ifnull(a.No_of_Unit_Point, 0) + ifnull(a.Finish_Year_Point, 0) + ifnull(a.HighRise_Point, 0)
        + ifnull(a.ListCompany_Point, 0) + ifnull(a.DistanceFromStation_Point, 0) AS Total_Point
    , station.Condo_Around_Station AS Condo_Around_Station
    , if(((type1.studio is null) and (type2.onebed is null) and (type3.twobed is null) and (type4.threebed is null)
            and (type5.fourbed is null))
        , '[1BED][2BED]'
        , concat(ifnull(type1.studio, ''), ifnull(type2.onebed, ''), ifnull(type3.twobed, ''), ifnull(type4.threebed, ''),
            ifnull(type5.fourbed, ''))) AS Condo_Bedroom_Type
    , if(((size_stu.stus is null) and (size_1bed.1beds is null) and (size_2bed.2beds is null)
                and (size_3bed.3beds is null) and (size_4bed.4beds is null))
            , '[1BR:20-60][2BR_1B:20-60]'
            , concat(ifnull(size_stu.stus, ''), ifnull(size_1bed.1beds, ''), ifnull(size_2bed.2beds, ''),
                ifnull(size_3bed.3beds, ''), ifnull(size_4bed.4beds, ''))) AS Condo_Room_Size
    , concat(
        if((c.PS001 = 'Y'), '[PS001]', ''),
        if((c.PS002 = 'Y'), '[PS002]', ''),
        if((c.PS003 = 'Y'), '[PS003]', ''),
        if((c.PS006 = 'Y'), '[PS006]', ''),
        if((c.PS007 = 'Y'), '[PS007]', ''),
        if((c.PS008 = 'Y'), '[PS008]', ''),
        if((c.PS009 = 'Y'), '[PS009]', ''),
        if((c.PS016 = 'Y'), '[PS016]', ''),
        if((c.PS017 = 'Y'), '[PS017]', ''),
        if((c.PS019 = 'Y'), '[PS019]', ''),
        if((c.PS021 = 'Y'), '[PS021]', ''),
        if((c.PS022 = 'Y'), '[PS022]', ''),
        if((c.PS024 = 'Y'), '[PS024]', ''),
        if((c.PS025 = 'Y'), '[PS025]', ''),
        if((c.PS026 = 'Y'), '[PS026]', ''),
        if((c.CUS000 = 'Y'), '[CUS000]', ''),
        if((c.CUS001 = 'Y'), '[CUS001]', ''),
        if((c.CUS002 = 'Y'), '[CUS002]', ''),
        if((c.CUS003 = 'Y'), '[CUS003]', ''),
        if((c.CUS004 = 'Y'), '[CUS004]', ''),
        if((c.CUS005 = 'Y'), '[CUS005]', ''),
        if((c.CUS006 = 'Y'), '[CUS006]', ''),
        if((c.CUS007 = 'Y'), '[CUS007]', ''),
        if((c.CUS008 = 'Y'), '[CUS008]', ''),
        if((c.CUS009 = 'Y'), '[CUS009]', ''),
        if((c.CUS010 = 'Y'), '[CUS010]', ''),
        if((c.CUS011 = 'Y'), '[CUS011]', ''),
        if((c.CUS014 = 'Y'), '[CUS014]', ''),
        if((c.CUS015 = 'Y'), '[CUS015]', ''),
        if((c.CUS016 = 'Y'), '[CUS016]', ''),
        if((c.CUS017 = 'Y'), '[CUS017]', ''),
        if((c.CUS018 = 'Y'), '[CUS018]', ''),
        if((c.CUS019 = 'Y'), '[CUS019]', ''),
        if((c.CUS020 = 'Y'), '[CUS020]', ''),
        if((c.CUS021 = 'Y'), '[CUS021]', ''),
        if((c.CUS022 = 'Y'), '[CUS022]', ''),
        if((c.CUS023 = 'Y'), '[CUS023]', ''),
        if((c.CUS024 = 'Y'), '[CUS024]', ''),
        if((c.CUS025 = 'Y'), '[CUS025]', ''),
        if((c.CUS026 = 'Y'), '[CUS026]', ''),
        if((c.CUS027 = 'Y'), '[CUS027]', ''),
        if((c.CUS028 = 'Y'), '[CUS028]', ''),
        if((c.CUS029 = 'Y'), '[CUS029]', ''),
        if((c.CUS030 = 'Y'), '[CUS030]', ''),
        if((c.CUS031 = 'Y'), '[CUS031]', ''),
        if((c.CUS032 = 'Y'), '[CUS032]', ''),
        if((c.CUS033 = 'Y'), '[CUS033]', ''),
        if((c.CUS034 = 'Y'), '[CUS034]', ''),
        if((c.CUS037 = 'Y'), '[CUS037]', ''),
        if((c.CUS038 = 'Y'), '[CUS038]', ''),
        if((c.CUS039 = 'Y'), '[CUS039]', ''),
        if((c.CUS040 = 'Y'), '[CUS040]', ''),
        if((c.CUS041 = 'Y'), '[CUS041]', ''),
        if((c.CUS042 = 'Y'), '[CUS042]', '')) AS Spotlight_List
    , if(d.Condo_Built_Finished is not null
        , greatest((year(curdate()) - year(d.Condo_Built_Finished)),0)
        , if(d.Condo_Built_Start is not null
            , if(a.Condo_HighRise = 1
                , greatest((year(curdate()) - (year(d.Condo_Built_Start) + 4)),0)
                , greatest((year(curdate()) - (year(d.Condo_Built_Start) + 3)),0))
            , NULL)) AS Condo_Age
    , round(rs.Realist_Score,2) as Realist_Score
    , if(a.Condo_HighRise = 1
        , 1
        , 0) as Condo_HighRise
    , d.Condo_Segment as Condo_Segment
    , condo_line.Condo_Around_Line as Condo_Around_Line
    , b.Condo_Price_Per_Square_Sort as Condo_Price_Per_Square_Sort -- b.Condo_Price_Per_Square_Sort
	, b.Condo_Price_Per_Unit_Sort as Condo_Price_Per_Unit_Sort -- b.Condo_Price_Per_Unit_Sort
    , concat_ws(' ', replace(a.Condo_ENName, '\n', ' '), concat('(', replace(a.Condo_Name, '\n', ' '), ')'), '| REAL DATA') as Condo_Title
    , concat_ws(' ',replace(a.Condo_ENName,'\n',' ')
        , replace(replace(concat_ws(' ', replace(a.Condo_Building, '"', ''), 'ชั้น'), 'Buildings', ' อาคาร '), ',', ' ชั้น, ')
        , concat('ย่าน', ym.District_Name), concat('ใกล้รฟฟ.สถานี', if(ff.Station = '-', null, ff.Station))
        , concat('จำนวน ', format(a.Condo_TotalUnit,0), ' ยูนิต')
        , concat(if(b.Condo_Price_Per_Square is not null
                    , b.Condo_Age_Status_Square_Text
                    , if(b.Condo_Price_Per_Unit is not null
                        , b.Condo_Price_Per_Unit_Text
                        , null))
            , ' ', ifnull(format(round(b.Condo_Price_Per_Square, -3), 0), ifnull(round(b.Condo_Price_Per_Unit/1000000, 1), null))
            , ' ', if(b.Condo_Price_Per_Square is not null
                        , 'บ./ตร.ม.'
                        , if(b.Condo_Price_Per_Unit is not null
                            , 'ลบ./ยูนิต'
                            , null)))
        , concat('(', ThaiMonth(MONTH(if(b.Condo_Price_Per_Square is not null
                                        , b.Condo_Price_Per_Square_Date
                                        , if(b.Condo_Price_Per_Unit is not null
                                            , b.Condo_Price_Per_Unit_Date
                                            , null))))
                , ' ', if(b.Condo_Price_Per_Square is not null
                            , year(b.Condo_Price_Per_Square_Date)
                            , if(b.Condo_Price_Per_Unit is not null
                                , year(b.Condo_Price_Per_Unit_Date)
                                , null)), ')')
        , concat('เริ่ม ', if(type1.Condo_Code is not null, 1
                            , if(type2.Condo_Code is not null, 1
                                , if(type3.Condo_Code is not null, 2
                                    , if(type4.Condo_Code is not null, 3
                                        , if(type5.Condo_Code is not null, 4
                                            , null))))), ' ห้องนอน '
            , if(type1.Condo_Code is not null, type1.minsize
                , if(type2.Condo_Code is not null, type2.minsize
                    , if(type3.Condo_Code is not null, type3.minsize
                        , if(type4.Condo_Code is not null, type4.minsize
                            , if(type5.Condo_Code is not null, type5.minsize
                                , null))))), ' ตร.ม.')
        , concat('ค่าส่วนกลาง ', d.Condo_Common_Fee, ' บ./ตร.ม./เดือน')) as Condo_Description
FROM condo_price_calculate_view b
left join real_condo a on b.Condo_Code = a.Condo_Code
left join condo_spotlight_relationship_view c on a.Condo_Code = c.Condo_Code
left join real_condo_price d on a.Condo_Code = d.Condo_Code
left join real_yarn_main ym on a.RealDistrict_Code = ym.District_Code
left join full_template_factsheet ff on a.Condo_Code = ff.Condo_Code
left join ( select Condo_Code
                , cast(Distance as decimal(25,20)) as Distance
            from ( select Condo_Code
                        , Distance
                        , Total_Point
                        , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Total_Point) AS RowNum
                    from condo_around_station_view) order_distance
            where RowNum = 1) sub_distance 
on a.Condo_Code = sub_distance.Condo_Code
left join (select Condo_Code AS Condo_Code
                , group_concat('[',Station_Code,']' separator '') AS Condo_Around_Station
            from condo_around_station
            group by Condo_Code) station 
on a.Condo_Code = station.Condo_Code
left join (select Condo_Code AS Condo_Code
                , roundsize(min(Size)) as minsize
                , '[STU]' AS studio
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 1
            group by Condo_Code) type1 
on a.Condo_Code = type1.Condo_Code
left join (select Condo_Code AS Condo_Code
                , roundsize(min(Size)) as minsize
                , '[1BED]' AS onebed
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 2
            group by Condo_Code) type2
on a.Condo_Code = type2.Condo_Code
left join (select Condo_Code AS Condo_Code
                , roundsize(min(Size)) as minsize
                , '[2BED]' AS twobed
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 4
            group by Condo_Code) type3 
on a.Condo_Code = type3.Condo_Code
left join (select Condo_Code AS Condo_Code
                , roundsize(min(Size)) as minsize
                , '[3BED]' AS threebed
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 5
            group by Condo_Code) type4
on a.Condo_Code = type4.Condo_Code
left join (select Condo_Code AS Condo_Code
                , roundsize(min(Size)) as minsize
                , '[4BED]' AS fourbed
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 6
            group by Condo_Code) type5
on a.Condo_Code = type5.Condo_Code
left join (select Condo_Code AS Condo_Code
                , concat('[STU:', roundSize(min(Size)), '-', roundSize(max(Size)),']') AS stus
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 1
            group by Condo_Code
            order by Condo_Code) size_stu 
on a.Condo_Code = size_stu.Condo_Code
left join (select Condo_Code AS Condo_Code
                , concat('[1BED :', roundSize(min(Size)), '-', roundSize(max(Size)),']') AS 1beds
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 2
            group by Condo_Code
            order by Condo_Code) size_1bed
on a.Condo_Code = size_1bed.Condo_Code
left join (select Condo_Code AS Condo_Code
                , concat('[2BED :', roundSize(min(Size)), '-', roundSize(max(Size)),']') AS 2beds
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 4
            group by Condo_Code
            order by Condo_Code) size_2bed
on a.Condo_Code = size_2bed.Condo_Code
left join (select Condo_Code AS Condo_Code
                , concat('[3BED :', roundSize(min(Size)), '-', roundSize(max(Size)),']') AS 3beds
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 5
            group by Condo_Code
            order by Condo_Code) size_3bed
on a.Condo_Code = size_3bed.Condo_Code
left join (select Condo_Code AS Condo_Code
                , concat('[4BED :', roundSize(min(Size)), '-', roundSize(max(Size)),']') AS 4beds
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 6
            group by Condo_Code
            order by Condo_Code) size_4bed
on a.Condo_Code = size_4bed.Condo_Code
left join realist_score rs on b.Condo_Code = rs.Condo_Code
left join ( select Condo_Code
                , group_concat('[',Line_Code,']' separator '') AS `Condo_Around_Line`
            from ( SELECT Condo_Code
                        , Line_Code
                    FROM `condo_around_station`
                    group by Condo_Code,Line_Code) c_line
            group by Condo_Code) condo_line
on b.Condo_Code = condo_line.Condo_Code;


-- ALTER TABLE `condo_fetch_for_map` ADD `Condo_Price_Per_Square_Date` INT(4) UNSIGNED NULL AFTER `Condo_Price_Per_Square`;
-- ALTER TABLE `condo_fetch_for_map` ADD `Condo_Price_Per_Unit_Date` INT(4) UNSIGNED NULL AFTER `Condo_Price_Per_Unit`;
-- ALTER TABLE `condo_fetch_for_map` ADD `Condo_Sold_Status_Show_Value_Date` INT(4) UNSIGNED NULL AFTER `Condo_Sold_Status_Show_Value`;
-- ALTER TABLE `condo_fetch_for_map` ADD `Realist_Score` float NULL AFTER `Condo_Age`;
-- ALTER TABLE `condo_fetch_for_map` ADD `Condo_HighRise` SMALLINT UNSIGNED NULL AFTER `Realist_Score`;
-- ALTER TABLE `condo_fetch_for_map` ADD `Condo_Segment` varchar(10) NULL AFTER `Condo_HighRise`;
-- ALTER TABLE `condo_fetch_for_map` ADD `Condo_Around_Line` TEXT NULL AFTER `Condo_Segment`;
ALTER TABLE `condo_fetch_for_map` ADD `Condo_Price_Per_Square_Sort` FLOAT NULL AFTER `Condo_Around_Line`;
ALTER TABLE `condo_fetch_for_map` ADD `Condo_Price_Per_Unit_Sort` FLOAT NULL AFTER `Condo_Price_Per_Square_Sort`;
ALTER TABLE `condo_fetch_for_map` ADD `Condo_Title` TEXT NULL AFTER `Condo_Price_Per_Unit_Sort`;
ALTER TABLE `condo_fetch_for_map` ADD `Condo_Description` TEXT NULL AFTER `Condo_Title`;

DROP PROCEDURE IF EXISTS truncateInsert_condo_fetch_for_map;
DELIMITER //

CREATE PROCEDURE truncateInsert_condo_fetch_for_map ()
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
	DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
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
	DECLARE v_name33 TEXT DEFAULT NULL;
    DECLARE v_name34 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name35 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name36 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name37 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name38 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name39 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name40 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name41 TEXT DEFAULT NULL;
    DECLARE v_name42 TEXT DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_condo_fetch_for_map';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_ID, Condo_Code, Distance, Condo_Price_Per_Square, Condo_Price_Per_Square_Date,
                                Condo_Built_Text, Condo_Built_Date, Condo_Age_Status_Square_Text, Condo_Price_Per_Unit_Text,
                                Condo_Price_Per_Unit, Condo_Price_Per_Unit_Date, Condo_Sold_Status_Show_Value,
                                Condo_Sold_Status_Show_Value_Date, Condo_Date_Calculate, Condo_ENName, Condo_Name_Search,
                                Condo_ENName_Search, Condo_ScopeArea, Condo_Latitude, Condo_Longitude, Brand_Code, 
                                Developer_Code, RealSubDistrict_Code, RealDistrict_Code, SubDistrict_ID, District_ID, 
                                Province_ID, Condo_URL_Tag, Condo_Cover, Total_Point, Condo_Around_Station, 
                                Condo_Bedroom_Type, Condo_Room_Size, Spotlight_List, Condo_Age, Realist_Score, Condo_HighRise,
                                Condo_Segment, Condo_Around_Line, Condo_Price_Per_Square_Sort, Condo_Price_Per_Unit_Sort, 
                                Condo_Title, Condo_Description
                            FROM source_condo_fetch_for_map;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name1);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    condo_fetch_for_map;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			condo_fetch_for_map(
				Condo_ID,
				Condo_Code,
				Distance,    
				Condo_Price_Per_Square,
                Condo_Price_Per_Square_Date,
				Condo_Built_Text,
				Condo_Built_Date,
				Condo_Age_Status_Square_Text,
				Condo_Price_Per_Unit_Text,
				Condo_Price_Per_Unit,
                Condo_Price_Per_Unit_Date,
				Condo_Sold_Status_Show_Value,
                Condo_Sold_Status_Show_Value_Date,
				Condo_Date_Calculate,
				Condo_ENName,
				Condo_Name_Search,
				Condo_ENName_Search,
				Condo_ScopeArea,
				Condo_Latitude,
				Condo_Longitude,
				Brand_Code,
				Developer_Code,
				RealSubDistrict_Code,
				RealDistrict_Code,
				SubDistrict_ID,
				District_ID,
				Province_ID,
				Condo_URL_Tag,
				Condo_Cover,
				Total_Point,
				Condo_Around_Station,
				Condo_Bedroom_Type,
				Condo_Room_Size,
				Spotlight_List,
				Condo_Age,
                Realist_Score,
                Condo_HighRise,
                Condo_Segment,
                Condo_Around_Line,
                Condo_Price_Per_Square_Sort,
                Condo_Price_Per_Unit_Sort,
                Condo_Title,
                Condo_Description
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42);
        
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