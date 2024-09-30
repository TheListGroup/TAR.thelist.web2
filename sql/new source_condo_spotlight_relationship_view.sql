-- table update
-- view
-- procedure insert
-- procedure count

"""ALTER TABLE `condo_spotlight_relationship_view` 
ADD `CUS039` VARCHAR(1) NOT NULL AFTER `CUS038`, 
ADD `CUS040` VARCHAR(1) NOT NULL AFTER `CUS039`;"""

"""ALTER TABLE `condo_spotlight_relationship_view` 
ADD `CUS041` VARCHAR(1) NOT NULL AFTER `CUS040`, 
ADD `CUS042` VARCHAR(1) NOT NULL AFTER `CUS041`;

ALTER TABLE `condo_spotlight_relationship_view` DROP `CUS035`;
ALTER TABLE `condo_spotlight_relationship_view` DROP `CUS036`;

INSERT INTO `real_condo_spotlight` (`Spotlight_ID`, `Spotlight_Order`, `Spotlight_Type`, `Spotlight_Code`, `Spotlight_Name`
            , `Spotlight_Label`, `Spotlight_Icon`, `Spotlight_Inactive`, `Condo_Count`, `Menu_List`, `Menu_Price_Order`
            , `Spotlight_Cover`, `Spotlight_Title`, `Spotlight_Description`, `Keyword_TH`, `Keyword_ENG`) 
VALUES (NULL, '0', 'custom', 'CUS041', 'คอนโดเปิดตัว 2024', '', '', '0', '0', '0', '8', '1', '', '', NULL, NULL)
    , (NULL, '0', 'custom', 'CUS042', 'คอนโดเปิดตัว 2023', '', '', '0', '0', '0', '9', '1', '', '', NULL, NULL);

UPDATE `real_condo_spotlight` SET `Menu_Price_Order` = '10' WHERE `real_condo_spotlight`.`Spotlight_ID` = 68;
UPDATE `real_condo_spotlight` SET `Menu_Price_Order` = '11' WHERE `real_condo_spotlight`.`Spotlight_ID` = 67;
UPDATE `real_condo_spotlight` SET `Menu_Price_Order` = '0' WHERE `real_condo_spotlight`.`Spotlight_ID` = 65;
UPDATE `real_condo_spotlight` SET `Menu_Price_Order` = '0' WHERE `real_condo_spotlight`.`Spotlight_ID` = 66;

UPDATE `real_condo_spotlight` SET `Spotlight_Inactive` = '1' WHERE `real_condo_spotlight`.`Spotlight_ID` = 65;
UPDATE `real_condo_spotlight` SET `Spotlight_Inactive` = '1' WHERE `real_condo_spotlight`.`Spotlight_ID` = 66;

UPDATE `real_condo_spotlight` SET `Condo_Count` = 0 WHERE `real_condo_spotlight`.`Spotlight_ID` = 65;
UPDATE `real_condo_spotlight` SET `Condo_Count` = 0 WHERE `real_condo_spotlight`.`Spotlight_ID` = 66;

UPDATE `real_condo_spotlight` SET `Spotlight_Name` = 'คอนโดเปิดตัว 2001 - 2010' 
WHERE `real_condo_spotlight`.`Spotlight_ID` = 63;
UPDATE `real_condo_spotlight` SET `Spotlight_Name` = 'คอนโดเปิดตัว 2011 - 2020' 
WHERE `real_condo_spotlight`.`Spotlight_ID` = 64;"""

