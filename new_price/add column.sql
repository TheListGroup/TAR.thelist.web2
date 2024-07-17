ALTER TABLE `condo_price_calculate_view` ADD `Full_Source_Condo_Price_Per_Square` VARCHAR(250) NULL AFTER `Source_Condo_Price_Per_Square`;
ALTER TABLE `condo_price_calculate_view` ADD `Full_Source_Condo_Price_Per_Unit` VARCHAR(250) NULL AFTER `Source_Condo_Price_Per_Unit`;
ALTER TABLE `condo_price_calculate_view` ADD `Full_Source_Condo_Sold_Status_Show_Value` VARCHAR(250) NULL AFTER `Source_Condo_Sold_Status_Show_Value`;

ALTER TABLE `all_condo_price_calculate` ADD `Full_Source_Condo_Price_Per_Square` VARCHAR(250) NULL AFTER `Source_Condo_Price_Per_Square`;
ALTER TABLE `all_condo_price_calculate` ADD `Full_Source_Condo_Price_Per_Unit` VARCHAR(250) NULL AFTER `Source_Condo_Price_Per_Unit`;
ALTER TABLE `all_condo_price_calculate` ADD `Full_Source_Condo_Sold_Status_Show_Value` VARCHAR(250) NULL AFTER `Source_Condo_Sold_Status_Show_Value`;