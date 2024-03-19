-- ไม่ได้ใส่ brand
-- ยังไม่มีชื่อถนน
-- ไม่มี segment
-- เพิ่ม list ทางด่วน

-- source_search_housing_detail_view
-- search_housing_detail_view
-- truncateInsert_search_housing_detail_view
-- search_housing_detail_getHousingTopSpotlight
-- search_housing_detail_update_spotlight

-- source_search_housing_category_spotlight
-- search_housing_category_spotlight
-- truncateInsert_search_housing_category_spotlight

-- source_search_housing_detail_view
CREATE OR REPLACE VIEW source_search_housing_detail_view as 
select h.Housing_Code
    , housing_thname.Housing_Name
    , housing_enname.Housing_ENName
    , REGEXP_REPLACE(housing_thname.Housing_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Housing_Name_Search
    , REGEXP_REPLACE(housing_enname.Housing_ENName, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Housing_ENName_Search
    , cd.Developer_THName
    , cd.Developer_ENName
    , h.Housing_Latitude
    , h.Housing_Longitude
    , h.Road_Name
    , ts.name_th as Sub_DistrictTH
    , ts.name_en as Sub_DistrictEN
    , td.name_th as DistrictTH
    , td.name_en as DistrictEN
    , tp.name_th as ProvinceTH
    , tp.name_en as ProvinceEN
    , rs.SubDistrict_Name as Real_SubDistrictTH
    , REGEXP_REPLACE(rs.SubDistrict_Name_Eng,concat(rs.SubDistrict_Code,'-'),'') as Real_SubDistrictEN
    , rd.District_Name as Real_DistrictTH
    , REGEXP_REPLACE(rd.District_Name_ENG,concat(rd.District_Code,'-'),'') as Real_DistrictEN
    , sub_station.StationTH
    , sub_station.StationEN
    , station.Housing_Around_Station
    , housing_line.Housing_Around_Line
    , sub_expressway.Express_Way
    , eway.Housing_Around_Express_Way
    , concat('/realist/housing/proj/',h.Housing_URL_Tag,'/') as Housing_URL
    , if(h.Housing_Cover = 1
        , concat('/realist/housing/uploads/housing/',h.Housing_Code,'/',h.Housing_Code,'-PE-01-Exterior-H-240.webp')
        , concat('/realist/housing/uploads/housing/CD-Default-H-240.webp')) as Housing_Cover
    , h.Realist_Score as Realist_Score
    , null as Brand_Name
    , null as Brand_Name_TH
    , concat_ws(', ',if(h.IS_SD=1,'บ้านเดี่ยว',null),if(h.IS_DD=1,'บ้านแฝด',null),if(h.IS_TH=1,'ทาวน์โฮม',null)
                        , if(h.IS_HO=1,'โฮมออฟฟิศ',null), if(h.IS_SH=1,'อาคารพาณิชย์',null)) as Housing_Type_TH
    , concat_ws(', ',if(h.IS_SD=1,'Single Detached House',null),if(h.IS_DD=1,'Double Detached House',null)
                        ,if(h.IS_TH=1,'Townhome',null), if(h.IS_HO=1,'Home Office',null)
                        , if(h.IS_SH=1,'Shophouse',null)) as Housing_Type_EN
from housing h
left join thailand_district td on h.District_ID = td.district_code
left join thailand_province tp on h.Province_ID = tp.province_code
left join condo_developer cd on h.Developer_Code = cd.Developer_Code
left join thailand_subdistrict ts on h.SubDistrict_ID = ts.subdistrict_code
left join real_yarn_sub rs on h.RealSubDistrict_Code = rs.SubDistrict_Code
left join real_yarn_main rd on h.RealDistrict_Code = rd.District_Code
left join ( select Housing_Code,Station_THName_Display as StationTH,Station_ENName_Display as StationEN
            from (  select hs.Housing_Code
                            , ms.Station_THName_Display
                            , ms.Station_ENName_Display
                            , ROW_NUMBER() OVER (PARTITION BY hs.Housing_Code ORDER BY hs.Distance) AS RowNum
                    from housing_around_station as hs
                    inner join mass_transit_station as ms on hs.Station_Code = ms.Station_Code
                    order by hs.Housing_Code) a
            where a.RowNum = 1) as sub_station
on h.Housing_Code = sub_station.Housing_Code
left join ( select Housing_Code,concat(Place_Attribute_1,' ',Place_Attribute_2) as Express_Way
            from (  select hw.Housing_Code
                            , hw.Place_Attribute_1
                            , hw.Place_Attribute_2
                            , ROW_NUMBER() OVER (PARTITION BY hw.Housing_Code ORDER BY hw.Distance) AS RowNum
                    from housing_around_express_way as hw
                    order by hw.Housing_Code) a
            where a.RowNum = 1) as sub_expressway
on h.Housing_Code = sub_expressway.Housing_Code
left join (select housing_around_station.Housing_Code AS Housing_Code,
                group_concat(housing_around_station.Station_THName_Display separator ',') AS Housing_Around_Station
            from housing_around_station
            group by housing_around_station.Housing_Code) station 
on h.Housing_Code = station.Housing_Code
left join (select Housing_Code
            , GROUP_CONCAT(Place_Attribute_2 SEPARATOR ',') as Housing_Around_Express_Way
            from (select Housing_Code, Place_Attribute_2 
                    from housing_around_express_way 
                    group by Housing_Code, Place_Attribute_2) aa
            GROUP by Housing_Code) eway 
on h.Housing_Code = eway.Housing_Code
left join ( select Housing_Code
            , group_concat(Line_Name SEPARATOR ',') as Housing_Around_Line
            from (select hs.Housing_Code,ml.Line_Name
                    from housing_around_station hs
                    left join mass_transit_line ml on hs.Line_Code = ml.Line_Code
                    group by hs.Housing_Code,ml.Line_Name) line_name
            group by Housing_Code) AS housing_line
on h.Housing_Code = housing_line.Housing_Code
left join ( SELECT h.Housing_Code, 
                if(Housing_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_ENName1,'\n',1),' ',SUBSTRING_INDEX(Housing_ENName1,'\n',-1))
                    , Housing_ENName2) as Housing_ENName
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
            where h.Housing_Status = '1'
            ORDER BY h.Housing_Code) housing_enname
