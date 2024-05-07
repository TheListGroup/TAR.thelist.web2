-- truncateInsertViewSearch_housing
-- truncateInsertHousingViewToTable
-- UpdateHousingCount
-- HousingUpdate

-- truncateInsertViewSearch_housing
DROP PROCEDURE IF EXISTS truncateInsertViewSearch_housing;
DELIMITER $$

CREATE PROCEDURE truncateInsertViewSearch_housing ()
BEGIN

    CALL truncateInsert_search_housing_detail_view ();
    CALL search_housing_detail_update_spotlight ();
    CALL truncateInsert_search_housing_category_spotlight ();

END$$
DELIMITER ;

-- truncateInsertHousingViewToTable
DROP PROCEDURE IF EXISTS truncateInsertHousingViewToTable;
DELIMITER $$

CREATE PROCEDURE truncateInsertHousingViewToTable ()
BEGIN

    CALL truncateInsert_housing_around_station();
    CALL truncateInsert_housing_around_express_way();
    CALL truncateInsert_housing_spotlight();
    CALL truncateInsert_housing_factsheet_view();
    CALL truncateInsert_housing_fetch_for_map();
    CALL truncateInsert_housing_article_fetch_for_map();
    CALL truncateInsertViewSearch_housing();

END$$
DELIMITER ;

-- UpdateHousingCount
DROP PROCEDURE IF EXISTS UpdateHousingCount;
DELIMITER $$

CREATE PROCEDURE UpdateHousingCount ()
BEGIN

	CALL updatehousingCountSpotlight();
	CALL updateHousingCountProvince();
	CALL updateHousingCountYarnMain();
	CALL updateHousingCountYarnSub();

END$$
DELIMITER ;


-- HousingUpdate
DROP PROCEDURE IF EXISTS HousingUpdate;
DELIMITER $$

CREATE PROCEDURE HousingUpdate ()
BEGIN

    SELECT CURRENT_TIMESTAMP () AS 'Start updatehousingPoint';
	CALL updateHousingPoint();
    SELECT CURRENT_TIMESTAMP () AS 'Start UpdateHousingCount';
	CALL UpdateHousingCount();
    SELECT CURRENT_TIMESTAMP () AS 'Start truncateInsertHousingViewToTable';
	CALL truncateInsertHousingViewToTable();

END$$
DELIMITER ;
