INSERT INTO `price_source` (`Head`, `Sub`) 
VALUES ('Online Survey', 'Online Survey - Homenayoo'),('Online Survey','Online Survey - Condonayoo')
,('Online Survey','Online Survey - DDproperty'),('Online Survey','Online Survey - Think of Living')
,('Online Survey','Online Survey - Condotiddoi'),('Online Survey','Online Survey - รายใหม่')
,('Online Survey','Online Survey - ฅน รักตึก'),('Online Survey','Online Survey - ClubSunday Condo Story')
,('Company Presentation','Company Presentation - 56-1'),('Company Presentation','Company Presentation - Presentation')
,('Developer','Developer - พนักงานขาย'),('Developer','Developer - ข้อมูลทำบทความ'),('Online Survey','Online Survey - Hipflat');


-- Price_Start_Blogger_Square
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , Price_Start_Blogger_Square
    , Price_Start_Blogger_Square_Date
    , if(Price_Start_Blogger_Square_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL)) as Condo_Build_Date
    , 'เริ่มต้น' as Start_or_AVG
    , 1 as Price_Source
    , 'บ/ตรม' as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_price
where Price_Start_Blogger_Square is not null;


-- Price_Start_Day1_Square
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , Price_Start_Day1_Square
    , Price_Start_Day1_Square_Date
    , if(Price_Start_Day1_Square_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL)) as Condo_Build_Date
    , 'เริ่มต้น' as Start_or_AVG
    , 1 as Price_Source
    , 'บ/ตรม' as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_price
where Price_Start_Day1_Square is not null;


-- Price_Start_Blogger_Unit
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , Price_Start_Blogger_Unit
    , Price_Start_Blogger_Unit_Date
    , if(Price_Start_Blogger_Unit_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL)) as Condo_Build_Date
    , 'เริ่มต้น' as Start_or_AVG
    , 1 as Price_Source
    , 'บ/ยูนิต' as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_price
where Price_Start_Blogger_Unit is not null;


-- Price_Start_Day1_Unit
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , Price_Start_Day1_Unit
    , Price_Start_Day1_Unit_Date
    , if(Price_Start_Day1_Unit_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL)) as Condo_Build_Date
    , 'เริ่มต้น' as Start_or_AVG
    , 1 as Price_Source
    , 'บ/ยูนิต' as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_price
where Price_Start_Day1_Unit is not null;

update `real_condo_561` set Data_Note = '' where Data_Note in ('56-1','56-7');

-- 56-1 to House_Type 1
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 1 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note in ('BLOGGER','BlOGGER');

delete from real_condo_561 where Data_Note in ('BLOGGER','BlOGGER') and Data_Attribute in ('price_per_unit_mb','price_per_sqm');

-- 56-1 to House_Type 10
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 10 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note in ('ร่างหนังสือชี้ชวน','Official');

delete from real_condo_561 where Data_Note in ('ร่างหนังสือชี้ชวน','Official') and Data_Attribute in ('price_per_unit_mb','price_per_sqm');

-- 56-1 to House_Type 12
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 12 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note like '%list%';

delete from real_condo_561 where Data_Note like '%list%' and Data_Attribute in ('price_per_unit_mb','price_per_sqm');

-- 56-1 to House_Type 4
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 4 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note like '%think%';

delete from real_condo_561 where Data_Note like '%think%' and Data_Attribute in ('price_per_unit_mb','price_per_sqm');

-- 56-1 to House_Type 2
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 2 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note like '%condonayoo%';

delete from real_condo_561 where Data_Note like '%condonayoo%' and Data_Attribute in ('price_per_unit_mb','price_per_sqm');

-- 56-1 to House_Type 5
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 5 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note like '%condotiddoi%';

delete from real_condo_561 where Data_Note like '%condotiddoi%' and Data_Attribute in ('price_per_unit_mb','price_per_sqm');

-- 56-1 to House_Type 11
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code
    , if(Data_Attribute='price_per_sqm',round(Data_Value),round(Data_Value*1000000,-4)) as Price
    , Data_Date as Price_Date
    , '0' as Condo_Build_Date
    , 'เฉลี่ย' as Start_or_Average
    , 11 as Price_Source
    , if(Data_Attribute='price_per_sqm','บ/ตรม','บ/ยูนิต') as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_561
where Data_Status = 1
and Data_Attribute in ('price_per_unit_mb','price_per_sqm')
and Data_Note = 'พี่บีม Official';

delete from real_condo_561 where Data_Note = 'พี่บีม Official' and Data_Attribute in ('price_per_unit_mb','price_per_sqm');