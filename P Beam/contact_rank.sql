-- นับลำดับคอนโดที่มีคนลงทะเบียน
-- นับลำดับห้องขายที่มีคนลงทะเบียน
-- นับลำดับห้องเช่าที่มีคนลงทะเบียน

-- นับลำดับคอนโดที่มีคนลงทะเบียน
SELECT a.Contact_Ref_ID as Condo_Code
	, condo_enname.Condo_ENName
    , condo_thname.Condo_Name
    , count(*) as Contact_Count
    , concat('https://thelist.group/realist/condo/proj/', rc.Condo_URL_Tag, '-', a.Contact_Ref_ID) as URL 
FROM `real_contact_form` a
left join real_condo rc on a.Contact_Ref_ID = rc.Condo_Code
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
on a.Contact_Ref_ID = condo_enname.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_Name1,'\n',1),' ',SUBSTRING_INDEX(Condo_Name1,'\n',-1))
                    , Condo_Name2) as Condo_Name,
                if(Condo_Name1 is not null
                    , SUBSTRING_INDEX(Condo_Name1,'\n',-1)
                    , '') as condo_location
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
on a.Contact_Ref_ID = condo_thname.Condo_Code
where a.Contact_Type = 'contact'
and year(a.Contact_Date) = 2024
group by a.Contact_Ref_ID, condo_enname.Condo_ENName, condo_thname.Condo_Name, rc.Condo_URL_Tag
ORDER BY `Contact_Count` DESC 
limit 10;

-- นับลำดับห้องขายที่มีคนลงทะเบียน
SELECT a.Contact_Ref_ID as Classified_ID
    , c.Condo_Code
    , condo_enname.Condo_ENName
    , condo_thname.Condo_Name
    , count(*) as Count_Contact
    , if(c.Classified_Status = '1'
        , concat('https://thelist.group/realist/condo/unit/', a.Contact_Ref_ID)
        , '') as URL
FROM `real_contact_form` a
left join classified c on a.Contact_Ref_ID = c.classified_ID
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
on c.Condo_Code = condo_enname.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_Name1,'\n',1),' ',SUBSTRING_INDEX(Condo_Name1,'\n',-1))
                    , Condo_Name2) as Condo_Name,
                if(Condo_Name1 is not null
                    , SUBSTRING_INDEX(Condo_Name1,'\n',-1)
                    , '') as condo_location
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
on c.Condo_Code = condo_thname.Condo_Code
where year(a.Contact_Date) = 2024
and a.Contact_Type = 'classified'
and a.Contact_Ref_ID <> ''
and c.Sale = 1
group by a.Contact_Ref_ID, c.Condo_Code, condo_enname.Condo_ENName, condo_thname.Condo_Name;

-- นับลำดับห้องเช่าที่มีคนลงทะเบียน
SELECT a.Contact_Ref_ID as Classified_ID
    , c.Condo_Code
    , condo_enname.Condo_ENName
    , condo_thname.Condo_Name
    , count(*) as Count_Contact
    , if(c.Classified_Status = '1'
        , concat('https://thelist.group/realist/condo/unit/', a.Contact_Ref_ID)
        , '') as URL
FROM `real_contact_form` a
left join classified c on a.Contact_Ref_ID = c.classified_ID
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
on c.Condo_Code = condo_enname.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_Name1,'\n',1),' ',SUBSTRING_INDEX(Condo_Name1,'\n',-1))
                    , Condo_Name2) as Condo_Name,
                if(Condo_Name1 is not null
                    , SUBSTRING_INDEX(Condo_Name1,'\n',-1)
                    , '') as condo_location
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
on c.Condo_Code = condo_thname.Condo_Code
where year(a.Contact_Date) = 2024
and a.Contact_Type = 'classified'
and a.Contact_Ref_ID <> ''
and c.Rent = 1
group by a.Contact_Ref_ID, c.Condo_Code, condo_enname.Condo_ENName, condo_thname.Condo_Name;