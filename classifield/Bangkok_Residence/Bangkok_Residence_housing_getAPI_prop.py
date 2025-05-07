import requests
import json

#property_file_path = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\Bangkok_Residence\Bangkok_Residence_housing_PROPERTY.json"
#property_file_path = r'/home/gitdev/ta_python/classifield/Bangkok_Residence/Bangkok_Residence_housing_PROPERTY.json'
property_file_path = r'/home/gitprod/ta_python/classifield/Bangkok_Residence/Bangkok_Residence_housing_PROPERTY.json'

api_url = "https://www.thebkkresidence.com/api/houses-list"

data_list = []
response = requests.get(api_url)
if response.status_code == 200:
    data = response.json()
    for item in data['data']:
        if item['Active_Status'] == '1':
            project_info = {
            'Ref_ID': item['Ref_ID'],
            'Project_ID': item['Project_ID'],
            'Housing_Type': item['Housing_Type'],
            'Housing_Latitude': item['Housing_Latitude'],
            'Housing_Longitude': item['Housing_Longitude'],
            'Title_TH': item['Title_TH'],
            'Title_ENG': item['Title_ENG'],
            'Description_TH': item['Description_TH'],
            'Description_ENG': item['Description_ENG'],
            'Sale_with_Tenant': item['Sale_with_Tenant'],
            'Sale_Reservation': item['Reservation'],
            'Sale_Transfer_Fee': item['Transfer'],
            'Sale_Contact': item['Sale_Contact'],
            'Price_Sale': item['Price_Sale'],
            'Price_Rent': item['Price_Rent'],
            'Min_Rental_Contract': item['Min_Rental_Contract'],
            'Deposit': item['Rent_Deposit'],
            'Advance_Payment': item['Advance_Payment'],
            'Housing_TotalRai': item['TotalRai'],
            'Housing_Usable_Area': item['Usable_Area'],
            'Floor': item['Floor'],
            'Bedroom': item['Bedroom'],
            'Bathroom': item['Bathroom'],
            'Parking_Amount': item['Parking_Amount'],
            'Direction': item['Direction'],
            'Furnish': item['Furnish'],
            'Move_In': item['Move_In'],
            'Images': item['Images'],
            'Created_Date': item['Created_Date'],
            'Last_Updated_Date': item['Last_Updated_Date']
            }
            data_list.append(project_info)

    with open(property_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(data_list, json_file, ensure_ascii=False, indent=4)

print("Property JSON Ready")