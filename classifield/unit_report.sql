-- view source_classified_condo_report
-- table classified_condo_report
-- procedure truncateInsert_classified_condo_report
-- classified_condo_report_getCondoSpotlight
-- classified_condo_report_update_spotlight
-- station query
-- line query
-- spotlight query
-- menu price query
-- segment query
-- province query
-- district query
-- subdistrict query
-- developer query


-- view source_classified_condo_report
create or replace view source_classified_condo_report as
select rc.Condo_Code
    , ifnull(total_sale.Total_Room_Count_Sale,0) + ifnull(total_rent.Total_Room_Count_Rent,0) as Total_Room_Count
    , total_sale.Total_Room_Count_Sale
    , total_sale.Total_Average_Sqm_Sale
    , total_sale.Total_Price_Per_Unit_Sale
    , total_sale.Total_Price_Per_Unit_Sqm_Sale
    , total_sale.Total_Total_Sqm_Sale
    , total_rent.Total_Room_Count_Rent
    , total_rent.Total_Average_Sqm_Rent
    , total_rent.Total_Price_Per_Unit_Rent
    , total_rent.Total_Price_Per_Unit_Sqm_Rent
    , total_rent.Total_Total_Sqm_Rent
    , 1bed_sale.Bed1_Room_Count_Sale
    , 1bed_sale.Bed1_Average_Sqm_Sale
    , 1bed_sale.Bed1_Price_Per_Unit_Sale
    , 1bed_sale.Bed1_Price_Per_Unit_Sqm_Sale
    , 1bed_sale.Bed1_Total_Sqm_Sale
    , 1bed_rent.Bed1_Room_Count_Rent
    , 1bed_rent.Bed1_Average_Sqm_Rent
    , 1bed_rent.Bed1_Price_Per_Unit_Rent
    , 1bed_rent.Bed1_Price_Per_Unit_Sqm_Rent
    , 1bed_rent.Bed1_Total_Sqm_Rent
    , 2bed_sale.Bed2_Room_Count_Sale
    , 2bed_sale.Bed2_Average_Sqm_Sale
    , 2bed_sale.Bed2_Price_Per_Unit_Sale
    , 2bed_sale.Bed2_Price_Per_Unit_Sqm_Sale
    , 2bed_sale.Bed2_Total_Sqm_Sale
    , 2bed_rent.Bed2_Room_Count_Rent
    , 2bed_rent.Bed2_Average_Sqm_Rent
    , 2bed_rent.Bed2_Price_Per_Unit_Rent
    , 2bed_rent.Bed2_Price_Per_Unit_Sqm_Rent
    , 2bed_rent.Bed2_Total_Sqm_Rent
    , 3bed_sale.Bed3_Room_Count_Sale
    , 3bed_sale.Bed3_Average_Sqm_Sale
    , 3bed_sale.Bed3_Price_Per_Unit_Sale
    , 3bed_sale.Bed3_Price_Per_Unit_Sqm_Sale
    , 3bed_sale.Bed3_Total_Sqm_Sale
    , 3bed_rent.Bed3_Room_Count_Rent
    , 3bed_rent.Bed3_Average_Sqm_Rent
    , 3bed_rent.Bed3_Price_Per_Unit_Rent
    , 3bed_rent.Bed3_Price_Per_Unit_Sqm_Rent
    , 3bed_rent.Bed3_Total_Sqm_Rent
    , 4bed_sale.Bed4_Room_Count_Sale
    , 4bed_sale.Bed4_Average_Sqm_Sale
    , 4bed_sale.Bed4_Price_Per_Unit_Sale
    , 4bed_sale.Bed4_Price_Per_Unit_Sqm_Sale
    , 4bed_sale.Bed4_Total_Sqm_Sale
    , 4bed_rent.Bed4_Room_Count_Rent
    , 4bed_rent.Bed4_Average_Sqm_Rent
    , 4bed_rent.Bed4_Price_Per_Unit_Rent
    , 4bed_rent.Bed4_Price_Per_Unit_Sqm_Rent
    , 4bed_rent.Bed4_Total_Sqm_Rent
    , rcp.Condo_Segment
    , tp.Province_code
    , rm.District_Code
    , rs.SubDistrict_Code
    , cd.Developer_Code
    , b.Brand_Code
    , aline.Condo_Around_Line
    , astation.Condo_Around_Station
