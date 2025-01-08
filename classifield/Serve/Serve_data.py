import requests
import xmltodict
import json

#project_file_path = r"C:\PYTHON\TAR.thelist.web2\classifield\Serve\SERVE_ALL.json"
project_file_path = r'/home/gitdev/ta_python/classifield/Serve/SERVE_ALL.json'
#project_file_path = r'/home/gitprod/ta_python/classifield/Serve/SERVE_ALL.json'

api_url = "https://www.serve.co.th/api/nestopa/gets"
data_list = []
response = requests.get(api_url)
if response.status_code == 200:
    response.encoding = 'utf-8'
    xml_dict = xmltodict.parse(response.text)
    json_string = json.dumps(xml_dict['listings']['listing'], ensure_ascii=False, indent=4)
    with open(project_file_path, 'w', encoding='utf-8') as json_file:
        json_file.write(json_string)

print("Project JSON Ready")