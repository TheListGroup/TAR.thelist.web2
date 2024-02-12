CREATE OR REPLACE VIEW source_condo_fetch_for_map AS
SELECT
    a.Condo_ID
,   a.Condo_Code
,   (
        SELECT  Distance
        FROM    condo_around_station_view
        WHERE   condo_around_station_view.Condo_Code = a.Condo_Code
        ORDER BY    condo_around_station_view.Total_Point
        LIMIT 1
    )   AS `Distance`    
,   b.Condo_Price_Per_Square
,   b.Condo_Built_Text
,   b.Condo_Built_Date
,   b.Condo_Age_Status_Square_Text
,   b.Condo_Price_Per_Unit_Text
,   b.Condo_Price_Per_Unit
,   b.Condo_Sold_Status_Show_Value
,   b.Condo_Date_Calculate
,   a.Condo_ENName
,   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.Condo_Name, '\n', ''), '-', ''),'(',''),')',''),' ','') 
        AS `Condo_Name_Search`
,   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.Condo_ENName, '\n', ''), '-', ''),'(',''),')',''),' ','')
        AS `Condo_ENName_Search`
,   a.Condo_ScopeArea
,   a.Condo_Latitude
,   a.Condo_Longitude
,   a.Brand_Code
,   a.Developer_Code
,   a.RealSubDistrict_Code
,   a.RealDistrict_Code
,   a.SubDistrict_ID
,   a.District_ID
,   a.Province_ID
,   a.Condo_URL_Tag
,   a.Condo_Cover
,   IFNULL(a.No_of_Unit_Point,0) 
    + IFNULL(a.Finish_Year_Point,0)
    + IFNULL(a.HighRise_Point,0)
    + IFNULL(a.ListCompany_Point,0)
    + IFNULL(a.DistanceFromStation_Point,0) AS 'Total_Point'
FROM    condo_price_calculate_view b
,       real_condo a
WHERE   a.Condo_Code = b.Condo_Code
    AND a.Condo_Latitude <> ''
    AND a.Condo_Longitude <> ''
    AND a.Province_ID IN (10, 11, 12, 13, 73, 74)
    AND a.Condo_Status = 1  
ORDER BY a.Condo_Code ;



-- cal each Point--
SELECT
	a.Condo_Code,
    ROUND(GREATEST(LEAST((IFNULL(a.Condo_TotalUnit,80)*0.0017+4.863)*20,200),100),1) AS NO_of_Unit_Point,
    GREATEST(LEAST(((ABS(IFNULL(if(isnull(b.Condo_Built_Finished),
    if(isnull(b.Condo_Built_Start),NULL,year(b.Condo_Built_Start)),year(b.Condo_Built_Finished)),YEAR(CURRENT_DATE)-10)-YEAR(CURRENT_DATE))*-1+15)*20),200),100) 
    AS Finish_Year_Point,
    IF(a.Condo_HighRise = 1,200,100) AS HighRise_Point,
    IF((SELECT Developer_ListedCompany
        FROM condo_developer
        WHERE condo_developer.Developer_Code = a.Developer_Code
        ) = 1,200,100) AS ListCompany_Point,
    ROUND(GREATEST(LEAST((((IFNULL((SELECT MIN(condo_around_station_view.Distance)
        FROM condo_around_station_view
        WHERE condo_around_station_view.Condo_Code = a.Condo_Code
        AND condo_around_station_view.Route_Timeline IN ('Completion','Under Construction')
        ORDER BY condo_around_station_view.Distance
        LIMIT 1),2)*1000)*-0.00263157894736842+10.26)*20),200),100),1) AS DistanceFromStation_Point
FROM    real_condo_price b
,       real_condo a
WHERE   a.Condo_Code = b.Condo_Code
ORDER BY a.Condo_Code

-- ***GREATEST( LEAST(IFNULL( X, ค่าต่ำสุดของ x) * m x fdssad , 1111) , 0000 )***

