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
    , concat_ws(' ',LPAD(cf.Province_ID,4,'0'),cf.District_ID,cf.SubDistrict_ID) as Search_Province
    , concat_ws(' ',LPAD(cf.RealDistrict_Code,4,'0'),cf.RealSubDistrict_Code) as Search_Realist_Yarn
    , concat_ws(' ',condo_line.Condo_Around_Line,station.Condo_Around_Station) as Search_Mass_Transit
    , '' as Search_University
    , '' as Search_Airport
    , '' as Search_Custom_Yarn
    , trim(replace(replace(cf.Spotlight_List,'[',''),']',' ')) as Search_Spotlight
    , c.Last_Update_Insert_Date as Last_Updated_Date
    , rc.Condo_ENName as Condo_Name
    , classified_image.Image as Image
    , tp.name_th as Province_Name
    , td.name_th as District_Name
    , cv.Badge_Home as Badge_Home
    , cv.Badge_Listing_or_Template as Badge_Listing_or_Template
    , rc.Condo_Latitude as Condo_Latitude
    , rc.Condo_Longitude as Condo_Longitude
    , rc.Condo_ScopeArea as Condo_ScopeArea
    , concat_ws(' ',rc.Brand_Code,rc.Developer_Code,rcp.Condo_Segment) as Search_Detail
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
                , group_concat(Line_Code separator ' ') AS `Condo_Around_Line`
            from ( SELECT Condo_Code
                        , Line_Code
                    FROM `condo_around_station`
                    group by Condo_Code,Line_Code) c_line
            group by Condo_Code) condo_line
on c.Condo_Code = condo_line.Condo_Code
left join (select Condo_Code AS Condo_Code
                , group_concat(LPAD(Station_Code,8,'0') separator ' ') AS Condo_Around_Station
            from ( SELECT Condo_Code
                        , Station_Code
                    FROM `condo_around_station`
                    group by Condo_Code,Station_Code) c_station
            group by Condo_Code) station 
on c.Condo_Code = station.Condo_Code
left join classified_list_view cv on c.Classified_ID = cv.Classified_ID
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
    Search_Province text null,
    Search_Realist_Yarn text null,
    Search_Mass_Transit text null,
    Search_University text null,
    Search_Airport text null,
    Search_Custom_Yarn text null,
    Search_Spotlight text null,
    Last_Updated_Date timestamp null,
    Condo_Name varchar(250) null,
    Image text null,
    Province_Name varchar(250) null,
    District_Name varchar(250) null,
    Badge_Home text null,
    Badge_Listing_or_Template text null,
    Condo_Latitude double null,
    Condo_Longitude double null,
    Condo_ScopeArea TEXT null,
    Search_Detail TEXT null,
    primary key (ID),
    FULLTEXT (Search_Province),
    FULLTEXT (Search_Realist_Yarn),
    FULLTEXT (Search_Mass_Transit),
    FULLTEXT (Search_Spotlight)
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
    DECLARE v_name10 TEXT        DEFAULT NULL;
    DECLARE v_name11 TEXT        DEFAULT NULL;
    DECLARE v_name12 TEXT        DEFAULT NULL;
    DECLARE v_name13 TEXT        DEFAULT NULL;
    DECLARE v_name14 TEXT        DEFAULT NULL;
    DECLARE v_name15 TEXT        DEFAULT NULL;
    DECLARE v_name16 TEXT        DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name19 TEXT DEFAULT NULL;
    DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name22 TEXT DEFAULT NULL;
    DECLARE v_name23 TEXT DEFAULT NULL;
    DECLARE v_name24 double DEFAULT NULL;
    DECLARE v_name25 double DEFAULT NULL;
    DECLARE v_name26 TEXT DEFAULT NULL;
    DECLARE v_name27 TEXT DEFAULT NULL;

    DECLARE proc_name       VARCHAR(70) DEFAULT 'truncateInsert_search_classified';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID, Condo_Code, Condo_Age, Title_TH, Title_ENG, Price_Rent, Price_Sale, Bedroom, Bathroom, Size
                                , Search_Province, Search_Realist_Yarn, Search_Mass_Transit, Search_University, Search_Airport, Search_Custom_Yarn
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
                `Search_University`,
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