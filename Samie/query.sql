-- province
-- district
-- subdistrict
-- segment
-- spotlight
-- Station 07,13
-- condo status 1

select * from (SELECT Housing_Name, count(*) as name_count
FROM `housing`
where Housing_Name is not null
and Housing_Status = '1' 
group by Housing_Name) aa
where name_count > 1;


select * from (SELECT Housing_ENName, count(*) as name_count
FROM `housing`
where Housing_ENName is not null
group by Housing_ENName) aa
where name_count > 1  
ORDER BY `aa`.`name_count`  DESC;


-- province
select name_th
    , name_en
    , concat('https://thelist.group/realist/condo/list/จังหวัด/',REGEXP_REPLACE(name_th,' ','-'),'/') as Province_URL
    , Condo_Count
from thailand_province
where Condo_Count > 0;

-- district
SELECT td.name_th AS name_th,
    td.name_en AS name_en,
    concat('https://thelist.group/realist/condo/list/จังหวัด/',tp.name_th,'/',td.name_th) AS District_URL
    , td.Condo_Count
FROM thailand_district td
left join thailand_province tp on td.province_id = tp.province_code
WHERE td.Condo_Count > 0
AND tp.Condo_Count > 0
and tp.province_code = 10;

-- subdistrict
select ts.name_th
    , ts.name_en
    , concat('https://thelist.group/realist/condo/list/จังหวัด/',REGEXP_REPLACE(tp.name_th,' ','-'),'/',REGEXP_REPLACE(td.name_th,' ','-'),'/',REGEXP_REPLACE(ts.name_th,' ','-')) as SubDistrict_URL
    , ts.Condo_Count
from thailand_subdistrict ts
left join thailand_district td on ts.district_id = td.district_code
left join thailand_province tp on td.province_id = tp.province_code
where td.Condo_Count > 0
and tp.Condo_Count > 0
and ts.Condo_Count > 0
and tp.province_code = 10;

-- segment
select Segment_Name
    , concat('https://thelist.group/realist/condo/list/segment/',REGEXP_REPLACE(Segment_Name,' ','-'),'/') as Segment_URL
    , Condo_Count
from real_condo_segment
where Condo_Count > 0
and Segment_Code = 'SEG06';

-- spotlight
select Spotlight_Name
    , concat('https://thelist.group/realist/condo/list/spotlight/',REGEXP_REPLACE(Spotlight_Name,' ','-'),'/') as Spotlight_URL
    , Condo_Count
from real_condo_spotlight
where Condo_Count > 0
and Spotlight_Code in ('CUS010','CUS032','CUS014','CUS030','CUS031','PS001','PS002','PS024');

-- Station 07,13
select ml.Line_Name
    , ml.Line_Name_Eng
    , ms.Station_THName
    , ms.Station_ENName
    , ms.Station_THName_Display
    , ms.Station_ENName_Display
    , concat('/realist/condo/list/รถไฟฟ้า/',REGEXP_REPLACE(ml.Line_Name,' ','-'),'/',REGEXP_REPLACE(ms.Station_THName_Display,' ','-')) as Station_URL
from mass_transit_station_match_route mtsm
left join mass_transit_route mr on mtsm.Route_Code = mr.Route_Code
left join mass_transit_line ml on mr.Line_Code = ml.Line_Code
left join mass_transit_station ms on mtsm.Station_Code = ms.Station_Code
where ms.Condo_Count > 0
and ml.Line_Code in ('LINE07','LINE13');

-- condo status 1
SELECT cpc.Condo_Code
    , condo_thname.Condo_Name
    , condo_enname.Condo_ENName
    , condo_thname.condo_location
    , b.Brand_Name
    , concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',cpc.Condo_Code) as URL 
FROM condo_price_calculate_view cpc
left join real_condo rc on cpc.Condo_Code = rc.Condo_Code
left join brand b on rc.Brand_Code = b.Brand_Code
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
on cpc.Condo_Code = condo_thname.Condo_Code
ORDER BY cpc.Condo_Code  ASC

-- article
SELECT po.post_title, po.post_date, concat('https://thelist.group/realist/blog/',po.post_name) as link, CAST(pm.meta_value AS SIGNED) as 'view'
FROM wp_postmeta pm
left join wp_posts po on pm.post_id = po.ID
WHERE pm.meta_key LIKE '_gapp_post_views'
and year(po.post_date) >= 2015
and po.post_type = 'post'
ORDER BY CAST(pm.meta_value AS SIGNED)  DESC;




SELECT ss.Condo_Code
    , condo_enname.Condo_ENName
    , condo_thname.Condo_Name
    , if(ff.Condo_Code is not null,'TRUE','FALSE') as Floor_Plan
    , if(ss.Article_Image is not null,'TRUE','FALSE') as Article
    , rc.Condo_LastUpdate as Condo_LastUpdate
