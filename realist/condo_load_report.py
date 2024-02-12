import pandas as pd

link = pd.read_csv("realist_link.csv")
check = pd.read_csv("check_load.csv")

link.insert(3,'run',check['run'])
link.insert(4,'load',check['load'])
link.to_csv('condo_load.csv')