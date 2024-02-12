/*  -- Table
        -- ads_base_2
        -- ads_cal_slot_2
        -- ads_cal_slot_show
        -- ads_cal_today_2
    -- Procedure
        -- ads_updateday_2
        -- ads_cal_today_2
        -- ads_calads_2
        -- ads_show_slot
        -- ads_CALADSS_2 */

-- Table ads_base_2
CREATE TABLE `ads_base_2` (
    `AD_ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `AD_Code` varchar(10) NULL,
    `Prop_Type` ENUM('CD','HP','NR','EV') NULL,
    `Prop_Code` varchar(10) NULL,
    `Published_date` timestamp NOT NULL,
    `Auto_AD_Budget` int UNSIGNED NULL,
    `Manual_AD_Day` int UNSIGNED NULL,
    `Size` ENUM('Banner','Billboard') NULL,
    `AD_Type` ENUM('Auto','Manual') NOT NULL DEFAULT 'Auto',
    `Show_Days` int UNSIGNED NOT NULL DEFAULT 0,
    `Left_Days` int UNSIGNED NOT NULL,
    `AD_Rank` int DEFAULT NULL,
    `Project_Name_Manual_Billboard` VARCHAR(250) NULL,
    `Developer_Manual_Billboard` VARCHAR(200) NULL,
    `Description_Manual_Billboard` TEXT NULL,
    `Manual_Desktop_Image` TEXT DEFAULT NULL,
    `Manual_Mobile_Image` TEXT DEFAULT NULL,
    `Link` TEXT DEFAULT NULL,
    `AD_Status` ENUM('0','1','2') NOT NULL DEFAULT '0',
    `Create_Date` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `Create_User` smallint unsigned NOT NULL default 0,
    `Last_Update_Date` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `Last_Update_User` smallint unsigned NOT NULL default 0,
    PRIMARY KEY (`AD_ID`),
    INDEX base2_admin1 (Create_User),
    INDEX base2_admin2 (Last_Update_User),
    CONSTRAINT base2_admin1 FOREIGN KEY (Create_User) REFERENCES user_admin(User_ID),
    CONSTRAINT base2_admin2 FOREIGN KEY (Last_Update_User) REFERENCES user_admin(User_ID)
) ENGINE = InnoDB;

-- Table ads_cal_slot_2
CREATE TABLE `ads_cal_slot_2` (
    `slot` int NOT NULL,
    `ad_code` varchar(10) NOT NULL,
    `prop_code` varchar(10) NULL,
    `temp_rank` int NOT NULL,
    PRIMARY KEY (`slot`)
) ENGINE=InnoDB;

-- Table ads_cal_slot_show
CREATE TABLE `ads_cal_slot_show` (
    `AD_Code` varchar(10) NOT NULL,
    `Prop_Code` varchar(10) NULL,
    `Project_Name` varchar(150) NULL,
    `Day_1` int NULL,
    `Day_2` int NULL,
    `Day_3` int NULL,
    `Day_4` int NULL,
    `Day_5` int NULL,
    `Day_6` int NULL,
    `Day_7` int NULL,
    `Day_8` int NULL,
    `Day_9` int NULL,
    `Day_10` int NULL,
    `Day_11` int NULL,
    `Day_12` int NULL,
    `Day_13` int NULL,
    `Day_14` int NULL,
    `Day_15` int NULL,
    `Day_16` int NULL,
    `Day_17` int NULL,
    `Day_18` int NULL,
    `Day_19` int NULL,
    `Day_20` int NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID)
) ENGINE=InnoDB;

-- Table ads_cal_today_2
CREATE TABLE `ads_cal_today_2` (
    `AD_ID` varchar(10) NOT NULL,
    `AD_Code` varchar(10) NULL,
    `Prop_Type` ENUM('CD','HP','NR','EV','DF') NULL,
    `Prop_Code` varchar(10) NULL,
    `Published_date` timestamp NOT NULL,
    `Auto_AD_Budget` int UNSIGNED NULL,
    `Manual_AD_Day` int UNSIGNED NULL,
    `Size` enum('Banner','Billboard') NULL,
    `AD_Type` enum('Auto','Manual','Default') NOT NULL,
    `Show_Days` int UNSIGNED NOT NULL,
    `Left_Days` int UNSIGNED NOT NULL,
    `AD_Rank` int NULL,
    `Manual_Desktop_Image` TEXT DEFAULT NULL,
    `Manual_Mobile_Image` TEXT DEFAULT NULL,
    `Link` TEXT DEFAULT NULL,
    `AD_Status` ENUM('0','1','2') NOT NULL,
    `temp_rank` int NOT NULL,
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (ID)
) ENGINE=InnoDB;

-- ads_updateday_2
DROP PROCEDURE IF EXISTS ads_updateday_2;
DELIMITER //
CREATE PROCEDURE ads_updateday_2 (OUT success BOOLEAN)
BEGIN
    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_updateday_2';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    set success = FALSE;

    UPDATE ads_base_2
    SET Show_Days = IF(AD_Rank <= ads_max_ban() + ads_max_bill(), Show_Days + 1, Show_Days),
        Left_Days = IF(AD_Rank <= ads_max_ban() + ads_max_bill(), Left_Days - 1, Left_Days),
        Last_Update_Date = IF(AD_Rank <= ads_max_ban() + ads_max_bill(),CURRENT_TIMESTAMP,Last_Update_Date);

    set success = TRUE;

END //
DELIMITER ;

-- insert ads_cal_today_2
DROP PROCEDURE IF EXISTS ads_update_adds_2;
DELIMITER //
CREATE PROCEDURE ads_update_adds_2 (IN days_to_add INT, OUT success BOOLEAN)
BEGIN
    DECLARE each_id             VARCHAR(250) DEFAULT NULL;
    DECLARE each_adcode         VARCHAR(250) DEFAULT NULL;
    DECLARE each_proptype       VARCHAR(250) DEFAULT NULL;
    DECLARE each_code           VARCHAR(250) DEFAULT NULL;
    DECLARE each_pubdate        TIMESTAMP DEFAULT NULL;
    DECLARE each_autobudget     INTEGER DEFAULT NULL;
    DECLARE each_manualday      INTEGER DEFAULT NULL;
    DECLARE each_size           VARCHAR(250) DEFAULT NULL;
    DECLARE each_adstype        VARCHAR(250) DEFAULT NULL;
    DECLARE each_showdays       INTEGER DEFAULT 0;
    DECLARE each_leftdays       INTEGER DEFAULT 0;
    DECLARE each_adrank         INTEGER DEFAULT 0;
    DECLARE each_desktopimage   TEXT DEFAULT NULL;
    DECLARE each_mobileimage    TEXT DEFAULT NULL;
    DECLARE each_link           TEXT DEFAULT NULL;
    DECLARE each_status         VARCHAR(10) DEFAULT '0';
    DECLARE each_temprank       INTEGER DEFAULT 0;
    DECLARE done                INTEGER DEFAULT FALSE;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_update_adds_2';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE cur_ADS CURSOR FOR 
        SELECT * FROM (
            SELECT AD_ID
                , AD_Code
                , Prop_Type
                , Prop_Code
                , Published_date
                , Auto_AD_Budget
                , Manual_AD_Day
                , Size
                , AD_Type
                , Show_Days
                , Left_Days
                , AD_Rank
                , Manual_Desktop_Image
                , Manual_Mobile_Image
                , Link
                , AD_Status
                , IF ( @r_bann < ads_max_ban() , @r_bann := @r_bann + 1, @r_bann := 200) as temp_rank
            FROM ads_base_2 a
            , (SELECT @r_bann := 0) as t
            WHERE Size = 'Banner'
            and Published_date <= CURDATE() + interval days_to_add day
            and Left_days > 0
            and AD_Status = '1'
            ORDER BY Published_date
        ) as bann
        UNION
        SELECT * FROM (
            SELECT AD_ID
                , AD_Code
                , Prop_Type
                , Prop_Code
                , Published_date
                , Auto_AD_Budget
                , Manual_AD_Day
                , Size
                , AD_Type
                , Show_Days
                , Left_Days
                , AD_Rank
                , Manual_Desktop_Image
                , Manual_Mobile_Image
                , Link
                , AD_Status
                , IF ( @r_bill < ads_max_ban() + ads_max_bill() , @r_bill := @r_bill + 1,@r_bill := 200) as temp_rank
            FROM ads_base_2 a
            , (SELECT @r_bill := ads_max_ban()) as t
            WHERE Size = 'Billboard'
            and Published_date <= CURDATE() + interval days_to_add day
            and Left_days > 0
            and AD_Status = '1'
            ORDER BY Published_date
        ) as bill
        UNION
        select * from (SELECT AD_ID, AD_Code, Prop_Type, Prop_Code, Published_date, Auto_AD_Budget, Manual_AD_Day, Size, AD_Type, Show_Days, Left_Days, AD_Rank, Manual_Desktop_Image, Manual_Mobile_Image, Link, AD_Status, 100 as temp_rank 
                        FROM ads_base_2
                        WHERE AD_Type = 'Auto' 
                        and Published_date <= CURDATE() + interval days_to_add day
                        and Left_days > 0 
                        and AD_Status = '1'
                        order by Published_date) as auto
        UNION
        select * from (SELECT AD_ID,AD_ID as AD_Code,Prop_Type,AD_ID as Prop_Code, CURDATE() + interval days_to_add day as Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days,Left_Days,AD_Rank,Desktop_Billboard_Image,Mobile_Billboard_Image,Link,AD_Status,150 as temp_rank 
                        FROM ads_default 
                        where AD_Status = '1'
                        order by rand()) as def;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT_WS(' ',msg,'AT',each_adcode,each_code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    set success = FALSE;

    TRUNCATE TABLE ads_cal_today_2;
    
    OPEN cur_ADS;
    read_loop: LOOP
        FETCH cur_ADS INTO each_id,each_adcode,each_proptype,each_code,each_pubdate,each_autobudget,each_manualday,each_size,each_adstype,each_showdays,each_leftdays,each_adrank,each_desktopimage,each_mobileimage,each_link,each_status,each_temprank;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO
            ads_cal_today_2(
                `AD_ID`,
                `AD_Code`,
                `Prop_Type`,
                `Prop_Code`,
                `Published_date`,
                `Auto_AD_Budget`,
                `Manual_AD_Day`,
                `Size`,
                `AD_Type`,
                `Show_Days`,
                `Left_Days`,
                `AD_Rank`,
                `Manual_Desktop_Image`,
                `Manual_Mobile_Image`,
                `Link`,
                `AD_Status`,
                `temp_rank`
                )
        VALUES(each_id,each_adcode,each_proptype,each_code,each_pubdate,each_autobudget,each_manualday,each_size,each_adstype,each_showdays,each_leftdays,each_adrank,each_desktopimage,each_mobileimage,each_link,each_status,each_temprank);
    END LOOP;

    set success = TRUE;

    CLOSE cur_ADS;
END //
DELIMITER ;

-- ads_calads_2
DROP PROCEDURE IF EXISTS ads_calads_2;
DELIMITER //
CREATE PROCEDURE ads_calads_2 (OUT success BOOLEAN)
BEGIN
	DECLARE totalRows	INTEGER		DEFAULT 0;
	DECLARE counter		INTEGER     DEFAULT 1;
	DECLARE code_found	VARCHAR(250)		DEFAULT NULL;
    DECLARE propcode_found	VARCHAR(250)		DEFAULT NULL;
    DECLARE each_rank	INTEGER		DEFAULT 0;
    DECLARE each_adcode         VARCHAR(250) DEFAULT NULL;
    DECLARE each_code       VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_calads_2';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;
    DECLARE done                INTEGER DEFAULT FALSE;

	DECLARE curAd_ExtraSlot
	CURSOR FOR
		SELECT AD_Code, Prop_Code, IF (same_condo2 > 1, 400, temp_rank) as new_temp_rank
        FROM (SELECT a3.AD_Code, a3.Prop_Type, a3.Prop_Code, a3.Published_date, a3.Auto_AD_Budget, a3.Manual_AD_Day, a3.Size, a3.AD_Type, a3.Show_Days, a3.Left_Days, a3.temp_rank, IF(a3.AD_Type = 'Manual', 1,a3.same_condo) same_condo2 
                from (select * 
                        from (SELECT *, row_number() over (PARTITION by Prop_Code ORDER BY temp_rank, published_date) as same_condo
                                FROM ads_cal_today_2
                                where AD_Type <> 'Default'
                                order by same_condo, temp_rank, Published_date, AD_Code, Prop_Code) a
                        union 
                        select * 
                        from (SELECT *, row_number() over (PARTITION by AD_Code ORDER BY temp_rank, published_date) as same_condo
                                FROM ads_cal_today_2
                                where AD_Type = 'Default'
                                order by rand()) b) a3 order by same_condo2,published_date) a4
        where IF (same_condo2 > 1, 400, temp_rank) >= 100;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = if(code_found is not null,CONCAT(msg,' AT ',code_found),CONCAT(msg,' AT ',each_code));
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    set success = FALSE;

	TRUNCATE TABLE ads_cal_slot_2;

	OPEN curAd_ExtraSlot;
	SELECT COUNT(1) INTO totalRows FROM ads_cal_today_2;
	SET counter = 1;
	WHILE counter <= totalRows DO
		SELECT AD_Code INTO code_found FROM ads_cal_today_2 WHERE temp_rank = counter;
        SELECT Prop_Code INTO propcode_found FROM ads_cal_today_2 WHERE temp_rank = counter and AD_Code = code_found;
        IF code_found IS NOT NULL THEN
            INSERT INTO ads_cal_slot_2 ( slot, ad_code, prop_code, temp_rank)
			VALUES (counter, code_found, propcode_found, counter );
        ELSE
            FETCH curAd_ExtraSlot INTO each_adcode, each_code, each_rank;
            INSERT INTO ads_cal_slot_2 ( slot, ad_code, prop_code, temp_rank)
			VALUES (counter, each_adcode, each_code, each_rank );
        END IF;
		SET counter = counter + 1;
        SET code_found = NULL;
        SET propcode_found = NULL;
	END WHILE;

    CLOSE curAd_ExtraSlot;
    
    update ads_base_2
    set AD_Rank = null;

    update ads_base_2
    join ads_cal_slot_2 on ads_base_2.AD_Code = ads_cal_slot_2.ad_code and ads_base_2.Prop_Code = ads_cal_slot_2.prop_code
    set ads_base_2.AD_Rank = ads_cal_slot_2.slot,
        ads_base_2.Last_Update_Date = CURRENT_TIMESTAMP
    where ads_cal_slot_2.temp_rank <= 100;

    set success = TRUE;

END //
DELIMITER ;

-- insert ads_show_slot
DROP PROCEDURE IF EXISTS ads_show_slot;
DELIMITER //
CREATE PROCEDURE ads_show_slot (IN column_day INT, OUT success BOOLEAN)
BEGIN
    DECLARE each_slot           INTEGER DEFAULT 0;
    DECLARE each_adcode         VARCHAR(250) DEFAULT NULL;
    DECLARE each_code       VARCHAR(250) DEFAULT NULL;
    DECLARE each_id             VARCHAR(250) DEFAULT NULL;
    DECLARE queryBase1			VARCHAR(100)	DEFAULT "UPDATE ads_cal_slot_show SET `Day_";
    DECLARE queryBase2			VARCHAR(100)	DEFAULT "` = ";
    DECLARE queryBase3			VARCHAR(100)	DEFAULT " Where AD_Code = '";
    DECLARE queryBase7			VARCHAR(100)	DEFAULT "' and Prop_Code = '";
    DECLARE queryFinal1			VARCHAR(2000)	DEFAULT NULL;
    DECLARE queryBase4			VARCHAR(100)	DEFAULT "INSERT INTO ads_cal_slot_show (`AD_Code`,`Prop_Code`,`Day_";
    DECLARE queryBase5			VARCHAR(100)	DEFAULT "`) VALUES('";
    DECLARE queryBase6			VARCHAR(100)	DEFAULT ")";
    DECLARE queryFinal2			VARCHAR(2000)	DEFAULT NULL;
    DECLARE stmt1 				VARCHAR(2000);
    DECLARE stmt2				VARCHAR(2000);
    DECLARE done                INTEGER DEFAULT FALSE;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_show_slot';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE cur_ADS CURSOR FOR 
        SELECT slot,ad_code,prop_code FROM ads_cal_slot_2 order by ad_code,prop_code;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT_WS(' ',msg,'AT',each_adcode,each_code);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    set success = FALSE;

    OPEN cur_ADS;
    read_loop: LOOP
        FETCH cur_ADS INTO each_slot,each_adcode,each_code;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET queryFinal1 = CONCAT(queryBase1, column_day, queryBase2, each_slot, queryBase3, each_adcode, queryBase7, each_code, "'");
        SET queryFinal2 = CONCAT(queryBase4, column_day, queryBase5, each_adcode, "','", each_code, "',", each_slot, queryBase6);
        IF EXISTS (SELECT AD_Code FROM ads_cal_slot_show WHERE AD_Code = each_adcode and Prop_Code = each_code) THEN
            -- select queryFinal1;
            SET @query1 = queryFinal1;
            PREPARE stmt1 FROM @query1;
            EXECUTE stmt1;
            DEALLOCATE PREPARE stmt1;
        ELSE
            -- select queryFinal2;
            SET @query2 = queryFinal2;
            PREPARE stmt2 FROM @query2;
            EXECUTE stmt2;
            DEALLOCATE PREPARE stmt2;
        END IF;
    END LOOP;

    set success = TRUE;

    CLOSE cur_ADS;
END //
DELIMITER ;

-- CALADSS_2
DROP PROCEDURE IF EXISTS ads_refresh_ad_timeline;
DELIMITER $$

CREATE PROCEDURE ads_refresh_ad_timeline ()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE num_times INT DEFAULT 20;
    DECLARE check_success BOOLEAN DEFAULT FALSE;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_refresh_ad_timeline';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    TRUNCATE TABLE ads_base_2;

    INSERT INTO ads_base_2 (AD_ID,AD_Code,Prop_Type,Prop_Code,Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days,Left_Days,AD_Rank
                            ,Project_Name_Manual_Billboard,Developer_Manual_Billboard,Description_Manual_Billboard,Manual_Desktop_Image
                            ,Manual_Mobile_Image,Link,AD_Status,Create_Date,Create_User,Last_Update_Date,Last_Update_User)
    SELECT AD_ID,AD_Code,Prop_Type,Prop_Code,Published_date,Auto_AD_Budget,Manual_AD_Day,Size,AD_Type,Show_Days,Left_Days,AD_Rank
        ,Project_Name_Manual_Billboard,Developer_Manual_Billboard,Description_Manual_Billboard,Manual_Desktop_Image
        ,Manual_Mobile_Image,Link,AD_Status,Create_Date,Create_User,Last_Update_Date,Last_Update_User FROM ads_base;

    TRUNCATE TABLE ads_cal_slot_show;

    WHILE i <= num_times DO
        CALL ads_updateday_2 (check_success) ; -- update show_day,left_day ใน ads_base
        if check_success then
            CALL ads_update_adds_2 (i,check_success) ; -- เอาทั้งหมดที่ผ่านตัวกรองไปเข้าการคำนวณคิว
        end if;
        if check_success then
            CALL ads_calads_2 (check_success) ; -- คำนวณคิว
        end if;
        if check_success then
            CALL ads_show_slot (i,check_success) ;
        end if;
        SET i = i + 1;
    END WHILE;

    update ads_cal_slot_show
    left join ads_property_view on ads_cal_slot_show.Prop_Code = ads_property_view.Prop_Code  
    set ads_cal_slot_show.Project_Name = ads_property_view.Project_Name;

    update ads_cal_slot_show
    left join ads_default on ads_cal_slot_show.Prop_Code = ads_default.AD_ID  
    set ads_cal_slot_show.Project_Name = ads_default.Project_Name_Manual_Billboard
    where ads_cal_slot_show.Prop_Code like 'D%';

    if errorcheck then
		SET code    = '00000';
		SET msg     = 'Success';
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

END$$
DELIMITER ;