CREATE or REPLACE VIEW `source_condo_spotlight_relationship_view` AS
SELECT
    `a`.`Condo_Code` AS `Condo_Code`,
    if((`s1`.`c1` > 0), 'Y', 'N') AS `PS001`,
    if((`s2`.`c1` > 0), 'Y', 'N') AS `PS002`,
    if((`s3`.`c1` > 0), 'Y', 'N') AS `PS003`,
    if((`d`.`Branded_Res_Status` = 'Y'), 'Y', 'N') AS `PS006`,
    if((`s7`.`Size` > 40), 'Y', 'N') AS `PS007`,
    if((`s8`.`c1` > 0), 'Y', 'N') AS `PS008`,
    if((`s9`.`c1` > 0), 'Y', 'N') AS `PS009`,
    if((`d`.`Pet_Friendly_Status` = 'Y'), 'Y', 'N') AS `PS016`,
    if((`d`.`Parking_Amount` > `a`.`Condo_TotalUnit`),'Y','N') AS `PS017`,
    if((`b`.`Condo_Segment` in ('SEG05', 'SEG06', 'SEG07')),
        if((`a`.`Condo_HighRise` = 1),
            if((`a`.`Condo_TotalUnit` < 200), 'Y', 'N'),
            if((`a`.`Condo_TotalUnit` < 100), 'Y', 'N'))
        ,'N') AS `PS019`,
    if((`s21`.`Condo_Code` is not null), 'Y', 'N') AS `PS021`,
    if((`s22`.`Condo_Code` is not null), 'Y', 'N') AS `PS022`,
    if((`s24`.`c1` > 0), 'Y', 'N') AS `PS024`,
    if((`d`.`Pool_Length` >= 50), 'Y', 'N') AS `PS025`,
    if((`d`.`Private_Lift_Status` = 'Y'), 'Y', 'N') AS `PS026`,
    if((`a`.`Condo_Code` <> ''), 'Y', 'N') AS `CUS000`,
    if((`cs1`.`c1` > 0), 'Y', 'N') AS `CUS001`,
    if((`cs2`.`c1` > 0), 'Y', 'N') AS `CUS002`,
    if((`cs3`.`c1` > 0), 'Y', 'N') AS `CUS003`,
    if((`cs4`.`c1` > 0), 'Y', 'N') AS `CUS004`,
    if((`cs5`.`c1` > 0), 'Y', 'N') AS `CUS005`,
    if((`cs6`.`c1` > 0), 'Y', 'N') AS `CUS006`,
    if((`cs7`.`c1` > 0), 'Y', 'N') AS `CUS007`,
    if((`a`.`RealDistrict_Code` = 'M11'), 'Y', 'N') AS `CUS008`,
    if((`d`.`Auto_Parking_Status` = 'Y'), 'Y', 'N') AS `CUS009`,
    if(((`c`.`Condo_Price_Per_Unit_Sort` <= 1000000) and (`c`.`Condo_Price_Per_Unit_Sort` > 0)),'Y','N') AS `CUS010`,
    if(((`c`.`Condo_Price_Per_Unit_Sort` <= 2000000) and (`c`.`Condo_Price_Per_Unit_Sort` > 1000000)),'Y','N') AS `CUS011`,
    if((`b`.`Condo_Built_Finished` is not null),
        if(((year(curdate()) - year(`b`.`Condo_Built_Finished`)) > 0),
            'Y',
            'N'),
        if((`b`.`Condo_Built_Start` is not null),
            if((`a`.`Condo_HighRise` = 1),
                if(((year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)) > 0),
                    'Y',
                    'N'),
                if(((year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)) > 0),
                    'Y',
                    'N')),
            'N')) AS `CUS014`,
    if((`cs15`.`c1` > 0), 'Y', 'N') AS `CUS015`,
    if((`cs16`.`c1` > 0), 'Y', 'N') AS `CUS016`,
    if((`cs17`.`c1` > 0), 'Y', 'N') AS `CUS017`,
    if((`cs18`.`c1` > 0), 'Y', 'N') AS `CUS018`,
    if((`cs19`.`c1` > 0), 'Y', 'N') AS `CUS019`,
    if((`cs20`.`c1` > 0), 'Y', 'N') AS `CUS020`,
    if(((`c`.`Condo_Price_Per_Unit_Sort` <= 5000000) and (`c`.`Condo_Price_Per_Unit_Sort` > 2000000)),'Y','N') AS `CUS021`,
    if(((`c`.`Condo_Price_Per_Unit_Sort` <= 10000000) and (`c`.`Condo_Price_Per_Unit_Sort` > 5000000)),'Y','N') AS `CUS022`,
    if(((`c`.`Condo_Price_Per_Unit_Sort` <= 20000000) and (`c`.`Condo_Price_Per_Unit_Sort` > 10000000)),'Y','N') AS `CUS023`,
    if(((`c`.`Condo_Price_Per_Unit_Sort` <= 40000000) and (`c`.`Condo_Price_Per_Unit_Sort` > 20000000)),'Y','N') AS `CUS024`,
    if((`c`.`Condo_Price_Per_Unit_Sort` > 40000000), 'Y', 'N') AS `CUS025`,
    if((`a`.`HoldType_ID` = 1), 'Y', 'N') AS `CUS026`,
    if((`a`.`HoldType_ID` = 2), 'Y', 'N') AS `CUS027`,
    if((`a`.`Condo_LowRise` = 1), 'Y', 'N') AS `CUS028`,
    if((`a`.`Condo_HighRise` = 1), 'Y', 'N') AS `CUS029`,
    if((`c`.`Condo_Sold_Status_Show_Value` = 'RESALE'),'N','Y') AS `CUS030`,
    if((`c`.`Condo_Sold_Status_Show_Value` = 'RESALE'),'Y','N') AS `CUS031`,
    if((`b`.`Condo_Built_Finished` is not null),
        if(((year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)) > 0),
            'N',
            'Y'),
        if((`b`.`Condo_Built_Start` is not null),
            if((`a`.`Condo_HighRise` = 1),
                if(((year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)) > 0),
                    'N',
                    'Y'),
                if(((year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)) > 0),
                    'N',
                    'Y')),
            'N')) AS `CUS032`,
    if(((year(`c`.`Condo_Date_Calculate`) >= 2001) and (year(`c`.`Condo_Date_Calculate`) <= 2010)),'Y','N') AS `CUS033`,
    if(((year(`c`.`Condo_Date_Calculate`) >= 2011) and (year(`c`.`Condo_Date_Calculate`) <= 2020)),'Y','N') AS `CUS034`,
    if((year(`c`.`Condo_Date_Calculate`) = 2021),'Y','N') AS `CUS037`,
    if((year(`c`.`Condo_Date_Calculate`) = 2022),'Y','N') AS `CUS038`,
    if(c39.Condo_Code is not null, 'Y', 'N') as CUS039,
    if(c40.Condo_Code is not null, 'Y', 'N') as CUS040,
    if((year(`c`.`Condo_Date_Calculate`) = 2024),'Y','N') AS `CUS041`,
    if((year(`c`.`Condo_Date_Calculate`) = 2023),'Y','N') AS `CUS042`
