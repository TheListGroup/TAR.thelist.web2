INSERT INTO `price_source` (`Head`, `Sub`) 
VALUES ('Company Presentation', '56-1'),('Online Survey', 'Hipflat'),('Online Survey', 'Blogger');


-- Price_Start_Blogger_Square
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code, Price_Start_Blogger_Square, Price_Start_Blogger_Square_Date
    , if(Price_Start_Blogger_Square_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL))
    , 'เฉลี่ย'
    , 0
    , 'บ/ตรม'
    , 0
    , NULL
    , '1'
    , 32
    , 32
from real_condo_price
where Price_Start_Blogger_Square is not null;


-- Price_Start_Day1_Square
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code, Price_Start_Day1_Square, Price_Start_Day1_Square_Date
    , if(Price_Start_Day1_Square_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL))
    , 'เฉลี่ย'
    , 0
    , 'บ/ตรม'
    , 0
    , NULL
    , '1'
    , 32
    , 32
from real_condo_price
where Price_Start_Day1_Square is not null;


-- Price_Start_Blogger_Unit
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code, Price_Start_Blogger_Unit, Price_Start_Blogger_Unit_Date
    , if(Price_Start_Blogger_Unit_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL))
    , 'เริ่มต้น'
    , 0
    , 'บ/ยูนิต'
    , 3
    , NULL
    , '1'
    , 32
    , 32
from real_condo_price
where Price_Start_Blogger_Unit is not null;


-- Price_Start_Day1_Unit
insert into real_condo_price_new (Condo_Code, Price, Price_Date, Condo_Build_Date, Start_or_AVG, Price_Source, Price_Type, Special, Remark, Price_Status, Created_By, Last_Updated_By)
select Condo_Code, Price_Start_Day1_Unit, Price_Start_Day1_Unit_Date
    , if(Price_Start_Day1_Unit_Date is not null
        , '0'
        , if(Condo_Built_Start is not null
            , '1'
            , NULL))
    , 'เริ่มต้น'
    , 0
    , 'บ/ยูนิต'
    , 3
    , NULL
    , '1'
    , 32
    , 32
from real_condo_price
where Price_Start_Day1_Unit is not null;