-- fuction surrounding
-- table classified_surrounding
    -- procedure insert_classified_surrounding
-- view source_classified_comparison_view
-- table classified_comparison
-- procedure truncateInsert_classified_comparison

-- fuction surrounding
DELIMITER //
CREATE FUNCTION surrounding(letter double)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE format_number INT;
    CASE
        WHEN letter <= 50 THEN SET format_number = letter;
        WHEN letter % 50 = 0 THEN SET format_number = letter;
        WHEN letter % 100 < 50 THEN SET format_number = floor(letter/100)*100;
        ELSE SET format_number = CEIL(letter / 100) * 100;
    END CASE;
    RETURN format_number;
END //

-- table classified_surrounding
CREATE TABLE IF NOT EXISTS `classified_surrounding` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code varchar(50) not null,
    Place_Name varchar(100) not NULL,
    Distance double not NULL,
    Result varchar(20) not NULL,
    Surrounding_Type enum('education','hospital','retail','express_way') not null,
    PRIMARY KEY (`ID`),
    INDEX ces_code (Condo_Code),
    INDEX ces_result (Result))
ENGINE = InnoDB;

-- procedure insert_classified_surrounding
DROP PROCEDURE IF EXISTS insert_classified_surrounding;
DELIMITER //

CREATE PROCEDURE insert_classified_surrounding ()
BEGIN
    DECLARE proc_name       VARCHAR(70) DEFAULT 'insert_classified_surrounding';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    TRUNCATE TABLE classified_surrounding;

    insert into classified_surrounding (Condo_Code, Place_Name, Distance, Result, Surrounding_Type)
    select order_distance.Condo_Code
        , order_distance.Place_Name
        , order_distance.Distance
        , if(round(order_distance.Distance * 1000,-2) >= 1000
            , concat(format(round(order_distance.Distance * 1000,-2) / 1000, 1), ' กม.')
            , concat(surrounding(round(order_distance.Distance * 1000)), ' ม.')) as result
        , 'education' as Surrounding_Type
    from (SELECT rc.Condo_Code
            , concat_ws('',re.Place_Short_Name,re.Place_Name) as Place_Name
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - re.Place_Latitude)) / 2), 2)
                + COS(RADIANS(re.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - re.Place_Longitude)) / 2), 2 )))) as Distance
            , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - re.Place_Latitude)) / 2), 2)
                + COS(RADIANS(re.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - re.Place_Longitude)) / 2), 2 ))))) AS RowNum
            FROM real_place_education re
            cross join real_condo rc
            where rc.Condo_Status <> 2) order_distance
    where order_distance.RowNum < 3
    order by order_distance.Condo_Code, order_distance.Distance;

    insert into classified_surrounding (Condo_Code, Place_Name, Distance, Result, Surrounding_Type)
    select order_distance.Condo_Code
        , order_distance.Place_Name
        , order_distance.Distance
        , if(round(order_distance.Distance * 1000,-2) >= 1000
            , concat(format(round(order_distance.Distance * 1000,-2) / 1000, 1), ' กม.')
            , concat(surrounding(round(order_distance.Distance * 1000)), ' ม.')) as result
        , 'hospital' as Surrounding_Type
    from (SELECT rc.Condo_Code
            , concat_ws('',rh.Place_Short_Name,rh.Place_Name) as Place_Name
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rh.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rh.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - rh.Place_Longitude)) / 2), 2 )))) as Distance
            , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rh.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rh.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - rh.Place_Longitude)) / 2), 2 ))))) AS RowNum
            FROM real_place_hospital rh
            cross join real_condo rc
            where rc.Condo_Status <> 2) order_distance
    where order_distance.RowNum < 3
    order by order_distance.Condo_Code, order_distance.Distance;

    insert into classified_surrounding (Condo_Code, Place_Name, Distance, Result, Surrounding_Type)
    select order_distance.Condo_Code
        , order_distance.Place_Name
        , order_distance.Distance
        , if(round(order_distance.Distance * 1000,-2) >= 1000
            , concat(format(round(order_distance.Distance * 1000,-2) / 1000, 1), ' กม.')
            , concat(surrounding(round(order_distance.Distance * 1000)), ' ม.')) as result
        , 'retail' as Surrounding_Type
    from (SELECT rc.Condo_Code
            , rr.Place_Name
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rr.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rr.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - rr.Place_Longitude)) / 2), 2 )))) as Distance
            , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rr.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rr.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - rr.Place_Longitude)) / 2), 2 ))))) AS RowNum
            FROM real_place_retail rr
            cross join real_condo rc
            where rc.Condo_Status <> 2) order_distance
    where order_distance.RowNum < 3
    order by order_distance.Condo_Code, order_distance.Distance;

    insert into classified_surrounding (Condo_Code, Place_Name, Distance, Result, Surrounding_Type)
    select order_distance.Condo_Code
        , order_distance.Place_Name
        , order_distance.Distance
        , if(round(order_distance.Distance * 1000,-2) >= 1000
            , concat(format(round(order_distance.Distance * 1000,-2) / 1000, 1), ' กม.')
            , concat(surrounding(round(order_distance.Distance * 1000)), ' ม.')) as result
        , 'express_way' as Surrounding_Type
    from (SELECT rc.Condo_Code
            , concat_ws(' ',rp.Place_Name,'-',rp.Place_Attribute_1,rp.Place_Attribute_2) as Place_Name
            , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rp.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rp.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - rp.Place_Longitude)) / 2), 2 )))) as Distance
            , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(rc.Condo_Latitude - rp.Place_Latitude)) / 2), 2)
                + COS(RADIANS(rp.Place_Latitude)) * COS(RADIANS(rc.Condo_Latitude)) *
                POWER(SIN((RADIANS(rc.Condo_Longitude - rp.Place_Longitude)) / 2), 2 ))))) AS RowNum
            FROM real_place_express_way rp
            cross join real_condo rc
            where rc.Condo_Status <> 2) order_distance
    where order_distance.RowNum < 3
    order by order_distance.Condo_Code, order_distance.Distance;

    if errorcheck then
        SET code    = '00000';
        SET msg     = 'Complete';
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

