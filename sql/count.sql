-- updateCondoCountSegment
-- updateCondoCountProvince
-- updateCondoCountDeveloper
-- updateCondoCountBrand
-- updateCondoCountLine
-- updateCondoCountStation
-- updateCondoCountYarnMain
-- updateCondoCountYarnSub
-- updateCondoCountDistrict
-- updateCondoCountSubDistrict_1
-- updateCondoCountSubDistrict_2
-- updateCondoCountSubDistrict_3
-- updateCondoCountSubDistrict_4

-- updateCondoCountSegment
DROP PROCEDURE IF EXISTS updateCondoCountSegment;
DELIMITER //

CREATE PROCEDURE updateCondoCountSegment ()
BEGIN
    DECLARE finished    INTEGER     DEFAULT 0;
    DECLARE eachSegment VARCHAR(20) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountSegment';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN     DEFAULT 1;

    DECLARE curSegment CURSOR FOR 
        SELECT Segment_Code FROM real_condo_segment;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        SET errorcheck = 0;
    END;

    OPEN curSegment;

    updateCondoCount: LOOP
        FETCH curSegment INTO eachSegment;
        IF finished = 1 THEN 
            LEAVE updateCondoCount;
        END IF;

        UPDATE  real_condo_segment
        SET     Condo_Count = ( SELECT  COUNT(RCP.Condo_Code) 
                                FROM    real_condo_price RCP
                                ,       condo_fetch_for_map CFRM
                                WHERE   RCP.Condo_Code = CFRM.Condo_Code
                                AND     RCP.Condo_Segment = eachSegment)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo_price rcp on c.Condo_Code = rcp.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rcp.Condo_Segment = eachSegment)
        WHERE   Segment_Code = eachSegment;

        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

    END LOOP updateCondoCount;

    IF errorcheck THEN
        SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    END IF;

    CLOSE curSegment;

END //
DELIMITER ;

-- updateCondoCountProvince
DROP PROCEDURE IF EXISTS updateCondoCountProvince;
DELIMITER //

CREATE PROCEDURE updateCondoCountProvince ()
BEGIN
    DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachProvince VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountProvince';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curProvince
		CURSOR FOR 
			SELECT province_code FROM thailand_province;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;

    OPEN curProvince;

	updateCondoCount: LOOP
		FETCH curProvince INTO eachProvince;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_province
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.Province_ID = eachProvince)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.Province_ID = eachProvince)
        WHERE   province_code = eachProvince;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curProvince;
END //
DELIMITER ;

-- updateCondoCountDeveloper
DROP PROCEDURE IF EXISTS updateCondoCountDeveloper;
DELIMITER //

CREATE PROCEDURE updateCondoCountDeveloper ()
BEGIN
    DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachDeveloper VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountDeveloper';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curDeveloper
		CURSOR FOR 
			SELECT Developer_Code FROM condo_developer;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curDeveloper;

	updateCondoCount: LOOP
		FETCH curDeveloper INTO eachDeveloper;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  condo_developer
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.Developer_Code = eachDeveloper)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.Developer_Code = eachDeveloper)
        WHERE   Developer_Code = eachDeveloper;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curDeveloper;

END //
DELIMITER ;

-- updateCondoCountBrand
DROP PROCEDURE IF EXISTS updateCondoCountBrand;
DELIMITER //

CREATE PROCEDURE updateCondoCountBrand ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachBrand VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountBrand';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curBrand
		CURSOR FOR 
			SELECT Brand_Code FROM brand;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curBrand;

	updateCondoCount: LOOP
		FETCH curBrand INTO eachBrand;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  brand
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.Brand_Code = eachBrand)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.Brand_Code = eachBrand)
        WHERE   Brand_Code = eachBrand;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curBrand;

END//
DELIMITER ;

-- updateCondoCountLine
DROP PROCEDURE IF EXISTS updateCondoCountLine;
DELIMITER //

