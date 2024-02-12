-- source_all_price_view
-- source_new_condo_price_calculate_view

-- source_all_price_view
CREATE or replace VIEW `source_all_price_view` AS
select * from (select Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark
				from real_condo_price_new
				where Price_Status = '1') np
union select * from (select Condo_Code
						, Data_Value as Price
						, Data_Date as Price_Date
						, '0' as Condo_Build_Date
						, 'เฉลี่ย' as Start_or_Average
						, 1 as Price_Source
						, if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
						, '0' as Special
						, if(Data_Note = "",null,Data_Note) as Remark
					from real_condo_561
					where Data_Status = '1'
					and (Data_Attribute = 'price_per_sqm' or Data_Attribute = 'price_per_unit_mb')) rc561
union select * from (select Condo_Code
						, Data_Value as Price
						, Data_Date as Price_Date
						, '0' as Condo_Build_Date
						, 'เฉลี่ย' as Start_or_Average
						, 2 as Price_Source
						, 'บ/ตรม' as Price_Type
						, '0' as Special
						, Data_Note as Remark
					from real_condo_hipflat
					where Data_Attribute = 'price_per_sqm') hip;
-- wait union ddprice


-- source_new_condo_price_calculate_view
select a.Condo_Code
from real_condo a
WHERE a.Condo_Latitude is not null
AND a.Condo_Longitude is not null
AND a.Province_ID in (10, 11, 12, 13, 73, 74)
AND a.Condo_Status = 1
order by a.Condo_Code;