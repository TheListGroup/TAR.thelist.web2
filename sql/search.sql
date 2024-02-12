-- VIEW source_search_condo_detail_view
-- TABLE search_condo_detail_view
-- PROCEDURE truncateInsert_search_condo_detail_view
-- PROCEDURE search_condo_detail_getCondoTopSpotlight
-- PROCEDURE search_condo_detail_update_spotlight

-- VIEW source_search_category_spotlight
-- Table search_category_spotlight
-- truncateInsert_search_category_spotlight

-- VIEW source_search_category_segment
-- Table search_category_segment
-- truncateInsert_search_category_segment

-- VIEW source_search_category_province
-- Table search_category_province
-- truncateInsert_search_category_province

-- VIEW source_search_category_developer
-- Table search_category_developer
-- truncateInsert_search_category_developer

-- VIEW source_search_category_brand
-- Table search_category_brand
-- truncateInsert_search_category_brand

-- VIEW source_search_category_line
-- Table search_category_line
-- truncateInsert_search_category_line

-- VIEW source_search_category_station
-- Table search_category_station
-- truncateInsert_search_category_station

-- VIEW source_search_category_realist_district
-- Table search_category_realist_district
-- truncateInsert_search_category_realist_district

-- VIEW source_search_category_realist_subdistrict
-- Table search_category_realist_subdistrict
-- truncateInsert_search_category_realist_subdistrict

-- VIEW source_search_category_district
-- Table search_category_district
-- truncateInsert_search_category_district

-- VIEW source_search_category_subdistrict
-- Table search_category_subdistrict
-- truncateInsert_search_category_subdistrict

ALTER TABLE mass_transit_station DROP INDEX station;

ALTER TABLE mass_transit_line ADD Line_Name_Eng VARCHAR(50) NULL AFTER Line_Cover;

ALTER TABLE brand ADD Brand_Name_TH VARCHAR(250) NULL AFTER Brand_Update_User;

ALTER TABLE `real_condo_spotlight` 
ADD `Keyword_TH` TEXT NULL AFTER `Spotlight_Description`
, ADD `Keyword_ENG` TEXT NULL AFTER `Keyword_TH`;

