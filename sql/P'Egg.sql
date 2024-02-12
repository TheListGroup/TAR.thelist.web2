SELECT fu.Condo_Code, fuf.Unit_Floor_Type_Name, if(fu.Unit_Floor_Type_ID<>1,format(count(*)/2,0),count(*)) as room_count
FROM `full_template_unit_type` fu
left join full_template_vector_floor_plan_relationship fv on fu.Unit_Type_ID = fv.Ref_ID
left join full_template_unit_floor_type fuf on fu.Unit_Floor_Type_ID = fuf.Unit_Floor_Type_ID
where fu.Condo_Code = 'CD3018'
and fv.Vector_Type = 1
and fv.Relationship_Status = 1
and fu.Unit_Type_Status = 1
group by fu.Condo_Code, fu.Unit_Floor_Type_ID;