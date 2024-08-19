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





-- ราคา 1,2,3 ตามปีเปิดตัว
select year(a.Condo_Date_Calculate) as 'YEAR'
    , count(a.Condo_Code) as Condo_Count
    , ifnull(type1.count_condo_price1,"") as Count_Condo_Price1
    , ifnull(type1.Price_Type1_Average,"") as Price_Type1_Average
    , ifnull(type2.count_condo_price2,"") as Count_Condo_Price2
    , ifnull(type2.Price_Type2_Average,"") as Price_Type2_Average
    , ifnull(type3_hip.count_condo_hipflat,"") as Count_Condo_Hipflat
    , ifnull(type3_hip.Price_Hipflat_Average,"") as Price_Hipflat_Average
    , ifnull(type3_classified.count_condo_classified,"") as Count_Condo_Classified
    , ifnull(type3_classified.Price_Classified_Average,"") as Price_Classified_Average
    , ifnull(type3_classified.Total_Unit,"") as Total_Unit
from all_condo_price_calculate a
left join (SELECT year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Type1_Average
                -- , count(bb.Price) as count_condo_average
                , count(bb.Condo_Code) as count_condo_price1
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                        FROM `all_price_view` ap
                        left join price_source ps on ap.Price_Source = ps.ID
                        where ap.Start_or_AVG = 'เฉลี่ย'
                        and ps.Head = 'Company Presentation'
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        and ap.Resale = '0'
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            group by year(aa.Condo_Date_Calculate)
            order by year(aa.Condo_Date_Calculate)) type1
on year(a.Condo_Date_Calculate) = type1.Condo_Built_Start
left join (SELECT year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Type2_Average
                -- , count(bb.Price) as count_condo_average
                , count(bb.Condo_Code) as count_condo_price2
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                        FROM `all_price_view` ap
                        left join price_source ps on ap.Price_Source = ps.ID
                        where ap.Start_or_AVG = 'เฉลี่ย'
                        and ps.Head in ('Online Survey','Developer')
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        and ap.Resale = '0'
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            group by year(aa.Condo_Date_Calculate)
            order by year(aa.Condo_Date_Calculate)) type2
on year(a.Condo_Date_Calculate) = type2.Condo_Built_Start
left join (SELECT year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.Price*rc.Condo_TotalUnit)/SUM(rc.Condo_TotalUnit),2) as Price_Hipflat_Average
                -- , count(bb.Price) as count_condo_average
                , count(bb.Condo_Code) as count_condo_hipflat
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join (SELECT ap.Condo_Code, ap.Price, ap.Price_Date
                            , ROW_NUMBER() OVER (PARTITION BY ap.Condo_Code ORDER BY ap.Price_Date desc) AS Myorder
                        FROM `all_price_view` ap
                        left join price_source ps on ap.Price_Source = ps.ID
                        where ap.Start_or_AVG = 'เฉลี่ย'
                        and ap.Price_Type = 'บ/ตรม'
                        and ap.Price_Date is not null
                        and ap.Resale = '1'
                        and ps.Sub = 'Online Survey - Hipflat'
                        order by ap.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            and bb.Myorder = 1
            group by year(aa.Condo_Date_Calculate)
            order by year(aa.Condo_Date_Calculate)) type3_hip
on year(a.Condo_Date_Calculate) = type3_hip.Condo_Built_Start
left join (SELECT year(aa.Condo_Date_Calculate) as Condo_Built_Start
                , round(SUM(bb.cal_price)/SUM(bb.cal_size),2) as Price_Classified_Average
                , count(bb.Condo_Code) as count_condo_classified
                , sum(bb.Condo_TotalUnit) as Total_Unit
                , sum(count_classified) as Count_Classified
            FROM `all_condo_price_calculate` aa
            left join real_condo rc on aa.Condo_Code = rc.Condo_Code
            left join (SELECT a.Condo_Code,sum(a.Price_Sale) as cal_price, sum(a.Size) as cal_size, b.Condo_TotalUnit, count(a.Classified_ID) as count_classified
                        FROM `classified` a
                        left join real_condo b on a.Condo_Code = b.Condo_Code
                        where a.Classified_Status = '1'
                        and a.Sale = 1
                        and b.Condo_TotalUnit is not null
                        and b.Condo_TotalUnit <> 0
                        group by a.Condo_Code, b.Condo_TotalUnit
                        order by a.Condo_Code) bb
            on aa.Condo_Code = bb.Condo_Code
            where rc.Condo_TotalUnit is not null
            and rc.Condo_TotalUnit <> 0
            and aa.Condo_Date_Calculate is not null
            group by year(aa.Condo_Date_Calculate)
            order by year(aa.Condo_Date_Calculate)) type3_classified
on year(a.Condo_Date_Calculate) = type3_classified.Condo_Built_Start
where a.Condo_Date_Calculate is not null
group by year(a.Condo_Date_Calculate), type1.count_condo_price1, type1.Price_Type1_Average, type2.count_condo_price2, type2.Price_Type2_Average, type3_hip.count_condo_hipflat, type3_hip.Price_Hipflat_Average, type3_classified.count_condo_classified, type3_classified.Price_Classified_Average, type3_classified.Total_Unit
order by year(a.Condo_Date_Calculate);