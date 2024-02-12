/*//spotlight_name//*/ 
SELECT DISTINCT(rcs.Spotlight_Name)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code



ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด...'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ยต่อยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด...'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนทั้งหมด
SELECT rcs.Spotlight_Name, COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโด…'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ล่าสุด 5 ปี
SELECT rcs.Spotlight_Name, COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโด...' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1


SELECT COUNT(rc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN condo_spotlight_relationship_view AS rsr ON rsr.Condo_Code = cpc.Condo_Code
WHERE rsr.PS008 = 'Y' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโด…' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL

ยูนิตเฉลี่ย
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM (((condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code)
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code)
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code)
WHERE rcs.Spotlight_Name = 'คอนโด…' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด…' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด…' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด…' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM((((rch.Data_Value/100)*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 
                    WHERE rch_in1.Condo_Code = cpc.Condo_Code 
                    AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcs.Spotlight_Name = 'คอนโด...' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date = (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 
                    WHERE rch_in2.Condo_Code = cpc.Condo_Code 
                    AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcs.Spotlight_Name = 'คอนโด…' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด…' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcs.Spotlight_Name = 'คอนโด…'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

สร้างเสร็จ
SELECT COUNT(CPCV.Condo_Code)/(SELECT COUNT(rc.Condo_Code)
								FROM condo_price_calculate_view AS cpc
								INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
								INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
								INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
								WHERE rcs.Spotlight_Name = 'คอนโด...' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
								AND rc.Condo_Latitude <> ''
								AND rc.Condo_Longitude <> ''
								AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
								AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS CPCV
INNER JOIN real_condo AS rc ON CPCV.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON CPCV.Condo_Code = rcp.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = CPCV.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE 1=1
AND rcs.Spotlight_Name = 'คอนโด...'
AND DATEDIFF(CURRENT_DATE,CPCV.Condo_Date_Calculate) <= 1826
AND CPCV.Condo_Built_Date <= 2022
ORDER BY CPCV.Condo_Code

-- v2
SELECT COUNT(cpc.Condo_Code)/(SELECT COUNT(rc.Condo_Code)
                              FROM condo_price_calculate_view AS cpc
                              INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
                              INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
                              INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
                              WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
                              AND rc.Condo_Latitude <> ''
                              AND rc.Condo_Longitude <> ''
                              AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
                              AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
where rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Finished) >= 1,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1460,'Y','N'), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1095,'Y','N')),'N'))) = 'Y'
ORDER BY cpc.Condo_Code

กำลังสร้าง
SELECT 100 - COUNT(CPCV.Condo_Code)/(SELECT COUNT(rc.Condo_Code)
								FROM condo_price_calculate_view AS cpc
								INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
								INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
								INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
								WHERE rcs.Spotlight_Name = 'คอนโด...' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
								AND rc.Condo_Latitude <> ''
								AND rc.Condo_Longitude <> ''
								AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
								AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS CPCV
INNER JOIN real_condo AS rc ON CPCV.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON CPCV.Condo_Code = rcp.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = CPCV.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE 1=1
AND rcs.Spotlight_Name = 'คอนโด...'
AND DATEDIFF(CURRENT_DATE,CPCV.Condo_Date_Calculate) <= 1826
AND CPCV.Condo_Built_Date <= 2022
ORDER BY CPCV.Condo_Code

นับคอนโดเลี้ยงสัตว์ได้ 98 == 98
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 19 == 19
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ยต่อยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 9498 == 9500
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0

เฉลี่ยยูนิต 499.89 == 500
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM((((rch.Data_Value/100)*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Pet_Friendly_Status = 'Y' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE  rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

สร้างเสร็จ
SELECT COUNT(cpc.Condo_Code)/(SELECT COUNT(rc.Condo_Code)
                              FROM condo_price_calculate_view AS cpc
                              INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
                              INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
                              WHERE rcft.Pet_Friendly_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
                              AND rc.Condo_Latitude <> ''
                              AND rc.Condo_Longitude <> ''
                              AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
                              AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
where rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Finished) >= 1,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1460,'Y','N'), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1095,'Y','N')),'N'))) = 'Y'
ORDER BY cpc.Condo_Code


