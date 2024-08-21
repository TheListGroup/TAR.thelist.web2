import pandas as pd
from datetime import datetime
import os

def check_null(variable):
    if pd.isna(variable):
        variable = ''
    return variable

output_path = r"C:\PYTHON\TAR.thelist.web2\Accounting Project\data.xlsx"

folder_path = r"C:\PYTHON\TAR.thelist.web2\Accounting Project\full_quotations"
data_list = []
files = os.listdir(folder_path)
for file_path in files:
    full_path = os.path.join(folder_path, file_path)
    xls = pd.ExcelFile(full_path)
    sheet_names = xls.sheet_names

    for sheet_name in sheet_names:
        print(sheet_name)
        quotation_number,quotation_date,company_name,company_address,tax_id,phone,email,project,contact_name = "","","","","","","","",""
        df = pd.read_excel(full_path, header=None, sheet_name=sheet_name, dtype=str)
        
        if "เลขที่" in check_null(df.iloc[8,14]):
            quotation_number = check_null(df.iloc[8,15])
            quotation_date = check_null(df.iloc[9,15])
        else:
            quotation_number = check_null(df.iloc[8,14])
            quotation_date = check_null(df.iloc[9,14])
        try:
            date_obj = datetime.strptime(str(quotation_date), "%Y-%m-%d %H:%M:%S")
            quotation_date = date_obj.strftime("%d/%m/%Y")
        except:
            pass
        
        company_name = check_null(df.iloc[8,5])
        
        if pd.isna(df.iloc[10,5]):
            company_address = check_null(df.iloc[9,5])
            tax_id = check_null(df.iloc[10,7])
            if tax_id != '':
                phone = check_null(df.iloc[11,5])
                email = check_null(df.iloc[12,5])
                project = check_null(df.iloc[13,5])
                contact_name = check_null(df.iloc[14,5])
        else:
            tax_id = check_null(df.iloc[11,7])
            if tax_id != '':
                company_address = check_null(df.iloc[9,5]) + ' ' + check_null(df.iloc[10,5])
                phone = check_null(df.iloc[12,5])
                email = check_null(df.iloc[13,5])
                project = check_null(df.iloc[14,5])
                contact_name = check_null(df.iloc[15,5])
            else:
                if 'โทรศัพท์' in check_null(df.iloc[11,1]):
                    company_address = check_null(df.iloc[9,5]) + ' ' + check_null(df.iloc[10,5])
                    phone = check_null(df.iloc[11,5])
                    email = ''
                    project = check_null(df.iloc[12,5])
                    contact_name = check_null(df.iloc[13,5])
                else:
                    company_address = check_null(df.iloc[9,5])
                    phone = check_null(df.iloc[10,5])
                    email = ''
                    project = check_null(df.iloc[11,5])
                    contact_name = check_null(df.iloc[12,5])
        data_list.append((sheet_name,quotation_number,quotation_date,company_name,company_address,tax_id,phone,email,project,contact_name))
    print(f"{file_path} DONE")

data_df = pd.DataFrame(data_list)
with pd.ExcelWriter(output_path, engine='xlsxwriter') as writer:
    data_df.to_excel(writer, sheet_name='Sheet1', index=False)
print('Done')