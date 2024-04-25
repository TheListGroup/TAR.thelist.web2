-- function
-- Table factsheet_price_view
-- source_factsheet_price_view
-- truncateInsert_factsheet_price_view
-- source_full_template_factsheet_view
-- Table full_template_factsheet
-- truncateInsert_full_template_factsheet
-- รวม procedure

-- update table
update real_condo
set Road_Name = null
where Road_Name = '';

update real_condo
set RealDistrict_Code = null
where RealDistrict_Code = '';

update real_condo
set RealSubDistrict_Code = null
where RealSubDistrict_Code = '';

-- update table
update real_condo_full_template
set Condo_Fund_Fee = null
where Condo_Fund_Fee = '';

-- function ใส่หน่วย
DELIMITER //

CREATE FUNCTION bath(letter VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = CONCAT(letter, ' บ./ตร.ม.');
    RETURN unit;
END //

-- function ใส่วงเล็บ
DELIMITER //

CREATE FUNCTION bk(brank VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = CONCAT('(',brank,')');
    RETURN unit;
END //

-- function check null
DELIMITER //

CREATE FUNCTION nun(nan VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = if(nan='','-',ifnull(nan,'-'));
    RETURN unit;
END //

-- Table `factsheet_price_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `factsheet_price_view` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Price_Average_Square_Date` VARCHAR(9) NULL,
    `Price_Average_Square` VARCHAR(50) NOT NULL,
    `Source_Price_Average_Square` VARCHAR(250) NOT NULL,
    `Price_Average_Resale_Square_Date` VARCHAR(9) NULL,
    `Price_Average_Resale_Square` VARCHAR(50) NOT NULL,
    `Source_Price_Average_Resale_Square` VARCHAR(250) NOT NULL,
    `Price_Start_Square_Date` VARCHAR(9) NULL,
    `Price_Start_Square` VARCHAR(50) NOT NULL,
    `Source_Price_Start_Square` VARCHAR(250) NOT NULL,
    `Condo_Price_Per_Unit_Text` VARCHAR(60) NOT NULL,
    `Price_Start_Unit_Date` VARCHAR(9) NULL,
    `Price_Start_Unit` VARCHAR(20) NOT NULL,
    `Source_Price_Start_Unit` VARCHAR(250) NOT NULL,
    PRIMARY KEY (`Condo_Code`))
ENGINE = InnoDB;

-- source_factsheet_price_view
CREATE OR REPLACE VIEW source_factsheet_price_view AS 
select cpc.Condo_Code,
    bk(CASE
        WHEN COALESCE(avg_compre_sqm.Price_Date, '1900-01-01') > COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') 
        THEN concat(if(month(avg_compre_sqm.Price_Date)<10,concat('0',month(avg_compre_sqm.Price_Date)),month(avg_compre_sqm.Price_Date)),'/',year(avg_compre_sqm.Price_Date))
        ELSE concat(if(month(avg_dev_survey_sqm.Price_Date)<10,concat('0',month(avg_dev_survey_sqm.Price_Date)),month(avg_dev_survey_sqm.Price_Date)),'/',year(avg_dev_survey_sqm.Price_Date))
    END) as Price_Average_Square_Date,
    nun(bath(format(CASE
                        WHEN COALESCE(avg_compre_sqm.Price_Date, '1900-01-01') > COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') 
                        THEN round(avg_compre_sqm.Price, -3)
                        ELSE round(avg_dev_survey_sqm.Price, -3)
                    END,0))) as Price_Average_Square,
    nun(CASE
            WHEN COALESCE(avg_compre_sqm.Price_Date, '1900-01-01') > COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') 
            THEN avg_compre_sqm.Price_Source
            ELSE avg_dev_survey_sqm.Price_Source
        END) as Source_Price_Average_Square,
    bk(concat(if(month(resale.Price_Date)<10,concat('0',month(resale.Price_Date)),month(resale.Price_Date)),'/',year(resale.Price_Date))) as Price_Average_Resale_Square_Date,
    nun(bath(format(round(resale.Price,-3),0))) as Price_Average_Resale_Square,
    nun(resale.Price_Source) as Source_Price_Average_Resale_Square,
    bk(CASE
        WHEN COALESCE(start_compre_sqm.Price_Date, '1900-01-01') > COALESCE(start_dev_survey_sqm.Price_Date, '1900-01-01') 
        THEN concat(if(month(start_compre_sqm.Price_Date)<10,concat('0',month(start_compre_sqm.Price_Date)),month(start_compre_sqm.Price_Date)),'/',year(start_compre_sqm.Price_Date))
        ELSE concat(if(month(start_dev_survey_sqm.Price_Date)<10,concat('0',month(start_dev_survey_sqm.Price_Date)),month(start_dev_survey_sqm.Price_Date)),'/',year(start_dev_survey_sqm.Price_Date))
    END) as Price_Start_Square_Date,
    nun(bath(format(CASE
                        WHEN COALESCE(start_compre_sqm.Price_Date, '1900-01-01') > COALESCE(start_dev_survey_sqm.Price_Date, '1900-01-01') 
                        THEN round(start_compre_sqm.Price, -3)
                        ELSE round(start_dev_survey_sqm.Price, -3)
                    END,0))) as Price_Start_Square,
    nun(CASE
            WHEN COALESCE(start_compre_sqm.Price_Date, '1900-01-01') > COALESCE(start_dev_survey_sqm.Price_Date, '1900-01-01') 
            THEN start_compre_sqm.Price_Source
            ELSE start_dev_survey_sqm.Price_Source
        END) as Source_Price_Start_Square,
    'ราคาเริ่มต้น / ยูนิต' as Condo_Price_Per_Unit_Text,
    bk(concat(if(month(start_unit.Price_Date)<10,concat('0',month(start_unit.Price_Date)),month(start_unit.Price_Date)),'/',year(start_unit.Price_Date))) as Price_Start_Unit_Date,
    nun(concat(round((cpc.Condo_Price_Per_Unit_Cal/1000000),2),' ลบ.')) as Price_Start_Unit,
    nun(start_unit.Price_Source) as Source_Price_Start_Unit
from all_condo_price_calculate cpc
left join ( select Condo_Code
                , Price
                , Price_Date
                , Price_Source
            from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ps.Head as Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                    FROM all_price_view ap
                    left join price_source ps on ap.Price_Source = ps.ID
                    where ps.Head = 'Company Presentation'
                    and ap.Price_Type = 'บ/ตรม'
                    and ap.Start_or_AVG = 'เฉลี่ย'
                    and ap.Resale = '0') order_compre_sqm
            where Myorder = 1) avg_compre_sqm
on cpc.Condo_Code = avg_compre_sqm.Condo_Code
left join ( select Condo_Code
                , Price
                , Price_Date
                , Price_Source
            from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ps.Head as Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                    FROM all_price_view ap
                    left join price_source ps on ap.Price_Source = ps.ID
                    where ps.Head in ('Online Survey','Developer')
                    and ap.Price_Type = 'บ/ตรม'
                    and ap.Start_or_AVG = 'เฉลี่ย'
                    and ap.Resale = '0') order_dev_survey_sqm
            where Myorder = 1) avg_dev_survey_sqm