CREATE OR REPLACE VIEW source_search_condo_detail_view as 
select rc.Condo_Code
    , condo_thname.Condo_Name
    , condo_enname.Condo_ENName
    , REGEXP_REPLACE(condo_thname.Condo_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Condo_Name_Search
    , REGEXP_REPLACE(condo_enname.Condo_ENName, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Condo_ENName_Search
    , b.Brand_Name
    , b.Brand_Name_TH
    , cd.Developer_THName
    , cd.Developer_ENName
    , rc.Condo_Latitude
    , rc.Condo_Longitude
    , rc.Road_Name
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
    , rcs.Segment_Name
    , station.Condo_Around_Station
    , condo_line.Condo_Around_Line
    , (SELECT concat(Place_Attribute_1,' ',Place_Attribute_2) FROM `real_place_express_way` 
        where ads_express_way(Place_Latitude, rc.Condo_Latitude, Place_Longitude, rc.Condo_Longitude) <= 3
        order by ads_express_way(Place_Latitude, rc.Condo_Latitude, Place_Longitude, rc.Condo_Longitude) 
        limit 1) as Express_Way
    , concat('/realist/condo/proj/',rc.Condo_URL_Tag,'-',rc.Condo_Code,'/') as Condo_URL
    , if(rc.Condo_Cover = 1
        , concat('/realist/condo/uploads/condo/',rc.Condo_Code,'/',rc.Condo_Code,'-PE-01-Exterior-H-240.webp')
        , concat('/realist/condo/uploads/condo/CD-Default-H-240.webp')) as Condo_Cover
    , sc.Realist_Score as Realist_Score 
from real_condo rc
left join thailand_district td on rc.District_ID = td.district_code
left join thailand_province tp on rc.Province_ID = tp.province_code
left join (select Brand_Code,Brand_Name,Brand_Name_TH
            from brand
            where Brand_Status = 1) b 
on rc.Brand_Code = b.Brand_Code
left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
left join thailand_subdistrict ts on rc.SubDistrict_ID = ts.subdistrict_code
left join real_yarn_sub rs on rc.RealSubDistrict_Code = rs.SubDistrict_Code
left join real_yarn_main rd on rc.RealDistrict_Code = rd.District_Code
left join ( select Condo_Code,Station_THName_Display as StationTH,Station_ENName_Display as StationEN
            from (  select cv.Condo_Code
                            , ms.Station_THName_Display
                            , ms.Station_ENName_Display
                            , ROW_NUMBER() OVER (PARTITION BY cv.Condo_Code ORDER BY cv.Total_Point) AS RowNum
                    from condo_around_station_view as cv 
                    inner join mass_transit_station as ms on cv.Station_Code = ms.Station_Code
                    order by cv.Condo_Code) a
            where a.RowNum = 1) as sub_station
on rc.Condo_Code = sub_station.Condo_Code
left join condo_spotlight_relationship_view as cs on rc.Condo_Code = cs.Condo_Code
left join real_condo_price rcp on rc.Condo_Code = rcp.Condo_Code
left join real_condo_segment rcs on rcp.Condo_Segment = rcs.Segment_Code
left join ( select Condo_Code
            , group_concat(Station_THName_Display SEPARATOR ',') as Condo_Around_Station
            from (select ct.Condo_Code,ms.Station_THName_Display
                    from condo_around_station ct
                    left join mass_transit_station_view ms on ct.Station_Code = ms.Station_Code
                    group by ct.Condo_Code,ms.Station_THName_Display) station_name
            group by Condo_Code) AS station
on rc.Condo_Code = station.Condo_Code
left join ( select Condo_Code
            , group_concat(Line_Name SEPARATOR ',') as Condo_Around_Line
            from (select ct.Condo_Code,ml.Line_Name
                    from condo_around_station ct
                    left join mass_transit_line ml on ct.Line_Code = ml.Line_Code
                    group by ct.Condo_Code,ml.Line_Name) line_name
            group by Condo_Code) AS condo_line
on rc.Condo_Code = condo_line.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
                    , Condo_ENName2) as Condo_ENName
            FROM real_condo AS cpc
            left JOIN ( select Condo_Code as Condo_Code1
                            ,   Condo_ENName as Condo_ENName1
                        from real_condo
                        where Condo_ENName LIKE '%\n%') real_condo1
            on cpc.Condo_Code = real_condo1.Condo_Code1
            left JOIN ( select Condo_Code as Condo_Code2
                            ,   Condo_ENName as Condo_ENName2
                        from real_condo
                        WHERE Condo_ENName NOT LIKE '%\n%' 
                        AND Condo_ENName NOT LIKE '%\r%') real_condo2
            on cpc.Condo_Code = real_condo2.Condo_Code2
            where cpc.Condo_Status = 1
            ORDER BY cpc.Condo_Code) condo_enname
on rc.Condo_Code = condo_enname.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_Name1,'\n',1),' ',SUBSTRING_INDEX(Condo_Name1,'\n',-1))
                    , Condo_Name2) as Condo_Name
            FROM real_condo AS cpc
            left JOIN ( select Condo_Code as Condo_Code1
                            ,   Condo_Name as Condo_Name1
                        from real_condo
                        where Condo_Name LIKE '%\n%') real_condo1
            on cpc.Condo_Code = real_condo1.Condo_Code1
            left JOIN ( select Condo_Code as Condo_Code2
                            ,   Condo_Name as Condo_Name2
                        from real_condo
                        WHERE Condo_Name NOT LIKE '%\n%' 
                        AND Condo_Name NOT LIKE '%\r%') real_condo2
            on cpc.Condo_Code = real_condo2.Condo_Code2
            where cpc.Condo_Status = 1
            ORDER BY cpc.Condo_Code) condo_thname
on rc.Condo_Code = condo_thname.Condo_Code
left join realist_score sc on rc.Condo_Code = sc.Condo_Code
where rc.Condo_Status = 1
order by rc.Condo_Code;