FROM full_template_section_shortcut_view ss
left join real_condo rc on ss.Condo_Code = rc.Condo_Code
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
on ss.Condo_Code = condo_enname.Condo_Code
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
on ss.Condo_Code = condo_thname.Condo_Code
left join (select Condo_Code from full_template_floor_plan_fullscreen_view group by Condo_Code) ff
on ss.Condo_Code = ff.Condo_Code;

-- classified ขาย
select cpc.Condo_Code
	, condo_thname.Condo_Name
    , condo_enname.Condo_ENName
    , concat(b.Brand_Name,' ',condo_thname.condo_location) as name
	, concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',cpc.Condo_Code) as URL 
from (select Condo_Code
    from classified 
    where Classified_Status = '1'
    and Sale = 1
    group by Condo_Code) cpc
left join real_condo rc on cpc.Condo_Code = rc.Condo_Code
left join brand b on rc.Brand_Code = b.Brand_Code
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
on cpc.Condo_Code = condo_thname.Condo_Code;

-- classified เช่า
select cpc.Condo_Code
	, condo_thname.Condo_Name
    , condo_enname.Condo_ENName
    , concat(b.Brand_Name,' ',condo_thname.condo_location) as name
	, concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',cpc.Condo_Code) as URL 
from (select Condo_Code
    from classified 
    where Classified_Status = '1'
    and Rent = 1
    group by Condo_Code) cpc
left join real_condo rc on cpc.Condo_Code = rc.Condo_Code
left join brand b on rc.Brand_Code = b.Brand_Code
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
on cpc.Condo_Code = condo_thname.Condo_Code;


SELECT cpc.Condo_Code
	, condo_enname.Condo_ENName
    , condo_thname.Condo_Name
    , concat(condo_enname.Condo_ENName_Line1, ' ', condo_thname.condo_location) as format_name
    , concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',cpc.Condo_Code) as URL 
FROM condo_price_calculate_view cpc
left join real_condo rc on cpc.Condo_Code = rc.Condo_Code
left join ( SELECT cpc.Condo_Code, 
                if(Condo_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1))
                    , Condo_ENName2) as Condo_ENName,
                if(Condo_ENName1 is not null
                    , SUBSTRING_INDEX(Condo_ENName1,'\n',1)
                    , Condo_ENName2) as Condo_ENName_Line1,
                SUBSTRING_INDEX(Condo_ENName1,'\n',-1) as Condo_ENName_Line2
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
                    , Condo_Name2) as Condo_Name,
                if(Condo_Name1 is not null
                    , SUBSTRING_INDEX(Condo_Name1,'\n',-1)
                    , '') as condo_location,
                if(Condo_Name1 is not null
                    , SUBSTRING_INDEX(Condo_Name1,'\n',1)
                    , Condo_Name2) as Condo_Name_Line1,
                SUBSTRING_INDEX(Condo_Name1,'\n',-1) as Condo_Name_Line2
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
ORDER BY `cpc`.`Condo_Code` ASC




SELECT h.Housing_Code
    , h.Housing_TotalUnit
	, housing_enname.Housing_ENName
    , housing_thname.Housing_Name
    , housing_thname.Housing_Name_Line1 as 'Name'
    , housing_thname.Housing_Name_Line2 as 'Location'
    , concat('https://thelist.group/realist/condo/proj/',h.Housing_URL_Tag,'-',h.Housing_Code) as URL 
FROM housing h
left join ( SELECT h.Housing_Code, 
                if(Housing_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_ENName1,'\n',1),' ',SUBSTRING_INDEX(Housing_ENName1,'\n',-1))
                    , Housing_ENName2) as Housing_ENName,
                if(Housing_ENName1 is not null
                    , SUBSTRING_INDEX(Housing_ENName1,'\n',1)
                    , Housing_ENName2) as Housing_ENName_Line1,
                SUBSTRING_INDEX(Housing_ENName1,'\n',-1) as Housing_ENName_Line2
            FROM housing AS h
            left JOIN ( select Housing_Code as Housing_Code1
                            ,   Housing_ENName as Housing_ENName1
                        from housing
                        where Housing_ENName LIKE '%\n%') housing1
            on h.Housing_Code = housing1.Housing_Code1
            left JOIN ( select Housing_Code as Housing_Code2
                            ,   Housing_ENName as Housing_ENName2
                        from housing
                        WHERE Housing_ENName NOT LIKE '%\n%' 
                        AND Housing_ENName NOT LIKE '%\r%') housing2
            on h.Housing_Code = housing2.Housing_Code2
            where h.Housing_Status = '1'
            ORDER BY h.Housing_Code) housing_enname