on cpc.Condo_Code = avg_dev_survey_sqm.Condo_Code
left join ( select Condo_Code
                , Price
                , Price_Date
                , Price_Source
            from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ps.Head as Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                    FROM all_price_view ap
                    left join price_source ps on ap.Price_Source = ps.ID
                    where ap.Price_Type = 'บ/ตรม'
                    and ap.Start_or_AVG = 'เฉลี่ย'
                    and ap.Resale = '1') order_resale
            where Myorder = 1) resale
on cpc.Condo_Code = resale.Condo_Code
left join ( select Condo_Code
                , Price
                , Price_Date
                , Price_Source
            from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ps.Head as Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                    FROM all_price_view ap
                    left join price_source ps on ap.Price_Source = ps.ID
                    where ps.Head = 'Company Presentation'
                    and ap.Price_Type = 'บ/ตรม'
                    and ap.Start_or_AVG = 'เริ่มต้น'
                    and ap.Resale = '0') order_compre_sqm
            where Myorder = 1) start_compre_sqm
on cpc.Condo_Code = start_compre_sqm.Condo_Code
left join ( select Condo_Code
                , Price
                , Price_Date
                , Price_Source
            from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ps.Head as Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                    FROM all_price_view ap
                    left join price_source ps on ap.Price_Source = ps.ID
                    where ps.Head in ('Online Survey','Developer')
                    and ap.Price_Type = 'บ/ตรม'
                    and ap.Start_or_AVG = 'เริ่มต้น'
                    and ap.Resale = '0') order_compre_sqm
            where Myorder = 1) start_dev_survey_sqm
