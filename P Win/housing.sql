SELECT h.Housing_Code, h.Housing_Name, h.Housing_ENName, hb.Brand_Name, cd.Developer_ENName, h.Housing_Latitude, h.Housing_Longitude, h.Road_Name, h.Postal_Code, h.SubDistrict_ID, h.District_ID
, tp.name_th, h.RealSubDistrict_Code, h.RealDistrict_Code, h.Housing_LandRai, h.Housing_LandNgan, h.Housing_LandWa, h.Housing_TotalRai, h.Housing_Floor_Min, h.Housing_Floor_Max, h.Housing_TotalUnit
, h.Housing_Area_Min, h.Housing_Area_Max, h.Housing_Usable_Area_Min, h.Housing_Usable_Area_Max, h.Bedroom_Min, h.Bedroom_Max, h.Bathroom_Min, h.Bathroom_Max, h.Housing_Price_Min, h.Housing_Price_Max, h.Housing_Price_Date, h.Housing_Built_Start
, h.Housing_Built_Finished, h.Housing_Sold_Status_Raw_Number, h.Housing_Sold_Status_Date, h.Housing_Parking_Min, h.Housing_Parking_Max, h.Housing_Common_Fee_Min, h.Housing_Common_Fee_Max
, if(h.IS_SD=1,'TRUE','FALSE') as Single_Detached_House
, if(h.IS_DD=1,'TRUE','FALSE') as Double_Detached_House
, if(h.IS_TH=1,'TRUE','FALSE') as Townhome
, if(h.IS_HO=1,'TRUE','FALSE') as Shophouse
, if(h.IS_SH=1,'TRUE','FALSE') as Home_Office
FROM `housing` h
left join housing_brand hb on h.Brand_Code = hb.Brand_Code
left join condo_developer cd on h.Developer_Code = cd.Developer_Code
left join thailand_province tp on h.Province_ID = tp.province_code
where h.Housing_Status = '1'
and h.Housing_TotalUnit <= 20;