on h.Housing_Code = housing_enname.Housing_Code
left join ( SELECT h.Housing_Code, 
                if(Housing_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_Name1,'\n',1),' ',SUBSTRING_INDEX(Housing_Name1,'\n',-1))
                    , Housing_Name2) as Housing_Name
            FROM housing AS h
            left JOIN ( select Housing_Code as Housing_Code1
                            ,   Housing_Name as Housing_Name1
                        from housing
                        where Housing_Name LIKE '%\n%') housing1
            on h.Housing_Code = housing1.Housing_Code1
            left JOIN ( select Housing_Code as Housing_Code2
                            ,   Housing_Name as Housing_Name2
                        from housing
                        WHERE Housing_Name NOT LIKE '%\n%' 
                        AND Housing_Name NOT LIKE '%\r%') housing2
            on h.Housing_Code = housing2.Housing_Code2
            where h.Housing_Status = '1'
            ORDER BY h.Housing_Code) housing_thname
on h.Housing_Code = housing_thname.Housing_Code
where h.Housing_Status = '1'
and h.Housing_ENName is not null
order by h.Housing_Code;


-- Table `search_housing_detail_view`
CREATE TABLE IF NOT EXISTS `search_housing_detail_view` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Name VARCHAR(250) NULL,
    Housing_ENName VARCHAR(150) NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(150) NULL,
    Developer_THName VARCHAR(200) NULL,
    Developer_ENName VARCHAR(150) NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    Road_Name VARCHAR(50) NULL,
    Sub_DistrictTH VARCHAR(150) NULL,
    Sub_DistrictEN VARCHAR(150) NULL,
    District_NameTH VARCHAR(150) NULL,
    District_NameEN VARCHAR(150) NULL,
    ProvinceTH VARCHAR(150) NULL,
    ProvinceEN VARCHAR(150) NULL,
    Real_SubDistrictTH VARCHAR(250) NULL,
    Real_SubDistrictEN VARCHAR(200) NULL,
    Real_DistrictTH VARCHAR(150) NULL,
    Real_DistrictEN VARCHAR(150) NULL,
    StationTH VARCHAR(200) NULL,
    StationEN VARCHAR(200) NULL,
    Housing_Around_Station TEXT NULL,
    Housing_Around_Line TEXT NULL,
    Express_Way TEXT NULL,
    Housing_Around_Express_Way TEXT NULL,
    Housing_Spotlight TEXT NULL,
    Housing_URL TEXT NULL,
    Housing_Cover Text NULL,
    Realist_Score DOUBLE NULL, 
    Brand_Name VARCHAR(150) NULL,
    Brand_Name_TH VARCHAR(150) NULL,
    Housing_Type_TH VARCHAR(200) NULL,
    Housing_Type_EN VARCHAR(200) NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX hscode (Housing_Code))