on cpc.Condo_Code = start_dev_survey_sqm.Condo_Code
left join ( select Condo_Code
                , Price
                , Price_Date
                , Price_Source
            from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ps.Head as Price_Source
                    , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                    FROM all_price_view ap
                    left join price_source ps on ap.Price_Source = ps.ID
                    where ap.Price_Type = 'บ/ยูนิต'
                    and ap.Start_or_AVG = 'เริ่มต้น'
                    and ap.Resale = '0') order_start_unit
            where Myorder = 1) start_unit
on cpc.Condo_Code = start_unit.Condo_Code;


-- truncateInsert_factsheet_price_view
DROP PROCEDURE IF EXISTS truncateInsert_factsheet_price_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_factsheet_price_view ()
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

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_factsheet_price_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Price_Average_Square_Date, Price_Average_Square, Source_Price_Average_Square
                                , Price_Average_Resale_Square_Date, Price_Average_Resale_Square, Source_Price_Average_Resale_Square
                                , Price_Start_Square_Date, Price_Start_Square, Source_Price_Start_Square, Condo_Price_Per_Unit_Text
                                , Price_Start_Unit_Date, Price_Start_Unit, Source_Price_Start_Unit
                            FROM source_factsheet_price_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    factsheet_price_view;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            factsheet_price_view(
                `Condo_Code`,
                `Price_Average_Square_Date`,
                `Price_Average_Square`,
                `Source_Price_Average_Square`,
                `Price_Average_Resale_Square_Date`,
                `Price_Average_Resale_Square`,
                `Source_Price_Average_Resale_Square`,
                `Price_Start_Square_Date`,
                `Price_Start_Square`,
                `Source_Price_Start_Square`,
                `Condo_Price_Per_Unit_Text`,
                `Price_Start_Unit_Date`,
                `Price_Start_Unit`,
                `Source_Price_Start_Unit`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13);
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;


