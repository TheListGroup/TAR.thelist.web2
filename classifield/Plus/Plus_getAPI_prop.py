import requests
import json

property_file_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Plus\Plus_PROPERTY.json'
#property_file_path = r'/home/gitdev/ta_python/classifield/Plus/Plus_PROPERTY.json'
#property_file_path = r'/home/gitprod/ta_python/classifield/Plus/Plus_PROPERTY.json'

api_url = "https://cm.plus.co.th/ApiSystem/Realist?key=f8dd385a719549d58ef0dadf168f6b17"

data_list = []
response = requests.get(api_url)
if response.status_code == 200:
    data = response.json()
    for item in data:
        if item['Active_Status'] == True:
            project_info = {
            'Ref_ID': item['Ref_ID'],
            'Project_ID': item['Project']['Project_ID'],
            'Title_TH': item['Title_TH'],
            'Title_ENG': item['Title_ENG'],
            'Description_TH': item['Description_TH'],
            'Description_ENG': item['Description_ENG'],
            'Sale': item['Sale'],
            'Rent': item['Rent'],
            'Price_Sale': item['Price_Sale'],
            'Price_Rent': item['Price_Rent'],
            'Bedroom': item['Bedroom'],
            'Bathroom': item['Bathroom'],
            'Size': item['Size'],
            'Building': item['Building'],
            'Furnish': item['Furnish'],
            'Images': item['Images'],
            'Created_Date': item['Created_Date'],
            'Last_Updated_Date': item['Last_Updated_Date'],
            'is_duplex': item['is_duplex'],
            'is_penthouse': item['is_penthouse'],
            'is_studio': item['is_studio']
            }
            data_list.append(project_info)

    with open(property_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(data_list, json_file, ensure_ascii=False, indent=4)

print("Property JSON Ready")