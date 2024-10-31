-- check full_template
SELECT rc.Condo_Code
    , condo_enname.Condo_ENName
    , condo_thname.Condo_Name
    , year(cpc.Condo_Date_Calculate) as 'ปีเปิดตัว'
    , ifnull(fp.Floor_Plan,0) as 'Floor_Plan'
    , ifnull(v.Vector,0) as 'Vector'
    , ifnull(fi.Element,0) as 'Element'
    , concat('https://thelist.group/realist/condo/proj/',rc.Condo_URL_Tag,'-',rc.Condo_Code) as URL 
FROM real_condo rc
left join all_condo_price_calculate cpc on rc.Condo_Code = cpc.Condo_Code
left join (select Condo_Code
                , count(Floor_Plan_ID) as 'Floor_Plan'
            from full_template_floor_plan
            where Floor_Plan_Status = 1
            group by Condo_Code) fp
on rc.Condo_Code = fp.Condo_Code
left join (select Condo_Code
                , sum(Vector) as Vector
            from (select fp.Condo_Code
                    , fp.Floor_Plan_ID
                    , count(vr.Vector_ID) as Vector
                from full_template_floor_plan fp
                left join full_template_vector_floor_plan_relationship vr on fp.Floor_Plan_ID = vr.Floor_Plan_ID
                where fp.Floor_Plan_Status = 1
                and vr.Relationship_Status = 1
                group by fp.Condo_Code, fp.Floor_Plan_ID) a
            group by Condo_Code) v
on rc.Condo_Code = v.Condo_Code
left join (select Condo_Code
                , count(Element_ID) as 'Element'
            from full_template_element_image_view
            group by Condo_Code) fi
on rc.Condo_Code = fi.Condo_Code
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
on rc.Condo_Code = condo_enname.Condo_Code
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
on rc.Condo_Code = condo_thname.Condo_Code
where rc.Condo_Status = 1;


-- floor plan, vector
select rc.Condo_Code
	, fb.Total_Building
    , f.Floors as Total_Floor
    , floor_plan.Total_Floor_Plan
    , (floor_plan.Total_Floor_Plan * 100)/f.Floors as Floor_Plan_Cal
    , rc.Condo_TotalUnit
    , ifnull(v.Vectors,0) as Total_Vector
    , ifnull((v.Vectors * 100)/ rc.Condo_TotalUnit,0) as Vector_Cal
from real_condo rc
inner join (select Condo_Code
                , count(Building_ID) as Total_Building
            from full_template_building
            where Building_Status = 1
            group by Condo_Code) fb 
on rc.Condo_Code = fb.Condo_Code
left join (select fb.Condo_Code
                , count(ff.Floor_ID) as Floors
            from full_template_floor ff
            left join full_template_building fb on ff.Building_ID = fb.Building_ID
            where ff.Floor_Status = 1
            and fb.Building_Status = 1
            group by fb.Condo_Code) f
on fb.Condo_Code = f.Condo_Code
left join (select Condo_Code
                , count(Floor_Plan_ID) as Total_Floor_Plan
            from (select  fb.Condo_Code
                        , ff.Floor_ID
                        , ifnull(fp.Floor_Plan_ID,fp2.Floor_Plan_ID) as Floor_Plan_ID
                    from full_template_floor ff
                    left join full_template_building fb on ff.Building_ID = fb.Building_ID
                    left join (select Condo_Code
                                    , Floor_Plan_ID
                                from full_template_floor_plan
                                where Floor_Plan_Status = 1) fp
                    on ff.Floor_Plan_ID = fp.Floor_Plan_ID
                    left join (select Condo_Code
                                    , Floor_Plan_ID 
                                from (select Condo_Code
                                            , Floor_Plan_ID
                                            , ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Floor_Plan_Order) AS RowNum
                                        from full_template_floor_plan
                                        where Floor_Plan_Status = 1
                                        and Master_Plan = 1) a
                                where RowNum = 1) fp2
                    on fb.Condo_Code = fp2.Condo_Code
                    where ff.Floor_Status = 1
                    and fb.Building_Status = 1) a
            group by Condo_Code) floor_plan
on fb.Condo_Code = floor_plan.Condo_Code
left join (select Condo_Code
                , sum(Vectors) as Vectors
            from (SELECT fp.Condo_Code
                        , vr.Floor_Plan_ID
                        , count(vr.Ref_ID) * ifnull(count_floor.Floor,1) as Vectors
                    FROM full_template_vector_floor_plan_relationship vr
                    left join full_template_unit_type fu on vr.Ref_ID = fu.Unit_Type_ID and vr.Vector_Type = 1
                    left join full_template_floor_plan fp on vr.Floor_Plan_ID = fp.Floor_Plan_ID
                    left join (select Floor_Plan_ID
                                    , count(Floor_ID) as Floor
                                from full_template_floor
                                where Floor_Status = 1
                                group by Floor_Plan_ID) count_floor
                    on vr.Floor_Plan_ID = count_floor.Floor_Plan_ID
                    where vr.Relationship_Status = 1
                    and vr.Vector_Type = 1  
                    and fu.Unit_Type_Status = 1
                    and fp.Floor_Plan_Status = 1
                    group by fp.Condo_Code, vr.Floor_Plan_ID, count_floor.Floor) a
            group by Condo_Code
            order by Condo_Code) v
on fb.Condo_Code = v.Condo_Code
where rc.Condo_Status = 1
order by rc.Condo_Code;



-- element
select 
    fte.Condo_Code AS Condo_Code,
    count(DISTINCT fte.Element_ID) AS Total_Element,
    ifnull(image_element.Element_ID,0) as Have_Image,
    ifnull((image_element.Element_ID*100)/count(DISTINCT fte.Element_ID),0) as Element_Cal
from full_template_element AS fte
left join (select fte.Condo_Code AS Condo_Code,
                count(DISTINCT fte.Element_ID) AS Element_ID
            from full_template_element AS fte
            inner join full_template_image as fti on fte.Element_ID = fti.Element_ID
            where fte.Element_Status = 1
            and fti.Image_Status = 1
            group by fte.Condo_Code) image_element
on fte.Condo_Code = image_element.Condo_Code
where fte.Element_Status = 1
group by fte.Condo_Code
ORDER BY fte.Condo_Code;