-- source_full_template_factsheet_view
CREATE OR REPLACE VIEW source_full_template_factsheet_view AS 
SELECT cpc.Condo_Code as Condo_Code,
    nun(Station) as Station,
    nun(rc.Road_Name) as Road_Name,
    nun(td.name_th) as District_Name,
    nun(rd.District_Name) as Real_District,
    nun(tp.name_th) as Province,
    price.Price_Average_Square_Date as Price_Average_Square_Date,
    price.Price_Average_Square as Price_Average_Square,
    price.Source_Price_Average_Square as Source_Price_Average_Square,
    price.Price_Average_Resale_Square_Date as Price_Average_Resale_Square_Date,
    price.Price_Average_Resale_Square as Price_Average_Resale_Square,
    price.Source_Price_Average_Resale_Square as Source_Price_Average_Resale_Square,
    price.Price_Start_Square_Date as Price_Start_Square_Date,
    price.Price_Start_Square as Price_Start_Square,
    price.Source_Price_Start_Square as Source_Price_Start_Square,
    price.Condo_Price_Per_Unit_Text as Condo_Price_Per_Unit_Text,
    price.Price_Start_Unit_Date as Price_Start_Unit_Date,
    nun(concat(round((cpc.Condo_Price_Per_Unit_Cal/1000000),2),' ลบ.')) as Price_Start_Unit,
    price.Source_Price_Start_Unit as Source_Price_Start_Unit,
    nun(concat(rcp.Condo_Common_Fee,' บ./ตร.ม./เดือน')) as Common_Fee,
    ifnull(cpc.Condo_Built_Text,'ปีที่แล้วเสร็จ') as Condo_Built_Text,
    nun(cpc.Condo_Built_Date) as Condo_Built_Date,
    nun(concat(format(rc.Condo_TotalRai,2),' ไร่')) as Land,
    nun(rc.Condo_Building) as Condo_Building,
    nun(concat(rc.Condo_TotalUnit,' ยูนิต')) as Condo_Total_Unit,
    if(cpc.Condo_Sold_Status_Show_Value = 'RESALE','RESALE',
        nun(concat(format((cpc.Condo_Sold_Status_Show_Value*100),0),'% SOLD'))) as Condo_Sold_Status_Show_Value,
    nun(cpc.Source_Condo_Sold_Status_Show_Value) as Source_Condo_Sold_Status_Show_Value,
    nun(bedsize.STU_Size) as STU_Size,
    nun(bedsize.1BED_Size) as 1BED_Size,
    nun(bedsize.2BED_Size) as 2BED_Size,
    nun(bedsize.3BED_Size) as 3BED_Size,
    nun(bedsize.4BED_Size) as 4BED_Size,
    nun(concat(rcft.Parking_Amount,' คัน')) as Parking_Amount,
    if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'Y'),'ที่จอดรถแบบวนจอด, อัตโนมัติ',
        if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'N'),'ที่จอดรถอัตโนมัติ',
            if((rcft.Auto_Parking_Status = 'N' and rcft.Manual_Parking_Status = 'Y'),'ที่จอดรถแบบวนจอด',
                if((rcft.Auto_Parking_Status = 'N' and rcft.Parking_Amount is not null),'ที่จอดรถแบบวนจอด',
                    if(rcft.Manual_Parking_Status = 'Y','ที่จอดรถแบบวนจอด',
                        if(rcft.Auto_Parking_Status = 'Y','ที่จอดรถอัตโนมัติ',
                            if(rcft.Parking_Amount is not null,'ที่จอดรถแบบวนจอด','ที่จอดรถแบบวนจอด, อัตโนมัติ'))))))) as Parking_Text,
    if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'Y'),
            ifnull(concat(rcft.Manual_Parking_Amount,' + ',rcft.Auto_Parking_Amount,' คัน'),
            ifnull(concat(rcft.Manual_Parking_Amount,' + ',rcft.Parking_Amount-rcft.Manual_Parking_Amount,' คัน'),
            ifnull(concat(rcft.Parking_Amount-rcft.Auto_Parking_Amount,' + ',rcft.Auto_Parking_Amount,' คัน'),
            nun(concat(rcft.Parking_Amount,' คัน'))))),
                if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'N'),
                    ifnull(concat(rcft.Auto_Parking_Amount,' คัน'),
                    nun(concat(rcft.Parking_Amount,' คัน'))),
                        if((rcft.Auto_Parking_Status = 'N' and rcft.Manual_Parking_Status = 'Y'),
                            ifnull(concat(rcft.Manual_Parking_Amount,' คัน'),
                            nun(concat(rcft.Parking_Amount,' คัน'))),
                                if((rcft.Auto_Parking_Status = 'N' and rcft.Parking_Amount is not null),
                                    ifnull(concat(rcft.Manual_Parking_Amount,' คัน'),
                                    nun(concat(rcft.Parking_Amount,' คัน'))),
                                        if(rcft.Manual_Parking_Status = 'Y',
                                            ifnull(concat(rcft.Manual_Parking_Amount,' คัน'),
                                            nun(concat(rcft.Parking_Amount,' คัน'))),
                                                if(rcft.Auto_Parking_Status = 'Y',
                                                    ifnull(concat(rcft.Auto_Parking_Amount,' คัน'),
                                                    nun(concat(rcft.Parking_Amount,' คัน'))),
                                                        if(rcft.Parking_Amount is not null,
                                                            nun(concat(rcft.Parking_Amount,' คัน')),'-'))))))) as Parking_Type_Amount,
    nun(concat(format(((rcft.Parking_Amount/rc.Condo_TotalUnit)*100),0),' %')) as Parking_Per_Unit,
    nun(concat(format(((rcft.Parking_Amount)/if(((ifnull(rcft.STU_Amount,0)*1)
                                                    +(ifnull(rcft.1BR_Amount,0)*1)
                                                        +(ifnull(rcft.2BR_Amount,0)*2)
                                                            +(ifnull(rcft.3BR_Amount,0)*3)
                                                                +(ifnull(rcft.4BR_Amount,0)*4))>0,
                                                    ((ifnull(rcft.STU_Amount,0)*1)
                                                        +(ifnull(rcft.1BR_Amount,0)*1)
                                                            +(ifnull(rcft.2BR_Amount,0)*2)
                                                                +(ifnull(rcft.3BR_Amount,0)*3)
                                                                    +(ifnull(rcft.4BR_Amount,0)*4)),null)*100),0),'%')) as Parking_Per_BedRoom,
    nun(bath(rcft.Condo_Fund_Fee)) as Condo_Fund_Fee,
    if((rcft.Passenger_Lift_Amount and rcft.Service_Lift_Amount)>0,'ลิฟท์โดยสาร, Service',
                if(rcft.Passenger_Lift_Amount > 0,'ลิฟท์โดยสาร',
                    if(rcft.Service_Lift_Amount > 0,'ลิฟท์ Service','ลิฟท์โดยสาร, Service'))) as Lift_Type_Text,
    if((rcft.Passenger_Lift_Amount and rcft.Service_Lift_Amount)>0,
                nun(concat(rcft.Passenger_Lift_Amount,', ',rcft.Service_Lift_Amount,' ชุด')),
                    if(rcft.Passenger_Lift_Amount > 0,
                        nun(concat(rcft.Passenger_Lift_Amount,' ชุด')),
                            if(rcft.Service_Lift_Amount > 0,
                                nun(concat(rcft.Service_Lift_Amount,' ชุด')),'-'))) as Lift_Type_Amount,
    nun(concat('1 : ',format(rc.Condo_TotalUnit/if(rcft.Passenger_Lift_Amount>0,rcft.Passenger_Lift_Amount,null),0))) as Passanger_Lift_Unit_Ratio,
    if((rcft.Private_Lift_Status = 'Y' and rcft.LockElevator_Status = 'Y' and rcft.UnLockElevator_Status = 'Y'),'ส่วนตัว, ล็อคชั้น, ไม่ล็อคชั้น',
        if((rcft.Private_Lift_Status = 'Y' and rcft.LockElevator_Status = 'Y'),'ส่วนตัว, ล็อคชั้น',
        if((rcft.Private_Lift_Status = 'Y' and rcft.UnLockElevator_Status = 'Y'),'ส่วนตัว, ไม่ล็อคชั้น',
        if((rcft.LockElevator_Status = 'Y' and rcft.UnLockElevator_Status = 'Y'),'ล็อคชั้น, ไม่ล็อคชั้น',
            if(rcft.Private_Lift_Status = 'Y','ส่วนตัว',
            if(rcft.LockElevator_Status = 'Y','ล็อคชั้น',
            if(rcft.UnLockElevator_Status = 'Y','ไม่ล็อคชั้น','-'))))))) as Lift_Type,
    ifnull(concat('สระว่ายน้ำ ',rcft.Pool_Name),'สระว่ายน้ำ') as Pool_Text,
    ifnull(concat(rcft.Pool_Width,' x ',rcft.Pool_Length,' ม.'),
                ifnull(concat(rcft.Pool_Width,' ม.'),
                    nun(concat(rcft.Pool_Length,' ม.')))) as Pool_Size,
    ifnull(concat('สระว่ายน้ำ ',rcft.Pool_2_Name),
        if(rcft.Pool_2_Width is not null or rcft.Pool_2_Length is not null,'สระว่ายน้ำ',null)) as Pool_2_Text,
    ifnull(concat(rcft.Pool_2_Width,' x ',rcft.Pool_2_Length,' ม.'),
                ifnull(concat(rcft.Pool_2_Width,' ม.'),
                    ifnull(concat(rcft.Pool_2_Length,' ม.'),null))) as Pool_2_Size,
    if(if(ifnull(rcft.Parking_Amount,0)+ifnull(rcft.Condo_Fund_Fee,0)>0,1,0) + 
        if(if(ifnull(rcft.Passenger_Lift_Amount,0)+ifnull(rcft.Service_Lift_Amount,0)>0,1,0) + 
            if(ifnull(rcft.Pool_Width,0)+ifnull(rcft.Pool_Length,0)>0,1,0)>0,1,0)=2,1,0) as FactSheet_Status
