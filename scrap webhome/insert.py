import mysql.connector
import pandas as pd
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
import time
from bs4 import BeautifulSoup as bs
from datetime import datetime

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

host = '159.223.76.99'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

agent = 'Web Home'
user_id = 1
sql = False
run = 1  ####
continue_run = False ####
continue_project = False
stop_processing = False
log = False
proj_insert,proj_upd,insert,upd = 0,0,0,0

all_link = pd.read_csv(r"C:\PYTHON\TAR.thelist.web2\scrap webhome\list_condo.csv", encoding='utf-8')

def scrap(use_list, stage, stop_processing,proj_insert,proj_upd,insert,upd,log):
    for count, data in enumerate(use_list):
        if stop_processing:
            break
        browser.execute_script(f"window.open('{data[3]}', '_blank');")
        browser.switch_to.window(browser.window_handles[-1])
        browser.refresh()
        time.sleep(1)
        
        soup = bs(browser.page_source, 'html.parser')
        price_start = soup.find('div', {'class': 'text-price'}).text.strip()
        check_price = re.findall(r'\d+', price_start)
        
        if len(check_price) > 0:
            price_start = int(re.sub('บาท', '', re.sub(',', '', price_start)).strip())
            
            area = soup.find('div', {'class': 'sc-qy3aqj-17 loMhBJ'}).text.strip()
            check_area = re.findall(r'\d+', area)
            if len(check_area) > 0:
                area = re.sub('ตร.ม.','',area).split("-")
                area_min = float(area[0])
                area_max = float(area[-1])
            else:
                area_min = None
                area_max = None
            
            name_section = soup.find('div', {'class': 'sc-qy3aqj-13 hqrLJw w-full'})
            date_update = name_section.find('div', {'class': 'title-update-date'}).text.strip()
            date_update = re.sub('อัพเดตล่าสุด', '', date_update).strip().split("/")
            date_update = date_update[-1] + '-' + date_update[1] + '-' + date_update[0]
            
            if stage == 'update':
                price_other_web_update = (price_start, area_min, area_max, date_update, '1', user_id, 32, data[4]
                                        , 32, update_date, run, str(data[0]), data[1])
                log, stop_processing = edit_condo_price_and_classified(price_other_web_update,'project_update','condo_price_other_web',stop_processing,proj_insert,proj_upd,insert,upd)
                proj_upd += 1
            else:
                price_other_web_insert = (str(data[0]), data[1], price_start, area_min, area_max, date_update, '1', user_id, 32, create_date
                                        , 32, update_date, run)
                log, stop_processing = edit_condo_price_and_classified(price_other_web_insert,'project_insert','condo_price_other_web',stop_processing,proj_insert,proj_upd,insert,upd)
                proj_insert += 1
        
            log, stop_processing, proj_insert, proj_upd, insert, upd = classified_scrap(soup, data[0], stop_processing, log, proj_insert, proj_upd, insert, upd)
        browser.close()
        browser.switch_to.window(browser.window_handles[0])
        #if count + 1 == 10:
        #    break
    return log, stop_processing, proj_insert, proj_upd, insert, upd

