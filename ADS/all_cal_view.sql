CREATE OR REPLACE VIEW `all_condo_price_calculate_view` AS
select a.Condo_Code
	, if(b.Condo_Built_Finished is not null
		, if((year(curdate()) - (year(b.Condo_Built_Finished) + 1)) > 0
			, 'OLD-finishDate'
			, 'NEW-finishDate')
		, if(b.Condo_Built_Start is not null
			, if(a.Condo_HighRise = 1
				, if((year(curdate()) - (year(b.Condo_Built_Start) + 4)) > 0
					, 'OLD-launchDate-HighRise(4)'
					, 'NEW-launchDate-HighRise(4)')
				, if((year(curdate()) - (year(b.Condo_Built_Start) + 3)) > 0
					, 'OLD-launchDate-HighRise(3)'
					, 'NEW-launchDate-HighRise(3)'))
			, 'OLD-donno')) as Old_or_New
	, if(avg_compre_sqm.Price is not null or avg_dev_survey_sqm.Price is not null or resale.Price is not null
		, 'ราคาเฉลี่ย'
		, if(start_compre_sqm.Price is not null or start_dev_survey_sqm.Price is not null
			, 'ราคาเริ่มต้น'
			, '')) as Condo_Age_Status_Square_Text
	, if(if(b.Condo_Built_Finished is not null
			, if((year(curdate()) - (year(b.Condo_Built_Finished) + 1)) > 0
				, 'OLD'
				, 'NEW')
			, if(b.Condo_Built_Start is not null
				, if(a.Condo_HighRise = 1
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 4)) > 0
						, 'OLD'
						, 'NEW')
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 3)) > 0
						, 'OLD'
						, 'NEW'))
				, 'OLD')) = 'NEW'
		, ifnull(avg_compre_sqm.Price
			, ifnull(avg_dev_survey_sqm.Price
				, ifnull(resale.Price
					, ifnull(start_compre_sqm.Price
						, start_dev_survey_sqm.Price))))
		, ifnull(resale.Price
			, ifnull(avg_dev_survey_sqm.Price
				, ifnull(avg_compre_sqm.Price
					, ifnull(start_compre_sqm.Price
						, start_dev_survey_sqm.Price))))) as Condo_Price_Per_Square
	, if(if(b.Condo_Built_Finished is not null
			, if((year(curdate()) - (year(b.Condo_Built_Finished) + 1)) > 0
				, 'OLD'
				, 'NEW')
			, if(b.Condo_Built_Start is not null
				, if(a.Condo_HighRise = 1
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 4)) > 0
						, 'OLD'
						, 'NEW')
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 3)) > 0
						, 'OLD'
						, 'NEW'))
				, 'OLD')) = 'NEW'
		, if(avg_compre_sqm.Price is not null
			, avg_compre_sqm.Price_Date
			, if(avg_dev_survey_sqm.Price is not null
				, avg_dev_survey_sqm.Price_Date
				, if(resale.Price is not null
					, resale.Price_Date
					, if(start_compre_sqm.Price is not null
						, start_compre_sqm.Price_Date
						, if(start_dev_survey_sqm.Price is not null
							, start_dev_survey_sqm.Price_Date
							, null)))))
		, if(resale.Price is not null
			, resale.Price_Date
			, if(avg_dev_survey_sqm.Price is not null
				, avg_dev_survey_sqm.Price_Date
				, if(avg_compre_sqm.Price is not null
					, avg_compre_sqm.Price_Date
					, if(start_compre_sqm.Price is not null
						, start_compre_sqm.Price_Date
						, if(start_dev_survey_sqm.Price is not null
							, start_dev_survey_sqm.Price_Date
							, null)))))) as Condo_Price_Per_Square_Date
	, if(if(b.Condo_Built_Finished is not null
			, if((year(curdate()) - (year(b.Condo_Built_Finished) + 1)) > 0
				, 'OLD'
				, 'NEW')
			, if(b.Condo_Built_Start is not null
				, if(a.Condo_HighRise = 1
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 4)) > 0
						, 'OLD'
						, 'NEW')
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 3)) > 0
						, 'OLD'
						, 'NEW'))
				, 'OLD')) = 'NEW'
		, ifnull(avg_compre_sqm.Price_Source
			, ifnull(avg_dev_survey_sqm.Price_Source
				, ifnull(resale.Price_Source
					, ifnull(start_compre_sqm.Price_Source
						, start_dev_survey_sqm.Price_Source))))
		, ifnull(resale.Price_Source
			, ifnull(avg_dev_survey_sqm.Price_Source
				, ifnull(avg_compre_sqm.Price_Source
					, ifnull(start_compre_sqm.Price_Source
						, start_dev_survey_sqm.Price_Source))))) as Source_Condo_Price_Per_Square
	, if(start_unit.Price is not null
		, 'ราคาเริ่มต้น'
		, if(avg_unit.Price is not null
			, 'ราคาเฉลี่ย'
			, '')) as Condo_Price_Per_Unit_Text
	, ifnull(start_unit.Price
		, avg_unit.Price) as Condo_Price_Per_Unit
	, if(start_unit.Price is not null
		, start_unit.Price_Date
		, if(avg_unit.Price is not null
			, avg_unit.Price_Date
			, null)) as Condo_Price_Per_Unit_Date
	, ifnull(start_unit.Price_Source
		, avg_unit.Price_Source) as Source_Condo_Price_Per_Unit
	, if(cal_561_mb.Data_Value is not null
		, if((cal_561_mb.Data_Value/100) <= 0
			, 'PRESALE'
			, if((cal_561_mb.Data_Value/100) >= 1
				, 'RESALE'
				, round((cal_561_mb.Data_Value/100), 2)))
		, if(b.Condo_Built_Finished is not null
			, if((b.Condo_Built_Finished + interval 5 year) < now()
				, 'RESALE'
				, null)
			, if(b.Condo_Built_Start is not null
				, if(a.Condo_HighRise = 1
					, if((b.Condo_Built_Start + interval 9 year) < now()
						, 'RESALE'
						, null)
					, if((b.Condo_Built_Start + interval 8 year) < now()
						, 'RESALE'
						, null))
				, 'RESALE'))) as Condo_Sold_Status_Show_Value
	, cal_561_mb.Price_Source as Source_Condo_Sold_Status_Show_Value
	, cal_561_mb.Data_Date as Condo_Sold_Status_Date
	, if(b.Condo_Built_Finished is not null
		, if(b.Condo_Built_Finished > now()
			, 'คาดว่าจะแล้วเสร็จ'
			, 'ปีที่แล้วเสร็จ')
		, if(b.Condo_Built_Start is not null
			, 'ปีที่เปิดตัว'
			, null)) as Condo_Built_Text
	, if(b.Condo_Built_Finished is not null
		, year(b.Condo_Built_Finished)
		, if(b.Condo_Built_Start is not null
			, year(b.Condo_Built_Start)
			, null)) as Condo_Built_Date
	, if(b.Condo_Built_Start is not null
		, b.Condo_Built_Start
		, if(b.Condo_Built_Finished is not null
			, if(a.Condo_HighRise = 1
				, b.Condo_Built_Finished - interval 4 year
				, b.Condo_Built_Finished - interval 3 year)
			, null)) as Condo_Date_Calculate
	, if(if(b.Condo_Built_Finished is not null
			, if((year(curdate()) - (year(b.Condo_Built_Finished) + 1)) > 0
				, 'OLD'
				, 'NEW')
			, if(b.Condo_Built_Start is not null
				, if(a.Condo_HighRise = 1
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 4)) > 0
						, 'OLD'
						, 'NEW')
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 3)) > 0
						, 'OLD'
						, 'NEW'))
				, 'OLD')) = 'NEW'
		, ifnull(avg_compre_sqm_cal.Price
			, ifnull(avg_dev_survey_sqm_cal.Price
				, resale_cal.Price))
		, ifnull(resale_cal.Price
			, ifnull(avg_dev_survey_sqm_cal.Price
				, avg_compre_sqm_cal.Price))) as Condo_Price_Per_Square_Cal
	, start_unit_cal.Price as Condo_Price_Per_Unit_Cal
	, if(if(b.Condo_Built_Finished is not null
			, if((year(curdate()) - (year(b.Condo_Built_Finished) + 1)) > 0
				, 'OLD'
				, 'NEW')
			, if(b.Condo_Built_Start is not null
				, if(a.Condo_HighRise = 1
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 4)) > 0
						, 'OLD'
						, 'NEW')
					, if((year(curdate()) - (year(b.Condo_Built_Start) + 3)) > 0
						, 'OLD'
						, 'NEW'))
				, 'OLD')) = 'NEW'
		, ifnull(avg_compre_sqm_cal.Price
			, ifnull(avg_dev_survey_sqm_cal.Price
				, ifnull(resale_cal.Price
					, ifnull(start_compre_sqm_cal.Price
						, start_dev_survey_sqm_cal.Price))))
		, ifnull(resale_cal.Price
			, ifnull(avg_dev_survey_sqm_cal.Price
				, ifnull(avg_compre_sqm_cal.Price
					, ifnull(start_compre_sqm_cal.Price
						, start_dev_survey_sqm_cal.Price))))) as Condo_Price_Per_Square_Sort
	, ifnull(start_unit_cal.Price
		, avg_unit_cal.Price) as Condo_Price_Per_Unit_Sort
