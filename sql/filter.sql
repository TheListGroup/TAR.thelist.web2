SELECT rc.Condo_Code, CONCAT(SUBSTRING_INDEX(rc.Condo_ENName,'\n',1),' ',SUBSTRING_INDEX(rc.Condo_ENName,'\n',-1)) AS 'name', cpc.Condo_Price_Per_Square, cpc.Condo_Price_Per_Unit, 
if(rcp.Condo_Built_Finished is not null, 
	YEAR(CURRENT_DATE())-YEAR(rcp.Condo_Built_Finished),
		if(rcp.Condo_Built_Start is not null,
			if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0),
                YEAR(CURRENT_DATE())-(YEAR(rcp.Condo_Built_Start)+4),
                YEAR(CURRENT_DATE())-(YEAR(rcp.Condo_Built_Start)+3)),'')) AS 'AGE',
rcp.Condo_Salable_Area,
if(rc.Condo_UnitSize_STU_Min
  +rc.Condo_UnitSize_STU_Med
  +rc.Condo_UnitSize_STU_Max > 0, 'Y', 'N') AS 'STU',
if(rc.Condo_UnitSize_1BR_Min
   +rc.Condo_UnitSize_1BR_Med
   +rc.Condo_UnitSize_1BR_Max
   +rc.Condo_UnitSize_1BR_P_Min
   +rc.Condo_UnitSize_1BR_P_Med
   +rc.Condo_UnitSize_1BR_P_Max
   +rc.Condo_UnitSize_1BR_PL_Min
   +rc.Condo_UnitSize_1BR_PL_Med
   +rc.Condo_UnitSize_1BR_PL_Max
   +rc.Condo_UnitSize_1BR_L_Min
   +rc.Condo_UnitSize_1BR_L_Med
   +rc.Condo_UnitSize_1BR_L_Max
   +rc.Condo_UnitSize_1BR_D_Min
   +rc.Condo_UnitSize_1BR_D_Med
   +rc.Condo_UnitSize_1BR_D_Max > 0, 'Y', 'N') AS '1 BED',
if(rc.Condo_UnitSize_2BR_2B_Min
  +rc.Condo_UnitSize_2BR_2B_Med
  +rc.Condo_UnitSize_2BR_2B_Max
  +rc.Condo_UnitSize_2BR_1B_Min
  +rc.Condo_UnitSize_2BR_1B_Med
  +rc.Condo_UnitSize_2BR_1B_Max
  +rc.Condo_UnitSize_2BR_D_Min
  +rc.Condo_UnitSize_2BR_D_Med
  +rc.Condo_UnitSize_2BR_D_Max > 0, 'Y', 'N') AS '2 BED',
if(rc.Condo_UnitSize_3BR_Min
  +rc.Condo_UnitSize_3BR_Med
  +rc.Condo_UnitSize_3BR_Max
  +rc.Condo_UnitSize_3BR_D_Min
  +rc.Condo_UnitSize_3BR_D_Med
  +rc.Condo_UnitSize_3BR_D_Max > 0, 'Y', 'N') AS '3 BED',
if(rc.Condo_UnitSize_4BR_Min
  +rc.Condo_UnitSize_4BR_Med
  +rc.Condo_UnitSize_4BR_Max
  +rc.Condo_UnitSize_4BR_D_Min
  +rc.Condo_UnitSize_4BR_D_Med
  +rc.Condo_UnitSize_4BR_D_Max > 0, 'Y', 'N') AS '4 BED'
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON rcp.Condo_Code = cpc.Condo_Code
WHERE rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
ORDER BY rc.Condo_Code



SELECT cpc.Condo_Code, rc.Condo_HighRise, rc.Condo_LowRise, rc.HoldType_ID, cpc.Condo_Sold_Status_Show_Value FROM `condo_price_calculate_view` AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rc.HoldType_ID IS NOT NULL
AND (rc.Condo_HighRise = 1 OR rc.Condo_LowRise = 1)
AND cpc.Condo_Sold_Status_Show_Value IS NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1