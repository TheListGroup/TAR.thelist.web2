import pandas as pd
import re
import Levenshtein as lev

list_en = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_eng.csv"
csv_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_not_match_eng.csv"

file_name = "D:\PYTHON\TAR.thelist.web-2\housing_template\work_nameEN3.csv"

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
                        best_ratio = 0
                        format_name = word2.lower().strip()
                        for name_en in en_list:
                            format_name_en = re.sub(' ','',name_en).lower().strip()
                            ratio = lev.ratio(format_name, format_name_en)
                            if ratio == 1:
                                final_word += '\n' + word
                                found = True
                                done = True
                                break
                            elif (ratio > best_ratio) and (ratio > 0.9):
                                best_ratio = ratio
                                final_word += '\n' + word
                                found = True
                        if found:
                            break
                    if not found:
                        final_word += ' ' + word