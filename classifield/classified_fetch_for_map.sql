-- table classified_condo_fetch_for_map
-- view source_classified_condo_fetch_for_map
-- procedure truncateInsert_classified_condo_fetch_for_map
-- classified_condo_fetch_for_map_getCondoSpotlight
-- classified_condo_fetch_for_map_update_spotlight

/* update classified set Sale = 0 where Price_Sale is null and classified_status = '1';
update classified set Rent = 0 where Price_Rent is null and classified_status = '1';
update classified set Sale = 1 where Price_Sale is not null and classified_status = '1';
update classified set Rent = 1 where Price_Rent is not null and classified_status = '1';
update classified set Sale_with_Tenant = 0 where Price_Sale is null and classified_status = '1';*/

-- table classified_condo_fetch_for_map
CREATE TABLE IF NOT EXISTS classified_condo_fetch_for_map (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(50) NOT NULL,
    Condo_ENName VARCHAR(150) NuLL,
    Condo_ScopeArea TEXT NULL,
    Condo_Latitude double NULL,
    Condo_Longitude double NULL,
    Room_Count_Sale int UNSIGNED null,
    Price_Sale_Min int UNSIGNED null,
    Use_Price_Sale_Min varchar(20) not null,
    Price_Sale_Sqm float null,
    Use_Price_Sale_Sqm varchar(20) not null,
    AVG_Price_Per_Unit_Sqm_Sale float null,
    Use_AVG_Per_Unit_Sqm_Sale varchar(20) null,
    Room_Count_Rent int UNSIGNED null,
    Price_Rent_Min int UNSIGNED null,
    Use_Price_Rent_Min varchar(20) not null,
    Price_Rent_Sqm float null,
    Use_Price_Rent_Sqm varchar(20) not null,
    AVG_Price_Per_Unit_Sqm_Rent float null,
    Use_AVG_Per_Unit_Sqm_Rent varchar(20) null,
    Condo_Segment varchar(10) null,
    Province_code varchar(4) null,
    District_Code varchar(20) null,
    SubDistrict_Code varchar(10) DEFAULT NULL,
    Developer_Code varchar(20) DEFAULT NULL,
    Brand_Code varchar(50) DEFAULT NULL,
    Condo_Around_Line json DEFAULT NULL,
    Condo_Around_Station json DEFAULT NULL,
    Condo_URL_Tag varchar(200) null,
    Condo_Cover int not null default 0,
    Total_Point double not null default 0, 
    Spotlight_List json DEFAULT NULL,
    PRIMARY KEY (ID),
    INDEX cfcode (Condo_Code),
    INDEX cfsegment (Condo_Segment),
    INDEX cfprovince (Province_code),
    INDEX cfdistrict (District_Code),
    INDEX cfsubdistrict (SubDistrict_Code),
    INDEX cfdev (Developer_Code),
    INDEX cfbrand (Brand_Code),
    INDEX cflat (Condo_Latitude),
    INDEX cflong (Condo_Longitude))
ENGINE = InnoDB;

