-- add column unit count
ALTER TABLE `real_condo_full_template` 
ADD `STU_Amount` INT NULL DEFAULT NULL 
AFTER `Pet_Friendly_Status`;

ALTER TABLE `real_condo_full_template` 
ADD `1BR_Amount` INT NULL DEFAULT NULL 
AFTER `STU_Amount`;

ALTER TABLE `real_condo_full_template` 
ADD `2BR_Amount` INT NULL DEFAULT NULL 
AFTER `1BR_Amount`;

ALTER TABLE `real_condo_full_template` 
ADD `3BR_Amount` INT NULL DEFAULT NULL 
AFTER `2BR_Amount`;

ALTER TABLE `real_condo_full_template` 
ADD `4BR_Amount` INT NULL DEFAULT NULL 
AFTER `3BR_Amount`;

-- remove room_count from full_template_unit_type
ALTER TABLE `full_template_unit_type` 
DROP `Room_Count`;

-- add column parking
ALTER TABLE `real_condo_full_template` 
ADD `Manual_Parking_Amount` INT NULL DEFAULT NULL 
AFTER `4BR_Amount`;

ALTER TABLE `real_condo_full_template` 
ADD `Auto_Parking_Amount` INT NULL DEFAULT NULL 
AFTER `Manual_Parking_Amount`;

-- column elevator
ALTER TABLE `real_condo_full_template` 
ADD `LockElevator_Status` VARCHAR(5) NULL DEFAULT NULL 
AFTER `Auto_Parking_Amount`;

ALTER TABLE `real_condo_full_template` 
ADD `UnLockElevator_Status` VARCHAR(5) NULL DEFAULT NULL 
AFTER `LockElevator_Status`;

-- column pool
ALTER TABLE `real_condo_full_template` 
ADD `Pool_Name` VARCHAR(50) NULL DEFAULT NULL 
AFTER `UnLockElevator_Status`;

ALTER TABLE `real_condo_full_template` 
ADD `Pool_2_Name` VARCHAR(50) NULL DEFAULT NULL 
AFTER `Pool_1_Name`;

ALTER TABLE `real_condo_full_template` 
ADD `Pool_2_Width` float NULL DEFAULT NULL 
AFTER `Pool_2_Name`;

ALTER TABLE `real_condo_full_template` 
ADD `Pool_2_Length` float NULL DEFAULT NULL 
AFTER `Pool_2_Width`;


