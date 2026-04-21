-- 1. สร้างฐานข้อมูล
CREATE DATABASE IF NOT EXISTS construction_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE construction_db;

-- suppliers brands series products รวมกัน
CREATE TABLE product_entities (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Entity_Type ENUM('suppliers', 'brands', 'series', 'products') NOT NULL,
    Parent_ID INT UNSIGNED,
    Name_EN VARCHAR(255) NOT NULL,
    Name_TH VARCHAR(255),
    Latitude DOUBLE,
    Longitude DOUBLE,
    Address TEXT,
    Yarn INT UNSIGNED,
    Sub_District INT UNSIGNED,
    District INT UNSIGNED,
    Province INT UNSIGNED,
    State INT UNSIGNED,
    Country INT UNSIGNED,
    FB_Link TEXT,
    IG_Link TEXT,
    Line_Link TEXT,
    YT_Link TEXT,
    Website TEXT,
    Content TEXT,
    Brief_Description TEXT,
    Logo_URL TEXT,
    Family_IDS VARCHAR(100),
    Top_Parent VARCHAR(100),
    Buttom_Parent VARCHAR(100),
    Entity_URL_Tag VARCHAR(200) NULL,
    Entity_Status ENUM('0', '1', '2') NOT NULL DEFAULT '1',
    Created_By INT UNSIGNED NULL,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Last_Updated_By INT UNSIGNED NULL,
    Last_Updated_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX(Name_EN),
    INDEX(Yarn),
    INDEX(Sub_District),
    INDEX(District),
    INDEX(Province),
    INDEX(State),
    INDEX(Country),
    INDEX(Latitude),
    INDEX(Longitude),
    FOREIGN KEY (Yarn) REFERENCES place_location(ID),
    FOREIGN KEY (Sub_District) REFERENCES place_location(ID),
    FOREIGN KEY (District) REFERENCES place_location(ID),
    FOREIGN KEY (Province) REFERENCES place_location(ID),
    FOREIGN KEY (State) REFERENCES place_location(ID),
    FOREIGN KEY (Country) REFERENCES country(ID),
    FOREIGN KEY (Created_By) REFERENCES user_admin(ID),
    FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(ID),
    FOREIGN KEY (Parent_ID) REFERENCES product_entities(ID)
);

-- cover
CREATE TABLE product_cover (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Entity_ID INT UNSIGNED NOT NULL,
    Cover_Name VARCHAR(100),
    Image_URL TEXT NOT NULL,
    Ratio_Type ENUM('16:9', '9:16', '1:1') NOT NULL,
    Image_Status ENUM('0','1','2') NOT NULL,
    FOREIGN KEY (Entity_ID) REFERENCES product_entities(ID)
) ENGINE=InnoDB;

-- 9. ระบบ Gallery (ใช้ร่วมกันทุก Entity)
CREATE TABLE product_gallery (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Entity_ID INT UNSIGNED NOT NULL,
    Image_Name VARCHAR(100),
    Image_Description TEXT,
    Image_URL TEXT NOT NULL,
    Image_Order INT NOT NULL,
    Image_Status ENUM('0', '1', '2') NOT NULL,
    FOREIGN KEY (Entity_ID) REFERENCES product_entities(ID)
);

-- 10. ระบบ Catalog (แนบไฟล์ PDF/Docx)
CREATE TABLE product_catalogs (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Entity_ID INT UNSIGNED NOT NULL,
    File_URL TEXT,
    File_Name VARCHAR(100),
    File_Size VARCHAR(50), -- เช่น "2.5 MB"
    File_Type VARCHAR(10), -- เช่น "pdf", "docx"
    FOREIGN KEY (Entity_ID) REFERENCES product_entities(ID)
);

-- 7. ระบบ Attribute Definitions (พจนานุกรมคุณสมบัติ)
CREATE TABLE product_attribute_definitions (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Key_Name VARCHAR(100) NOT NULL UNIQUE, -- เช่น size_tile, color_sml
    Display_Name VARCHAR(100) NOT NULL,    -- เช่น Size, Color
    Remark TEXT,
    Data_Type ENUM('text', 'number', 'list_text', 'color_rgb') NOT NULL,
    Unit VARCHAR(50) DEFAULT NULL,         -- เช่น kg, cm, watt
    Options_List JSON DEFAULT NULL,        -- เก็บตัวเลือก ["S", "M", "L"] ถ้าเป็น list_text
    Display_Order INT NOT NULL, -- ลำดับ default
    Attr_Status ENUM('0', '1', '2') NOT NULL
);

-- 8. ค่า Attribute ของแต่ละ Product (JSONB Approach)
CREATE TABLE product_attribute_values (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Entity_ID INT UNSIGNED NOT NULL,
    Attr_Def_ID INT UNSIGNED NOT NULL,
    Attr_Value Text NOT NULL,              -- เก็บค่าจริง (String, Number หรือ Array)
    Display_Order INT NOT NULL,           -- ลำดับการแสดงผลในหน้า Product สามารถเปลี่ยนเองได้
    Relationship_Status ENUM('0','1','2') NOT NULL,
    FOREIGN KEY (Entity_ID) REFERENCES product_entities(ID),
    FOREIGN KEY (Attr_Def_ID) REFERENCES product_attribute_definitions(ID)
);

CREATE TABLE proj_prod_relationship (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Proj_ID INT UNSIGNED NOT NULL,
    Prod_ID INT UNSIGNED NOT NULL,
    Anchor TEXT,
    Relationship_Status ENUM('0','1','2') NOT NULL,
    FOREIGN KEY (Proj_ID) REFERENCES projects(ID),
    FOREIGN KEY (Prod_ID) REFERENCES product_entities(ID)
);

CREATE TABLE product_entities_categories (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Parent_ID INT UNSIGNED, -- Self-reference สำหรับหมวดหมู่ใหญ่/ย่อย
    Code VARCHAR(10) NOT NULL,
    Category_ENName VARCHAR(255) NOT NULL,
    Category_THName VARCHAR(255),
    Categories_Order INT UNSIGNED NOT NULL,
    Categories_Status ENUM('0','1','2') NOT NULL,
    INDEX (Category_ENName),
    INDEX (Category_THName),
    INDEX (Categories_Order)
);

CREATE TABLE product_entities_categories_relationship (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Entity_ID INT UNSIGNED NOT NULL,
    Category_ID INT UNSIGNED NOT NULL,
    Relationship_Order INT UNSIGNED NOT NULL,
    Relationship_Status ENUM('0','1','2') NOT NULL,
    UNIQUE KEY unique_entity_category (Entity_ID, Category_ID),
    INDEX (Entity_ID),
    INDEX (Category_ID),
    FOREIGN KEY (Entity_ID) REFERENCES product_entities(ID),
    FOREIGN KEY (Category_ID) REFERENCES product_entities_categories(ID)
) ENGINE=InnoDB;