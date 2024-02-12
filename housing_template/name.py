import pandas as pd

list_th = "D:\PYTHON\TAR.thelist.web-2\housing_template\list_th.csv"
csv_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\home.csv"

file_name = "D:\PYTHON\TAR.thelist.web-2\housing_template\work_name1.csv"

def check_null(variable):
    if pd.isna(variable) or variable == '':
        variable = None
    else:
        variable = str(variable).strip()
    return variable

th = pd.read_csv(list_th, encoding='utf-8')
csv = pd.read_csv(csv_path, encoding='utf-8')

th_list = []
for i in range(th.index.size):
    name_th = th.iloc[i][0]
    th_list.append(name_th)

data_list = []
for i in range(csv.index.size):
    link = check_null(csv.iloc[i][1])
    name = check_null(csv.iloc[i][3])
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
                        for name_th in th_list:
                            if word2 == name_th:
                                final_word += '\n' + word
                                found = True
                                done = True
                                break
                        if found:
                            break
                    if not found:
                        final_word += ' ' + word
                else:
                    for name_th in th_list:
                        if word == name_th:
                            final_word += '\n' + word
                            found = True
                            done = True
                            break
                    if not found:
                        final_word += ' ' + word
        if done:
            data_dict = {"Link" : link, "Name" : name, "Format_Name" : final_word, "Done" : 1}
        else:
            data_dict = {"Link" : link, "Name" : name, "Format_Name" : final_word, "Done" : 0}
    else:
        data_dict = {"Link" : link}
    data_list.append(data_dict)

data_df = pd.DataFrame(data_list)
data_df.to_csv(file_name, encoding='utf-8')
print("DONE")