-- import unit in each room_type from google sheet
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0001';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 228,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0011';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 581,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0015';
update real_condo_full_template set STU_Amount = 1936,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0035';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 960,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0112';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 807,2BR_Amount = 47,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0113';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 282,2BR_Amount = 23,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0114';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1049,2BR_Amount = 105,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0116';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 489,2BR_Amount = 7,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0117';
update real_condo_full_template set STU_Amount = 407,1BR_Amount = 137,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0138';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 232,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0139';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 650,2BR_Amount = 163,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0145';
update real_condo_full_template set STU_Amount = 353,1BR_Amount = 1067,2BR_Amount = 112,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0163';
update real_condo_full_template set STU_Amount = 380,1BR_Amount = 333,2BR_Amount = 70,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0166';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 672,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0168';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 703,2BR_Amount = 69,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0171';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0176';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0177';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 698,2BR_Amount = 42,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0184';
update real_condo_full_template set STU_Amount = 424,1BR_Amount = 896,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0186';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 174,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0189';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 828,2BR_Amount = 29,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0190';
update real_condo_full_template set STU_Amount = 100,1BR_Amount = 286,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0192';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 2623,2BR_Amount = 118,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0193';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 534,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0196';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 298,2BR_Amount = 27,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0200';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 242,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0208';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 216,2BR_Amount = 1,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0210';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0211';
update real_condo_full_template set STU_Amount = 205,1BR_Amount = 387,2BR_Amount = 49,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0215';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 242,2BR_Amount = 4,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0218';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 980,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0234';
update real_condo_full_template set STU_Amount = 50,1BR_Amount = 1421,2BR_Amount = 104,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0280';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0284';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 401,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0384';
update real_condo_full_template set STU_Amount = 468,1BR_Amount = null,2BR_Amount = 14,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0424';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1282,2BR_Amount = 146,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0450';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1522,2BR_Amount = 326,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0488';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0517';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 832,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0523';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1458,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0566';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0609';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 482,2BR_Amount = 6,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0611';
update real_condo_full_template set STU_Amount = 47,1BR_Amount = 186,2BR_Amount = 28,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0615';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 225,2BR_Amount = 34,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0625';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 98,2BR_Amount = 59,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0629';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0631';
update real_condo_full_template set STU_Amount = 426,1BR_Amount = 764,2BR_Amount = 160,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0632';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 82,2BR_Amount = 41,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0639';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 709,2BR_Amount = 69,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0642';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 324,2BR_Amount = 226,3BR_Amount = 104,`4BR_Amount` = 12,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0643';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 416,2BR_Amount = 110,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0645';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0652';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 99,2BR_Amount = 30,3BR_Amount = 1,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0653';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 136,2BR_Amount = 32,3BR_Amount = 4,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0660';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 733,2BR_Amount = 177,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0674';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 129,2BR_Amount = 47,3BR_Amount = 3,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0676';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 645,2BR_Amount = 214,3BR_Amount = 5,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0683';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 315,2BR_Amount = 135,3BR_Amount = 12,`4BR_Amount` = 4,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0758';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 487,2BR_Amount = 56,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0760';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 144,2BR_Amount = 64,3BR_Amount = 12,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0820';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 83,2BR_Amount = 2,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0823';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 208,2BR_Amount = 104,3BR_Amount = 18,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0824';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 85,2BR_Amount = 37,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0825';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 87,2BR_Amount = 115,3BR_Amount = 12,`4BR_Amount` = 9,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0829';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 221,2BR_Amount = 47,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0831';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 220,2BR_Amount = 114,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0833';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 356,2BR_Amount = 53,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0834';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 351,2BR_Amount = 98,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0835';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 254,2BR_Amount = 122,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0837';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 220,2BR_Amount = 78,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0845';
update real_condo_full_template set STU_Amount = 39,1BR_Amount = 113,2BR_Amount = 10,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0847';
update real_condo_full_template set STU_Amount = 76,1BR_Amount = 154,2BR_Amount = 84,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0849';
update real_condo_full_template set STU_Amount = 39,1BR_Amount = 113,2BR_Amount = 10,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0850';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 262,2BR_Amount = 166,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0852';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0853';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 324,2BR_Amount = 92,3BR_Amount = 3,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0858';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 272,2BR_Amount = 105,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0859';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1026,2BR_Amount = 154,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0860';
update real_condo_full_template set STU_Amount = 29,1BR_Amount = 274,2BR_Amount = 150,3BR_Amount = 22,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0865';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 443,2BR_Amount = 107,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0872';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 709,2BR_Amount = 74,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0873';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 210,2BR_Amount = 112,3BR_Amount = 12,`4BR_Amount` = 4,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0953';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 84,2BR_Amount = 54,3BR_Amount = 10,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0954';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 651,2BR_Amount = 75,3BR_Amount = 3,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0956';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 50,2BR_Amount = 60,3BR_Amount = 14,`4BR_Amount` = 2,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0957';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 104,2BR_Amount = 88,3BR_Amount = 5,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0959';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = 52,3BR_Amount = 51,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD0961';
update real_condo_full_template set STU_Amount = 40,1BR_Amount = 16,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0971';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 300,2BR_Amount = 168,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0976';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 48,2BR_Amount = 66,3BR_Amount = 16,`4BR_Amount` = 6,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD0997';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 14,2BR_Amount = 39,3BR_Amount = 7,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD0998';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = 145,3BR_Amount = 36,`4BR_Amount` = 10,LockElevator_Status = 'N/A',UnLockElevator_Status = 'N/A' where Condo_Code = 'CD1005';
update real_condo_full_template set STU_Amount = 301,1BR_Amount = 175,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1015';
update real_condo_full_template set STU_Amount = 192,1BR_Amount = 372,2BR_Amount = 36,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1041';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1042';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1043';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 726,2BR_Amount = 446,3BR_Amount = 10,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1045';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1047';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1049';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 133,2BR_Amount = 59,3BR_Amount = 11,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1050';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 222,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1073';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 960,2BR_Amount = 46,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1100';
update real_condo_full_template set STU_Amount = 52,1BR_Amount = 812,2BR_Amount = 36,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1108';
update real_condo_full_template set STU_Amount = 58,1BR_Amount = 545,2BR_Amount = 32,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1109';
update real_condo_full_template set STU_Amount = 41,1BR_Amount = 261,2BR_Amount = 14,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1113';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 58,2BR_Amount = 49,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1114';
update real_condo_full_template set STU_Amount = 509,1BR_Amount = 335,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1115';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1484,2BR_Amount = 401,3BR_Amount = 32,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1116';
update real_condo_full_template set STU_Amount = 62,1BR_Amount = 491,2BR_Amount = 28,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1122';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 431,2BR_Amount = 14,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1123';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1032,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1126';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1257,2BR_Amount = 90,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1127';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 250,2BR_Amount = 91,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1129';
update real_condo_full_template set STU_Amount = 216,1BR_Amount = 839,2BR_Amount = 106,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1130';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 102,2BR_Amount = 14,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1131';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 89,2BR_Amount = 67,3BR_Amount = 13,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1132';
update real_condo_full_template set STU_Amount = 117,1BR_Amount = 232,2BR_Amount = 61,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1133';
update real_condo_full_template set STU_Amount = 36,1BR_Amount = 117,2BR_Amount = 25,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1134';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 334,2BR_Amount = 109,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1137';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 405,2BR_Amount = 132,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1142';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 104,2BR_Amount = 1,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1145';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 124,2BR_Amount = 68,3BR_Amount = 6,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1146';
update real_condo_full_template set STU_Amount = 4,1BR_Amount = 253,2BR_Amount = 18,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1162';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 1268,2BR_Amount = 144,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1163';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1164';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 728,2BR_Amount = 51,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1166';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 238,2BR_Amount = 85,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1167';
update real_condo_full_template set STU_Amount = 766,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1168';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 758,2BR_Amount = 32,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1169';
update real_condo_full_template set STU_Amount = 493,1BR_Amount = 567,2BR_Amount = 172,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1170';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 888,2BR_Amount = 113,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1171';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 94,2BR_Amount = 36,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1172';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1266';
update real_condo_full_template set STU_Amount = 112,1BR_Amount = 334,2BR_Amount = 28,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1269';
update real_condo_full_template set STU_Amount = 21,1BR_Amount = 473,2BR_Amount = 59,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1279';
update real_condo_full_template set STU_Amount = 145,1BR_Amount = 363,2BR_Amount = 28,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1296';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 640,2BR_Amount = 240,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1305';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 478,2BR_Amount = 38,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1312';
update real_condo_full_template set STU_Amount = 266,1BR_Amount = 660,2BR_Amount = 99,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1317';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1329';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = 124,3BR_Amount = 3,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1350';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1363';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 56,2BR_Amount = 41,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1379';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 575,2BR_Amount = 64,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1500';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD1512';
update real_condo_full_template set STU_Amount = 96,1BR_Amount = 169,2BR_Amount = 14,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1524';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 406,2BR_Amount = 28,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1525';
update real_condo_full_template set STU_Amount = 96,1BR_Amount = 169,2BR_Amount = 14,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1526';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 406,2BR_Amount = 28,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1527';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 40,2BR_Amount = 19,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1743';
update real_condo_full_template set STU_Amount = 66,1BR_Amount = 398,2BR_Amount = 10,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1745';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1925';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 154,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD1968';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 217,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD1977';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 26,2BR_Amount = 50,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD2082';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2144';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2466';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 146,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2489';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2500';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2503';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2575';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2582';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2592';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2626';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2633';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2637';
update real_condo_full_template set STU_Amount = null,1BR_Amount = 4,2BR_Amount = 27,3BR_Amount = 1,`4BR_Amount` = 9,LockElevator_Status = null,UnLockElevator_Status = null where Condo_Code = 'CD2676';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2708';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = null,UnLockElevator_Status = 'Yes' where Condo_Code = 'CD2709';
update real_condo_full_template set STU_Amount = null,1BR_Amount = null,2BR_Amount = null,3BR_Amount = null,`4BR_Amount` = null,LockElevator_Status = 'Yes',UnLockElevator_Status = null where Condo_Code = 'CD2724';

update real_condo_full_template
set LockElevator_Status = 'Y'
where LockElevator_Status = 'Yes';

update real_condo_full_template
set UnLockElevator_Status = 'Y'
where UnLockElevator_Status = 'Yes';

update real_condo_full_template
set LockElevator_Status = 'N'
where LockElevator_Status = 'No';

update real_condo_full_template
set UnLockElevator_Status = 'N'
where UnLockElevator_Status = 'No';