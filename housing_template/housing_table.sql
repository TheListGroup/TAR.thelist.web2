-- Table housing
    -- function check null
    -- table housing_around_station
    -- table housing_around_express_way
    -- table housing_popular_carousel
    -- table housing_spotlight
    -- table housing_factsheet_view
    -- table housing_fetch_for_map
    -- table housing_article_fetch_for_map
    -- table housing_gallery

-- function check null
DELIMITER //
CREATE FUNCTION h_nun(nan VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = if(nan='','N/A',ifnull(nan,'N/A'));
    RETURN unit;
END //

-- table housing_around_station
CREATE TABLE IF NOT EXISTS housing_around_station (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Station_Code VARCHAR(50) NOT NULL,
    Station_THName_Display VARCHAR(200) NULL,
    Route_Code VARCHAR(30) NOT NULL,
    Line_Code VARCHAR(30) NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_around_express_way
CREATE TABLE IF NOT EXISTS housing_around_express_way (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Place_ID INT UNSIGNED NOT NULL,
    Place_Attribute_1 VARCHAR(150) NOT NULL,
    Place_Attribute_2 VARCHAR(150) NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_popular_carousel
CREATE TABLE housing_popular_carousel (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    housing_type ENUM('Home','SD','DD','TH','HO','SH'),
    popular_type VARCHAR(30) NOT NULL,
    popular_Code VARCHAR(30) NOT NULL,
    flipboard_display_list INT NOT NULL,
    PRIMARY KEY (id))
ENGINE = InnoDB;

-- table housing_spotlight
CREATE TABLE housing_spotlight (
    Spotlight_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Spotlight_Order int NOT NULL,
    Spotlight_Type varchar(20) NOT NULL,
    Spotlight_Code varchar(20) NOT NULL,
    Spotlight_Name varchar(150) NOT NULL,
    Spotlight_Label varchar(200) NOT NULL,
    Spotlight_Icon varchar(200) NOT NULL,
    Spotlight_Inactive int NOT NULL,
    Housing_Count int NOT NULL,
    Housing_Count_SD int NOT NULL,
    Housing_Count_DD int NOT NULL,
    Housing_Count_TH int NOT NULL,
    Housing_Count_HO int NOT NULL,
    Housing_Count_SH int NOT NULL,
    Menu_List int NOT NULL,
    Menu_Price_Order int NOT NULL,
    Spotlight_Cover int NOT NULL,
    Spotlight_Title varchar(250) NULL,
    Spotlight_Description text NULL,
    Spotlight_Description_Start text NULL,
    Spotlight_Description_End text NULL,
    Keyword_TH text null,
    Keyword_ENG text null,
    PRIMARY KEY (Spotlight_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table housing
---- รอเพิ่ม column คะแนน
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS housing (
    Housing_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Name VARCHAR(250) NULL DEFAULT NULL,
    Housing_ENName VARCHAR(250) NULL DEFAULT NULL,
    Brand_Code VARCHAR(10) NULL DEFAULT NULL,
    Developer_Code VARCHAR(30) NULL DEFAULT NULL,
    Housing_Latitude DOUBLE NULL DEFAULT NULL,
    Housing_Longitude DOUBLE NULL DEFAULT NULL,
    Coordinate_Mark SMALLINT NOT NULL,
    Housing_ScopeArea TEXT NULL DEFAULT NULL,
    Road_Name VARCHAR(50) NULL DEFAULT NULL,
    Postal_Code INT NULL DEFAULT NULL,
    SubDistrict_ID INT NULL DEFAULT NULL,
    District_ID INT NULL DEFAULT NULL,
    Province_ID INT NULL DEFAULT NULL,
    Address_Mark SMALLINT NOT NULL, 
    RealSubDistrict_Code VARCHAR(30) NULL DEFAULT NULL,
    RealDistrict_Code VARCHAR(30) NULL DEFAULT NULL,
    Housing_LandRai FLOAT(10,5) NULL DEFAULT NULL,
    Housing_LandNgan FLOAT(10,5) NULL DEFAULT NULL,
    Housing_LandWa FLOAT(10,5) NULL DEFAULT NULL,
    Housing_TotalRai FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Floor_Min INT NULL DEFAULT NULL,
    Housing_Floor_Max INT NULL DEFAULT NULL,
    Housing_TotalUnit INT NULL DEFAULT NULL,
    Housing_Area_Min FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Area_Max FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Usable_Area_Min FLOAT(10,5) NULL DEFAULT NULL,
    Housing_Usable_Area_Max FLOAT(10,5) NULL DEFAULT NULL,
    Bedroom_Min INT NULL DEFAULT NULL,
    Bedroom_Max INT NULL DEFAULT NULL,
    Bathroom_Min INT NULL DEFAULT NULL,
    Bathroom_Max INT NULL DEFAULT NULL,
    Housing_Price_Min INT NULL DEFAULT NULL,
    Housing_Price_Max INT NULL DEFAULT NULL,
    Housing_Price_Date DATE NULL DEFAULT NULL,
    Housing_Built_Start DATE NULL DEFAULT NULL,
    Housing_Built_Finished DATE NULL DEFAULT NULL,
    Housing_Sold_Status_Raw_Number FLOAT NULL DEFAULT NULL,
    Housing_Sold_Status_Date DATE NULL DEFAULT NULL,
    Housing_Parking_Min INT NULL DEFAULT NULL,
    Housing_Parking_Max INT NULL DEFAULT NULL,
    Housing_Common_Fee_Min INT NULL DEFAULT NULL,
    Housing_Common_Fee_Max INT NULL DEFAULT NULL,
    IS_SD BOOLEAN NOT NULL DEFAULT 0,
    IS_DD BOOLEAN NOT NULL DEFAULT 0,
    IS_TH BOOLEAN NOT NULL DEFAULT 0,
    IS_HO BOOLEAN NOT NULL DEFAULT 0,
    IS_SH BOOLEAN NOT NULL DEFAULT 0,
    Housing_Spotlight_1 VARCHAR(250) NULL,
    Housing_Spotlight_2 VARCHAR(250) NULL,
    Realist_Score DECIMAL(44,12) NULL,
    Housing_URL_Tag VARCHAR(200) NULL DEFAULT NULL,
    Housing_Cover BOOLEAN NOT NULL DEFAULT 0,
    Housing_Redirect VARCHAR(10) NULL DEFAULT NULL,
    Housing_Pageviews INT NOT NULL DEFAULT 0,
    Housing_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Housing_ID),
    INDEX housing_admin1 (Created_By),
    INDEX housing_admin2 (Last_Updated_By),
    INDEX housing_housing_code (Housing_Code),
    INDEX housing_lat (Housing_Latitude),
    INDEX housing_long (Housing_Longitude),
    INDEX housing_brand (Brand_Code),
    INDEX housing_dev (Developer_Code),
    INDEX housing_subdistrict (SubDistrict_ID),
    INDEX housing_district (District_ID),
    INDEX housing_province (Province_ID),
    INDEX housing_realsubdistrict (RealSubDistrict_Code),
    INDEX housing_realdistrict (RealDistrict_Code),
    CONSTRAINT home_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT home_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- table housing_factsheet_view
CREATE TABLE IF NOT EXISTS housing_factsheet_view (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Area VARCHAR(30) NOT NULL,
    Usable_Area VARCHAR(30) NOT NULL,
    Bedroom VARCHAR(20) NOT NULL,
    Price_Date VARCHAR(4) NULL,
    Price VARCHAR(30) NOT NULL,
    Express_Way VARCHAR(250) NOT NULL,
    RealDistrict VARCHAR(150) NOT NULL,
    District VARCHAR(150) NOT NULL,
    Province VARCHAR(150) NOT NULL,
    Housing_Type VARCHAR(70) NOT NULL,
    Housing_TotalRai VARCHAR(20) NOT NULL,
    TotalUnit VARCHAR(10) NOT NULL,
    Housing_Built_Start VARCHAR(4) NOT NULL,
    Housing_Sold_Status_Date VARCHAR(4) NULL,
    Housing_Sold_Status VARCHAR(10) NOT NULL,
    Floor VARCHAR(20) NOT NULL,
    Bedroom_Factsheet VARCHAR(20) NOT NULL,
    Bathroom VARCHAR(20) NOT NULL,
    Parking_Amount VARCHAR(20) NOT NULL,
    Price_Date_Factsheet VARCHAR(4) NULL,
    Price_Factsheet VARCHAR(30) NOT NULL,
    Housing_Area_Factsheet VARCHAR(30) NOT NULL,
    Usable_Area_Factsheet VARCHAR(30) NOT NULL,
    Common_Fee VARCHAR(50) NOT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_fetch_for_map
CREATE TABLE IF NOT EXISTS housing_fetch_for_map (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_ID INT UNSIGNED NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_ENName VARCHAR(250) NULL,
    Housing_Type VARCHAR(70) NOT NULL,
    Price VARCHAR(30) NOT NULL,
    Housing_Area VARCHAR(30) NOT NULL,
    Usable_Area VARCHAR(30) NOT NULL,
    Housing_Build_Date DATE NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(250) NULL,
    Housing_ScopeArea TEXT NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    Brand_Code VARCHAR(10) NULL,
    Developer_Code VARCHAR(30) NULL,
    RealSubDistrict_Code VARCHAR(30) NULL,
    RealDistrict_Code VARCHAR(30) NULL,
    SubDistrict_ID INT NULL,
    District_ID INT NULL,
    Province_ID INT NULL,
    Housing_URL_Tag VARCHAR(200) NULL,
    Housing_Cover BOOLEAN NOT NULL DEFAULT 0,
    Express_Way Text NULL,
    Station Text NULL,
    Total_Point DOUBLE NOT NULL DEFAULT 0,
    Housing_Age INT NULL,
    Housing_Area_Min FLOAT NULL,
    Housing_Area_Max FLOAT NULL,
    Usable_Area_Min FLOAT NULL,
    Usable_Area_Max FLOAT NULL,
    Price_Min INT NULL,
    Price_Max INT NULL,
    Price_Carousel VARCHAR(30) NULL,
    Housing_Area_Carousel VARCHAR(30) NULL,
    Usable_Area_Carousel VARCHAR(30) NULL,
    Housing_Around_Line TEXT NULL,
    Spotlight_List TEXT NULL,
    TotalUnit INT NULL,
    TotalRai FLOAT(10,5) NULL,
    Common_Fee_Min INT NULL,
    Common_Fee_Max INT NULL,
    Bedroom_Min INT NULL,
    Bedroom_Max INT NULL,
    Bathroom_Min INT NULL,
    Bathroom_Max INT NULL,
    Parking_Min INT NULL,
    Parking_Max INT NULL,
    PRIMARY KEY (ID))
ENGINE = InnoDB;

-- table housing_article_fetch_for_map
CREATE TABLE IF NOT EXISTS housing_article_fetch_for_map (
    ID_Prime INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_ID INT UNSIGNED NOT NULL,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_ENName VARCHAR(250) NULL,
    Housing_Name_Search VARCHAR(250) NULL,
    Housing_ENName_Search VARCHAR(250) NULL,
    Housing_Latitude DOUBLE NULL,
    Housing_Longitude DOUBLE NULL,
    ID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    post_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    post_name VARCHAR(200) NOT NULL,
    post_title MEDIUMTEXT NOT NULL,
    RealDistrict_Code VARCHAR(30) NULL,
    RealSubDistrict_Code VARCHAR(30) NULL,
    Province_ID INT NULL,
    PRIMARY KEY (ID_Prime))
ENGINE = InnoDB;

-- table housing_gallery
CREATE TABLE IF NOT EXISTS housing_gallery (
    Housing_Gallery_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Housing_Code VARCHAR(50) NOT NULL,
    Housing_Gallery_Order INT NOT NULL,
    Housing_Gallery_PicName VARCHAR(250) NOT NULL,
    Housing_Gallery_PicName_300 VARCHAR(250) NOT NULL,
    Housing_Gallery_ShortCaption VARCHAR(5) NULL,
    Housing_Gallery_OrderName VARCHAR(5) NULL,
    Housing_Gallery_Caption VARCHAR(100) NULL,
    PRIMARY KEY (Housing_Gallery_ID),
    INDEX hgall_code (Housing_Code),
    INDEX hgall_pic_name (Housing_Gallery_PicName))
ENGINE = InnoDB;