from real_condo a
left join real_condo_price b on a.Condo_Code = b.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head = 'Company Presentation'
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Resale = '0') order_compre_sqm
			where Myorder = 1) avg_compre_sqm
on a.Condo_Code = avg_compre_sqm.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head in ('Online Survey','Developer')
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Resale = '0') order_dev_survey_sqm
			where Myorder = 1) avg_dev_survey_sqm
on a.Condo_Code = avg_dev_survey_sqm.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Resale = '1') order_resale
			where Myorder = 1) resale
on a.Condo_Code = resale.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head = 'Company Presentation'
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เริ่มต้น'
					and ap.Resale = '0') order_compre_sqm
			where Myorder = 1) start_compre_sqm
on a.Condo_Code = start_compre_sqm.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head in ('Online Survey','Developer')
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เริ่มต้น'
					and ap.Resale = '0') order_compre_sqm
			where Myorder = 1) start_dev_survey_sqm
on a.Condo_Code = start_dev_survey_sqm.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ap.Price_Type = 'บ/ยูนิต'
					and ap.Start_or_AVG = 'เริ่มต้น'
					and ap.Resale = '0') order_start_unit
			where Myorder = 1) start_unit
on a.Condo_Code = start_unit.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ap.Price_Type = 'บ/ยูนิต'
					and ap.Start_or_AVG = 'เฉลี่ย') order_avg_unit
			where Myorder = 1) avg_unit
