import os
import re

folder = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\new 300\cover"

code_list = []
files = os.listdir(folder)

print('WORKING.....')
for file_name in files:
    housing_code = 'HP' + file_name[:4]
    code_list.append(housing_code)

print(list(set(code_list)))