def classified_scrap(soup,code,stop_processing,log,proj_insert,proj_upd,insert,upd):
    def scroll_down():
        web_bottom = browser.find_element(By.XPATH, '//div[@class="sc-feUZmu jGbTjU container-fluid inner-footer"]')
        actions = ActionChains(browser)
        actions.move_to_element(web_bottom).perform()
        time.sleep(2)
    
    def new_tab(url):
        browser.execute_script(f"window.open('{url}', '_blank');")
        browser.switch_to.window(browser.window_handles[-1])
        browser.refresh()
        time.sleep(1)
        
    classified_check = soup.find('div', {'class': 'project-unit-market'})
    if classified_check != None:
        classified_all = classified_check.find("a").get("href")
        new_tab(classified_all)
        
        more_classified = False
        while more_classified != True:
            try:
                loading = browser.find_element(By.XPATH, '//div[@class="ant-spin ant-spin-spinning"]')
                if loading:
                    scroll_down()
            except:
                more_classified = True
        
        correct_text = classified_check.find('h2').text.strip()
        if correct_text != 'ประกาศแนะนำ':
            soup_classified = bs(browser.page_source, 'html.parser')
            classified_result = soup_classified.find('div', {'class': 'content-result1 row'})
            for i , classified in enumerate(classified_result.find_all('div', {'class': 'p-0 col-md-6 col-sm-6 col-12'})):
                if stop_processing:
                    break
                classified_link = classified.find('a').get('href')
                classified_link = 'https://market.home.co.th'+ re.sub('\n','',classified_link).strip()
                new_tab(classified_link)
                
                classified_id = classified_link.split("-")[-1].strip()
                soup_classified_in = bs(browser.page_source, 'html.parser')
                classified_data = soup_classified_in.find('div', {'class': 'card-info'})
                
                classified_text = classified_data.find('div', {'class': 'col-price p-0 col'}).text
                price = int(re.sub(',', '', classified_data.find('span', {'class': 'mb-0 title-price'}).text.split(' ')[0]).strip())
                if 'ขาย' in classified_text:
                    sale = 1
                    rent = 0
                    classified_price_sale = price
                    classified_price_rent = None
                else:
                    sale = 0
                    rent = 1
                    classified_price_sale = None
                    classified_price_rent = price
                
                classified_size = soup_classified_in.find('div', {'class': 'card-section1'})
                try:
                    classified_size_value = "{:.1f}".format(float(classified_size.find('p', {'class': 'title-spec'}).text.strip()))
                except:
                    classified_size_value = None
                
                bedroom = soup_classified_in.find('div', {'class': 'card-section2'})
                try:
                    bedroom_value = int(bedroom.find('p', {'class': 'title-spec'}).text.strip())
                except:
                    bedroom_value = None
                
                bathroom = soup_classified_in.find('div', {'class': 'card-section3'})
                try:
                    bathroom_value = int(bathroom.find('p', {'class': 'title-spec'}).text.strip())
                except:
                    bathroom_value = None

                unit_info = soup_classified_in.find('div', {'class': 'unit-info'})
                for a, row in enumerate(unit_info.find_all('div', {'class': 'row'})):
                    if a == 3:
                        try:
                            clasified_date_field = row.find('div', {'class': 'data-style col-4'}).text.strip()
                            classified_date = clasified_date_field.split('-')[-1]+ '-' + clasified_date_field.split('-')[1] + '-' + clasified_date_field.split('-')[0]
                        except:
                            classified_date = None
                
                check = result_update.get((str(code),classified_id))
                if check:
                    classified_create_date = check[3].strftime('%Y-%m-%d %H:%M:%S')
                    classified_other_web_update = (sale, rent, classified_price_sale, classified_price_rent, bedroom_value, bathroom_value, classified_size_value
                                                    , classified_date, '1', 32, classified_create_date, 32, update_date, str(code), classified_id)
                    log, stop_processing = edit_condo_price_and_classified(classified_other_web_update,'classified_update','classified_other_web',stop_processing,proj_insert,proj_upd,insert,upd)
                    upd += 1
                else:
                    classified_other_web_insert = (str(code), classified_id, sale, rent, classified_price_sale, classified_price_rent, bedroom_value
                                                    , bathroom_value, classified_size_value, classified_date, '1', user_id, 32, create_date, 32, update_date)
                    log, stop_processing = edit_condo_price_and_classified(classified_other_web_insert,'classified_insert','classified_other_web',stop_processing,proj_insert,proj_upd,insert,upd)
                    insert += 1
                
                classified_other_web.append((str(code), classified_id, sale, rent, classified_price_sale, classified_price_rent, bedroom_value\
                                            , bathroom_value, classified_size_value, classified_date, '1', 32, create_date, 32, update_date))
                browser.close()
                browser.switch_to.window(browser.window_handles[-1])
        browser.close()
        browser.switch_to.window(browser.window_handles[-1])
    return log, stop_processing, proj_insert, proj_upd, insert, upd