END //
DELIMITER ;

-- view source_classified_comparison_view
create or replace view source_classified_comparison_view as
select cv.Classified_ID
    , cover.Classified_Image_URL
    , SUBSTRING_INDEX(cv.Unit_Type, ' ', 4) as Unit_Type
    , cv.Condo_Name
    , cv.Condo_Code
    , cv.Sale
    , cv.Rent
    , concat_ws('\n',cv.District_Name,cv.Province_Name) as Location
    , replace(format(cv.Unit_Size,1),',','') as Unit_Size
    , cv.Bedroom
    , cv.Bathroom
    , nun(cv.Furnish) as Furnish
    , nun(round(cv.Price_Sale/1000000,2)) as Price_Sale
    , nun(format(cv.Price_Sale_Per_Square,0)) as Price_Sale_Per_Square
    , nun(format(cv.Price_Rent,0)) as Price_Rent
    , nun(if(ac.Condo_Built_Text <> 'ปีเปิดตัว' and ac.Condo_Sold_Status_Show_Value is not null
        , concat('เสร็จ ',ac.Condo_Built_Date,' | ',if(ac.Condo_Sold_Status_Show_Value <> 'RESALE', concat('SOLD ',round(ac.Condo_Sold_Status_Show_Value*100),' %'), 'RESALE'))
        , if(ac.Condo_Built_Text <> 'ปีเปิดตัว'
            , concat('เสร็จ ',ac.Condo_Built_Date)
            , if(ac.Condo_Sold_Status_Show_Value is not null
                , if(ac.Condo_Sold_Status_Show_Value <> 'RESALE', concat('SOLD ',ac.Condo_Sold_Status_Show_Value*100,' %'), 'RESALE')
                , '')))) as Project_Status
    , nun(rc.Condo_Building) as Condo_Building
    , nun(concat(format(rc.Condo_TotalUnit,0),' ยูนิต')) as Condo_TotalUnit
    , nun(if(ff.Parking_Amount <> '-'
            , concat(ff.Parking_Amount,' (',ff.Parking_Per_Unit,')')
            , '-')) as Parking_Amount
    , nun(ff.Common_Fee) as Common_Fee
    , nun(faci.Facility) as Facility
    , ifnull(gal.Facilities_Gallery,ifnull(gal2.Gallery,'-')) as Facilities_Gallery
    , nun(ss.Station_Surrounding) as Station_Surrounding
    , nun(rs.Retail_Surrounding) as Retail_Surrounding
    , nun(hs.Hospital_Surrounding) as Hospital_Surrounding
    , nun(es.Education_Surrounding) as Education_Surrounding
    , nun(exs.Express_Way_Surrounding) as Express_Way_Surrounding
