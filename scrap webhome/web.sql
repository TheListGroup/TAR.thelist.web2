-- Table `web_user`
-- Table `condo_price_other_web`
-- Table `classified_other_web`

-- -----------------------------------------------------
-- Table `web_user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `web_user` (
    `User_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Name` VARCHAR(100) NOT NULL,
    `URL` TEXT NOT NULL,
    `User_Status` ENUM('0','1','2') NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`User_ID`),
    INDEX web_user_admin1 (Created_By),
    INDEX web_user_admin2 (Last_Updated_By),
    CONSTRAINT web_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT web_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

insert into web_user (Name, URL, User_Status, Created_By, Last_Updated_By)
values ('Home Buyer', 'https://www.home.co.th/area', '1', 32, 32);

-- -----------------------------------------------------
-- Table `condo_price_other_web`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `condo_price_other_web` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Project_ID` VARCHAR(50) NOT NULL,
    `Condo_Code` VARCHAR(50) NOT NULL,
    `Price_Start` INT UNSIGNED NULL,
    `Area_Min` FLOAT(6,2) UNSIGNED NULL,
    `Area_Max` FLOAT(6,2) UNSIGNED NULL,
    `Lastest_Update` DATE NOT NULL,
    `Project_Status` ENUM('0','1','2') NOT NULL,
    `User_ID` INT UNSIGNED NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Run_Count` smallint unsigned NOT NULL,
    PRIMARY KEY (`ID`),
    INDEX web_price_project (Project_ID),
    INDEX web_price_admin1 (Created_By),
    INDEX web_price_admin2 (Last_Updated_By),
    INDEX web_price_user (User_ID),
    CONSTRAINT web_price_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT web_price_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT web_price_user FOREIGN KEY (User_ID) REFERENCES web_user(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `classified_other_web`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classified_other_web` (
    `Classified_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Project_ID`  VARCHAR(50) NOT NULL,
    `Ref_ID` varchar(100) NOT NULL,
    `Sale` BOOLEAN NOT NULL DEFAULT 0,
    `Rent` BOOLEAN NOT NULL DEFAULT 0,
    `Price_Sale` INT UNSIGNED NULL,
    `Price_Rent` INT UNSIGNED NULL,
    `Bedroom` SMALLINT UNSIGNED NULL,
    `Bathroom` SMALLINT UNSIGNED NULL,
    `Size` FLOAT UNSIGNED NULL,
    `Classified_Date` DATE NULL,
    `Classified_Status` ENUM('0','1','2','3') NULL,
    `User_ID` INT UNSIGNED NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Classified_ID`),
    INDEX co_admin1 (Created_By),
    INDEX co_admin2 (Last_Updated_By),
    CONSTRAINT co_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT co_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;