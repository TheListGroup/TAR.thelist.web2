-- table classified_condo_fetch_for_map_user
CREATE TABLE IF NOT EXISTS classified_condo_fetch_for_map_user (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(50) NOT NULL,
    User_ID INT UNSIGNED NOT NULL,
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
    Last_Updated_Date varchar(20) null,
    Last_Updated_Date_Sort date null,
    Spotlight_List json DEFAULT NULL,
    PRIMARY KEY (ID),
    INDEX cfucode (Condo_Code),
    INDEX cfusegment (Condo_Segment),
    INDEX cfuprovince (Province_code),
    INDEX cfudistrict (District_Code),
    INDEX cfusubdistrict (SubDistrict_Code),
    INDEX cfudev (Developer_Code),
    INDEX cfubrand (Brand_Code),
    INDEX cfulat (Condo_Latitude),
    INDEX cfulong (Condo_Longitude),
    INDEX cfuuserid (User_ID),
    CONSTRAINT cfu_user FOREIGN KEY (User_ID) REFERENCES classified_user(User_ID))
ENGINE = InnoDB;


-- procedure truncateInsert_classified_condo_fetch_for_map_user
DROP PROCEDURE IF EXISTS truncateInsert_classified_condo_fetch_for_map_user;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_condo_fetch_for_map_user ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE each_id INT DEFAULT 0;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_condo_fetch_for_map_user';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR select User_ID from classified_user;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE classified_condo_fetch_for_map_user;

    open cur;

    insertuser: LOOP
		FETCH cur INTO each_id;
		IF done = 1 THEN 
			LEAVE insertuser;
		END IF;

        insert into classified_condo_fetch_for_map_user (Condo_Code, User_ID, Condo_ENName, Condo_ScopeArea, Condo_Latitude, Condo_Longitude, Room_Count_Sale
            , Price_Sale_Min, Use_Price_Sale_Min, Price_Sale_Sqm, Use_Price_Sale_Sqm, AVG_Price_Per_Unit_Sqm_Sale, Use_AVG_Per_Unit_Sqm_Sale, Room_Count_Rent
            , Price_Rent_Min, Use_Price_Rent_Min, Price_Rent_Sqm, Use_Price_Rent_Sqm, AVG_Price_Per_Unit_Sqm_Rent, Use_AVG_Per_Unit_Sqm_Rent, Condo_Segment
            , Province_code, District_Code, SubDistrict_Code, Developer_Code, Brand_Code, Condo_Around_Line, Condo_Around_Station, Condo_URL_Tag, Condo_Cover
            , Total_Point, Last_Updated_Date, Last_Updated_Date_Sort)
        select rc.Condo_Code
            , each_id
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
            , updateday.Last_Updated_Date
            , updateday.Last_Updated_Date_Sort
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
                    and User_ID = each_id
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
                        and User_ID = each_id
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
                    and User_ID = each_id
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
                        and User_ID = each_id
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
        left join (SELECT Condo_Code
                        , max(date(Last_Updated_Date)) as Last_Updated_Date_Sort  
                        , concat(if(length(day(max(Last_Updated_Date)))=2
                                    , day(max(Last_Updated_Date))
                                    , concat("0",day(max(Last_Updated_Date)))) ,'/'
                                ,if(length(month(max(Last_Updated_Date)))=2
                                    , month(max(Last_Updated_Date))
                                    , concat("0",month(max(Last_Updated_Date)))),'/'
                                ,year(max(Last_Updated_Date))) as Last_Updated_Date
                    FROM classified
                    where Classified_Status = '1'
                    and User_ID = each_id
                    group by Condo_Code) updateday
        on rc.Condo_Code = updateday.Condo_Code
        inner join (select Condo_Code 
                    from classified 
                    where Classified_Status = '1' 
                    and User_ID = each_id
                    group by Condo_Code) user_id 
        on rc.Condo_Code = user_id.Condo_Code 
        where rc.Condo_Status = 1;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP insertuser;

    update classified_condo_fetch_for_map_user a
    JOIN classified_condo_fetch_for_map b ON a.Condo_Code = b.Condo_Code
    SET a.Spotlight_List = b.Spotlight_List;

	if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(rowCount,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;
END //
DELIMITER ;