-- office_admin_and_leasing_user
-- office_project
-- office_building
-- office_unit
-- office_image_category
-- office_image
-- office_around_station
-- tenant_user
-- tenant_document
-- office_floor_plan
-- office_unit_image_category
-- office_unit_image
-- office_highlight
-- office_cover
-- tenant_user_search_input
-- tenant_user_search_output
-- office_email_log
-- tenant_user_variable
-- office_building_relationship
-- office_sole_agent
-- office_project_tag
-- office_project_tag_relationship
-- office_around_express_way
-- office_contact_form
-- office_unit_highlight
-- real_place_bank
-- real_place_convenience_store


-- -----------------------------------------------------
-- Table office_admin_and_leasing_user
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_admin_and_leasing_user (
    User_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Role_ID INT NOT NULL,
    Company_Name VARCHAR(100) NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    User_FullName VARCHAR(250) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    User_User_Name VARCHAR(50) NOT NULL,
    User_Password VARCHAR(60) NOT NULL,
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
    Name_TH VARCHAR(250) NULL,
    Name_EN VARCHAR(250) NULL,
    Latitude DOUBLE NULL,
    Longitude DOUBLE NULL,
    Road_Name VARCHAR(250) NULL,
    Province_ID VARCHAR(4) NULL,
    District_ID VARCHAR(4) NULL,
    SubDistrict_ID VARCHAR(11) NULL,
    Realist_DistrictID VARCHAR(20) NULL,
    Realist_SubDistrictID VARCHAR(10) NULL,
    Land_Rai FLOAT NULL,
    Land_Ngan FLOAT NULL,
    Land_Wa FLOAT NULL,
    Land_ToTal FLOAT NULL,
    Office_Lettable_Area FLOAT NULL,
    Total_Usable_Area FLOAT NULL,
    Parking_Amount INT UNSIGNED NULL,
    Security_Type ENUM('Guard Personels', 'Keycard', 'Turnstiles', 'Face Scan', 'QR / Mobile') NULL,
    F_Common_Bathroom BOOLEAN NULL,
    F_Common_Pantry BOOLEAN NULL,
    F_Common_Garbageroom BOOLEAN NULL,
    F_Retail_Conv_Store BOOLEAN NULL,
    F_Retail_Supermarket BOOLEAN NULL,
    F_Retail_Mall_Shop BOOLEAN NULL,
    F_Food_Market BOOLEAN NULL,
    F_Food_Foodcourt BOOLEAN NULL,
    F_Food_Cafe BOOLEAN NULL,
    F_Food_Restaurant BOOLEAN NULL,
    F_Services_ATM BOOLEAN NULL,
    F_Services_Bank BOOLEAN NULL,
    F_Services_Pharma_Clinic BOOLEAN NULL,
    F_Services_Hair_Salon BOOLEAN NULL,
    F_Services_Spa_Beauty BOOLEAN NULL,
    F_Others_Gym BOOLEAN NULL,
    F_Others_Valet BOOLEAN NULL,
    F_Others_EV BOOLEAN NULL,
    F_Others_Conf_Meetingroom BOOLEAN NULL,
    Environment_Friendly TEXT NULL,
    Project_Description TEXT NULL,
    Project_URL_Tag VARCHAR(200) NULL,
    Building_Copy BOOLEAN NOT NULL,
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
    INDEX proj_province (Province_ID),
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
    Office_Condo BOOLEAN NOT NULL,
    Rent_Price_Min INT UNSIGNED NULL,
    Rent_Price_Max INT UNSIGNED NULL,
    Building_Latitude DOUBLE NULL,
    Building_Longitude DOUBLE NULL,
    Total_Building_Area FLOAT NULL,
    Lettable_Area FLOAT NULL,
    Typical_Floor_Plate_1 INT UNSIGNED NULL,
    Typical_Floor_Plate_2 INT UNSIGNED NULL,
    Typical_Floor_Plate_3 INT UNSIGNED NULL,
    Unit_Size_Min FLOAT(8,3) NULL,
    Unit_Size_Max FLOAT(8,3) NULL,
    Landlord VARCHAR(250) NULL,
    Management VARCHAR(250) NULL,
    Sole_Agent INT UNSIGNED NULL,
    Built_Complete DATE NULL,
    Last_Renovate DATE NULL,
    Floor_above FLOAT NULL,
    Floor_basement FLOAT NULL,
    Floor_office_only FLOAT NULL,
    Ceiling_Avg DECIMAL(5,2) NULL,
    Parking_Ratio VARCHAR(20) NULL,
    Parking_Fee_Car INT UNSIGNED NULL,
    Total_Lift SMALLINT UNSIGNED NULL,
    Passenger_Lift SMALLINT UNSIGNED NULL,
    Service_Lift SMALLINT UNSIGNED NULL,
    Retail_Parking_Lift SMALLINT UNSIGNED NULL,
    AC_System ENUM('Split Type', 'Water Cooled Chiller', 'Central Chilled Water VAV', 'Water Cooled Package', 'Magnatic Cooling Chiller', 'Central Chilled Water'
                    , 'Cooling Tower', 'Central Air', 'Chiller System', 'Air Cooled Package', 'Variable Air volume (VAV)', 'Variable Refrigerant Volume (VRV)'
                    , 'Central Chilled Water VRV') NULL,
    AC_Split_Type BOOLEAN NULL,
    ACTime_Start TIME NULL,
    ACTime_End TIME NULL,
    AC_OT_Weekday_by_Hour TEXT NULL,
    AC_OT_Weekday_by_Area TEXT NULL,
    AC_OT_Weekend_by_Hour TEXT NULL,
    AC_OT_Weekend_by_Area TEXT NULL,
    AC_OT_Min_Hour FLOAT NULL,
    AC_OT_Min_Baht FLOAT NULL,
    AC_OT_Average_Weekday_by_Hour FLOAT NULL,
    AC_OT_Average_Weekday_by_Area FLOAT NULL,
    AC_OT_Average_Weekend_by_Hour FLOAT NULL,
    AC_OT_Average_Weekend_by_Area FLOAT NULL,
    Bills_Electricity FLOAT NULL,
    Bills_Water FLOAT NULL,
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
    INDEX build_agent (Sole_Agent),
    INDEX build_admin1 (Created_By),
    INDEX build_admin2 (Last_Updated_By),
    CONSTRAINT proj FOREIGN KEY (Project_ID) REFERENCES office_project(Project_ID),
    CONSTRAINT user_building FOREIGN KEY (User_ID) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT agent FOREIGN KEY (Sole_Agent) REFERENCES office_sole_agent(Sole_Agent_ID),
    CONSTRAINT build_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT build_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_unit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_unit (
    Unit_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Building_ID INT UNSIGNED NOT NULL,
    Unit_NO TEXT NOT NULL,
    Rent_Price INT UNSIGNED NULL,
    Size FLOAT NULL,
    Unit_Status ENUM('0', '1', '2', '3') NOT NULL DEFAULT '0',
    Available DATE NULL,
    Furnish_Condition ENUM('As Is', 'Standard', 'Bareshell', 'Furnished') NULL,
    Combine_Divide BOOLEAN NULL,
    Min_Divide_Size FLOAT NULL,
    Floor_Zone VARCHAR(20) NULL,
    Floor VARCHAR(20) NULL,
    View_N BOOLEAN NULL,
    View_E BOOLEAN NULL,
    View_S BOOLEAN NULL,
    View_W BOOLEAN NULL,
    Ceiling_Dropped FLOAT NULL,
    Ceiling_Full_Structure FLOAT NULL,
    Column_InUnit BOOLEAN NULL,
    AC_Split_Type BOOLEAN NULL,
    Pantry_InUnit BOOLEAN NULL,
    Bathroom_InUnit TINYINT NULL,
    Rent_Term SMALLINT UNSIGNED NULL,
    Rent_Deposit SMALLINT UNSIGNED NULL,
    Rent_Advance SMALLINT UNSIGNED NULL,
    Unit_Description TEXT NULL,
    User_ID INT UNSIGNED NOT NULL,
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
    Section ENUM('Exteriors','Interiors','Facilities','Floor Plan','Retail Zones') NOT NULL,
    Display_Order SMALLINT UNSIGNED NOT NULL,
    Category_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Category_ID),
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
    Project_or_Building ENUM('Project', 'Building') NOT NULL,
    Ref_ID INT UNSIGNED NOT NULL,
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
    INDEX office_image_cate_proj (Ref_ID),
    CONSTRAINT img_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT img_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT img_cate FOREIGN KEY (Category_ID) REFERENCES office_image_category(Category_ID))
