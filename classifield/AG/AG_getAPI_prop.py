import requests
import xmltodict
import json
import math

#property_file_path = r'C:\PYTHON\TAR.thelist.web2\classifield\AG\AG_PROPERTY.json'
property_file_path = '/home/gitdev/ta_python/classifield/AG/AG_PROPERTY.json'
#property_file_path = '/home/gitprod/ta_python/classifield/AG/AG_PROPERTY.json'

api_path = 'https://feed.theagent.co.th/feed/agreallist/property.ashx?c=ag&t=a&p='
api_url = 'https://feed.theagent.co.th/feed/agreallist/property.ashx?c=ag&t=a&p=1'
data_list = []
response = requests.get(api_url)

response = requests.get(api_url)
if response.status_code == 200:
    xml_dict = xmltodict.parse(response.text)
    data_count = int(xml_dict['Property']['Clients']['feed_count'])
    try:
        divide = int(xml_dict['Property']['Clients']['feed_no'].split("-")[1])
    except:
        divide = int(xml_dict['Property']['Clients']['feed_no'].split("-")[0])
    page = math.ceil(data_count/divide)
    for i in range(page):
        api_url = api_path + str(i+1)
        response = requests.get(api_url)
        xml_dict = xmltodict.parse(response.text)
        listing_data = xml_dict['Property']['Listing']['Property-list']
        data_list.append(listing_data)
        #print(api_url)
    
    merged_list = [each_prop for prop in data_list for each_prop in prop]
    json_string = json.dumps(merged_list, ensure_ascii=False, indent=4)
    with open(property_file_path, 'w', encoding='utf-8') as json_file:
        json_file.write(json_string)
else:
    print(f"Error: {response.status_code}")

print("Property JSON Ready")