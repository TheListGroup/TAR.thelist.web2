-- สร้าง Database (หากยังไม่มี)
/*CREATE DATABASE IF NOT EXISTS architecture_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE architecture_db;*/

-- 1. ตารางหมวดหมู่โครงการ (Proj Category) 
CREATE TABLE proj_categories (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Parent_ID INT UNSIGNED NULL, -- Self-reference สำหรับหมวดหมู่ใหญ่/ย่อย
    Category_Name VARCHAR(255) NOT NULL,
    Categories_Order INT UNSIGNED NOT NULL,
    Categories_Status ENUM('0','1','2') NOT NULL,
    INDEX (Category_Name),
    INDEX (Categories_Order)
) ENGINE=InnoDB;

-- ตาราง ย่าน แขวง เขต เมือง/จังหวัด รัฐ
CREATE TABLE place_location (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Location_Type ENUM('Yarn', 'Subdistrict', 'District', 'Province', 'State') NOT NULL,
    Name_EN VARCHAR(255) NOT NULL,
    Name_TH VARCHAR(255) NULL,
    Location_Status ENUM('0','1','2') NOT NULL,
    INDEX (Name_EN),
    INDEX (Name_TH)
) ENGINE=InnoDB;

-- ตาราง ประเทศ
CREATE TABLE country (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name_EN VARCHAR(255) NOT NULL,
    Name_TH VARCHAR(255) NULL,
    Country_Status ENUM('0','1','2') NOT NULL,
    INDEX (Name_EN),
    INDEX (Name_TH)
) ENGINE=InnoDB;

-- ตาราง admin
CREATE TABLE user_admin (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Role_ID INT NULL,
    User_FullName Varchar(250) NOT NULL,
    User_Username Varchar(20) NOT NULL,
    User_Password Varchar(80) NOT NULL,
    INDEX(Role_ID),
    FOREIGN KEY (Role_ID) REFERENCES role(Role_ID)
) ENGINE=InnoDB;

-- 2. ตารางโครงการ (Proj)
CREATE TABLE projects (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name_EN VARCHAR(255) NOT NULL,
    Name_TH VARCHAR(255),
    Latitude DOUBLE,
    Longitude DOUBLE,
    Proj_Address TEXT,
    Proj_Yarn INT UNSIGNED,
    Proj_Sub_District INT UNSIGNED,
    Proj_District INT UNSIGNED,
    Proj_Province INT UNSIGNED,
    Proj_State INT UNSIGNED,
    Proj_Country INT UNSIGNED,
    Start_Date DATE,
    Finish_Date DATE,
    Renovated_Date DATE,
    Land_Rai Float,
    Land_Ngan Float,
    Land_Wa Float,
    Land_Total Float,
    Usable_Area Float,
    Commercial_Area Float,
    Brief_Description TEXT,
    Proj_URL_Tag VARCHAR(200) NULL,
    Proj_Status ENUM('0','1','2') NOT NULL,
    Created_By INT UNSIGNED NULL,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NULL,
    Last_Updated_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX(Proj_Yarn),
    INDEX(Proj_Sub_District),
    INDEX(Proj_District),
    INDEX(Proj_Province),
    INDEX(Proj_State),
    INDEX(Proj_Country),
    INDEX(Latitude),
    INDEX(Longitude),
    INDEX(Created_By),
    INDEX(Last_Updated_By),
    FOREIGN KEY (Proj_Yarn) REFERENCES place_location(ID),
    FOREIGN KEY (Proj_Sub_District) REFERENCES place_location(ID),
    FOREIGN KEY (Proj_District) REFERENCES place_location(ID),
    FOREIGN KEY (Proj_Province) REFERENCES place_location(ID),
    FOREIGN KEY (Proj_State) REFERENCES place_location(ID),
    FOREIGN KEY (Proj_Country) REFERENCES country(ID),
    FOREIGN KEY (Created_By) REFERENCES user_admin(ID),
    FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(ID)
) ENGINE=InnoDB;

-- 3. ความสัมพันธ์ Proj <-> Category (ManyToMany)
CREATE TABLE proj_category_relationship (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Proj_ID INT UNSIGNED NOT NULL,
    Category_ID INT UNSIGNED NOT NULL,
    Relationship_Order INT UNSIGNED NOT NULL,
    Relationship_Status ENUM('0','1','2') NOT NULL,
    INDEX (Proj_ID),
    INDEX (Category_ID),
    FOREIGN KEY (Proj_ID) REFERENCES projects(ID),
    FOREIGN KEY (Category_ID) REFERENCES proj_categories(ID)
) ENGINE=InnoDB;

