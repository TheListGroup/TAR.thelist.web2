import Levenshtein as lev
import pandas as pd
import re

input_home = "D:\PYTHON\TAR.thelist.web-2\scrap\Housing_Developer.csv"
input_realist = "D:\PYTHON\TAR.thelist.web-2\scrap\Realist_Developer.csv"
output_csv = "D:\PYTHON\TAR.thelist.web-2\scrap\Match_Developer_TH.csv"

data_list = []
home = pd.read_csv(input_home, encoding='utf-8')
realist = pd.read_csv(input_realist, encoding='utf-8')

print("Start")
for x in range(home.index.size):
    dont_have_th = False
    developer_thname = home.iloc[x][3]
    if pd.notna(home.iloc[x][3]):
        format_list = ["บริษัท","บมจ","จำกัด","(มหาชน)","มหาชน","\| .*",":","\.","\|","–","-","\(.*?\)",","," "]
        for word_clean in format_list:
            developer_thname = re.sub(word_clean, "", developer_thname).strip()
    else:
        dont_have_th = True
    #print(f"Housing -- {home.iloc[x,0]}")
    best_ratio = 0
    
    for y in range(realist.index.size):
        if pd.notna(realist.iloc[y][1]) and pd.notna(home.iloc[x][3]):
            developer_realistth = realist.iloc[y][1]
            for word_clean in format_list:
                developer_realistth = re.sub(word_clean, "", developer_realistth).strip()
            ratio = lev.ratio(developer_thname, developer_realistth)
            
            if (ratio == 1):
                best_ratio = ratio
                best_word = developer_realistth
                best_dev_code = realist.iloc[y][0]
                developer_realistth_full = realist.iloc[y][1]
                break
            elif (ratio > best_ratio):
                best_ratio = ratio
                best_word = developer_realistth
                best_dev_code = realist.iloc[y][0]
                developer_realistth_full = realist.iloc[y][1]
            #print(f"{home.iloc[x][0]} -- {developer_thname} ---- {best_dev_code} -- {best_word} -- {best_ratio}")
    if dont_have_th == False:
        data_dict = {"ID": home.iloc[x][0], "LINK": home.iloc[x][1], "Developer_Full_TH": home.iloc[x][3], "Developer_TH": developer_thname
                    , "Dev_TH": best_word, "Dev_THFull": developer_realistth_full, "Dev_Code": best_dev_code, "Point": best_ratio}
    else:
        data_dict = {"ID": home.iloc[x][0], "LINK": home.iloc[x][1], "Developer_Full_TH": "", "Developer_TH": "", "Dev_TH": ""
                    , "Dev_THFull": "", "Dev_Code": "", "Point": ""}
    data_list.append(data_dict)
    if int(home.iloc[x][0]) % 500 == 0:
        print(home.iloc[x][0])

data_df = pd.DataFrame(data_list)
data_df.to_csv(output_csv, encoding='utf-8')
print('DONE')