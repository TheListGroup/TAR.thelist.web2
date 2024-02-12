-- Example Query
insert into table_name (Condo_Code,Price,Price_Date,Built_Start,Condo_Square_Text,Source)
select (cpc.Condo_Code
        , rcp.Price_Average_56_1_Square
        , rcp.Price_Average_56_1_Square_Date
        , if(rcp.Price_Average_56_1_Square_Date is not null
            , 0
            , if(rcp.Condo_Built_Start is not null
                , 1
                , 0))
        , "เฉลี่ย"
        , "56-1"
        from condo_price_calculate_view cpc
        left join real_condo_price rcp on cpc.Condo_Code = rcp.Condo_Code
        where rcp.Price_Average_56_1_Square is not null);




insert into table_name (Condo_Code,Price,Price_Date,Built_Start,Condo_Square_Text,Source)
select (cpc.Condo_Code
        , rcp.Price_Average_Resale_Square
        , rcp.Price_Average_Resale_Square_Date
        , if(rcp.Price_Average_Resale_Square_Date is not null
            , 0
            , if(rcp.Condo_Built_Start is not null
                , 1
                , 0))
        , "เฉลี่ย"
        , ""
        from condo_price_calculate_view cpc
        left join real_condo_price rcp on cpc.Condo_Code = rcp.Condo_Code
        where rcp.Price_Average_Resale_Square is not null);




insert into table_name (Condo_Code,Price,Price_Date,Built_Start,Condo_Square_Text,Source)
select (cpc.Condo_Code
        , rcp.Price_Start_Blogger_Square
        , rcp.Price_Start_Blogger_Square_Date
        , if(rcp.Price_Start_Blogger_Square_Date is not null
            , 0
            , if(rcp.Condo_Built_Start is not null
                , 1
                , 0))
        , "เริ่มต้น"
        , "Blogger"
        from condo_price_calculate_view cpc
        left join real_condo_price rcp on cpc.Condo_Code = rcp.Condo_Code
        where rcp.Price_Start_Blogger_Square is not null);




insert into table_name (Condo_Code,Price,Price_Date,Built_Start,Condo_Square_Text,Source)
select (cpc.Condo_Code
        , rcp.Price_Start_Day1_Square
        , rcp.Price_Start_Day1_Square_Date
        , if(rcp.Price_Start_Day1_Square_Date is not null
            , 0
            , if(rcp.Condo_Built_Start is not null
                , 1
                , 0))
        , "เริ่มต้น"
        , "Blogger"
        from condo_price_calculate_view cpc
        left join real_condo_price rcp on cpc.Condo_Code = rcp.Condo_Code
        where rcp.Price_Start_Day1_Square is not null);