on h.Housing_Code = housing_enname.Housing_Code
left join ( SELECT h.Housing_Code, 
                if(Housing_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_Name1,'\n',1),' ',SUBSTRING_INDEX(Housing_Name1,'\n',-1))
                    , Housing_Name2) as Housing_Name,
                if(Housing_Name1 is not null
                    , SUBSTRING_INDEX(Housing_Name1,'\n',-1)
                    , '') as housing_location,
                if(Housing_Name1 is not null
                    , SUBSTRING_INDEX(Housing_Name1,'\n',1)
                    , Housing_Name2) as Housing_Name_Line1,
                SUBSTRING_INDEX(Housing_Name1,'\n',-1) as Housing_Name_Line2
            FROM housing AS h
            left JOIN ( select Housing_Code as Housing_Code1
                            ,   Housing_Name as Housing_Name1
                        from housing
                        where Housing_Name LIKE '%\n%') housing1
            on h.Housing_Code = housing1.Housing_Code1
            left JOIN ( select Housing_Code as Housing_Code2
                            ,   Housing_Name as Housing_Name2
                        from housing
                        WHERE Housing_Name NOT LIKE '%\n%' 
                        AND Housing_Name NOT LIKE '%\r%') housing2
            on h.Housing_Code = housing2.Housing_Code2
            where h.Housing_Status = '1'
            ORDER BY h.Housing_Code) housing_thname
on h.Housing_Code = housing_thname.Housing_Code
where h.Developer_Code like 'DV0319%'
and h.Housing_Status = '1'
ORDER BY `h`.`Housing_Code` ASC



SELECT wp.post_date
    , wp.post_title
    , concat('https://thelist.group/realist/blog/', wp.post_name) as Link, category_blog.`Category`
    /*, count_view.post_view*/
FROM wp_posts wp
left join (SELECT pm.post_id , CAST(pm.meta_value AS SIGNED) as post_view 
            FROM wp_postmeta pm
            WHERE meta_key LIKE '_gapp_post_views') count_view
on wp.ID = count_view.post_id
left join (SELECT wp.ID as 'ID' 
            , group_concat(wt.name separator ', ') AS `Category`
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wp.post_status = 'publish'
            and wp.post_password = ''
            and wtt.taxonomy = 'category'
            group by wp.ID) category_blog
on wp.ID = category_blog.ID
WHERE wp.post_status='publish' 
and wp.post_type='post' 
and wp.post_password='' OR wp.ID = '185138' OR wp.ID = '185032' 
ORDER BY wp.post_date DESC;



SELECT h.Housing_Code
	, housing_enname.Housing_ENName
    , housing_thname.Housing_Name
    , concat(housing_enname.Housing_ENName_Line1, ' ', housing_thname.housing_location) as format_name
    , housing_thname.housing_location as thai_location
    , concat('https://thelist.group/realist/housing/proj/',h.Housing_URL_Tag) as URL 
FROM housing h
left join ( SELECT h.Housing_Code, 
                if(Housing_ENName1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_ENName1,'\n',1),' ',SUBSTRING_INDEX(Housing_ENName1,'\n',-1))
                    , Housing_ENName2) as Housing_ENName,
                if(Housing_ENName1 is not null
                    , SUBSTRING_INDEX(Housing_ENName1,'\n',1)
                    , Housing_ENName2) as Housing_ENName_Line1,
                SUBSTRING_INDEX(Housing_ENName1,'\n',-1) as Housing_ENName_Line2
            FROM housing AS h
            left JOIN ( select Housing_Code as Housing_Code1
                            ,   Housing_ENName as Housing_ENName1
                        from housing
                        where Housing_ENName LIKE '%\n%') housing1
            on h.Housing_Code = housing1.Housing_Code1
            left JOIN ( select Housing_Code as Housing_Code2
                            ,   Housing_ENName as Housing_ENName2
                        from housing
                        WHERE Housing_ENName NOT LIKE '%\n%' 
                        AND Housing_ENName NOT LIKE '%\r%') housing2
            on h.Housing_Code = housing2.Housing_Code2
            where h.Housing_Status = '1'
            ORDER BY h.Housing_Code) housing_enname
