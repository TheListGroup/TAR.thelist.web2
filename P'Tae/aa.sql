SELECT 
    rs.SubDistrict_Name as SubDistrict_Name,
    sum(cr.Total_Room_Count) as Total_Room_Count,
    sum(cr.Total_Room_Count_Sale) as Total_Room_Count_Sale,
    round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) as Total_Average_Sqm_Sale,
    round((SUM(cr.Total_Price_Per_Unit_Sale*cr.Total_Total_Sqm_Sale)/SUM(cr.Total_Total_Sqm_Sale))/1000000,2) as Total_Price_Per_Unit_Sale,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Sale * cr.Total_Total_Sqm_Sale) / SUM(cr.Total_Total_Sqm_Sale),-3) as Total_Price_Per_Unit_Sqm_Sale,
    sum(cr.Total_Room_Count_Rent) as Total_Room_Count_Rent,
    round(sum(cr.Total_Average_Sqm_Rent*cr.Total_Room_Count_Rent)/sum(cr.Total_Room_Count_Rent),1) as Total_Average_Sqm_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Rent*cr.Total_Total_Sqm_Rent)/SUM(cr.Total_Total_Sqm_Rent),-2) as Total_Price_Per_Unit_Rent,
    round(SUM(cr.Total_Price_Per_Unit_Sqm_Rent * cr.Total_Total_Sqm_Rent) / SUM(cr.Total_Total_Sqm_Rent),-1) as Total_Price_Per_Unit_Sqm_Rent,
    min(cr.Min_Total_Price_Rent) as Min_Total_Price_Rent,
    max(cr.Max_Total_Price_Rent) as Max_Total_Price_Rent,
    sum(cr.Bed1_Room_Count_Sale) as Bed1_Room_Count_Sale,
    round(sum(cr.Bed1_Average_Sqm_Sale*cr.Bed1_Room_Count_Sale)/sum(cr.Bed1_Room_Count_Sale),1) as Bed1_Average_Sqm_Sale,
    round((SUM(cr.Bed1_Price_Per_Unit_Sale*cr.Bed1_Total_Sqm_Sale)/SUM(cr.Bed1_Total_Sqm_Sale))/1000000,2) as Bed1_Price_Per_Unit_Sale,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Sale * cr.Bed1_Total_Sqm_Sale) / SUM(cr.Bed1_Total_Sqm_Sale),-3) as Bed1_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed1_Room_Count_Rent) as Bed1_Room_Count_Rent,
    round(sum(cr.Bed1_Average_Sqm_Rent*cr.Bed1_Room_Count_Rent)/sum(cr.Bed1_Room_Count_Rent),1) as Bed1_Average_Sqm_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Rent*cr.Bed1_Total_Sqm_Rent)/SUM(cr.Bed1_Total_Sqm_Rent),-2) as Bed1_Price_Per_Unit_Rent,
    round(SUM(cr.Bed1_Price_Per_Unit_Sqm_Rent * cr.Bed1_Total_Sqm_Rent) / SUM(cr.Bed1_Total_Sqm_Rent),-1) as Bed1_Price_Per_Unit_Sqm_Rent,
    min(cr.Min_Bed1_Price_Rent) as Min_Bed1_Price_Rent,
    max(cr.Max_Bed1_Price_Rent) as Max_Bed1_Price_Rent,
    sum(cr.Bed2_Room_Count_Sale) as Bed2_Room_Count_Sale,
    round(sum(cr.Bed2_Average_Sqm_Sale*cr.Bed2_Room_Count_Sale)/sum(cr.Bed2_Room_Count_Sale),1) as Bed2_Average_Sqm_Sale,
    round((SUM(cr.Bed2_Price_Per_Unit_Sale*cr.Bed2_Total_Sqm_Sale)/SUM(cr.Bed2_Total_Sqm_Sale))/1000000,2) as Bed2_Price_Per_Unit_Sale,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Sale * cr.Bed2_Total_Sqm_Sale) / SUM(cr.Bed2_Total_Sqm_Sale),-3) as Bed2_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed2_Room_Count_Rent) as Bed2_Room_Count_Rent,
    round(sum(cr.Bed2_Average_Sqm_Rent*cr.Bed2_Room_Count_Rent)/sum(cr.Bed2_Room_Count_Rent),1) as Bed2_Average_Sqm_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Rent*cr.Bed2_Total_Sqm_Rent)/SUM(cr.Bed2_Total_Sqm_Rent),-2) as Bed2_Price_Per_Unit_Rent,
    round(SUM(cr.Bed2_Price_Per_Unit_Sqm_Rent * cr.Bed2_Total_Sqm_Rent) / SUM(cr.Bed2_Total_Sqm_Rent),-1) as Bed2_Price_Per_Unit_Sqm_Rent,
    min(cr.Min_Bed2_Price_Rent) as Min_Bed2_Price_Rent,
    max(cr.Max_Bed2_Price_Rent) as Max_Bed2_Price_Rent,
    sum(cr.Bed3_Room_Count_Sale) as Bed3_Room_Count_Sale,
    round(sum(cr.Bed3_Average_Sqm_Sale*cr.Bed3_Room_Count_Sale)/sum(cr.Bed3_Room_Count_Sale),1) as Bed3_Average_Sqm_Sale,
    round((SUM(cr.Bed3_Price_Per_Unit_Sale*cr.Bed3_Total_Sqm_Sale)/SUM(cr.Bed3_Total_Sqm_Sale))/1000000,2) as Bed3_Price_Per_Unit_Sale,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Sale * cr.Bed3_Total_Sqm_Sale) / SUM(cr.Bed3_Total_Sqm_Sale),-3) as Bed3_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed3_Room_Count_Rent) as Bed3_Room_Count_Rent,
    round(sum(cr.Bed3_Average_Sqm_Rent*cr.Bed3_Room_Count_Rent)/sum(cr.Bed3_Room_Count_Rent),1) as Bed3_Average_Sqm_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Rent*cr.Bed3_Total_Sqm_Rent)/SUM(cr.Bed3_Total_Sqm_Rent),-2) as Bed3_Price_Per_Unit_Rent,
    round(SUM(cr.Bed3_Price_Per_Unit_Sqm_Rent * cr.Bed3_Total_Sqm_Rent) / SUM(cr.Bed3_Total_Sqm_Rent),-1) as Bed3_Price_Per_Unit_Sqm_Rent,
    min(cr.Min_Bed3_Price_Rent) as Min_Bed3_Price_Rent,
    max(cr.Max_Bed3_Price_Rent) as Max_Bed3_Price_Rent,
    sum(cr.Bed4_Room_Count_Sale) as Bed4_Room_Count_Sale,
    round(sum(cr.Bed4_Average_Sqm_Sale*cr.Bed4_Room_Count_Sale)/sum(cr.Bed4_Room_Count_Sale),1) as Bed4_Average_Sqm_Sale,
    round((SUM(cr.Bed4_Price_Per_Unit_Sale*cr.Bed4_Total_Sqm_Sale)/SUM(cr.Bed4_Total_Sqm_Sale))/1000000,2) as Bed4_Price_Per_Unit_Sale,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Sale * cr.Bed4_Total_Sqm_Sale) / SUM(cr.Bed4_Total_Sqm_Sale),-3) as Bed4_Price_Per_Unit_Sqm_Sale,
    sum(cr.Bed4_Room_Count_Rent) as Bed4_Room_Count_Rent,
    round(sum(cr.Bed4_Average_Sqm_Rent*cr.Bed4_Room_Count_Rent)/sum(cr.Bed4_Room_Count_Rent),1) as Bed4_Average_Sqm_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Rent*cr.Bed4_Total_Sqm_Rent)/SUM(cr.Bed4_Total_Sqm_Rent),-2) as Bed4_Price_Per_Unit_Rent,
    round(SUM(cr.Bed4_Price_Per_Unit_Sqm_Rent * cr.Bed4_Total_Sqm_Rent) / SUM(cr.Bed4_Total_Sqm_Rent),-1) as Bed4_Price_Per_Unit_Sqm_Rent,
    min(cr.Min_Bed4_Price_Rent) as Min_Bed4_Price_Rent,
    max(cr.Max_Bed4_Price_Rent) as Max_Bed4_Price_Rent
