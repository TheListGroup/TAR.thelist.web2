import json
import re

#project_file_path = r"C:\PYTHON\TAR.thelist.web2\classifield\Serve\SERVE_ALL.json"
#project_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Serve\Serve_PROJECT.json'
project_file_path = r'/home/gitdev/ta_python/classifield/Serve/SERVE_ALL.json'
project_path = r'/home/gitdev/ta_python/classifield/Serve/Serve_PROJECT.json'
#project_file_path = r'/home/gitprod/ta_python/classifield/Serve/SERVE_ALL.json'
#project_path = r'/home/gitprod/ta_python/classifield/Serve/Serve_PROJECT.json'

project_list = []
with open(project_file_path, 'r', encoding='utf-8') as json_file:
    project_data = json.load(json_file)
    for project in project_data:
        if project['type'] == 'condo':
            project_info = {
                            'Project_ID': project['project_id'],
                            'Name_TH': (next(iter(re.findall(r'\((.*?)\)', project['project_name'])), None).strip()
                                        if re.findall(r'\((.*?)\)', project['project_name']) else None),
                            'Name_EN': re.sub(r'\(.*?\)', '', project['project_name']).strip(),
                            'Latitude': project['gps_lat'],
                            'Longitude': project['gps_lon']
                            }
            project_list.append(project_info)
    
    unique_project_ids = set()
    unique_project_data = []
    for project in project_list:
        project_id = project['Project_ID']
        if project_id not in unique_project_ids:
            unique_project_ids.add(project_id)
            unique_project_data.append(project)
    
    with open(project_path, 'w', encoding='utf-8') as json_file:
        json.dump(unique_project_data, json_file, ensure_ascii=False, indent=4)

print("Project JSON Ready")