กำลังสร้าง
SELECT 100 - COUNT(CPCV.Condo_Code)/(SELECT COUNT(cpc.Condo_Code)
								FROM condo_price_calculate_view AS cpc
								INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
                                INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
                                WHERE rcft.Pet_Friendly_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
                                AND rc.Condo_Latitude <> ''
                                AND rc.Condo_Longitude <> ''
                                AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
                                AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS CPCV
INNER JOIN real_condo AS rc ON CPCV.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE 1=1
AND rcft.Pet_Friendly_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,CPCV.Condo_Date_Calculate) <= 1096
AND CPCV.Condo_Built_Date <= 2022
ORDER BY CPCV.Condo_Code

นับคอนโดลิฟต์ส่วนตัว 8 == 8
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 2 == 2
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 401 == 401
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 200.5 == 201
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Private_Lift_Status = 'Y' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Private_Lift_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Private_Lift_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับคอนโด Branded Residence 8 == 8
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 4 == 4
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 2000 == 2000
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 200.5 == 201
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Branded_Res_Status = 'Y' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND  rcft.Branded_Res_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Branded_Res_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับคอนโด Auto-Parking 63 == 63
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 37 == 37
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 15805 == 15800
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 427.16 == 427
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y' AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Auto_Parking_Status = 'Y' 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND  rcft.Auto_Parking_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Auto_Parking_Status = 'Y'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับคอนโดสระว่ายน้ำ Olympic 30 == 30
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pool_Length >= 50
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 13 == 13
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pool_Length >= 50 AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 12797 == 12800
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pool_Length >= 50 AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 984.38 == 984
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pool_Length >= 50 AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rcft.Pool_Length >= 50
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pool_Length >= 50
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Pool_Length >= 50
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcft.Pool_Length >= 50 
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND  rcft.Pool_Length >= 50
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Pool_Length >= 50
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE rcft.Pool_Length >= 50
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับคอนโดที่จอดรถมากกว่า 100 % 37 == 95
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 13 == 35
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100 AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 12797 == 12800
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100 AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 984.38 == 984
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100 AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON rc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rcft.Parking_Amount/rc.Condo_TotalUnit)*100 > 100
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนคอนโดหรูยูนิตน้อย 72 == 72
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 24 == 24
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07') AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 7717 == 7700
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07') AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 984.38 == 984
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07') AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment IN ('SEG05','SEG06','SEG07')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนคอนโดห้อง Duplex 181 == 180
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 51 == 51
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 28084 == 28100
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 984.38 == 984
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_D_Min + rc.Condo_UnitSize_1BR_D_Med + rc.Condo_UnitSize_1BR_D_Max + rc.Condo_UnitSize_2BR_D_Min + rc.Condo_UnitSize_2BR_D_Med + rc.Condo_UnitSize_2BR_D_Max + rc.Condo_UnitSize_3BR_D_Min + rc.Condo_UnitSize_3BR_D_Med + rc.Condo_UnitSize_3BR_D_Max + rc.Condo_UnitSize_4BR_D_Min + rc.Condo_UnitSize_4BR_D_Med + rc.Condo_UnitSize_4BR_D_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนคอนโดห้อง Loft 45 == 45
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0     
ORDER BY cpc.Condo_Code

