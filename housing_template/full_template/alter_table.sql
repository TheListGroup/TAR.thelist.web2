-- housing
ALTER TABLE `housing` ADD `Entrance` TEXT NULL AFTER `Housing_Common_Fee_Max`;
ALTER TABLE `housing` ADD Main_Road INT UNSIGNED NULL AFTER `Entrance`;
ALTER TABLE `housing` ADD Sub_Road INT UNSIGNED NULL AFTER `Main_Road`;
ALTER TABLE `housing` ADD `Pool` SMALLINT UNSIGNED NOT NULL DEFAULT '0' AFTER `Sub_Road`;
ALTER TABLE `housing` ADD Pool_System ENUM('เกลือ','Hydrotherapy','คลอรีน','UV','น้ำแร่') NULL AFTER `Pool`;
ALTER TABLE `housing` ADD Pool_Width FLOAT NULL AFTER `Pool_System`;
ALTER TABLE `housing` ADD Pool_Length FLOAT NULL AFTER `Pool_Width`;

DROP INDEX h_cate_show_faci ON housing_full_template_category;
ALTER TABLE `housing_full_template_category` ADD `Show_Faci_order` INT UNSIGNED NULL AFTER `Category_Order`;
update `housing_full_template_category` set Show_Faci_order = 1 where Category_Show_Faci = 11;
update `housing_full_template_category` set Show_Faci_order = 2 where Category_Show_Faci = 50;
update `housing_full_template_category` set Show_Faci_order = 3 where Category_Show_Faci = 2;
update `housing_full_template_category` set Show_Faci_order = 4 where Category_Show_Faci = 45;
ALTER TABLE `housing_full_template_element_image_view` ADD `Show_Faci_order` INT UNSIGNED NULL AFTER `Category_Show_Faci`;