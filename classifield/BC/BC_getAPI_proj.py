import requests
import json

#project_file_path = r'C:\PYTHON\TAR.thelist.web2\classifield/BC/BC_PROJECT.json'
project_file_path = '/home/gitdev/ta_python/classifield/BC/BC_PROJECT.json'
#project_file_path = '/home/gitprod/ta_python/classifield/BC/BC_PROJECT.json'

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
    #print(token)
else:
    print(f"Error: {response.status_code}")


project_url = 'https://crm-interface-api.bkkcitismart.com/master/v1/project-feed'
project_response = requests.get(project_url)
project_headers = {
        'Authorization': f'Bearer {token}'
    }
project_response = requests.get(project_url, headers=project_headers)
if project_response.status_code == 200:
    project_data = project_response.json()
    with open(project_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(project_data['data'], json_file, ensure_ascii=False, indent=4)
else:
    print(f"Error: {project_response.status_code}")

print("Project JSON Ready")