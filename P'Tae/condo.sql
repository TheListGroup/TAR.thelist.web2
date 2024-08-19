SELECT rc.Condo_Code, rc.Condo_Name, rc.Condo_ENName, cpc.Condo_Built_Date, rc.Condo_TotalUnit, cpc.Condo_Price_Per_Square as 'ราคา/ตร.ม.', cpc.Condo_Price_Per_Unit/1000000 as 'ราคา/ยูนิต', round(cpc.Condo_Sold_Status_Show_Value*100) as Condo_Sold_Status_Show_Value
FROM `real_condo` rc
left join condo_price_calculate_view cpc on rc.Condo_Code = cpc.Condo_Code
WHERE rc.`District_ID` IN (1017,1030,1026) 
AND rc.`Condo_Status` = 1 
and (year(curdate()) - CAST(cpc.Condo_Built_Date as SIGNED) < 5
and cpc.Condo_Sold_Status_Show_Value <> 'RESALE'
and cpc.Condo_Sold_Status_Show_Value <> 1 or cpc.Condo_Sold_Status_Show_Value is null)
ORDER BY rc.`Condo_Code` ASC;

SELECT rc.Condo_Code, rc.Condo_Name, rc.Condo_ENName, cpc.Condo_Built_Date, rc.Condo_TotalUnit, cpc.Condo_Price_Per_Square as 'ราคา/ตร.ม.', cpc.Condo_Price_Per_Unit/1000000 as 'ราคา/ยูนิต', round(cpc.Condo_Sold_Status_Show_Value*100) as Condo_Sold_Status_Show_Value
FROM `real_condo` rc
left join condo_price_calculate_view cpc on rc.Condo_Code = cpc.Condo_Code
WHERE rc.`District_ID` IN (1015,1018,1020,1016,1025) 
AND rc.`Condo_Status` = 1 
and (year(curdate()) - CAST(cpc.Condo_Built_Date as SIGNED) < 5
and cpc.Condo_Sold_Status_Show_Value <> 'RESALE'
and cpc.Condo_Sold_Status_Show_Value <> 1 or cpc.Condo_Sold_Status_Show_Value is null)
ORDER BY rc.`Condo_Code` ASC;

SELECT rc.Condo_Code, rc.Condo_Name, rc.Condo_ENName, cpc.Condo_Built_Date, rc.Condo_TotalUnit, cpc.Condo_Price_Per_Square as 'ราคา/ตร.ม.', cpc.Condo_Price_Per_Unit/1000000 as 'ราคา/ยูนิต', round(cpc.Condo_Sold_Status_Show_Value*100) as Condo_Sold_Status_Show_Value
FROM `real_condo` rc
left join condo_price_calculate_view cpc on rc.Condo_Code = cpc.Condo_Code
WHERE rc.`District_ID` IN (1009,1047,1034,1032) 
AND rc.`Condo_Status` = 1 
and (year(curdate()) - CAST(cpc.Condo_Built_Date as SIGNED) < 5
and cpc.Condo_Sold_Status_Show_Value <> 'RESALE'
and cpc.Condo_Sold_Status_Show_Value <> 1 or cpc.Condo_Sold_Status_Show_Value is null)
ORDER BY rc.`Condo_Code` ASC;

SELECT rc.Condo_Code, rc.Condo_Name, rc.Condo_ENName, cpc.Condo_Built_Date, rc.Condo_TotalUnit, cpc.Condo_Price_Per_Square as 'ราคา/ตร.ม.', cpc.Condo_Price_Per_Unit/1000000 as 'ราคา/ยูนิต', round(cpc.Condo_Sold_Status_Show_Value*100) as Condo_Sold_Status_Show_Value
FROM `real_condo` rc
left join condo_price_calculate_view cpc on rc.Condo_Code = cpc.Condo_Code
WHERE rc.`District_ID` IN (1201,1206) 
AND rc.`Condo_Status` = 1 
and (year(curdate()) - CAST(cpc.Condo_Built_Date as SIGNED) < 5
and cpc.Condo_Sold_Status_Show_Value <> 'RESALE'
and cpc.Condo_Sold_Status_Show_Value <> 1 or cpc.Condo_Sold_Status_Show_Value is null)
ORDER BY rc.`Condo_Code` ASC;

SELECT rc.Condo_Code, rc.Condo_Name, rc.Condo_ENName, cpc.Condo_Built_Date, rc.Condo_TotalUnit, cpc.Condo_Price_Per_Square as 'ราคา/ตร.ม.', cpc.Condo_Price_Per_Unit/1000000 as 'ราคา/ยูนิต', round(cpc.Condo_Sold_Status_Show_Value*100) as Condo_Sold_Status_Show_Value
FROM `real_condo` rc
left join condo_price_calculate_view cpc on rc.Condo_Code = cpc.Condo_Code
WHERE rc.`District_ID` IN (1038,1045,1006) 
AND rc.`Condo_Status` = 1 
and (year(curdate()) - CAST(cpc.Condo_Built_Date as SIGNED) < 5
and cpc.Condo_Sold_Status_Show_Value <> 'RESALE'
and cpc.Condo_Sold_Status_Show_Value <> 1 or cpc.Condo_Sold_Status_Show_Value is null)
ORDER BY rc.`Condo_Code` ASC;