import pandas as pd

file_path = r"C:\PYTHON\TAR.thelist.web2\Accounting Project\summary.xlsx"
output_path = r"C:\PYTHON\TAR.thelist.web2\Accounting Project\quotations.xlsx"

df = pd.read_excel(file_path)
data_list = df.values[2:].tolist()

def quotation(data):
    if len(data) > 50:
        quotation_type = data[1][0:2]
        project = data[9].strip()
        quotation_id = data[3]
        try:
            cost = int(data[44])
        except:
            cost = 0
        quotation_status = data[40]
        sign_date = data[41]
        start_date = data[46]
        publish_date = data[49]
    else:
        quotation_type = data[0][1][0:2]
        project = data[0][9].strip()
        quotation_id = data[0][3]
        for x, quotation_data in enumerate(data):
            try:
                data[x][44] = int(data[x][44])
            except:
                data[x][44] = 0
        cost = sum(item[44] for item in data)
        quotation_status = data[0][40]
        sign_date = data[0][41]
        start_date = data[0][46]
        publish_date = data[0][49]
    
    if quotation_type == "AN":
        quotation_type = "LQ"
    discount = 0
    vat = (cost + discount)*7/100
    amount = cost + discount + vat
    
    if quotation_status == "Y":
        quotation_status = "signed"
    elif quotation_status == "N":
        quotation_status = "not interest"
    else:
        quotation_status = "wait"
    
    try:
        sign_date = sign_date.strftime('%d/%m/%Y')
    except:
        sign_date = ""
    try:
        start_date = start_date.strftime('%d/%m/%Y')
    except:
        start_date = ""
    try:
        publish_date = publish_date.strftime('%d/%m/%Y')
    except:
        publish_date = ""
    note_text = "หมายเหตุn\n1.ขอยืนยันราคาที่เสนอเป็นเวลา 15 วัน นับจากวันที่เสนอราคา\n2.สามารถหักภาษี ณ ที่จ่าย 3% จากยอดก่อนภาษีมูลค่าเพิ่มได้\n3.บริษัท ฯ จะคิดค่าดำเนินการ 30% จากราคาตามใบเสนอราคา หากมีการเปลี่ยนแปลงใด ๆ จากผู้ว่าจ้าง เช่น การยกเลิกสัญญา การเปลี่ยนแปลงเนื้อหาของงานภายหลังจากที่มีการอนุมัติใบเสนอราคาแล้ว"
    quotation_data_list.append((quotation_id,quotation_type,quotation_no,project,cost,discount,vat,amount,quotation_status,sign_date,note_text))
    quotation_work_date_list.append((quotation_id,start_date,publish_date))

def service_detail(data,list_name,section):
    def service_manage(manage_data,free,section_id):
        for s, services in enumerate(manage_data[24:35]):
            if not pd.isna(services) and services > 0:
                service_id = service_id_list[s]
                if service_id == 86:
                    service_cost = manage_data[44]
                    free_boost,boost_cost,boost_fee = 0,0,0
                    detail_list = (section_id,service_id,service_cost,free_boost,boost_cost,boost_fee,service_cost+free_boost+boost_cost+boost_fee)
                    service_detail_list.append(detail_list)
                    break
                elif service_id == 18:
                    service_cost,free_boost = 0,0
                    boost_cost = services
                    if pd.isna(manage_data[36]):
                        boost_fee = 0
                    else:
                        boost_fee = manage_data[36]
                    detail_list = (section_id,service_id,service_cost,free_boost,boost_cost,boost_fee,service_cost+free_boost+boost_cost+boost_fee)
                    service_detail_list.append(detail_list)
                else:
                    service_cost = services
                    boost_cost,boost_fee = 0,0
                    if not free:
                        free_boost = manage_data[35]
                    else:
                        free_boost = 0
                    free = True
                    detail_list = (section_id,service_id,service_cost,free_boost,boost_cost,boost_fee,service_cost+free_boost+boost_cost+boost_fee)
                    service_detail_list.append(detail_list)
    
    service_detail_list = []
    service_id_list = [86,24,27,6,72,31,52,84,4,18,85]
    if len(data) > 50:
        free = False
        if section == "quotation":
            section_id = data[3]
        elif section == "invoice":
            section_id = data[57]
        else:
            section_id = data[63]
        service_manage(data,free,section_id)
    else:
        sums_by_id = {}
        section_id = data[0][3]
        for data_set in data:
            free = False
            service_manage(data_set,free,section_id)
        for item in service_detail_list:
            id_val = item[1]
            if id_val in sums_by_id:
                sums_by_id[id_val] = (
                    sums_by_id[id_val][0],  
                    id_val,
                    sums_by_id[id_val][2] + item[2],
                    sums_by_id[id_val][3] + item[3],
                    sums_by_id[id_val][4] + item[4],
                    sums_by_id[id_val][5] + item[5],
                    sums_by_id[id_val][6] + item[6])
            else:
                sums_by_id[id_val] = item
        service_detail_list = [sums_by_id[id_val] for id_val in sums_by_id]
    for detail in service_detail_list:
        list_name.append(detail)

