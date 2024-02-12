/*กรณีเป็น set EX. 4 โครงการ 75000 บาท ตัวหารคือ 7500 
- ได้ทั้งหมด 10 วัน ได้ 3,3,2,2
- โชว์ไปแล้วโครงการละ 1 วัน เหลือ Left_Days 2,2,1,1
** เปลี่ยนตัวหารเป็น 10000 
    - เอาจำนวนเงินหารกับตัวหาร ให้เป็น a = 7.5
    - เอา Show_Days ทั้งกลุ่มบวก Left_Days ทั้งกลุ่มให้เป็น b = 10
    - เอา a ลบกับ b  ให้เป็น c = -2.5
    - เอา c บวกกับ Left_Days ทั้งกลุ่มให้เป็น d = 3.5
    - ปัดเศษ d = 4
    - เอา d หารกับโครงการในกลุ่ม จะได้โครงการละ 1 วัน เอาไปใส่ใน Left_Days
** เปลี่ยนตัวหารเป็น 5000
    - เอาจำนวนเงินหารกับตัวหาร ให้เป็น a = 15
    - เอา Show_Days ทั้งกลุ่มบวก Left_Days ทั้งกลุ่มให้เป็น b = 10
    - เอา a ลบกับ b  ให้เป็น c = 5
    - เอา c บวกกับ Left_Days ทั้งกลุ่มให้เป็น d = 11
    - ปัดเศษ d = 11
    - เอา d หารกับโครงการในกลุ่ม จะได้ 3,3,3,2 วัน เอาไปใส่ใน Left_Days
- ใช้ได้ทั้ง ยังไม่เคยโชว์เลย, โชว์ไปแล้ว

กรณีเป็น set แล้วมีอันที่ไม่มี Left_Days ตั้งแต่แรก EX. 4 โครงการ 22500 บาท ตัวหารคือ 7500
- ได้ 3 วัน ได้ Left_Days 1,1,1,0
** เปลี่ยนตัวหารเป็น 10000
    - เอาจำนวนเงินหารกับตัวหาร ให้เป็น a = 2.25
    - เอา Show_Days ทั้งกลุ่มบวก Left_Days ทั้งกลุ่มให้เป็น b = 3
    - เอา a ลบกับ b  ให้เป็น c = -0.75
    - เอา c บวกกับ Left_Days ทั้งกลุ่มให้เป็น d = 2.25
    - ปัดเศษ d = 2
    - เอา d หารกับโครงการในกลุ่ม 1,1,0,0 เอาไปใส่ใน Left_Days
** เปลี่ยนตัวหารเป็น 4500
    - เอาจำนวนเงินหารกับตัวหาร ให้เป็น a = 5
    - เอา Show_Days ทั้งกลุ่มบวก Left_Days ทั้งกลุ่มให้เป็น b = 3
    - เอา a ลบกับ b  ให้เป็น c = 2
    - เอา c บวกกับ Left_Days ทั้งกลุ่มให้เป็น d = 5
    - ปัดเศษ d = 5
    - เอา d หารกับโครงการในกลุ่ม จะได้ 2,1,1,1 วัน เอาไปใส่ใน Left_Days
- ใช้ได้ทั้ง ยังไม่เคยโชว์เลย, โชว์ไปแล้ว*/


-- ads_divide
DROP PROCEDURE IF EXISTS ads_change_divide_ad_costs;
DELIMITER //

