-- housing_classified
-- Table `housing_classified_image`
-- housing_classified_list_view
-- housing_classified_detail_view

-- housing_classified
CREATE TABLE IF NOT EXISTS `housing_classified` (
    `Classified_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Ref_ID` VARCHAR(100) NOT NULL,
    `Project_ID` VARCHAR(100) NULL,
    `Classified_Type` ENUM('เช่า','ขาย','เช่าและขาย') NOT NULL,
    `Housing_Type` ENUM('บ้านเดี่ยว','บ้านแฝด','ทาวน์โฮม,','โฮมออฟฟิศ','อาคารพาณิชย์') NOT NULL,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Housing_Latitude` DOUBLE NULL,
    `Housing_Longitude` DOUBLE NULL,
    `Price_Sale` INT UNSIGNED NOT NULL DEFAULT 0,
    `Sale_Reservation` INT UNSIGNED NULL,
    `Sale_Contact` FLOAT(6,2) NULL,
    `Sale_Transfer_Fee` FLOAT(6,2) NULL,
    `Sale_with_Tenant` BOOLEAN NOT NULL DEFAULT 0,
    `Price_Rent` INT UNSIGNED NOT NULL DEFAULT 0,
    `Min_Rental_Contract` ENUM('3','6','12','1','2','4','5','7','8','9','10','11') NULL,
    `Rent_Deposit` ENUM('0','1','2','3','4','5','6','7','8','9','10','11','12') NULL,
    `Advance_Payment` ENUM('0','1','2','3','4','5','6','7','8','9','10','11','12') NULL,
    `Housing_TotalRai` FLOAT(10,5) NOT NULL,
    `Housing_Usable_Area` FLOAT(10,5) NOT NULL,
    `Floor` ENUM('1','2','2.5','3','3.5','4','4.5','5','6+') NULL,
    `Bedroom` ENUM('1','2','3','4','5+') NOT NULL,
    `Bathroom` ENUM('1','2','3','4','5+') NOT NULL,
    `Parking_Amount` ENUM('0','1','2','3','4','5+') NULL,
    `Direction` ENUM('หันหน้าทิศเหนือ','หันหน้าทิศใต้','หันหน้าทิศตะวันตก','หันหน้าทิศตะวันออก','หันหน้าทิศตะวันตกเฉียงเหนือ','หันหน้าทิศตะวันตกเฉียงใต้','หันหน้าทิศตะวันออกเฉียงเหนือ','หันหน้าทิศตะวันออกเฉียงใต้') NULL,
    `Furnish` ENUM('Bareshell','Non Furnished','Fully Fitted','Fully Furnished') NULL,
    `Move_In` ENUM('พร้อมให้เข้าอยู่', 'ภายใน 1 - 3 เดือน') NULL,
    `Title_TH` TEXT NULL,
    `Title_ENG` TEXT NULL,
    `Descriptions_TH` TEXT NULL,
    `Descriptions_ENG` TEXT NULL,
    `User_ID` INT UNSIGNED NOT NULL,
    `Classified_Status` ENUM('0','1','2','3') NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Update_Insert_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Classified_ID`),
    INDEX hc_admin1 (Created_By),
    INDEX hc_admin2 (Last_Updated_By),
    INDEX hclassified_user (User_ID),
    INDEX hclassified_housing (Housing_Code),
    CONSTRAINT hc_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hc_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hclassified_user FOREIGN KEY (User_ID) REFERENCES classified_user(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_classified_image`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_classified_image` (
    `Classified_Image_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Classified_Image_Type` SMALLINT UNSIGNED NULL DEFAULT 1,
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
    INDEX hclassified_image_admin1 (Created_By),
    INDEX hclassified_image_admin2 (Last_Updated_By),
    INDEX hclassified_image_id (Classified_ID),
    CONSTRAINT hclassified_image_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hclassified_image_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hclassified_image_id FOREIGN KEY (Classified_ID) REFERENCES classified(Classified_ID))
ENGINE = InnoDB;