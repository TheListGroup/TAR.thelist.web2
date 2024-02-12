-- clean building
update full_template_building
set Building_Name = REGEXP_REPLACE(Building_Name, 'Building ', '')
where Building_Name like 'Building%';

-- clean floor_plan
update full_template_floor_plan
set Floor_Plan_Name = REGEXP_REPLACE(Floor_Plan_Name, '[A-z]+-', '')
where Condo_Code in ( SELECT Condo_Code
                    FROM full_template_building
                    WHERE Building_Status = 1
                    GROUP BY Condo_Code
                    HAVING COUNT(Building_ID) = 1);

update full_template_floor_plan
set Floor_Plan_Name = REGEXP_REPLACE(Floor_Plan_Name, 'fl-', '')
where Floor_Plan_Name like 'fl-%';

-- clean unit_type
update full_template_unit_type
set Unit_Type_Name = null
where Unit_Type_Name = '';


select fu.Unit_Type_ID,fu.Unit_Type_Name,fu.Room_Type_ID,fu.Room_Plus,fu.BathRoom,fu.Unit_Floor_Type_ID,fu.Size,fu.Condo_Code,n.same_name ,v.Vector
from full_template_unit_type fu
left join (SELECT Condo_Code,Unit_Type_Name,COUNT(Unit_Type_Name) as same_name
            FROM `full_template_unit_type`  
            where Unit_Type_Status = 1
            and Unit_Type_Name is not null
            group by Condo_Code,Unit_Type_Name) n
on fu.Unit_Type_Name = n.Unit_Type_Name
and fu.Condo_Code = n.Condo_Code
left join (SELECT Ref_ID,count(Vector_ID) as vector 
            FROM `full_template_vector_floor_plan_relationship` 
            where Relationship_Status = 1
            and Vector_Type = 1
            group by Ref_ID
            ORDER BY Ref_ID) v
on fu.Unit_Type_ID = v.Ref_ID
where n.same_name > 1
and fu.Unit_Type_Status = 1
order by fu.Condo_Code,fu.Unit_Type_Name,fu.Size;

-- ใช้ดูว่าคอนโดไหน มีห้อง มีวาด มี floor_plan
select fu.Condo_Code,count(fu.Unit_Type_ID),sum(v.Vector),sum(fp.fpp)
from full_template_unit_type fu
left join (select Condo_Code,count(Floor_Plan_ID) as fpp
            from full_template_floor_plan
            where Floor_Plan_Status = 1
            group by Condo_Code) fp
on fu.Condo_Code = fp.Condo_Code
left join (SELECT vf.Ref_ID,count(vf.Vector_ID) as vector 
            FROM full_template_vector_floor_plan_relationship vf
            left join full_template_floor_plan fp on vf.Floor_Plan_ID = fp.Floor_Plan_ID
            where vf.Relationship_Status = 1
            and vf.Vector_Type = 1
            and fp.Floor_Plan_Status = 1
            group by vf.Ref_ID
            ORDER BY vf.Ref_ID) v
on fu.Unit_Type_ID = v.Ref_ID
where  fu.Unit_Type_Status = 1 
group by fu.Condo_Code;

-- ลบ Unit_Type ชื่อซ้ำ ที่ไม่มี Vector (เปลี่ยน Status)
update full_template_unit_type
set Unit_Type_Status = 2
where Unit_Type_ID in (select Unit_Type_ID 
                        from (select fu.Unit_Type_ID,fu.Unit_Type_Name,fu.Room_Type_ID,fu.Room_Plus,fu.BathRoom,fu.Unit_Floor_Type_ID,fu.Size,fu.Condo_Code,n.same_name ,v.Vector
                                from full_template_unit_type fu
                                left join (SELECT Condo_Code,Unit_Type_Name,COUNT(Unit_Type_Name) as same_name
                                            FROM `full_template_unit_type`  
                                            where Unit_Type_Status = 1
                                            and Unit_Type_Name is not null
                                            group by Condo_Code,Unit_Type_Name) n
                                on fu.Unit_Type_Name = n.Unit_Type_Name
                                and fu.Condo_Code = n.Condo_Code
                                left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                            FROM `full_template_vector_floor_plan_relationship` 
                                            where Relationship_Status = 1
                                            and Vector_Type = 1
                                            group by Ref_ID
                                            ORDER BY Ref_ID) v
                                on fu.Unit_Type_ID = v.Ref_ID
                                where n.same_name > 1
                                and v.Vector is null
                                and fu.Unit_Type_Status = 1
                                order by fu.Condo_Code,fu.Unit_Type_Name,fu.Size) ut);