on a.Condo_Code = avg_unit.Condo_Code
left join ( select Condo_Code, Data_Date, Data_Attribute, Data_Value, Data_Note, Price_Source
			from (	select rc561.Condo_Code
						, rc561.Data_Date
						, rc561.Data_Attribute
						, rc561.Data_Value
						, rc561.Data_Note
						, ps.Head as Price_Source
						, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Data_Date desc) AS Myorder
					from real_condo_561 rc561
					cross join (select ID, Head, Sub from price_source where Sub = 'Company Presentation - 56-1') ps
					where rc561.Data_Status = 1
					and rc561.Data_Attribute = 'sold_percent') order_561_mb
			where Myorder = 1) cal_561_mb
on a.Condo_Code = cal_561_mb.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head = 'Company Presentation'
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Resale = '0'
					and ap.Special = '0') order_compre_sqm
			where Myorder = 1) avg_compre_sqm_cal
on a.Condo_Code = avg_compre_sqm_cal.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head in ('Online Survey','Developer')
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Resale = '0'
					and ap.Special = '0') order_dev_survey_sqm
			where Myorder = 1) avg_dev_survey_sqm_cal
on a.Condo_Code = avg_dev_survey_sqm_cal.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Resale = '1'
					and ap.Special = '0') order_resale
			where Myorder = 1) resale_cal
on a.Condo_Code = resale_cal.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head = 'Company Presentation'
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เริ่มต้น'
					and ap.Resale = '0'
					and ap.Special = '0') order_compre_sqm
			where Myorder = 1) start_compre_sqm_cal
on a.Condo_Code = start_compre_sqm_cal.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ps.Head in ('Online Survey','Developer')
					and ap.Price_Type = 'บ/ตรม'
					and ap.Start_or_AVG = 'เริ่มต้น'
					and ap.Resale = '0'
					and ap.Special = '0') order_compre_sqm
			where Myorder = 1) start_dev_survey_sqm_cal
on a.Condo_Code = start_dev_survey_sqm_cal.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ap.Price_Type = 'บ/ยูนิต'
					and ap.Start_or_AVG = 'เริ่มต้น'
					and ap.Resale = '0'
					and ap.Special = '0') order_start_unit
			where Myorder = 1) start_unit_cal
on a.Condo_Code = start_unit_cal.Condo_Code
left join ( select Condo_Code
				, Price
				, Price_Date
				, Condo_Build_Date
				, Start_or_AVG
				, Price_Source
				, Price_Type
				, Special
				, Remark
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Sub as Price_Source
					, ap.Price_Type, ap.Special, ap.Remark
					, ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
					FROM all_price_view ap
					left join price_source ps on ap.Price_Source = ps.ID
					where ap.Price_Type = 'บ/ยูนิต'
					and ap.Start_or_AVG = 'เฉลี่ย'
					and ap.Special = '0') order_avg_unit
			where Myorder = 1) avg_unit_cal
on a.Condo_Code = avg_unit_cal.Condo_Code
WHERE a.Condo_Latitude is not null
AND a.Condo_Longitude is not null
AND a.Condo_Status = 1
order by a.Condo_Code;


