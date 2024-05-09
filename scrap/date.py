import pandas as pd
import re
file = r'C:\PYTHON\TAR.thelist.web2\scrap\home.csv'
csv_file = r'C:\PYTHON\TAR.thelist.web2\scrap\home_date.csv'

urls = pd.read_csv(file)

data_list = []
month_list = ['มค','กพ','มีค','เมย','พค','มิย','กค','สค','กย','ตค','พย','ธค']
fullmonth_list = ['มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม']

def work(sp_text,index,column_name):
    def findmonth(list_name,a,b):
        for i, each_month in enumerate(list_name):
            if each_month in clean_schedule:
                a = each_month
                b = True
                break
        return a, b, i

    def calyear(year):
        if len(year) == 2:
            year = str(1957 + int(year))
        elif len(year) == 4:
            year = str(int(year) - 543)
        return year

    find_month = False
    month, i = '', 0
    special_text = sp_text
    schedule = urls.iloc[ind].iloc[index]
    if pd.notna(schedule):
        data_dict[column_name + '_ต้นฉบับ'] = schedule
        clean_schedule = re.sub(r'\.','',schedule)
        clean_schedule = re.sub('พศ','',clean_schedule)
        clean_schedule = re.sub('ปี','',clean_schedule)
        clean_schedule = re.sub(' ','',clean_schedule)
        month, find_month, i = findmonth(month_list,month,find_month)
        if find_month != True:
            month, find_month, i = findmonth(fullmonth_list,month,find_month)
            if find_month != True:
                if special_text in clean_schedule:
                    text = special_text
                    data_dict[sp_text] = text
                else:
                    number = re.search(r'\d+', clean_schedule)
                    if number:
                        year = number.group(0)
                        year = calyear(year)
                        data_dict[column_name] = '01/07/' + year
                        data_dict[sp_text] = ''
                        data_dict[column_name + '_Check'] = 0
        if find_month == True:
            number = re.search(f'{month}(\\d+)', clean_schedule)
            month = str(i + 1) 
            if number:
                year = number.group(1)
                year = calyear(year)
                text = '01/' + month + '/' + year
                data_dict[column_name] = text
                data_dict[sp_text] = ''
                data_dict[column_name + '_Check'] = 0
            else:
                article_date = urls.iloc[ind].iloc[57]
                article_year = article_date[-2:]
                text = '01/' + month + '/20' + article_year
                data_dict[column_name] = text
                data_dict[sp_text] = ''
                data_dict[column_name + '_Check'] = 1

ind = 0
while ind in urls.index:
    url = urls.iloc[ind][0]
    data_dict = {'Link' : url}
    work('เปิดลงทะเบียน',42,'กำหนดการ')
    work('สร้างเสร็จพร้อมอยู่',43,'สร้างเสร็จ')
    
    print(f"LINK {ind+1} -- {url}")
    ind += 1
    data_list.append(data_dict)

data_df = pd.DataFrame(data_list)
data_df.to_csv(csv_file, encoding='utf-8')
print("OK")