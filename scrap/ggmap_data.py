import json

json_path_1 = 'D:\PYTHON\TAR.thelist.web-2\scrap\ggmap.json'
json_path_2 = 'D:\PYTHON\TAR.thelist.web-2\scrap\ggmap_location.json'

data_list = []

def va():
    locality = ''
    sublocality_level_1 = ''
    administrative_area_level_2 = ''
    sublocality_level_2 = ''
    postal_code = ''
    latitude = ''
    longitude = ''
    return locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude

def locate_type():
    locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = va()
    def district():
        locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = va()
        latitude = components['geometry']['location']['lat']
        longitude = components['geometry']['location']['lng']
        for gov in components['address_components']:
            if 'locality' in gov['types']:
                locality = gov['long_name']
            elif 'sublocality_level_1' in gov['types']:
                sublocality_level_1 = gov['long_name']
            elif 'administrative_area_level_2' in gov['types']:
                administrative_area_level_2 = gov['long_name']
            elif 'sublocality_level_2' in gov['types']:
                sublocality_level_2 = gov['long_name']
            elif 'postal_code' in gov['types']:
                postal_code = gov['long_name']
        return locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude

    def point_cal():
        choose = False
        if point >= max(point_list):
            choose = True
        return choose

    count_object = len(project)
    point_list = [0]
    for j, components in enumerate(project):
        point = 0
        geometry = components["geometry"]
        location_type = geometry.get("location_type")
        try:
            code = components['plus_code']['global_code']
            point += 5
        except:
            code = ''
        long_name = components["address_components"][0]["long_name"]

        if "bounds" in geometry:
            location_type = "FOUND BOUNDS"
            use = 0

        if location_type == "ROOFTOP":
            point += 50
            choose = point_cal()
            if choose:
                locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                point_list.append(point)
                use = j + 1
                break
        elif location_type == "RANGE_INTERPOLATED":
            point += 35
            choose = point_cal()
            if choose:
                locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                point_list.append(point)
                use = j + 1
        elif location_type == "GEOMETRIC_CENTER":
            point += 30
            choose = point_cal()
            if choose:
                locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                point_list.append(point)
                use = j + 1
        elif location_type == "APPROXIMATE":
            point += 25
            choose = point_cal()
            if choose:
                locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                point_list.append(point)
                use = j + 1
    return use, count_object, location_type, locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude, code

with open(json_path_1, 'r', encoding='utf-8') as json_file:
    location_data = json.load(json_file)
with open(json_path_2, 'r', encoding='utf-8') as json2_file:
    location_data_2 = json.load(json2_file)

for i, project in enumerate(location_data):
    if project:
        use, count_object, location_type, locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude, code = locate_type()

    else:
        project = location_data_2[i]
        if project:
            use, count_object, location_type, locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude, code = locate_type()
        else:
            use = ''
            count_object = 0
            location_type = 'NOT FOUND'
            code = ''
            locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = va()

    data_dict = {'JSON': i+1, 'SET_COUNT': count_object, 'USE_SET': use, 'TYPE': location_type, 'Locality': locality
                ,'Sublocality_level_1': sublocality_level_1, 'Administrative_area_level_2': administrative_area_level_2
                , 'Sublocality_level_2': sublocality_level_2, 'Postal_Code': postal_code, 'Latitude': latitude, 'Longitude': longitude,'Global_Code': code}
    data_list.append(data_dict)
print('done')