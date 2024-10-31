SELECT count(wp.ID) as Article
FROM wp_posts wp
where wp.post_status = 'publish';

select count(*)
from (select wpr.object_id 
        from wp_term_relationships wpr
        left join wp_term_taxonomy wtt on wpr.term_taxonomy_id = wtt.term_taxonomy_id
        left join wp_terms wt on wtt.term_id = wt.term_id
        left join wp_posts wp on wpr.object_id = wp.ID
        where wtt.term_id <> 461
        and wp.post_status = 'publish'
        group by wpr.object_id) a;


select count(*)
from (select wpr.object_id 
        from wp_term_relationships wpr
        left join wp_term_taxonomy wtt on wpr.term_taxonomy_id = wtt.term_taxonomy_id
        left join wp_terms wt on wtt.term_id = wt.term_id
        left join wp_posts wp on wpr.object_id = wp.ID
        where wtt.term_id = 461
        and wp.post_status = 'publish'
        group by wpr.object_id) a;


select count(*)
from real_condo
where Condo_Status = 1;


SELECT count(*)
FROM real_condo rc
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
where rc.Condo_Status = 1
and fp.Floor_Plan is null
and v.Vector is null
and fi.Element is null;


SELECT count(*)
FROM real_condo rc
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
where rc.Condo_Status = 1
and fp.Floor_Plan is not null
and v.Vector is not null
and fi.Element is not null;


SELECT count(*)
FROM real_condo rc
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
where rc.Condo_Status = 1
and (fp.Floor_Plan is not null or v.Vector is not null or fi.Element is not null);


select count(*)
from classified_user
where User_Status = '1'
and User_Type = 'Agent';


select count(*)
from classified c
left join classified_user cu on c.User_ID = cu.User_ID
where c.Classified_Status = '1'
and cu.User_Status = '1'
and cu.User_Type = 'Agent';


select count(*)
from classified_user
where User_Status = '1'
and User_Type = 'Member';


select count(*)
from classified c
left join classified_user cu on c.User_ID = cu.User_ID
where c.Classified_Status = '1'
and cu.User_Status = '1'
and cu.User_Type = 'Member';


select count(Condo_Code)
from (select Condo_Code
        from classified
        where Classified_Status = '1'
        group by Condo_Code) a