from real_condo rc
left join real_condo_price rcp on rc.Condo_Code = rcp.Condo_Code
left join thailand_province tp on rc.Province_ID = tp.province_code
left join real_yarn_main rm on rc.RealDistrict_Code = rm.District_Code
left join real_yarn_sub rs on rc.RealSubDistrict_Code = rs.SubDistrict_Code
left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
left join brand b on rc.Brand_Code = b.Brand_Code
left join (select Condo_Code
                , SUM(Price_Sale*Size)/SUM(Size) as Bed1_Price_Per_Unit_Sale
                , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed1_Price_Per_Unit_Sqm_Sale
                , count(*) as Bed1_Room_Count_Sale
                , AVG(Size) as Bed1_Average_Sqm_Sale
                , sum(Size) as Bed1_Total_Sqm_Sale
            from classified
            where Classified_Status = '1'
            and Bedroom = 1
            and Sale = 1
            group by Condo_Code) 1bed_sale
on rc.Condo_Code = 1bed_sale.Condo_Code
left join (select Condo_Code
                , SUM(Price_Rent*Size)/SUM(Size) as Bed1_Price_Per_Unit_Rent
                , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed1_Price_Per_Unit_Sqm_Rent
                , count(*) as Bed1_Room_Count_Rent
                , AVG(Size) as Bed1_Average_Sqm_Rent
                , sum(Size) as Bed1_Total_Sqm_Rent
            from classified
            where Classified_Status = '1'
            and Bedroom = 1
            and Rent = 1
            group by Condo_Code) 1bed_rent
on rc.Condo_Code = 1bed_rent.Condo_Code
left join (select Condo_Code
                , SUM(Price_Sale*Size)/SUM(Size) as Bed2_Price_Per_Unit_Sale
                , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed2_Price_Per_Unit_Sqm_Sale
                , count(*) as Bed2_Room_Count_Sale
                , AVG(Size) as Bed2_Average_Sqm_Sale
                , sum(Size) as Bed2_Total_Sqm_Sale
            from classified
            where Classified_Status = '1'
            and Bedroom = 2
            and Sale = 1
            group by Condo_Code) 2bed_sale
on rc.Condo_Code = 2bed_sale.Condo_Code
left join (select Condo_Code
                , SUM(Price_Rent*Size)/SUM(Size) as Bed2_Price_Per_Unit_Rent
                , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed2_Price_Per_Unit_Sqm_Rent
                , count(*) as Bed2_Room_Count_Rent
                , AVG(Size) as Bed2_Average_Sqm_Rent
                , sum(Size) as Bed2_Total_Sqm_Rent
            from classified
            where Classified_Status = '1'
            and Bedroom = 2
            and Rent = 1
            group by Condo_Code) 2bed_rent
on rc.Condo_Code = 2bed_rent.Condo_Code
left join (select Condo_Code
                , SUM(Price_Sale*Size)/SUM(Size) as Bed3_Price_Per_Unit_Sale
                , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed3_Price_Per_Unit_Sqm_Sale
                , count(*) as Bed3_Room_Count_Sale
                , AVG(Size) as Bed3_Average_Sqm_Sale
                , sum(Size) as Bed3_Total_Sqm_Sale
            from classified
            where Classified_Status = '1'
            and Bedroom = 3
            and Sale = 1
            group by Condo_Code) 3bed_sale
on rc.Condo_Code = 3bed_sale.Condo_Code
left join (select Condo_Code
                , SUM(Price_Rent*Size)/SUM(Size) as Bed3_Price_Per_Unit_Rent
                , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed3_Price_Per_Unit_Sqm_Rent
                , count(*) as Bed3_Room_Count_Rent
                , AVG(Size) as Bed3_Average_Sqm_Rent
                , sum(Size) as Bed3_Total_Sqm_Rent
            from classified
            where Classified_Status = '1'
            and Bedroom = 3
            and Rent = 1
            group by Condo_Code) 3bed_rent
