select mtsm.Station_Code
	,ml.Line_Name
    , ms.Station_THName
    , concat('https://thelist.group/realist/condo/list/รถไฟฟ้า/',REGEXP_REPLACE(ml.Line_Name,' ','-'),'/',REGEXP_REPLACE(ms.Station_THName_Display,' ','-')) as Station_URL
from mass_transit_station_match_route mtsm
left join mass_transit_route mr on mtsm.Route_Code = mr.Route_Code
left join mass_transit_line ml on mr.Line_Code = ml.Line_Code
left join mass_transit_station ms on mtsm.Station_Code = ms.Station_Code
where mr.Route_Timeline = 'Completion'
group by ml.Line_Name,ms.Station_THName,ms.Station_THName_Display,ml.Line_Code,mtsm.Station_Code
order by ml.Line_Code,mtsm.Station_Code;