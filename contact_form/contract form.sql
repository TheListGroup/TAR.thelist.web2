ALTER TABLE `real_contact_form` ADD `Contact_Room_Status` ENUM('ห้องจากโครงการ','รวมห้อง Resale ด้วย') NULL DEFAULT NULL AFTER `Contact_Link`;
ALTER TABLE `real_contact_form` ADD `Contact_Position` ENUM('เฉพาะโครงการนี้','รวมโครงการข้างเคียงด้วย') NULL DEFAULT NULL AFTER `Contact_Room_Status`;
ALTER TABLE `real_contact_form` ADD `Contact_Decision_Time` ENUM('ภายใน 3 เดือน','มากกว่า 3 เดือน') NULL DEFAULT NULL AFTER `Contact_Position`;
ALTER TABLE `real_contact_form` ADD `Contract_Classified_Text` TEXT NULL DEFAULT NULL AFTER `Contact_Decision_Time`;

update `real_contact_form`
set Contact_Room_Status = 'ห้องจากโครงการ + Resale'
where Contact_Room_Status = 'รวมห้อง Resale ด้วย';

ALTER TABLE `real_contact_form` CHANGE `Contact_Room_Status` `Contact_Room_Status` 
ENUM('ห้องจากโครงการ','ห้อง Resale เท่านั้น','ห้องจากโครงการ + Resale') NULL DEFAULT NULL;

ALTER TABLE `real_contact_form` CHANGE `Contact_Decision_Time` `Contact_Decision_Time` 
ENUM('ภายใน 3 เดือน','มากกว่า 3 เดือน') NULL DEFAULT NULL;

ALTER TABLE `real_contact_form` CHANGE `Contact_Position` `Contact_Position` 
ENUM('เฉพาะโครงการนี้','รวมโครงการข้างเคียงด้วย') NULL DEFAULT NULL;