DROP PROCEDURE IF EXISTS ads_getCondoTopSpotlight;
DELIMITER //

CREATE PROCEDURE ads_getCondoTopSpotlight(IN Condo_Code VARCHAR(50), OUT finalSpotlight_Name VARCHAR(500))
BEGIN

	DECLARE done				BOOLEAN			DEFAULT FALSE;
	DECLARE eachSpotlight_Code	VARCHAR(250)	DEFAULT NULL;
	DECLARE eachSpotlight_Name	VARCHAR(250)	DEFAULT NULL;
	DECLARE queryBase1			VARCHAR(1000)	DEFAULT "SELECT COUNT(1) INTO @spotlightCount FROM condo_spotlight_relationship_view CSRV WHERE CSRV.Condo_Code = '";
	DECLARE queryBase2			VARCHAR(100)	DEFAULT "' AND ";
	DECLARE queryBase3			VARCHAR(100)	DEFAULT "= 'Y'";
	DECLARE queryFinal			VARCHAR(2000)	DEFAULT NULL;
	DECLARE	queryResultCount	INTEGER			DEFAULT 0;
	DECLARE stmt 				VARCHAR(2000);
	DECLARE maxSpotlightAllowed	INTEGER			DEFAULT 2;
	DECLARE spotlightCounter	INTEGER			DEFAULT 0;

	DECLARE curTopSpotlight
	CURSOR FOR
		SELECT RCS.Spotlight_Code, RCS.Spotlight_Name 
		FROM real_condo_spotlight RCS
		WHERE RCS.Spotlight_Order >= 4
		ORDER BY RCS.Spotlight_Order;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET finalSpotlight_Name = "";
	SET queryBase1 = CONCAT(queryBase1, Condo_Code, queryBase2);
	
	OPEN curTopSpotlight;
	
	TopSpotlightLoop:LOOP
		FETCH curTopSpotlight INTO eachSpotlight_Code, eachSpotlight_Name;
		
		SET queryFinal = CONCAT(queryBase1, eachSpotlight_Code, queryBase3);
		-- select queryFinal;
		SET @query = queryFinal;
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET queryResultCount = @spotlightCount;
		
		IF (queryResultCount > 0) THEN
            IF finalSpotlight_Name <> "" THEN
                SET finalSpotlight_Name = CONCAT(finalSpotlight_Name, "\n" , eachSpotlight_Name);
            ELSE
                SET finalSpotlight_Name = CONCAT(finalSpotlight_Name, "" , eachSpotlight_Name);
            END IF;
			SET spotlightCounter = spotlightCounter + 1;
        --    select queryResultCount,finalSpotlight_Name,spotlightCounter;
		END IF;
		
		IF spotlightCounter >= maxSpotlightAllowed THEN
			SET done = TRUE;
		END IF;
		
		IF done THEN
			CLOSE curTopSpotlight;
			LEAVE TopSpotlightLoop;
		END IF;
	
	END LOOP;
	
	SET finalSpotlight_Name = TRIM(finalSpotlight_Name);

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS ads_update_spotlight;
DELIMITER //

CREATE PROCEDURE ads_update_spotlight ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE condo	    VARCHAR(50) DEFAULT 0;
    DECLARE mySpotlight	VARCHAR(500);

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_update_spotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code FROM condo_spotlight_relationship_view;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',condo);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO condo;

        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL ads_getCondoTopSpotlight(condo, mySpotlight);
        UPDATE condo_spotlight_relationship_view
        SET Top_Spotlight = mySpotlight
        WHERE Condo_Code = condo;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;
END //
DELIMITER ;


ALTER TABLE `all_condo_spotlight_relationship` 
ADD `CUS041` VARCHAR(1) NOT NULL AFTER `CUS040`, 
ADD `CUS042` VARCHAR(1) NOT NULL AFTER `CUS041`;

ALTER TABLE `all_condo_spotlight_relationship` DROP `CUS035`;
ALTER TABLE `all_condo_spotlight_relationship` DROP `CUS036`;

