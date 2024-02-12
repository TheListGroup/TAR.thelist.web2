import urllib.request
import pandas as pd
import os

urls = pd.read_csv("cover.csv")
for i in urls.index:
    url = urls.iloc[i][3]
    filename = url.split('/')[-1]
    path = "D:\PYTHON\COVER"
    if not os.path.exists(path):
        os.makedirs(path)
    file_path = os.path.join(path, filename)
    urllib.request.urlretrieve(url, file_path)
    i+=1
print('done')