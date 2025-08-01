-- table classified_condo_education
-- view source_search_classified_education
-- procedure truncateInsert_classified_condo_education
-- view source_search_classified

ALTER TABLE `real_place_education` ADD `polygon` polygon NULL AFTER `Education_Boundary`;
ALTER TABLE `real_place_education` ADD `Condo_Count` INT NOT NULL AFTER `polygon`;
ALTER TABLE `real_place_education` ADD `Housing_Count` INT NOT NULL AFTER `Condo_Count`;
ALTER TABLE `real_place_education` ADD `Classified_Unit_Count` INT NOT NULL AFTER `Housing_Count`;

-- table
CREATE TABLE `classified_condo_education` (
    `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` int UNSIGNED NOT NULL,
    `Education` JSON NOT NULL,
    PRIMARY KEY (`ID`))
ENGINE=InnoDB;

-- view
create or replace view source_search_classified_education as
select c.Classified_ID
    , CONCAT('[',CONCAT_WS(',',school_only.Place_ID, collage_only.Place_ID),']') AS `Education`
from classified c
left join (select Classified_ID
                , group_concat(Place_ID separator ',') AS Place_ID
            from (select Classified_ID
                        , concat('"',Place_ID,'"') as Place_ID
                        , Place_Name
                        , Place_category
                        , Distance
                    from (SELECT pe.Place_ID
                                , pe.Place_Name
                                , pe.Place_category
                                , pe.Place_Latitude
                                , pe.Place_Longitude
                                , c.Classified_ID
                                , c.Condo_Code
                                , c.Condo_Latitude
                                , c.Condo_Longitude
                                , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(c.Condo_Latitude - pe.Place_Latitude)) / 2), 2)
                                    + COS(RADIANS(pe.Place_Latitude)) * COS(RADIANS(c.Condo_Latitude)) *
                                    POWER(SIN((RADIANS(c.Condo_Longitude - pe.Place_Longitude)) / 2), 2 )))) AS Distance
                            FROM real_place_education pe
                            cross join (select a.classified_ID
                                            , a.Condo_Code
                                            , b.Condo_Latitude
                                            , b.Condo_Longitude
                                        from classified a
                                        left join real_condo b on a.Condo_Code = b.Condo_Code
                                        where a.classified_status = '1'
                                        and b.Condo_Latitude is not null
                                        and b.Condo_Longitude is not null) c
                            where pe.Place_category in ('โรงเรียน','โรงเรียนนานาชาติ')) aaa
                    where aaa.Distance <= 1.8) school
            group by Classified_ID) school_only
on c.Classified_ID = school_only.Classified_ID
left join (select Classified_ID
                        , group_concat(Place_ID separator ',') AS Place_ID
                    from (select Classified_ID
                                , concat('"',Place_ID,'"') as Place_ID
                                , Place_Name
                                , Place_category
                                , 0 as Distance
                            from (select a.Classified_ID
                                    , a.Condo_Code
                                    , b.Condo_Latitude
                                    , b.Condo_Longitude
                                    , pe.Place_ID
                                    , pe.Place_Name
                                    , pe.Place_category
                                    , pe.Place_Latitude
                                    , pe.Place_Longitude
                                from classified a
                                join real_condo b on a.Condo_Code = b.Condo_Code
                                JOIN real_place_education AS pe ON ST_Contains(pe.polygon, ST_GeomFromText(CONCAT('POINT(', b.Condo_Longitude, ' ', b.Condo_Latitude, ')')))
                                where a.classified_status = '1'
                                and b.Condo_Latitude is not null
                                and b.Condo_Longitude is not null
                                and pe.Place_category not in ('โรงเรียน','โรงเรียนนานาชาติ')) bbb) college
                group by Classified_ID) collage_only
on c.Classified_ID = collage_only.Classified_ID
where c.Classified_Status = '1'
and (school_only.Place_ID is not null or collage_only.Place_ID is not null)
group by c.Classified_ID;

