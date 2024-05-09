-- source_classified_price
-- source_all_price_view
-- source_condo_price_calculate_view

-- source_classified_price
create or replace view source_classified_price as
select * from (select total_sale.Condo_Code
					, CURRENT_DATE as Data_Date
					, 'price_per_unit' as Data_Attribute
					, round(total_sale.Total_Price_Per_Unit_Sale,-4) as Data_Value
				from (select Condo_Code
							, SUM(Price_Sale*Size)/SUM(Size) as Total_Price_Per_Unit_Sale
							, SUM((Price_Sale/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Sale
							, count(*) as Total_Room_Count_Sale
							, AVG(Size) as Total_Average_Sqm_Sale
							, sum(Size) as Total_Total_Sqm_Sale
						from classified
						where Classified_Status = '1'
						and Sale = 1
						group by Condo_Code) total_sale
				where total_sale.Total_Room_Count_Sale >= 3) unit_sale
union all select * from (select total_sale.Condo_Code
							, CURRENT_DATE as Data_Date
							, 'price_per_sqm' as Data_Attribute
							, round(total_sale.Total_Price_Per_Unit_Sqm_Sale) as Data_Value
						from (select Condo_Code
									, SUM(Price_Sale*Size)/SUM(Size) as Total_Price_Per_Unit_Sale
									, SUM((Price_Sale/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Sale
									, count(*) as Total_Room_Count_Sale
									, AVG(Size) as Total_Average_Sqm_Sale
									, sum(Size) as Total_Total_Sqm_Sale
								from classified
								where Classified_Status = '1'
								and Sale = 1
								group by Condo_Code) total_sale
						where total_sale.Total_Room_Count_Sale >= 3) sqm_sale
union all select * from (select total_rent.Condo_Code
							, CURRENT_DATE as Data_Date
							, 'rent_per_unit' as Data_Attribute
							, round(total_rent.Total_Price_Per_Unit_Rent) as Data_Value
						from (select Condo_Code
									, SUM(Price_Rent*Size)/SUM(Size) as Total_Price_Per_Unit_Rent
									, SUM((Price_Rent/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Rent
									, count(*) as Total_Room_Count_Rent
									, AVG(Size) as Total_Average_Sqm_Rent
									, sum(Size) as Total_Total_Sqm_Rent
								from classified
								where Classified_Status = '1'
								and Rent = 1
								group by Condo_Code) total_rent
						where total_rent.Total_Room_Count_Rent >= 3) unit_rent
union all select * from (select total_rent.Condo_Code
							, CURRENT_DATE as Data_Date
							, 'rent_per_sqm' as Data_Attribute
							, round(total_rent.Total_Price_Per_Unit_Sqm_Rent) as Data_Value
						from (select Condo_Code
									, SUM(Price_Rent*Size)/SUM(Size) as Total_Price_Per_Unit_Rent
									, SUM((Price_Rent/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Rent
									, count(*) as Total_Room_Count_Rent
									, AVG(Size) as Total_Average_Sqm_Rent
									, sum(Size) as Total_Total_Sqm_Rent
								from classified
								where Classified_Status = '1'
								and Rent = 1
								group by Condo_Code) total_rent
						where total_rent.Total_Room_Count_Rent >= 3) sqm_rent;

-- source_all_price_view
CREATE or replace VIEW `source_all_price_view` AS
select * from (select Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Resale, Price_Source, Price_Type, Special, Remark
				from real_condo_price_new
				where Price_Status = '1') np
union all select * from (select Condo_Code
						, if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
						, Data_Date as Price_Date
						, '0' as Condo_Build_Date
						, 'เฉลี่ย' as Start_or_Average
						, '0' as Resale
						, 9 as Price_Source
						, if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
						, '0' as Special
						, null as Remark
					from real_condo_561
					where Data_Status = '1'
					and (Data_Attribute = 'price_per_sqm' or Data_Attribute = 'price_per_unit_mb')) rc561
union all select * from (select Condo_Code
						, Data_Value as Price
						, Data_Date as Price_Date
						, '0' as Condo_Build_Date
						, 'เฉลี่ย' as Start_or_Average
						, '1' as Resale
						, 13 as Price_Source
						, 'บ/ตรม' as Price_Type
						, '0' as Special
						, null as Remark
					from real_condo_hipflat
					where Data_Attribute = 'price_per_sqm') hip
union all select * from (select Condo_Code
							, Data_Value as Price
							, Data_Date as Price_Date
							, '0' as Condo_Build_Date
							, 'เฉลี่ย' as Start_or_Average
							, '1' as Resale
							, 14 as Price_Source
							, if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
							, '0' as Special
							, null as Remark
						from classified_price
						where (Data_Attribute = 'price_per_sqm' or Data_Attribute = 'price_per_unit')) classified;

-- source_condo_price_calculate_view
create or replace view source_condo_price_calculate_view as
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
		, ifnull(CASE
				WHEN COALESCE(resale.Price_Date, '1900-01-01') > GREATEST(COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01'), COALESCE(avg_compre_sqm.Price_Date, '1900-01-01'))
					THEN resale.Price
				WHEN COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') > COALESCE(avg_compre_sqm.Price_Date, '1900-01-01')
					THEN avg_dev_survey_sqm.Price
					ELSE avg_compre_sqm.Price
				END,ifnull(start_compre_sqm.Price, start_dev_survey_sqm.Price))) as Condo_Price_Per_Square
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
		, ifnull(CASE
				WHEN COALESCE(resale.Price_Date, '1900-01-01') > GREATEST(COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01'), COALESCE(avg_compre_sqm.Price_Date, '1900-01-01'))
					THEN resale.Price_Date
				WHEN COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') > COALESCE(avg_compre_sqm.Price_Date, '1900-01-01')
					THEN avg_dev_survey_sqm.Price_Date
					ELSE avg_compre_sqm.Price_Date
				END,ifnull(start_compre_sqm.Price_Date, start_dev_survey_sqm.Price_Date))) as Condo_Price_Per_Square_Date
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
		, ifnull(CASE
				WHEN COALESCE(resale.Price_Date, '1900-01-01') > GREATEST(COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01'), COALESCE(avg_compre_sqm.Price_Date, '1900-01-01'))
					THEN resale.Price_Source
				WHEN COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') > COALESCE(avg_compre_sqm.Price_Date, '1900-01-01')
					THEN avg_dev_survey_sqm.Price_Source
					ELSE avg_compre_sqm.Price_Source
				END,ifnull(start_compre_sqm.Price_Source, start_dev_survey_sqm.Price_Source))) as Source_Condo_Price_Per_Square
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
		, CASE
			WHEN COALESCE(resale_cal.Price_Date, '1900-01-01') > GREATEST(COALESCE(avg_dev_survey_sqm_cal.Price_Date, '1900-01-01'), COALESCE(avg_compre_sqm_cal.Price_Date, '1900-01-01'))
				THEN resale_cal.Price
			WHEN COALESCE(avg_dev_survey_sqm_cal.Price_Date, '1900-01-01') > COALESCE(avg_compre_sqm_cal.Price_Date, '1900-01-01')
				THEN avg_dev_survey_sqm_cal.Price
				ELSE avg_compre_sqm_cal.Price
			END) as Condo_Price_Per_Square_Cal
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
		, ifnull(CASE
				WHEN COALESCE(resale_cal.Price_Date, '1900-01-01') > GREATEST(COALESCE(avg_dev_survey_sqm_cal.Price_Date, '1900-01-01'), COALESCE(avg_compre_sqm_cal.Price_Date, '1900-01-01'))
					THEN resale_cal.Price
				WHEN COALESCE(avg_dev_survey_sqm_cal.Price_Date, '1900-01-01') > COALESCE(avg_compre_sqm_cal.Price_Date, '1900-01-01')
					THEN avg_dev_survey_sqm_cal.Price
					ELSE avg_compre_sqm_cal.Price
				END,ifnull(start_compre_sqm_cal.Price, start_dev_survey_sqm_cal.Price))) as Condo_Price_Per_Square_Sort
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
			from ( SELECT ap.Condo_Code, ap.Price, ap.Price_Date, ap.Condo_Build_Date, ap.Start_or_AVG, ps.Head as Price_Source
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
AND a.Province_ID in (10, 11, 12, 13, 73, 74)
AND a.Condo_Status = 1
order by a.Condo_Code;