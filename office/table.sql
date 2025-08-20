-- -----------------------------------------------------
-- Table office_admin_and_leasing_user
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_admin_and_leasing_user (
    User_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Role_ID INT UNSIGNED NOT NULL,
    Company_Name VARCHAR(100) NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    User_FullName VARCHAR(250) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    User_User_Name VARCHAR(50) NOT NULL,
    User_Password VARCHAR(50) NOT NULL,
    Profile_Picture TEXT NULL,
    User_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    PRIMARY KEY (User_ID),
    INDEX role_idx (Role_ID),
    CONSTRAINT role FOREIGN KEY (Role_ID) REFERENCES role(Role_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_project
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_project (
    Project_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Name_TH VARCHAR(250) NOT NULL,
    Name_EN VARCHAR(250) NULL,
    Latitude DOUBLE NULL,
    Longitude DOUBLE NULL,
    Road_Name VARCHAR(250) NULL,
    Provice_ID VARCHAR(4) NULL,
    District_ID VARCHAR(4) NULL,
    SubDistrict_ID VARCHAR(11) NULL,
    Realist_DistrictID VARCHAR(20) NULL,
    Realist_SubDistrictID VARCHAR(10) NULL,
    Land_Rai FLOAT NULL,
    Land_Ngan FLOAT NULL,
    Land_Wa FLOAT NULL,
    Land_ToTal FLOAT NULL,
    Total_Lettable_Area FLOAT NULL,
    Parking_Amount INT UNSIGNED NULL,
    User_ID INT UNSIGNED NOT NULL,
    Project_Status ENUM('0', '1', '2', '3') NOT NULL DEFAULT '0',
    Project_Redirect INT UNSIGNED NULL,
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Project_ID),
    INDEX proj_user (User_ID),
    INDEX proj_lat (Latitude),
    INDEX proj_long (Longitude),
    INDEX proj_provice (Provice_ID),
    INDEX proj_district (District_ID),
    INDEX proj_subdistrict (SubDistrict_ID),
    INDEX proj_yarnmain (Realist_DistrictID),
    INDEX proj_yarnsub (Realist_SubDistrictID),
    INDEX proj_admin1 (Created_By),
    INDEX proj_admin2 (Last_Updated_By),
    CONSTRAINT proj_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT proj_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT proj_user FOREIGN KEY (User_ID) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_building
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_building (
    Building_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Building_Name VARCHAR(250) NOT NULL,
    Project_ID INT UNSIGNED NOT NULL,
    Office_Condo TINYINT NOT NULL,
    Rent_Price_Min INT UNSIGNED NOT NULL,
    Rent_Price_Max INT UNSIGNED NULL,
    Building_latitude DOUBLE NULL,
    Building_Longitude DOUBLE NULL,
    Floor FLOAT NOT NULL,
    Landlord ENUM('Single', 'Multiple') NULL,
    Management VARCHAR(250) NULL,
    Built_Start DATE NULL,
    Last_Renovate DATE NULL,
    Ceiling ENUM('Average', 'Standard') NULL,
    Total_Building_Area FLOAT NULL,
    Lettable_Area FLOAT NULL,
    Typical_Floor_Plate SMALLINT UNSIGNED NULL,
    Unit_Size_Min FLOAT(8,3) NOT NULL,
    Unit_Size_Max FLOAT(8,3) NULL,
    Parking_Ratio VARCHAR(20) NULL,
    Parking_Fee_Car INT UNSIGNED NULL,
    Total_Lift SMALLINT UNSIGNED NULL,
    Passenger_Lift SMALLINT UNSIGNED NULL,
    Parking_Lift SMALLINT UNSIGNED NULL,
    VIP_Lift SMALLINT UNSIGNED NULL,
    Service_Lift SMALLINT UNSIGNED NULL,
    Retail_Lift SMALLINT UNSIGNED NULL,
    AC_System ENUM('a', 'b') NULL,
    ACTime_Start TIME NULL,
    ACTime_End TIME NULL,
    Bills_Electricity FLOAT NULL,
    Bills_Water FLOAT NULL,
    Phone_Line_Fee FLOAT NULL,
    Internet_Line_Fee FLOAT NULL,
    Fiber_Obtic_Line_Fee FLOAT NULL,
    Line_Deposit FLOAT NULL,
    Rent_Term SMALLINT UNSIGNED NULL,
    Rent_Deposit SMALLINT UNSIGNED NULL,
    Rent_Advance SMALLINT UNSIGNED NULL,
    User_ID INT UNSIGNED NOT NULL,
    Building_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Building_ID),
    INDEX build_proj (Project_ID),
    INDEX build_user (User_ID),
    INDEX build_admin1 (Created_By),
    INDEX build_admin2 (Last_Updated_By),
    CONSTRAINT proj FOREIGN KEY (Project_ID) REFERENCES office_project(Project_ID),
    CONSTRAINT user FOREIGN KEY (User_ID) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT build_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT build_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_unit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_unit (
    Unit_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Building_ID INT UNSIGNED NOT NULL,
    Unit_NO VARCHAR(50) NOT NULL,
    Rent_Price INT UNSIGNED NOT NULL,
    Unit_Size FLOAT NOT NULL,
    Furnish ENUM('Standard', 'Bareshell', 'Ready to Move-in') NULL,
    Floor VARCHAR(20) NULL,
    Direction ENUM('North','South','East','West','Northeast','Northwest','Southeast','Southwest','Eastnorth','Eastsouth','Westnorth','Westsouth') NULL,
    Ceiling FLOAT NULL,
    Bathroom_InUnit TINYINT NULL,
    Plumbing TINYINT NULL,
    Rent_Term SMALLINT UNSIGNED NULL,
    Rent_Deposit SMALLINT UNSIGNED NULL,
    Rent_Advance SMALLINT UNSIGNED NULL,
    Available TIMESTAMP NOT NULL,
    User_ID INT UNSIGNED NOT NULL,
    Unit_Status ENUM('0', '1', '2', '3') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Unit_ID),
    INDEX unit_building (Building_ID),
    INDEX unit_user (User_ID),
    INDEX unit_admin1 (Created_By),
    INDEX unit_admin2 (Last_Updated_By),
    CONSTRAINT unit_building FOREIGN KEY (Building_ID) REFERENCES office_building(Building_ID),
    CONSTRAINT unit_user FOREIGN KEY (User_ID) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_image_category
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_image_category (
    Category_ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    Category_Name VARCHAR(100) NOT NULL,
    Project_or_Building ENUM('Project', 'Building') NOT NULL,
    Section ENUM('Exterior', 'Interior', 'Amentiles') NOT NULL,
    Ref_ID INT UNSIGNED NOT NULL,
    Display_Order SMALLINT UNSIGNED NOT NULL,
    Category_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Category_ID),
    INDEX office_image_cate_proj (Ref_ID),
    INDEX office_image_cate_admin1 (Created_By),
    INDEX office_image_cate_admin2 (Last_Updated_By),
    CONSTRAINT office_image_cate_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT office_image_cate_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_image
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_image (
    Image_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Category_ID SMALLINT UNSIGNED NOT NULL,
    Image_Name VARCHAR(100) NULL,
    Image_URL VARCHAR(100) NOT NULL,
    Display_Order SMALLINT UNSIGNED NOT NULL,
    Image_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Image_ID),
    INDEX img_cate (Category_ID),
    INDEX img_admin1 (Created_By),
    INDEX img_admin2 (Last_Updated_By),
    CONSTRAINT img_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT img_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT img_cate FOREIGN KEY (Category_ID) REFERENCES office_image_category(Category_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_around_station
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_around_station (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Station_Code VARCHAR(50) NOT NULL,
    Station_THName_Display VARCHAR(200) NOT NULL,
    Route_Code VARCHAR(30) NOT NULL,
    Line_Code VARCHAR(30) NOT NULL,
    Project_ID INT UNSIGNED NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID),
    INDEX station_proj (Project_ID),
    CONSTRAINT station_proj FOREIGN KEY (Project_ID) REFERENCES office_project (Project_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table tenant_user
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tenant_user (
    Tenant_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    First_Name VARCHAR(100) NOT NULL,
    Last_Name VARCHAR(100) NOT NULL,
    Company_Name VARCHAR(100) NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Profile_Picture TEXT NULL,
    Normal_Search_Remaining SMALLINT UNSIGNED NOT NULL DEFAULT 5,
    Premium_Search_Remaining SMALLINT NOT NULL DEFAULT 0,
    Member_Status ENUM('Normal', 'Premium') NOT NULL DEFAULT 'Normal',
    User_Status ENUM('1', '2') NOT NULL DEFAULT '1',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Tenant_ID),
    INDEX tenant_admin1 (Created_By),
    INDEX tenant_admin2 (Last_Updated_By),
    CONSTRAINT tenant_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT tenant_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table tenant_document
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tenant_document (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Tenant_ID INT UNSIGNED NOT NULL,
    Doc_Type ENUM('a', 'b', 'c') NOT NULL,
    Doc_Status ENUM('1', '2') NOT NULL DEFAULT '1',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    INDEX tenant_doc (Tenant_ID),
    INDEX tenant_doc_admin1 (Created_By),
    INDEX tenant_doc_admin2 (Last_Updated_By),
    CONSTRAINT tenant_doc FOREIGN KEY (Tenant_ID) REFERENCES tenant_user(Tenant_ID),
    CONSTRAINT tenant_doc_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT tenant_doc_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_floor_plan
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_floor_plan (
    Floor_Plan_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Floor_Name VARCHAR(100) NOT NULL,
    Building_ID INT UNSIGNED NOT NULL,
    Floor_Plan_Image VARCHAR(100) NOT NULL,
    Floor_Plan_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Floor_Plan_ID),
    INDEX floor_plan_build (Building_ID),
    INDEX floor_plan_admin1 (Created_By),
    INDEX floor_plan_admin2 (Last_Updated_By),
    CONSTRAINT floor_plan_build FOREIGN KEY (Building_ID) REFERENCES office_building(Building_ID),
    CONSTRAINT floor_plan_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT floor_plan_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_unit_image_category
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_unit_image_category (
    Unit_Category_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Category_Name VARCHAR(100) NOT NULL,
    Section ENUM('Interior') NOT NULL,
    Unit_ID INT UNSIGNED NOT NULL,
    Display_Order SMALLINT UNSIGNED NOT NULL,
    Category_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Unit_Category_ID),
    INDEX unit_cate (Unit_ID),
    INDEX unit_cate_admin1 (Created_By),
    INDEX unit_cate_admin2 (Last_Updated_By),
    CONSTRAINT unit_cate FOREIGN KEY (Unit_ID) REFERENCES office_unit(Unit_ID),
    CONSTRAINT unit_cate_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_cate_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_unit_image
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_unit_image (
    Unit_Image_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Unit_Category_ID INT UNSIGNED NOT NULL,
    Image_Name VARCHAR(100) NULL,
    Image_Url TEXT NOT NULL,
    Display_Order SMALLINT UNSIGNED NOT NULL,
    Image_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Unit_Image_ID),
    INDEX unit_img (Unit_Category_ID),
    INDEX unit_img_admin1 (Created_By),
    INDEX unit_img_admin2 (Last_Updated_By),
    CONSTRAINT unit_img FOREIGN KEY (Unit_Category_ID) REFERENCES office_unit_image_category (Unit_Category_ID),
    CONSTRAINT unit_img_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_img_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_features
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_features (
    Features_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Feature_Name VARCHAR(100) NOT NULL,
    Category ENUM('Security', 'Common', 'Retails', 'Food', 'Services', 'Others') NOT NULL,
    Feature_Icon TEXT NULL,
    Feature_Order SMALLINT UNSIGNED NOT NULL,
    Feature_Status ENUM('0', '1', '2') NULL,
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Features_ID),
    INDEX feat_admin1 (Created_By),
    INDEX feat_admin2 (Last_Updated_By),
    CONSTRAINT feat_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT feat_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_features_relationship
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_features_relationship (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Building_or_Unit ENUM('Building', 'Unit') NOT NULL,
    Ref_ID INT UNSIGNED NOT NULL,
    Features_ID INT UNSIGNED NOT NULL,
    Relationship_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    INDEX rela_ref (Ref_ID),
    INDEX rela_feat (Features_ID),
    INDEX rela_admin1 (Created_By),
    INDEX rela_admin2 (Last_Updated_By),
    CONSTRAINT rela_feat FOREIGN KEY (Features_ID) REFERENCES office_features(Features_ID),
    CONSTRAINT rela_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT rela_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_cover
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_cover (
    Cover_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Project_or_Building ENUM('Project', 'Building') NOT NULL,
    Ref_ID INT UNSIGNED NOT NULL,
    Cover_Size INT UNSIGNED NOT NULL,
    Cover_Url TEXT NOT NULL,
    Cover_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Cover_ID),
    INDEX cover (Ref_ID),
    INDEX cover_admin1 (Created_By),
    INDEX cover_admin2 (Last_Updated_By),
    CONSTRAINT cover_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT cover_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table tenant_user_search_input
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tenant_user_search_input (
    Search_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Tenant_ID INT UNSIGNED NOT NULL,
    input1 VARCHAR(45) NOT NULL,
    input2 VARCHAR(45) NOT NULL,
    input3 VARCHAR(45) NOT NULL,
    Search_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Search_ID),
    INDEX tenant_search (Tenant_ID),
    CONSTRAINT tenant_search FOREIGN KEY (Tenant_ID) REFERENCES tenant_user(Tenant_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table tenant_user_search_output
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tenant_user_search_output (
    Search_output_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Search_ID INT UNSIGNED NOT NULL,
    Tenant_ID INT UNSIGNED NOT NULL,
    Unit_ID INT UNSIGNED NOT NULL,
    Unit_Score FLOAT NOT NULL,
    Unit_Rank INT UNSIGNED NOT NULL,
    Search_Date DATE NOT NULL,
    To_Send_Email TINYINT NOT NULL,
    PRIMARY KEY (Search_output_ID),
    INDEX search_output (Search_ID),
    INDEX tenant_search_output (Tenant_ID),
    INDEX unit_search_output (Unit_ID),
    CONSTRAINT search_output FOREIGN KEY (Search_ID) REFERENCES tenant_user_search_input(Search_ID),
    CONSTRAINT tenant_search_output FOREIGN KEY (Tenant_ID) REFERENCES tenant_user(Tenant_ID),
    CONSTRAINT unit_search_output FOREIGN KEY (Unit_ID) REFERENCES office_unit(Unit_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_email_log
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_email_log (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Search_output_ID INT UNSIGNED NOT NULL,
    Contact_Sent ENUM('Y', 'N', 'W', 'E', 'A') NULL,
    Error_Reason TEXT NULL,
    Sent_Date DATETIME NOT NULL,
    PRIMARY KEY (ID),
    INDEX email_log (Search_output_ID),
    CONSTRAINT email_log FOREIGN KEY (Search_output_ID) REFERENCES tenant_user_search_output(Search_output_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table tenant_user_variable
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tenant_user_variable (
    Variable_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    User_ID INT UNSIGNED NOT NULL,
    weight_input1 INT NOT NULL,
    weight_input2 INT NOT NULL,
    weight_input3 INT NOT NULL,
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Variable_ID),
    INDEX user_var (User_ID),
    INDEX user_var_admin1 (Created_By),
    INDEX user_var_admin2 (Last_Updated_By),
    CONSTRAINT user_var FOREIGN KEY (User_ID) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT user_var_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT user_var_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;