-- all_condo_spotlight_relationship_view
CREATE OR REPLACE VIEW all_condo_spotlight_relationship_view AS
SELECT  a.Condo_Code
	,	if(s1.c1>0,'Y','N') as PS001
    ,	if(s2.c1>0,'Y','N') as PS002
    ,	if(s3.c1>0,'Y','N') as PS003
    ,	if(d.Branded_Res_Status = 'Y','Y','N') as PS006
    ,	if(s7.Size > 40,'Y','N') as PS007
    ,	if(s8.c1>0,'Y','N') as PS008
    ,	if(s9.c1>0,'Y','N') as PS009
    ,	if(d.Pet_Friendly_Status = 'Y','Y','N') as PS016
    ,	if(d.Parking_Amount > a.Condo_TotalUnit,'Y','N') as PS017
    ,	if(
        (`b`.`Condo_Segment` in ('SEG05', 'SEG06', 'SEG07')),
        if(
            (`a`.`Condo_HighRise` = 1),
            if((`a`.`Condo_TotalUnit` < 200), 'Y', 'N'),
            if((`a`.`Condo_TotalUnit` < 100), 'Y', 'N')
        ),
        'N'
    ) AS `PS019`
    ,	if(s21.Condo_Code is not null,'Y','N') as PS021
    ,	if(s22.Condo_Code is not null,'Y','N') as PS022
    ,	if(s24.c1>0,'Y','N') as PS024
    ,	if(d.Pool_Length >= 50,'Y','N') as PS025
    ,	if(d.Private_Lift_Status = 'Y','Y','N') as PS026
    ,	if((`a`.`Condo_Code` <> ''), 'Y', 'N') AS CUS000
    ,	if(cs1.c1>0,'Y','N') as CUS001
    ,	if(cs2.c1>0,'Y','N') as CUS002
    ,	if(cs3.c1>0,'Y','N') as CUS003
    ,	if(cs4.c1>0,'Y','N') as CUS004
    ,	if(cs5.c1>0,'Y','N') as CUS005
    ,	if(cs6.c1>0,'Y','N') as CUS006
    ,	if(cs7.c1>0,'Y','N') as CUS007
    ,	if((`a`.`RealDistrict_Code` = 'M11'), 'Y', 'N') AS `CUS008`
    ,	if(d.Auto_Parking_Status = 'Y','Y','N') as CUS009
    ,	if(
        (
            (`c`.`Condo_Price_Per_Unit_Sort` <= 1000000)
            and (`c`.`Condo_Price_Per_Unit_Sort` > 0)
        ),
        'Y',
        'N'
    ) AS `CUS010`,
    if(
        (
            (`c`.`Condo_Price_Per_Unit_Sort` <= 2000000)
            and (`c`.`Condo_Price_Per_Unit_Sort` > 1000000)
        ),
        'Y',
        'N'
    ) AS `CUS011`,
    if(
        (`b`.`Condo_Built_Finished` is not null),
        if(
            (
                (
                    year(curdate()) - year(`b`.`Condo_Built_Finished`)
                ) > 0
            ),
            'Y',
            'N'
        ),
        if(
            (`b`.`Condo_Built_Start` is not null),
            if(
                (
                    (`a`.`Condo_HighRise` = 1)
                ),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)
                        ) > 0
                    ),
                    'Y',
                    'N'
                ),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)
                        ) > 0
                    ),
                    'Y',
                    'N'
                )
            ),
            'N'
        )
    ) AS `CUS014`
    ,	if(cs15.c1>0,'Y','N') as CUS015
    ,	if(cs16.c1>0,'Y','N') as CUS016
    ,	if(cs17.c1>0,'Y','N') as CUS017
    ,	if(cs18.c1>0,'Y','N') as CUS018
    ,	if(cs19.c1>0,'Y','N') as CUS019
    ,	if(cs20.c1>0,'Y','N') as CUS020
    ,	if(
        (
            (`c`.`Condo_Price_Per_Unit_Sort` <= 5000000)
            and (`c`.`Condo_Price_Per_Unit_Sort` > 2000000)
        ),
        'Y',
        'N'
    ) AS `CUS021`,
    if(
        (
            (`c`.`Condo_Price_Per_Unit_Sort` <= 10000000)
            and (`c`.`Condo_Price_Per_Unit_Sort` > 5000000)
        ),
        'Y',
        'N'
    ) AS `CUS022`,
    if(
        (
            (`c`.`Condo_Price_Per_Unit_Sort` <= 20000000)
            and (`c`.`Condo_Price_Per_Unit_Sort` > 10000000)
        ),
        'Y',
        'N'
    ) AS `CUS023`,
    if(
        (
            (`c`.`Condo_Price_Per_Unit_Sort` <= 40000000)
            and (`c`.`Condo_Price_Per_Unit_Sort` > 20000000)
        ),
        'Y',
        'N'
    ) AS `CUS024`,
    if((`c`.`Condo_Price_Per_Unit_Sort` > 40000000), 'Y', 'N') AS `CUS025`,
    if((`a`.`HoldType_ID` = 1), 'Y', 'N') AS `CUS026`,
    if((`a`.`HoldType_ID` = 2), 'Y', 'N') AS `CUS027`,
    if((`a`.`Condo_LowRise` = 1), 'Y', 'N') AS `CUS028`,
    if((`a`.`Condo_HighRise` = 1), 'Y', 'N') AS `CUS029`,
    if(
        (`c`.`Condo_Sold_Status_Show_Value` = 'RESALE'),
        'N',
        'Y'
    ) AS `CUS030`,
    if(
        (`c`.`Condo_Sold_Status_Show_Value` = 'RESALE'),
        'Y',
        'N'
    ) AS `CUS031`,
    if(
        (`b`.`Condo_Built_Finished` is not null),
        if(
            (
                (
                    year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)
                ) > 0
            ),
            'N',
            'Y'
        ),
        if(
            (`b`.`Condo_Built_Start` is not null),
            if(
                (
                    (`a`.`Condo_HighRise` = 1)
                ),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)
                        ) > 0
                    ),
                    'N',
                    'Y'
                ),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)
                        ) > 0
                    ),
                    'N',
                    'Y'
                )
            ),
            'N'
        )
    ) AS `CUS032`,
    if(
        (
            (year(`c`.`Condo_Date_Calculate`) >= 2001)
            and (year(`c`.`Condo_Date_Calculate`) <= 2010)
        ),
        'Y',
        'N'
    ) AS `CUS033`,
    if(
        (
            (year(`c`.`Condo_Date_Calculate`) >= 2011)
            and (year(`c`.`Condo_Date_Calculate`) <= 2020)
        ),
        'Y',
        'N'
    ) AS `CUS034`,
    if(
        (year(`c`.`Condo_Date_Calculate`) = 2021),
        'Y',
        'N'
    ) AS `CUS037`,
    if(
        (year(`c`.`Condo_Date_Calculate`) = 2022),
        'Y',
        'N'
    ) AS `CUS038`
    ,   if(c39.Condo_Code is not null, 'Y', 'N') as CUS039
    ,   if(c40.Condo_Code is not null, 'Y', 'N') as CUS040
    ,   if((year(`c`.`Condo_Date_Calculate`) = 2024),'Y','N') AS `CUS041`
    ,   if((year(`c`.`Condo_Date_Calculate`) = 2023),'Y','N') AS `CUS042`