ENGINE = InnoDB;


/*-- -----------------------------------------------------
-- Table office_around_station
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_around_station (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Station_Code VARCHAR(50) NOT NULL,
    Station_THName_Display VARCHAR(200) NOT NULL,
    Route_Code VARCHAR(30) NOT NULL,
    Line_Code VARCHAR(30) NOT NULL,
    MTran_ShortName VARCHAR(100) NULL,
    Project_ID INT UNSIGNED NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID),
    INDEX station_proj (Project_ID),
    CONSTRAINT station_proj FOREIGN KEY (Project_ID) REFERENCES office_project (Project_ID))
ENGINE = InnoDB;*/


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
    Display_Order SMALLINT UNSIGNED NOT NULL,
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
    Section ENUM('Overview','Interior','Windows / View','Utilities','Floor Plan') NOT NULL,
    Display_Order SMALLINT UNSIGNED NOT NULL,
    Category_Status ENUM('0', '1', '2') NOT NULL DEFAULT '0',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Unit_Category_ID),
    INDEX unit_cate_admin1 (Created_By),
    INDEX unit_cate_admin2 (Last_Updated_By),
    CONSTRAINT unit_cate_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_cate_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_unit_image
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_unit_image (
    Unit_Image_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Unit_Category_ID INT UNSIGNED NOT NULL,
    Unit_ID INT UNSIGNED NOT NULL,
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
    INDEX unit_cate (Unit_ID),
    CONSTRAINT unit_cate FOREIGN KEY (Unit_ID) REFERENCES office_unit(Unit_ID),
    CONSTRAINT unit_img FOREIGN KEY (Unit_Category_ID) REFERENCES office_unit_image_category (Unit_Category_ID),
    CONSTRAINT unit_img_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_img_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table office_highlight
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_highlight (
    Highlight_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Highlight_Name VARCHAR(200) NOT NULL,
    Highlight_Order SMALLINT UNSIGNED NOT NULL,
    Highlight_Status ENUM('0', '1', '2') NOT NULL,
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Highlight_ID),
    INDEX feat_admin1 (Created_By),
    INDEX feat_admin2 (Last_Updated_By),
    CONSTRAINT feat_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT feat_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
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


-- -----------------------------------------------------
-- Table office_building_relationship
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_building_relationship (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Building_ID INT UNSIGNED NOT NULL,
    User_ID INT UNSIGNED NOT NULL,
    Relationship_Status ENUM('1', '2') NOT NULL DEFAULT '1',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    INDEX building_rel (Building_ID),
    INDEX user_rel (User_ID),
    INDEX building_rel_admin1 (Created_By),
    INDEX building_rel_admin2 (Last_Updated_By),
    CONSTRAINT building_rel FOREIGN KEY (Building_ID) REFERENCES office_building(Building_ID),
    CONSTRAINT user_rel FOREIGN KEY (User_ID) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT building_rel_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT building_rel_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table office_sole_agent
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_sole_agent (
    Sole_Agent_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Sole_Agent_Short_Name VARCHAR(250) NOT NULL,
    PRIMARY KEY (Sole_Agent_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table office_project_tag
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_project_tag (
    Tag_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Tag_Name TEXT NOT NULL,
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Tag_ID),
    INDEX tag_admin1 (Created_By),
    INDEX tag_admin2 (Last_Updated_By),
    CONSTRAINT tag_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT tag_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table office_project_tag_relationship
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_project_tag_relationship (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Tag_ID INT UNSIGNED NOT NULL,
    Project_ID INT UNSIGNED NOT NULL,
    Relationship_Order INT NOT NULL,
    Relationship_Status ENUM('1', '2') NOT NULL DEFAULT '1',
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    INDEX tag_re_tag (Tag_ID),
    INDEX tag_re_project (Project_ID),
    INDEX tag_re_admin1 (Created_By),
    INDEX tag_re_admin2 (Last_Updated_By),
    CONSTRAINT tag_re_tag FOREIGN KEY (Tag_ID) REFERENCES office_project_tag(Tag_ID),
    CONSTRAINT tag_re_project FOREIGN KEY (Project_ID) REFERENCES office_project(Project_ID),
    CONSTRAINT tag_re_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT tag_re_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;

/*-- -----------------------------------------------------
-- Table office_around_express_way
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_around_express_way (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Place_ID INT UNSIGNED NOT NULL,
    Place_Type VARCHAR(80) NOT NULL,
    Place_Category VARCHAR(150) NOT NULL,
    Place_Name VARCHAR(100) NOT NULL,
    Place_Latitude double NOT NULL,
    Place_Longitude double NOT NULL,
    Project_ID INT UNSIGNED NOT NULL,
    Distance FLOAT NOT NULL,
    PRIMARY KEY (ID),
    INDEX express_proj (Project_ID),
    CONSTRAINT express_proj FOREIGN KEY (Project_ID) REFERENCES office_project (Project_ID))
ENGINE = InnoDB;*/

-- -----------------------------------------------------
-- Table mass_transit_bus_stop
-- -----------------------------------------------------
/*CREATE TABLE IF NOT EXISTS mass_transit_bus_stop (
    Bus_Stop_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Bus_Stop_Name_TH VARCHAR(250) NOT NULL,
    Bus_Stop_Name_EN VARCHAR(250) NOT NULL,
    Bus_Stop_Latitude DOUBLE NOT NULL,
    Bus_Stop_Longitude DOUBLE NOT NULL,
    PRIMARY KEY (Bus_Stop_ID),
    INDEX bus_stop_lat (Bus_Stop_Latitude),
    INDEX bus_stop_long (Bus_Stop_Longitude))
ENGINE = InnoDB;*/

CREATE TABLE IF NOT EXISTS office_contact_form (
    Contact_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Contact_Name VARCHAR(50) NOT NULL,
    Contact_Tel VARCHAR(30) NOT NULL,
    Contact_Email VARCHAR(80) NOT NULL,
    Contact_Text TEXT NULL,
    Contact_IP VARCHAR(50) NOT NULL,
    Contact_Date DATETIME NOT NULL,
    PRIMARY KEY (Contact_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table office_unit_highlight
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS office_unit_highlight (
    Highlight_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Highlight_Name VARCHAR(200) NOT NULL,
    Highlight_Order SMALLINT UNSIGNED NOT NULL,
    Highlight_Status ENUM('0', '1', '2') NOT NULL,
    Created_By INT UNSIGNED NOT NULL DEFAULT 0,
    Created_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NOT NULL DEFAULT 0,
    Last_Updated_Date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Highlight_ID),
    INDEX unit_feat_admin1 (Created_By),
    INDEX unit_feat_admin2 (Last_Updated_By),
    CONSTRAINT unit_feat_admin1 FOREIGN KEY (Created_By) REFERENCES office_admin_and_leasing_user(User_ID),
    CONSTRAINT unit_feat_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES office_admin_and_leasing_user(User_ID))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table real_place_bank
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS real_place_bank (
    Bank_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Bank_Name_TH VARCHAR(250) NOT NULL,
    Bank_Name_EN VARCHAR(250) NOT NULL,
    Branch_Name VARCHAR(250) NOT NULL,
    Place_Latitude DOUBLE NOT NULL,
    Place_Longitude DOUBLE NOT NULL,
    PRIMARY KEY (Bank_ID),
    INDEX bank_lat (Place_Latitude),
    INDEX bank_long (Place_Longitude))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table real_place_convenience_store
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS real_place_convenience_store (
    Store_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Store_Type VARCHAR(250) NOT NULL,
    Branch_Name VARCHAR(250) NOT NULL,
    Place_Latitude DOUBLE NOT NULL,
    Place_Longitude DOUBLE NOT NULL,
    PRIMARY KEY (Store_ID),
    INDEX store_lat (Place_Latitude),
    INDEX store_long (Place_Longitude))
ENGINE = InnoDB;