-- retail point
DROP PROCEDURE IF EXISTS update_RetailPoint;
DELIMITER $$

CREATE PROCEDURE update_RetailPoint ()
BEGIN
    DECLARE finished  INTEGER     DEFAULT 0;
	DECLARE eachplace  VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_RetailPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    -- declare cursor 
	DEClARE curplace
		CURSOR FOR 
			SELECT Place_ID FROM real_place_retail;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

    -- declare SQLEXCEPTION handler	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
            set errorcheck = 0;
        END;    

    OPEN curplace;

	updateRetail_Point: LOOP
		FETCH curplace INTO eachplace;
		IF finished = 1 THEN 
			LEAVE updateRetail_Point;
		END IF;

        UPDATE  real_place_retail
        SET     Place_Category_Cal_Point         = (1*Place_Category_Point+0)*30,
                Place_Boundary_Area_Point        = ROUND(GREATEST(LEAST((0.000119047619*Place_Boundary_Area+4.047619048)*40,400),200),1),
                Place_Distance_From_Center_Point = ROUND(GREATEST(LEAST((-0.33*Place_Distance_From_Center+10)*20,200),100),1)
        WHERE   Place_ID = eachplace;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateRetail_Point;

    if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curplace;

END$$
DELIMITER ;


-- hospital point
DROP PROCEDURE IF EXISTS update_HospitalPoint;
DELIMITER $$

CREATE PROCEDURE update_HospitalPoint ()
BEGIN
    DECLARE finished  INTEGER     DEFAULT 0;
	DECLARE eachplace  VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_HospitalPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    -- declare cursor 
	DEClARE curplace
		CURSOR FOR 
			SELECT Place_ID FROM real_place_hospital;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

    -- declare SQLEXCEPTION handler	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
            set errorcheck = 0;
        END;    

    OPEN curplace;

	updateHospital_Point: LOOP
		FETCH curplace INTO eachplace;
		IF finished = 1 THEN 
			LEAVE updateHospital_Point;
		END IF;

        UPDATE  real_place_hospital
        SET     Place_Point_Cal         = (2*Place_Point+0)*50,
                Place_Point_Bed         = ROUND(GREATEST(LEAST((0.01*Place_Bed+4)*20,200),100),1),
                Place_Point_Center      = ROUND(GREATEST(LEAST((-0.33*Place_Distance_From_Center+10)*20,200),100),1)
        WHERE   Place_ID = eachplace;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateHospital_Point;

    if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curplace;

END$$
DELIMITER ;


-- education point
DROP PROCEDURE IF EXISTS update_EducationPoint;
DELIMITER $$

CREATE PROCEDURE update_EducationPoint ()
BEGIN
    DECLARE finished  INTEGER     DEFAULT 0;
	DECLARE eachplace  VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_EducationPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    -- declare cursor 
	DEClARE curplace
		CURSOR FOR 
			SELECT Place_ID FROM real_place_education;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

    -- declare SQLEXCEPTION handler	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
            set errorcheck = 0;
        END;    

    OPEN curplace;

	updateEducation_Point: LOOP
		FETCH curplace INTO eachplace;
		IF finished = 1 THEN 
			LEAVE updateEducation_Point;
		END IF;

        UPDATE  real_place_education
        SET     Place_Point_Cal         = (1*Place_Point+5)*20,
                Place_Point_Weight      = ROUND(GREATEST(LEAST((0.0003623188406*Place_Student_Weight+4.202898551)*50,500),250),1),
                Place_Point_Center      = ROUND(GREATEST(LEAST((-0.33*Place_Distance_From_Center+10)*20,200),100),1)
        WHERE   Place_ID = eachplace;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateEducation_Point;

    if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curplace;

END$$
DELIMITER ;


-- port point
DROP PROCEDURE IF EXISTS update_PortPoint;
DELIMITER $$

CREATE PROCEDURE update_PortPoint ()
BEGIN
    DECLARE finished  INTEGER     DEFAULT 0;
	DECLARE eachplace  VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_PortPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    -- declare cursor 
	DEClARE curplace
		CURSOR FOR 
			SELECT Place_ID FROM real_place_port;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

    -- declare SQLEXCEPTION handler	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
            set errorcheck = 0;
        END;    

    OPEN curplace;

	updatePort_Point: LOOP
		FETCH curplace INTO eachplace;
		IF finished = 1 THEN 
			LEAVE updatePort_Point;
		END IF;

        UPDATE  real_place_port
        SET     Place_Point_Center     =  ROUND(GREATEST(LEAST((-0.33*Place_Distance_From_Center+10)*70,700),350),1)
        WHERE   Place_ID = eachplace;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updatePort_Point;

    if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curplace;

END$$
DELIMITER ;


-- port point
DROP PROCEDURE IF EXISTS update_ExpresswayPoint;
DELIMITER $$

CREATE PROCEDURE update_ExpresswayPoint ()
BEGIN
    DECLARE finished  INTEGER     DEFAULT 0;
	DECLARE eachplace  VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'update_ExpresswayPoint';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    -- declare cursor 
	DEClARE curplace
		CURSOR FOR 
			SELECT Place_ID FROM real_place_express_way;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

    -- declare SQLEXCEPTION handler	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
            set errorcheck = 0;
        END;    

    OPEN curplace;

	updateExpressway_Point: LOOP
		FETCH curplace INTO eachplace;
		IF finished = 1 THEN 
			LEAVE updateExpressway_Point;
		END IF;

        UPDATE  real_place_express_way
        SET     Place_Point_Center     =  ROUND(GREATEST(LEAST((-0.33*Place_Distance_From_Center+10)*20,200),100),1)
        WHERE   Place_ID = eachplace;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateExpressway_Point;

    if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curplace;

END$$
DELIMITER ;

-- update place point
DROP PROCEDURE IF EXISTS updatePlacePoint;
DELIMITER $$

CREATE PROCEDURE updatePlacePoint ()
BEGIN
	CALL update_RetailPoint ();
    CALL update_HospitalPoint ();
    CALL update_EducationPoint ();
    CALL update_PortPoint ();
    CALL update_ExpresswayPoint ();
END$$
DELIMITER ;