from classified_detail_view cv
left join all_condo_price_calculate ac on cv.Condo_Code = ac.Condo_Code
left join real_condo rc on cv.Condo_Code = rc.Condo_Code
left join full_template_factsheet ff on cv.Condo_Code = ff.Condo_Code
left join (SELECT Classified_ID
                , JSON_UNQUOTE(JSON_EXTRACT(image, '$[0].Classified_Image_URL')) AS Classified_Image_URL
            FROM classified_detail_view
            WHERE JSON_EXTRACT(image, '$[0].Displayed_Order_in_Classified') = 1) cover
on cv.Classified_ID = cover.Classified_ID
left join (select Condo_Code
                , group_concat(Category_Name separator '\n') AS `Facility`
            from ( SELECT Condo_Code
                        , Category_Name
                        , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Condo_Code) AS mynum
                    FROM `full_template_facilities_icon_view`
                    group by Condo_Code,Category_Name) c_line
            where mynum <= 10
            group by Condo_Code) faci
on cv.Condo_Code = faci.Condo_Code
left join (SELECT Condo_Code
                , JSON_ARRAYAGG(JSON_OBJECT('Image_ID' , Image_ID
                                            , 'Image_URL', Image_URL
                                            , 'Element_Name', Element_Name
                                            , 'Display_Order_in_Element', Display_Order_in_Element
                                            , 'Display_Order_in_Section', Display_Order_in_Section)) AS Facilities_Gallery
            FROM full_template_facilities_raw_view
            where Image_URL is not null
            and Image_Status = 1 
            group by Condo_Code) gal
on cv.Condo_Code = gal.Condo_Code
left join (select Condo_Code
                , GROUP_CONCAT(CONCAT_WS('[!]', Station_Name, result) SEPARATOR '\n') as Station_Surrounding
            from (select order_distance.Condo_Code
                        , ms.Station_THName_Display as Station_Name
                        , if(round(order_distance.Distance * 1000,-2) >= 1000
                            , concat(format(round(order_distance.Distance * 1000,-2) / 1000, 1), ' กม.')
                            , concat(surrounding(round(order_distance.Distance * 1000)), ' ม.')) as result
                    from ( select Condo_Code
                                , Station_Code
                                , Distance
                                , Total_Point
                                , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Total_Point) AS RowNum
                            from condo_around_station_view) order_distance
                    left join mass_transit_station ms on order_distance.Station_Code = ms.Station_Code
                    where order_distance.RowNum < 3
                    group by order_distance.Condo_Code, ms.Station_THName_Display, order_distance.Distance
                    order by order_distance.Condo_Code, order_distance.Distance) station_data
            group by Condo_Code) ss
on cv.Condo_Code = ss.Condo_Code
left join (select Condo_Code
                , GROUP_CONCAT(CONCAT_WS('[!]', Place_Name, result) SEPARATOR '\n') as Retail_Surrounding
            from classified_surrounding
            where Surrounding_Type = 'retail'
            group by Condo_Code) rs
on cv.Condo_Code = rs.Condo_Code
left join (select Condo_Code
                , GROUP_CONCAT(CONCAT_WS('[!]', Place_Name, result) SEPARATOR '\n') as Hospital_Surrounding
            from classified_surrounding
            where Surrounding_Type = 'hospital'
            group by Condo_Code) hs
on cv.Condo_Code = hs.Condo_Code
left join (select Condo_Code
                , GROUP_CONCAT(CONCAT_WS('[!]', Place_Name, result) SEPARATOR '\n') as Education_Surrounding
            from classified_surrounding
            where Surrounding_Type = 'education'
            group by Condo_Code) es