CREATE PROCEDURE updateCondoCountLine ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachLine VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountLine';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curLine 
		CURSOR FOR 
			SELECT Line_Code FROM mass_transit_line;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;

    OPEN curLine;

	updateCondoCount: LOOP
		FETCH curLine INTO eachLine;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  mass_transit_line
        SET	    Condo_Count = ( SELECT  COUNT(DISTINCT(CAS.Condo_Code)) 
                                FROM    condo_around_station CAS
                                , 	    condo_fetch_for_map CFRM
                                WHERE   CAS.Condo_Code      = CFRM.Condo_Code
                                AND     CAS.Line_Code    = eachLine)
            , Classified_Unit_Count = (SELECT COUNT(DISTINCT c.Classified_ID)
                                        FROM classified c
                                        INNER JOIN condo_around_station cas ON c.Condo_Code = cas.Condo_Code
                                        WHERE c.Classified_Status = '1'
                                        and cas.Line_Code = eachLine)
        WHERE   Line_Code = eachLine;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curLine;

END //
DELIMITER ;

-- updateCondoCountStation
DROP PROCEDURE IF EXISTS updateCondoCountStation;
DELIMITER //

CREATE PROCEDURE updateCondoCountStation ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachStation VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountStation';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curStation 
		CURSOR FOR 
			SELECT Station_Code FROM mass_transit_station;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;	

    OPEN curStation;

	updateCondoCount: LOOP
		FETCH curStation INTO eachStation;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  mass_transit_station
        SET	    Condo_Count = ( SELECT  COUNT(DISTINCT(CAS.Condo_Code))
                                FROM    condo_around_station CAS
                                , 	    condo_fetch_for_map CFRM
                                WHERE   CAS.Condo_Code      = CFRM.Condo_Code
                                AND     CAS.Station_Code    = eachStation)
            , Classified_Unit_Count = (SELECT COUNT(DISTINCT c.Classified_ID)
                                        FROM classified c
                                        INNER JOIN condo_around_station cas ON c.Condo_Code = cas.Condo_Code
                                        WHERE c.Classified_Status = '1'
                                        and cas.Station_Code = eachStation)
        WHERE   Station_Code = eachStation;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curStation;

END //
DELIMITER ;

-- updateCondoCountYarnMain
DROP PROCEDURE IF EXISTS updateCondoCountYarnMain;
DELIMITER //

CREATE PROCEDURE updateCondoCountYarnMain ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachYarnMain VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountYarnMain';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curYarnMain
		CURSOR FOR 
			SELECT District_Code FROM real_yarn_main;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curYarnMain;

	updateCondoCount: LOOP
		FETCH curYarnMain INTO eachYarnMain;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  real_yarn_main
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.RealDistrict_Code = eachYarnMain)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.RealDistrict_Code = eachYarnMain)
        WHERE   District_Code = eachYarnMain;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curYarnMain;

END //
DELIMITER ;

-- updateCondoCountYarnSub
DROP PROCEDURE IF EXISTS updateCondoCountYarnSub;
DELIMITER //

CREATE PROCEDURE updateCondoCountYarnSub ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachYarnSub VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountYarnSub';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curYarnSub
		CURSOR FOR 
			SELECT SubDistrict_Code FROM real_yarn_sub;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curYarnSub;

	updateCondoCount: LOOP
		FETCH curYarnSub INTO eachYarnSub;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  real_yarn_sub
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.RealSubDistrict_Code = eachYarnSub)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.RealSubDistrict_Code = eachYarnSub)
        WHERE   SubDistrict_Code = eachYarnSub;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curYarnSub;

END //
DELIMITER ;

-- updateCondoCountDistrict
DROP PROCEDURE IF EXISTS updateCondoCountDistrict;
DELIMITER //

CREATE PROCEDURE updateCondoCountDistrict ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachDistrict VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountDistrict';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curDistrict
		CURSOR FOR 
			SELECT district_code FROM thailand_district;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;

    OPEN curDistrict;

	updateCondoCount: LOOP
		FETCH curDistrict INTO eachDistrict;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_district
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.District_ID = eachDistrict)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.District_ID = eachDistrict)
        WHERE   district_code = eachDistrict;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curDistrict;

