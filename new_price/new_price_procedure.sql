-- truncateInsert_classified_price
-- truncateInsert_all_price_view
-- truncateInsert_condo_price_calculate_view
-- truncateInsert_real_condo_rental

-- truncateInsert_classified_price
DROP PROCEDURE IF EXISTS truncateInsert_classified_price;
DELIMITER //

CREATE PROCEDURE truncateInsert_classified_price ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_classified_price';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Data_Date, Data_Attribute, Data_Value
                            FROM source_classified_price;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE classified_price;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            classified_price(
                `Condo_Code`,
                `Data_Date`,
                `Data_Attribute`,
                `Data_Value`
                )
        VALUES(v_name,v_name1,v_name2,v_name3);
        
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

-- truncateInsert_all_price_view
DROP PROCEDURE IF EXISTS truncateInsert_all_price_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_all_price_view ()
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

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_all_price_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Resale, Price_Source
                                , Price_Type, Special, Remark
                            FROM source_all_price_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name1,' - ',v_name6);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE all_price_view;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            all_price_view(
                `Condo_Code`,
                `Price`,
                `Price_Date`,
                `Condo_Build_Date`,
                `Start_or_AVG`,
                `Resale`,
                `Price_Source`,
                `Price_Type`,
                `Special`,
                `Remark`
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


-- truncateInsert_all_condo_price_calculate_view
DROP PROCEDURE IF EXISTS truncateInsert_all_condo_price_calculate_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_all_condo_price_calculate_view ()
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

	DECLARE proc_name       VARCHAR(60) DEFAULT 'truncateInsert_all_condo_price_calculate_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Old_or_New, Condo_Age_Status_Square_Text, Condo_Price_Per_Square
                                , Condo_Price_Per_Square_Date, Source_Condo_Price_Per_Square, Full_Source_Condo_Price_Per_Square, Condo_Price_Per_Unit_Text
                                , Condo_Price_Per_Unit, Condo_Price_Per_Unit_Date, Source_Condo_Price_Per_Unit, Full_Source_Condo_Price_Per_Unit
                                , Condo_Sold_Status_Show_Value, Source_Condo_Sold_Status_Show_Value, Full_Source_Condo_Sold_Status_Show_Value
                                , Condo_Sold_Status_Date, Condo_Built_Text, Condo_Built_Date, Condo_Date_Calculate, Condo_Price_Per_Square_Cal
                                , Condo_Price_Per_Unit_Cal, Condo_Price_Per_Square_Sort, Condo_Price_Per_Unit_Sort
                                FROM source_all_condo_price_calculate_view;
	
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE all_condo_price_calculate;
	
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			all_condo_price_calculate (
				Condo_Code,
				Old_or_New,
				Condo_Age_Status_Square_Text,
				Condo_Price_Per_Square,
				Condo_Price_Per_Square_Date,
                Source_Condo_Price_Per_Square,
                Full_Source_Condo_Price_Per_Square,
				Condo_Price_Per_Unit_Text,
				Condo_Price_Per_Unit,
				Condo_Price_Per_Unit_Date,
                Source_Condo_Price_Per_Unit,
                Full_Source_Condo_Price_Per_Unit,
				Condo_Sold_Status_Show_Value,
                Source_Condo_Sold_Status_Show_Value,
                Full_Source_Condo_Sold_Status_Show_Value,
				Condo_Sold_Status_Date,
				Condo_Built_Text,
				Condo_Built_Date,
				Condo_Date_Calculate,
				Condo_Price_Per_Square_Cal,
				Condo_Price_Per_Unit_Cal,
                Condo_Price_Per_Square_Sort,
				Condo_Price_Per_Unit_Sort
			)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22);
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

-- truncateInsert_real_condo_rental
DROP PROCEDURE IF EXISTS truncateInsert_real_condo_rental;
DELIMITER //

CREATE PROCEDURE truncateInsert_real_condo_rental ()
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

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_real_condo_rental';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code, Rent_Per_Unit_Date, Rent_Per_Unit, Rental_Yield_Percent_Date
                                , Rental_Yield_Percent, Rent_Per_Unit_Sqm_Date, Rent_Per_Unit_Sqm
                                FROM source_real_condo_rental_view;
	
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE real_condo_rental;
	
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			real_condo_rental (
				Condo_Code,
				Rent_Per_Unit_Date,
				Rent_Per_Unit,
				Rental_Yield_Percent_Date,
				Rental_Yield_Percent,
				Rent_Per_Unit_Sqm_Date,
				Rent_Per_Unit_Sqm
			)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6);
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