-- view source_classified_condo_fetch_for_map
create or replace view source_classified_condo_fetch_for_map as
select rc.Condo_Code
    , rc.Condo_ENName as Condo_ENName
    , rc.Condo_ScopeArea AS Condo_ScopeArea
    , rc.Condo_Latitude AS Condo_Latitude
    , rc.Condo_Longitude AS Condo_Longitude
    , ifnull(total_sale.Total_Room_Count_Sale,0) as Room_Count_Sale
    , total_sale.Price_Sale_Min
    , if(ifnull(total_sale.Total_Room_Count_Sale,0) = 0
        , 'N/A'
        , round(total_sale.Price_Sale_Min/1000000,2)) as Use_Price_Sale_Min
    , total_sale.Price_Sale_Min / size_at_min_total_sale.Price_Sale_Min_Size as Price_Sale_Sqm
    , if(ifnull(total_sale.Total_Room_Count_Sale,0) = 0
        , 'N/A'
        , format(round(total_sale.Price_Sale_Min / size_at_min_total_sale.Price_Sale_Min_Size,-3),0)) as Use_Price_Sale_Sqm
    , if(ifnull(total_sale.Total_Room_Count_Sale,0) < 3
        , null
        , total_sale.Total_Price_Per_Unit_Sqm_Sale) as AVG_Price_Per_Unit_Sqm_Sale
    , if(ifnull(total_sale.Total_Room_Count_Sale,0) < 3
        , null
        , format(round(total_sale.Total_Price_Per_Unit_Sqm_Sale,-3),0)) as Use_AVG_Per_Unit_Sqm_Sale
    , ifnull(total_rent.Total_Room_Count_Rent,0) as Room_Count_Rent
    , total_rent.Price_Rent_Min
    , if(ifnull(total_rent.Total_Room_Count_Rent,0) = 0
        , 'N/A'
        , format(round(total_rent.Price_Rent_Min,-2),0)) as Use_Price_Rent_Min
    , total_rent.Price_Rent_Min / size_at_min_total_rent.Price_Rent_Min_Size as Price_Rent_Sqm
    , if(ifnull(total_rent.Total_Room_Count_Rent,0) = 0
        , 'N/A'
        , format(round(total_rent.Price_Rent_Min / size_at_min_total_rent.Price_Rent_Min_Size,-1),0)) as Use_Price_Rent_Sqm
    , if(ifnull(total_rent.Total_Room_Count_Rent,0) < 3
        , null
        , total_rent.Total_Price_Per_Unit_Sqm_Rent) as AVG_Price_Per_Unit_Sqm_Rent
    , if(ifnull(total_rent.Total_Room_Count_Rent,0) < 3
        , null
        , format(round(total_rent.Total_Price_Per_Unit_Sqm_Rent,-1),0)) as Use_AVG_Per_Unit_Sqm_Rent
    , rcp.Condo_Segment
    , tp.Province_code
    , rm.District_Code
    , rs.SubDistrict_Code
    , cd.Developer_Code
    , b.Brand_Code
    , aline.Condo_Around_Line
    , astation.Condo_Around_Station
    , rc.Condo_URL_Tag
    , rc.Condo_Cover
    , ifnull(rc.No_of_Unit_Point, 0) + ifnull(rc.Finish_Year_Point, 0) + ifnull(rc.HighRise_Point, 0)
        + ifnull(rc.ListCompany_Point, 0) + ifnull(rc.DistanceFromStation_Point, 0) AS Total_Point
