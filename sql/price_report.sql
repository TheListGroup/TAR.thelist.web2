-- ปี
select year(a.Condo_Date_Calculate), aaa.Price_Start_Average, aaa.count_condo_average, bbb.Price_Start_Average as Price_Average, bbb.count_condo_average as count_average
from all_condo_price_calculate a
left join (SELECT year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Start_Average
                , count(bb.Price) as count_condo_average
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date) AS Myorder
                        FROM `all_price_view` ap
                        where ap.Start_or_AVG = 'เริ่มต้น'
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.HoldType_ID <> 2
            and rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            group by year(aa.Condo_Date_Calculate)
            order by year(aa.Condo_Date_Calculate)) aaa
on year(a.Condo_Date_Calculate) = aaa.Condo_Built_Start
left join (SELECT year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Start_Average
                , count(bb.Price) as count_condo_average
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date) AS Myorder
                        FROM `all_price_view` ap
                        where ap.Start_or_AVG = 'เฉลี่ย'
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.HoldType_ID <> 2
            and rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            group by year(aa.Condo_Date_Calculate)
            order by year(aa.Condo_Date_Calculate)) bbb
on year(a.Condo_Date_Calculate) = bbb.Condo_Built_Start
where a.Condo_Date_Calculate is not null
group by year(a.Condo_Date_Calculate),aaa.Price_Start_Average, aaa.count_condo_average,bbb.Price_Start_Average, bbb.count_condo_average
order by year(a.Condo_Date_Calculate);




-- ปี, ย่านหลัก
select rm.District_Name, year(a.Condo_Date_Calculate), aaa.Price_Start_Average, aaa.count_condo_average, bbb.Price_Start_Average, bbb.count_condo_average
from real_yarn_main rm
cross join all_condo_price_calculate a
left join (SELECT rm.District_Code, rm.District_Name
                , year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Start_Average
                , count(bb.Price) as count_condo_average
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join real_yarn_main rm on rc.RealDistrict_Code = rm.District_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date) AS Myorder
                        FROM `all_price_view` ap
                        where ap.Start_or_AVG = 'เริ่มต้น'
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.HoldType_ID <> 2
            and rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            and rc.RealDistrict_Code is not null
            and rc.RealDistrict_Code <> ''
            group by year(aa.Condo_Date_Calculate), rm.District_Code, rm.District_Name
            order by rm.District_Code, year(aa.Condo_Date_Calculate)) aaa
on rm.District_Code = aaa.District_Code and year(a.Condo_Date_Calculate) = aaa.Condo_Built_Start
left join (SELECT rm.District_Code, rm.District_Name
                , year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Start_Average
                , count(bb.Price) as count_condo_average
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join real_yarn_main rm on rc.RealDistrict_Code = rm.District_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date) AS Myorder
                        FROM `all_price_view` ap
                        where ap.Start_or_AVG = 'เฉลี่ย'
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.HoldType_ID <> 2
            and rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            and rc.RealDistrict_Code is not null
            and rc.RealDistrict_Code <> ''
            group by year(aa.Condo_Date_Calculate), rm.District_Code, rm.District_Name
            order by rm.District_Code, year(aa.Condo_Date_Calculate)) bbb
on rm.District_Code = bbb.District_Code and year(a.Condo_Date_Calculate) = bbb.Condo_Built_Start
where a.Condo_Date_Calculate is not null
and (aaa.Price_Start_Average is not null or bbb.Price_Start_Average is not null)
group by year(a.Condo_Date_Calculate), rm.District_Name, aaa.Price_Start_Average, aaa.count_condo_average,bbb.Price_Start_Average, bbb.count_condo_average
order by rm.District_Name, year(a.Condo_Date_Calculate);