FROM real_condo as a
inner join real_condo_price as b on a.Condo_Code = b.Condo_Code
inner join all_condo_price_calculate_view as c on a.Condo_Code = c.Condo_Code
left join (select * 
            from real_condo_full_template
            where Condo_Code <> 'CD2860'
            and Condo_Code <> 'CD2861') d 
on a.Condo_Code = d.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'PS001'
            group by Condo_Code) s1
on a.Condo_Code = s1.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'PS002'
            group by Condo_Code) s2
on a.Condo_Code = s2.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'PS003'
            group by Condo_Code) s3
on a.Condo_Code = s3.Condo_Code
left join ( select Condo_Code,max(Size) as Size
            from full_template_unit_type
            where Unit_Type_Status <> 2
            group by Condo_Code) s7
on a.Condo_Code = s7.Condo_Code    
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'PS008'
            group by Condo_Code) s8
on a.Condo_Code = s8.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'PS009'
            group by Condo_Code) s9
on a.Condo_Code = s9.Condo_Code
left join ( select Condo_Code,Unit_Floor_Type_ID
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Unit_Floor_Type_ID = 3
            group by Condo_Code) s21
on a.Condo_Code = s21.Condo_Code  
left join ( select Condo_Code,Unit_Floor_Type_ID
            from full_template_unit_type
            where Unit_Type_Status <> 2
            and Unit_Floor_Type_ID = 2
            group by Condo_Code) s22
on a.Condo_Code = s22.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'PS024'
            group by Condo_Code) s24
on a.Condo_Code = s24.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS001'
            group by Condo_Code) cs1
on a.Condo_Code = cs1.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS002'
            group by Condo_Code) cs2
on a.Condo_Code = cs2.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS003'
            group by Condo_Code) cs3
on a.Condo_Code = cs3.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS004'
            group by Condo_Code) cs4
on a.Condo_Code = cs4.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS005'
            group by Condo_Code) cs5
on a.Condo_Code = cs5.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS006'
            group by Condo_Code) cs6
on a.Condo_Code = cs6.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS007'
            group by Condo_Code) cs7
on a.Condo_Code = cs7.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS015'
            group by Condo_Code) cs15
on a.Condo_Code = cs15.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS016'
            group by Condo_Code) cs16
on a.Condo_Code = cs16.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS017'
            group by Condo_Code) cs17
on a.Condo_Code = cs17.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS018'
            group by Condo_Code) cs18
