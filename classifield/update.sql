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