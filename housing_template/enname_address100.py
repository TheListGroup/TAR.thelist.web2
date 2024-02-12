import pandas as pd
import re

list_en = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_eng.csv"
csv_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_not_match_eng.csv"

file_name = "D:\PYTHON\TAR.thelist.web-2\housing_template\work_nameEN2.csv"

def check_null(variable):
    if pd.isna(variable) or variable == '':
        variable = None
    else:
        variable = str(variable).strip()
    return variable

en = pd.read_csv(list_en, encoding='utf-8')
csv = pd.read_csv(csv_path, encoding='utf-8')

en_list = []
for i in range(en.index.size):
    name_en = en.iloc[i][0]
    en_list.append(name_en)

data_list = []
for i in range(csv.index.size):
    code = check_null(csv.iloc[i][0])
    name = check_null(csv.iloc[i][2])
    if name != None:
        name_split = name.split()
        final_word = name_split[0]
        done = False
        for word in name_split[1:]:
            if done:
                final_word += ' ' + word
            else:
                found = False
                if "-" in word:
                    sub_word = word.split("-")
                    for word2 in sub_word:
                        format_name = word2.lower().strip()
                        for name_en in en_list:
                            format_name_en = re.sub(' ','',name_en).lower().strip()
                            if format_name == format_name_en:
                                final_word += '\n' + word
                                found = True
                                done = True
                                break
                        if found:
                            break
                    if not found:
                        final_word += ' ' + word
                else:
                    format_name = word.lower().strip()
                    for name_en in en_list:
                        format_name_en = re.sub(' ','',name_en).lower().strip()
                        if format_name == format_name_en:
                            final_word += '\n' + word
                            found = True
                            done = True
                            break
                    if not found:
                        final_word += ' ' + word
        if done:
            data_dict = {"Code" : code, "Name" : name, "Format_Name" : final_word, "Word_Match" : name_en, "Done" : 1}
        else:
            data_dict = {"Code" : code, "Name" : name, "Format_Name" : final_word, "Word_Match" : "", "Done" : 0}
    else:
        data_dict = {"Code" : code}
    data_list.append(data_dict)

data_df = pd.DataFrame(data_list)
data_df.to_csv(file_name, encoding='utf-8')
print("DONE")