from real_condo rc
left join real_condo_price rcp on rc.Condo_Code = rcp.Condo_Code
left join thailand_province tp on rc.Province_ID = tp.province_code
left join real_yarn_main rm on rc.RealDistrict_Code = rm.District_Code
left join real_yarn_sub rs on rc.RealSubDistrict_Code = rs.SubDistrict_Code
left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
left join brand b on rc.Brand_Code = b.Brand_Code
left join (select Condo_Code
                , SUM((Price_Sale/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Sale
                , count(*) as Total_Room_Count_Sale
                , min(Price_Sale) as Price_Sale_Min
            from classified
            where Classified_Status = '1'
            and Sale = 1
            group by Condo_Code) total_sale
on rc.Condo_Code = total_sale.Condo_Code
LEFT JOIN ( SELECT c1.Condo_Code,
                min(c1.Size) AS Price_Sale_Min_Size
            FROM classified c1
            JOIN (SELECT Condo_Code,
                        MIN(Price_Sale) AS Min_Price_Sale
                FROM classified
                WHERE Classified_Status = '1'
                AND Sale = 1
                GROUP BY Condo_Code) c2 
            ON c1.Condo_Code = c2.Condo_Code AND c1.Price_Sale = c2.Min_Price_Sale
            group by c1.Condo_Code) size_at_min_total_sale
ON rc.Condo_Code = size_at_min_total_sale.Condo_Code
left join (select Condo_Code
                , SUM((Price_Rent/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Rent
                , count(*) as Total_Room_Count_Rent
                , min(Price_Rent) as Price_Rent_Min
            from classified
            where Classified_Status = '1'
            and Rent = 1
            group by Condo_Code) total_rent
on rc.Condo_Code = total_rent.Condo_Code
LEFT JOIN ( SELECT c1.Condo_Code,
                min(c1.Size) AS Price_Rent_Min_Size
            FROM classified c1
            JOIN (SELECT Condo_Code,
                        MIN(Price_Rent) AS Min_Price_Rent
                FROM classified
                WHERE Classified_Status = '1'
                AND Rent = 1
                GROUP BY Condo_Code) c2 
            ON c1.Condo_Code = c2.Condo_Code AND c1.Price_Rent = c2.Min_Price_Rent
            group by c1.Condo_Code) size_at_min_total_rent
ON rc.Condo_Code = size_at_min_total_rent.Condo_Code
left join (select Condo_Code
                , JSON_ARRAYAGG( JSON_OBJECT('Line_Code',Line_Code) ) as Condo_Around_Line
            from ( SELECT Condo_Code
                        , Line_Code
                    FROM condo_around_station
                    group by Condo_Code,Line_Code) c_line
            group by Condo_Code) aline
on rc.Condo_Code = aline.Condo_Code
left join (select Condo_Code
                , JSON_ARRAYAGG( JSON_OBJECT('Station_Code',Station_Code) ) as Condo_Around_Station
            from ( SELECT Condo_Code
                        , Station_Code
                    FROM condo_around_station
                    group by Condo_Code,Station_Code) c_station
            group by Condo_Code) astation
on rc.Condo_Code = astation.Condo_Code
where rc.Condo_Status = 1;


-- procedure truncateInsert_classified_condo_fetch_for_map
DROP PROCEDURE IF EXISTS truncateInsert_classified_condo_fetch_for_map;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_condo_fetch_for_map ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 text DEFAULT NULL;
	DECLARE v_name3 double DEFAULT NULL;
	DECLARE v_name4 double DEFAULT NULL;
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
	DECLARE v_name25 json DEFAULT NULL;
	DECLARE v_name26 json DEFAULT NULL;
	DECLARE v_name27 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name28 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name29 VARCHAR(250) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_condo_fetch_for_map';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Condo_ENName, Condo_ScopeArea, Condo_Latitude, Condo_Longitude, Room_Count_Sale, Price_Sale_Min, Use_Price_Sale_Min,
                                Price_Sale_Sqm, Use_Price_Sale_Sqm, AVG_Price_Per_Unit_Sqm_Sale, Use_AVG_Per_Unit_Sqm_Sale, Room_Count_Rent, Price_Rent_Min,
                                Use_Price_Rent_Min, Price_Rent_Sqm, Use_Price_Rent_Sqm, AVG_Price_Per_Unit_Sqm_Rent, Use_AVG_Per_Unit_Sqm_Rent, Condo_Segment,
                                Province_code, District_Code, SubDistrict_Code, Developer_Code, Brand_Code, Condo_Around_Line, Condo_Around_Station, Condo_URL_Tag,
                                Condo_Cover, Total_Point
                            FROM source_classified_condo_fetch_for_map;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE classified_condo_fetch_for_map;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			classified_condo_fetch_for_map(
				Condo_Code
                , Condo_ENName
                , Condo_ScopeArea
                , Condo_Latitude
                , Condo_Longitude
                , Room_Count_Sale
                , Price_Sale_Min
                , Use_Price_Sale_Min
                , Price_Sale_Sqm
                , Use_Price_Sale_Sqm
                , AVG_Price_Per_Unit_Sqm_Sale
                , Use_AVG_Per_Unit_Sqm_Sale
                , Room_Count_Rent
                , Price_Rent_Min
                , Use_Price_Rent_Min
                , Price_Rent_Sqm
                , Use_Price_Rent_Sqm
                , AVG_Price_Per_Unit_Sqm_Rent
                , Use_AVG_Per_Unit_Sqm_Rent
                , Condo_Segment
                , Province_code
                , District_Code
                , SubDistrict_Code
                , Developer_Code
                , Brand_Code
                , Condo_Around_Line
                , Condo_Around_Station
                , Condo_URL_Tag
                , Condo_Cover
                , Total_Point)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29);
        
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


-- classified_condo_fetch_for_map_getCondoSpotlight
DROP PROCEDURE IF EXISTS classified_condo_fetch_for_map_getCondoSpotlight;
DELIMITER //

CREATE PROCEDURE classified_condo_fetch_for_map_getCondoSpotlight(IN Condo_Code VARCHAR(50), OUT finalSpotlight TEXT)
BEGIN

	DECLARE done				BOOLEAN			DEFAULT FALSE;
	DECLARE eachSpotlight_Code	VARCHAR(250)	DEFAULT NULL;
	DECLARE queryBase1			VARCHAR(1000)	DEFAULT "SELECT COUNT(1) INTO @spotlightCount FROM condo_spotlight_relationship_view CSRV WHERE CSRV.Condo_Code = '";
	DECLARE queryBase2			VARCHAR(100)	DEFAULT "' AND ";
	DECLARE queryBase3			VARCHAR(100)	DEFAULT "= 'Y'";
	DECLARE queryFinal			VARCHAR(2000)	DEFAULT NULL;
	DECLARE	queryResultCount	INTEGER			DEFAULT 0;
	DECLARE stmt 				VARCHAR(2000);

	DECLARE curTopSpotlight
	CURSOR FOR
		SELECT RCS.Spotlight_Code 
		FROM real_condo_spotlight RCS
		WHERE RCS.Spotlight_Inactive = 0;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET finalSpotlight = "";
	SET queryBase1 = CONCAT(queryBase1, Condo_Code, queryBase2);
	
	OPEN curTopSpotlight;
	
	TopSpotlightLoop:LOOP
		FETCH curTopSpotlight INTO eachSpotlight_Code;

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
            IF finalSpotlight <> "" THEN
                SET finalSpotlight = CONCAT(finalSpotlight, "," , '{"Spotlight_Code":"',eachSpotlight_Code,'"}');
            ELSE
                SET finalSpotlight = concat(finalSpotlight,"",'{"Spotlight_Code":"',eachSpotlight_Code,'"}');
            END IF;
            -- select queryResultCount,finalSpotlight;
		END IF;
	
	END LOOP;

    CLOSE curTopSpotlight;
	
	SET finalSpotlight = TRIM(finalSpotlight);
    SET finalSpotlight = concat('[',finalSpotlight,']');
    -- select finalSpotlight;

END //
DELIMITER ;

-- classified_condo_fetch_for_map_update_spotlight
DROP PROCEDURE IF EXISTS classified_condo_fetch_for_map_update_spotlight;
DELIMITER //

CREATE PROCEDURE classified_condo_fetch_for_map_update_spotlight ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE condo	    VARCHAR(50) DEFAULT 0;
    DECLARE mySpotlight	TEXT;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'classified_condo_fetch_for_map_update_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code FROM source_classified_condo_fetch_for_map;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',condo);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    UPDATE classified_condo_fetch_for_map
    SET Spotlight_List = null;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO condo;

        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL classified_condo_report_getCondoSpotlight(condo, mySpotlight);
        UPDATE classified_condo_fetch_for_map
        SET Spotlight_List = mySpotlight
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

    UPDATE classified_condo_fetch_for_map
    SET Spotlight_List = null
    WHERE TRIM(Spotlight_List) = "[]";

END //
DELIMITER ;