FROM 
    (select rc.Condo_Code
            , ifnull(total_sale.Total_Room_Count_Sale,0) + ifnull(total_rent.Total_Room_Count_Rent,0) as Total_Room_Count
            , total_sale.Total_Room_Count_Sale
            , total_sale.Total_Average_Sqm_Sale
            , total_sale.Total_Price_Per_Unit_Sale
            , total_sale.Total_Price_Per_Unit_Sqm_Sale
            , total_sale.Total_Total_Sqm_Sale
            , total_rent.Total_Room_Count_Rent
            , total_rent.Total_Average_Sqm_Rent
            , total_rent.Total_Price_Per_Unit_Rent
            , total_rent.Total_Price_Per_Unit_Sqm_Rent
            , total_rent.Total_Total_Sqm_Rent
            , total_rent.Min_Total_Price_Rent
            , total_rent.Max_Total_Price_Rent
            , 1bed_sale.Bed1_Room_Count_Sale
            , 1bed_sale.Bed1_Average_Sqm_Sale
            , 1bed_sale.Bed1_Price_Per_Unit_Sale
            , 1bed_sale.Bed1_Price_Per_Unit_Sqm_Sale
            , 1bed_sale.Bed1_Total_Sqm_Sale
            , 1bed_rent.Bed1_Room_Count_Rent
            , 1bed_rent.Bed1_Average_Sqm_Rent
            , 1bed_rent.Bed1_Price_Per_Unit_Rent
            , 1bed_rent.Bed1_Price_Per_Unit_Sqm_Rent
            , 1bed_rent.Bed1_Total_Sqm_Rent
            , 1bed_rent.Min_Bed1_Price_Rent
            , 1bed_rent.Max_Bed1_Price_Rent
            , 2bed_sale.Bed2_Room_Count_Sale
            , 2bed_sale.Bed2_Average_Sqm_Sale
            , 2bed_sale.Bed2_Price_Per_Unit_Sale
            , 2bed_sale.Bed2_Price_Per_Unit_Sqm_Sale
            , 2bed_sale.Bed2_Total_Sqm_Sale
            , 2bed_rent.Bed2_Room_Count_Rent
            , 2bed_rent.Bed2_Average_Sqm_Rent
            , 2bed_rent.Bed2_Price_Per_Unit_Rent
            , 2bed_rent.Bed2_Price_Per_Unit_Sqm_Rent
            , 2bed_rent.Bed2_Total_Sqm_Rent
            , 2bed_rent.Min_Bed2_Price_Rent
            , 2bed_rent.Max_Bed2_Price_Rent
            , 3bed_sale.Bed3_Room_Count_Sale
            , 3bed_sale.Bed3_Average_Sqm_Sale
            , 3bed_sale.Bed3_Price_Per_Unit_Sale
            , 3bed_sale.Bed3_Price_Per_Unit_Sqm_Sale
            , 3bed_sale.Bed3_Total_Sqm_Sale
            , 3bed_rent.Bed3_Room_Count_Rent
            , 3bed_rent.Bed3_Average_Sqm_Rent
            , 3bed_rent.Bed3_Price_Per_Unit_Rent
            , 3bed_rent.Bed3_Price_Per_Unit_Sqm_Rent
            , 3bed_rent.Bed3_Total_Sqm_Rent
            , 3bed_rent.Min_Bed3_Price_Rent
            , 3bed_rent.Max_Bed3_Price_Rent
            , 4bed_sale.Bed4_Room_Count_Sale
            , 4bed_sale.Bed4_Average_Sqm_Sale
            , 4bed_sale.Bed4_Price_Per_Unit_Sale
            , 4bed_sale.Bed4_Price_Per_Unit_Sqm_Sale
            , 4bed_sale.Bed4_Total_Sqm_Sale
            , 4bed_rent.Bed4_Room_Count_Rent
            , 4bed_rent.Bed4_Average_Sqm_Rent
            , 4bed_rent.Bed4_Price_Per_Unit_Rent
            , 4bed_rent.Bed4_Price_Per_Unit_Sqm_Rent
            , 4bed_rent.Bed4_Total_Sqm_Rent
            , 4bed_rent.Min_Bed4_Price_Rent
            , 4bed_rent.Max_Bed4_Price_Rent
            , rcp.Condo_Segment
            , tp.Province_code
            , rm.District_Code
            , rs.SubDistrict_Code
            , cd.Developer_Code
            , b.Brand_Code
            -- , aline.Condo_Around_Line
            -- , astation.Condo_Around_Station
        from real_condo rc
        left join real_condo_price rcp on rc.Condo_Code = rcp.Condo_Code
        left join thailand_province tp on rc.Province_ID = tp.province_code
        left join real_yarn_main rm on rc.RealDistrict_Code = rm.District_Code
        left join real_yarn_sub rs on rc.RealSubDistrict_Code = rs.SubDistrict_Code
        left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
        left join brand b on rc.Brand_Code = b.Brand_Code
        left join (select Condo_Code
                            , SUM(Price_Sale*Size)/SUM(Size) as Bed1_Price_Per_Unit_Sale
                            , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed1_Price_Per_Unit_Sqm_Sale
                            , count(*) as Bed1_Room_Count_Sale
                            , AVG(Size) as Bed1_Average_Sqm_Sale
                            , sum(Size) as Bed1_Total_Sqm_Sale
                        from classified
                        where Classified_Status = '1'
                        and Bedroom = 1
                        and Sale = 1
                        group by Condo_Code) 1bed_sale
            on rc.Condo_Code = 1bed_sale.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Rent*Size)/SUM(Size) as Bed1_Price_Per_Unit_Rent
                            , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed1_Price_Per_Unit_Sqm_Rent
                            , count(*) as Bed1_Room_Count_Rent
                            , AVG(Size) as Bed1_Average_Sqm_Rent
                            , sum(Size) as Bed1_Total_Sqm_Rent
                            , min(Price_Rent) AS Min_Bed1_Price_Rent
                            , max(Price_Rent) AS Max_Bed1_Price_Rent
                        from classified
                        where Classified_Status = '1'
                        and Bedroom = 1
                        and Rent = 1
                        group by Condo_Code) 1bed_rent
            on rc.Condo_Code = 1bed_rent.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Sale*Size)/SUM(Size) as Bed2_Price_Per_Unit_Sale
                            , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed2_Price_Per_Unit_Sqm_Sale
                            , count(*) as Bed2_Room_Count_Sale
                            , AVG(Size) as Bed2_Average_Sqm_Sale
                            , sum(Size) as Bed2_Total_Sqm_Sale
                        from classified
                        where Classified_Status = '1'
                        and Bedroom = 2
                        and Sale = 1
                        group by Condo_Code) 2bed_sale
            on rc.Condo_Code = 2bed_sale.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Rent*Size)/SUM(Size) as Bed2_Price_Per_Unit_Rent
                            , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed2_Price_Per_Unit_Sqm_Rent
                            , count(*) as Bed2_Room_Count_Rent
                            , AVG(Size) as Bed2_Average_Sqm_Rent
                            , sum(Size) as Bed2_Total_Sqm_Rent
                            , min(Price_Rent) AS Min_Bed2_Price_Rent
                            , max(Price_Rent) AS Max_Bed2_Price_Rent
                        from classified
                        where Classified_Status = '1'
                        and Bedroom = 2
                        and Rent = 1
                        group by Condo_Code) 2bed_rent
            on rc.Condo_Code = 2bed_rent.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Sale*Size)/SUM(Size) as Bed3_Price_Per_Unit_Sale
                            , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed3_Price_Per_Unit_Sqm_Sale
                            , count(*) as Bed3_Room_Count_Sale
                            , AVG(Size) as Bed3_Average_Sqm_Sale
                            , sum(Size) as Bed3_Total_Sqm_Sale
                        from classified
                        where Classified_Status = '1'
                        and Bedroom = 3
                        and Sale = 1
                        group by Condo_Code) 3bed_sale
            on rc.Condo_Code = 3bed_sale.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Rent*Size)/SUM(Size) as Bed3_Price_Per_Unit_Rent
                            , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed3_Price_Per_Unit_Sqm_Rent
                            , count(*) as Bed3_Room_Count_Rent
                            , AVG(Size) as Bed3_Average_Sqm_Rent
                            , sum(Size) as Bed3_Total_Sqm_Rent
                            , min(Price_Rent) AS Min_Bed3_Price_Rent
                            , max(Price_Rent) AS Max_Bed3_Price_Rent
                        from classified
                        where Classified_Status = '1'
                        and Bedroom = 3
                        and Rent = 1
                        group by Condo_Code) 3bed_rent
            on rc.Condo_Code = 3bed_rent.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Sale*Size)/SUM(Size) as Bed4_Price_Per_Unit_Sale
                            , SUM((Price_Sale/Size)*Size)/SUM(Size) as Bed4_Price_Per_Unit_Sqm_Sale
                            , count(*) as Bed4_Room_Count_Sale
                            , AVG(Size) as Bed4_Average_Sqm_Sale
                            , sum(Size) as Bed4_Total_Sqm_Sale
                        from classified
                        where Classified_Status = '1'
                        and Bedroom >= 4
                        and Sale = 1
                        group by Condo_Code) 4bed_sale
            on rc.Condo_Code = 4bed_sale.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Rent*Size)/SUM(Size) as Bed4_Price_Per_Unit_Rent
                            , SUM((Price_Rent/Size)*Size)/SUM(Size) as Bed4_Price_Per_Unit_Sqm_Rent
                            , count(*) as Bed4_Room_Count_Rent
                            , AVG(Size) as Bed4_Average_Sqm_Rent
                            , sum(Size) as Bed4_Total_Sqm_Rent
                            , min(Price_Rent) AS Min_Bed4_Price_Rent
                            , max(Price_Rent) AS Max_Bed4_Price_Rent
                        from classified
                        where Classified_Status = '1'
                        and Bedroom >= 4
                        and Rent = 1
                        group by Condo_Code) 4bed_rent
            on rc.Condo_Code = 4bed_rent.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Sale*Size)/SUM(Size) as Total_Price_Per_Unit_Sale
                            , SUM((Price_Sale/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Sale
                            , count(*) as Total_Room_Count_Sale
                            , AVG(Size) as Total_Average_Sqm_Sale
                            , sum(Size) as Total_Total_Sqm_Sale
                        from classified
                        where Classified_Status = '1'
                        and Sale = 1
                        group by Condo_Code) total_sale
            on rc.Condo_Code = total_sale.Condo_Code
            left join (select Condo_Code
                            , SUM(Price_Rent*Size)/SUM(Size) as Total_Price_Per_Unit_Rent
                            , SUM((Price_Rent/Size)*Size)/SUM(Size) as Total_Price_Per_Unit_Sqm_Rent
                            , count(*) as Total_Room_Count_Rent
                            , AVG(Size) as Total_Average_Sqm_Rent
                            , sum(Size) as Total_Total_Sqm_Rent
                            , min(Price_Rent) AS Min_Total_Price_Rent
                            , max(Price_Rent) AS Max_Total_Price_Rent
                        from classified
                        where Classified_Status = '1'
                        and Rent = 1
                        group by Condo_Code) total_rent
            on rc.Condo_Code = total_rent.Condo_Code
            /*left join (select Condo_Code
                            , JSON_ARRAYAGG( JSON_OBJECT('Line_Code',Line_Code) ) as Condo_Around_Line
                        from ( SELECT Condo_Code
                                    , Line_Code
                                FROM condo_around_station
                                group by Condo_Code,Line_Code) c_line
                        group by Condo_Code) aline
            on rc.Condo_Code = aline.Condo_Code
            left join (select Condo_Code
                            , JSON_ARRAYAGG( JSON_OBJECT('Station_Code',Station_Code) ) as Condo_Around_Station
                        from ( SELECT Condo_Code
                                    , Station_Code
                                FROM condo_around_station
                                group by Condo_Code,Station_Code) c_station
                        group by Condo_Code) astation
            on rc.Condo_Code = astation.Condo_Code*/
            where rc.Condo_Status = 1
            /*and rs.SubDistrict_Code = 'M11-S3'*/) cr
JOIN 
    real_yarn_sub rs ON cr.SubDistrict_Code = rs.SubDistrict_Code
group by rs.SubDistrict_Name
order by sum(cr.Total_Room_Count) DESC, sum(cr.Total_Room_Count_Sale) DESC, sum(cr.Total_Room_Count_Rent) DESC
    , round(sum(cr.Total_Average_Sqm_Sale*cr.Total_Room_Count_Sale)/sum(cr.Total_Room_Count_Sale),1) DESC;