/* NO_of_Unit_Point
Weight = 20
m = 0.0017 from (5-10)/(80-3000)
b = 4.863 from 5-0.0017*80
best_score = 10
Unit_to_best_score >= 3000
worst_score = 5
Unit_to_worst_score <= 80
Max_Point = 200
Min_Point = 100
default_score = 5
*/


/* Finish_Year_Point
Weight = 20
m = -1 from (5-10)/(10-5)
b = 15 from 5-(-1)*10
best_score = 10
Year_to_best_score <= 5
worst_score = 5
Year_to_worst_score >= 10
Max_Point = 200
Min_Point = 100
default_score = 5
*/


/* HighRise_Point
Weight = 20
best_score = 10
Type_to_best_score = HighRise=1
worst_score = 5
Type_to_worst_score = LowRise=1
Max_Point = 200
Min_Point = 100
default_score = 5
*/


/* ListedCompany_Point
Weight = 20
best_score = 10
ListedCompany_to_best_score = Developer_ListedCompany=1
worst_score = 5
ListedCompany_to_worst_score = Developer_ListedCompany=1
Max_Point = 200
Min_Point = 100
default_score = 5
*/


/* DistanceFromStation_Point
Weight = 20
m = -0.002631 from (5-10)/(2000-100)
b = 10.263 from 5-(-0.002631)*2000
best_score = 10
Distance_to_best_score (KM. to m.) <= 100
worst_score = 5
Distance_to_worst_score (KKM. to m.) >= 2000
Max_Point = 200
Min_Point = 100
default_score = 5
*/


-- update_Point
DROP PROCEDURE IF EXISTS update_Point;
DELIMITER $$

CREATE PROCEDURE update_Point ()
BEGIN
    DECLARE finished  INTEGER     DEFAULT 0;
	DECLARE eachcondo  VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_Point';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    -- declare cursor 
	DEClARE curcondo
		CURSOR FOR 
			SELECT Condo_Code FROM real_condo;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

    -- declare SQLEXCEPTION handler	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO Realist_Log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
            set errorcheck = 0;
        END;    

    OPEN curcondo;

	updateTotal_Point: LOOP
		FETCH curcondo INTO eachcondo;
		IF finished = 1 THEN 
			LEAVE updateTotal_Point;
		END IF;

        UPDATE  real_condo
        SET	    NO_of_Unit_Point        = ROUND(GREATEST(LEAST((IFNULL(Condo_TotalUnit,80)*0.0017+4.863)*20,200),100),1),
                Finish_Year_Point       =   (SELECT GREATEST(LEAST(((ABS(IFNULL(if(isnull(Condo_Built_Finished),
                                            if(isnull(Condo_Built_Start),NULL,year(Condo_Built_Start)),year(Condo_Built_Finished)),
                                            YEAR(CURRENT_DATE)-10)-YEAR(CURRENT_DATE))*-1+15)*20),200),100)
                                            FROM real_condo_price
                                            WHERE real_condo_price.Condo_Code = eachcondo),
                HighRise_Point          = IF(Condo_HighRise = 1,200,100),
                ListCompany_Point       = IF((SELECT Developer_ListedCompany
                                            FROM condo_developer,
                                                real_condo_price
                                            WHERE condo_developer.Developer_Code = real_condo.Condo_Code
                                            AND real_condo_price.Condo_Code = eachcondo) = 1,200,100),
                DistanceFromStation_Point = ROUND(GREATEST(LEAST((((IFNULL((SELECT MIN(condo_around_station_view.Distance)
                                            FROM condo_around_station_view,
                                                real_condo_price
                                            WHERE condo_around_station_view.Condo_Code = real_condo_price.Condo_Code
                                            AND condo_around_station_view.Route_Timeline IN ('Completion','Under Construction')
                                            AND real_condo_price.Condo_Code = eachcondo
                                            ORDER BY condo_around_station_view.Distance
                                            LIMIT 1),2)*1000)*-0.00263157894736842+10.26)*20),200),100),1)
        WHERE   Condo_Code = eachcondo;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateTotal_Point;

    if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO Realist_Log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curcondo;

END$$
DELIMITER ;



