import os
import re

folder = "D:\PYTHON\TAR.thelist.web-2\scrap\pic\housing_img_crop"

code_list = []
files = os.listdir(folder)

print('WORKING.....')
for file_name in files:
    housing_code = 'HP' + file_name[:4]
    code_list.append(housing_code)

print(len(list(set(code_list))))