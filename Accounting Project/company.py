import pandas as pd
import gspread
from oauth2client.service_account import ServiceAccountCredentials

json_file = r"C:\PYTHON\TAR.thelist.web2\Accounting Project\access.json"
output_path = r"C:\PYTHON\TAR.thelist.web2\Accounting Project\clean company.xlsx"

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
client = gspread.authorize(creds)
spreadsheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1owBpvhTfupZ8KgRtKqbzlMFG2eBgXQbFxbgMEBt3HR4')
print('Connect to GoogleSheet')

data_list = []
sheet = spreadsheet.get_worksheet(0)
data = sheet.get_all_values()
for row in data[1:]:
    sheet_name = row[0]
    tax_id = row[6]
    company_name = row[3]
    branch = row[4]
    if tax_id:
        data_list.append((sheet_name,tax_id,company_name,branch))

perfect_list = []
check_list = []
i = 0
while i < len(data_list):
    perfect,check = False,False
    tax_id1 = data_list[i][1]
    j = i + 1 
    while j < len(data_list):
        tax_id2 = data_list[j][1]
        if tax_id1 == tax_id2:
            if data_list[i][1:] == data_list[j][1:]:
                #print(f"{data_list[i]} ----- {data_list[j]}")
                perfect_list.append(data_list[j])
                perfect = True
            else:
                #print(f"{data_list[i]} ----- {data_list[j]}")
                check_list.append(data_list[j])
                check = True
            data_list.pop(j)
        else:
            j += 1
    if perfect:
        perfect_list.append(data_list[i])
    if check:
        check_list.append(data_list[i])
    data_list.pop(i)

df_perfect = pd.DataFrame(perfect_list, columns=['Sheet Name', 'Tax ID', 'Company Name', 'Branch'])
df_check = pd.DataFrame(check_list, columns=['Sheet Name', 'Tax ID', 'Company Name', 'Branch'])

with pd.ExcelWriter(output_path) as writer:
    df_perfect.to_excel(writer, sheet_name='Perfect List', index=False)
    df_check.to_excel(writer, sheet_name='Check List', index=False)

print("DONE")