on a.Condo_Code = cs18.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS019'
            group by Condo_Code) cs19
on a.Condo_Code = cs19.Condo_Code
left join ( select Condo_Code, count(1) as c1
            from real_spotlight_relationships
            where Spotlight_Code = 'CUS020'
            group by Condo_Code) cs20
on a.Condo_Code = cs20.Condo_Code
left join (SELECT ff.Condo_Code
            FROM `full_template_floor_plan` ff
            left join full_template_vector_floor_plan_relationship fv on ff.Floor_Plan_ID = fv.Floor_Plan_ID
            left join ( SELECT *
                            ,(if(Section_1_shortcut_Name is not null,1,0) 
                            + if(Section_2_shortcut_Name is not null,1,0) 
                            + if(Section_3_shortcut_Name is not null,1,0) 
                            + if(Section_4_shortcut_Name is not null,1,0) 
                            + if(Section_5_shortcut_Name is not null,1,0)) as cal 
                        FROM `full_template_section_shortcut_view`) aaa
            on ff.Condo_Code = aaa.Condo_Code
            where ff.Floor_Plan_Status = 1
            and fv.Vector_Type = 1
            and fv.Relationship_Status = 1
            and aaa.cal > 0
            group by ff.Condo_Code
            order by ff.Condo_Code) c39
on a.Condo_Code = c39.Condo_Code
left join (select Condo_Code 
            from classified 
            where Classified_Status = '1' 
            group by Condo_Code) c40
on a.Condo_Code = c40.Condo_Code
where a.Condo_Latitude is not null
and a.Condo_Longitude is not null
and a.Condo_Status = 1
order by a.Condo_Code;


CREATE TABLE all_condo_spotlight_relationship LIKE condo_spotlight_relationship_view;


DROP PROCEDURE IF EXISTS ads_getCondoTopSpotlight_all;
DELIMITER //

CREATE PROCEDURE ads_getCondoTopSpotlight_all(IN Condo_Code VARCHAR(50), OUT finalSpotlight_Name VARCHAR(500))
BEGIN

	DECLARE done				BOOLEAN			DEFAULT FALSE;
	DECLARE eachSpotlight_Code	VARCHAR(250)	DEFAULT NULL;
	DECLARE eachSpotlight_Name	VARCHAR(250)	DEFAULT NULL;
	DECLARE queryBase1			VARCHAR(1000)	DEFAULT "SELECT COUNT(1) INTO @spotlightCount FROM all_condo_spotlight_relationship CSRV WHERE CSRV.Condo_Code = '";
	DECLARE queryBase2			VARCHAR(100)	DEFAULT "' AND ";
	DECLARE queryBase3			VARCHAR(100)	DEFAULT "= 'Y'";
	DECLARE queryFinal			VARCHAR(2000)	DEFAULT NULL;
	DECLARE	queryResultCount	INTEGER			DEFAULT 0;
	DECLARE stmt 				VARCHAR(2000);
	DECLARE maxSpotlightAllowed	INTEGER			DEFAULT 2;
	DECLARE spotlightCounter	INTEGER			DEFAULT 0;

	DECLARE curTopSpotlight
	CURSOR FOR
		SELECT RCS.Spotlight_Code, RCS.Spotlight_Name 
		FROM real_condo_spotlight RCS
		WHERE RCS.Spotlight_Order >= 4
		ORDER BY RCS.Spotlight_Order;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET finalSpotlight_Name = "";
	SET queryBase1 = CONCAT(queryBase1, Condo_Code, queryBase2);
	
	OPEN curTopSpotlight;
	
	TopSpotlightLoop:LOOP
		FETCH curTopSpotlight INTO eachSpotlight_Code, eachSpotlight_Name;
		
		SET queryFinal = CONCAT(queryBase1, eachSpotlight_Code, queryBase3);
		-- select queryFinal;
		SET @query = queryFinal;
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET queryResultCount = @spotlightCount;
		
		IF (queryResultCount > 0) THEN
            IF finalSpotlight_Name <> "" THEN
                SET finalSpotlight_Name = CONCAT(finalSpotlight_Name, "\n" , eachSpotlight_Name);
            ELSE
                SET finalSpotlight_Name = CONCAT(finalSpotlight_Name, "" , eachSpotlight_Name);
            END IF;
            SET spotlightCounter = spotlightCounter + 1;
        --    select queryResultCount,finalSpotlight_Name,spotlightCounter;
		END IF;
		
		IF spotlightCounter >= maxSpotlightAllowed THEN
			SET done = TRUE;
		END IF;
		
		IF done THEN
			CLOSE curTopSpotlight;
			LEAVE TopSpotlightLoop;
		END IF;
	
	END LOOP;
	
	SET finalSpotlight_Name = TRIM(finalSpotlight_Name);