CREATE PROCEDURE ads_change_divide_ad_costs ()
BEGIN
    DECLARE done            INTEGER         DEFAULT FALSE ;
    DECLARE each_group      VARCHAR(250)    DEFAULT NULL ;
    DECLARE each_budget     INTEGER         DEFAULT NULL;
    DECLARE each_showdays   INTEGER         DEFAULT 0;
    DECLARE each_leftdays   INTEGER         DEFAULT 0;
    DECLARE each_proj       INTEGER         DEFAULT 0;
    DECLARE each_newdays    INTEGER         DEFAULT 0;
    DECLARE each_cal        INTEGER         DEFAULT 0;
    DECLARE each_off        INTEGER         DEFAULT 0;
    DECLARE each_id		    VARCHAR(250)	DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_change_divide_ad_costs';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE cur_Group CURSOR FOR  select * from (SELECT AD_Code
                                                    ,Auto_AD_Budget
                                                    ,sum(Show_Days) as Total_show
                                                    ,sum(Left_Days) as Total_left 
                                                    ,count(*) as Proj
                                                FROM `ads_base` 
                                                where AD_Type = 'Auto' 
                                                group by AD_Code,Auto_AD_Budget) main
                                    where Total_left > 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',each_group);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    open cur_Group;

    read_loop: LOOP
        FETCH cur_Group INTO each_group,each_budget,each_showdays,each_leftdays,each_proj;

        IF done THEN
            LEAVE read_loop;
        END IF;

        set each_newdays = greatest(round(((each_budget/ads_auto_divide()) - (each_showdays + each_leftdays)) + each_leftdays),0);
        if each_newdays = 0 then
            update ads_base set Left_Days = 0 where AD_Code = each_group;
        else
            set each_off = 0;
            while each_newdays > 0 do
                set each_cal = ceiling(each_newdays/each_proj);
                set each_newdays = each_newdays - each_cal;
                set each_proj = each_proj - 1;
                select AD_ID into each_id from ads_base where AD_Code = each_group order by AD_ID limit 1 offset each_off;
                update ads_base set Left_Days = each_cal, Last_Update_Date = CURRENT_TIMESTAMP, Last_Update_User = 0
                where AD_Code = each_group and AD_ID = each_id;
                set each_off = each_off + 1;
                set each_id = null;
            end while;
            while each_proj > 0 do
                select AD_ID into each_id from ads_base where AD_Code = each_group limit 1 offset each_off;
                update ads_base set Left_Days = 0, Last_Update_Date = CURRENT_TIMESTAMP, Last_Update_User = 0
                where AD_Code = each_group and AD_ID = each_id;
                set each_off = each_off + 1;
                set each_id = null;
                set each_proj = each_proj - 1;
            end while;
        end if;

    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = 'Update Success';
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur_Group;

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS truncateInsertViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertViewToTable ()
BEGIN

	CALL truncateInsert_condo_price_calculate_view ();
	CALL truncateInsert_condo_spotlight_relationship_view ();
    CALL truncateInsert_condo_fetch_for_map ();
    CALL ads_update_spotlight ();
    CALL truncateInsert_all_condo_spotlight_relationship ();
    CALL ads_update_allspotlight ();
	CALL truncateInsert_mass_transit_station_match_route ();
    CALL truncateInsert_full_template_factsheet ();
    CALL truncateInsert_full_template_element_image_view ();
    CALL truncateInsert_full_template_credit_view ();
    CALL truncateInsert_full_template_facilities_icon_view ();
    CALL truncateInsert_full_template_section_shortcut_view ();
    CALL truncateInsert_full_template_unit_plan_fullscreen_view ();
    CALL truncateInsert_full_template_unit_gallery_fullscreen_view ();
    CALL truncateInsert_full_template_floor_plan_fullscreen_view ();
    CALL truncateInsert_full_template_facilities_gallery_fullscreen_view ();

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS nightlyUpdate;
DELIMITER $$

CREATE PROCEDURE nightlyUpdate ()
BEGIN

	SELECT CURRENT_TIMESTAMP () AS 'Start updateAllPoint';
    CALL updateAllPoint ();
	SELECT CURRENT_TIMESTAMP () AS 'Start updateCondoCount';
	CALL updateCondoCount ();
	SELECT CURRENT_TIMESTAMP () AS 'Start updateCondoSegment';
	CALL updateCondoSegment ();
	SELECT CURRENT_TIMESTAMP () AS 'Start truncateInsertViewToTable';
	CALL truncateInsertViewToTable ();
	SELECT CURRENT_TIMESTAMP () AS 'Finish';
    CALL ads_nightly_gen_new_ads ();
    SELECT CURRENT_TIMESTAMP () AS 'Start ads_nightly_gen_new_ads';

END$$
DELIMITER ;