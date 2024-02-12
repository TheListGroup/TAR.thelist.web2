--filter highrise
SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_HighRise = 1


-- filter date
SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(YEAR(CURRENT_DATE) - YEAR(rcp.Condo_Built_Finished) <= 10,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(YEAR(CURRENT_DATE) - (YEAR(rcp.Condo_Built_Start)+4) <= 10,'Y','N'), 
                                        if(YEAR(CURRENT_DATE) - (YEAR(rcp.Condo_Built_Start)+3) <= 10,'Y','N')),'N'))) = 'Y'




-- for check date
SELECT rc.Condo_Code, rc.Condo_HighRise, rc.Condo_LowRise, YEAR(rcp.Condo_Built_Finished), YEAR(rcp.Condo_Built_Start), 
IF(rcp.Condo_Built_Finished is not null, YEAR(CURRENT_DATE) - YEAR(rcp.Condo_Built_Finished), 
   if(rcp.Condo_Built_Start is not null,if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0),
      YEAR(CURRENT_DATE) - (YEAR(rcp.Condo_Built_Start)+4),YEAR(CURRENT_DATE) - (YEAR(rcp.Condo_Built_Start)+4)),NULL)) AS 'age',
YEAR(cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
ORDER BY cpc.Condo_Code


-- fiter holdtype id
SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.HoldType_ID = 1


-- 2 condition
-- holdtype+highrise
SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.HoldType_ID = 1
AND rc.Condo_HighRise = 1


-- holdtype+All Subdistrict
SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.HoldType_ID = 1
AND rc.RealSubDistrict_Code LIKE 'M11%'


-- 3 condition
-- holdtype+All Subdistrict+lowrise
SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.HoldType_ID = 1
AND (rc.RealSubDistrict_Code LIKE 'M11%' OR rc.RealSubDistrict_Code LIKE 'M04%')
AND rc.Condo_LowRise = 1



SELECT COUNT(DISTINCT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_route AS mtr ON cas.Line_Code = mtr.Line_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND mtr.Route_Timeline IN ('Completion','Planning','Under Construction')
ORDER BY cpc.Condo_Code


SELECT cpc.Condo_Code,cas.Line_Code,mtl.Line_Name,cas.Station_Code,mts.Station_THName,mtr.Route_Timeline
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_route AS mtr ON cas.Route_Code = mtr.Route_Code
INNER JOIN mass_transit_station AS mts ON cas.Station_Code = mts.Station_Code
INNER JOIN mass_transit_line AS mtl ON cas.Line_Code = mtl.Line_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND mtr.Route_Timeline = 'Planning'
ORDER BY cpc.Condo_Code


-- count planning
SELECT COUNT(DISTINCT(Condo_Code)) FROM (SELECT cpc.Condo_Code,cas.Line_Code,mtl.Line_Name,cas.Station_Code,mts.Station_THName,mtr.Route_Timeline
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_route AS mtr ON cas.Route_Code = mtr.Route_Code
INNER JOIN mass_transit_station AS mts ON cas.Station_Code = mts.Station_Code
INNER JOIN mass_transit_line AS mtl ON cas.Line_Code = mtl.Line_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND mtr.Route_Timeline = 'Planning'
ORDER BY cpc.Condo_Code) AS aa


-- COUNT LINE
SELECT COUNT(DISTINCT(Condo_Code)) FROM (SELECT cpc.Condo_Code,cas.Line_Code,mtl.Line_Name,cas.Station_Code,mts.Station_THName,mtr.Route_Timeline
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_route AS mtr ON cas.Route_Code = mtr.Route_Code
INNER JOIN mass_transit_station AS mts ON cas.Station_Code = mts.Station_Code
INNER JOIN mass_transit_line AS mtl ON cas.Line_Code = mtl.Line_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND cas.Line_Code = 'LINE01'
ORDER BY cpc.Condo_Code) AS aa


-- COUNT LINE + Planning
SELECT COUNT(DISTINCT(Condo_Code)) FROM (SELECT cpc.Condo_Code,cas.Line_Code,mtl.Line_Name,cas.Station_Code,mts.Station_THName,mtr.Route_Timeline
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_route AS mtr ON cas.Route_Code = mtr.Route_Code
INNER JOIN mass_transit_station AS mts ON cas.Station_Code = mts.Station_Code
INNER JOIN mass_transit_line AS mtl ON cas.Line_Code = mtl.Line_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND (cas.Line_Code = 'LINE01' OR mtr.Route_Timeline = 'Planning')
ORDER BY cpc.Condo_Code) AS aa


-- สายสีเขียวอ่อน + lowrise + ห้อง studio
SELECT COUNT(DISTINCT(Condo_Code)) FROM (SELECT cpc.Condo_Code,cas.Line_Code,mtl.Line_Name,cas.Station_Code,mts.Station_THName,mtr.Route_Timeline
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_route AS mtr ON cas.Route_Code = mtr.Route_Code
INNER JOIN mass_transit_station AS mts ON cas.Station_Code = mts.Station_Code
INNER JOIN mass_transit_line AS mtl ON cas.Line_Code = mtl.Line_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND cas.Line_Code = 'LINE01'
AND rc.Condo_LowRise = 1
AND rc.Condo_UnitSize_STU_Min+rc.Condo_UnitSize_STU_Med+rc.Condo_UnitSize_STU_Max > 0
ORDER BY cpc.Condo_Code) AS aa