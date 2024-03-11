-- -----------------------------------------------------
-- Table `classified_user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_user` (
    `User_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `First_Name` VARCHAR(100) NOT NULL,
    `Last_Name` VARCHAR(100) NULL,
    `Profile_Picture` TEXT NULL,
    `User_Type` ENUM('Owner','Agent') NULL,
    `Call` VARCHAR(15) NULL,
    `Line_ID` VARCHAR(100) NULL,
    `Email` VARCHAR(100) NULL,
    `Facebook` VARCHAR(100) NULL,
    `Registration_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Company` VARCHAR(100) NULL,
    `User_Status` ENUM('0','1','2') NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`User_ID`),
    INDEX classified_user_admin1 (Created_By),
    INDEX classified_user_admin2 (Last_Updated_By),
    CONSTRAINT classified_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT classified_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `classified`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified` (
    `Classified_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Ref_ID` VARCHAR(100) NOT NULL,
    `Project_ID` VARCHAR(100) NOT NULL,
    `Title_TH` TEXT NULL,
    `Title_ENG` TEXT NULL,
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Sale` BOOLEAN NOT NULL DEFAULT 0,
    `Sale_with_Tenant` BOOLEAN NOT NULL DEFAULT 0,
    `Rent` BOOLEAN NOT NULL DEFAULT 0,
    `Price_Sale` INT UNSIGNED NULL,
    `Sale_Transfer_Fee` INT UNSIGNED NULL,
    `Sale_Deposit` INT UNSIGNED NULL,
    `Sale_Mortgage_Costs` INT UNSIGNED NULL,
    `Price_Rent` INT UNSIGNED NULL,
    `Min_Rental_Contract` SMALLINT UNSIGNED NULL,
    `Rent_Deposit` SMALLINT UNSIGNED NULL,
    `Advance_Payment` SMALLINT UNSIGNED NULL,
    `Room_Type` ENUM('Studio','1 Bedroom','2 Bedroom','3 Bedroom','4 Bedroom') NULL,
    `Unit_Floor_Type` ENUM('Loft','Duplex') NULL,
    `Bedroom` SMALLINT UNSIGNED NULL,
    `Bathroom` SMALLINT UNSIGNED NULL,
    `Size` FLOAT(8,3) UNSIGNED NULL,
    `Furnish` ENUM('Unfurnished','Fully Fitted','Fully Furnished') NULL,
    `Parking` BOOLEAN NULL,
    `Descriptions_Eng` TEXT NULL,
    `Descriptions_TH` TEXT NULL,
    `User_ID` INT UNSIGNED NULL,
    `Classified_Status` ENUM('0','1','2','3') NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Classified_ID`),
    INDEX c_admin1 (Created_By),
    INDEX c_admin2 (Last_Updated_By),
    INDEX classified_user (User_ID),
    INDEX classified_condo (Condo_Code),
    CONSTRAINT c_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT c_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT classified_user FOREIGN KEY (User_ID) REFERENCES classified_user(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `classified_image`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_image` (
    `Classified_Image_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_Image_Caption` VARCHAR(100) NULL,
    `Classified_Image_URL` TEXT NOT NULL,
    `Displayed_Order_in_Classified` SMALLINT UNSIGNED NOT NULL,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Classified_Image_Status` ENUM('0','1','2') NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Classified_Image_ID`),
    INDEX classified_image_admin1 (Created_By),
    INDEX classified_image_admin2 (Last_Updated_By),
    INDEX classified_image_id (Classified_ID),
    CONSTRAINT classified_image_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT classified_image_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT classified_image_id FOREIGN KEY (Classified_ID) REFERENCES classified(Classified_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `classified_furniture_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_furniture_category` (
    `Furniture_Category_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Furniture_Category_Name` VARCHAR(100) NOT NULL,
    `Furniture_Category_Order` SMALLINT UNSIGNED NOT NULL,
    `Furniture_Category_Icon` VARCHAR(250) NOT NULL,
    `Furniture_Category_Status` ENUM('0','1','2') NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Furniture_Category_ID`),
    INDEX cate_admin1 (Created_By),
    INDEX cate_admin2 (Last_Updated_By),
    CONSTRAINT cate_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT cate_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `classified_furniture`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_furniture` (
    `Furniture_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Furniture_Name` VARCHAR(100) NOT NULL,
    `Furniture_Category_ID` SMALLINT UNSIGNED NOT NULL,
    `Furniture_Order` SMALLINT UNSIGNED NOT NULL,
    `Furniture_Status` ENUM('0','1','2') NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Furniture_ID`),
    INDEX furniture_admin1 (Created_By),
    INDEX furniture_admin2 (Last_Updated_By),
    INDEX furniture_category (Furniture_Category_ID),
    CONSTRAINT furniture_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT furniture_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT furniture_category FOREIGN KEY (Furniture_Category_ID) REFERENCES classified_furniture_category(Furniture_Category_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `classified_furniture_category_relationships`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_furniture_category_relationships` (
    `Relationship_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Furniture_ID` SMALLINT UNSIGNED NOT NULL,
    `Relationship_Status` ENUM('0','1','2') NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Relationship_ID`),
    INDEX relationship_admin1 (Created_By),
    INDEX relationship_admin2 (Last_Updated_By),
    INDEX relationship_classified (Classified_ID),
    INDEX relationship_furniture (Furniture_ID),
    CONSTRAINT relationship_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT relationship_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT relationship_classified FOREIGN KEY (Classified_ID) REFERENCES classified(Classified_ID),
    CONSTRAINT relationship_furniture FOREIGN KEY (Furniture_ID) REFERENCES classified_furniture(Furniture_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `classified_all_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_all_logs` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Insert_Day` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Classified_ID` INT UNSIGNED NOT NULL,
    `Ref_ID` VARCHAR(100) NOT NULL,
    `Project_ID` VARCHAR(100) NOT NULL,
    `Title_TH` TEXT NULL,
    `Title_ENG` TEXT NULL,
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Sale` BOOLEAN NOT NULL DEFAULT 0,
    `Sale_with_Tenant` BOOLEAN NOT NULL DEFAULT 0,
    `Rent` BOOLEAN NOT NULL DEFAULT 0,
    `Price_Sale` INT UNSIGNED NULL,
    `Sale_Transfer_Fee` INT UNSIGNED NULL,
    `Sale_Deposit` INT UNSIGNED NULL,
    `Sale_Mortgage_Costs` INT UNSIGNED NULL,
    `Price_Rent` INT UNSIGNED NULL,
    `Min_Rental_Contract` SMALLINT UNSIGNED NULL,
    `Rent_Deposit` SMALLINT UNSIGNED NULL,
    `Advance_Payment` SMALLINT UNSIGNED NULL,
    `Room_Type` ENUM('Studio','1 Bedroom','2 Bedroom','3 Bedroom','4 Bedroom') NULL,
    `Unit_Floor_Type` ENUM('Loft','Duplex') NULL,
    `Bedroom` SMALLINT UNSIGNED NULL,
    `Bathroom` SMALLINT UNSIGNED NULL,
    `Size` FLOAT(8,3) UNSIGNED NULL,
    `Furnish` ENUM('Unfurnished','Fully Fitted','Fully Furnished') NULL,
    `Parking` BOOLEAN NULL,
    `Descriptions_Eng` TEXT NULL,
    `Descriptions_TH` TEXT NULL,
    `User_ID` INT UNSIGNED NULL,
    `Classified_Status` ENUM('0','1','2','3') NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX cl_user (User_ID),
    INDEX cl_condo (Condo_Code),
    CONSTRAINT cl_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT cl_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT classifiedl_user FOREIGN KEY (User_ID) REFERENCES classified_user(User_ID))
ENGINE = InnoDB;