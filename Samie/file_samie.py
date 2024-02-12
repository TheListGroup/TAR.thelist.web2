import pandas as pd
import os

folder_path = "D:\PYTHON\condo"
csv_file_path = pd.read_csv('file_SM.csv', encoding='iso-8859-1')
# Create a folder for each row in the CSV file
for ind in csv_file_path.index:
    folder_name = csv_file_path.iloc[ind][0]
    folder_pathname = os.path.join(folder_path, folder_name)
    os.makedirs(folder_pathname, exist_ok=True)
    print(f"Created folder: {folder_pathname}")