ENGINE = InnoDB;

-- truncateInsert_search_housing_detail_view
DROP PROCEDURE IF EXISTS truncateInsert_search_housing_detail_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_housing_detail_view ()
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
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name22 TEXT DEFAULT NULL;
    DECLARE v_name23 TEXT DEFAULT NULL;
    DECLARE v_name24 TEXT DEFAULT NULL;
    DECLARE v_name25 TEXT DEFAULT NULL;
    DECLARE v_name26 TEXT DEFAULT NULL;
    DECLARE v_name27 TEXT DEFAULT NULL;
    DECLARE v_name28 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name29 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name30 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name31 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name32 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_housing_detail_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code,Housing_Name,Housing_ENName,Housing_Name_Search,Housing_ENName_Search
                                ,Developer_THName,Developer_ENName,Housing_Latitude,Housing_Longitude,Road_Name,Sub_DistrictTH
                                ,Sub_DistrictEN,DistrictTH,DistrictEN,ProvinceTH,ProvinceEN,Real_SubDistrictTH,Real_SubDistrictEN
                                ,Real_DistrictTH,Real_DistrictEN,StationTH,StationEN,Housing_Around_Station,Housing_Around_Line
                                ,Express_Way,Housing_Around_Express_Way,Housing_URL,Housing_Cover,Realist_Score,Brand_Name,Brand_Name_TH
                                ,Housing_Type_TH,Housing_Type_EN
                            FROM source_search_housing_detail_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_housing_detail_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_housing_detail_view(
                `Housing_Code`,
                `Housing_Name`,    
                `Housing_ENName`,
                `Housing_Name_Search`,    
                `Housing_ENName_Search`,
                `Developer_THName`,
                `Developer_ENName`,
                `Housing_Latitude`,
                `Housing_Longitude`,
                `Road_Name`,
                `Sub_DistrictTH`,
                `Sub_DistrictEN`,
                `District_NameTH`,
                `District_NameEN`,
                `ProvinceTH`,
                `ProvinceEN`,
                `Real_SubDistrictTH`,
                `Real_SubDistrictEN`,
                `Real_DistrictTH`,
                `Real_DistrictEN`,
                `StationTH`,
                `StationEN`,
                `Housing_Around_Station`,
                `Housing_Around_Line`,
                `Express_Way`,
                `Housing_Around_Express_Way`,
                `Housing_URL`,
                `Housing_Cover`,
                `Realist_Score`,
                `Brand_Name`,
                `Brand_Name_TH`,
                `Housing_Type_TH`,
                `Housing_Type_EN`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32);
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

-- search_housing_detail_getHousingTopSpotlight
DROP PROCEDURE IF EXISTS search_housing_detail_getHousingTopSpotlight;
DELIMITER //

