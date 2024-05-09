import pandas as pd
import csv

old = pd.read_csv(r"C:\PYTHON\TAR.thelist.web2\scrap\old link.csv")
new = pd.read_csv(r"C:\PYTHON\TAR.thelist.web2\scrap\new_link.csv")

csv_file_path = r"C:\PYTHON\TAR.thelist.web2\scrap\format_link.csv"

old_list = []
for x in range(old.index.size):
    url = old.iloc[x].iloc[0]
    old_list.append(url)

new_list = []
for x in range(new.index.size):
    url = new.iloc[x].iloc[0]
    new_list.append(url)

format_list = []
duplicate = False
for i, new_url in enumerate(new_list):
    for old_url in old_list:
        if new_url == old_url:
            duplicate = True
            break
    else:
        format_list.append(new_url)

with open(csv_file_path, 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Links'])
    for link in format_list:
        writer.writerow([link])

print("done")