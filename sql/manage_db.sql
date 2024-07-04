-- check แต่ละคอลัมน์ ควรจะเป็น True
select if(current_data_length = new_data_length,'TRUE','FALSE') as cal -- เปลี่ยนคอลัมน์ตรงนี้
from (select a.table_name as current_table
        , a.auto_increment as current_auto_increment
        , a.data_length as current_data_length
        , b.table_name as new_table
        , b.auto_increment as new_auto_increment
        , b.data_length as new_data_length
    from (SELECT table_name
                ,auto_increment
                ,data_length
            FROM information_schema.tables 
            WHERE table_schema = 'realist2') a
    left join (SELECT table_name
                    ,auto_increment
                    ,data_length
                FROM information_schema.tables 
                WHERE table_schema = 'realist_tar') b -- เปลี่ยน database ตรงนี้
    on a.table_name = b.table_name) aaa
where current_data_length is not null -- เปลี่ยนคอลัมน์ตรงนี้
and new_data_length is not null -- เปลี่ยนคอลัมน์ตรงนี้
group by 1;


-- ถ้าเจอ False
select * 
from (select current_table, current_auto_increment, new_table, new_auto_increment
    , if(current_auto_increment = new_auto_increment,'TRUE','FALSE') as cal -- เปลี่ยนคอลัมน์ตรงนี้
        from (select a.table_name as current_table
                , a.auto_increment as current_auto_increment
                , a.data_length as current_data_length
                , b.table_name as new_table
                , b.auto_increment as new_auto_increment
                , b.data_length as new_data_length
            from (SELECT table_name
                        ,auto_increment
                        ,data_length
                    FROM information_schema.tables 
                    WHERE table_schema = 'realist2') a
            left join (SELECT table_name
                            ,auto_increment
                            ,data_length
                        FROM information_schema.tables 
                        WHERE table_schema = 'realist_tar') b -- เปลี่ยน database ตรงนี้
            on a.table_name = b.table_name) aaa
            where current_auto_increment is not null -- เปลี่ยนคอลัมน์ตรงนี้
            and new_auto_increment is not null ) bbb -- เปลี่ยนคอลัมน์ตรงนี้
where cal = 'FALSE';