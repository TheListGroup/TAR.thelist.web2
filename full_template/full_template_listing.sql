select * 
from (SELECT *
    ,(if(Section_1_shortcut_Name is not null,1,0) 
        + if(Section_2_shortcut_Name is not null,1,0) 
        + if(Section_3_shortcut_Name is not null,1,0) 
        + if(Section_4_shortcut_Name is not null,1,0) 
        + if(Section_5_shortcut_Name is not null,1,0)) as cal 
    FROM `full_template_section_shortcut_view`) aaa 
where cal > 1;


SELECT ff.Condo_Code, bbb.condo_name
FROM `full_template_floor_plan` ff
left join full_template_vector_floor_plan_relationship fv on ff.Floor_Plan_ID = fv.Floor_Plan_ID
left join ( SELECT *
                ,(if(Section_1_shortcut_Name is not null,1,0) 
                + if(Section_2_shortcut_Name is not null,1,0) 
                + if(Section_3_shortcut_Name is not null,1,0) 
                + if(Section_4_shortcut_Name is not null,1,0) 
                + if(Section_5_shortcut_Name is not null,1,0)) as cal 
            FROM `full_template_section_shortcut_view`) aaa
on ff.Condo_Code = aaa.Condo_Code
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
            on cpc.Condo_Code = real_condo2.Condo_Code2
            where cpc.Condo_Status = 1) bbb
on ff.Condo_Code = bbb.Condo_Code
where ff.Floor_Plan_Status = 1
and fv.Vector_Type = 1
and fv.Relationship_Status = 1
and aaa.cal > 1
group by ff.Condo_Code,bbb.condo_name
order by ff.Condo_Code;