-- procedure
DROP PROCEDURE IF EXISTS truncateInsert_classified_condo_education;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_condo_education ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 JSON DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_condo_education';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID, Education FROM source_search_classified_education;
	
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE classified_condo_education;
	
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			classified_condo_education (
				Classified_ID,
				Education
			)
		VALUES(v_name,v_name1);
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


-- view search_classified
create or replace view source_search_classified as
select c.Classified_ID
    , c.Condo_Code
    , cf.Condo_Age
    , c.Title_TH
    , c.Title_ENG
    , c.Price_Rent
    , c.Price_Sale
    , c.Bedroom
    , c.Bathroom
    , c.Size
    , JSON_ARRAY(CAST(cf.Province_ID as CHAR),CAST(cf.District_ID as CHAR),CAST(cf.SubDistrict_ID as CHAR)) as Search_Province
    , JSON_ARRAY(cf.RealDistrict_Code,cf.RealSubDistrict_Code) as Search_Realist_Yarn
    , CONCAT('[',CONCAT_WS(',',condo_line.Condo_Around_Line,station.Condo_Around_Station),']') as Search_Mass_Transit
    , cce.Education as Search_Education
    , NULL as Search_Airport
    , NULL as Search_Custom_Yarn
    , CONCAT('[',TRIM(TRAILING ',' FROM replace(replace(cf.Spotlight_List,'[','"'),']','",')),']') as Search_Spotlight
    , c.Last_Update_Insert_Date as Last_Updated_Date
    , rc.Condo_ENName as Condo_Name
    , ifnull(classified_image.Image,concat('https://thelist.group/realist/condo/uploads/condo/',c.Condo_Code,'/',c.Condo_Code,'-PE-01-Exterior-H-1920.webp')) as Image
    , tp.name_th as Province_Name
    , td.name_th as District_Name
    , cv.Badge_Home as Badge_Home
    , cv.Badge_Listing_or_Template as Badge_Listing_or_Template
    , rc.Condo_Latitude as Condo_Latitude
    , rc.Condo_Longitude as Condo_Longitude
    , rc.Condo_ScopeArea as Condo_ScopeArea
    , JSON_ARRAY(rc.Brand_Code,rc.Developer_Code,rcp.Condo_Segment) as Search_Detail
from classified c
join condo_fetch_for_map cf on c.Condo_Code = cf.Condo_Code
join real_condo rc on c.Condo_Code = rc.Condo_Code
join thailand_district td on cf.District_ID = td.district_code
join thailand_province tp on cf.Province_ID = tp.province_code
left join real_condo_price rcp on c.Condo_Code = rcp.Condo_Code
left join (select Classified_ID,JSON_ARRAYAGG( JSON_OBJECT('Classified_Image_ID',Classified_Image_ID
                                                    , 'Classified_Image_Type',Classified_Image_Type
                                                    , 'Classified_Image_Caption',Classified_Image_Caption
                                                    , 'Classified_Image_URL',concat('/realist/condo/uploads/classified/',lpad(Classified_ID,6,0),'/',Classified_Image_URL)
                                                    , 'Displayed_Order_in_Classified',Displayed_Order_in_Classified)) as Image
    from classified_image
    where Classified_Image_Status = '1'
    group by Classified_ID) classified_image
on c.Classified_ID = classified_image.Classified_ID
left join ( select Condo_Code
                , group_concat(Line_Code separator ',') AS `Condo_Around_Line`
            from ( SELECT Condo_Code
                        , concat('"',Line_Code,'"') as Line_Code
                    FROM `condo_around_station`
                    group by Condo_Code,Line_Code) c_line
            group by Condo_Code) condo_line
on c.Condo_Code = condo_line.Condo_Code
left join (select Condo_Code AS Condo_Code
                , group_concat(Station_Code separator ',') AS Condo_Around_Station
            from ( SELECT Condo_Code
                        , concat('"',Station_Code,'"') as Station_Code
                    FROM `condo_around_station`
                    group by Condo_Code,Station_Code) c_station
            group by Condo_Code) station 
