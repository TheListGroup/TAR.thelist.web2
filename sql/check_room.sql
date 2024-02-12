-- have min and med
SELECT cpc.Condo_Code, rc.Condo_UnitSize_4BR_D_Min, rc.Condo_UnitSize_4BR_D_Med, rc.Condo_UnitSize_4BR_D_Max FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
-- change type room
WHERE rc.Condo_UnitSize_4BR_D_Med > 0
AND rc.Condo_UnitSize_4BR_D_Min > 0
AND rc.Condo_UnitSize_4BR_D_Max = ''

--have med and max
SELECT cpc.Condo_Code, rc.Condo_UnitSize_4BR_D_Min, rc.Condo_UnitSize_4BR_D_Med, rc.Condo_UnitSize_4BR_D_Max FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
-- change type room
WHERE rc.Condo_UnitSize_4BR_D_Med > 0
AND rc.Condo_UnitSize_4BR_D_Max > 0
AND rc.Condo_UnitSize_4BR_D_Min = ''

-- have min
SELECT cpc.Condo_Code, rc.Condo_UnitSize_4BR_D_Min, rc.Condo_UnitSize_4BR_D_Med, rc.Condo_UnitSize_4BR_D_Max FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
-- change type room
WHERE rc.Condo_UnitSize_4BR_D_Min > 0
AND rc.Condo_UnitSize_4BR_D_Max = ''
AND rc.Condo_UnitSize_4BR_D_Med = ''

--have max
SELECT cpc.Condo_Code, rc.Condo_UnitSize_4BR_D_Min, rc.Condo_UnitSize_4BR_D_Med, rc.Condo_UnitSize_4BR_D_Max FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
-- change type room
WHERE rc.Condo_UnitSize_4BR_D_Max > 0
AND rc.Condo_UnitSize_4BR_D_Min = ''
AND rc.Condo_UnitSize_4BR_D_Med = ''

-- have all
SELECT cpc.Condo_Code, rc.Condo_UnitSize_4BR_D_Min, rc.Condo_UnitSize_4BR_D_Med, rc.Condo_UnitSize_4BR_D_Max FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
-- change type room
WHERE rc.Condo_UnitSize_4BR_D_Max > 0
AND rc.Condo_UnitSize_4BR_D_Min > 0
AND rc.Condo_UnitSize_4BR_D_Med > 0




SELECT rc.Condo_Code
from real_condo AS rc
where rc.Condo_UnitSize_STU_Min is null
  and rc.Condo_UnitSize_STU_Med is null
  and rc.Condo_UnitSize_STU_Max is null
  and rc.Condo_UnitSize_1BR_Min is null
   and rc.Condo_UnitSize_1BR_Med is null
   and rc.Condo_UnitSize_1BR_Max is null
   and rc.Condo_UnitSize_1BR_P_Min is null
   and rc.Condo_UnitSize_1BR_P_Med is null
   and rc.Condo_UnitSize_1BR_P_Max is null
   and rc.Condo_UnitSize_1BR_PL_Min is null
   and rc.Condo_UnitSize_1BR_PL_Med is null
   and rc.Condo_UnitSize_1BR_PL_Max is null
   and rc.Condo_UnitSize_1BR_L_Min is null
   and rc.Condo_UnitSize_1BR_L_Med is null
   and rc.Condo_UnitSize_1BR_L_Max is null
   and rc.Condo_UnitSize_1BR_D_Min is null
   and rc.Condo_UnitSize_1BR_D_Med is null
   and rc.Condo_UnitSize_1BR_D_Max is null
and rc.Condo_UnitSize_2BR_2B_Min is null
  and rc.Condo_UnitSize_2BR_2B_Med is null
  and rc.Condo_UnitSize_2BR_2B_Max is null
  and rc.Condo_UnitSize_2BR_1B_Min is null
  and rc.Condo_UnitSize_2BR_1B_Med is null
  and rc.Condo_UnitSize_2BR_1B_Max is null
  and rc.Condo_UnitSize_2BR_D_Min is null
  and rc.Condo_UnitSize_2BR_D_Med is null
  and rc.Condo_UnitSize_2BR_D_Max is null
and rc.Condo_UnitSize_3BR_Min is null
  and rc.Condo_UnitSize_3BR_Med is null
  and rc.Condo_UnitSize_3BR_Max is null
  and rc.Condo_UnitSize_3BR_D_Min is null
  and rc.Condo_UnitSize_3BR_D_Med is null
  and rc.Condo_UnitSize_3BR_D_Max is null
and rc.Condo_UnitSize_4BR_Min is null
  and rc.Condo_UnitSize_4BR_Med is null
  and rc.Condo_UnitSize_4BR_Max is null
  and rc.Condo_UnitSize_4BR_D_Min is null
  and rc.Condo_UnitSize_4BR_D_Med is null
  and rc.Condo_UnitSize_4BR_D_Max is null
ORDER BY rc.Condo_Code