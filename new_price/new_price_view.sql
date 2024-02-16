-- source_all_price_view
-- source_condo_price_calculate_view

-- source_all_price_view
CREATE or replace VIEW `source_all_price_view` AS
select * from (select Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Resale, Price_Source, Price_Type, Special, Remark
				from real_condo_price_new
				where Price_Status = '1') np
union all select * from (select Condo_Code
						, if(Data_Attribute='price_per_sqm',Data_Value,Data_Value*1000000) as Price
						, Data_Date as Price_Date
						, '0' as Condo_Build_Date
						, if(Data_Attribute='price_per_sqm','เฉลี่ย','เริ่มต้น') as Start_or_Average
						, '0' as Resale
						, 1 as Price_Source
						, if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
						, '0' as Special
						, if(Data_Note = "",null,Data_Note) as Remark
					from real_condo_561
					where Data_Status = '1'
					and (Data_Attribute = 'price_per_sqm' or Data_Attribute = 'price_per_unit_mb')) rc561
union all select * from (select Condo_Code
						, Data_Value as Price
						, Data_Date as Price_Date
						, '0' as Condo_Build_Date
						, 'เฉลี่ย' as Start_or_Average
						, '1' as Resale
						, 2 as Price_Source
						, 'บ/ตรม' as Price_Type
						, '0' as Special
						, Data_Note as Remark
					from real_condo_hipflat
					where Data_Attribute = 'price_per_sqm') hip;
-- wait union ddprice


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
	, if(cal56_1_sqm.Price is not null or cal_hip.Price is not null
		, 'ราคาเฉลี่ย'
		, if(cal_bgsq.Price is not null or cal_d1sq.Price is not null
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
		, ifnull(cal56_1_sqm.Price
			, ifnull(cal_hip.Price
				, ifnull(cal_bgsq.Price
					, cal_d1sq.Price)))
		, ifnull(cal_hip.Price
			, ifnull(cal56_1_sqm.Price
				, ifnull(cal_bgsq.Price
					, cal_d1sq.Price)))) as Condo_Price_Per_Square
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
		, if(cal56_1_sqm.Price is not null
			, cal56_1_sqm.Price_Date
			, if(cal_hip.Price is not null
				, cal_hip.Price_Date
				, if(cal_bgsq.Price is not null
					, cal_bgsq.Price_Date
					, if(cal_d1sq.Price is not null
						, cal_d1sq.Price_Date
						, null))))
		, if(cal_hip.Price is not null
			, cal_hip.Price_Date
			, if(cal56_1_sqm.Price is not null
				, cal56_1_sqm.Price_Date
				, if(cal_bgsq.Price is not null
					, cal_bgsq.Price_Date
					, if(cal_d1sq.Price is not null
						, cal_d1sq.Price_Date
						, null))))) as Condo_Price_Per_Square_Date
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
		, ifnull(cal56_1_sqm.Price_Source
			, ifnull(cal_hip.Price_Source
				, ifnull(cal_bgsq.Price_Source
					, cal_d1sq.Price_Source)))
		, ifnull(cal_hip.Price_Source
			, ifnull(cal56_1_sqm.Price_Source
				, ifnull(cal_bgsq.Price_Source
					, cal_d1sq.Price_Source)))) as Source_Condo_Price_Per_Square
	, if(cal_bg_u.Price is not null or cal_d1_u.Price is not null
		, 'ราคาเริ่มต้น'
		, if(cal56_1_u.Price is not null
			, 'ราคาเฉลี่ย'
			, '')) as Condo_Price_Per_Unit_Text
	, ifnull(cal_bg_u.Price
		, ifnull(cal_d1_u.Price, cal56_1_u.Price)) as Condo_Price_Per_Unit
	, if(cal_bg_u.Price is not null
		, cal_bg_u.Price_Date
		, if(cal_d1_u.Price is not null
			, cal_d1_u.Price_Date
			, if(cal56_1_u.Price is not null
				, cal56_1_u.Price_Date
				, null))) as Condo_Price_Per_Unit_Date
	, ifnull(cal_bg_u.Price_Source
		, ifnull(cal_d1_u.Price_Source, cal56_1_u.Price_Source)) as Source_Condo_Price_Per_Unit
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
		, ifnull(cal56_1_sqm.Price
			, cal_hip.Price)
		, ifnull(cal_hip.Price
			, cal56_1_sqm.Price)) as Condo_Price_Per_Square_New
	, ifnull(cal_bg_u.Price
		, cal_d1_u.Price) as Condo_Price_Per_Unit_New	
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
					where ap.Price_Source = 1
					and ap.Price_Type = 'บ/ตรม') order56_1_sqm
					where Myorder = 1) cal56_1_sqm
on a.Condo_Code = cal56_1_sqm.Condo_Code
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
					where ap.Price_Source = 2) order_hip
					where Myorder = 1) cal_hip
on a.Condo_Code = cal_hip.Condo_Code
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
					where ap.Price_Source = 4) order_bgsq
					where Myorder = 1) cal_bgsq
on a.Condo_Code = cal_bgsq.Condo_Code
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
					where ap.Price_Source = 5) order_d1sq
					where Myorder = 1) cal_d1sq
on a.Condo_Code = cal_d1sq.Condo_Code
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
					where ap.Price_Source = 6) order_bg_u
					where Myorder = 1) cal_bg_u
on a.Condo_Code = cal_bg_u.Condo_Code
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
					where ap.Price_Source = 7) order_d1_u
					where Myorder = 1) cal_d1_u
on a.Condo_Code = cal_d1_u.Condo_Code
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
					where ap.Price_Source = 1
					and ap.Price_Type = 'บ/ยูนิต') order56_1_u
					where Myorder = 1) cal56_1_u
on a.Condo_Code = cal56_1_u.Condo_Code
left join ( select Condo_Code, Data_Date, Data_Attribute, Data_Value, Data_Note, Price_Source
			from (	select rc561.Condo_Code
						, rc561.Data_Date
						, rc561.Data_Attribute
						, rc561.Data_Value
						, rc561.Data_Note
						, ps.Head as Price_Source
						, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Data_Date desc) AS Myorder
					from real_condo_561 rc561
					cross join (select ID, Head, Sub from price_source where ID = 1) ps
					where rc561.Data_Status = 1
					and rc561.Data_Attribute = 'sold_percent') order_561_mb
			where Myorder = 1) cal_561_mb
on a.Condo_Code = cal_561_mb.Condo_Code			
WHERE a.Condo_Latitude is not null
AND a.Condo_Longitude is not null
AND a.Province_ID in (10, 11, 12, 13, 73, 74)
AND a.Condo_Status = 1
order by a.Condo_Code;