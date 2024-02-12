import pandas as pd
import re

match_file = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_match.csv"
not_match_file = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_not_match.csv"
save_file = "D:\PYTHON\TAR.thelist.web-2\housing_template\work_name_round2.csv"

match = pd.read_csv(match_file, encoding='utf-8')
not_match = pd.read_csv(not_match_file, encoding='utf-8')

match_list = []
for i in range(match.index.size):
    name_match = match.iloc[i][0]
    match_list.append(name_match)

not_match_list = []
for i in range(not_match.index.size):
    link = not_match.iloc[i][0]
    name_not_match = not_match.iloc[i][1]
    not_match_list.append((link , name_not_match))

match2_list = []
i = 0
while i in range(len(not_match_list)):
    match = False
    link_not_match = not_match_list[i][0]
    name_not_match = not_match_list[i][1]
    for name_match in match_list:
        if name_match in name_not_match:
            match = True
            format_name = re.sub(f"{re.escape(name_match)} ", f"{name_match}\n", name_not_match)
            match2_dict = {'Link': link_not_match, 'Name': name_not_match, 'Format_Name': format_name, 'Done': 2}
            match2_list.append(match2_dict)
            not_match_list.pop(i)
            break
    if not match:
        i += 1
        match2_dict = {'Link': link_not_match, 'Name': name_not_match, 'Format_Name': '', 'Done': 0}
        match2_list.append(match2_dict)

data_df = pd.DataFrame(match2_list)
data_df.to_csv(save_file, encoding='utf-8')
print("DONE")