on rc.Condo_Code = 3bed_rent.Condo_Code
left join (select Condo_Code
                , SUM(Price_Sale*Size)/SUM(Size) as Bed4_Price_Per_Unit_Sale
                , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed4_Price_Per_Unit_Sqm_Sale
                , count(*) as Bed4_Room_Count_Sale
                , AVG(Size) as Bed4_Average_Sqm_Sale
                , sum(Size) as Bed4_Total_Sqm_Sale
            from classified
            where Classified_Status = '1'
            and Bedroom >= 4
            and Sale = 1
            group by Condo_Code) 4bed_sale
on rc.Condo_Code = 4bed_sale.Condo_Code
left join (select Condo_Code
                , SUM(Price_Rent*Size)/SUM(Size) as Bed4_Price_Per_Unit_Rent
                , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed4_Price_Per_Unit_Sqm_Rent
                , count(*) as Bed4_Room_Count_Rent
                , AVG(Size) as Bed4_Average_Sqm_Rent
                , sum(Size) as Bed4_Total_Sqm_Rent
            from classified
            where Classified_Status = '1'
            and Bedroom >= 4
            and Rent = 1
            group by Condo_Code) 4bed_rent
on rc.Condo_Code = 4bed_rent.Condo_Code
left join (select Condo_Code
                , SUM(Price_Sale*Size)/SUM(Size) as Total_Price_Per_Unit_Sale
                , SUM((Price_Sale/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Sale
                , count(*) as Total_Room_Count_Sale
                , AVG(Size) as Total_Average_Sqm_Sale
                , sum(Size) as Total_Total_Sqm_Sale
            from classified
            where Classified_Status = '1'
            and Sale = 1
            group by Condo_Code) total_sale
on rc.Condo_Code = total_sale.Condo_Code
left join (select Condo_Code
                , SUM(Price_Rent*Size)/SUM(Size) as Total_Price_Per_Unit_Rent
                , SUM((Price_Rent/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Rent
                , count(*) as Total_Room_Count_Rent
                , AVG(Size) as Total_Average_Sqm_Rent
                , sum(Size) as Total_Total_Sqm_Rent
            from classified
            where Classified_Status = '1'
            and Rent = 1
            group by Condo_Code) total_rent
on rc.Condo_Code = total_rent.Condo_Code
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
where rc.Condo_Status = 1
and ((total_sale.Total_Price_Per_Unit_Sale or 1bed_sale.Bed1_Price_Per_Unit_Sale or 2bed_sale.Bed2_Price_Per_Unit_Sale or 3bed_sale.Bed3_Price_Per_Unit_Sale or 4bed_sale.Bed4_Price_Per_Unit_Sale)
or (total_rent.Total_Price_Per_Unit_Rent or 1bed_rent.Bed1_Price_Per_Unit_Rent or 2bed_rent.Bed2_Price_Per_Unit_Rent or 3bed_rent.Bed3_Price_Per_Unit_Rent or 4bed_rent.Bed4_Price_Per_Unit_Rent));

-- table classified_condo_report
CREATE TABLE IF NOT EXISTS classified_condo_report (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(50) NOT NULL,
    Total_Room_Count int UNSIGNED null,
    Total_Room_Count_Sale int UNSIGNED null,
	Total_Average_Sqm_Sale double null,
    Total_Price_Per_Unit_Sale double null,
    Total_Price_Per_Unit_Sqm_Sale double null,
	Total_Total_Sqm_Sale double null,
    Total_Room_Count_Rent int UNSIGNED null,
	Total_Average_Sqm_Rent double null,
    Total_Price_Per_Unit_Rent double null,
    Total_Price_Per_Unit_Sqm_Rent double null,
	Total_Total_Sqm_Rent double null,
    Bed1_Room_Count_Sale int UNSIGNED null,
	Bed1_Average_Sqm_Sale double null,
    Bed1_Price_Per_Unit_Sale double null,
    Bed1_Price_Per_Unit_Sqm_Sale double null,
	Bed1_Total_Sqm_Sale double null,
    Bed1_Room_Count_Rent int UNSIGNED null,
	Bed1_Average_Sqm_Rent double null,
    Bed1_Price_Per_Unit_Rent double null,
    Bed1_Price_Per_Unit_Sqm_Rent double null,
	Bed1_Total_Sqm_Rent double null,
    Bed2_Room_Count_Sale int UNSIGNED null,
	Bed2_Average_Sqm_Sale double null,
    Bed2_Price_Per_Unit_Sale double null,
    Bed2_Price_Per_Unit_Sqm_Sale double null,
	Bed2_Total_Sqm_Sale double null,
    Bed2_Room_Count_Rent int UNSIGNED null,
	Bed2_Average_Sqm_Rent double null,
    Bed2_Price_Per_Unit_Rent double null,
    Bed2_Price_Per_Unit_Sqm_Rent double null,
	Bed2_Total_Sqm_Rent double null,
    Bed3_Room_Count_Sale int UNSIGNED null,
	Bed3_Average_Sqm_Sale double null,
    Bed3_Price_Per_Unit_Sale double null,
    Bed3_Price_Per_Unit_Sqm_Sale double null,
	Bed3_Total_Sqm_Sale double null,
    Bed3_Room_Count_Rent int UNSIGNED null,
	Bed3_Average_Sqm_Rent double null,
    Bed3_Price_Per_Unit_Rent double null,
    Bed3_Price_Per_Unit_Sqm_Rent double null,
	Bed3_Total_Sqm_Rent double null,
    Bed4_Room_Count_Sale int UNSIGNED null,
	Bed4_Average_Sqm_Sale double null,
    Bed4_Price_Per_Unit_Sale double null,
    Bed4_Price_Per_Unit_Sqm_Sale double null,
	Bed4_Total_Sqm_Sale double null,
    Bed4_Room_Count_Rent int UNSIGNED null,
	Bed4_Average_Sqm_Rent double null,
    Bed4_Price_Per_Unit_Rent double null,
    Bed4_Price_Per_Unit_Sqm_Rent double null,
	Bed4_Total_Sqm_Rent double null,
    Condo_Segment varchar(10) null,
    Province_code varchar(4) null,
    District_Code varchar(20) null,
    SubDistrict_Code varchar(10) null,
    Developer_Code varchar(20) null,
    Brand_Code varchar(50) null,
    Condo_Around_Line json null,
    Condo_Around_Station json null,
    Spotlight_list json null,
    PRIMARY KEY (ID),
    INDEX crcode (Condo_Code),
    INDEX crsegment (Condo_Segment),
    INDEX  crprovince (Province_code),
    INDEX crdistrict (District_Code),
    INDEX crsubdistrict (SubDistrict_Code),
    INDEX crdev (Developer_Code),
    INDEX crbrand (Brand_Code))
ENGINE = InnoDB;

-- procedure truncateInsert_classified_condo_report
DROP PROCEDURE IF EXISTS truncateInsert_classified_condo_report;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_condo_report ()
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
    DECLARE v_name25 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name26 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name27 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name28 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name29 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name30 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name31 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name32 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name33 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name34 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name35 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name36 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name37 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name38 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name39 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name40 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name41 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name42 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name43 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name44 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name45 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name46 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name47 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name48 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name49 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name50 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name51 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name52 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name53 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name54 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name55 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name56 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name57 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name58 JSON DEFAULT NULL;
	DECLARE v_name59 JSON DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_condo_report';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR select Condo_Code, Total_Room_Count, Total_Room_Count_Sale, Total_Average_Sqm_Sale, Total_Price_Per_Unit_Sale, Total_Price_Per_Unit_Sqm_Sale
                                , Total_Total_Sqm_Sale, Total_Room_Count_Rent, Total_Average_Sqm_Rent, Total_Price_Per_Unit_Rent, Total_Price_Per_Unit_Sqm_Rent
                                , Total_Total_Sqm_Rent, Bed1_Room_Count_Sale, Bed1_Average_Sqm_Sale, Bed1_Price_Per_Unit_Sale, Bed1_Price_Per_Unit_Sqm_Sale
                                , Bed1_Total_Sqm_Sale, Bed1_Room_Count_Rent, Bed1_Average_Sqm_Rent, Bed1_Price_Per_Unit_Rent, Bed1_Price_Per_Unit_Sqm_Rent, Bed1_Total_Sqm_Rent
                                , Bed2_Room_Count_Sale, Bed2_Average_Sqm_Sale, Bed2_Price_Per_Unit_Sale, Bed2_Price_Per_Unit_Sqm_Sale, Bed2_Total_Sqm_Sale, Bed2_Room_Count_Rent
                                , Bed2_Average_Sqm_Rent, Bed2_Price_Per_Unit_Rent, Bed2_Price_Per_Unit_Sqm_Rent, Bed2_Total_Sqm_Rent, Bed3_Room_Count_Sale, Bed3_Average_Sqm_Sale
                                , Bed3_Price_Per_Unit_Sale, Bed3_Price_Per_Unit_Sqm_Sale, Bed3_Total_Sqm_Sale, Bed3_Room_Count_Rent, Bed3_Average_Sqm_Rent, Bed3_Price_Per_Unit_Rent
                                , Bed3_Price_Per_Unit_Sqm_Rent, Bed3_Total_Sqm_Rent, Bed4_Room_Count_Sale, Bed4_Average_Sqm_Sale, Bed4_Price_Per_Unit_Sale
                                , Bed4_Price_Per_Unit_Sqm_Sale, Bed4_Total_Sqm_Sale, Bed4_Room_Count_Rent, Bed4_Average_Sqm_Rent, Bed4_Price_Per_Unit_Rent
                                , Bed4_Price_Per_Unit_Sqm_Rent, Bed4_Total_Sqm_Rent, Condo_Segment, Province_code, District_Code, SubDistrict_Code, Developer_Code , Brand_Code
                                , Condo_Around_Line, Condo_Around_Station
                            from source_classified_condo_report;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE  classified_condo_report;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54,v_name55,v_name56,v_name57,v_name58,v_name59;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			classified_condo_report(
				Condo_Code
                , Total_Room_Count
                , Total_Room_Count_Sale
                , Total_Average_Sqm_Sale
                , Total_Price_Per_Unit_Sale
                , Total_Price_Per_Unit_Sqm_Sale
                , Total_Total_Sqm_Sale
                , Total_Room_Count_Rent
                , Total_Average_Sqm_Rent
                , Total_Price_Per_Unit_Rent
                , Total_Price_Per_Unit_Sqm_Rent
                , Total_Total_Sqm_Rent
                , Bed1_Room_Count_Sale
                , Bed1_Average_Sqm_Sale
                , Bed1_Price_Per_Unit_Sale
                , Bed1_Price_Per_Unit_Sqm_Sale
                , Bed1_Total_Sqm_Sale
                , Bed1_Room_Count_Rent
                , Bed1_Average_Sqm_Rent
                , Bed1_Price_Per_Unit_Rent	
                , Bed1_Price_Per_Unit_Sqm_Rent
                , Bed1_Total_Sqm_Rent
                , Bed2_Room_Count_Sale
                , Bed2_Average_Sqm_Sale
                , Bed2_Price_Per_Unit_Sale
                , Bed2_Price_Per_Unit_Sqm_Sale
                , Bed2_Total_Sqm_Sale
                , Bed2_Room_Count_Rent
                , Bed2_Average_Sqm_Rent
                , Bed2_Price_Per_Unit_Rent
                , Bed2_Price_Per_Unit_Sqm_Rent
                , Bed2_Total_Sqm_Rent
                , Bed3_Room_Count_Sale
                , Bed3_Average_Sqm_Sale
                , Bed3_Price_Per_Unit_Sale
                , Bed3_Price_Per_Unit_Sqm_Sale
                , Bed3_Total_Sqm_Sale
                , Bed3_Room_Count_Rent
                , Bed3_Average_Sqm_Rent
                , Bed3_Price_Per_Unit_Rent
                , Bed3_Price_Per_Unit_Sqm_Rent
                , Bed3_Total_Sqm_Rent
                , Bed4_Room_Count_Sale
                , Bed4_Average_Sqm_Sale
                , Bed4_Price_Per_Unit_Sale
                , Bed4_Price_Per_Unit_Sqm_Sale
                , Bed4_Total_Sqm_Sale
                , Bed4_Room_Count_Rent
                , Bed4_Average_Sqm_Rent
                , Bed4_Price_Per_Unit_Rent
                , Bed4_Price_Per_Unit_Sqm_Rent
                , Bed4_Total_Sqm_Rent
                , Condo_Segment
                , Province_code
                , District_Code
                , SubDistrict_Code
                , Developer_Code 
                , Brand_Code
                , Condo_Around_Line
                , Condo_Around_Station
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54,v_name55,v_name56,v_name57,v_name58,v_name59);
        
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

-- classified_condo_report_getCondoSpotlight
DROP PROCEDURE IF EXISTS classified_condo_report_getCondoSpotlight;
DELIMITER //

CREATE PROCEDURE classified_condo_report_getCondoSpotlight(IN Condo_Code VARCHAR(50), OUT finalSpotlight TEXT)
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

-- classified_condo_report_update_spotlight
DROP PROCEDURE IF EXISTS classified_condo_report_update_spotlight;
DELIMITER //

CREATE PROCEDURE classified_condo_report_update_spotlight ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE condo	    VARCHAR(50) DEFAULT 0;
    DECLARE mySpotlight	TEXT;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'classified_condo_report_update_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code FROM classified_condo_report;

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

        CALL classified_condo_report_getCondoSpotlight(condo, mySpotlight);
        UPDATE classified_condo_report
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
END //
DELIMITER ;

-- station query
SELECT 
    ms.Station_THName_Display as Station_Name,
    msr.Route_Name as Route_Name,
    msr.Line_Name as Line_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr,
    JSON_TABLE(
        cr.Condo_Around_Station,
        '$[*]'
        COLUMNS (
            station_code varchar(100) PATH '$.Station_Code'
        )
    ) AS station
JOIN 
    mass_transit_station ms ON station.station_code = ms.Station_Code
join mass_transit_station_match_route msr on ms.station_code = msr.Station_Code
group by ms.Station_Code,ms.Station_THName_Display,msr.Route_Name,msr.Line_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- line query
SELECT 
    ml.Line_Name as Line_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr,
    JSON_TABLE(
        cr.Condo_Around_Line,
        '$[*]'
        COLUMNS (
            line_code varchar(100) PATH '$.Line_Code'
        )
    ) AS c_line
JOIN 
    mass_transit_line ml ON c_line.line_code = ml.Line_Code
group by ml.Line_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- spotlight query
SELECT 
    rs.Spotlight_Name as Spotlight_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr,
    JSON_TABLE(
        cr.Spotlight_List,
        '$[*]'
        COLUMNS (
            spotlight_code varchar(100) PATH '$.Spotlight_Code'
        )
    ) AS spotlight
JOIN 
    real_condo_spotlight rs ON spotlight.spotlight_code = rs.Spotlight_Code
where rs.Menu_List > 0
group by rs.Spotlight_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- menu price query
SELECT 
    rs.Spotlight_Name as Spotlight_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr,
    JSON_TABLE(
        cr.Spotlight_List,
        '$[*]'
        COLUMNS (
            spotlight_code varchar(100) PATH '$.Spotlight_Code'
        )
    ) AS spotlight
JOIN 
    real_condo_spotlight rs ON spotlight.spotlight_code = rs.Spotlight_Code
where rs.Menu_Price_Order > 0
group by rs.Spotlight_Name,rs.Menu_Price_Order
order by rs.Menu_Price_Order;

-- segment query
SELECT 
    rs.Segment_Name as Segment_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr
JOIN 
    real_condo_segment rs ON cr.Condo_Segment = rs.Segment_Code
group by rs.Segment_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- province query
SELECT 
    tp.name_th as Province_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr
JOIN 
    thailand_province tp ON cr.Province_code = tp.province_code
group by tp.name_th
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- district query
SELECT 
    rm.District_Name as District_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr
JOIN 
    real_yarn_main rm ON cr.District_Code = rm.District_Code
group by rm.District_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- subdistrict query
SELECT 
    rs.SubDistrict_Name as SubDistrict_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr
JOIN 
    real_yarn_sub rs ON cr.SubDistrict_Code = rs.SubDistrict_Code
group by rs.SubDistrict_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- developer query
SELECT 
    cd.Developer_Name as Developer_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr
JOIN 
    condo_developer cd ON cr.Developer_Code = cd.Developer_Code
group by cd.Developer_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;

-- brand query
SELECT 
    b.Brand_Name as Brand_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent
FROM 
    classified_condo_report cr
JOIN 
    brand b ON cr.Brand_Code = b.Brand_Code
group by b.Brand_Name
order by `Total_Room_Count` DESC, `Total_Room_Count_Sale` DESC, `Total_Room_Count_Rent` DESC, `Total_Average_Sqm_Sale` DESC;