import pandas as pd
import mysql.connector

file_name = "D:\PYTHON\TAR.thelist.web-2\housing_template\work_nameEN1.csv"

host = '157.230.242.204'
user = 'real-research2'
password = 'Y2qhLqIV9Vwqg]U@'

def check_null(variable):
    if pd.isna(variable) or variable == '':
        variable = None
    else:
        variable = str(variable).strip()
    return variable

try:
    connection = mysql.connector.connect(
        host = host,
        user = user,
        password = password,
        database = 'realist2'
    )
    if connection.is_connected():
        print('Connected to MySQL server')
        cursor = connection.cursor()
        query = "select Housing_Code, Housing_Name, Housing_ENName from housing where Housing_Status = '1'"
        cursor.execute(query)
        result = cursor.fetchall()
    
except Exception as e:
    print(f'Error: {e}')

data_list = []
for each_house in result:
    code = each_house[0]
    th_name = check_null(each_house[1])
    en_name = check_null(each_house[2])
    
    if th_name != None and en_name != None:
        th_split = th_name.split(" ")
        en_split = en_name.split(" ")
        
        final_word = en_name
        if len(th_split) + 1 == len(en_split):
            final_word = en_split[0]
            for i, th_part in enumerate(th_split):
                if '\n' in th_part:
                    final_word += '\n' + en_split[i+1]
                else:
                    final_word += ' ' + en_split[i+1]
            data_dict = {'Code':code,'Name_TH':th_name,'Name_EN':en_name,'Format_Name':final_word,'Done':1}
        else:
            data_dict = {'Code':code,'Name_TH':th_name,'Name_EN':en_name,'Format_Name':'','Done':0}
    else:
        data_dict = {'Code':code,'Name_TH':th_name,'Name_EN':en_name}
    data_list.append(data_dict)

#count_of_ones = sum(1 for d in data_list if 'Done' in d and d['Done'] == 1)
#print(count_of_ones)

data_df = pd.DataFrame(data_list)
data_df.to_csv(file_name, encoding='utf-8')
print("DONE")