-- 4. รูปภาพโครงการ
CREATE TABLE proj_cover (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Proj_ID INT UNSIGNED NOT NULL,
    Cover_Name VARCHAR(100),
    Image_URL TEXT NOT NULL,
    Ratio_Type ENUM('16:9', '9:16', '3:2') NOT NULL,
    Image_Status ENUM('0','1','2') NOT NULL,
    INDEX (Proj_ID),
    FOREIGN KEY (Proj_ID) REFERENCES projects(ID)
) ENGINE=InnoDB;

-- 5. ข้อมูล Prof
CREATE TABLE professionals (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Name_EN VARCHAR(255) NOT NULL,
    Name_TH VARCHAR(255),
    Latitude DOUBLE,
    Longitude DOUBLE,
    Prof_Address TEXT,
    Prof_Yarn INT UNSIGNED,
    Prof_Sub_District INT UNSIGNED,
    Prof_District INT UNSIGNED,
    Prof_Province INT UNSIGNED,
    Prof_State INT UNSIGNED,
    Prof_Country INT UNSIGNED,
    FB_Link TEXT,
    IG_Link TEXT,
    Line_Link TEXT,
    YT_Link TEXT,
    Website TEXT,
    Found_Date DATE,
    Is_Freelance BOOLEAN NOT NULL DEFAULT FALSE,
    Logo_URL TEXT,
    Brief_Description TEXT,
    Content TEXT,
    Prof_URL_Tag VARCHAR(200) NULL,
    Prof_Status ENUM('0','1','2') NOT NULL,
    Created_By INT UNSIGNED NULL,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NULL,
    Last_Updated_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX(Prof_Yarn),
    INDEX(Prof_Sub_District),
    INDEX(Prof_District),
    INDEX(Prof_Province),
    INDEX(Prof_State),
    INDEX(Prof_Country),
    INDEX(Latitude),
    INDEX(Longitude),
    INDEX(Created_By),
    INDEX(Last_Updated_By),
    FOREIGN KEY (Prof_Yarn) REFERENCES place_location(ID),
    FOREIGN KEY (Prof_Sub_District) REFERENCES place_location(ID),
    FOREIGN KEY (Prof_District) REFERENCES place_location(ID),
    FOREIGN KEY (Prof_Province) REFERENCES place_location(ID),
    FOREIGN KEY (Prof_State) REFERENCES place_location(ID),
    FOREIGN KEY (Prof_Country) REFERENCES country(ID),
    FOREIGN KEY (Created_By) REFERENCES user_admin(ID),
    FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(ID)
) ENGINE=InnoDB;

-- 6. หมวดหมู่ความรับผิดชอบ (เช่น Architect, Interior)
CREATE TABLE prof_expertise (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Parent_ID INT UNSIGNED,
    Responsibility VARCHAR(255),
    Content_Header VARCHAR(255),
    Expertise_Order INT NOT NULL,
    Expertise_Status ENUM('0','1','2') NOT NULL,
    INDEX (Responsibility),
    INDEX (Content_Header),
    INDEX (Expertise_Order)
) ENGINE=InnoDB;

-- 7. ความสัมพันธ์ Prof <-> expertise
CREATE TABLE prof_expertise_relationship (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Prof_ID INT UNSIGNED NOT NULL,
    Expertise_ID INT UNSIGNED NOT NULL,
    Relationship_Order INT,
    Relationship_Status ENUM('0','1','2') NOT NULL,
    INDEX (Prof_ID),
    INDEX (Expertise_ID),
    FOREIGN KEY (Prof_ID) REFERENCES professionals(ID),
    FOREIGN KEY (Expertise_ID) REFERENCES prof_expertise(ID)
) ENGINE=InnoDB;

-- 8. ความชำนาญตามประเภท Proj
CREATE TABLE prof_experience_relationship (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Prof_ID INT UNSIGNED NOT NULL,
    Proj_Category_ID INT UNSIGNED NOT NULL,
    Proj_Category_Status ENUM('0','1','2') NOT NULL,
    INDEX (Prof_ID),
    INDEX (Proj_Category_ID),
    FOREIGN KEY (Prof_ID) REFERENCES professionals(ID),
    FOREIGN KEY (Proj_Category_ID) REFERENCES proj_categories(ID)
) ENGINE=InnoDB;