on cv.Condo_Code = es.Condo_Code
left join (select Condo_Code
                , GROUP_CONCAT(CONCAT_WS('[!]', Place_Name, result) SEPARATOR '\n') as Express_Way_Surrounding
            from classified_surrounding
            where Surrounding_Type = 'express_way'
            group by Condo_Code) exs
on cv.Condo_Code = exs.Condo_Code
left join (SELECT Condo_Code
                , JSON_ARRAYAGG(JSON_OBJECT('Image_ID' , CondoGallery_ID 
                                            , 'Image_URL', CondoGallery_PicName
                                            , 'Element_Name', CondoGallery_Caption
                                            , 'Display_Order_in_Element', CondoGallery_OrderName
                                            , 'Display_Order_in_Section', CondoGallery_Order
                                            )) AS Gallery
            FROM condo_gallery
            group by Condo_Code) gal2
on cv.Condo_Code = gal2.Condo_Code
order by cv.Classified_ID;

-- table classified_comparison
CREATE TABLE IF NOT EXISTS `classified_comparison` (
    ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    Classified_ID int UNSIGNED NOT NULL,
    Classified_Image_URL TEXT NULL,
    Unit_Type varchar(250) not null,
    Condo_Name varchar(250) not null,
    Condo_Code VARCHAR(50) NOT NULL,
    Sale boolean not null default 0,
    Rent boolean not null default 0,
    Location text null,
    Unit_Size float(6,1) null,
    Bedroom VARCHAR(4) not null,
    Bathroom SMALLINT UNSIGNED null,
    Furnish enum('Bareshell','Non Furnished','Fully Fitted', 'Fully Furnished','-') not null,
    Price_Sale varchar(10) not null,
    Price_Sale_Per_Square varchar(20) not null,
    Price_Rent varchar(10) not null,
    Project_Status varchar(100) not null,
    Condo_Building 	varchar(250) not null,
    Condo_TotalUnit varchar(20) not null,
    Parking_Amount varchar(100) not null,
    Common_Fee varchar(100) not null,
    Facility text not null,
    Facilities_Gallery text not null,
    Station_Surrounding text not null,
    Retail_Surrounding text not null,
    Hospital_Surrounding text not null,
    Education_Surrounding text not null,
    Express_Way_Surrounding text not null,
    PRIMARY KEY (`ID`),
    INDEX cc_condo_code (Condo_Code))
ENGINE = InnoDB;

-- procedure truncateInsert_classified_comparison
DROP PROCEDURE IF EXISTS truncateInsert_classified_comparison;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_comparison ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 text DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name7 text DEFAULT NULL;
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
    DECLARE v_name20 text DEFAULT NULL;
	DECLARE v_name21 text DEFAULT NULL;
	DECLARE v_name22 text DEFAULT NULL;
    DECLARE v_name23 text DEFAULT NULL;
	DECLARE v_name24 text DEFAULT NULL;
	DECLARE v_name25 text DEFAULT NULL;
    DECLARE v_name26 text DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_comparison';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Classified_ID, Classified_Image_URL, Unit_Type, Condo_Name, Condo_Code, Sale, Rent, Location, Unit_Size, Bedroom
                                , Bathroom, Furnish, Price_Sale, Price_Sale_Per_Square, Price_Rent, Project_Status, Condo_Building, Condo_TotalUnit
                                , Parking_Amount, Common_Fee, Facility, Facilities_Gallery, Station_Surrounding, Retail_Surrounding, Hospital_Surrounding
                                , Education_Surrounding, Express_Way_Surrounding
                            FROM source_classified_comparison_view;
	
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE classified_comparison;
	
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			classified_comparison (
				Classified_ID
                , Classified_Image_URL
                , Unit_Type
                , Condo_Name
                , Condo_Code
                , Sale
                , Rent
                , Location
                , Unit_Size
                , Bedroom
                , Bathroom
                , Furnish
                , Price_Sale
                , Price_Sale_Per_Square
                , Price_Rent
                , Project_Status
                , Condo_Building
                , Condo_TotalUnit
                , Parking_Amount
                , Common_Fee
                , Facility
                , Facilities_Gallery
                , Station_Surrounding
                , Retail_Surrounding
                , Hospital_Surrounding
                , Education_Surrounding
                , Express_Way_Surrounding
			)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26);
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