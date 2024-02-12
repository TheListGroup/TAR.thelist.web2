-- ads_housing_project_view
CREATE OR REPLACE VIEW ads_housing_project_view AS
select h.Housing_Code as Prop_Code
    , h.Housing_Latitude
    , h.Housing_Latitude
    , h.Housing_ENName
    , concat('เริ่มต้น ',format((h.Housing_Price_Min/1000000),2),' ลบ.') as Price
    , if(h.Housing_Built_Finished is not null
        ,if(year(curdate()) - year(h.Housing_Built_Finished) > 0
            ,if(housing_type.Housing_Code is not null
                ,'โครงการ พร้อมอยู่'
                ,if(h.IS_HO = 1
                    ,'โฮมออฟฟิศ พร้อมอยู่'
                    ,if(h.IS_SH = 1 is not null
                        ,'อาคารพาณิชย์ พร้อมอยู่'
                        ,if(h.IS_TH = 1 is not null
                            ,'ทาวน์โฮม พร้อมอยู่'
                            ,if(h.IS_DD = 1 is not null
                                ,'บ้านแฝด พร้อมอยู่'
                                ,if(h.IS_SD = 1 is not null
                                    ,'บ้านเดี่ยว พร้อมอยู่'
                                    ,null))))))
            ,if(housing_type.Housing_Code is not null
                ,'โครงการ ใหม่'
                ,if(h.IS_HO = 1
                    ,'โฮมออฟฟิศ ใหม่'
                    ,if(h.IS_SH = 1
                        ,'อาคารพาณิชย์ ใหม่'
                        ,if(h.IS_TH = 1
                            ,'ทาวน์โฮม ใหม่'
                            ,if(h.IS_DD = 1
                                ,'บ้านแฝด ใหม่'
                                ,if(h.IS_SD = 1
                                    ,'บ้านเดี่ยว ใหม่'
                                    ,null)))))))
        ,if(h.Housing_Built_Start is not null
            ,if(year(curdate()) - (year(h.Housing_Built_Start) + 3) > 0
                ,if(housing_type.Housing_Code is not null
                    ,'โครงการ พร้อมอยู่'
                    ,if(h.IS_HO = 1
                        ,'โฮมออฟฟิศ พร้อมอยู่'
                        ,if(h.IS_SH = 1
                            ,'อาคารพาณิชย์ พร้อมอยู่'
                            ,if(h.IS_TH = 1
                                ,'ทาวน์โฮม พร้อมอยู่'
                                ,if(h.IS_DD = 1
                                    ,'บ้านแฝด พร้อมอยู่'
                                    ,if(h.IS_SD = 1
                                        ,'บ้านเดี่ยว พร้อมอยู่'
                                        ,null))))))
                ,if(housing_type.Housing_Code is not null
                    ,'โครงการ พร้อมอยู่'
                    ,if(h.IS_HO = 1
                        ,'โฮมออฟฟิศ พร้อมอยู่'
                        ,if(h.IS_SH = 1
                            ,'อาคารพาณิชย์ พร้อมอยู่'
                            ,if(h.IS_TH = 1
                                ,'ทาวน์โฮม พร้อมอยู่'
                                ,if(h.IS_DD = 1
                                    ,'บ้านแฝด พร้อมอยู่'
                                    ,if(h.IS_SD = 1
                                        ,'บ้านเดี่ยว พร้อมอยู่'
                                        ,null)))))))
            ,null)) as Project_Status
    , if(h.IS_TH = 1 or h.IS_DD = 1 or h.IS_SD = 1
        , if(h.Housing_Price_Min <= 15000000
            , (select word from ads_words where `word_set` = '3' order by rand() limit 1)
            , if(h.Housing_Price_Min > 15000000
                ,(select word from ads_words where `word_set` = '4' order by rand() limit 1)
                ,null))
        , if(h.IS_HO = 1
            , (select word from ads_words where `word_set` = '5' order by rand() limit 1)
            , if(h.IS_SH = 1
                , (select word from ads_words where `word_set` = '6' order by rand() limit 1)
                , NULL))) as Word
    , concat_ws('\n',h.Housing_Spotlight_1,h.Housing_Spotlight_2) as Attribute
    , rsd.SubDistrict_Name as Location
    , express_way.Express_Way
    , 'Link' as Link -- ??? 
    , concat(h.Housing_Code,"/",h.Housing_Code,ads_desktop_billboard('HP')) as Desktop_Billboard_Image
    , concat(h.Housing_Code,"/",h.Housing_Code,ads_mobile_billboard('HP')) as Mobile_Billboard_Image
    , concat(h.Housing_Code,"/",h.Housing_Code,ads_banner('HP')) as Banner_Image
from housing h
left join ( select Housing_Code
                , IS_SD , IS_DD, IS_TH, IS_HO, IS_SH
            from housing
            where Housing_Status = '1'
            and IS_SD + IS_DD + IS_TH + IS_HO + IS_SH > 1) housing_type
on h.Housing_Code = housing_type.Housing_Code
left join real_yarn_sub rsd on h.RealSubDistrict_Code = rsd.SubDistrict_Code
left join ( select Housing_Code,concat(Place_Attribute_1,' ',Place_Attribute_2) as Express_Way
            from (  select Housing_Code
                            , Place_ID
                            , Place_Attribute_1
                            , Place_Attribute_2
                            , ROW_NUMBER() OVER (PARTITION BY Housing_Code ORDER BY Distance) AS RowNum
                    from housing_around_express_way
                    order by Housing_Code) ew
            where ew.RowNum = 1 ) express_way 
on h.Housing_Code = express_way.Housing_Code
where h.Housing_Status = '1';