FROM (((((((((((((((((((((((((((`real_condo` `a` 
join `real_condo_price` `b` on((`a`.`Condo_Code` = `b`.`Condo_Code`)))
join `condo_price_calculate_view` `c` on((`a`.`Condo_Code` = `c`.`Condo_Code`)))
left join (select `real_condo_full_template`.`id` AS `id`,
                `real_condo_full_template`.`Condo_Code` AS `Condo_Code`,
                `real_condo_full_template`.`Parking_Amount` AS `Parking_Amount`,
                `real_condo_full_template`.`Manual_Parking_Status` AS `Manual_Parking_Status`,
                `real_condo_full_template`.`Auto_Parking_Status` AS `Auto_Parking_Status`,
                `real_condo_full_template`.`Passenger_Lift_Amount` AS `Passenger_Lift_Amount`,
                `real_condo_full_template`.`Service_Lift_Amount` AS `Service_Lift_Amount`,
                `real_condo_full_template`.`Private_Lift_Status` AS `Private_Lift_Status`,
                `real_condo_full_template`.`Pool_Type` AS `Pool_Type`,
                `real_condo_full_template`.`Pool_Width` AS `Pool_Width`,
                `real_condo_full_template`.`Pool_Length` AS `Pool_Length`,
                `real_condo_full_template`.`Condo_Fund_Fee` AS `Condo_Fund_Fee`,
                `real_condo_full_template`.`Branded_Res_Status` AS `Branded_Res_Status`,
                `real_condo_full_template`.`Pet_Friendly_Status` AS `Pet_Friendly_Status`,
                `real_condo_full_template`.`STU_Amount` AS `STU_Amount`,
                `real_condo_full_template`.`1BR_Amount` AS `1BR_Amount`,
                `real_condo_full_template`.`2BR_Amount` AS `2BR_Amount`,
                `real_condo_full_template`.`3BR_Amount` AS `3BR_Amount`,
                `real_condo_full_template`.`4BR_Amount` AS `4BR_Amount`,
                `real_condo_full_template`.`Manual_Parking_Amount` AS `Manual_Parking_Amount`,
                `real_condo_full_template`.`Auto_Parking_Amount` AS `Auto_Parking_Amount`,
                `real_condo_full_template`.`LockElevator_Status` AS `LockElevator_Status`,
                `real_condo_full_template`.`UnLockElevator_Status` AS `UnLockElevator_Status`,
                `real_condo_full_template`.`Pool_Name` AS `Pool_Name`,
                `real_condo_full_template`.`Pool_2_Name` AS `Pool_2_Name`,
                `real_condo_full_template`.`Pool_2_Width` AS `Pool_2_Width`,
                `real_condo_full_template`.`Pool_2_Length` AS `Pool_2_Length`,
                `real_condo_full_template`.`Create_Date` AS `Create_Date`,
                `real_condo_full_template`.`Create_User` AS `Create_User`,
                `real_condo_full_template`.`Last_Update_Date` AS `Last_Update_Date`,
                `real_condo_full_template`.`Last_Update_User` AS `Last_Update_User`
            from `real_condo_full_template`
            where ((`real_condo_full_template`.`Condo_Code` <> 'CD2860')
            and (`real_condo_full_template`.`Condo_Code` <> 'CD2861'))) `d` 
on((`a`.`Condo_Code` = `d`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'PS001')
            group by `real_spotlight_relationships`.`Condo_Code`) `s1` 
on((`a`.`Condo_Code` = `s1`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'PS002')
            group by `real_spotlight_relationships`.`Condo_Code`) `s2` 
on((`a`.`Condo_Code` = `s2`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'PS003')
            group by `real_spotlight_relationships`.`Condo_Code`) `s3` 
on((`a`.`Condo_Code` = `s3`.`Condo_Code`)))
left join (select `full_template_unit_type`.`Condo_Code` AS `Condo_Code`,
                    max(`full_template_unit_type`.`Size`) AS `Size`
            from `full_template_unit_type`
            where (`full_template_unit_type`.`Unit_Type_Status` <> 2)
            group by `full_template_unit_type`.`Condo_Code`) `s7` 
on((`a`.`Condo_Code` = `s7`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'PS008')
            group by `real_spotlight_relationships`.`Condo_Code`) `s8` 
on((`a`.`Condo_Code` = `s8`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'PS009')
            group by `real_spotlight_relationships`.`Condo_Code`) `s9` 
on((`a`.`Condo_Code` = `s9`.`Condo_Code`)))
left join (select `full_template_unit_type`.`Condo_Code` AS `Condo_Code`,
                    `full_template_unit_type`.`Unit_Floor_Type_ID` AS `Unit_Floor_Type_ID`
            from `full_template_unit_type`
            where ((`full_template_unit_type`.`Unit_Type_Status` <> 2)
            and (`full_template_unit_type`.`Unit_Floor_Type_ID` = 3))
            group by `full_template_unit_type`.`Condo_Code`) `s21` 
on((`a`.`Condo_Code` = `s21`.`Condo_Code`)))
left join (select `full_template_unit_type`.`Condo_Code` AS `Condo_Code`,
                    `full_template_unit_type`.`Unit_Floor_Type_ID` AS `Unit_Floor_Type_ID`
            from `full_template_unit_type`
            where ((`full_template_unit_type`.`Unit_Type_Status` <> 2)
            and (`full_template_unit_type`.`Unit_Floor_Type_ID` = 2))
            group by `full_template_unit_type`.`Condo_Code`) `s22` 
on((`a`.`Condo_Code` = `s22`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'PS024')
            group by `real_spotlight_relationships`.`Condo_Code`) `s24` 
on((`a`.`Condo_Code` = `s24`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS001')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs1` 
on((`a`.`Condo_Code` = `cs1`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS002')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs2` 
on((`a`.`Condo_Code` = `cs2`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS003')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs3` 
on((`a`.`Condo_Code` = `cs3`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS004')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs4` 
on((`a`.`Condo_Code` = `cs4`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS005')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs5` 
on((`a`.`Condo_Code` = `cs5`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS006')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs6` 
on((`a`.`Condo_Code` = `cs6`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS007')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs7` 
on((`a`.`Condo_Code` = `cs7`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS015')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs15` 
on((`a`.`Condo_Code` = `cs15`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS016')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs16` 
on((`a`.`Condo_Code` = `cs16`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS017')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs17` 
on((`a`.`Condo_Code` = `cs17`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS018')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs18` 
on((`a`.`Condo_Code` = `cs18`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS019')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs19` 
on((`a`.`Condo_Code` = `cs19`.`Condo_Code`)))
left join (select `real_spotlight_relationships`.`Condo_Code` AS `Condo_Code`,
                    count(1) AS `c1`
            from `real_spotlight_relationships`
            where (`real_spotlight_relationships`.`Spotlight_Code` = 'CUS020')
            group by `real_spotlight_relationships`.`Condo_Code`) `cs20` 
on((`a`.`Condo_Code` = `cs20`.`Condo_Code`)))
left join (SELECT ff.Condo_Code
            FROM `full_template_floor_plan` ff
            left join full_template_vector_floor_plan_relationship fv on ff.Floor_Plan_ID = fv.Floor_Plan_ID
            left join ( SELECT *
                            ,(if(Section_1_shortcut_Name is not null,1,0) 
                            + if(Section_2_shortcut_Name is not null,1,0) 
                            + if(Section_3_shortcut_Name is not null,1,0) 
                            + if(Section_4_shortcut_Name is not null,1,0) 
                            + if(Section_5_shortcut_Name is not null,1,0)) as cal 
                        FROM `full_template_section_shortcut_view`) aaa
            on ff.Condo_Code = aaa.Condo_Code
            where ff.Floor_Plan_Status = 1
            and fv.Vector_Type = 1
            and fv.Relationship_Status = 1
            and aaa.cal > 0
            group by ff.Condo_Code
            order by ff.Condo_Code) c39
on((a.Condo_Code = c39.Condo_Code)))
left join (select Condo_Code 
            from classified 
            where Classified_Status = '1' 
            group by Condo_Code) c40
on((a.Condo_Code = c40.Condo_Code)))
WHERE ((`a`.`Condo_Latitude` is not null)
AND (`a`.`Condo_Longitude` is not null)
AND (`a`.`Condo_Status` = 1))
ORDER BY `a`.`Condo_Code` ASC;


DROP PROCEDURE IF EXISTS truncateInsert_condo_spotlight_relationship_view;
DELIMITER //

CREATE PROCEDURE truncateInsert_condo_spotlight_relationship_view ()
BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(50) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name6 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name7 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name8 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name9 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name10 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name11 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name12 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name13 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name14 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name15 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name16 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name17 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name18 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name19 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name20 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name21 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name22 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name23 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name24 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name25 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name26 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name27 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name28 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name29 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name30 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name31 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name32 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name33 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name34 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name35 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name36 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name37 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name38 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name39 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name40 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name41 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name42 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name43 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name44 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name45 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name46 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name47 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name48 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name49 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name50 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name51 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name52 VARCHAR(50) DEFAULT NULL;
    DECLARE v_name53 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name54 VARCHAR(50) DEFAULT NULL;
    DECLARE mySpotlight	VARCHAR(500) DEFAULT 0;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_condo_spotlight_relationship_view';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

	-- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code,PS001,PS002,PS003,PS006,PS007,PS008,PS009,PS016,PS017,PS019,PS021,PS022,PS024,
                                PS025,PS026,CUS000,CUS001,CUS002,CUS003,CUS004,CUS005,CUS006,CUS007,CUS008,CUS009,
                                CUS010,CUS011,CUS014,CUS015,CUS016,CUS017,CUS018,CUS019,CUS020,CUS021,CUS022,CUS023,CUS024,
                                CUS025,CUS026,CUS027,CUS028,CUS029,CUS030,CUS031,CUS032,CUS033,CUS034,CUS037,
                                CUS038,CUS039,CUS040,CUS041,CUS042 FROM source_condo_spotlight_relationship_view;
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

	TRUNCATE TABLE condo_spotlight_relationship_view;

	-- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO
			condo_spotlight_relationship_view(
				Condo_Code,
				PS001,
				PS002,
				PS003,
				PS006,
				PS007,
				PS008,
				PS009,
				PS016,
				PS017,
				PS019,
				PS021,
				PS022,
				PS024,
				PS025,
				PS026,
				CUS000,
				CUS001,
				CUS002,
				CUS003,
				CUS004,
				CUS005,
				CUS006,
				CUS007,
				CUS008,
				CUS009,
				CUS010,
				CUS011,
				CUS014,
				CUS015,
				CUS016,
				CUS017,
				CUS018,
				CUS019,
				CUS020,
				CUS021,
				CUS022,
				CUS023,
				CUS024,
				CUS025,
				CUS026,
				CUS027,
				CUS028,
				CUS029,
				CUS030,
				CUS031,
				CUS032,
				CUS033,
				CUS034,
				CUS037,
				CUS038,
                CUS039,
				CUS040,
                CUS041,
				CUS042,
                Top_Spotlight
			)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54,mySpotlight);
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



DROP PROCEDURE IF EXISTS updateCondoCountSpotlight;
DELIMITER //

CREATE PROCEDURE updateCondoCountSpotlight ()
BEGIN
	DECLARE proc_name       VARCHAR(50) DEFAULT 'updateCondoCountSpotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT; 
            INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
			set errorcheck = 0;
        END;

	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS001 ='Y' ) WHERE   Spotlight_Code = 'PS001';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS002 ='Y' ) WHERE   Spotlight_Code = 'PS002';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS003 ='Y' ) WHERE   Spotlight_Code = 'PS003';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS006 ='Y' ) WHERE   Spotlight_Code = 'PS006';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS007 ='Y' ) WHERE   Spotlight_Code = 'PS007';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS008 ='Y' ) WHERE   Spotlight_Code = 'PS008';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS009 ='Y' ) WHERE   Spotlight_Code = 'PS009';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS016 ='Y' ) WHERE   Spotlight_Code = 'PS016';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS017 ='Y' ) WHERE   Spotlight_Code = 'PS017';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS019 ='Y' ) WHERE   Spotlight_Code = 'PS019';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS021 ='Y' ) WHERE   Spotlight_Code = 'PS021';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS022 ='Y' ) WHERE   Spotlight_Code = 'PS022';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS024 ='Y' ) WHERE   Spotlight_Code = 'PS024';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS025 ='Y' ) WHERE   Spotlight_Code = 'PS025';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where PS026 ='Y' ) WHERE   Spotlight_Code = 'PS026';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS001 ='Y' ) WHERE   Spotlight_Code = 'CUS001';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS002 ='Y' ) WHERE   Spotlight_Code = 'CUS002';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS003 ='Y' ) WHERE   Spotlight_Code = 'CUS003';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS004 ='Y' ) WHERE   Spotlight_Code = 'CUS004';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS005 ='Y' ) WHERE   Spotlight_Code = 'CUS005';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS006 ='Y' ) WHERE   Spotlight_Code = 'CUS006';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS007 ='Y' ) WHERE   Spotlight_Code = 'CUS007';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS008 ='Y' ) WHERE   Spotlight_Code = 'CUS008';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS009 ='Y' ) WHERE   Spotlight_Code = 'CUS009';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS010 ='Y' ) WHERE   Spotlight_Code = 'CUS010';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS011 ='Y' ) WHERE   Spotlight_Code = 'CUS011';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS014 ='Y' ) WHERE   Spotlight_Code = 'CUS014';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS015 ='Y' ) WHERE   Spotlight_Code = 'CUS015';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS016 ='Y' ) WHERE   Spotlight_Code = 'CUS016';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS017 ='Y' ) WHERE   Spotlight_Code = 'CUS017';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS018 ='Y' ) WHERE   Spotlight_Code = 'CUS018';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS019 ='Y' ) WHERE   Spotlight_Code = 'CUS019';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS020 ='Y' ) WHERE   Spotlight_Code = 'CUS020';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS021 ='Y' ) WHERE   Spotlight_Code = 'CUS021';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS022 ='Y' ) WHERE   Spotlight_Code = 'CUS022';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS023 ='Y' ) WHERE   Spotlight_Code = 'CUS023';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS024 ='Y' ) WHERE   Spotlight_Code = 'CUS024';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS025 ='Y' ) WHERE   Spotlight_Code = 'CUS025';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS026 ='Y' ) WHERE   Spotlight_Code = 'CUS026';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS027 ='Y' ) WHERE   Spotlight_Code = 'CUS027';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS028 ='Y' ) WHERE   Spotlight_Code = 'CUS028';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS029 ='Y' ) WHERE   Spotlight_Code = 'CUS029';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS030 ='Y' ) WHERE   Spotlight_Code = 'CUS030';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS031 ='Y' ) WHERE   Spotlight_Code = 'CUS031';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS032 ='Y' ) WHERE   Spotlight_Code = 'CUS032';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS033 ='Y' ) WHERE   Spotlight_Code = 'CUS033';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS034 ='Y' ) WHERE   Spotlight_Code = 'CUS034';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS037 ='Y' ) WHERE   Spotlight_Code = 'CUS037';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS038 ='Y' ) WHERE   Spotlight_Code = 'CUS038';
    UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS039 ='Y' ) WHERE   Spotlight_Code = 'CUS039';
    UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS040 ='Y' ) WHERE   Spotlight_Code = 'CUS040';
    UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS041 ='Y' ) WHERE   Spotlight_Code = 'CUS041';
	UPDATE  real_condo_spotlight SET Condo_Count = ( SELECT COUNT(1) FROM  condo_spotlight_relationship_view where CUS042 ='Y' ) WHERE   Spotlight_Code = 'CUS042';

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT('No count for update (too many updates).');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

END //
DELIMITER ;