-- province
-- district
-- subdistrict
-- segment
-- spotlight
--

-- province
select name_th
    , name_en
    , concat('https://thelist.group/realist/condo/list/จังหวัด/',REGEXP_REPLACE(name_th,' ','-'),'/') as Province_URL
    , Condo_Count
from thailand_province
where Condo_Count > 0;

-- district
SELECT td.name_th AS name_th,
    td.name_en AS name_en,
    concat('https://thelist.group/realist/condo/list/จังหวัด/',tp.name_th,'/',td.name_th) AS District_URL
    , td.Condo_Count
FROM thailand_district td
left join thailand_province tp on td.province_id = tp.province_code
WHERE td.Condo_Count > 0
AND tp.Condo_Count > 0
and tp.province_code = 10;

-- subdistrict
select ts.name_th
    , ts.name_en
    , concat('https://thelist.group/realist/condo/list/จังหวัด/',REGEXP_REPLACE(tp.name_th,' ','-'),'/',REGEXP_REPLACE(td.name_th,' ','-'),'/',REGEXP_REPLACE(ts.name_th,' ','-')) as SubDistrict_URL
    , ts.Condo_Count
from thailand_subdistrict ts
left join thailand_district td on ts.district_id = td.district_code
left join thailand_province tp on td.province_id = tp.province_code
where td.Condo_Count > 0
and tp.Condo_Count > 0
and ts.Condo_Count > 0
and tp.province_code = 10;

-- segment
select Segment_Name
    , concat('https://thelist.group/realist/condo/list/segment/',REGEXP_REPLACE(Segment_Name,' ','-'),'/') as Segment_URL
    , Condo_Count
from real_condo_segment
where Condo_Count > 0
and Segment_Code = 'SEG06';

-- spotlight
select Spotlight_Name
    , concat('https://thelist.group/realist/condo/list/spotlight/',REGEXP_REPLACE(Spotlight_Name,' ','-'),'/') as Spotlight_URL
    , Condo_Count
from real_condo_spotlight
where Condo_Count > 0
and Spotlight_Code in ('CUS010','CUS032','CUS014','CUS030','CUS031','PS001','PS002','PS024');

--
select ml.Line_Name
    , ml.Line_Name_Eng
    , ms.Station_THName
    , ms.Station_ENName
    , ms.Station_THName_Display
    , ms.Station_ENName_Display
    , concat('/realist/condo/list/รถไฟฟ้า/',REGEXP_REPLACE(ml.Line_Name,' ','-'),'/',REGEXP_REPLACE(ms.Station_THName_Display,' ','-')) as Station_URL
from mass_transit_station_match_route mtsm
left join mass_transit_route mr on mtsm.Route_Code = mr.Route_Code
left join mass_transit_line ml on mr.Line_Code = ml.Line_Code
left join mass_transit_station ms on mtsm.Station_Code = ms.Station_Code
where ms.Condo_Count > 0
and ml.Line_Code in ('LINE07','LINE13');