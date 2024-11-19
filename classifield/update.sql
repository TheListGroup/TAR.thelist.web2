/*insert into classified_popular_carousel (popular_type, popular_code, flipboard_display_list)
values ('Spotlight','PS006',1)
    , ('Spotlight','PS007',2)
    , ('Spotlight','PS008',3)
    , ('Spotlight','PS009',4)
    , ('Spotlight','PS016',5)
    , ('Spotlight','PS017',6)
    , ('Spotlight','PS019',7)
    , ('Spotlight','PS024',8)
    , ('Spotlight','PS025',9)
    , ('Spotlight','PS001',10)
    , ('Custom','CUS003',11)
    , ('Custom','CUS001',12)
    , ('Custom','CUS002',13)
    , ('Spotlight','PS002',14)
    , ('Spotlight','PS003',15)
    , ('Spotlight','PS021',16)
    , ('Spotlight','PS022',17)
    , ('Custom','CUS008',18)
    , ('Custom','CUS014',19)
    , ('Custom','CUS009',20)
    , ('Custom','CUS039',21)
    , ('Custom','CUS040',22);*/

INSERT INTO classified_user (User_ID, First_Name, Last_Name, Profile_Picture, User_Type, `Call`, Line_ID, Email, Facebook, Registration_Date, Company
    , User_Status, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date) 
VALUES (NULL, 'Plus', NULL, NULL, 'Agent', NULL, NULL, NULL, NULL, CURRENT_TIMESTAMP, NULL, '1', '32', CURRENT_TIMESTAMP, '32', CURRENT_TIMESTAMP);

ALTER TABLE `classified_project_staging` CHANGE `Ref_ID` `Ref_ID` VARCHAR(100) NULL DEFAULT '10';

ALTER TABLE `classified` ADD `PentHouse` BOOLEAN NULL DEFAULT FALSE AFTER `Unit_Floor_Type`;

ALTER TABLE `classified` ADD `Floor` SMALLINT UNSIGNED NULL AFTER `Bathroom`;
ALTER TABLE `classified` ADD `Direction` ENUM('ทิศเหนือ','ทิศใต้','ทิศตะวันออก','ทิศตะวันตก','ทิศตะวันออกเฉียงเหนือ','ทิศตะวันออกเฉียงใต้','ทิศตะวันตกเฉียงเหนือ','ทิศตะวันตกเฉียงใต้') NULL AFTER `Floor`;
ALTER TABLE `classified` ADD `Move_In` enum('พร้อมให้เข้าอยู่', 'ภายใน 1 - 3 เดือน') NULL AFTER `Direction`;

ALTER TABLE `classified` CHANGE `Sale_Transfer_Fee` `Sale_Transfer_Fee` FLOAT(6,2) UNSIGNED NULL DEFAULT NULL;
ALTER TABLE `classified` CHANGE `Sale_Deposit` `Sale_Deposit` FLOAT(6,2) UNSIGNED NULL DEFAULT NULL;
ALTER TABLE `classified` CHANGE `Sale_Mortgage_Costs` `Sale_Mortgage_Costs` FLOAT(6,2) UNSIGNED NULL DEFAULT NULL;

ALTER TABLE `classified` CHANGE `Min_Rental_Contract` `Min_Rental_Contract` ENUM('3','6','12','1','2','4','5','7','8','9','10','11') NULL DEFAULT NULL;
ALTER TABLE `classified` CHANGE `Rent_Deposit` `Rent_Deposit` ENUM('0','1','2','3','4','5','6','7','8','9','10','11','12') NULL DEFAULT NULL;
ALTER TABLE `classified` CHANGE `Advance_Payment` `Advance_Payment` ENUM('0','1','2','3','4','5','6','7','8','9','10','11','12') NULL DEFAULT NULL;

ALTER TABLE `classified` CHANGE `Room_Type` `Room_Type` ENUM('Studio','1 Bedroom','2 Bedrooms','3 Bedrooms','4 Bedrooms','4+ Bedrooms') NULL DEFAULT NULL;
ALTER TABLE `classified` CHANGE `Unit_Floor_Type` `Unit_Floor_Type` ENUM('Loft','Simplex','Duplex','Triplex') NULL DEFAULT NULL;

ALTER TABLE `classified` CHANGE `Furnish` `Furnish` VARCHAR(50) NULL DEFAULT NULL;
update `classified` set Furnish = 'Non Furnished' where Furnish = 'Unfurnished';
ALTER TABLE `classified` CHANGE `Furnish` `Furnish` ENUM('Bareshell','Non Furnished','Fully Fitted','Fully Furnished') NULL DEFAULT NULL;

ALTER TABLE `classified_image` CHANGE `Classified_Image_Type` `Classified_Image_Type` SMALLINT UNSIGNED NULL DEFAULT 1;
update classified_image set Classified_Image_Type = 1;