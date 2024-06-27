-- update column in classified_user table
-- procedure updateClassified_User

-- update column in classified_user table
ALTER TABLE `classified_user` ADD `Classified_Now` INT UNSIGNED NULL AFTER `Facebook`;
ALTER TABLE `classified_user` ADD `Classified_All` INT UNSIGNED NULL AFTER `Classified_Now`;
ALTER TABLE `classified_user` ADD `Condo_Count` INT UNSIGNED NULL AFTER `Classified_All`;
ALTER TABLE `classified_user` ADD `Condo_Age` float(4,1) NULL AFTER `Condo_Count`;
ALTER TABLE `classified_user` ADD `Room_Size` varchar(10) NULL AFTER `Condo_Age`;
ALTER TABLE `classified_user` ADD `Bedroom` varchar(5) NULL AFTER `Room_Size`;
ALTER TABLE `classified_user` ADD `Price_Sale_Min` float(6,2) NULL AFTER `Bedroom`;
ALTER TABLE `classified_user` ADD `Price_Rent_Min` INT UNSIGNED NULL AFTER `Price_Sale_Min`;
ALTER TABLE `classified_user` ADD `Price_Sale_Average` float(6,2) NULL AFTER `Price_Rent_Min`;
ALTER TABLE `classified_user` ADD `Price_Sale_Sqm_Average` INT UNSIGNED NULL AFTER `Price_Sale_Average`;
ALTER TABLE `classified_user` ADD `Common_Fee_Average` INT UNSIGNED NULL AFTER `Price_Sale_Sqm_Average`;
ALTER TABLE `classified_user` ADD `Price_Rent_Average` INT UNSIGNED NULL AFTER `Common_Fee_Average`;
ALTER TABLE `classified_user` ADD `Price_Rent_Sqm_Average` INT UNSIGNED NULL AFTER `Price_Rent_Average`;
ALTER TABLE `classified_user` ADD `Rental_Contract` INT UNSIGNED NULL AFTER `Price_Rent_Sqm_Average`;
ALTER TABLE `classified_user` ADD `Description` text NULL AFTER `Rental_Contract`;
ALTER TABLE `classified_user` ADD `User_Cover` BOOLEAN NOT NULL DEFAULT FALSE AFTER `Registration_Date`;

ALTER TABLE `classified_user` ADD `Age_Count` INT UNSIGNED NULL AFTER `Condo_Age`;
ALTER TABLE `classified_user` ADD `Price_Sale_Count` INT UNSIGNED NULL AFTER `Price_Sale_Sqm_Average`;
ALTER TABLE `classified_user` ADD `Common_Fee_Count` INT UNSIGNED NULL AFTER `Common_Fee_Average`;
ALTER TABLE `classified_user` ADD `Price_Rent_Count` INT UNSIGNED NULL AFTER `Price_Rent_Sqm_Average`;

-- procedure updateClassified_User
DROP PROCEDURE IF EXISTS updateClassified_User;
DELIMITER //

