import Levenshtein as lev
import pandas as pd
import re

input_home = "D:\PYTHON\TAR.thelist.web-2\scrap\Housing_Developer_EN.csv"
input_realist = "D:\PYTHON\TAR.thelist.web-2\scrap\Realist_Developer.csv"
output_csv = "D:\PYTHON\TAR.thelist.web-2\scrap\Match_Developer_EN.csv"

data_list = []
home = pd.read_csv(input_home, encoding='utf-8')
realist = pd.read_csv(input_realist, encoding='utf-8')

print("Start")
for x in range(home.index.size):
    dont_have_en = False
    if pd.notna(home.iloc[x][2]):
        developer_enname = home.iloc[x][2].lower()
    if pd.notna(home.iloc[x][2]):
        format_list = [" ","\|","co.,ltd.","\.","–","’","'","plc","public","company","limited","\(.*?\)",","," "]
        for word_clean in format_list:
            developer_enname = re.sub(word_clean, "", developer_enname).strip()
    else:
        dont_have_en = True
    #print(f"Housing -- {home.iloc[x,0]}")
    best_ratio = 0
    
    for y in range(realist.index.size):
        if pd.notna(realist.iloc[y][2]) and pd.notna(home.iloc[x][2]): 
            developer_realisten = realist.iloc[y][2].lower()
            for word_clean in format_list:
                developer_realisten = re.sub(word_clean, "", developer_realisten).strip()
            ratio = lev.ratio(developer_enname, developer_realisten)
            
            if (ratio == 1):
                best_ratio = ratio
                best_word = developer_realisten
                best_dev_code = realist.iloc[y][0]
                developer_realisten_full = realist.iloc[y][2]
                break
            elif (ratio > best_ratio):
                best_ratio = ratio
                best_word = developer_realisten
                best_dev_code = realist.iloc[y][0]
                developer_realisten_full = realist.iloc[y][2]
            #print(f"{home.iloc[x][0]} -- {developer_thname} ---- {best_dev_code} -- {best_word} -- {best_ratio}")
    if dont_have_en == False:
        data_dict = {"ID": home.iloc[x][0], "LINK": home.iloc[x][1], "Developer_Full_EN": home.iloc[x][2], "Developer_EN": developer_enname
                    , "Dev_EN": best_word, "Dev_ENFull": developer_realisten_full, "Dev_Code": best_dev_code, "Point": best_ratio}
    else:
        data_dict = {"ID": home.iloc[x][0], "LINK": home.iloc[x][1], "Developer_Full_EN": "", "Developer_EN": "", "Dev_EN": ""
                    , "Dev_ENFull": "", "Dev_Code": "", "Point": ""}
    data_list.append(data_dict)
    if x % 500 == 0:
        print(x)

data_df = pd.DataFrame(data_list)
data_df.to_csv(output_csv, encoding='utf-8')
print('DONE')