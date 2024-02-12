import pandas as pd

input1 = "D:\PYTHON\TAR.thelist.web-2\Samie\district.csv"
input2 = "D:\PYTHON\TAR.thelist.web-2\Samie\clean_subdistrict.csv"
input3 = "D:\PYTHON\TAR.thelist.web-2\Samie\khet_kwang.csv"
file_name = "D:\PYTHON\TAR.thelist.web-2\Samie\work_khet_kwang.csv"

district = pd.read_csv(input1, encoding='utf-8')
subdistrict = pd.read_csv(input2, encoding='utf-8')
khet_kwang = pd.read_csv(input3, encoding='utf-8')

district_list = []
for i in range(district.index.size):
    district_name = district.iloc[i][0].strip()
    district_list.append(district_name)
for i in range(subdistrict.index.size):
    subdistrict_name = subdistrict.iloc[i][0].strip()
    district_list.append(subdistrict_name)

data_list = []
for i in range(khet_kwang.index.size):
    j = 0
    khet_kwang_name = khet_kwang.iloc[i][0]
    khet_kwang_name_split = khet_kwang_name.split('-')
    while j in range(len(khet_kwang_name_split)):
        found = False
        for k, name1 in enumerate(district_list):
            name2 = khet_kwang_name_split[j]
            if name2 == name1:
                khet_kwang_name_split.remove(name2)
                found = True
                break
        if not found:
            j += 1
    khet_kwang_name_split = '-'.join(khet_kwang_name_split)
    data_dict = {'Khet_Kwang_Name': khet_kwang_name, 'Khet_Kwang': khet_kwang_name_split
                , 'Khet_Kwang_ENName': khet_kwang.iloc[i][1], 'URL': khet_kwang.iloc[i][2]
                , 'Condo_Count': khet_kwang.iloc[i][3]}
    data_list.append(data_dict)
data_df = pd.DataFrame(data_list)
data_df.to_csv(file_name, encoding='utf-8')
print('OK')