-- ลบ Unit_Type ที่ดูดมาจากของเก่า ที่ไม่มี floor_plan
update full_template_unit_type
set Unit_Type_Status = 0
where Unit_Type_ID in (select Unit_Type_ID 
                        from (select fu.Unit_Type_ID,fu.Unit_Type_Name,fu.Room_Type_ID,fu.Room_Plus,fu.BathRoom,fu.Unit_Floor_Type_ID,fu.Size,fu.Condo_Code,v.Vector,fp.fpp
                                from full_template_unit_type fu
                                left join (select Condo_Code,count(Floor_Plan_ID) as fpp
                                            from full_template_floor_plan
                                            where Floor_Plan_Status = 1
                                            group by Condo_Code) fp
                                on fu.Condo_Code = fp.Condo_Code
                                            left join (SELECT vf.Ref_ID,count(vf.Vector_ID) as vector 
                                            FROM full_template_vector_floor_plan_relationship vf
                                            left join full_template_floor_plan fp on vf.Floor_Plan_ID = fp.Floor_Plan_ID
                                            where vf.Relationship_Status = 1
                                            and vf.Vector_Type = 1
                                            and fp.Floor_Plan_Status = 1
                                            group by vf.Ref_ID
                                            ORDER BY vf.Ref_ID) v
                                on fu.Unit_Type_ID = v.Ref_ID
                                where fp.fpp is null  
                                and fu.Unit_Type_Status <> 2) ut);

-- ชื่อซ้ำ ทำให้เหลืออันเดียว โดยเฉลี่ยขนาด ลบอันที่เหลือ เปลี่ยน vector
DROP PROCEDURE IF EXISTS format_unit_type;
DELIMITER //

