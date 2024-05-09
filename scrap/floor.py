import pandas as pd
import re

file = r'C:\PYTHON\TAR.thelist.web2\scrap\home.csv'
csv_file = r'C:\PYTHON\TAR.thelist.web2\scrap\home_floor.csv'

urls = pd.read_csv(file)

data_list = []

ind = 0
while ind in urls.index:
    url = urls.iloc[ind].iloc[0]
    data_dict = {'Link' : url}
    house_type = urls.iloc[ind].iloc[7]
    floor_min,floor_max = '',''
    if pd.notna(house_type):
        pattern = r'(\d+)\s+ชั้น'
        matches = re.findall(pattern, house_type)
        matches = list(set(matches))
        matches = sorted(matches)
        if len(matches) == 2:
            floor_min = str(matches[0])
            floor_max = str(matches[1])
        elif len(matches) == 1:
            floor_min = str(matches[0])
        elif len(matches) > 2:
            floor_min = str(min(matches))
            floor_max = str(max(matches))
    data_dict["Floor_Min"] = floor_min
    data_dict["Floor_Max"] = floor_max
    print(f"LINK {ind+1} -- {url}")
    ind += 1
    data_list.append(data_dict)

data_df = pd.DataFrame(data_list)
data_df.to_csv(csv_file, encoding='utf-8')
print("OK")