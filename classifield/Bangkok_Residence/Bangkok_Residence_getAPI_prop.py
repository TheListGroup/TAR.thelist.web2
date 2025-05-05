import requests
import json

#property_file_path = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\Bangkok_Residence\Bangkok_Residence_PROPERTY.json"
#property_file_path = r'/home/gitdev/ta_python/classifield/Bangkok_Residence/Bangkok_Residence_PROPERTY.json'
property_file_path = r'/home/gitprod/ta_python/classifield/Bangkok_Residence/Bangkok_Residence_PROPERTY.json'

api_url = "https://www.thebkkresidence.com/api/property-list"

data_list = []
response = requests.get(api_url)
if response.status_code == 200:
    data = response.json()
    for item in data:
        if item['Active_Status'] == '1':
            project_info = {
            'Ref_ID': item['Ref_ID'],
            'Project_ID': item['Project_ID'],
            'Title_TH': item['Title_TH'],
            'Title_ENG': item['Title_ENG'],
            'Description_TH': item['Description_TH'],
            'Description_ENG': item['Description_ENG'],
            'Sale': item['Sale'],
            'Sale_with_Tenant': item['Sale_with_Tenant'],
            'Rent': item['Rent'],
            'Price_Sale': item['Price_Sale'],
            'Price_Rent': item['Price_Rent'],
            'Min_Rental_Contract': item['Min_Rental_Contract'],
            'Deposit': item['Deposit'],
            'Advance_Payment': item['Advance_Payment'],
            'Bedroom': item['Bedroom'],
            'Bathroom': item['Bathroom'],
            'Size': item['Size'],
            'Building': item['Building'],
            'Floor': item['Floor'],
            'Furnish': item['Furnish'],
            'Fix_Parking': item['Fix_Parking'],
            'Parking_Amount': item['Parking_Amount'],
            'Images': item['Images'],
            'Created_Date': item['Created_Date'],
            'Last_Updated_Date': item['Last_Updated_Date']
            }
            data_list.append(project_info)

    with open(property_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(data_list, json_file, ensure_ascii=False, indent=4)

print("Property JSON Ready")