CREATE PROCEDURE updateClassified_User ()
BEGIN
    DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachuser    VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name6     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name7     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name8     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name9     VARCHAR(250) DEFAULT NULL;
	DECLARE v_name10    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name11    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name12    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name13    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name14    VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name16    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name17    VARCHAR(250) DEFAULT NULL;
	DECLARE v_name18    VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'updateClassified_User';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DEClARE cur_user CURSOR FOR SELECT cu.User_ID
                                    , active.User_Count as Classified_Now
                                    , all_count.User_Count as Classified_All
                                    , condo_count.condo_count as Condo_Count
                                    , round(cal_age.condo_age,1) as Condo_Age
                                    , cal_age.Age_Count as Age_Count
                                    , condo_count.Room_Size as Room_Size
                                    , condo_count.Bedroom as Bedroom
                                    , condo_count.Price_Sale_Min as Price_Sale_Min
                                    , condo_count.Price_Rent_Min as Price_Rent_Min
                                    , price_sale.Price_Sale_Average as Price_Sale_Average
                                    , price_sale.Price_Sale_Sqm_Average as Price_Sale_Sqm_Average
                                    , count_sale.Price_Sale_Count as Price_Sale_Count
                                    , common_fee.Common_Fee_Average as Common_Fee_Average
                                    , common_fee.Common_Fee_Count as Common_Fee_Count
                                    , price_rent.Price_Rent_Average as Price_Rent_Average
                                    , price_rent.Price_Rent_Sqm_Average as Price_Rent_Sqm_Average
                                    , count_rent.Price_Rent_Count as Price_Rent_Count
                                    , price_rent.Rental_Contract as Rental_Contract
                                FROM classified_user cu
                                left join (select User_ID, count(*) as User_Count
                                            from classified
                                            where Classified_Status = '1'
                                            group by User_ID) active
                                on cu.User_ID = active.User_ID
                                left join (select User_ID, count(*) as User_Count
                                            from classified
                                            group by User_ID) all_count
                                on cu.User_ID = all_count.User_ID
                                left join (select User_ID
                                                , count(Condo_Code) as condo_count
                                                , concat(round(min(Size_Min)), '-', round(max(Size_Max))) as Room_Size
                                                , concat(min(Size_Bedroom_Min), '-', max(Size_Bedroom_Max)) as Bedroom
                                                , min(Price_Sale_Min) as Price_Sale_Min
                                                , min(Price_Rent_Min) as Price_Rent_Min
                                            from (select c.User_ID
                                                        , c.Condo_Code
                                                        , min(c.Size) as Size_Min
                                                        , max(c.Size) as Size_Max
                                                        , min(c.Bedroom) as Size_Bedroom_Min
                                                        , max(c.Bedroom) as Size_Bedroom_Max
                                                        , min(c.Bathroom) as Size_Bathroom_Min
                                                        , max(c.Bathroom) as Size_Bathroom_Max
                                                        , round(min(c.Price_Sale)/1000000,2) as Price_Sale_Min
                                                        , round(min(c.Price_Rent),-2) as Price_Rent_Min
                                                    from classified c
                                                    where c.Classified_Status = '1'
                                                    group by c.User_ID, c.Condo_Code) a
                                            group by User_ID) condo_count
                                on cu.User_ID = condo_count.User_ID
                                left join (select User_ID
                                                , round(sum(cal)/sum(Size),2) as Price_Sale_Average
                                                , round(SUM(cal2)/SUM(Size),-3) as Price_Sale_Sqm_Average
                                            from (Select Classified_ID
                                                        , Condo_Code
                                                        , Price_Sale
                                                        , Size
                                                        , User_ID
                                                        , (Price_Sale/1000000) * Size as cal
                                                        , (Price_Sale/Size)*Size as cal2
                                                    from classified
                                                    where Classified_Status = '1'
                                                    and Sale = 1) a
                                            group by User_ID) price_sale
                                on cu.User_ID = price_sale.User_ID
                                left join (select User_ID
                                                , round(sum(cal)/sum(Condo_TotalUnit)) as Common_Fee_Average
                                                , count(Condo_Code) as Common_Fee_Count
                                            from (SELECT c.User_ID
                                                        , c.Condo_Code 
                                                        , rcp.Condo_Common_Fee
                                                        , rc.Condo_TotalUnit
                                                        , rcp.Condo_Common_Fee * rc.Condo_TotalUnit as cal
                                                    FROM classified c
                                                    left join real_condo_price rcp on c.Condo_Code = rcp.Condo_Code
                                                    left join real_condo rc on rcp.Condo_Code = rc.Condo_Code
                                                    where c.Classified_Status = '1'
                                                    and rcp.Condo_Common_Fee is not null
                                                    and rcp.Condo_Common_Fee <> 0
                                                    and rc.Condo_TotalUnit is not null
                                                    and rc.Condo_TotalUnit <> 0
                                                    group by c.User_ID, c.Condo_Code, rcp.Condo_Common_Fee, rc.Condo_TotalUnit) a
                                            group by User_ID) common_fee
                                on cu.User_ID = common_fee.User_ID
                                left join (select User_ID
                                                , round(sum(cal)/sum(Size),-3) as Price_Rent_Average
                                                , round(SUM(cal2)/SUM(Size),-1) as Price_Rent_Sqm_Average
                                                , if(min(Min_Rental_Contract)=max(Min_Rental_Contract)
                                                    , min(Min_Rental_Contract)
                                                    , concat(min(Min_Rental_Contract),'-',max(Min_Rental_Contract))) as Rental_Contract
                                            from (Select Classified_ID
                                                        , Condo_Code
                                                        , Price_Rent
                                                        , Size
                                                        , User_ID
                                                        , Price_Rent * Size as cal
                                                        , (Price_Rent/Size)*Size as cal2
                                                        , Min_Rental_Contract
                                                    from classified
                                                    where Classified_Status = '1'
                                                    and Rent = 1) a
                                            group by User_ID) price_rent
                                on cu.User_ID = price_rent.User_ID
                                left join (select User_ID
                                                , count(Condo_Code) as Age_Count
                                                , sum(age)/count(Condo_Code) as condo_age
                                            from (SELECT c.User_ID
                                                    , c.Condo_Code
                                                    , year(curdate()) - year(acpc.Condo_Date_Calculate) as age
                                                FROM `classified` c
                                                left join all_condo_price_calculate acpc on c.Condo_Code = acpc.Condo_Code
                                                where c.Classified_Status = '1'
                                                and acpc.Condo_Date_Calculate is not null
                                                group by c.User_ID, c.Condo_Code, acpc.Condo_Date_Calculate) avg_age
                                            group by User_ID) cal_age
                                on cu.User_ID = cal_age.User_ID
                                left join (select User_ID, count(Condo_Code) as Price_Sale_Count
                                            from (Select Condo_Code
                                                        , User_ID
                                                    from classified
                                                    where Classified_Status = '1'
                                                    and Sale = 1
                                                    group by Condo_Code, User_ID) cs
                                            group by User_ID) count_sale
                                on cu.User_ID = count_sale.User_ID
                                left join (select User_ID, count(Condo_Code) as Price_Rent_Count
                                            from (Select Condo_Code
                                                        , User_ID
                                                    from classified
                                                    where Classified_Status = '1'
                                                    and Rent = 1
                                                    group by Condo_Code, User_ID) cr
                                            group by User_ID) count_rent
                                on cu.User_ID = count_rent.User_ID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;    

    OPEN cur_user;

	updateUser: LOOP
		FETCH cur_user INTO eachuser,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18;
		IF finished = 1 THEN 
			LEAVE updateUser;
		END IF;

        update classified_user
        set Classified_Now = v_name1,
            Classified_All = v_name2,
            Condo_Count = v_name3,
            Condo_Age = v_name4,
            Age_Count = v_name5,
            Room_Size = v_name6,
            Bedroom = v_name7,
            Price_Sale_Min = v_name8,
            Price_Rent_Min = v_name9,
            Price_Sale_Average = v_name10,
            Price_Sale_Sqm_Average = v_name11,
            Price_Sale_Count = v_name12,
            Common_Fee_Average = v_name13,
            Common_Fee_Count = v_name14,
            Price_Rent_Average = v_name15,
            Price_Rent_Sqm_Average = v_name16,
            Price_Rent_Count = v_name17,
            Rental_Contract = v_name18
        where User_ID = eachuser;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateUser;

    if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE cur_user;

END //
DELIMITER ;