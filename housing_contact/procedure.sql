-- proc housing_contact_dev_agent_detail
DROP PROCEDURE IF EXISTS truncateInsert_housing_contact_dev_agent_detail;
DELIMITER //

CREATE PROCEDURE truncateInsert_housing_contact_dev_agent_detail ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 text DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_housing_contact_dev_agent_detail';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Housing_Code, Housing_Sold_Out, Dev_or_Agent, Dev_Agent_Contact_ID, Company_Name, Contact_Name, Email
                            FROM source_housing_contact_dev_agent_detail;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name, ' -- ',v_name3);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE housing_contact_dev_agent_detail;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6;

        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            housing_contact_dev_agent_detail(
                `Housing_Code`,
                `Housing_Sold_Out`,
                `Dev_or_Agent`,
                `Dev_Agent_Contact_ID`,
                `Company_Name`,
                `Contact_Name`,
                `Email`
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