CREATE PROCEDURE format_unit_type ()
BEGIN
    DECLARE done               INTEGER      DEFAULT FALSE;
    Declare each_name          VARCHAR(250) DEFAULT NULL;
    Declare each_code          VARCHAR(250) DEFAULT NULL;
    Declare each_samename      INTEGER      DEFAULT 0;
    Declare each_size          FLOAT(8,3)   DEFAULT 0;
    Declare each_vector        INTEGER      DEFAULT 0;
    Declare each_id            VARCHAR(250) DEFAULT NULL;

    DECLARE cur_UnitType CURSOR FOR  select * from (select Unit_Type_Name,Condo_Code,same_name,avg(Size) as Size,max(Vector) as Vector 
                                                    from (select fu.Unit_Type_Name,fu.Size,fu.Condo_Code,n.same_name,v.Vector
                                                            from full_template_unit_type fu
                                                            left join (SELECT Condo_Code,Unit_Type_Name,COUNT(Unit_Type_Name) as same_name
                                                                        FROM `full_template_unit_type`  
                                                                        where Unit_Type_Status = 1
                                                                        and Unit_Type_Name is not null
                                                                        group by Condo_Code,Unit_Type_Name) n
                                                            on fu.Unit_Type_Name = n.Unit_Type_Name
                                                            and fu.Condo_Code = n.Condo_Code
                                                            left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                                        FROM `full_template_vector_floor_plan_relationship` 
                                                                        where Relationship_Status = 1
                                                                        and Vector_Type = 1
                                                                        group by Ref_ID
                                                                        ORDER BY Ref_ID) v
                                                            on fu.Unit_Type_ID = v.Ref_ID
                                                            where n.same_name > 1
                                                            and fu.Unit_Type_Status = 1
                                                            order by fu.Condo_Code,fu.Unit_Type_Name,fu.Size) aa
                                                    group by Unit_Type_Name,Condo_Code
                                                    order by Condo_Code,Unit_Type_Name) main;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    open cur_UnitType;
    
    read_loop: LOOP
        FETCH cur_UnitType INTO each_name,each_code,each_samename,each_size,each_vector;

        IF done THEN
            LEAVE read_loop;
        END IF;

        set each_id = (select Unit_Type_ID from (select fu.Unit_Type_ID,v.vector from full_template_unit_type fu 
                                                left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                            FROM `full_template_vector_floor_plan_relationship` 
                                                            where Relationship_Status = 1
                                                            and Vector_Type = 1
                                                            group by Ref_ID
                                                            ORDER BY Ref_ID) v
                                                on fu.Unit_Type_ID = v.Ref_ID
                                                where fu.Unit_Type_Name = each_name and fu.Condo_Code = each_code and fu.Unit_Type_Status = 1) aa
                        where aa.vector = each_vector order by Unit_Type_ID limit 1);

        update full_template_unit_type set Size = each_size,Last_Updated_Date = CURRENT_TIMESTAMP where Unit_Type_ID = each_id;
        update full_template_vector_floor_plan_relationship set Ref_ID = each_id,Last_Updated_Date = CURRENT_TIMESTAMP 
        where Vector_Type = 1 
        and Ref_ID in (select Unit_Type_ID from (select fu.Unit_Type_ID,v.vector from full_template_unit_type fu 
                                                left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                            FROM `full_template_vector_floor_plan_relationship` 
                                                            where Relationship_Status = 1
                                                            and Vector_Type = 1
                                                            group by Ref_ID
                                                            ORDER BY Ref_ID) v
                                                on fu.Unit_Type_ID = v.Ref_ID
                                                where fu.Unit_Type_Name = each_name and fu.Condo_Code = each_code and fu.Unit_Type_Status = 1) aa
                        where Unit_Type_ID not in (each_id));
        update full_template_unit_type set Unit_Type_Status = 2,Last_Updated_Date = CURRENT_TIMESTAMP where Unit_Type_Name = each_name 
        and Condo_Code = each_code and Unit_Type_ID <> each_id and Unit_Type_Status = 1;
    END LOOP;

END //
DELIMITER ;


DROP PROCEDURE IF EXISTS format_unit_type_2;
DELIMITER //

