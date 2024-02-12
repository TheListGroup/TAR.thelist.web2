SELECT cpc.Condo_Code 
	,condo_enname.Condo_ENName
    ,condo_thname.Condo_Name
    ,rc.Condo_TotalUnit
    ,cpc.Condo_Price_Per_Square
    ,cpc.Condo_Price_Per_Unit
    ,rcp.Condo_Salable_Area
    ,rcft.Parking_Amount
    ,rcp.Condo_Common_Fee
    ,rch1.Data_Value as Rental_Yield_Percent
    ,rch2.Data_Value as Price_Per_Square
    ,rc561_sold.Data_Value as Sold_Percent
    ,rc561_transfer.Data_Value as Transfer_Percent
    ,rcp.Condo_Built_Finished
    ,rcp.Condo_Built_Start
    ,rc.Condo_Building
    ,rc.Condo_TotalRai
    ,rcft.Passenger_Lift_Amount
    ,rcft.Service_Lift_Amount
    ,rcft.Pool_Width
    ,rcft.Pool_Length
    ,rcft.Pool_2_Width
    ,rcft.Pool_2_Length
    ,rcft.Condo_Fund_Fee
    ,rcft.STU_Amount
    ,rcft.1BR_Amount
    ,rcft.2BR_Amount
    ,rcft.3BR_Amount
    ,rcft.4BR_Amount
    ,rcft.Manual_Parking_Amount
    ,rcft.Auto_Parking_Amount
    ,cpc.Condo_Sold_Status_Show_Value
    ,size1.STU_Min_Size
    ,size1.STU_Max_Size
    ,size2.1BED_Min_Size
    ,size2.1BED_Max_Size
    ,size3.2BED_Min_Size
    ,size3.2BED_Max_Size
    ,size4.3BED_Min_Size
    ,size4.3BED_Max_Size
    ,size5.4BED_Min_Size
    ,size5.4BED_Max_Size
FROM `condo_price_calculate_view` cpc
left JOIN real_condo_price AS rcp ON cpc.Condo_Code = rcp.Condo_Code
left JOIN real_condo AS rc ON cpc.Condo_Code = rc.Condo_Code
left JOIN real_condo_full_template AS rcft ON cpc.Condo_Code = rcft.Condo_Code
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
            WHERE Data_Attribute = 'rental_yield_percent'
            and Data_Date = ( SELECT MAX(rch_in1.Data_Date) 
                            FROM real_condo_hipflat AS rch_in1 
                            WHERE rch_in1.Data_Attribute = 'rental_yield_percent')) rch1
on cpc.Condo_Code = rch1.Condo_Code
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
left join ( SELECT  rc561.Condo_Code
                    , rc561.Data_Date
                    , rc561.Data_Value
                    , rc561.Data_Note
            FROM `real_condo_561` rc561
            left join condo_price_calculate_view cpc on rc561.Condo_Code = cpc.Condo_Code
            where Data_Attribute = 'sold_percent'
            and Data_Date = (SELECT MAX(rc561_in1.Data_Date) 
                            FROM real_condo_561 AS rc561_in1 
                            WHERE rc561_in1.Condo_Code = cpc.Condo_Code 
                            AND rc561_in1.Data_Attribute = 'sold_percent'
                            and rc561_in1.Data_Status = 1)
            and Data_Update_Date = (SELECT MAX(rc561_in1.Data_Update_Date) 
                                    FROM real_condo_561 AS rc561_in1 
                                    WHERE rc561_in1.Condo_Code = cpc.Condo_Code 
                                    AND rc561_in1.Data_Attribute = 'sold_percent'
                                    and rc561_in1.Data_Status = 1)
            and rc561.Data_Status = 1) rc561_sold
on cpc.Condo_Code = rc561_sold.Condo_Code
left join ( SELECT  rc561.Condo_Code
                    , rc561.Data_Date
                    , rc561.Data_Value
                    , rc561.Data_Note
            FROM `real_condo_561` rc561
            left join condo_price_calculate_view cpc on rc561.Condo_Code = cpc.Condo_Code
            where Data_Attribute = 'transfer_percent'
            and Data_Date = (SELECT MAX(rc561_in1.Data_Date) 
                            FROM real_condo_561 AS rc561_in1 
                            WHERE rc561_in1.Condo_Code = cpc.Condo_Code 
                            AND rc561_in1.Data_Attribute = 'transfer_percent'
                            and rc561_in1.Data_Status = 1)
            and Data_Update_Date = (SELECT MAX(rc561_in1.Data_Update_Date) 
                                    FROM real_condo_561 AS rc561_in1 
                                    WHERE rc561_in1.Condo_Code = cpc.Condo_Code 
                                    AND rc561_in1.Data_Attribute = 'transfer_percent'
                                    and rc561_in1.Data_Status = 1)
            and rc561.Data_Status = 1) rc561_transfer
on cpc.Condo_Code = rc561_transfer.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS STU_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),roundsize(min(size)),roundsize(min(size))) as STU_Min_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),'',roundsize(max(size))) as STU_Max_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 1
            GROUP BY Condo_Code) as size1
on cpc.Condo_Code = size1.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 1BED_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),roundsize(min(size)),roundsize(min(size))) as 1BED_Min_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),'',roundsize(max(size))) as 1BED_Max_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 2
            GROUP BY Condo_Code) as size2
on cpc.Condo_Code = size2.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 2BED_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),roundsize(min(size)),roundsize(min(size))) as 2BED_Min_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),'',roundsize(max(size))) 2BED_Max_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 4
            GROUP BY Condo_Code) as size3
on cpc.Condo_Code = size3.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 3BED_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),roundsize(min(size)),roundsize(min(size))) as 3BED_Min_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),'',roundsize(max(size))) 3BED_Max_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 5
            GROUP BY Condo_Code) as size4
on cpc.Condo_Code = size4.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 4BED_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),roundsize(min(size)),roundsize(min(size))) as 4BED_Min_Size
            ,   if(roundsize(min(size))=roundsize(max(size)),'',roundsize(max(size))) 4BED_Max_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 6
            GROUP BY Condo_Code) as size5
on cpc.Condo_Code = size5.Condo_Code;