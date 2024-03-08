DROP PROCEDURE IF EXISTS updateCondoSegment;
DELIMITER $$
CREATE PROCEDURE updateCondoSegment ()
BEGIN
	DECLARE finished    INTEGER   DEFAULT 0;
	DECLARE eachCondo VARCHAR(20) DEFAULT NULL;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoSegment';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DEClARE curCondo 
		CURSOR FOR 
			SELECT Condo_Code FROM real_condo_price;

		DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;
	
    OPEN curCondo;

	updateCondoSegment: LOOP
		FETCH curCondo INTO eachCondo;
		IF finished = 1 THEN 
			LEAVE updateCondoSegment;
		END IF;

        UPDATE  real_condo_price
        SET	    Condo_Segment = ( SELECT (CASE WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 0 AND ROUND(Condo_Price_Per_Square_Sort,-3) <= 50000 THEN 'SEG01'
                            			WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 50000 AND ROUND(Condo_Price_Per_Square_Sort,-3) <= 80000 THEN 'SEG02'
                            			WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 80000 AND ROUND(Condo_Price_Per_Square_Sort,-3) <= 150000 THEN 'SEG03'
                            			WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 150000 AND ROUND(Condo_Price_Per_Square_Sort,-3) <= 250000 THEN 'SEG04'
                						WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 250000 AND ROUND(Condo_Price_Per_Square_Sort,-3) <= 300000 THEN 'SEG05'
                            			WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 300000 AND ROUND(Condo_Price_Per_Square_Sort,-3) <= 350000 THEN 'SEG06'
                            			WHEN ROUND(Condo_Price_Per_Square_Sort,-3) > 350000 THEN 'SEG07'
                            			ELSE NULL
                            			END)
                                	FROM   condo_price_calculate_view
                                	WHERE  Condo_Code = eachCondo)
        WHERE Condo_Code = eachCondo;

		GET DIAGNOSTICS nrows = ROW_COUNT;
        SET rowCount = rowCount + nrows;

	END LOOP updateCondoSegment;

	if errorcheck then
		SET code    = '00000';
    	SET msg     = CONCAT(rowCount,' rows changed.');
    	INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;
	
    CLOSE curCondo;

END$$
DELIMITER ;