-- Table `search_condo_detail_view`
CREATE TABLE IF NOT EXISTS `search_condo_detail_view` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(50) NOT NULL,
    Condo_Name VARCHAR(250) NULL,
    Condo_ENName VARCHAR(150) NULL,
    Condo_Name_Search VARCHAR(250) NULL,
    Condo_ENName_Search VARCHAR(150) NULL,
    Brand_Name VARCHAR(150) NULL,
    Brand_Name_TH VARCHAR(250) NULL,
    Developer_THName VARCHAR(200) NULL,
    Developer_ENName VARCHAR(150) NULL,
    Condo_Latitude DOUBLE NULL,
    Condo_Longitude DOUBLE NULL,
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
    Segment_Name VARCHAR(200) NULL,
    Condo_Around_Station TEXT NULL,
    Condo_Around_Line TEXT NULL,
    Express_Way TEXT NULL,
    Condo_Spotlight TEXT NULL,
    Condo_URL TEXT NULL,
    Condo_Cover Text NULL,
    Realist_Score DOUBLE NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_condo_detail_view
DROP PROCEDURE IF EXISTS truncateInsert_search_condo_detail_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_condo_detail_view ()
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
    DECLARE v_name22 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name23 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name24 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name25 TEXT DEFAULT NULL;
    DECLARE v_name26 TEXT DEFAULT NULL;
    DECLARE v_name27 TEXT DEFAULT NULL;
    DECLARE v_name28 TEXT DEFAULT NULL;
    DECLARE v_name29 TEXT DEFAULT NULL;
    DECLARE v_name30 TEXT DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_condo_detail_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code,Condo_Name,Condo_ENName,Condo_Name_Search,Condo_ENName_Search,Brand_Name,Brand_Name_TH
                                ,Developer_THName,Developer_ENName,Condo_Latitude,Condo_Longitude,Road_Name,Sub_DistrictTH,Sub_DistrictEN
                                ,DistrictTH,DistrictEN,ProvinceTH,ProvinceEN,Real_SubDistrictTH,Real_SubDistrictEN,Real_DistrictTH
                                ,Real_DistrictEN,StationTH,StationEN,Segment_Name,Condo_Around_Station,Condo_Around_Line,Express_Way
                                ,Condo_URL,Condo_Cover,Realist_Score
                            FROM source_search_condo_detail_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_condo_detail_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_condo_detail_view(
                `Condo_Code`,
                `Condo_Name`,    
                `Condo_ENName`,
                `Condo_Name_Search`,    
                `Condo_ENName_Search`,
                `Brand_Name`,
                `Brand_Name_TH`,
                `Developer_THName`,
                `Developer_ENName`,
                `Condo_Latitude`,
                `Condo_Longitude`,
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
                `Segment_Name`,
                `Condo_Around_Station`,
                `Condo_Around_Line`,
                `Express_Way`,
                `Condo_URL`,
                `Condo_Cover`,
                `Realist_Score`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30);
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

-- search_condo_detail_getCondoTopSpotlight
DROP PROCEDURE IF EXISTS search_condo_detail_getCondoTopSpotlight;
DELIMITER //

CREATE PROCEDURE search_condo_detail_getCondoTopSpotlight(IN Condo_Code VARCHAR(50), OUT finalSpotlight_Name TEXT)
BEGIN

	DECLARE done				BOOLEAN			DEFAULT FALSE;
	DECLARE eachSpotlight_Code	VARCHAR(250)	DEFAULT NULL;
	DECLARE eachSpotlight_Name	VARCHAR(250)	DEFAULT NULL;
	DECLARE queryBase1			VARCHAR(1000)	DEFAULT "SELECT COUNT(1) INTO @spotlightCount FROM condo_spotlight_relationship_view CSRV WHERE CSRV.Condo_Code = '";
	DECLARE queryBase2			VARCHAR(100)	DEFAULT "' AND ";
	DECLARE queryBase3			VARCHAR(100)	DEFAULT "= 'Y'";
	DECLARE queryFinal			VARCHAR(2000)	DEFAULT NULL;
	DECLARE	queryResultCount	INTEGER			DEFAULT 0;
	DECLARE stmt 				VARCHAR(2000);

	DECLARE curTopSpotlight
	CURSOR FOR
		SELECT RCS.Spotlight_Code, RCS.Spotlight_Name 
		FROM real_condo_spotlight RCS
		WHERE RCS.Condo_Count > 0;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET finalSpotlight_Name = "";
	SET queryBase1 = CONCAT(queryBase1, Condo_Code, queryBase2);
	
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

