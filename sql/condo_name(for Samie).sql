SELECT cpc.Condo_Code, 
    if(Condo_ENName1 is not null
        , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
        , Condo_ENName2) as condo_name,
    year(rcp.Condo_Built_Start) AS 'ปีเปิดตัว'
FROM condo_price_calculate_view AS cpc
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
INNER JOIN real_condo_price AS rcp ON rcp.Condo_Code = cpc.Condo_Code
ORDER BY cpc.Condo_Code;


-- condo_name
SELECT cpc.Condo_Code, 
    if(Condo_ENName1 is not null
        , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
        , Condo_ENName2) as condo_name,
        if(rcp.Condo_Built_Start is not null,
            year(rcp.Condo_Built_Start)
            ,if(rcp.Condo_Built_Finished is not null
                ,if(cpc.Condo_HighRise = 1
                    ,year(rcp.Condo_Built_Finished) - 4
                    ,year(rcp.Condo_Built_Finished) - 3)
                ,null)) AS 'ปีเปิดตัว'
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
INNER JOIN real_condo_price AS rcp ON rcp.Condo_Code = cpc.Condo_Code
where cpc.Condo_Status = 1
ORDER BY cpc.Condo_Code;


-- price null
SELECT cpc.Condo_Code,name_condo.condo_name,cpc.Condo_Price_Per_Square_New,cpc.Condo_Price_Per_Unit_New,cpc.Condo_Date_Calculate
FROM `condo_price_calculate_view` cpc
left join (SELECT cpc.Condo_Code, 
                if(Condo_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
                    , Condo_ENName2) as condo_name
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
			on cpc.Condo_Code = real_condo2.Condo_Code2) name_condo
on cpc.Condo_Code = name_condo.Condo_Code
WHERE (cpc.`Condo_Price_Per_Square_New` IS NULL) OR (cpc.`Condo_Price_Per_Unit_New` IS NULL) 
ORDER BY cpc.Condo_Date_Calculate desc,cpc.Condo_Code desc;


-- 10 ล้าน
SELECT cpc.Condo_Code, condo_enname.Condo_ENName, cpc.Condo_Price_Per_Unit_Text, cpc.Condo_Price_Per_Unit, cpc.Condo_Price_Per_Unit_Date
FROM `condo_price_calculate_view` cpc
left join condo_spotlight_relationship_view csr on cpc.Condo_Code = csr.Condo_Code
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
where csr.CUS023 = 'Y';

-- 20 ล้าน
SELECT cpc.Condo_Code, condo_enname.Condo_ENName, cpc.Condo_Price_Per_Unit_Text, cpc.Condo_Price_Per_Unit, cpc.Condo_Price_Per_Unit_Date
FROM `condo_price_calculate_view` cpc
left join condo_spotlight_relationship_view csr on cpc.Condo_Code = csr.Condo_Code
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
where csr.CUS024 = 'Y';

-- 40 ล้าน
SELECT cpc.Condo_Code, condo_enname.Condo_ENName, cpc.Condo_Price_Per_Unit_Text, cpc.Condo_Price_Per_Unit, cpc.Condo_Price_Per_Unit_Date
FROM `condo_price_calculate_view` cpc
left join condo_spotlight_relationship_view csr on cpc.Condo_Code = csr.Condo_Code
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
where csr.CUS025 = 'Y';


select Brand_Name
	, concat('https://thelist.group/realist/condo/list/brand/',REGEXP_REPLACE(Brand_Name,' ','-'),'/') as Brand_URL
    , Condo_Count
from brand
where Brand_Status = 1
and Condo_Count > 1;