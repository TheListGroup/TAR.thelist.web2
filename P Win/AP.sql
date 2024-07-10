SELECT rc.Condo_Code
    , rc.Condo_Name
    , ff.Station
    , ff.Real_District as 'ย่าน'
    , ff.Road_Name
    , ff.District_Name
    , ts.name_th as SubDistrict_Name
    , ff.Province
    , rc.Condo_Latitude
    , rc.Condo_Longitude
    , ifnull(year(rcp.Condo_Built_Start),'') as 'ปีเปิดตัว'
    , ifnull(year(rcp.Condo_Built_Finished),'') as 'ปีสร้างเสร็จ'
    , round(rc.Condo_TotalRai,2) as 'ขนาดที่ดิน'
    , replace(replace(concat(replace(rc.Condo_Building,'"'," "), ' ชั้น'),"Buildings",' อาคาร'),",",' ชั้น') as 'จำนวนอาคาร/ชั้น'
    , rc.Condo_TotalUnit as 'จำนวนยูนิต'
    , ff.Condo_Sold_Status_Show_Value as 'สถานะโครงการ'
    , ifnull(bedsize.Size_STU_Min,'') as 'ขนาดห้อง Studio เล็กสุด'
    , ifnull(bedsize.Size_STU_Max,'') as 'ขนาดห้อง Studio ใหญ่สุด'
    , ifnull(bedsize.Size_1BED_Min,'') as 'ขนาดห้อง 1Bed เล็กสุด'
    , ifnull(bedsize.Size_1BED_Max,'') as 'ขนาดห้อง 1Bed ใหญ่สุด'
    , ifnull(bedsize.Size_2BED_Min,'') as 'ขนาดห้อง 2Bed เล็กสุด'
    , ifnull(bedsize.Size_2BED_Max,'') as 'ขนาดห้อง 2Bed ใหญ่สุด'
    , ifnull(bedsize.Size_3BED_Min,'') as 'ขนาดห้อง 3Bed เล็กสุด'
    , ifnull(bedsize.Size_3BED_Max,'') as 'ขนาดห้อง 3Bed ใหญ่สุด'
    , ifnull(bedsize.Size_4BED_Min,'') as 'ขนาดห้อง 4Bed ขึ้นไปเล็กสุด'
    , ifnull(bedsize.Size_4BED_Max,'') as 'ขนาดห้อง 4Bed ขึ้นไปใหญ่สุด'
    , ifnull(rcft.Manual_Parking_Amount,'') as Manual_Parking_Amount
    , ifnull(rcft.Auto_Parking_Amount,'') as Auto_Parking_Amount
    , ff.Parking_Per_Unit as Parking_Per_Unit
    , ifnull(rcft.Condo_Fund_Fee,'') as 'ค่ากองทุน'
    , ifnull(rcft.Passenger_Lift_Amount,'') as 'ลิฟท์โดยสาร'
    , ifnull(rcft.Service_Lift_Amount,'') as 'ลิฟท์ Service'
    , ff.Pool_Size
    , ifnull(ff.Pool_2_Size,'') as Pool_2_Size
    , replace(ff.Price_Average_Square, " บ./ตร.ม.", "") as 'เฉลี่ย/ตร.ม.'
    , replace(ff.Price_Average_Resale_Square, " บ./ตร.ม.", "") as 'Resale เฉลี่ย/ตร.ม.'
    , replace(ff.Price_Start_Square, " บ./ตร.ม.", "") as 'เริ่มต้น/ตร.ม.'
    , replace(ff.Price_Start_Unit, " ลบ.", "") as 'เริ่มต้น/ยูนิต'
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
WHERE rc.Condo_Code in ('CD1305','CD1321','CD2180','CD2996','CD3086','CD1820','CD2972','CD1351','CD1497','CD3096','CD2973','CD2955','CD2919','CD2633','CD2583','CD2595','CD2168','CD1831');