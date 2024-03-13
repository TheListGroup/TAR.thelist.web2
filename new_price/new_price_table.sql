-- real_condo_dd
-- price_source
-- real_condo_price_new
-- all_price_view
-- condo_price_calculate_view
-- all_condo_price_calculate

-- Table `real_condo_dd`
CREATE TABLE IF NOT EXISTS `real_condo_dd` (
    Data_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(8) NOT NULL,
    Data_Date DATE NOT NULL,
    Data_Attribute VARCHAR(100) NULL,
    Data_Value FLOAT NOT NULL,
    Data_Note TEXT NULL,
    Data_Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- Table `price_source`
CREATE TABLE IF NOT EXISTS `price_source` (
    ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    Head ENUM('Company Presentation','Online Survey','Developer') NOT NULL,
    Sub VARCHAR(250) NULL,
    PRIMARY KEY (`ID`))
ENGINE = InnoDB;

-- Table `real_condo_price_new`
CREATE TABLE IF NOT EXISTS `real_condo_price_new` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(50) NOT NULL,
    Price FLOAT UNSIGNED NOT NULL,
    Price_Date DATE NULL,
    Condo_Build_Date ENUM('0','1') NULL,
    Start_or_AVG ENUM('เริ่มต้น','เฉลี่ย') NOT NULL,
    Resale ENUM('0','1') NOT NULL,
    Price_Source SMALLINT UNSIGNED NOT NULL,
    Price_Type ENUM('บ/ตรม','บ/ยูนิต') NOT NULL,
    Special ENUM('0','1') NOT NULL,
    Remark TEXT NULL,
    Price_Status ENUM('0','1','2') NOT NULL,
    Created_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX new_price_admin1 (Created_By),
    INDEX new_price_admin2 (Last_Updated_By),
    INDEX psource (Price_Source),
    CONSTRAINT new_price_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT new_price_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT new_price_source FOREIGN KEY (Price_Source) REFERENCES price_source(ID))
ENGINE = InnoDB;

-- Table `all_price_view`
CREATE TABLE IF NOT EXISTS `all_price_view` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(50) NOT NULL,
    Price FLOAT UNSIGNED NOT NULL,
    Price_Date DATE NULL,
    Condo_Build_Date ENUM('0','1') NULL,
    Start_or_AVG ENUM('เริ่มต้น','เฉลี่ย') NOT NULL,
    Resale ENUM('0','1') NOT NULL,
    Price_Source SMALLINT UNSIGNED NOT NULL,
    Price_Type ENUM('บ/ตรม','บ/ยูนิต') NOT NULL,
    Special ENUM('0','1') NOT NULL,
    Remark TEXT NULL,
    PRIMARY KEY (`ID`),
    INDEX apsource (Price_Source),
    CONSTRAINT all_price_source FOREIGN KEY (Price_Source) REFERENCES price_source(ID))
ENGINE = InnoDB;

-- Table `condo_price_calculate_view`
CREATE TABLE IF NOT EXISTS `condo_price_calculate_view` (
    ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(10) NOT NULL,
    Old_or_New VARCHAR(30) NULL,
    Condo_Age_Status_Square_Text VARCHAR(20) NULL,
    Condo_Price_Per_Square FLOAT NULL,
    Condo_Price_Per_Square_Date DATE NULL,
    Source_Condo_Price_Per_Square VARCHAR(250) NULL,
    Condo_Price_Per_Unit_Text VARCHAR(20) NULL,
    Condo_Price_Per_Unit FLOAT NULL,
    Condo_Price_Per_Unit_Date DATE NULL,
    Source_Condo_Price_Per_Unit VARCHAR(250) NULL,
    Condo_Sold_Status_Show_Value VARCHAR(10) NULL,
    Condo_Sold_Status_Date DATE NULL,
    Source_Condo_Sold_Status_Show_Value VARCHAR(250) NULL,
    Condo_Built_Text VARCHAR(20) NULL,
    Condo_Built_Date YEAR NULL,
    Condo_Date_Calculate DATE NULL,
    Condo_Price_Per_Square_Cal FLOAT NULL,
    Condo_Price_Per_Unit_Cal FLOAT NULL,
    Condo_Price_Per_Square_Sort FLOAT NULL,
    Condo_Price_Per_Unit_Sort FLOAT NULL,
    PRIMARY KEY (`ID`),
    INDEX cpc_condo_code (Condo_Code),
    INDEX cpc_cal_date (Condo_Date_Calculate))
ENGINE = InnoDB;

-- Table `all_condo_price_calculate`
CREATE TABLE IF NOT EXISTS `all_condo_price_calculate` (
    ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    Condo_Code VARCHAR(10) NOT NULL,
    Old_or_New VARCHAR(30) NULL,
    Condo_Age_Status_Square_Text VARCHAR(20) NULL,
    Condo_Price_Per_Square FLOAT NULL,
    Condo_Price_Per_Square_Date DATE NULL,
    Source_Condo_Price_Per_Square VARCHAR(250) NULL,
    Condo_Price_Per_Unit_Text VARCHAR(20) NULL,
    Condo_Price_Per_Unit FLOAT NULL,
    Condo_Price_Per_Unit_Date DATE NULL,
    Source_Condo_Price_Per_Unit VARCHAR(250) NULL,
    Condo_Sold_Status_Show_Value VARCHAR(10) NULL,
    Condo_Sold_Status_Date DATE NULL,
    Source_Condo_Sold_Status_Show_Value VARCHAR(250) NULL,
    Condo_Built_Text VARCHAR(20) NULL,
    Condo_Built_Date YEAR NULL,
    Condo_Date_Calculate DATE NULL,
    Condo_Price_Per_Square_Cal FLOAT NULL,
    Condo_Price_Per_Unit_Cal FLOAT NULL,
    Condo_Price_Per_Square_Sort FLOAT NULL,
    Condo_Price_Per_Unit_Sort FLOAT NULL,
    PRIMARY KEY (`ID`),
    INDEX acpc_condo_code (Condo_Code),
    INDEX acpc_cal_date (Condo_Date_Calculate))
ENGINE = InnoDB;