on c.Condo_Code = station.Condo_Code
left join classified_list_view cv on c.Classified_ID = cv.Classified_ID
left join classified_condo_education cce on c.Classified_ID = cce.Classified_ID
where c.Classified_Status = '1';

-- table search_classified
create table if not exists search_classified (
    ID int unsigned not null auto_increment,
    Classified_ID int unsigned not null,
    Condo_Code varchar(50) not null,
    Condo_Age int unsigned null,
    Title_TH text null,
    Title_ENG text null,
    Price_Rent int unsigned null,
    Price_Sale int unsigned null,
    Bedroom varchar(4) null,
    Bathroom smallint unsigned null,
    Size float(8,3) unsigned null,
    Search_Province JSON null,
    Search_Realist_Yarn JSON null,
    Search_Mass_Transit JSON null,
    Search_Education JSON null,
    Search_Airport JSON null,
    Search_Custom_Yarn JSON null,
    Search_Spotlight JSON null,
    Last_Updated_Date timestamp null,
    Condo_Name varchar(250) null,
    Image TEXT null,
    Province_Name varchar(250) null,
    District_Name varchar(250) null,
    Badge_Home JSON null,
    Badge_Listing_or_Template JSON null,
    Condo_Latitude double null,
    Condo_Longitude double null,
    Condo_ScopeArea TEXT null,
    Search_Detail JSON null,
    primary key (ID),
    INDEX search_lat (Condo_Latitude),
    INDEX search_lon (Condo_Longitude)
) ENGINE = InnoDB;

-- truncateInsert_search_classified
DROP PROCEDURE IF EXISTS truncateInsert_search_classified;
DELIMITER //

CREATE PROCEDURE truncateInsert_search_classified ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name  VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 TEXT         DEFAULT NULL;
    DECLARE v_name4 TEXT         DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name10 JSON        DEFAULT NULL;
    DECLARE v_name11 JSON        DEFAULT NULL;
    DECLARE v_name12 JSON        DEFAULT NULL;
    DECLARE v_name13 JSON        DEFAULT NULL;
    DECLARE v_name14 JSON        DEFAULT NULL;
    DECLARE v_name15 JSON        DEFAULT NULL;
    DECLARE v_name16 JSON        DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name19 TEXT DEFAULT NULL;
    DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name22 JSON DEFAULT NULL;
    DECLARE v_name23 JSON DEFAULT NULL;
    DECLARE v_name24 double DEFAULT NULL;
    DECLARE v_name25 double DEFAULT NULL;
    DECLARE v_name26 TEXT DEFAULT NULL;
    DECLARE v_name27 JSON DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_search_classified';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID, Condo_Code, Condo_Age, Title_TH, Title_ENG, Price_Rent, Price_Sale, Bedroom, Bathroom, Size
                                , Search_Province, Search_Realist_Yarn, Search_Mass_Transit, Search_Education, Search_Airport, Search_Custom_Yarn
                                , Search_Spotlight, Last_Updated_Date, Condo_Name, Image, Province_Name, District_Name
                                , Badge_Home, Badge_Listing_or_Template, Condo_Latitude, Condo_Longitude, Condo_ScopeArea, Search_Detail
                            FROM source_search_classified ;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE search_classified;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            search_classified(
                `Classified_ID`,
                `Condo_Code`,
                `Condo_Age`,
                `Title_TH`,
                `Title_ENG`,
                `Price_Rent`,
                `Price_Sale`,
                `Bedroom`,
                `Bathroom`,
                `Size`,
                `Search_Province`,
                `Search_Realist_Yarn`,
                `Search_Mass_Transit`,
                `Search_Education`,
                `Search_Airport`,
                `Search_Custom_Yarn`,
                `Search_Spotlight`,
                `Last_Updated_Date`,
                `Condo_Name`,
                `Image`,
                `Province_Name`,
                `District_Name`,
                `Badge_Home`,
                `Badge_Listing_or_Template`,
                `Condo_Latitude`,
                `Condo_Longitude`,
                `Condo_ScopeArea`,
                `Search_Detail`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27);
        
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