def calculate(data,data_date):
    try:
        cost = int(data[44])
    except:
        cost = 0
    try:
        data_date = data_date.strftime('%d/%m/%Y')
    except:
        data_date = ""
    discount = 0
    vat = (cost + discount)*7/100
    amount = cost + discount + vat
    return cost,data_date,discount,vat,amount

def invoice(data):
    quotation_id = data[3]
    #quotation_order = data[2]
    if pd.isna(data[55]):
        invoice_no = ""
    else:
        invoice_no = data[55]
    if pd.isna(data[56]):
        invoice_date = ""
    else:
        invoice_date = data[56]
    if invoice_no != "" or invoice_date != "":
        cost,invoice_date,discount,vat,amount = calculate(data,invoice_date)
        invoice_status = "Invoiced"
        invoice_id = data[57]
        invoice_data_list.append((invoice_id,quotation_id,invoice_no,invoice_date,cost,discount,vat,amount,invoice_status))
        service_detail(data,invoice_service_list,"invoice")

def receipt(data):
    invoice_id = data[57]
    receipt_id = data[63]
    receipt_no = data[61]
    receipt_date = data[62]
    if pd.isna(data[61]):
        receipt_no = ""
    else:
        receipt_no = data[61]
    if pd.isna(data[62]):
        receipt_date = ""
    else:
        receipt_date = data[62]
    if (receipt_no != "" and receipt_date != "") or receipt_date != "":
        cost,receipt_date,discount,vat,amount = calculate(data,receipt_date)
        receipt_status = "received"
        receipt_data_list.append((receipt_id,invoice_id,receipt_no,receipt_date,cost,discount,vat,amount,receipt_status))
        service_detail(data,receipt_service_list,"receipt")

i,invoice_i = 0,0
quotation_data_list,quotation_work_date_list,quotation_service_list,invoice_data_list,invoice_service_list,receipt_data_list,receipt_service_list = [],[],[],[],[],[],[]
quotation_column = ['Quotation_ID', 'Quotation_Type', 'Quotation_NO.', 'Project', 'Cost', 'Discount', 'VAT', 'Amount', 'Status', 'Sign_Date', 'Note_Text']
quotation_work_date_column = ['Quotation_ID', 'Start_Date', 'Publish Date']
quotation_service_column = ['Quotation_ID', 'Service', 'Cost', 'Free', 'Boost', 'Fee', 'Total_Amount']
invoice_column = ['Invoice_ID','Quotation_ID', 'Invoice_NO.', 'Invoice_Date', 'Cost', 'Discount', 'VAT', 'Amount', 'Status']
invoice_service_column = ['Invoice_ID', 'Service', 'Cost', 'Free', 'Boost', 'Fee', 'Total_Amount']
receipt_column = ['Receipt_ID','Invoice_ID','Receipt_No.', 'Receipt_Date.', 'Cost', 'Discount', 'VAT', 'Amount', 'Status']
receipt_service_column = ['Receipt_ID', 'Service', 'Cost', 'Free', 'Boost', 'Fee', 'Total_Amount']
column_list = [quotation_column,quotation_work_date_column,quotation_service_column,invoice_column,invoice_service_column,receipt_column,receipt_service_column]
clean_data_list = [quotation_data_list,quotation_work_date_list,quotation_service_list,invoice_data_list,invoice_service_list,receipt_data_list,receipt_service_list]
sheet_name_list = ['Quotation','Work_Date','Service_Detail','Invoice','Invoice_Service_Detail','Receipt','Receipt_Service_Detail']

while invoice_i < len(data_list):
    invoice(data_list[invoice_i])
    receipt(data_list[invoice_i])
    invoice_i += 1

while i < len(data_list):
    merge_list = []
    do_merge = False
    quotation_no = data_list[i][1].strip()
    j = i+1
    while j < len(data_list):
        quotation_no2 = data_list[j][1].strip()
        if quotation_no == quotation_no2:
            merge_list.append(data_list[j])
            do_merge = True
            data_list.pop(j)
        else:
            j += 1
    if not do_merge:
        quotation(data_list[i])
        service_detail(data_list[i],quotation_service_list,"quotation")
    elif do_merge:
        merge_list.append(data_list[i])
        merge_list.sort(key=lambda x: x[2])
        quotation(merge_list)
        service_detail(merge_list,quotation_service_list,"quotation")
    data_list.pop(i)

with pd.ExcelWriter(output_path, engine='xlsxwriter') as writer:
    for i, data in enumerate(clean_data_list):
        df = pd.DataFrame(data, columns=column_list[i])
        df.to_excel(writer, sheet_name=sheet_name_list[i], index=False)
print("DONE")