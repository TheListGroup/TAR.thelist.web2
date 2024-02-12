-- spotlights
SELECT year(b.Condo_Date_Calculate) as start_year, count(*) as Condo_Count
FROM `condo_spotlight_relationship_view` a
left join condo_price_calculate_view b on a.Condo_Code = b.Condo_Code
where a.PS002 = 'Y' -- เปลี่ยนเอา
and year(b.Condo_Date_Calculate) in ('2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022','2023')
group by year(b.Condo_Date_Calculate)
order by year(b.Condo_Date_Calculate)

-- segments
SELECT year(b.Condo_Date_Calculate) as start_year, count(*) as Condo_Count
FROM condo_price_calculate_view b
left join real_condo_price a on b.Condo_Code = a.Condo_Code
where year(b.Condo_Date_Calculate) in ('2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022','2023')
and a.Condo_Segment = 'SEG01'
group by year(b.Condo_Date_Calculate)
order by year(b.Condo_Date_Calculate);

-- price_range
SELECT year(b.Condo_Date_Calculate) as start_year, count(*) as Condo_Count
FROM condo_price_calculate_view b
left join real_condo_price a on b.Condo_Code = a.Condo_Code
where year(b.Condo_Date_Calculate) in ('2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022','2023')
and b.Condo_Price_Per_Unit > 40000000
group by year(b.Condo_Date_Calculate)
order by year(b.Condo_Date_Calculate);


SELECT cpc.Condo_Code, if(Condo_ENName1 is not null
        , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
        , Condo_ENName2) as Condo_Name,year(b.Condo_Date_Calculate) as 'Year'
FROM real_condo AS cpc
left JOIN ( select Condo_Code as Condo_Code1
                ,   Condo_ENName as Condo_ENName1
            from real_condo
            where Condo_ENName LIKE '%\n%') real_condo1
on cpc.Condo_Code = real_condo1.Condo_Code1
left JOIN ( select Condo_Code as Condo_Code2
                ,   Condo_ENName as Condo_ENName2
            from real_condo
            WHERE Condo_ENName NOT LIKE '%\n%' 
            AND Condo_ENName NOT LIKE '%\r%') real_condo2
on cpc.Condo_Code = real_condo2.Condo_Code2
INNER JOIN condo_price_calculate_view AS b ON b.Condo_Code = cpc.Condo_Code
where cpc.Condo_Status = 1
ORDER BY cpc.Condo_Code;