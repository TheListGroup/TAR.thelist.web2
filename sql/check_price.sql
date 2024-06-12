select a.Condo_Code
	, if(a.Province_ID = 10 or a.Province_ID = 11 or a.Province_ID = 12 or a.Province_ID = 13 or a.Province_ID = 73 or a.Province_ID = 74
        , 'กทม./ปริ'
        , 'ตจว.') as Province
	, if(b.Condo_Built_Finished is not null
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
			, 'OLD')) as Old_or_New
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
            , 1
            , if(avg_dev_survey_sqm.Price is not null
                , 2
                , if(resale.Price is not null
                    , 3
                    , if(start_compre_sqm.Price is not null
                        , 4
                        , if(start_dev_survey_sqm.Price is not null
                            , 5
                            , null)))))
		, ifnull(CASE
				WHEN COALESCE(resale.Price_Date, '1900-01-01') > GREATEST(COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01'), COALESCE(avg_compre_sqm.Price_Date, '1900-01-01'))
					THEN 3
				WHEN COALESCE(avg_dev_survey_sqm.Price_Date, '1900-01-01') > COALESCE(avg_compre_sqm.Price_Date, '1900-01-01')
					THEN 2
				ELSE 
                    CASE 
                        WHEN avg_compre_sqm.Price is not null
                            THEN 1
                        WHEN start_compre_sqm.Price IS NOT NULL 
                            THEN 4
                        WHEN start_dev_survey_sqm.Price IS NOT NULL 
                            THEN 5
                        ELSE null
                    END
				END,NULL)) as Condo_Price_Per_Square
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
WHERE a.Condo_Latitude is not null
AND a.Condo_Longitude is not null
AND a.Condo_Status = 1
order by a.Condo_Code;