5 ปีล่าสุด 33 == 33
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 17790 == 17800
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 539.09 == 539
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rc.Condo_UnitSize_1BR_PL_Min + rc.Condo_UnitSize_1BR_PL_Med + rc.Condo_UnitSize_1BR_PL_Max + rc.Condo_UnitSize_1BR_L_Min + rc.Condo_UnitSize_1BR_L_Med + rc.Condo_UnitSize_1BR_L_Max) > 0
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนคอนโดห้องใหญ่  1339 == 1337
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40) OR (rc.Condo_UnitSize_STU_Med>40) OR (rc.Condo_UnitSize_STU_Max>40) OR  (rc.Condo_UnitSize_1BR_Min>40) OR (rc.Condo_UnitSize_1BR_Med>40) OR (rc.Condo_UnitSize_1BR_Max>40) OR (rc.Condo_UnitSize_1BR_P_Min>40) OR (rc.Condo_UnitSize_1BR_P_Med>40) OR (rc.Condo_UnitSize_1BR_P_Max>40) OR (rc.Condo_UnitSize_1BR_PL_Min>40) OR  (rc.Condo_UnitSize_1BR_PL_Med>40) OR (rc.Condo_UnitSize_1BR_PL_Max>40) OR (rc.Condo_UnitSize_1BR_L_Min>40) OR (rc.Condo_UnitSize_1BR_L_Med>40) OR (rc.Condo_UnitSize_1BR_L_Max>40) OR (rc.Condo_UnitSize_1BR_D_Min>40) OR  (rc.Condo_UnitSize_1BR_D_Med>40) OR (rc.Condo_UnitSize_1BR_D_Max>40) OR  (rc.Condo_UnitSize_2BR_2B_Min>40) OR (rc.Condo_UnitSize_2BR_2B_Med>40) OR (rc.Condo_UnitSize_2BR_2B_Max>40) OR (rc.Condo_UnitSize_2BR_1B_Min>40) OR (rc.Condo_UnitSize_2BR_1B_Med>40) OR (rc.Condo_UnitSize_2BR_1B_Max>40) OR (rc.Condo_UnitSize_2BR_D_Min>40) OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR (rc.Condo_UnitSize_3BR_Max>40) OR  (rc.Condo_UnitSize_3BR_D_Min>40) OR (rc.Condo_UnitSize_3BR_D_Med>40) OR  (rc.Condo_UnitSize_3BR_D_Max>40) OR (rc.Condo_UnitSize_4BR_Min>40) OR (rc.Condo_UnitSize_4BR_Med>40) OR (rc.Condo_UnitSize_4BR_Max>40) OR (rc.Condo_UnitSize_4BR_D_Min>40) OR (rc.Condo_UnitSize_4BR_D_Med>40) OR (rc.Condo_UnitSize_4BR_D_Max>40)                                           
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปีล่าสุด 307 == 307
SELECT cpc.Condo_Code, DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40) AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต 158300 == 160000
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40) AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต 515.63 == 516
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40) AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM(((rch.Data_Value*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE (rc.Condo_UnitSize_STU_Min>40 OR rc.Condo_UnitSize_STU_Med>40 OR rc.Condo_UnitSize_STU_Max>40 OR  rc.Condo_UnitSize_1BR_Min>40 OR rc.Condo_UnitSize_1BR_Med>40 OR rc.Condo_UnitSize_1BR_Max>40 OR rc.Condo_UnitSize_1BR_P_Min>40 OR rc.Condo_UnitSize_1BR_P_Med>40 OR rc.Condo_UnitSize_1BR_P_Max>40 OR rc.Condo_UnitSize_1BR_PL_Min>40 OR  rc.Condo_UnitSize_1BR_PL_Med>40 OR rc.Condo_UnitSize_1BR_PL_Max>40 OR rc.Condo_UnitSize_1BR_L_Min>40 OR rc.Condo_UnitSize_1BR_L_Med>40 OR rc.Condo_UnitSize_1BR_L_Max>40 OR rc.Condo_UnitSize_1BR_D_Min>40 OR rc.Condo_UnitSize_1BR_D_Med>40 OR rc.Condo_UnitSize_1BR_D_Max>40 OR rc.Condo_UnitSize_2BR_2B_Min>40 OR rc.Condo_UnitSize_2BR_2B_Med>40 OR rc.Condo_UnitSize_2BR_2B_Max>40 OR rc.Condo_UnitSize_2BR_1B_Min>40 OR rc.Condo_UnitSize_2BR_1B_Med>40 OR rc.Condo_UnitSize_2BR_1B_Max>40 OR rc.Condo_UnitSize_2BR_D_Min>40 OR (rc.Condo_UnitSize_2BR_D_Med>40) OR  (rc.Condo_UnitSize_2BR_D_Max>40) OR (rc.Condo_UnitSize_3BR_Min>40) OR  (rc.Condo_UnitSize_3BR_Med>40) OR rc.Condo_UnitSize_3BR_Max>40 OR rc.Condo_UnitSize_3BR_D_Min>40 OR rc.Condo_UnitSize_3BR_D_Med>40 OR rc.Condo_UnitSize_3BR_D_Max>40 OR rc.Condo_UnitSize_4BR_Min>40 OR rc.Condo_UnitSize_4BR_Med>40 OR rc.Condo_UnitSize_4BR_Max>40 OR rc.Condo_UnitSize_4BR_D_Min>40 OR rc.Condo_UnitSize_4BR_D_Med>40 OR rc.Condo_UnitSize_4BR_D_Max>40)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1


SELECT cpc.Condo_Code, YEAR(rcp.Condo_Built_Finished), YEAR(CURRENT_DATE)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_spotlight_relationships AS rsr ON rsr.Condo_Code = cpc.Condo_Code
INNER JOIN real_condo_spotlight AS rcs ON rcs.Spotlight_Code = rsr.Spotlight_Code
WHERE rcs.Spotlight_Name = 'คอนโดใกล้สถานีรถไฟฟ้า'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND YEAR(rcp.Condo_Built_Finished) <= YEAR(CURRENT_DATE)
AND rcp.Condo_Built_Finished <> 0
AND rcp.Condo_Built_Finished IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

-- work P'WHITE
SELECT cpc.Condo_Code, rch.Data_Value, rch2.Data_Value, (rch.Data_Value*rch2.Data_Value)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rcp.Condo_Segment = 'SEG02'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
ORDER BY cpc.Condo_Code


-- work P'WHITE
SELECT cpc.Condo_Code, rch.Data_Value, rch2.Data_Value, (rch.Data_Value*rch2.Data_Value)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rcp.Condo_Segment = 'SEG07'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
ORDER BY cpc.Condo_Code



-- HIGH CLASS
ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1  


นับจำนวนทั้งหมด
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1


5 ปี
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1  


รวมยูนิต
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1  
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL


เฉลี่ยยูนิต
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1 

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM((((rch.Data_Value/100)*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date =  (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date =  (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

สร้างเสร็จ
SELECT COUNT(cpc.Condo_Code)/(SELECT COUNT(cpc.Condo_Code)
							FROM condo_price_calculate_view AS cpc
							INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
							INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
							INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
							WHERE rcp.Condo_Segment = 'SEG04'
							AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
							AND rc.Condo_Latitude <> ''
							AND rc.Condo_Longitude <> ''
							AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
							AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
where rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Finished) >= 1,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1460,'Y','N'), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1095,'Y','N')),'N'))) = 'Y'
ORDER BY cpc.Condo_Code

ราคาเฉลี่ย/ยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo_segment AS rcsm ON rcp.Condo_Segment = rcsm.Segment_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rcp.Condo_Segment = 'SEG04'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

-- สายสีเขียวอ่อน
ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_line AS mt ON cas.Line_Code = mt.Line_Code
WHERE cas.Line_Code = 'LINE01'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1  

ราคาเฉลี่ย/ยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_line AS mt ON cas.Line_Code = mt.Line_Code
WHERE cas.Line_Code = 'LINE01'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนทั้งหมด
SELECT COUNT(DISTINCT(cpc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_line AS mt ON cas.Line_Code = mt.Line_Code
WHERE cas.Line_Code = 'LINE01'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

5 ปี
SELECT COUNT(DISTINCT(cpc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_line AS mt ON cas.Line_Code = mt.Line_Code
WHERE cas.Line_Code = 'LINE01'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

-- พร้อมพงษ์
5 ปี
SELECT COUNT(DISTINCT(cpc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN condo_around_station AS cas ON cpc.Condo_Code = cas.Condo_Code
INNER JOIN mass_transit_station AS mt ON cas.Station_Code = mt.Station_Code
WHERE cas.Station_Code = 'E5'
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1


-- กรุงเทพ
5 ปี
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

ราคาเฉลี่ยต่อยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

นับจำนวนทั้งหมด
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

รวมยูนิต
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1 
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0

เฉลี่ยยูนิต
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1  
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1 

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM((((rch.Data_Value/100)*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date = (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1

สร้างเสร็จ
SELECT COUNT(cpc.Condo_Code)/(SELECT COUNT(cpc.Condo_Code)
							FROM condo_price_calculate_view AS cpc
							INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
							WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
							AND rc.Condo_Latitude <> ''
							AND rc.Condo_Longitude <> ''
							AND rc.Province_ID = 10
							AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
where rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID = 10
AND rc.Condo_Status = 1
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Finished) >= 1,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1460,'Y','N'), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1095,'Y','N')),'N'))) = 'Y'
ORDER BY cpc.Condo_Code

-- Sansiri
5 ปี
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ยต่อยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนทั้งหมด
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
AND rc.Developer_Code LIKE 'DV0138%'
WHERE rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0

เฉลี่ยยูนิต
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM((((rch.Data_Value/100)*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date = (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

สร้างเสร็จ
SELECT COUNT(cpc.Condo_Code)/(SELECT COUNT(cpc.Condo_Code)
							FROM condo_price_calculate_view AS cpc
							INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
							WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
							AND rc.Developer_Code LIKE 'DV0138%'
							AND rc.Condo_Latitude <> ''
							AND rc.Condo_Longitude <> ''
							AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
							AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
-- ถ้าจะดึงแค่ลูก ใช้ AND rc.Developer_Code = 'dev code'
AND rc.Developer_Code LIKE 'DV0138%'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Finished) >= 1,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1460,'Y','N'), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1095,'Y','N')),'N'))) = 'Y'
ORDER BY cpc.Condo_Code

-- life
5 ปี
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ย
SELECT SUM(cpc.Condo_Price_Per_Square*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Square IS NOT NULL
AND cpc.Condo_Price_Per_Square <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ราคาเฉลี่ยต่อยูนิต
SELECT SUM(cpc.Condo_Price_Per_Unit*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)/1000000
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND cpc.Condo_Price_Per_Unit IS NOT NULL
AND cpc.Condo_Price_Per_Unit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

นับจำนวนทั้งหมด
SELECT COUNT(cpc.Condo_Code)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
AND rc.Brand_Code = 'BR0552'
WHERE rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

รวมยูนิต
SELECT SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

เฉลี่ยยูนิต
SELECT (SUM(rc.Condo_TotalUnit)/COUNT(rc.Condo_Code))
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ขนาดห้องเฉลี่ย
SELECT SUM(rcp.Condo_Salable_Area)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Salable_Area <> 0 
AND rcp.Condo_Salable_Area IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

อัตราส่วนที่จอดรถต่อห้อง
SELECT (SUM(rcft.Parking_Amount)/SUM(rc.Condo_TotalUnit))*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcft.Parking_Amount <> 0 
AND rcft.Parking_Amount IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าส่วนกลางเฉลี่ย
SELECT SUM(rcp.Condo_Common_Fee*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826 
AND rcp.Condo_Common_Fee <> 0 
AND rcp.Condo_Common_Fee IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ค่าเช่าเฉลี่ย
SELECT SUM((((rch.Data_Value/100)*rch2.Data_Value)/12)*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_hipflat AS rch2 ON cpc.Condo_Code = rch2.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rch2.Data_Attribute = 'price_per_sqm'
AND rch2.Data_Date = (SELECT MAX(rch_in2.Data_Date) FROM real_condo_hipflat AS rch_in2 WHERE rch_in2.Condo_Code = cpc.Condo_Code AND rch_in2.Data_Attribute = 'price_per_sqm')
AND rch2.Data_Value <> 0 
AND rch2.Data_Value IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

rental yield
SELECT SUM(rch.Data_Value*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_hipflat AS rch ON cpc.Condo_Code = rch.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
WHERE rch.Data_Attribute = 'rental_yield_percent'
AND rch.Data_Date = (SELECT MAX(rch_in1.Data_Date) FROM real_condo_hipflat AS rch_in1 WHERE rch_in1.Condo_Code = cpc.Condo_Code AND rch_in1.Data_Attribute = 'rental_yield_percent')
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rch.Data_Value <> 0 
AND rch.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดขาย
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'sold_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'sold_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

ยอดโอน
SELECT SUM(rc.Condo_TotalUnit*rc561.Data_Value)/SUM(rc.Condo_TotalUnit)
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
INNER JOIN real_condo_561 AS rc561 ON cpc.Condo_Code = rc561.Condo_Code
WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826
AND rc561.Data_Attribute = 'transfer_percent'
AND rc561.Data_Date = (SELECT MAX(rc561_in1.Data_Date) FROM real_condo_561 AS rc561_in1 WHERE rc561_in1.Condo_Code = cpc.Condo_Code AND rc561_in1.Data_Attribute = 'transfer_percent')
AND rc561.Data_Value <> 0
AND rc561.Data_Value IS NOT NULL
AND rc.Condo_TotalUnit <> 0
AND rc.Condo_TotalUnit IS NOT NULL
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1

สร้างเสร็จ
SELECT COUNT(cpc.Condo_Code)/(SELECT COUNT(cpc.Condo_Code)
							FROM condo_price_calculate_view AS cpc
							INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
							WHERE DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
							AND rc.Brand_Code = 'BR0552'
							AND rc.Condo_Latitude <> ''
							AND rc.Condo_Longitude <> ''
							AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
							AND rc.Condo_Status = 1)*100
FROM condo_price_calculate_view AS cpc
INNER JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
INNER JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
AND rc.Brand_Code = 'BR0552'
AND rc.Condo_Latitude <> ''
AND rc.Condo_Longitude <> ''
AND rc.Province_ID IN (10, 11, 12, 13, 73, 74)
AND rc.Condo_Status = 1
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1096
AND (if(rcp.Condo_Built_Finished is not null, 
                            if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Finished) >= 1,'Y','N'), 
                                if(rcp.Condo_Built_Start is not null,
                                    if(rc.Condo_HighRise = 1 or (rc.Condo_HighRise = 0 and rc.Condo_LowRise = 0), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1460,'Y','N'), 
                                        if(DATEDIFF(CURRENT_DATE,rcp.Condo_Built_Start) >= 1095,'Y','N')),'N'))) = 'Y'
ORDER BY cpc.Condo_Code