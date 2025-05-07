import requests
import json

#project_file_path = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\Bangkok_Residence\Bangkok_Residence_housing_PROJECT.json"
#project_file_path = r"/home/gitdev/ta_python/classifield/Bangkok_Residence/Bangkok_Residence_housing_PROJECT.json"
project_file_path = r"/home/gitprod/ta_python/classifield/Bangkok_Residence/Bangkok_Residence_housing_PROJECT.json"

api_url = 'https://www.thebkkresidence.com/api/houses-project-list'
response = requests.get(api_url)
if response.status_code == 200:
    data = response.json()
    project_list = data.get('data', [])
    with open(project_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(project_list, json_file, ensure_ascii=False, indent=4)
else:
    print(f"Error: {response.status_code}")

print("Project JSON Ready")