-- 11. เจ้าของ
CREATE TABLE prof_owners (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Prof_ID INT UNSIGNED NOT NULL,
    First_Name_EN VARCHAR(255) NOT NULL,
    Last_Name_EN VARCHAR(255),
    First_Name_TH VARCHAR(255),
    Last_Name_TH VARCHAR(255),
    Owner_Status ENUM('0','1','2') NOT NULL,
    INDEX (Prof_ID),
    FOREIGN KEY (Prof_ID) REFERENCES professionals(id)
) ENGINE=InnoDB;

-- 12. รูปภาพ Prof
CREATE TABLE prof_cover (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Prof_ID INT UNSIGNED NOT NULL,
    Cover_Name VARCHAR(100),
    Image_URL TEXT NOT NULL,
    Ratio_type ENUM('16:9', '9:16') NOT NULL,
    Image_Status ENUM('0','1','2') NOT NULL,
    INDEX (Prof_ID),
    FOREIGN KEY (Prof_ID) REFERENCES professionals(ID)
) ENGINE=InnoDB;

-- 9. ทีมงานในโปรเจกต์ (เชื่อมโยง Proj กับ Prof และหน้าที่ที่ได้รับมอบหมาย)
CREATE TABLE proj_prof_relationship (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Proj_ID INT UNSIGNED NOT NULL,
    Prof_Expertise_Relationship_ID INT UNSIGNED NOT NULL,
    Content TEXT NULL,
    Relationship_Status ENUM('0','1','2') NOT NULL,
    INDEX (Proj_ID),
    INDEX (Prof_Expertise_Relationship_ID),
    FOREIGN KEY (Proj_ID) REFERENCES projects(ID),
    FOREIGN KEY (Prof_Expertise_Relationship_ID) REFERENCES prof_expertise_relationship(ID)
) ENGINE=InnoDB;

-- 4. proj gallery
CREATE TABLE proj_gallery (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Proj_Profs_Relationship_ID INT UNSIGNED NOT NULL,
    Image_Name VARCHAR(100),
    Image_Description TEXT,
    Image_URL TEXT NOT NULL,
    Image_Order INT NOT NULL,
    Image_Status ENUM('0','1','2') NOT NULL,
    INDEX (Proj_Profs_Relationship_ID),
    FOREIGN KEY (Proj_Profs_Relationship_ID) REFERENCES proj_prof_relationship(ID)
) ENGINE=InnoDB;

-- 10. พนักงาน
CREATE TABLE prof_employees (
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Proj_Profs_Relationship_ID INT UNSIGNED NOT NULL,
    First_Name_EN VARCHAR(255) NOT NULL,
    Last_Name_EN VARCHAR(255),
    Position_EN VARCHAR(255),
    First_Name_TH VARCHAR(255),
    Last_Name_TH VARCHAR(255),
    Position_TH VARCHAR(255),
    Member_Order INT,
    Member_Status ENUM('0','1','2') NOT NULL,
    Created_By INT UNSIGNED NULL,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NULL,
    Last_Updated_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX (Proj_Profs_Relationship_ID),
    INDEX (Created_By),
    INDEX (Last_Updated_By),
    FOREIGN KEY (Proj_Profs_Relationship_ID) REFERENCES proj_prof_relationship(ID),
    FOREIGN KEY (Created_By) REFERENCES user_admin(ID),
    FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(ID)
) ENGINE=InnoDB;

-- 4. prof gallery
CREATE TABLE prof_gallery (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Prof_ID INT UNSIGNED NOT NULL,
    Image_Name VARCHAR(100),
    Image_Description TEXT,
    Image_URL TEXT NOT NULL,
    Image_Order INT NOT NULL,
    Image_Status ENUM('0','1','2') NOT NULL,
    INDEX (Prof_ID),
    FOREIGN KEY (Prof_ID) REFERENCES professionals(ID)
) ENGINE=InnoDB;

CREATE TABLE home_image (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Card_Type VARCHAR(30),
    Category VARCHAR(100),
    Category_Hierarchy json,
    Card_Name VARCHAR(255),
    Card_Sub_Name VARCHAR(255),
    Card_Logo TEXT,
    Brief_Description TEXT,
    Image_URL TEXT NOT NULL,
    Image_Order INT NOT NULL,
    Card_Url TEXT,
    Last_Updated_Date timestamp NOT NULL,
    All_Category TEXT
) ENGINE=InnoDB;