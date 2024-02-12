import pandas as pd
import requests
import re

def check_null(variable):
    if pd.isna(variable) or variable == '':
        variable = None
    return variable

def format_address_name(var1):
    var1 = var1.lower()
    word_list = ['amphoe','tambon','khet','khwaeng','district']
    for word in word_list:
        var1 = re.sub(' ','',re.sub(word,'',var1)).strip()
    return var1

def select(var1):
    if var1 != '':
        var1 = format_address_name(var1)
    return var1

def check_blank(va):
    if va != '':
        format_list.append(va)
        format_list.sort()

def sort_list(va1,va2,va3):
    va3 = [va1,va2]
    va3.sort()
    return va3

def create_dict(dict_name):
    dict_name = {'Link': link, 'Latitude' : latitude, 'Longitude' : longitude, 'District_EN': item[2], 'District_TH': item[6]
                , 'District_ID': item[1], 'SubDistrict_EN': item[4], 'SubDistrict_TH': item[7], 'SubDistrict_ID': item[3]
                , 'Postal_Code': item[5] ,'Province': item[8], 'Province_ID': item[0]}
    return dict_name

output_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\home_address.csv"
csv_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\home.csv"
postal_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\postal_code.csv"
api_path = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='
key = '&key=AIzaSyDqh3t4OB3_RUR8_5N36fGrkfl2UE87JvE'

csv = pd.read_csv(csv_path, encoding='utf-8')
th_db = pd.read_csv(postal_path, encoding='utf-8')

address_list = []
for i in range(th_db.index.size):
    real_province_id = th_db.iloc[i][10]
    real_district_id = th_db.iloc[i][5]
    real_district = th_db.iloc[i][9]
    real_subdistrict_id = th_db.iloc[i][0]
    real_subdistrict = th_db.iloc[i][4]
    real_postal_code = th_db.iloc[i][18]
    real_district_th = th_db.iloc[i][8]
    real_subdistrict_th = th_db.iloc[i][3]
    real_provine = th_db.iloc[i][11]
    address_list.append((real_province_id,real_district_id,real_district,real_subdistrict_id,real_subdistrict
                        ,real_postal_code,real_district_th,real_subdistrict_th,real_provine)) 

data_list = []
n = 0
print("Working...")
for i in range(csv.index.size):
    found = False
    link = csv.iloc[i][1]
    data_dict = {'Link' : link}
    latitude = check_null(csv.iloc[i][86])
    longitude = check_null(csv.iloc[i][87])
    data_dict = {'Link' : link, 'Latitude' : latitude, 'Longitude' : longitude}
    postal_code = check_null(csv.iloc[i][85])
    if latitude != None and longitude != None:
        full_api = requests.get(api_path + str(latitude) + ',' + str(longitude) + key)
        json_data = full_api.json()
        for j, data in enumerate(json_data['results']):
            format_list = []
            locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2,district,subdistrict,administrative_area_level_3 = '','','','','','',''
            for gov in data['address_components']:
                if 'locality' in gov['types']:
                    locality = gov['long_name']
                elif 'sublocality_level_1' in gov['types']:
                    sublocality_level_1 = gov['long_name']
                elif 'administrative_area_level_2' in gov['types']:
                    administrative_area_level_2 = gov['long_name']
                elif 'sublocality_level_2' in gov['types']:
                    sublocality_level_2 = gov['long_name']
                elif 'administrative_area_level_3' in gov['types']:
                    administrative_area_level_3 = gov['long_name']
            
            locality = select(locality)
            sublocality_level_1 = select(sublocality_level_1)
            administrative_area_level_2 = select(administrative_area_level_2)
            sublocality_level_2 = select(sublocality_level_2)
            administrative_area_level_3 = select(administrative_area_level_3)
            
            cal_list = [locality,sublocality_level_1,administrative_area_level_2,sublocality_level_2,administrative_area_level_3]
            for cal in cal_list:
                check_blank(cal)
            
            try:
                postal_code = int(postal_code)
            except:
                postal_code = 0
            
            #select_list = []
            #for address in address_list:
            #    if address[5] == postal_code:
            #        select_list.append(address)
            for item in address_list:
                item_list,item_list_th_th,item_list_th_en,item_list_en_th  = '','','',''
                real_district = re.sub(' ','',item[2]).lower().strip()
                real_subdistrict = re.sub(' ','',item[4]).lower().strip()
                item_list = sort_list(real_district,real_subdistrict,item_list)
                item_list_th_th = sort_list(item[6],item[7],item_list_th_th) #เขตแขวงไทย
                item_list_th_en = sort_list(item[6],real_subdistrict,item_list_th_en) #เขตไทย แขวงอิ้ง
                item_list_en_th = sort_list(real_district,item[7],item_list_en_th) #เขตอิ้ง แขวงไทย
                if all(x == y for x, y in zip(format_list, item_list)):
                    data_dict = create_dict(data_dict)
                    found =True
                    break
                elif all(x == y for x, y in zip(format_list, item_list_th_th)):
                    data_dict = create_dict(data_dict)
                    found =True
                    break
                elif all(x == y for x, y in zip(format_list, item_list_th_en)):
                    data_dict = create_dict(data_dict)
                    found =True
                    break
                elif all(x == y for x, y in zip(format_list, item_list_en_th)):
                    data_dict = create_dict(data_dict)
                    found =True
                    break
            if found:
                break

    data_list.append(data_dict)
    n += 1
    if n % 800 == 0:
        print(n)

data_df = pd.DataFrame(data_list)
data_df.to_csv(output_path, encoding='utf-8')
print('DONE')