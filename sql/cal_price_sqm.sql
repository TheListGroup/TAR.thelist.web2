SELECT Condo_Code
        , round(sum(Price_Sale_Per_Square*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Square_1
FROM `classified_detail_view`
where Classified_Status = '1'
and Price_Sale_Per_Square is not null
and Unit_Size is not null
group by Condo_Code
order by Condo_Code;

SELECT Condo_Code
        , round(sum(Price_Sale_Per_Square*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Square_1_3
FROM `classified_detail_view`
where (Classified_Status = '1' or Classified_Status = '3')
and Price_Sale_Per_Square is not null
and Unit_Size is not null
group by Condo_Code
order by Condo_Code;




SELECT Condo_Code
        , round(sum(Price_Rent*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Rent_1
FROM `classified_detail_view`
where Classified_Status = '1'
and Price_Rent is not null
and Unit_Size is not null
group by Condo_Code
order by Condo_Code;

SELECT Condo_Code
        , round(sum(Price_Rent*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Rent_1_3
FROM `classified_detail_view`
where (Classified_Status = '1' or Classified_Status = '3')
and Price_Rent is not null
and Unit_Size is not null
group by Condo_Code
order by Condo_Code;




SELECT cpc.Condo_Code 
	,condo_enname.Condo_ENName
        ,condo_thname.Condo_Name
        ,cpc.Condo_Price_Per_Square
        ,cpc.Condo_Price_Per_Unit
        ,rch2.Data_Value as Price_Per_Square_Hipflat
        ,p1.Cal_Price_Square_1 as Cal_Price_Square_1
        ,p2.Cal_Price_Square_1_3 as Cal_Price_Square_1_3
        ,p3.Cal_Price_Rent_1 as Cal_Price_Rent_1
        ,p4.Cal_Price_Rent_1_3 as Cal_Price_Rent_1_3
        ,stat.Room_Count_Active
        ,stat2.Room_Count_All
        ,stat.Min_Price_Sale_Active
        ,stat2.Min_Price_Sale_All
        ,stat.Avg_Price_Sale_Active
        ,stat2.Avg_Price_Sale_All
        ,stat.Max_Price_Sale_Active
        ,stat2.Max_Price_Sale_All
        ,stat.Min_Price_Rent_Active
        ,stat2.Min_Price_Rent_All
        ,stat.Avg_Price_Rent_Active
        ,stat2.Avg_Price_Rent_All
        ,stat.Max_Price_Rent_Active
        ,stat2.Max_Price_Rent_All
        ,stat.Min_Unit_Size_Active
        ,stat2.Min_Unit_Size_All
        ,stat.Avg_Unit_Size_Active
        ,stat2.Avg_Unit_Size_All
        ,stat.Max_Unit_Size_Active
        ,stat2.Max_Unit_Size_All
        ,stat.Total_Unit_Size_Active
        ,stat2.Total_Unit_Size_All
FROM `condo_price_calculate_view` cpc
left JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
left JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
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
on cpc.Condo_Code = condo_enname.Condo_Code
left join ( SELECT cpc.Condo_Code, 
        if(Condo_Name1 is not null
                , CONCAT(SUBSTRING_INDEX(Condo_Name1,'\n',1),' ',SUBSTRING_INDEX(Condo_Name1,'\n',-1))
                , Condo_Name2) as Condo_Name
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
on cpc.Condo_Code = condo_thname.Condo_Code
left join ( SELECT  Condo_Code
                , Data_Date
                , Data_Attribute
                , Data_Value 
        FROM `real_condo_hipflat`
        WHERE Data_Attribute = 'price_per_sqm'
        and Data_Date = ( SELECT MAX(rch_in2.Data_Date) 
                        FROM real_condo_hipflat AS rch_in2
                        WHERE rch_in2.Data_Attribute = 'price_per_sqm')) rch2
on cpc.Condo_Code = rch2.Condo_Code
left join ( SELECT Condo_Code
        , round(sum(Price_Sale_Per_Square*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Square_1
        FROM `classified_detail_view`
        where Classified_Status = '1'
        and Price_Sale_Per_Square is not null
        and Unit_Size is not null
        group by Condo_Code) p1
on cpc.Condo_Code = p1.Condo_Code
left join ( SELECT Condo_Code
        , round(sum(Price_Sale_Per_Square*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Square_1_3
        FROM `classified_detail_view`
        where (Classified_Status = '1' or Classified_Status = '3')
        and Price_Sale_Per_Square is not null
        and Unit_Size is not null
        group by Condo_Code) p2
on cpc.Condo_Code = p2.Condo_Code
left join ( SELECT Condo_Code
        , round(sum(Price_Rent*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Rent_1
        FROM `classified_detail_view`
        where Classified_Status = '1'
        and Price_Rent is not null
        and Unit_Size is not null
        group by Condo_Code) p3
on cpc.Condo_Code = p3.Condo_Code
left join ( SELECT Condo_Code
        , round(sum(Price_Rent*Unit_Size)/sum(Unit_Size),-3) as Cal_Price_Rent_1_3
        FROM `classified_detail_view`
        where (Classified_Status = '1' or Classified_Status = '3')
        and Price_Rent is not null
        and Unit_Size is not null
        group by Condo_Code) p4
on cpc.Condo_Code = p4.Condo_Code
left join (SELECT Condo_Code 
        , count(*) as Room_Count_Active
        , min(Price_Sale) as Min_Price_Sale_Active
        , round(avg(Price_Sale),0) as Avg_Price_Sale_Active
        , max(Price_Sale) as Max_Price_Sale_Active
        , min(Price_Rent) as Min_Price_Rent_Active
        , round(avg(Price_Rent),0) as Avg_Price_Rent_Active
        , max(Price_Rent) as Max_Price_Rent_Active
        , min(Unit_Size) as Min_Unit_Size_Active
        , round(avg(Unit_Size),2) as Avg_Unit_Size_Active
        , max(Unit_Size) as Max_Unit_Size_Active
        , sum(Unit_Size) as Total_Unit_Size_Active
        FROM `classified_detail_view`
        where Classified_Status = '1'
        group by Condo_Code) stat
on cpc.Condo_Code = stat.Condo_Code
left join (SELECT Condo_Code 
        , count(*) as Room_Count_All
        , min(Price_Sale) as Min_Price_Sale_All
        , round(avg(Price_Sale),0) as Avg_Price_Sale_All
        , max(Price_Sale) as Max_Price_Sale_All
        , min(Price_Rent) as Min_Price_Rent_All
        , round(avg(Price_Rent),0) as Avg_Price_Rent_All
        , max(Price_Rent) as Max_Price_Rent_All
        , min(Unit_Size) as Min_Unit_Size_All
        , round(avg(Unit_Size),2) as Avg_Unit_Size_All
        , max(Unit_Size) as Max_Unit_Size_All
        , sum(Unit_Size) as Total_Unit_Size_All
        FROM `classified_detail_view`
        where (Classified_Status = '1' or Classified_Status = '3')
        group by Condo_Code) stat2
on cpc.Condo_Code = stat2.Condo_Code
order by Condo_Code;


select cpc.Condo_Code
	, bed1.room_type as 1Bed_Active
    , bed2.room_type as 2Bed_Active
    , bed3.room_type as 3Bed_Active
    , bed4.room_type as 4Bed_Active
    , bed11.room_type as 1Bed_All
    , bed22.room_type as 2Bed_All
    , bed33.room_type as 3Bed_All
    , bed44.room_type as 4Bed_All
FROM `condo_price_calculate_view` cpc
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '1 Bed%'
            and Classified_Status = '1'
            group by Condo_Code) bed1
on cpc.Condo_Code = bed1.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '2 Bed%'
            and Classified_Status = '1'
            group by Condo_Code) bed2
on cpc.Condo_Code = bed2.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '3 Bed%'
            and Classified_Status = '1'
            group by Condo_Code) bed3
on cpc.Condo_Code = bed3.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '4 Bed%'
            and Classified_Status = '1'
            group by Condo_Code) bed4
on cpc.Condo_Code = bed4.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '1 Bed%'
            and (Classified_Status = '1' or Classified_Status = '3')
            group by Condo_Code) bed11
on cpc.Condo_Code = bed11.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '2 Bed%'
            and (Classified_Status = '1' or Classified_Status = '3')
            group by Condo_Code) bed22
on cpc.Condo_Code = bed22.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '3 Bed%'
            and (Classified_Status = '1' or Classified_Status = '3')
            group by Condo_Code) bed33
on cpc.Condo_Code = bed33.Condo_Code
left join (SELECT Condo_Code,count(*) as room_type 
            FROM `classified_detail_view`
            where Unit_Type like '4 Bed%'
            and (Classified_Status = '1' or Classified_Status = '3')
            group by Condo_Code) bed44
on cpc.Condo_Code = bed44.Condo_Code
order by Condo_Code;