END //
DELIMITER ;


DROP PROCEDURE IF EXISTS truncateInsert_all_condo_spotlight_relationship;
DELIMITER //

CREATE PROCEDURE truncateInsert_all_condo_spotlight_relationship ()
BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(50) DEFAULT NULL;
	DECLARE v_name1 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name2 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name3 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name4 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name5 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name6 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name7 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name8 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name9 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name10 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name11 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name12 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name13 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name14 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name15 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name16 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name17 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name18 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name19 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name20 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name21 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name22 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name23 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name24 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name25 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name26 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name27 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name28 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name29 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name30 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name31 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name32 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name33 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name34 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name35 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name36 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name37 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name38 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name39 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name40 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name41 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name42 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name43 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name44 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name45 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name46 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name47 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name48 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name49 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name50 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name51 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name52 VARCHAR(50) DEFAULT NULL;
    DECLARE v_name53 VARCHAR(50) DEFAULT NULL;
	DECLARE v_name54 VARCHAR(50) DEFAULT NULL;
    DECLARE mySpotlight	VARCHAR(500) DEFAULT 0;

	DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_all_condo_spotlight_relationship';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

	-- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT Condo_Code,PS001,PS002,PS003,PS006,PS007,PS008,PS009,PS016,PS017,PS019,PS021,PS022,PS024,
                                PS025,PS026,CUS000,CUS001,CUS002,CUS003,CUS004,CUS005,CUS006,CUS007,CUS008,CUS009,
                                CUS010,CUS011,CUS014,CUS015,CUS016,CUS017,CUS018,CUS019,CUS020,CUS021,CUS022,CUS023,CUS024,
                                CUS025,CUS026,CUS027,CUS028,CUS029,CUS030,CUS031,CUS032,CUS033,CUS034,CUS037,
                                CUS038,CUS039,CUS040,CUS041,CUS042 FROM source_condo_spotlight_relationship_view;
    -- more columns here as needed

	-- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	TRUNCATE TABLE all_condo_spotlight_relationship;

	-- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO
			all_condo_spotlight_relationship(
				Condo_Code,
				PS001,
				PS002,
				PS003,
				PS006,
				PS007,
				PS008,
				PS009,
				PS016,
				PS017,
				PS019,
				PS021,
				PS022,
				PS024,
				PS025,
				PS026,
				CUS000,
				CUS001,
				CUS002,
				CUS003,
				CUS004,
				CUS005,
				CUS006,
				CUS007,
				CUS008,
				CUS009,
				CUS010,
				CUS011,
				CUS014,
				CUS015,
				CUS016,
				CUS017,
				CUS018,
				CUS019,
				CUS020,
				CUS021,
				CUS022,
				CUS023,
				CUS024,
				CUS025,
				CUS026,
				CUS027,
				CUS028,
				CUS029,
				CUS030,
				CUS031,
				CUS032,
				CUS033,
				CUS034,
				CUS037,
				CUS038,
                CUS039,
				CUS040,
                CUS041,
                CUS042,
                Top_Spotlight
			)
		VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41,v_name42,v_name43,v_name44,v_name45,v_name46,v_name47,v_name48,v_name49,v_name50,v_name51,v_name52,v_name53,v_name54,mySpotlight);
		GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

	if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

	-- Close the cursor
    CLOSE cur;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS ads_update_allspotlight;
DELIMITER //

CREATE PROCEDURE ads_update_allspotlight ()
BEGIN
    DECLARE i           INT DEFAULT 0;
	DECLARE total_rows  INT DEFAULT 0;
    DECLARE condo	    VARCHAR(50) DEFAULT 0;
    DECLARE mySpotlight	VARCHAR(500);

    DECLARE proc_name       VARCHAR(50) DEFAULT 'ads_update_allspotlight';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
	DECLARE errorcheck      BOOLEAN		DEFAULT 1;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR SELECT Condo_Code FROM all_condo_spotlight_relationship;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
			SET msg = CONCAT(msg,' AT ',condo);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
		set errorcheck = 0;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO condo;

        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL ads_getCondoTopSpotlight_all(condo, mySpotlight);
        UPDATE all_condo_spotlight_relationship
        SET Top_Spotlight = mySpotlight
        WHERE Condo_Code = condo;

        GET DIAGNOSTICS nrows = ROW_COUNT;
		SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
		SET code    = '00000';
		SET msg     = CONCAT(total_rows,' rows inserted.');
		INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
	end if;

    CLOSE cur;
END //
DELIMITER ;