on h.Housing_Code = housing_enname.Housing_Code
left join ( SELECT h.Housing_Code, 
                if(Housing_Name1 is not null
                    , CONCAT(SUBSTRING_INDEX(Housing_Name1,'\n',1),' ',SUBSTRING_INDEX(Housing_Name1,'\n',-1))
                    , Housing_Name2) as Housing_Name,
                if(Housing_Name1 is not null
                    , SUBSTRING_INDEX(Housing_Name1,'\n',-1)
                    , '') as housing_location,
                if(Housing_Name1 is not null
                    , SUBSTRING_INDEX(Housing_Name1,'\n',1)
                    , Housing_Name2) as Housing_Name_Line1,
                SUBSTRING_INDEX(Housing_Name1,'\n',-1) as Housing_Name_Line2
            FROM housing AS h
            left JOIN ( select Housing_Code as Housing_Code1
                            ,   Housing_Name as Housing_Name1
                        from housing
                        where Housing_Name LIKE '%\n%') housing1
            on h.Housing_Code = housing1.Housing_Code1
            left JOIN ( select Housing_Code as Housing_Code2
                            ,   Housing_Name as Housing_Name2
                        from housing
                        WHERE Housing_Name NOT LIKE '%\n%' 
                        AND Housing_Name NOT LIKE '%\r%') housing2
            on h.Housing_Code = housing2.Housing_Code2
            where h.Housing_Status = '1'
            ORDER BY h.Housing_Code) housing_thname
on h.Housing_Code = housing_thname.Housing_Code
where h.Housing_Status = '1'
ORDER BY `h`.`Housing_Code` ASC

-- housing_spotlight
select hs.Spotlight_Code
    , hs.Spotlight_Name
    , concat("https://thelist.group/realist/housing/list/spotlight/",hs.Spotlight_Name) as 'Link'
from housing_spotlight hs
where hs.Spotlight_Inactive = 0
union all
select 'SH'
    , 'บ้านเดี่ยว'
    , concat("https://thelist.group/realist/housing/single-detached-house") as 'Link'
union all
select 'single-detached-house'
    , replace(hs.Spotlight_Title,"{type}","บ้านเดี่ยว")
    , concat("https://thelist.group/realist/housing/single-detached-house/list/spotlight/",hs.Spotlight_Name) as 'Link'
from housing_spotlight hs
where hs.Spotlight_Inactive = 0
union all
select 'DD'
    , 'บ้านเดี่ยว'
    , concat("https://thelist.group/realist/housing/semi-detached-house") as 'Link'
union all
select 'semi-detached-house'
    , replace(hs.Spotlight_Title,"{type}","บ้านแฝด")
    , concat("https://thelist.group/realist/housing/semi-detached-house/list/spotlight/",hs.Spotlight_Name) as 'Link'
from housing_spotlight hs
where hs.Spotlight_Inactive = 0
union all
select 'TH'
    , 'ทาวน์โฮม'
    , concat("https://thelist.group/realist/housing/townhome") as 'Link'
union all
select 'townhome'
    , replace(hs.Spotlight_Title,"{type}","ทาวน์โฮม")
    , concat("https://thelist.group/realist/housing/townhome/list/spotlight/",hs.Spotlight_Name) as 'Link'
from housing_spotlight hs
where hs.Spotlight_Inactive = 0
union all
select 'HO'
    , 'โฮมออฟฟิศ'
    , concat("https://thelist.group/realist/housing/home-office") as 'Link'
union all
select 'home-office'
    , replace(hs.Spotlight_Title,"{type}","โฮมออฟฟิศ")
    , concat("https://thelist.group/realist/housing/home-office/list/spotlight/",hs.Spotlight_Name) as 'Link'
from housing_spotlight hs
where hs.Spotlight_Inactive = 0
union all
select 'SH'
    , 'อาคารพาณิชย์'
    , concat("https://thelist.group/realist/housing/shophouse") as 'Link'
union all
select 'shophouse'
    , replace(hs.Spotlight_Title,"{type}","อาคารพาณิชย์")
    , concat("https://thelist.group/realist/housing/shophouse/list/spotlight/",hs.Spotlight_Name) as 'Link'
from housing_spotlight hs
where hs.Spotlight_Inactive = 0;


SELECT 
  wp.ID, 
  wp.post_date, 
  wp.post_title,
  ifnull(pm.aaa_condo,'') as Condo_Code,
  tag_type.tag_name,
  CONCAT('https://thelist.group/realist/blog/', wp.post_name) AS Link
FROM wp_posts wp
left join (select post_id, group_concat(meta_value separator ', ') AS aaa_condo
          from wp_postmeta 
          where meta_key = 'aaa_condo'
          and meta_value <> ''
          group by post_id) pm
on wp.ID = pm.post_id
LEFT JOIN (select wpr.object_id, group_concat(wt.name separator ', ') as tag_name 
          from wp_term_relationships wpr
          left join wp_term_taxonomy wtt on wpr.term_taxonomy_id = wtt.term_taxonomy_id
          left join wp_terms wt on wtt.term_id = wt.term_id
          -- where wtt.term_id in (6,7,156,760,867,869,972)
          group by wpr.object_id) tag_type
ON wp.ID = tag_type.object_id
WHERE wp.post_status = 'publish'
AND wp.post_password = ''
and tag_type.tag_name is not null
ORDER BY wp.ID DESC;