FROM all_condo_price_calculate as cpc
inner join real_condo_price as rcp on cpc.Condo_Code = rcp.Condo_Code
inner join real_condo as rc on cpc.Condo_Code = rc.Condo_Code
left join thailand_district as td on rc.District_ID = td.district_code
left join real_yarn_main as rd on rc.RealDistrict_Code = rd.District_Code
inner join thailand_province as tp on rc.Province_ID = tp.province_code
inner join real_condo_full_template as rcft on cpc.Condo_Code = rcft.Condo_Code
inner join factsheet_price_view price on cpc.Condo_Code = price.Condo_Code
left join ( select Condo_Code,Station_THName_Display as Station
            from (  select cv.Condo_Code
                            , ms.Station_THName_Display
                            , ROW_NUMBER() OVER (PARTITION BY cv.Condo_Code ORDER BY cv.Total_Point) AS RowNum
                    from condo_around_station_view as cv 
                    inner join mass_transit_station as ms on cv.Station_Code = ms.Station_Code
                    order by cv.Condo_Code) a
            where a.RowNum = 1) as sub_station
on cpc.Condo_Code = sub_station.Condo_Code
inner join (select rc.Condo_Code as Condo_Code, size1.STU_Size, size2.1BED_Size, size3.2BED_Size, size4.3BED_Size, size5.4BED_Size
            from real_condo rc
            left join (SELECT Condo_Code
                        ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                                unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS STU_Size
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 1
                        GROUP BY Condo_Code) as size1
            on rc.Condo_Code = size1.Condo_Code
            left join (SELECT Condo_Code
                        ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                                unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 1BED_Size
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 2
                        GROUP BY Condo_Code) as size2
            on rc.Condo_Code = size2.Condo_Code
            left join (SELECT Condo_Code
                        ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                                unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 2BED_Size
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 4
                        GROUP BY Condo_Code) as size3
            on rc.Condo_Code = size3.Condo_Code
            left join (SELECT Condo_Code
                        ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                                unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 3BED_Size
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 5
                        GROUP BY Condo_Code) as size4
            on rc.Condo_Code = size4.Condo_Code
            left join (SELECT Condo_Code
                        ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                                unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 4BED_Size
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 6
                        GROUP BY Condo_Code) as size5
            on rc.Condo_Code = size5.Condo_Code) bedsize
