INSERT INTO `price_source` (`Head`, `Sub`) 
VALUES ('Company Presentation', '56-1'),('Online Survey', 'Hipflat'),('Online Survey', 'Blogger')
,('DONT KNOW', 'Price_Start_Blogger_Square'),('DONT KNOW', 'Price_Start_Day1_Square'),('DONT KNOW', 'Price_Start_Blogger_Unit')
,('DONT KNOW', 'Price_Start_Day1_Unit');


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
    , 4 as Price_Source
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
    , 5 as Price_Source
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
    , 6 as Price_Source
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
    , 7 as Price_Source
    , 'บ/ยูนิต' as Price_Type
    , '0' as Special
    , NULL as Remark
    , '1' as Price_Status
    , 32 as Created_By
    , 32 as Last_Updated_By
from real_condo_price
where Price_Start_Day1_Unit is not null;