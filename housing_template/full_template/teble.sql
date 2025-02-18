-- Table `housing_full_template_section`
-- Table `housing_full_template_category`
-- Table `housing_full_template_housing_type`
-- Table `housing_full_template_element`
-- Table `housing_full_template_image`
-- Table `housing_full_template_floor_plan`
-- Table `housing_full_template_master_plan`
-- Table `housing_full_template_vector`
-- Table `housing_full_template_vector_master_plan_relationship`
-- Table `housing_full_template_360`

-- -----------------------------------------------------
-- Table `housing_full_template_section`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_section` (
    `Section_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Section_Name` VARCHAR(50) NOT NULL,
    `Section_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Section_ID`),
    INDEX section_admin1 (Created_By),
    INDEX section_admin2 (Last_Updated_By),
    CONSTRAINT section_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT section_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_category` (
    `Category_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Category_Name` VARCHAR(100) NOT NULL,
    `Section_ID` SMALLINT UNSIGNED NOT NULL,
    `Category_Show_Faci` SMALLINT UNSIGNED NULL,
    `Category_Icon` VARCHAR(250) NULL,
    `Category_Order` SMALLINT UNSIGNED NULL,
    `Show_Faci_order` INT UNSIGNED NULL,
    `Long_Text` TEXT NULL,
    `Category_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Category_ID`),
    INDEX `Section_idx` (`Section_ID`),
    INDEX h_cate_admin1 (Created_By),
    INDEX h_cate_admin2 (Last_Updated_By),
    CONSTRAINT h_cate_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_cate_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_cate_section FOREIGN KEY (Section_ID) REFERENCES housing_full_template_section (Section_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_housing_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_housing_type` (
    `Housing_Type_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Housing_Type_Name` VARCHAR(100) NULL,
    `Housing_Category` ENUM('บ้านเดี่ยว','บ้านแฝด','ทาวน์โฮม','โฮมออฟฟิศ','อาคารพาณิชย์') NOT NULL,
    `Total_Unit` INT UNSIGNED NULL,
    `Price_Min` INT UNSIGNED NULL,
    `Price_Max` INT UNSIGNED NULL,
    `Price_Date` DATE NULL,
    `Housing_Area_Min` FLOAT(10,5) NULL,
    `Housing_Area_Max` FLOAT(10,5) NULL,
    `Housing_Usable_Area` FLOAT(10,5) NULL,
    `Parking` INT UNSIGNED NULL,
    `Floor` FLOAT(2,1) UNSIGNED NULL,
    `Bedroom` INT UNSIGNED NULL,
    `Bathroom` INT UNSIGNED NULL,
    `Foyer` BOOLEAN NOT NULL DEFAULT False,
    `Multi_Purposed` INT UNSIGNED NULL,
    `Pool` BOOLEAN NOT NULL DEFAULT False,
    `Pool_System` ENUM('เกลือ','Hydrotherapy','คลอรีน','UV','น้ำแร่') NULL,
    `Pool_Width` FLOAT NULL,
    `Pool_Length` FLOAT NULL,
    `Double_Volume` BOOLEAN NOT NULL DEFAULT FALSE,
    `Powder_Room` INT UNSIGNED NULL,
    `Lift` BOOLEAN NOT NULL DEFAULT FALSE,
    `Thai_Kitchen` BOOLEAN NOT NULL DEFAULT FALSE,
    `Shoes_Storage_Room` BOOLEAN NOT NULL DEFAULT FALSE,
    `Storage_Room` BOOLEAN NOT NULL DEFAULT FALSE,
    `Laundry_Room` INT UNSIGNED NULL,
    `Maid_Room` INT UNSIGNED NULL,
    `Digital_Door_Lock` BOOLEAN NOT NULL DEFAULT FALSE,
    `Home_Automation` BOOLEAN NOT NULL DEFAULT FALSE,
    `Air_Ventilation` BOOLEAN NOT NULL DEFAULT FALSE,
    `Solar_Cell` BOOLEAN NOT NULL DEFAULT FALSE,
    `CCTV` BOOLEAN NOT NULL DEFAULT FALSE,
    `EV_Charge_Place` BOOLEAN NOT NULL DEFAULT FALSE,
    `EV_Charge` BOOLEAN NOT NULL DEFAULT FALSE,
    `Housing_Type_Image_Horizontal` VARCHAR(100) NULL,
    `Housing_Type_Image_Square` VARCHAR(100) NULL,
    `Housing_Type_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Housing_Type_ID`),
    INDEX h_type_admin1 (Created_By),
    INDEX h_type_admin2 (Last_Updated_By),
    INDEX h_type_housing (`Housing_Code`),
    CONSTRAINT h_type_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_type_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_type_housing FOREIGN KEY (`Housing_Code`) REFERENCES `housing` (`Housing_Code`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_element`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_element` (
    `Element_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Element_Name` VARCHAR(100) NOT NULL,
    `Category_ID` SMALLINT UNSIGNED NOT NULL,
    `Housing_Code` VARCHAR(50) NOT NULL,
    `Housing_Type_ID` INT UNSIGNED NULL,
    `Long_Text` TEXT NULL,
    `Display_Order_in_Section` SMALLINT UNSIGNED NULL,
    `Element_Status` SMALLINT UNSIGNED NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Element_ID`),
    INDEX ele_admin1 (Created_By),
    INDEX ele_admin2 (Last_Updated_By),
    INDEX ele_cate (Category_ID),
    INDEX ele_housing (Housing_Code),
    INDEX ele_name (Element_Name),
    INDEX ele_order (Display_Order_in_Section),
    INDEX ele_type (Housing_Type_ID),
    CONSTRAINT ele_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT ele_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT ele_cate FOREIGN KEY (Category_ID) REFERENCES housing_full_template_category(Category_ID),
    CONSTRAINT ele_type FOREIGN KEY (Housing_Type_ID) REFERENCES housing_full_template_housing_type(Housing_Type_ID),
    CONSTRAINT ele_housing FOREIGN KEY (Housing_Code) REFERENCES housing(Housing_Code))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_image`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_image` (
    `Image_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Image_Caption` VARCHAR(100) NULL,
    `Image_URL` VARCHAR(100) NULL,
    `Date_Taken` TIMESTAMP NULL,
    `Display_Order_in_Element` SMALLINT UNSIGNED NOT NULL,
    `Element_ID` INT UNSIGNED NOT NULL,
    `Image_Type_ID` SMALLINT UNSIGNED NOT NULL,
    `Image_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Image_ID`),
    INDEX h_image_admin1 (Created_By),
    INDEX h_image_admin2 (Last_Updated_By),
    INDEX h_image_element (`Element_ID`),
    INDEX h_image_image_type (`Image_Type_ID`),
    INDEX h_image_caption (`Image_Caption`),
    INDEX h_image_url (`Image_URL`),
    INDEX h_image_order (`Display_Order_in_Element`),
    CONSTRAINT h_image_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_image_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_image_element FOREIGN KEY (`Element_ID`) REFERENCES `housing_full_template_element` (`Element_ID`),
    CONSTRAINT h_image_image_type FOREIGN KEY (`Image_Type_ID`) REFERENCES `full_template_image_type` (`Image_Type_ID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_floor_plan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_floor_plan` (
    `Floor_Plan_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Floor_Plan_Name` VARCHAR(100)  NOT NULL,
    `Floor_Plan_Order` SMALLINT UNSIGNED NOT NULL,
    `Housing_Type_ID` INT UNSIGNED NOT NULL,
    `Floor_Plan_Image` VARCHAR(100) NOT NULL,
    `Floor_Plan_Status` SMALLINT NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Floor_Plan_ID`),
    INDEX fplan_admin1 (Created_By),
    INDEX fplan_admin2 (Last_Updated_By),
    INDEX fplan_type (`Housing_Type_ID`),
    CONSTRAINT `fplan_type` FOREIGN KEY (`Housing_Type_ID`) REFERENCES `housing_full_template_housing_type` (`Housing_Type_ID`),
    CONSTRAINT fplan_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT fplan_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_master_plan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_master_plan` (
    `Master_Plan_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` VARCHAR(50) NULL,
    `Master_Plan_Image` VARCHAR(100) NOT NULL,
    `Master_Plan_Status` SMALLINT NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Master_Plan_ID`),
    INDEX m_plan_admin1 (Created_By),
    INDEX m_plan_admin2 (Last_Updated_By),
    INDEX m_plan_housing (`Housing_Code`),
    CONSTRAINT `m_plan_housing` FOREIGN KEY (`Housing_Code`) REFERENCES `housing` (`Housing_Code`),
    CONSTRAINT m_plan_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT m_plan_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_vector`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_vector` (
    `Vector_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Master_Plan_ID` INT UNSIGNED NOT NULL,
    `Polygon` TEXT NOT NULL,
    `Vector_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Vector_ID`),
    INDEX hv_admin1 (Created_By),
    INDEX hv_admin2 (Last_Updated_By),
    INDEX hv_master_plan (Master_Plan_ID),
    CONSTRAINT hv_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hv_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hv_master_plan FOREIGN KEY (Master_Plan_ID) REFERENCES housing_full_template_master_plan(Master_Plan_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_vector_master_plan_relationship`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_vector_master_plan_relationship` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Vector_ID` INT UNSIGNED NOT NULL,
    `Ref_Type` SMALLINT UNSIGNED NOT NULL,
    `Ref_ID` INT UNSIGNED NOT NULL,
    `Relationship_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX hre_admin1 (Created_By),
    INDEX hre_admin2 (Last_Updated_By),
    INDEX hre_vector (Vector_ID),
    INDEX hre_ref (Ref_ID),
    CONSTRAINT hre_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hre_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT hre_vector FOREIGN KEY (Vector_ID) REFERENCES housing_full_template_vector(Vector_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `housing_full_template_360`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `housing_full_template_360` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Project_360_Name` TEXT NOT NULL,
    `Project_360_Link` TEXT NOT NULL,
    `Housing_Code` VARCHAR(50) NULL,
    `Housing_Type_ID` INT UNSIGNED NULL,
    `Project_360_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX p360_admin1 (Created_By),
    INDEX p360_admin2 (Last_Updated_By),
    INDEX p360_house (Housing_Code),
    INDEX p360_type (Housing_Type_ID),
    CONSTRAINT p360_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT p360_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT p360_house FOREIGN KEY (Housing_Code) REFERENCES housing(Housing_Code),
    CONSTRAINT p360_type FOREIGN KEY (Housing_Type_ID) REFERENCES housing_full_template_housing_type(Housing_Type_ID))
ENGINE = InnoDB;