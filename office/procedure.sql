-- procedure truncateInsert_office_around_station
DROP PROCEDURE IF EXISTS truncateInsert_office_around_station;
DELIMITER //

CREATE PROCEDURE truncateInsert_office_around_station ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(250) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_office_around_station';
	DECLARE code            VARCHAR(10) DEFAULT '00000';
	DECLARE msg             TEXT;
	DECLARE rowCount        INTEGER     DEFAULT 0;
	DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Station_Code, Station_THName_Display, Route_Code, Line_Code, Project_ID, Distance
                            FROM source_office_around_station;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name,' - ',v_name4);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE    office_around_station;
	
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

		INSERT INTO
			office_around_station(
				Station_Code
                , Station_THName_Display
                , Route_Code
                , Line_Code
                , Project_ID
                , Distance
				)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5);
        
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