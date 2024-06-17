import mysql.connector
import pandas as pd

output_path = r'C:\PYTHON\TAR.thelist.web2\classifield\classified_log.xlsx'

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

sql = False
unique_list = []
save_list = []
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
        sql = True
    
except Exception as e:
    print(f'Error: {e}')
    
query = """select cl.ID, cl.Insert_Day, cl.Classified_ID, cl.Ref_ID, cl.Project_ID, cl.Title_TH, cl.Title_ENG, cl.Condo_Code, cl.Sale, cl.Sale_with_Tenant, cl.Rent, cl.Price_Sale
            , cl.Sale_Transfer_Fee, cl.Sale_Deposit, cl.Sale_Mortgage_Costs, cl.Price_Rent, cl.Min_Rental_Contract, cl.Rent_Deposit, cl.Advance_Payment, cl.Room_Type
            , cl.Unit_Floor_Type, cl.PentHouse, cl.Bedroom, cl.Bathroom, cl.Size, cl.Furnish, cl.Parking, cl.Descriptions_Eng, cl.Descriptions_TH, cu.First_Name
            , cl.Classified_Status, cl.Created_By , cl.Created_Date, cl.Last_Updated_By , cl.Last_Updated_Date
            from classified_all_logs cl 
            join classified_user cu on cl.User_ID = cu.User_ID
            where cl.Classified_Status = '1'"""
cursor.execute(query)
result = cursor.fetchall()

for classified_id in result:
    unique_list.append(classified_id[2])
unique_list = list(set(unique_list))

column_list = ["Ref_ID", "Project_ID", "Title_TH", "Title_ENG", "Condo_Code", "Sale", "Sale_with_Tenant", "Rent", "Price_Sale", "Sale_Transfer_Fee"
            , "Sale_Deposit", "Sale_Mortgage_Costs", "Price_Rent", "Min_Rental_Contract", "Rent_Deposit", "Advance_Payment", "Room_Type", "Unit_Floor_Type", "PentHouse"
            , "Bedroom", "Bathroom", "Size", "Furnish", "Parking", "Descriptions_Eng", "Descriptions_TH", "User_ID", "Classified_Status"]

for each_id in unique_list:
    data_list = []
    for each_row in result:
        if each_row[2] == each_id:
            data_list.append(each_row)
    else:
        for i, data in enumerate(data_list):
            if i > 0:
                base_data = data_list[i-1]
                if data[2:] != base_data[2:]:
                    for j, each_column in enumerate(data[3:31]):
                        if each_column != base_data[j+3]:
                            if data[-1] != base_data[-1]:
                                update = True
                            else:
                                update = False
                            #print(f"ID {str(base_data[0]) + ',' + str(data[0])} -- {data[2]} -- {column_list[j]} Changed AT {data[1].strftime('%Y-%m-%d %H:%M:%S')} -- {update}")
                            data_dict = {"Log_ID": str(base_data[0]) + ' AND ' + str(data[0]), "Classified_ID": data[2], "Column_Name": column_list[j], "Insert_Date": data[1].strftime('%Y-%m-%d %H:%M:%S'), "Update_Date": update, "User": data[29]}
                            save_list.append(data_dict)

data_df = pd.DataFrame(save_list)
data_df.to_excel(output_path, index = False)
cursor.close()
connection.close()
print('Done -- Connection closed')