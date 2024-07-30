CREATE TABLE `banner_condo` (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Title_Text varchar(100) not null,
    Subtitle_Text varchar(100) not null,
    Description_Text text not null,
    Button_Text varchar(50) not null,
    Billboard_URL text not null,
    Billboard_Image text not null,
    Billboard_Order smallint not null,
    Page_Type enum('template','developer','brand') not null,
    Billboard_Code varchar(50) not null,
    Billboard_Status smallint not null DEFAULT 0,
    PRIMARY KEY (ID)
) ENGINE = InnoDB;