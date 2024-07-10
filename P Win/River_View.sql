SELECT rc.Condo_ENName
    , cd.Developer_Name
    , if(rc.Condo_HighRise = 1,'Hi-Rise','Low-Rise') as 'Type'
    , concat_ws(',',rc.Condo_Latitude, rc.Condo_Longitude) as 'Location'
    , ff.Condo_Sold_Status_Show_Value as 'Status'
    , ifnull(year(rcp.Condo_Built_Start),'') as 'Year Built Start'
    , ifnull(year(rcp.Condo_Built_Finished),'') as 'Year Built Done'
    , concat_ws('-',rc.Condo_LandRai,rc.Condo_LandNgan,rc.Condo_LandWa) as 'Land Size'
    , trim(concat(replace(ff.Price_Start_Unit, " ลบ.", ""),' ',if(ff.Price_Start_Unit_Date is not null,ff.Price_Start_Unit_Date,''))) as 'Price_Start'
    , trim(concat(replace(ff.Price_Average_Square, " บ./ตร.ม.", ""),' ',if(ff.Price_Average_Square_Date is not null,ff.Price_Average_Square_Date,''))) as 'Price_Average'
    , replace(replace(concat(replace(rc.Condo_Building,'"'," "), ' ชั้น'),"Buildings",' อาคาร'),",",' ชั้น') as 'จำนวนอาคาร/ชั้น'
    , rc.Condo_TotalUnit as 'Total Units'
    , ifnull(rcft.Parking_Amount,'') as Parking_Amount
    , ifnull(rcft.Manual_Parking_Amount,'') as Manual_Parking_Amount
    , ifnull(rcft.Auto_Parking_Amount,'') as Auto_Parking_Amount
    , ff.Parking_Per_Unit as Parking_Per_Unit
    , ifnull(bedsize.Size_STU_Min,'') as 'Studio Min'
    , ifnull(bedsize.Size_STU_Max,'') as 'Studio Max'
    , ifnull(bedsize.Size_1BED_Min,'') as '1Bed Min'
    , ifnull(bedsize.Size_1BED_Max,'') as '1Bed Max'
    , ifnull(bedsize.Size_2BED_Min,'') as '2Bed Min'
    , ifnull(bedsize.Size_2BED_Max,'') as '2Bed Max'
    , ifnull(bedsize.Size_3BED_Min,'') as '3Bed Min'
    , ifnull(bedsize.Size_3BED_Max,'') as '3Bed Max'
    , ifnull(bedsize.Size_4BED_Min,'') as '4Bed Min'
    , ifnull(bedsize.Size_4BED_Max,'') as '4Bed Max'
    , if(ft.Condo_Code is not null,"TRUE","FALSE") as 'Loft Unit'
    , ff.Station
    , ff.Real_District as 'ย่าน'
    , ff.Road_Name
    , ff.District_Name
    , ts.name_th as SubDistrict_Name
    , ff.Province
    , ifnull(rcft.Condo_Fund_Fee,'') as 'ค่ากองทุน'
    , ifnull(rcft.Passenger_Lift_Amount,'') as 'ลิฟท์โดยสาร'
    , ifnull(rcft.Service_Lift_Amount,'') as 'ลิฟท์ Service'
    , ff.Pool_Size
    , ifnull(ff.Pool_2_Size,'') as Pool_2_Size
    , replace(ff.Price_Average_Resale_Square, " บ./ตร.ม.", "") as 'Resale เฉลี่ย/ตร.ม.'
    , replace(ff.Price_Start_Square, " บ./ตร.ม.", "") as 'เริ่มต้น/ตร.ม.'
    , ifnull(rcp.Condo_Common_Fee,'') as 'ค่าส่วนกลาง'
    , ifnull(rcft.STU_Amount,'') as 'STU_Amount'
    , ifnull(rcft.1BR_Amount,'') as '1BR_Amount'
    , ifnull(rcft.2BR_Amount,'') as '2BR_Amount'
    , ifnull(rcft.3BR_Amount,'') as '3BR_Amount'
    , ifnull(rcft.4BR_Amount,'') as '4BR_Amount'
FROM `real_condo` rc
left join condo_price_calculate_view cpc on rc.Condo_Code = cpc.Condo_Code
left join full_template_factsheet ff on rc.Condo_Code = ff.Condo_Code
left join real_condo_price rcp on rc.Condo_Code = rcp.Condo_Code
left join real_condo_full_template rcft on rc.Condo_Code = rcft.Condo_Code
left join thailand_subdistrict as ts on rc.SubDistrict_ID = ts.subdistrict_code
left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
left join (select Condo_Code
            from full_template_unit_type
            where Unit_Type_Status = 1
            and Unit_Floor_Type_ID = 2
            group by Condo_Code) ft
on rc.Condo_Code = ft.Condo_Code
left join (select rc.Condo_Code as Condo_Code, size1.Size_STU_Min, size1.Size_STU_Max, size2.Size_1BED_Min, size2.Size_1BED_Max
                , size3.Size_2BED_Min, size3.Size_2BED_Max, size4.Size_3BED_Min, size4.Size_3BED_Max
                , size5.Size_4BED_Min, size5.Size_4BED_Max
            from real_condo rc
            left join (SELECT Condo_Code
                            , round(min(Size),2) as Size_STU_Min
                            , if(roundsize(min(size))=roundsize(max(size))
                                , ''
                                , round(max(Size),2)) AS Size_STU_Max
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 1
                        GROUP BY Condo_Code) as size1
            on rc.Condo_Code = size1.Condo_Code
            left join (SELECT Condo_Code
                            , round(min(Size),2) as Size_1BED_Min
                            , if(roundsize(min(size))=roundsize(max(size))
                                , ''
                                , round(max(Size),2)) AS Size_1BED_Max
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 2
                        GROUP BY Condo_Code) as size2
            on rc.Condo_Code = size2.Condo_Code
            left join (SELECT Condo_Code
                            , round(min(Size),2) as Size_2BED_Min
                            , if(roundsize(min(size))=roundsize(max(size))
                                , ''
                                , round(max(Size),2)) AS Size_2BED_Max
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 4
                        GROUP BY Condo_Code) as size3
            on rc.Condo_Code = size3.Condo_Code
            left join (SELECT Condo_Code
                            , round(min(Size),2) as Size_3BED_Min
                            , if(roundsize(min(size))=roundsize(max(size))
                                , ''
                                , round(max(Size),2)) AS Size_3BED_Max
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 5
                        GROUP BY Condo_Code) as size4
            on rc.Condo_Code = size4.Condo_Code
            left join (SELECT Condo_Code
                            , round(min(Size),2) as Size_4BED_Min
                            , if(roundsize(min(size))=roundsize(max(size))
                                , ''
                                , round(max(Size),2)) AS Size_4BED_Max
                        FROM full_template_unit_type
                        where Unit_Type_Status <> 2
                        and Room_Type_ID = 6
                        GROUP BY Condo_Code) as size5
            on rc.Condo_Code = size5.Condo_Code) bedsize
on rc.Condo_Code = bedsize.Condo_Code
WHERE rc.Condo_Code in ('CD0193','CD0225','CD0244','CD2091','CD1278','CD2939','CD2052','CD3015','CD3027','CD2656','CD0997','CD2180','CD2996','CD3086','CD3070','CD0305','CD2185','CD0188','CD0994','CD3032','CD2658','CD3028','CD2556')