-- search_condo_detail_update_spotlight
DROP PROCEDURE IF EXISTS search_condo_detail_update_spotlight;
DELIMITER //

CREATE PROCEDURE search_condo_detail_update_spotlight ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE condo	    VARCHAR(50) DEFAULT 0;
    DECLARE mySpotlight	TEXT;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'search_condo_detail_update_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code FROM condo_spotlight_relationship_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',condo);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO condo;

        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL search_condo_detail_getCondoTopSpotlight(condo, mySpotlight);
        UPDATE search_condo_detail_view
        SET Condo_Spotlight = mySpotlight
        WHERE Condo_Code = condo;

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

-- source_search_category_spotlight
CREATE OR REPLACE VIEW source_search_category_spotlight as
select Spotlight_Code
    , Spotlight_Name
    , REGEXP_REPLACE(Spotlight_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Spotlight_Name_Search
    , Keyword_TH
    , Keyword_ENG
    , concat('/realist/condo/list/spotlight/',REGEXP_REPLACE(Spotlight_Name,' ','-'),'/') as Spotlight_URL
from real_condo_spotlight
where Condo_Count > 0;

-- Table `search_category_spotlight`
CREATE TABLE IF NOT EXISTS `search_category_spotlight` (
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

-- truncateInsert_search_category_spotlight
DROP PROCEDURE IF EXISTS truncateInsert_search_category_spotlight;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_spotlight ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 TEXT DEFAULT NULL;
    DECLARE v_name3 TEXT DEFAULT NULL;
    DECLARE v_name4 TEXT DEFAULT NULL;
    DECLARE v_name5 TEXT DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Spotlight_Code,Spotlight_Name,Spotlight_Name_Search,Keyword_TH,Keyword_ENG,Spotlight_URL
                            FROM source_search_category_spotlight;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_spotlight;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_spotlight(
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

-- source_search_category_segment
CREATE OR REPLACE VIEW source_search_category_segment as
select Segment_Code
    , Segment_Name
    , concat('/realist/condo/list/segment/',REGEXP_REPLACE(Segment_Name,' ','-'),'/') as Segment_URL
from real_condo_segment
where Condo_Count > 0;

-- Table `search_category_segment`
CREATE TABLE IF NOT EXISTS `search_category_segment` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Segment_Code VARCHAR(30) NOT NULL,
    Segment_Name VARCHAR(200) NOT NULL,
    Segment_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_segment
DROP PROCEDURE IF EXISTS truncateInsert_search_category_segment;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_segment ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_segment';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Segment_Code,Segment_Name,Segment_URL
                            FROM source_search_category_segment;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_segment;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_segment(
                `Segment_Code`,
                `Segment_Name`,    
                `Segment_URL`
                )
        VALUES(v_name,v_name1,v_name2);
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

-- source_search_category_province
CREATE OR REPLACE VIEW source_search_category_province as
select province_code
    , name_th
    , name_en
    , REGEXP_REPLACE(name_th, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as name_th_Search
    , REGEXP_REPLACE(name_en, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as name_en_Search
    , concat('/realist/condo/list/จังหวัด/',REGEXP_REPLACE(name_th,' ','-'),'/') as Province_URL
from thailand_province
where Condo_Count > 0;

-- Table `search_category_province`
CREATE TABLE IF NOT EXISTS `search_category_province` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    province_code VARCHAR(4) NOT NULL,
    name_th VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    name_th_Search VARCHAR(150) NOT NULL,
    name_en_Search VARCHAR(150) NOT NULL,
    Province_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_province
DROP PROCEDURE IF EXISTS truncateInsert_search_category_province;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_province ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_province';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT province_code,name_th,name_en,name_th_Search,name_en_Search,Province_URL
                            FROM source_search_category_province;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_province;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_province(
                `province_code`,
                `name_th`,    
                `name_en`,
                `name_th_Search`,    
                `name_en_Search`,
                `Province_URL`
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

-- souce_search_category_developer
CREATE OR REPLACE VIEW source_search_category_developer as
select Developer_Code
    , Developer_THName
    , Developer_ENName
    , REGEXP_REPLACE(Developer_THName, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Developer_THName_Search
    , REGEXP_REPLACE(Developer_ENName, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Developer_ENName_Search
    , concat('/realist/condo/list/developer/',REGEXP_REPLACE(Developer_ENName,' ','-'),'/') as Developer_URL
from condo_developer
where Developer_Status = 1
and Condo_Count > 0;

-- Table `search_category_developer`
CREATE TABLE IF NOT EXISTS `search_category_developer` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Developer_Code VARCHAR(20) NOT NULL,
    Developer_THName VARCHAR(200) NOT NULL,
    Developer_ENName VARCHAR(200) NOT NULL,
    Developer_THName_Search VARCHAR(200) NOT NULL,
    Developer_ENName_Search VARCHAR(200) NOT NULL,
    Developer_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_developer
DROP PROCEDURE IF EXISTS truncateInsert_search_category_developer;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_developer ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 TEXT DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_developer';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Developer_Code,Developer_THName,Developer_ENName,Developer_THName_Search
                                    ,Developer_ENName_Search,Developer_URL
                            FROM source_search_category_developer;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_developer;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_developer(
                `Developer_Code`,
                `Developer_THName`,    
                `Developer_ENName`,
                `Developer_THName_Search`,    
                `Developer_ENName_Search`,
                `Developer_URL`
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

-- source_search_category_brand
CREATE OR REPLACE VIEW source_search_category_brand as
select Brand_Code
    , Brand_Name
    , Brand_Name_TH
    , REGEXP_REPLACE(Brand_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Brand_Name_Search
    , REGEXP_REPLACE(Brand_Name_TH, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Brand_Name_TH_Search
    , concat('/realist/condo/list/brand/',REGEXP_REPLACE(Brand_Name,' ','-'),'/') as Brand_URL
from brand
where Brand_Status = 1
and Condo_Count > 0;

-- Table `search_category_brand`
CREATE TABLE IF NOT EXISTS `search_category_brand` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Brand_Code VARCHAR(50) NOT NULL,
    Brand_Name VARCHAR(150) NOT NULL,
    Brand_Name_TH VARCHAR(250) NULL,
    Brand_Name_Search VARCHAR(150) NOT NULL,
    Brand_Name_TH_Search VARCHAR(250) NULL,
    Brand_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_brand
DROP PROCEDURE IF EXISTS truncateInsert_search_category_brand;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_brand ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 TEXT DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_brand';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Brand_Code,Brand_Name,Brand_Name_TH,Brand_Name_Search,Brand_Name_TH_Search,Brand_URL
                            FROM source_search_category_brand;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_brand;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_brand(
                `Brand_Code`,
                `Brand_Name`,
                `Brand_Name_TH`,    
                `Brand_Name_Search`,
                `Brand_Name_TH_Search`,   
                `Brand_URL`
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

-- source_search_category_line
CREATE OR REPLACE VIEW source_search_category_line as
select Line_Code
    , Line_Name
    , Line_Name_Eng
    , REGEXP_REPLACE(Line_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Line_Name_Search
    , REGEXP_REPLACE(Line_Name_Eng, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Line_Name_Eng_Search
    , concat('/realist/condo/list/รถไฟฟ้า/',REGEXP_REPLACE(Line_Name,' ','-'),'/') as Line_URL
from  mass_transit_line
where Condo_Count > 0;

-- Table `search_category_line`
CREATE TABLE IF NOT EXISTS `search_category_line` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Line_Code VARCHAR(30) NOT NULL,
    Line_Name VARCHAR(50) NOT NULL,
    Line_Name_Eng VARCHAR(50) NULL,
    Line_Name_Search VARCHAR(50) NOT NULL,
    Line_Name_Eng_Search VARCHAR(50) NULL,
    Line_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_line
DROP PROCEDURE IF EXISTS truncateInsert_search_category_line;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_line ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 TEXT DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_line';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Line_Code,Line_Name,Line_Name_Eng,Line_Name_Search,Line_Name_Eng_Search,Line_URL
                            FROM source_search_category_line;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_line;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_line(
                `Line_Code`,
                `Line_Name`,
                `Line_Name_Eng`,
                `Line_Name_Search`,
                `Line_Name_Eng_Search`,    
                `Line_URL`
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

--source_search_category_station
CREATE OR REPLACE VIEW source_search_category_station as
select mtsm.Station_Code
    , ml.Line_Name
    , ml.Line_Name_Eng
    , ms.Station_THName
    , ms.Station_ENName
    , ms.Station_THName_Display
    , ms.Station_ENName_Display
    , REGEXP_REPLACE(ms.Station_THName_Display, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Station_THName_Display_Search
    , REGEXP_REPLACE(ms.Station_ENName_Display, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as Station_ENName_Display_Search
    , concat('/realist/condo/list/รถไฟฟ้า/',REGEXP_REPLACE(ml.Line_Name,' ','-'),'/',REGEXP_REPLACE(ms.Station_THName_Display,' ','-')) as Station_URL
from mass_transit_station_match_route mtsm
left join mass_transit_route mr on mtsm.Route_Code = mr.Route_Code
left join mass_transit_line ml on mr.Line_Code = ml.Line_Code
left join mass_transit_station ms on mtsm.Station_Code = ms.Station_Code
where ms.Condo_Count > 0;

-- Table `search_category_station`
CREATE TABLE IF NOT EXISTS `search_category_station` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Station_Code VARCHAR(100) NOT NULL,
    Line_Name VARCHAR(50) NOT NULL,
    Line_Name_Eng VARCHAR(50) NULL,
    Station_THName VARCHAR(100) NOT NULL,
    Station_ENName VARCHAR(100) NOT NULL,
    Station_THName_Display VARCHAR(200) NOT NULL,
    Station_ENName_Display VARCHAR(200) NOT NULL,
    Station_THName_Display_Search VARCHAR(200) NOT NULL,
    Station_ENName_Display_Search VARCHAR(200) NOT NULL,
    Station_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_station
DROP PROCEDURE IF EXISTS truncateInsert_search_category_station;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_station ()
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
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_station';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Station_Code,Line_Name,Line_Name_Eng,Station_THName,Station_ENName
                                , Station_THName_Display,Station_ENName_Display
                                , Station_THName_Display_Search,Station_ENName_Display_Search,Station_URL
                            FROM source_search_category_station;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_station;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_station(
                `Station_Code`,
                `Line_Name`,
                `Line_Name_Eng`,
                `Station_THName`,    
                `Station_ENName`,
                `Station_THName_Display`,    
                `Station_ENName_Display`,
                `Station_THName_Display_Search`,    
                `Station_ENName_Display_Search`,
                `Station_URL`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9);
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

-- source_search_category_realist_district
CREATE OR REPLACE VIEW source_search_category_realist_district as
select District_Code
    , District_Name
    , REGEXP_REPLACE(District_Name_ENG,concat(District_Code,'-'),'') as District_Name_ENG
    , REGEXP_REPLACE(District_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as District_Name_Search
    , REGEXP_REPLACE(REGEXP_REPLACE(District_Name_ENG,concat(District_Code,'-'),''), '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as District_Name_ENG_Search
    , concat('/realist/condo/list/ย่าน/',REGEXP_REPLACE(District_Name,' ','-'),'/') as Real_District_URL
from  real_yarn_main
where Condo_Count > 0;

-- Table `search_category_realist_district`
CREATE TABLE IF NOT EXISTS `search_category_realist_district` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    District_Code VARCHAR(20) NOT NULL,
    District_Name VARCHAR(150) NOT NULL,
    District_Name_ENG VARCHAR(150) NOT NULL,
    District_Name_Search VARCHAR(150) NOT NULL,
    District_Name_ENG_Search VARCHAR(150) NOT NULL,
    Real_District_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_realist_district
DROP PROCEDURE IF EXISTS truncateInsert_search_category_realist_district;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_realist_district ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_realist_district';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT District_Code,District_Name,District_Name_ENG
                                    ,District_Name_Search,District_Name_ENG_Search,Real_District_URL
                            FROM source_search_category_realist_district;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_realist_district;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_realist_district(
                `District_Code`,
                `District_Name`,    
                `District_Name_ENG`,
                `District_Name_Search`,    
                `District_Name_ENG_Search`,
                `Real_District_URL`
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

-- source_search_category_realist_subdistrict
CREATE OR REPLACE VIEW source_search_category_realist_subdistrict as
select rs.SubDistrict_Code
    , rs.SubDistrict_Name
    , REGEXP_REPLACE(rs.SubDistrict_Name_ENG,concat(rs.SubDistrict_Code,'-'),'') as SubDistrict_Name_ENG
    , REGEXP_REPLACE(rs.SubDistrict_Name, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as SubDistrict_Name_Search
    , REGEXP_REPLACE(REGEXP_REPLACE(rs.SubDistrict_Name_ENG,concat(rs.SubDistrict_Code,'-'),''), '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as SubDistrict_Name_ENG_Search
    , concat('/realist/condo/list/ย่าน/',rm.District_Name,'/',REGEXP_REPLACE(rs.SubDistrict_Name,' ','-')) as Real_SubDistrict_URL
from real_yarn_main rm
left join real_yarn_sub rs on rm.District_Code = rs.District_Code
where rs.Condo_Count > 0;

-- Table `search_category_realist_subdistrict`
CREATE TABLE IF NOT EXISTS `search_category_realist_subdistrict` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    SubDistrict_Code VARCHAR(10) NOT NULL,
    SubDistrict_Name VARCHAR(250) NOT NULL,
    SubDistrict_Name_ENG VARCHAR(200) NOT NULL,
    SubDistrict_Name_Search VARCHAR(250) NOT NULL,
    SubDistrict_Name_ENG_Search VARCHAR(200) NOT NULL,
    Real_SubDistrict_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_realist_subdistrict
DROP PROCEDURE IF EXISTS truncateInsert_search_category_realist_subdistrict;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_realist_subdistrict ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_realist_subdistrict';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT SubDistrict_Code,SubDistrict_Name,SubDistrict_Name_ENG
                                    ,SubDistrict_Name_Search,SubDistrict_Name_ENG_Search,Real_SubDistrict_URL
                            FROM source_search_category_realist_subdistrict;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_realist_subdistrict;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_realist_subdistrict(
                `SubDistrict_Code`,
                `SubDistrict_Name`,    
                `SubDistrict_Name_ENG`,
                `SubDistrict_Name_Search`,    
                `SubDistrict_Name_ENG_Search`,
                `Real_SubDistrict_URL`
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

-- source_search_category_district
CREATE OR REPLACE VIEW source_search_category_district AS
SELECT
    td.district_code AS district_code,
    td.name_th AS name_th,
    td.name_en AS name_en,
    REGEXP_REPLACE(td.name_th, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as name_th_Search,
    REGEXP_REPLACE(td.name_en, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as name_en_Search,
    concat('/realist/condo/list/จังหวัด/',tp.name_th,'/',td.name_th) AS District_URL
FROM thailand_district td
left join thailand_province tp on td.province_id = tp.province_code
WHERE td.Condo_Count > 0
AND tp.Condo_Count > 0;

-- Table `search_category_district`
CREATE TABLE `search_category_district` (
    ID int UNSIGNED NOT NULL AUTO_INCREMENT,
    District_Code varchar(10) NOT NULL,
    District_Name varchar(250) NOT NULL,
    District_Name_ENG varchar(200) NOT NULL,
    District_Name_Search varchar(250) NOT NULL,
    District_Name_ENG_Search varchar(200) NOT NULL,
    District_URL text NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_district
DROP PROCEDURE IF EXISTS truncateInsert_search_category_district;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_district ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_district';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT district_code,name_th,name_en,name_th_Search,name_en_Search,District_URL
                            FROM source_search_category_district;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_district;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_district(
                `District_Code`,
                `District_Name`,    
                `District_Name_ENG`,
                `District_Name_Search`,    
                `District_Name_ENG_Search`,
                `District_URL`
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

-- source_search_category_subdistrict
CREATE OR REPLACE VIEW source_search_category_subdistrict as
select ts.subdistrict_code
    , ts.name_th
    , ts.name_en
    , REGEXP_REPLACE(ts.name_th, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as name_th_Search
    , REGEXP_REPLACE(ts.name_en, '[!@#\\$%^&*()_+{}\\[\\]:;<>,.?~\\\\|/`''"\\s-]', '') as name_en_Search
    , concat('/realist/condo/list/จังหวัด/',REGEXP_REPLACE(tp.name_th,' ','-'),'/',REGEXP_REPLACE(td.name_th,' ','-'),'/',REGEXP_REPLACE(ts.name_th,' ','-')) as SubDistrict_URL
from thailand_subdistrict ts
left join thailand_district td on ts.district_id = td.district_code
left join thailand_province tp on td.province_id = tp.province_code
where td.Condo_Count > 0
and tp.Condo_Count > 0
and ts.Condo_Count > 0;

-- Table `search_category_subdistrict`
CREATE TABLE IF NOT EXISTS `search_category_subdistrict` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    SubDistrict_Code VARCHAR(10) NOT NULL,
    SubDistrict_Name VARCHAR(250) NOT NULL,
    SubDistrict_Name_ENG VARCHAR(200) NOT NULL,
    SubDistrict_Name_Search VARCHAR(250) NOT NULL,
    SubDistrict_Name_ENG_Search VARCHAR(200) NOT NULL,
    SubDistrict_URL TEXT NOT NULL,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- truncateInsert_search_category_subdistrict
DROP PROCEDURE IF EXISTS truncateInsert_search_category_subdistrict;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_category_subdistrict ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    
    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_search_category_subdistrict';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT subdistrict_code,name_th,name_en,name_th_Search,name_en_Search,SubDistrict_URL
                            FROM source_search_category_subdistrict;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_category_subdistrict;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_category_subdistrict(
                `SubDistrict_Code`,
                `SubDistrict_Name`,    
                `SubDistrict_Name_ENG`,
                `SubDistrict_Name_Search`,    
                `SubDistrict_Name_ENG_Search`,
                `SubDistrict_URL`
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


-- truncateInsertViewSearch
DROP PROCEDURE IF EXISTS truncateInsertViewSearch;
DELIMITER $$

CREATE PROCEDURE truncateInsertViewSearch ()
BEGIN

    CALL truncateInsert_search_condo_detail_view ();
    CALL search_condo_detail_update_spotlight ();
    CALL truncateInsert_search_category_spotlight ();
    CALL truncateInsert_search_category_segment ();
    CALL truncateInsert_search_category_province ();
    CALL truncateInsert_search_category_developer ();
    CALL truncateInsert_search_category_brand ();
    CALL truncateInsert_search_category_line ();
    CALL truncateInsert_search_category_station ();
    CALL truncateInsert_search_category_realist_district ();
    CALL truncateInsert_search_category_realist_subdistrict ();
    CALL truncateInsert_search_category_district ();
    CALL truncateInsert_search_category_subdistrict ();

END$$
DELIMITER ;


-- truncateInsertViewToTable
DROP PROCEDURE IF EXISTS truncateInsertViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertViewToTable ()
BEGIN

	CALL truncateInsert_condo_price_calculate_view ();
    CALL truncateInsert_condo_spotlight_relationship_view ();
	CALL truncateInsert_condo_fetch_for_map ();
    CALL ads_update_spotlight ();
    CALL truncateInsert_all_condo_spotlight_relationship ();
    CALL ads_update_allspotlight ();
	CALL truncateInsert_mass_transit_station_match_route ();
    CALL truncateInsert_full_template_factsheet ();
    CALL truncateInsert_full_template_element_image_view ();
    CALL truncateInsert_full_template_credit_view ();
    CALL truncateInsert_full_template_facilities_icon_view ();
    CALL truncateInsert_full_template_section_shortcut_view ();
    CALL truncateInsert_full_template_unit_plan_fullscreen_view ();
    CALL truncateInsert_full_template_unit_gallery_fullscreen_view ();
    CALL truncateInsert_full_template_floor_plan_fullscreen_view ();
    CALL truncateInsert_full_template_facilities_gallery_fullscreen_view ();
    CALL truncateInsertViewSearch ();

END$$
DELIMITER ;