CREATE PROCEDURE format_unit_type_2 ()
BEGIN
    DECLARE done               INTEGER      DEFAULT FALSE;
    Declare each_code          VARCHAR(250) DEFAULT NULL;
    Declare each_roomtype      INTEGER      DEFAULT 0;
    Declare each_name          VARCHAR(250) DEFAULT NULL;
    Declare each_newname       VARCHAR(250) DEFAULT NULL;
    Declare each_vector        INTEGER      DEFAULT 0;
    Declare each_id            VARCHAR(250) DEFAULT NULL;
    Declare each_size          FLOAT(8,3)   DEFAULT 0;

    DECLARE cur_UnitType CURSOR FOR  select * from (select Condo_Code,Room_Type_ID,name,count(name)  as new_name
                                                    from (SELECT Condo_Code,Room_Type_ID,Unit_Type_Name,SUBSTRING(Unit_Type_Name, 1, LENGTH(Unit_Type_Name) - 1) as name
                                                            FROM `full_template_unit_type`  
                                                            where Unit_Type_Status = 1
                                                            and Unit_Type_Name is not null
                                                            order by Condo_Code) aaa
                                                    group by Condo_Code,Room_Type_ID,name) bbb
                                    where new_name > 1
                                    and name <> ''
                                    order by Condo_Code,name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    open cur_UnitType;
    
    read_loop: LOOP
        FETCH cur_UnitType INTO each_code,each_roomtype,each_name,each_newname;

        IF done THEN
            LEAVE read_loop;
        END IF;

        set each_vector = (select max(vector) from (select fu.Unit_Type_ID,fu.Unit_Type_Image,fu.Size,v.vector
                                                    from full_template_unit_type fu
                                                    left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                            FROM `full_template_vector_floor_plan_relationship` 
                                                            where Relationship_Status = 1
                                                            and Vector_Type = 1
                                                            group by Ref_ID
                                                            ORDER BY Ref_ID) v
                                                    on fu.Unit_Type_ID = v.Ref_ID
                                                    where SUBSTRING(Unit_Type_Name, 1, LENGTH(Unit_Type_Name) - 1) = each_name
                                                    and fu.Condo_Code = each_code
                                                    and fu.Room_Type_ID = each_roomtype
                                                    and fu.Unit_Type_Status = 1
                                                    group by fu.Unit_Type_ID,fu.Unit_Type_Image,fu.Size) aaa);

        set each_id = (select Unit_Type_ID from (select fu.Unit_Type_ID,fu.Unit_Type_Image,fu.Size,v.vector
                                                from full_template_unit_type fu
                                                left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                        FROM `full_template_vector_floor_plan_relationship` 
                                                        where Relationship_Status = 1
                                                        and Vector_Type = 1
                                                        group by Ref_ID
                                                        ORDER BY Ref_ID) v
                                                on fu.Unit_Type_ID = v.Ref_ID
                                                where SUBSTRING(Unit_Type_Name, 1, LENGTH(Unit_Type_Name) - 1) = each_name
                                                and fu.Condo_Code = each_code
                                                and fu.Room_Type_ID = each_roomtype
                                                and fu.Unit_Type_Status = 1
                                                group by fu.Unit_Type_ID,fu.Unit_Type_Image,fu.Size
                                                ) unit
                        where unit.vector = each_vector order by Unit_Type_ID desc limit 1);

        set each_size = (select avg(Size) from (select fu.Unit_Type_ID,fu.Unit_Type_Image,fu.Size,v.vector
                                                from full_template_unit_type fu
                                                left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                        FROM `full_template_vector_floor_plan_relationship` 
                                                        where Relationship_Status = 1
                                                        and Vector_Type = 1
                                                        group by Ref_ID
                                                        ORDER BY Ref_ID) v
                                                on fu.Unit_Type_ID = v.Ref_ID
                                                where SUBSTRING(Unit_Type_Name, 1, LENGTH(Unit_Type_Name) - 1) = each_name
                                                and fu.Condo_Code = each_code
                                                and fu.Room_Type_ID = each_roomtype
                                                and fu.Unit_Type_Status = 1
                                                group by fu.Unit_Type_ID,fu.Unit_Type_Image,fu.Size
                                                ) unit);
        
        update full_template_unit_type set Size = each_size,Last_Updated_Date = CURRENT_TIMESTAMP where Unit_Type_ID = each_id;
        update full_template_vector_floor_plan_relationship set Ref_ID = each_id,Last_Updated_Date = CURRENT_TIMESTAMP 
        where Vector_Type = 1 
        and Ref_ID in (select Unit_Type_ID from (select fu.Unit_Type_ID,v.vector from full_template_unit_type fu 
                                                left join (SELECT Ref_ID,count(Vector_ID) as vector 
                                                            FROM `full_template_vector_floor_plan_relationship` 
                                                            where Relationship_Status = 1
                                                            and Vector_Type = 1
                                                            group by Ref_ID
                                                            ORDER BY Ref_ID) v
                                                on fu.Unit_Type_ID = v.Ref_ID
                                                where SUBSTRING(Unit_Type_Name, 1, LENGTH(Unit_Type_Name) - 1) = each_name 
                                                and fu.Condo_Code = each_code and fu.Room_Type_ID = each_roomtype) aa
                        where Unit_Type_ID not in (each_id));
        update full_template_unit_type set Unit_Type_Status = 2,Last_Updated_Date = CURRENT_TIMESTAMP 
            where SUBSTRING(Unit_Type_Name, 1, LENGTH(Unit_Type_Name) - 1) = each_name 
            and Condo_Code = each_code and Unit_Type_ID <> each_id and Unit_Type_Status = 1 and Room_Type_ID = each_roomtype;
    END LOOP;

END //
DELIMITER ;