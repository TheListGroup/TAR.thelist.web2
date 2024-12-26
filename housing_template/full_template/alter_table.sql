-- housing
ALTER TABLE `housing` ADD `Entrance` TEXT NULL AFTER `Housing_Common_Fee_Max`;
ALTER TABLE `housing` ADD Main_Road INT UNSIGNED NULL AFTER `Entrance`;
ALTER TABLE `housing` ADD Sub_Road INT UNSIGNED NULL AFTER `Main_Road`;
ALTER TABLE `housing` ADD `Pool` SMALLINT UNSIGNED NOT NULL DEFAULT '0' AFTER `Sub_Road`;
ALTER TABLE `housing` ADD Pool_System ENUM('เกลือ','Hydrotherapy','คลอรีน','UV','น้ำแร่') NULL AFTER `Pool`;
ALTER TABLE `housing` ADD Pool_Width FLOAT NULL AFTER `Pool_System`;
ALTER TABLE `housing` ADD Pool_Length FLOAT NULL AFTER `Pool_Width`;