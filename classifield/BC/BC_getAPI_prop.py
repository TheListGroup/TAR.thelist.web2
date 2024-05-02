import requests
import json

#property_file_path = 'D:\PYTHON\TAR.thelist.web-1\classifield\BC\BC_PROPERTY.json'
#project_file_path = '/home/gitdev/ta_python/classifield/BC/BC_PROJECT.json'
property_file_path = '/home/gitprod/ta_python/classifield/BC/BC_PROPERTY.json'

api_url = 'https://crm-interface-api.bkkcitismart.com/api/ext/bc/v1/auth'
response = requests.get(api_url)
headers = {
    'Application-Name': 'data-feed',
    'client_id': 'realist',
    'client_secret': '0200BBEE0C2C4586C3B4E5C028CAECB5',
}
response = requests.get(api_url, headers=headers)
if response.status_code == 200:
    data = response.json()
    token = data['access_token']
else:
    print(f"Error: {response.status_code}")


property_url = 'https://crm-interface-api.bkkcitismart.com/master/v1/property-feed'
property_response = requests.get(property_url)
property_headers = {
        'Authorization': f'Bearer {token}'
    }
property_response = requests.get(property_url, headers=property_headers)
if property_response.status_code == 200:
    property_data = property_response.json()
    with open(property_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(property_data['data'], json_file, ensure_ascii=False, indent=4)
else:
    print(f"Error: {property_response.status_code}")

print("Property JSON Ready")