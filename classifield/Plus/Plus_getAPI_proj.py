import requests
import json

#project_file_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Plus\Plus_PROJECT.json'
#project_file_path = r'/home/gitdev/ta_python/classifield/Plus/Plus_PROJECT.json'
project_file_path = r'/home/gitprod/ta_python/classifield/Plus/Plus_PROJECT.json'

api_url = "https://cm.plus.co.th/ApiSystem/Realist?key=f8dd385a719549d58ef0dadf168f6b17"

data_list = []
response = requests.get(api_url)
if response.status_code == 200:
    data = response.json()
    for item in data:
        project_info = {
        'Project_ID': item['Project']['Project_ID'],
        'Name_TH': item['Project']['Name_TH'],
        'Name_EN': item['Project']['Name_EN'],
        'Latitude': item['Project']['Latitude'],
        'Longitude': item['Project']['Longitude'],
        'Created_Date': item['Project']['Created_Date'],
        'Last_Updated_Date': item['Project']['Last_Updated_Date']
        }
        data_list.append(project_info)
    
    unique_project_ids = set()
    unique_project_data = []
    for project in data_list:
        project_id = project['Project_ID']
        if project_id not in unique_project_ids:
            unique_project_ids.add(project_id)
            unique_project_data.append(project)
    
    with open(project_file_path, 'w', encoding='utf-8') as json_file:
        json.dump(unique_project_data, json_file, ensure_ascii=False, indent=4)

print("Project JSON Ready")