END //
DELIMITER ;

-- updateCondoCountSubDistrict_1
DROP PROCEDURE IF EXISTS updateCondoCountSubDistrict_1;
DELIMITER //

CREATE PROCEDURE updateCondoCountSubDistrict_1 ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachSubDistrict VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountSubDistrict_1';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curSubDistrict
		CURSOR FOR 
			SELECT subdistrict_code FROM thailand_subdistrict
			WHERE id < 2000;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curSubDistrict;

	updateCondoCount: LOOP
		FETCH curSubDistrict INTO eachSubDistrict;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_subdistrict
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.SubDistrict_ID = eachSubDistrict)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.SubDistrict_ID = eachSubDistrict)
        WHERE   subdistrict_code = eachSubDistrict;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curSubDistrict;

END //
DELIMITER ;

-- updateCondoCountSubDistrict_2
DROP PROCEDURE IF EXISTS updateCondoCountSubDistrict_2;
DELIMITER //

CREATE PROCEDURE updateCondoCountSubDistrict_2 ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachSubDistrict VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountSubDistrict_2';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curSubDistrict
		CURSOR FOR 
			SELECT subdistrict_code FROM thailand_subdistrict
			WHERE id >= 2000 AND id < 4000;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curSubDistrict;

	updateCondoCount: LOOP
		FETCH curSubDistrict INTO eachSubDistrict;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_subdistrict
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.SubDistrict_ID = eachSubDistrict)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.SubDistrict_ID = eachSubDistrict)
        WHERE   subdistrict_code = eachSubDistrict;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curSubDistrict;

END //
DELIMITER ;

-- updateCondoCountSubDistrict_3
DROP PROCEDURE IF EXISTS updateCondoCountSubDistrict_3;
DELIMITER //

CREATE PROCEDURE updateCondoCountSubDistrict_3 ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachSubDistrict VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountSubDistrict_3';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curSubDistrict
		CURSOR FOR 
			SELECT subdistrict_code FROM thailand_subdistrict
			WHERE id >= 4000 AND id < 6000;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curSubDistrict;

	updateCondoCount: LOOP
		FETCH curSubDistrict INTO eachSubDistrict;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_subdistrict
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.SubDistrict_ID = eachSubDistrict)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.SubDistrict_ID = eachSubDistrict)
        WHERE   subdistrict_code = eachSubDistrict;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curSubDistrict;

END //
DELIMITER ;

-- updateCondoCountSubDistrict_4
DROP PROCEDURE IF EXISTS updateCondoCountSubDistrict_4;
DELIMITER //

CREATE PROCEDURE updateCondoCountSubDistrict_4 ()
BEGIN
	DECLARE finished    INTEGER     DEFAULT 0;
	DECLARE eachSubDistrict VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountSubDistrict_4';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curSubDistrict
		CURSOR FOR 
			SELECT subdistrict_code FROM thailand_subdistrict
			WHERE id >= 6000;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curSubDistrict;

	updateCondoCount: LOOP
		FETCH curSubDistrict INTO eachSubDistrict;
		IF finished = 1 THEN 
			LEAVE updateCondoCount;
		END IF;

        UPDATE  thailand_subdistrict
        SET	    Condo_Count = ( SELECT  COUNT(CFRM.Condo_Code) 
                                FROM    condo_fetch_for_map CFRM
								WHERE   CFRM.SubDistrict_ID = eachSubDistrict)
            , Classified_Unit_Count = (SELECT count(c.Classified_ID)
                                        FROM classified c
                                        inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                                        where c.Classified_Status = '1'
                                        and rc.SubDistrict_ID = eachSubDistrict)
        WHERE   subdistrict_code = eachSubDistrict;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoCount;

	if errorcheck then
		SET code    = '00000';
        SET msg     = CONCAT(rowCount,' rows changed.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curSubDistrict;

END //
DELIMITER ;