on cpc.Condo_Code = bedsize.Condo_Code
order by cpc.Condo_Code;

-- -----------------------------------------------------
-- Table `full_template_factsheet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_factsheet` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Station` VARCHAR(200) NOT NULL,
    `Road_Name` VARCHAR(150) NOT NULL,
    `District_Name` VARCHAR(150) NOT NULL,
    `Real_District` VARCHAR(150) NOT NULL,
    `Province` VARCHAR(150) NOT NULL,
    `Price_Average_Square_Date` VARCHAR(9) NULL,
    `Price_Average_Square` VARCHAR(50) NOT NULL,
    `Source_Price_Average_Square` VARCHAR(250) NOT NULL,
    `Price_Average_Resale_Square_Date` VARCHAR(9) NULL,
    `Price_Average_Resale_Square` VARCHAR(50) NOT NULL,
    `Source_Price_Average_Resale_Square` VARCHAR(250) NOT NULL,
    `Price_Start_Square_Date` VARCHAR(9) NULL,
    `Price_Start_Square` VARCHAR(50) NOT NULL,
    `Source_Price_Start_Square` VARCHAR(250) NOT NULL,
    `Condo_Price_Per_Unit_Text` VARCHAR(60) NOT NULL,
    `Price_Start_Unit_Date` VARCHAR(9) NULL,
    `Price_Start_Unit` VARCHAR(20) NOT NULL,
    `Source_Price_Start_Unit` VARCHAR(250) NOT NULL,
    `Common_Fee` VARCHAR(50) NOT NULL,
    `Condo_Built_Text` VARCHAR(60) NOT NULL,
    `Condo_Built_Date` VARCHAR(4) NOT NULL,
    `Land` VARCHAR(20) NOT NULL,
    `Condo_Building` VARCHAR(250) NOT NULL,
    `Condo_Total_Unit` VARCHAR(30) NOT NULL,
    `Condo_Sold_Status_Show_Value` VARCHAR(10) NOT NULL,
    `Source_Condo_Sold_Status_Show_Value` VARCHAR(250) NOT NULL,
    `STU_Size` VARCHAR(50) NOT NULL,
    `1BED_Size` VARCHAR(50) NOT NULL,
    `2BED_Size` VARCHAR(50) NOT NULL,
    `3BED_Size` VARCHAR(50) NOT NULL,
    `4BED_Size` VARCHAR(50) NOT NULL,
    `Parking_Amount` VARCHAR(20) NOT NULL,
    `Parking_Text` VARCHAR(80) NOT NULL,
    `Parking_Type_Amount` VARCHAR(100) NOT NULL,
    `Parking_Per_Unit` VARCHAR(6) NOT NULL,
    `Parking_Per_BedRoom` VARCHAR(6) NOT NULL,
    `Condo_Fund_Fee` VARCHAR(30) NOT NULL,
    `Lift_Type_Text` VARCHAR(50) NOT NULL,
    `Lift_Type_Amount` VARCHAR(20) NOT NULL,
    `Passanger_Lift_Unit_Ratio` VARCHAR(10) NOT NULL,
    `Lift_Type` VARCHAR(60) NOT NULL,
    `Pool_Text` VARCHAR(250) NOT NULL,
    `Pool_Size` VARCHAR(20) NOT NULL,
    `Pool_2_Text` VARCHAR(250) NULL,
    `Pool_2_Size` VARCHAR(20) NULL,
    `FactSheet_Status` INT(1) UNSIGNED NOT NULL,
    PRIMARY KEY (`Condo_Code`))
ENGINE = InnoDB;

-- truncateInsert_full_template_factsheet
DROP PROCEDURE IF EXISTS truncateInsert_full_template_factsheet;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_factsheet ()
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

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_full_template_factsheet';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code, Station, Road_Name, District_Name, Real_District, Province, Price_Average_Square_Date
                                , Price_Average_Square, Source_Price_Average_Square, Price_Average_Resale_Square_Date
                                , Price_Average_Resale_Square, Source_Price_Average_Resale_Square, Price_Start_Square_Date
                                , Price_Start_Square, Source_Price_Start_Square, Condo_Price_Per_Unit_Text, Price_Start_Unit_Date
                                , Price_Start_Unit, Source_Price_Start_Unit, Common_Fee, Condo_Built_Text, Condo_Built_Date
                                , Land, Condo_Building, Condo_Total_Unit, Condo_Sold_Status_Show_Value, Source_Condo_Sold_Status_Show_Value
                                , STU_Size, 1BED_Size, 2BED_Size, 3BED_Size, 4BED_Size, Parking_Amount, Parking_Text, Parking_Type_Amount
                                , Parking_Per_Unit, Parking_Per_BedRoom, Condo_Fund_Fee, Lift_Type_Text, Lift_Type_Amount
                                , Passanger_Lift_Unit_Ratio, Lift_Type, Pool_Text, Pool_Size, Pool_2_Text, Pool_2_Size, FactSheet_Status
                            FROM source_full_template_factsheet_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_factsheet;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_factsheet(
                `Condo_Code`,
                `Station`,    
                `Road_Name`,
                `District_Name`,
                `Real_District`,
                `Province`,
                `Price_Average_Square_Date`,
                `Price_Average_Square`,
                `Source_Price_Average_Square`,
                `Price_Average_Resale_Square_Date`,
                `Price_Average_Resale_Square`,
                `Source_Price_Average_Resale_Square`,
                `Price_Start_Square_Date`,
                `Price_Start_Square`,
                `Source_Price_Start_Square`,
                `Condo_Price_Per_Unit_Text`,
                `Price_Start_Unit_Date`,
                `Price_Start_Unit`,
                `Source_Price_Start_Unit`,
                `Common_Fee`,
                `Condo_Built_Text`,
                `Condo_Built_Date`,
                `Land`,
                `Condo_Building`,
                `Condo_Total_Unit`,
                `Condo_Sold_Status_Show_Value`,
                `Source_Condo_Sold_Status_Show_Value`,
                `STU_Size`,
                `1BED_Size`,
                `2BED_Size`,
                `3BED_Size`,
                `4BED_Size`,
                `Parking_Amount`,
                `Parking_Text`,
                `Parking_Type_Amount`,
                `Parking_Per_Unit`,
                `Parking_Per_BedRoom`,
                `Condo_Fund_Fee`,
                `Lift_Type_Text`,
                `Lift_Type_Amount`,
                `Passanger_Lift_Unit_Ratio`,
                `Lift_Type`,
                `Pool_Text`,
                `Pool_Size`,
                `Pool_2_Text`,
                `Pool_2_Size`,
                `FactSheet_Status`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46);
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;

-- รวม procedure
DROP PROCEDURE IF EXISTS truncateInsertViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertViewToTable ()
BEGIN

	CALL truncateInsert_condo_price_calculate_view ();
    CALL truncateInsert_condo_spotlight_relationship_view ();
	CALL truncateInsert_condo_fetch_for_map ();
    CALL truncateInsert_article_condo_fetch_for_map ();
    CALL ads_update_spotlight ();
    CALL truncateInsert_all_condo_spotlight_relationship ();
    CALL ads_update_allspotlight ();
	CALL truncateInsert_mass_transit_station_match_route ();
    CALL truncateInsert_factsheet_price_view ();
    CALL truncateInsert_full_template_factsheet ();
    CALL truncateInsert_full_template_element_image_view ();
    CALL truncateInsert_full_template_credit_view ();
    CALL truncateInsert_full_template_facilities_icon_view ();
    CALL truncateInsert_full_template_section_shortcut_view ();
    CALL truncateInsert_full_template_unit_plan_gallery_raw ();
    CALL truncateInsert_full_template_unit_plan_facilities_image_raw ();
    CALL truncateInsert_full_template_unit_plan_image_raw ();
    CALL truncateInsert_full_template_unit_plan_fullscreen_view ();
    CALL truncateInsert_full_template_unit_gallery_fullscreen_view ();
    CALL truncateInsert_full_template_floor_plan_fullscreen_view ();
    CALL truncateInsert_full_template_facilities_gallery_fullscreen_view ();
    CALL truncateInsertViewSearch ();
    CALL truncateInsert_classified_list_view ();
    CALL truncateInsert_classified_detail_view ();

END$$
DELIMITER ;