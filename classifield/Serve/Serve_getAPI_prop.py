import json

#property_file_path = r"C:\PYTHON\TAR.thelist.web2\classifield\Serve\SERVE_ALL.json"
#property_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Serve\Serve_PROPERTY.json'
property_file_path = r'/home/gitdev/ta_python/classifield/Serve/SERVE_ALL.json'
property_path = r'/home/gitdev/ta_python/classifield/Serve/Serve_PROPERTY.json'
#property_file_path = r'/home/gitprod/ta_python/classifield/Serve/SERVE_ALL.json'
#property_path = r'/home/gitprod/ta_python/classifield/Serve/Serve_PROPERTY.json'

property_list = []
with open(property_file_path, 'r', encoding='utf-8') as json_file:
    property_data = json.load(json_file)
    for prop in property_data:
        if prop['status'] == 'live':
            prop_info = {
                        'Ref_ID': prop['id'],
                        'Project_ID': prop['project_id'],
                        'Title_TH': next((item['#text'] for item in prop['titles']['title'] if item.get('@lang') == 'th' and '#text' in item), None),
                        'Title_ENG': next((item['#text'] for item in prop['titles']['title'] if item.get('@lang') == 'en' and '#text' in item), None),
                        'Description_TH': next((item['#text'] for item in prop['descriptions']['description'] if item.get('@lang') == 'th' and '#text' in item), None),
                        'Description_ENG': next((item['#text'] for item in prop['descriptions']['description'] if item.get('@lang') == 'en' and '#text' in item), None),
                        'Sale': True if int(prop['price_sale']) > 0 else False,
                        'Rent': True if int(prop['price_rent']) > 0 else False,
                        'Price_Sale': int(prop['price_sale']),
                        'Price_Rent': int(prop['price_rent']),
                        "Bedroom": prop['bedrooms'],
                        "Bathroom": prop['bathrooms'],
                        "Size": float(prop['interior_size']),
                        "Images": prop['images']
                        }
            property_list.append(prop_info)

    with open(property_path, 'w', encoding='utf-8') as json_file:
        json.dump(property_list, json_file, ensure_ascii=False, indent=4)

print("Property JSON Ready")