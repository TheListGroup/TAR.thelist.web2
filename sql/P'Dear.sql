SELECT ml.Line_Name
	,ms.Station_THName
    ,mr.Route_Name
    ,condo_enname.Condo_ENName
    ,condo_thname.Condo_Name
    ,ifnull(format(round(rcp.Price_Average_56_1_Square,-3),0),'') as Price_Average_Square
    ,ifnull(format(round(rcp.Price_Average_Resale_Square,-3),0),'') as Price_Average_Resale_Square
    ,ifnull(ifnull(format(round(rcp.Price_Start_Blogger_Square,-3),0),
        format(round(rcp.Price_Start_Day1_Square,-3),0)),'') as Price_Start_Square
    ,ifnull(stu.Sizes,'') as Studio_Size
    ,ifnull(1bed.Sizes,'') as 1Bed_Size
    ,concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',cpc.Condo_Code) as link
FROM `condo_price_calculate_view` cpc
left join real_condo_price rcp on cpc.Condo_Code = rcp.Condo_Code
left join condo_spotlight_relationship_view cs on cpc.Condo_Code = cs.Condo_Code
inner join condo_around_station ca on cpc.Condo_Code = ca.Condo_Code
left join mass_transit_line ml on ca.Line_Code = ml.Line_Code
left join mass_transit_station ms on ca.Station_Code = ms.Station_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
                    , Condo_ENName2) as Condo_ENName
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
            where cpc.Condo_Status = 1
            ORDER BY cpc.Condo_Code) condo_enname
on cpc.Condo_Code = condo_enname.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_Name1,'\n',1),' ',SUBSTRING_INDEX(Condo_Name1,'\n',-1))
                    , Condo_Name2) as Condo_Name
            FROM real_condo AS cpc
            left JOIN ( select Condo_Code as Condo_Code1
                            ,   Condo_Name as Condo_Name1
                        from real_condo
                        where Condo_Name LIKE '%\n%') real_condo1
            on cpc.Condo_Code = real_condo1.Condo_Code1
            left JOIN ( select Condo_Code as Condo_Code2
                            ,   Condo_Name as Condo_Name2
                        from real_condo
                        WHERE Condo_Name NOT LIKE '%\n%' 
                        AND Condo_Name NOT LIKE '%\r%') real_condo2
            on cpc.Condo_Code = real_condo2.Condo_Code2
            where cpc.Condo_Status = 1
            ORDER BY cpc.Condo_Code) condo_thname
on cpc.Condo_Code = condo_thname.Condo_Code
left join real_condo rc on cpc.Condo_Code = rc.Condo_Code
left join mass_transit_station_match_route mr on ca.Route_Code = mr.Route_Code
left join (SELECT Condo_Code,min(Size) as Sizes 
            FROM full_template_unit_type
            where Room_Type_ID = 1
            group by Condo_Code) stu
on cpc.Condo_Code = stu.Condo_Code
left join (SELECT Condo_Code,min(Size) as Sizes
            FROM full_template_unit_type
            where Room_Type_ID = 2
            group by Condo_Code) 1bed
on cpc.Condo_Code = 1bed.Condo_Code
where (cpc.Condo_Price_Per_Unit > 0 and cpc.Condo_Price_Per_Unit <= 2000000)
AND DATEDIFF(CURRENT_DATE,cpc.Condo_Date_Calculate) <= 1826  
and cs.CUS030 = 'Y'
group by ca.Line_Code,ml.Line_Name,ms.Station_THName,ca.Route_Code,mr.Route_Name,condo_enname.Condo_ENName
        ,condo_thname.Condo_Name,rc.Condo_URL_Tag,cpc.Condo_Code,ca.Station_Code,rcp.Price_Average_56_1_Square
        ,rcp.Price_Average_Resale_Square,rcp.Price_Start_Blogger_Square,rcp.Price_Start_Day1_Square
ORDER BY ca.Line_Code, ca.Station_Code, cpc.Condo_Code;


-- คอนโดยูนิตน้อย
SELECT a.Condo_Code , b.Condo_Name,b.Condo_TotalUnit, c.Condo_Price_Per_Square, c.Condo_Price_Per_Unit
FROM `all_condo_spotlight_relationship` a
left join real_condo b on a.Condo_Code = b.Condo_Code
left join all_condo_price_calculate c on a.Condo_Code = c.Condo_Code
WHERE a.`PS019` LIKE 'Y'  
ORDER BY `b`.`Condo_TotalUnit`  DESC;