CREATE PROCEDURE search_housing_detail_getHousingTopSpotlight(IN Housing_Code VARCHAR(50), OUT finalSpotlight_Name TEXT)
BEGIN

	DECLARE done				BOOLEAN			DEFAULT FALSE;
	DECLARE eachSpotlight_Code	VARCHAR(250)	DEFAULT NULL;
	DECLARE eachSpotlight_Name	VARCHAR(250)	DEFAULT NULL;
	DECLARE queryBase1			VARCHAR(1000)	DEFAULT "SELECT COUNT(1) INTO @spotlightCount 
                                                        FROM (SELECT Housing_Code, Spotlight_Code FROM housing_spotlight_relationship
                                                        union SELECT Housing_Code, Spotlight_Code FROM housing_spotlight_relationship_manual) HSR 
                                                        WHERE HSR.Housing_Code = '";
	DECLARE queryBase2			VARCHAR(100)	DEFAULT "' AND HSR.Spotlight_Code = '";
	DECLARE queryBase3			VARCHAR(100)	DEFAULT "'";
	DECLARE queryFinal			VARCHAR(2000)	DEFAULT NULL;
	DECLARE	queryResultCount	INTEGER			DEFAULT 0;
	DECLARE stmt 				VARCHAR(2000);

	DECLARE curTopSpotlight
	CURSOR FOR
		SELECT HS.Spotlight_Code, HS.Spotlight_Name 
		FROM housing_spotlight HS
		WHERE HS.Housing_Count > 0;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET finalSpotlight_Name = "";
	SET queryBase1 = CONCAT(queryBase1, Housing_Code, queryBase2);
	
	OPEN curTopSpotlight;
	
	TopSpotlightLoop:LOOP
		FETCH curTopSpotlight INTO eachSpotlight_Code, eachSpotlight_Name;

        IF done THEN
			LEAVE TopSpotlightLoop;
		END IF;
		
		SET queryFinal = CONCAT(queryBase1, eachSpotlight_Code, queryBase3);
		-- select queryFinal;
		SET @query = queryFinal;
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET queryResultCount = @spotlightCount;
		
		IF (queryResultCount > 0) THEN
            IF finalSpotlight_Name <> "" THEN
                SET finalSpotlight_Name = CONCAT(finalSpotlight_Name, "," , eachSpotlight_Name);
            ELSE
                SET finalSpotlight_Name = CONCAT(finalSpotlight_Name, "" , eachSpotlight_Name);
            END IF;
            -- select queryResultCount,finalSpotlight_Name;
		END IF;
	
	END LOOP;

    CLOSE curTopSpotlight;
	
	SET finalSpotlight_Name = TRIM(finalSpotlight_Name);

END //
DELIMITER ;


-- search_housing_detail_update_spotlight
DROP PROCEDURE IF EXISTS search_housing_detail_update_spotlight;
DELIMITER //

CREATE PROCEDURE search_housing_detail_update_spotlight ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE housing	    VARCHAR(50) DEFAULT 0;
    DECLARE mySpotlight	TEXT;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'search_housing_detail_update_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code FROM search_housing_detail_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',housing);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO housing;

        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL search_housing_detail_getHousingTopSpotlight(housing, mySpotlight);
        UPDATE search_housing_detail_view
        SET Housing_Spotlight = mySpotlight
        WHERE Housing_Code = housing;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows run in spotlight_relationships.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;
END //
DELIMITER ;


-- source_search_housing_category_spotlight
CREATE OR REPLACE VIEW source_search_housing_category_spotlight as
select Spotlight_Code
    , Spotlight_Name
    , REGEXP_REPLACE(Spotlight_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Spotlight_Name_Search
    , Keyword_TH
    , Keyword_ENG
    , concat('/realist/housing/list/spotlight/',REGEXP_REPLACE(Spotlight_Name,' ','-'),'/') as Spotlight_URL
from housing_spotlight
where Housing_Count > 0;

-- Table `search_housing_category_spotlight`
CREATE TABLE IF NOT EXISTS `search_housing_category_spotlight` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Spotlight_Code VARCHAR(20) NOT NULL,
    Spotlight_Name VARCHAR(150) NOT NULL,
    Spotlight_Name_Search VARCHAR(150) NOT NULL,
    Keyword_TH TEXT NULL,
    Keyword_ENG TEXT NULL,
    Spotlight_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_housing_category_spotlight
DROP PROCEDURE IF EXISTS truncateInsert_search_housing_category_spotlight;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_housing_category_spotlight ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 TEXT DEFAULT NULL;
    DECLARE v_name3 TEXT DEFAULT NULL;
    DECLARE v_name4 TEXT DEFAULT NULL;
    DECLARE v_name5 TEXT DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_housing_category_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Spotlight_Code,Spotlight_Name,Spotlight_Name_Search,Keyword_TH,Keyword_ENG,Spotlight_URL
                            FROM source_search_housing_category_spotlight;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_housing_category_spotlight;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_housing_category_spotlight(
                `Spotlight_Code`,
                `Spotlight_Name`,
                `Spotlight_Name_Search`,
                `Keyword_TH`,
                `Keyword_ENG`, 
                `Spotlight_URL`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5);
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