def edit_condo_price_and_classified(use_list,stat,location,stop_processing,proj_insert,proj_upd,insert,upd):
    if stat == 'project_insert':
        query = """insert into condo_price_other_web (Project_ID, Condo_Code, Price_Start, Area_Min, Area_Max, Lastest_Update
                , Project_Status, User_ID, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date, Run_Count)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    elif stat == 'project_update':
        query = """update condo_price_other_web set Price_Start = %s, Area_Min = %s, Area_Max = %s
                , Lastest_Update = %s, Project_Status = %s, User_ID = %s, Created_By = %s, Created_Date = %s, Last_Updated_By = %s
                , Last_Updated_Date = %s , Run_Count = %s where Project_ID = %s and Condo_Code = %s"""
    elif stat == 'classified_insert':
        query = """insert into classified_other_web (Project_ID, Ref_ID, Sale, Rent, Price_Sale, Price_Rent, Bedroom, Bathroom
                , Size, Classified_Date, Classified_Status, User_ID, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    else:
        query = """update classified_other_web set Sale = %s, Rent = %s, Price_Sale = %s
                , Price_Rent = %s, Bedroom = %s, Bathroom = %s, Size = %s, Classified_Date = %s, Classified_Status = %s, Created_By  = %s
                , Created_Date = %s, Last_Updated_By = %s, Last_Updated_Date = %s where Project_ID = %s and Ref_ID = %s"""
    try:
        cursor.execute(query,use_list)
        connection.commit()
        log = True
    except Exception as e:
        stop_processing = True
        print(f'Error: {e} at {stat}_{location}')
        log = False
        insert_log("from home buyer",log,e,proj_insert,proj_upd,insert,upd)
    
    return log, stop_processing

def insert_log(location,log,e,proj_insert,proj_upd,insert,upd):
    if log:
        query_log = """INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES (%s, %s, %s, %s)"""
        val_log = (0, '00000', f'insert {proj_insert} rows and update {proj_upd} rows in condo_price_other_web\n'
                    f'insert {insert} rows and update {upd} rows in classified_other_web', 'from home buyer')
        cursor.execute(query_log,val_log)
        connection.commit()
    else:
        query = """INSERT INTO realist_log (Type, Message, Location)
                VALUES (%s, %s, %s)"""
        val = (1, str(e), f'{location}')
        cursor.execute(query,val)
        connection.commit()

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
        
        match = f"SELECT Project_ID, Condo_Code FROM classified_match WHERE Agent = '{agent}'"
        cursor.execute(match)
        result_match = {row[0]: row for row in cursor.fetchall()}
        
        project_update = f"SELECT Project_ID, Condo_Code, Created_Date, ID FROM condo_price_other_web WHERE User_ID = {user_id} and Project_Status = '1'"
        cursor.execute(project_update)
        result_project_update = {(row[0], row[1]): row for row in cursor.fetchall()}
        
        project_update_continue_run = f"SELECT Project_ID, Condo_Code, Created_Date, ID FROM condo_price_other_web WHERE User_ID = {user_id} and Project_Status = '1' and Run_Count = {run}"
        cursor.execute(project_update_continue_run)
        result_project_update_continue_run = {(row[0], row[1]): row for row in cursor.fetchall()}
        
        update = f"""SELECT a.Classified_ID, a.Project_ID, a.Ref_ID, a.Created_Date
                    FROM classified_other_web a
                    join condo_price_other_web b on a.Project_ID = b.Project_ID
                    where b.User_ID = {user_id} and a.Classified_Status = '1'"""
        cursor.execute(update)
        result_update = {(row[1], row[2]): row for row in cursor.fetchall()}
        
except Exception as e:
    print(f'Error: {e}')

if sql:
    project_list, project_update, project_insert, price_other_web_update, price_other_web_insert = [], [], [], [], []
    classified_other_web, classified_other_web_update, classified_other_web_insert = [], [], []
    
    for i in range(all_link.index.size):
        code = int(all_link.iloc[i, 0])
        update_date = all_link.iloc[i, 1]
        link = all_link.iloc[i, 4]
        
        update_date = re.sub('อัพเดตล่าสุด ','',update_date)
        
        check_match = result_match.get(str(code))
        if check_match:
            condo_code = str(check_match[1])
            project_list.append((code,condo_code,update_date,link))
    
    if len(project_list) > 0:
        f = 0
        if continue_run:
            skip_update = dict(sorted(result_project_update_continue_run.items(), key=lambda x: int(x[1][3]), reverse=True))
            skip_update = dict([list(skip_update.items())[0]])
        
        while f in range(len(project_list)):
            project_id = str(project_list[f][0])
            project_condo_code = project_list[f][1]
            
            if not continue_run:
                check_project = result_project_update.get((project_id, project_condo_code))
            else:
                check_project = skip_update.get((project_id, project_condo_code))
            
            old_record = result_project_update.get((project_id, project_condo_code))
            if check_project:
                update_date = check_project[2].strftime('%Y-%m-%d %H:%M:%S')
                project_update.append(project_list[f]+(update_date,))
                f+=1
                if continue_run:
                    continue_project = True
            elif run > 1 and old_record and continue_project:
                update_date = old_record[2].strftime('%Y-%m-%d %H:%M:%S')
                project_update.append(project_list[f]+(update_date,))
                f+=1
            else:
                if continue_run:
                    if continue_project:
                        project_insert.append(project_list[f])
                        f+=1
                    else:
                        project_list.pop(f)
                else:
                    project_insert.append(project_list[f])
                    f+=1
        
        project_work = [(project_update,'update'), (project_insert,'insert')]
        
        create_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        update_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        browser = webdriver.Chrome()
        browser.maximize_window()
        
        for use_list in project_work:
            if stop_processing:
                break
            log, stop_processing, proj_insert, proj_upd, insert, upd = scrap(use_list[0] ,use_list[1], stop_processing, proj_insert, proj_upd, insert, upd, log)
        browser.close()
    
    if not stop_processing:
        try:
            query_project = """update condo_price_other_web set Project_Status = '2' 
                                WHERE User_ID = %s and Run_Count < %s"""
            cursor.execute(query_project, (user_id, run))
            connection.commit()
            
            query_classified = """update classified_other_web a
                                join condo_price_other_web b on a.Project_ID = b.Project_ID
                                set a.Classified_Status = '2'
                                where b.User_ID = %s and b.Run_Count < %s"""
            cursor.execute(query_classified, (user_id, run))
            connection.commit()
        except Exception as e:
            print(f'Error: {e}')
    
    if log:
        e = ''
        insert_log("from home buyer",log,e,proj_insert,proj_upd,insert,upd)

cursor.close()
connection.close()
print("DONE")