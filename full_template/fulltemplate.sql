-- -----------------------------------------------------
-- Table `full_template_section`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_section` (
  `Section_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Section_Name` VARCHAR(50) NOT NULL,
  Section_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Section_ID`),
  INDEX uadmin1 (Created_By),
  INDEX uadmin2 (Last_Updated_By),
  CONSTRAINT uadmin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT uadmin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_floor_plan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_floor_plan` (
  `Floor_Plan_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  Floor_Plan_Order FLOAT UNSIGNED NOT NULL,
  `Floor_Plan_Name` VARCHAR(50) NOT NULL,
  `Floor_Plan_Image` VARCHAR(100) NOT NULL,
  Master_Plan BOOLEAN NOT NULL DEFAULT FALSE,
  Condo_Code VARCHAR(50) NOT NULL,
  Floor_Plan_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Floor_Plan_ID`),
  INDEX floor_plan_admin1 (Created_By),
  INDEX floor_plan_admin2 (Last_Updated_By),
  CONSTRAINT floor_plan_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT floor_plan_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_building`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_building` (
  `Building_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Building_Name` VARCHAR(20) NOT NULL,
  `Building_Order` SMALLINT UNSIGNED NOT NULL,
  `Condo_Code` VARCHAR(50) NOT NULL,
  `Building_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Building_ID`),
  INDEX building_admin1 (Created_By),
  INDEX building_admin2 (Last_Updated_By),
  CONSTRAINT building_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT building_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID)) 
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_category` (
  `Category_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Category_Name` VARCHAR(100) NOT NULL,
  `Section_ID` SMALLINT UNSIGNED NOT NULL,
  `Category_Icon` VARCHAR(250) NULL DEFAULT NULL,
  `Category_Order` SMALLINT UNSIGNED NULL DEFAULT NULL,
  Category_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_by` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Category_ID`),
  INDEX category_admin1 (Created_By),
  INDEX category_admin2 (Last_Updated_By),
  INDEX category_section (Section_ID),
  CONSTRAINT category_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT category_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
  CONSTRAINT category_section FOREIGN KEY (Section_ID) REFERENCES full_template_section(Section_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_set`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_set` (
  `Set_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Set_Name` VARCHAR(100) NOT NULL,
  Set_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Display_Order_in_Condo` SMALLINT UNSIGNED NOT NULL,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Set_ID`),
  INDEX set_admin1 (Created_By),
  INDEX set_admin2 (Last_Updated_By),
  CONSTRAINT set_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT set_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_element`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_element` (
  `Element_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Element_Name` VARCHAR(100) NOT NULL,
  `Category_ID` SMALLINT UNSIGNED NOT NULL,
  `Condo_Code` VARCHAR(50) NOT NULL,
  `Long_Text` TEXT NULL DEFAULT NULL,
  `Display_Order_in_Section` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `Set_ID` INT UNSIGNED NULL DEFAULT NULL,
  Element_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Element_ID`),
  INDEX element_category1 (Category_ID),
  INDEX element_set1 (Set_ID),
  INDEX element_admin1 (Created_By),
  INDEX element_admin2 (Last_Updated_By),
  CONSTRAINT element_category1 FOREIGN KEY (Category_ID) REFERENCES full_template_category(Category_ID),
  CONSTRAINT element_set1 FOREIGN KEY (Set_ID) REFERENCES full_template_set(Set_ID),
  CONSTRAINT element_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT element_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_credit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_credit` (
  `Credit_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Credit_Name` VARCHAR(50) NOT NULL,
  `Credit_Logo` VARCHAR(250) NOT NULL,
  Credit_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Credit_ID`),
  INDEX credit_admin1 (Created_By),
  INDEX credit_admin2 (Last_Updated_By),
  CONSTRAINT credit_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT credit_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_image_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_image_type` (
  `Image_Type_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Image_Type_Name` VARCHAR(100) NULL DEFAULT NULL,
  `Image_Type_Displayed_Order` SMALLINT NOT NULL,
  `Image_Type_Status` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Image_Type_ID`),
  INDEX image_type_admin1 (Created_By),
  INDEX image_type_admin2 (Last_Updated_By),
  CONSTRAINT image_type_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT image_type_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_image`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_image` (
  `Image_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Image_Caption` VARCHAR(100) NULL DEFAULT NULL,
  `Image_URL` VARCHAR(100) NOT NULL,
  `Date_Taken` TIMESTAMP NULL DEFAULT NULL,
  `Display_Order_in_Element` SMALLINT UNSIGNED NOT NULL,
  `Element_ID` INT UNSIGNED NOT NULL,
  `Image_Type_ID` SMALLINT UNSIGNED NOT NULL,
  Image_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Image_ID`),
  INDEX image_admin1 (Created_By),
  INDEX image_admin2 (Last_Updated_By),
  INDEX image_element (Element_ID),
  INDEX image_image_type (Image_Type_ID),
  CONSTRAINT image_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT image_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
  CONSTRAINT image_element FOREIGN KEY (Element_ID) REFERENCES full_template_element(Element_ID),
  CONSTRAINT image_image_type FOREIGN KEY (Image_Type_ID) REFERENCES full_template_image_type(Image_Type_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_credit_url_condo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_credit_url_condo` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Condo_Code` VARCHAR(50) NOT NULL,
  `Credit_ID` SMALLINT UNSIGNED NOT NULL,
  `Credit_URL` TEXT NOT NULL,
  `Credit_Order` SMALLINT UNSIGNED NOT NULL,
  Credit_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  INDEX credit_url_admin1 (Created_By),
  INDEX credit_url_admin2 (Last_Updated_By),
  INDEX credit_url_credit1 (Credit_ID),
  CONSTRAINT credit_url_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT credit_url_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
  CONSTRAINT credit_url_credit1 FOREIGN KEY (Credit_ID) REFERENCES full_template_credit(Credit_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_room_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_room_type` (
  `Room_Type_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Room_Type_Name` VARCHAR(50) NOT NULL,
  Room_Type_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Late_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Room_Type_ID`),
  INDEX room_type_admin1 (Created_By),
  INDEX room_type_admin2 (Last_Updated_By),
  CONSTRAINT room_type_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT room_type_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_unit_floor_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_floor_type` (
  `Unit_Floor_Type_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Unit_Floor_Type_Name` VARCHAR(50) NOT NULL,
  Unit_Floor_Type_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Late_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Unit_Floor_Type_ID`),
  INDEX unit_floor_type_admin1 (Created_By),
  INDEX unit_floor_type_admin2 (Last_Updated_By),
  CONSTRAINT unit_floor_type_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT unit_floor_type_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_unit_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_unit_type` (
  `Unit_Type_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Unit_Type_Name` VARCHAR(100) NULL DEFAULT NULL,
  `Room_Type_ID` SMALLINT UNSIGNED NOT NULL,
  Room_Plus BOOLEAN NOT NULL DEFAULT FALSE,
  `Unit_Type_Image` VARCHAR(100) NULL DEFAULT NULL,
  BathRoom SMALLINT UNSIGNED NULL DEFAULT NULL,
  Unit_Floor_Type_ID SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  MaidRoom BOOLEAN NOT NULL DEFAULT FALSE,
  `Size` FLOAT(8,3) UNSIGNED NULL DEFAULT NULL,
  `Unit_Type_Floor` VARCHAR(20) NULL DEFAULT NULL,
  `Condo_Code` VARCHAR(50) NOT NULL,
  Unit_Type_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Unit_Type_ID`),
  INDEX unit_type_admin1 (Created_By),
  INDEX unit_type_admin2 (Last_Updated_By),
  INDEX unit_type_room_type (Room_Type_ID),
  INDEX unit_type_unit_floor_type (Unit_Floor_Type_ID),
  CONSTRAINT unit_type_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT unit_type_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
  CONSTRAINT unit_type_room_type FOREIGN KEY (Room_Type_ID) REFERENCES full_template_room_type(Room_Type_ID),
  CONSTRAINT unit_type_unit_floor_type FOREIGN KEY (Unit_Floor_Type_ID) REFERENCES full_template_unit_floor_type(Unit_Floor_Type_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_set_unit_type_relationship`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_set_unit_type_relationship` (
  `ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Set_ID` INT UNSIGNED NOT NULL,
  `Unit_Type_ID` INT UNSIGNED NOT NULL,
  Relationship_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`),
  INDEX unit_type_relationship1 (Set_ID),
  INDEX unit_type_relationship2 (Unit_Type_ID),
  CONSTRAINT unit_type_relationship1 FOREIGN KEY (Set_ID) REFERENCES full_template_set(Set_ID),
  CONSTRAINT unit_type_relationship2 FOREIGN KEY (Unit_Type_ID) REFERENCES full_template_unit_type(Unit_Type_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_floor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_floor` (
  `Floor_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Floor_Order` SMALLINT NOT NULL,
  `Floor_Displayed_Name` VARCHAR(20) NOT NULL,
  `Floor_Plan_ID` INT UNSIGNED NULL DEFAULT NULL,
  Building_ID INT UNSIGNED NULL DEFAULT NULL,
  Floor_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Floor_ID`),
  INDEX floor_admin1 (Created_By),
  INDEX floor_admin2 (Last_Updated_By),
  INDEX floor_floor_plan (Floor_Plan_ID),
  INDEX floor_building (Building_ID),
  CONSTRAINT floor_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT floor_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
  CONSTRAINT floor_floor_plan FOREIGN KEY (Floor_Plan_ID) REFERENCES full_template_floor_plan(Floor_Plan_ID),
  CONSTRAINT floor_building FOREIGN KEY (Building_ID) REFERENCES full_template_building(Building_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `full_template_vector_floor_plan_relationship`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_vector_floor_plan_relationship` (
  `Vector_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Vector_Type` SMALLINT UNSIGNED NOT NULL,
  `Ref_ID` INT UNSIGNED NOT NULL,
  `Floor_Plan_ID` INT UNSIGNED NOT NULL,
  `Polygon` TEXT NOT NULL,
  Relationship_Status SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `Last_Updated_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Vector_ID`),
  INDEX vector_admin1 (Created_By),
  INDEX vector_admin2 (Last_Updated_By),
  INDEX vector_floor_plan (Floor_Plan_ID),
  INDEX vector_unit_type (Ref_ID),
  INDEX vector_element (Ref_ID),
  INDEX vector_building (Ref_ID),
  CONSTRAINT vector_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
  CONSTRAINT vector_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
  CONSTRAINT vector_floor_plan FOREIGN KEY (Floor_Plan_ID) REFERENCES full_template_floor_plan(Floor_Plan_ID))
ENGINE = InnoDB;