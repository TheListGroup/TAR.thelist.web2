import mysql.connector
import pandas as pd
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    SimpleDocTemplate, Table, TableStyle,
    Paragraph, Spacer
)
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
import html
from babel.dates import format_date
from datetime import date
import os
from dotenv import load_dotenv
import base64
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail, Attachment, FileContent, FileName, FileType, Disposition, Email, To, Content, Personalization
from dateutil.relativedelta import relativedelta
from reportlab.platypus import PageBreak

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

#pdf_folder = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\contact_form\genpdf"
#font_path = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\contact_form\THSarabunNew.ttf"
#font_path_bold = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\contact_form\THSarabunNew Bold.ttf"
#logo_path = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\contact_form\logo.png"

#pdf_folder = r"/home/gitdev/ta_python/contact_form/genpdf"
#font_path = r"/home/gitdev/ta_python/contact_form/THSarabunNew.ttf"
#font_path_bold = r"/home/gitdev/ta_python/contact_form/THSarabunNew Bold.ttf"
#logo_path = r"/home/gitdev/ta_python/contact_form/logo.png"

pdf_folder = r"/home/gitprod/ta_python/contact_form/genpdf"
font_path = r"/home/gitprod/ta_python/contact_form/THSarabunNew.ttf"
font_path_bold = r"/home/gitprod/ta_python/contact_form/THSarabunNew Bold.ttf"
logo_path = r"/home/gitprod/ta_python/contact_form/logo.png"

sql = False
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

def add_page_info(canvas, doc):
    canvas.saveState()

    # ---------- FOOTER with logo ----------
    # Desired logo display size
    logo_h = 5 * mm          # 10 mm tall
    logo_w = 20 * mm

    # Bottom-left coordinates for the logo
    leftx = doc.leftMargin
    rightx = doc.pagesize[0] - doc.rightMargin
    footer_y = 15 * mm

    canvas.drawImage(logo_path, leftx, footer_y, width=logo_w, height=logo_h, preserveAspectRatio=True, mask='auto')

    # ---------- Page number on right ----------
    canvas.setFont("THSarabun", 10)
    canvas.drawRightString(rightx, footer_y,f"หน้า {doc.page}")

    canvas.restoreState()

def make_table(df, title, header_style, body_style, col_widths):
    title_style = ParagraphStyle(
        'Title', fontName='THSarabunBold', fontSize=16, alignment=1, spaceAfter=12
    )
    title_para = Paragraph(title, title_style)

    header = [Paragraph(html.escape(str(c)), header_style) for c in df.columns]
    rows = [
        [Paragraph(html.escape(str(cell)), body_style) for cell in row]
        for row in df.itertuples(index=False)
    ]
    data = [header] + rows

    table = Table(data, repeatRows=1, colWidths=col_widths)
    table.setStyle(TableStyle([
        ('FONTNAME',  (0, 0), (-1, -1), 'THSarabun'),
        ('FONTSIZE',  (0, 0), (-1, -1), 12),
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#003366')),
        ('TEXTCOLOR',  (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN',      (0, 0), (-1, 0), 'CENTER'),
        ('ALIGN',      (0, 1), (-1, -1), 'LEFT'),
        ('VALIGN',     (0, 0), (-1, -1), 'TOP'),
        ('GRID',       (0, 0), (-1, -1), 0.25, colors.grey),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.whitesmoke, colors.lightgrey]),
        ('LEFTPADDING',  (0, 0), (-1, -1), 3),
        ('RIGHTPADDING', (0, 0), (-1, -1), 3),
        ('TOPPADDING',   (0, 0), (-1, -1), 2),
        ('BOTTOMPADDING',(0, 0), (-1, -1), 2),
    ]))

    return [title_para, Spacer(1, 6), table, Spacer(1, 12)]

def generate_html_table(df, table_class="desktop-table"):
    return (
        df.style
        .set_table_attributes(f'class="{table_class}" border="1" cellspacing="0" cellpadding="4"')
        .set_table_styles([
            {'selector': 'th', 'props': [('text-align', 'center')]},
            {'selector': 'td', 'props': [('text-align', 'left')]},
        ])
        .hide(axis="index")
        .to_html()
    )

def generate_mobile_table(df, col_list):
    html_output = "<div class='mobile-table'>"
    for _, row in df.iterrows():
        html_output += "<div class='mobile-row' style='border:1px solid #ccc; margin-bottom:10px; padding:10px;'>"
        for i, (col, val) in enumerate(row.items()):
            html_output += f"<div><strong>{col_list[i]}:</strong> {val}</div>"
        html_output += "</div>"
    html_output += "</div>"
    return html_output

def generate_table_blocks_html(work, lastest_work, sixmonth_work, month_th, topic_text,
                                table_html_lastest, table_html_mobile_lastest,
                                table_html_range, table_html_mobile_range,x,i):
    html = ""
    if work:
        html += f"""
        <p><strong>รายชื่อผู้ลงทะเบียนเดือน{month_th} :</strong></p>
        {table_html_lastest}
        {table_html_mobile_lastest}
        <p style="margin-bottom: 24px;"></p>"""

        if x == 0 and i == 0:
            html += f"""
            <p><strong>{topic_text} :</strong></p>
            {table_html_range}
            {table_html_mobile_range}
            <p style="margin-bottom: 24px;"></p>
            """
    elif lastest_work:
        html += f"""
        <p><strong>รายชื่อผู้ลงทะเบียนเดือน{month_th} :</strong></p>
        {table_html_lastest}
        {table_html_mobile_lastest}
        <p style="margin-bottom: 24px;"></p>"""
        
        if x == 0 and i == 0:
            html += f"""
            <p><strong>{topic_text} : ไม่มีข้อมูล</strong></p>
            <p style="margin-bottom: 24px;"></p>
            """
    elif sixmonth_work:
        html += f"""
        <p><strong>รายชื่อผู้ลงทะเบียนเดือน{month_th} : ไม่มีข้อมูล</strong></p>
        <p style="margin-bottom: 24px;"></p>"""

        if x == 0 and i == 0:
            html += f"""
            <p><strong>{topic_text}:</strong></p>
            {table_html_range}
            {table_html_mobile_range}
            <p style="margin-bottom: 24px;"></p>
            """
    return html


if sql:
    load_dotenv()
    pdfmetrics.registerFont(TTFont('THSarabun', font_path))
    pdfmetrics.registerFont(TTFont('THSarabunBold', font_path_bold))
    
    today = date.today() #date(2025, 8, 1)
    month = today.month
    year = today.year
    condo_template = f"""SELECT DATE(rcf.Contact_Date) AS 'วันที่ลงทะเบียน',
                        rcf.Contact_Name AS 'ชื่อผู้ลงทะเบียน',
                        rcf.Contact_Tel AS 'เบอร์โทรติดต่อ',
                        rcf.Contact_Email AS 'Email',
                        rc.Condo_ENName AS 'ชื่อโครงการ',
                        rcf.Contact_Room_Status AS 'ความสนใจห้อง',
                        IF(el.Contact_Type='Main','โครงการนี้','โครงการข้างเคียง') AS 'ประเภทความสนใจโครงการ',
                        rcf.Contact_Decision_Time AS 'ระยะเวลาตัดสินใจ',
                        DATE(el.Contact_Sent_Date) as Contact_Sent_Date,
                        el.Dev_or_Agent,
                        el.Company_Name,
                        el.Contact_Name,
                        el.Email AS Send_Email
                    FROM real_contact_email_log el
                    INNER JOIN real_condo rc ON el.Condo_Code = rc.Condo_Code
                    INNER JOIN real_contact_form rcf ON el.Contact_ID = rcf.Contact_ID
                    INNER JOIN real_contact_dev_agent rda ON el.Dev_Agent_Contact_ID = rda.Dev_Agent_Contact_ID and el.Company_Name = rda.Company_Name
                    and el.Contact_Name = rda.Contact_Name
                    WHERE el.Contact_Sent = 'Y'
                    AND el.Contact_Sent_Date >= DATE_FORMAT(DATE_SUB('{year}-{month}-01', INTERVAL 7 MONTH), '%Y-%m-01')
                    AND el.Contact_Sent_Date <  DATE_FORMAT('{year}-{month}-01', '%Y-%m-01')
                    AND rcf.Contact_Type = 'contact'
                    ORDER BY rcf.Contact_Date"""
    
    classified = """SELECT DATE(rcf.Contact_Date) as 'วันที่ลงทะเบียน'
                        , rcf.Contact_Name as 'ชื่อผู้ลงทะเบียน'
                        , rcf.Contact_Tel as 'เบอร์โทรติดต่อ'
                        , rcf.Contact_Email as 'Email'
                        , c.Ref_ID as 'ID ของห้อง'
                        , rc.Condo_ENName as 'ชื่อโครงการ'
                        , if(c.Classified_Status='1',rcf.Contact_Link,'-') as Link
                        , DATE(el.Sent_Date) as Contact_Sent_Date
                        , concat(cu.User_Type,' ',ifnull(cu.First_Name, cu.User_Code)) as Contact_Name
                        , cu.Email as Send_Email
                    FROM email_sent_to_log el
                    inner join real_contact_form rcf on el.Contact_ID = rcf.Contact_ID
                    inner join classified c on rcf.Contact_Ref_ID = c.Classified_ID
                    inner join real_condo rc on c.Condo_Code = rc.Condo_Code
                    inner join classified_user cu on c.User_ID = cu.User_ID
                    where el.Type = 'classified'
                    and rcf.Contact_Type = 'classified'
                    and cu.User_Type = 'Agent'
                    and el.Email <> 'realist@thelist.group'"""
    
    query_list = [condo_template, classified]
    for i, query in enumerate(query_list):
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        data = cursor.fetchall()
        df = pd.DataFrame(data, columns=columns)
        df = df.apply(lambda x: x.map(lambda v: v.decode('utf-8') if isinstance(v, bytes) else v))

        if i == 0:
            type_col = df.columns[9]
            dev = df[df[type_col] == 'D'].copy()
            agent = df[df[type_col] == 'A'].copy()
            dev = dev.drop_duplicates()
            agent = agent.drop_duplicates()
            company_col = df.columns[-3]
            date_col = df.columns[-5]
            data_list = [dev, agent]
            dev[date_col] = pd.to_datetime(dev[date_col])
            agent[date_col] = pd.to_datetime(agent[date_col])
            email_col = df.columns[-1]
            unique_emails_dev = dev.drop_duplicates(subset=[email_col, company_col])
            unique_emails_agent = agent.drop_duplicates(subset=[email_col, company_col])
            unique_emails = [unique_emails_dev, unique_emails_agent]
            pdf_type = 'Condo_Contact'
            idx = -5
        else:
            date_col = df.columns[-3]
            company_col = df.columns[-2]
            df = df.drop_duplicates()
            data_list = [df]
            email_col = df.columns[-1]
            unique_emails_classified = df.drop_duplicates(subset=[email_col, company_col])
            unique_emails = [unique_emails_classified]
            pdf_type = 'Classified_Contact'
            idx = -3
        
        df[date_col] = pd.to_datetime(df[date_col])
        latest_month = (today - relativedelta(months=1)).replace(day=1)

        for x, email_list in enumerate(unique_emails):
            if x == 0:
                month_ago = 6
                range_months_count = 1 #2
                lastest_count = 0 #1
                if i == 0:
                    file_text = 'D'
            else:
                month_ago = 3
                range_months_count = 1
                lastest_count = 1
                if i == 0:
                    file_text = 'A'
            
            range_start = latest_month - relativedelta(months=month_ago)
            range_end = latest_month
            
            start_period = pd.Period(range_start, freq='M')
            end_period = pd.Period(range_end, freq='M')
            
            month_latest = format_date(latest_month, "MMMM", locale="th_TH") #เดือนไทย
            month_range_start = format_date(range_start, "MMMM", locale="th_TH") #เดือนไทย
            month_range_end = format_date((range_end - relativedelta(months=1)).replace(day=1), "MMMM", locale="th_TH") #เดือนไทย
            
            year_range_start = range_start.year
            year_range_end = range_end.year
            
            for a, row in email_list.iterrows():
                email = row[email_col]
                email_text = email.split(";")[0]
                company = row[company_col]
                pdf_subfolder = os.path.join(pdf_folder, pdf_type, company.strip())
                if not os.path.exists(pdf_subfolder):
                    os.makedirs(pdf_subfolder)
                pdf_date = f"{file_text}_{today.year}_{today.month}_{today.day}_{email_text}.pdf"
                pdf_path = os.path.join(pdf_subfolder, pdf_date)
                each_mail = data_list[x][(data_list[x][email_col] == email) & (data_list[x][company_col] == company)]
                
                in_latest_month = each_mail[each_mail[date_col].dt.to_period('M') == pd.Period(latest_month, freq='M')]
                range_months = each_mail[(each_mail[date_col].dt.to_period('M') >= start_period) & (each_mail[date_col].dt.to_period('M') < end_period)]
                
                print(f'{email} -- {company}')
            
                if len(in_latest_month) > lastest_count or len(range_months) > range_months_count:
                    send = True
                
                if send:
                    body_style = ParagraphStyle(
                        'body',
                        fontName='THSarabun',
                        fontSize=12,
                        leading=14,          # line‑height; a bit larger than fontSize
                        alignment=0,         # 0 = left align
                        wordWrap='CJK',      # wraps even when there are no spaces (good for Thai)
                    )
                    header_style = ParagraphStyle(
                        'header',
                        parent=body_style,
                        fontName='THSarabun',
                        fontSize=12,
                        leading=14,
                        textColor=colors.whitesmoke,
                        alignment=1,
                    )
                    
                    HEADER_H = 20 * mm
                    FOOTER_H = 15 * mm
                    doc = SimpleDocTemplate(pdf_path, pagesize=landscape(A4), rightMargin=30,leftMargin=30, topMargin=30 ,bottomMargin=30 + FOOTER_H)

                    if i == 0:
                        col_pct = [0.08, 0.13, 0.08, 0.16, 0.22, 0.12, 0.12, 0.09]
                        col_list = ["วันที่", "ชื่อ", "เบอร์โทร", "Email", "โครงการ", "ห้อง", "ความสนใจ", "เวลาตัดสินใจ"]
                        mail_text = "โครงการต่างๆ"
                        subject_text = "โครงการ"
                    elif i == 1:
                        col_pct = [0.09, 0.13, 0.08, 0.16, 0.10, 0.21, 0.23]
                        col_list = ["วันที่", "ชื่อ", "เบอร์โทร", "Email", "ID ห้อง", "โครงการ", "Link"]
                        mail_text = "ประกาศห้องในโครงการต่างๆ"
                        subject_text = "ประกาศห้องโครงการ"
                    col_widths = [doc.width * p for p in col_pct]
                    
                    if year_range_start == year_range_end:
                        topic_text = f"รายชื่อผู้ลงทะเบียนเดือน{month_range_start} - {month_range_end}"
                    else:
                        topic_text = f"รายชื่อผู้ลงทะเบียนเดือน{month_range_start} {year_range_start} - {month_range_end} {year_range_end}"
                    
                    elements = []
                    table_html_lastest = ""
                    table_html_range = ""
                    table_html_mobile_lastest = ""
                    table_html_mobile_range = ""
                    work,lastest_work,sixmonth_work = False,False,False
                    
                    if len(in_latest_month) > 0 and len(range_months) > 0:
                        work = True
                    elif len(in_latest_month) > 0:
                        lastest_work = True
                    elif len(range_months) > 0:
                        sixmonth_work = True
                    
                    if work:
                        data_latest = in_latest_month.iloc[:, :idx]
                        data_range = range_months.iloc[:, :idx]
                        elements += make_table(data_latest, f"รายชื่อผู้ลงทะเบียนเดือน{month_latest}", header_style, body_style, col_widths)
                        elements.append(PageBreak())
                        elements += make_table(data_range, topic_text, header_style, body_style, col_widths)
                        
                        table_html_lastest = generate_html_table(data_latest)
                        table_html_mobile_lastest = generate_mobile_table(data_latest, col_list)
                        if x == 0 and i == 0:
                            table_html_range = generate_html_table(data_range)
                            table_html_mobile_range = generate_mobile_table(data_range, col_list)
                    elif lastest_work:
                        data_latest = in_latest_month.iloc[:, :idx]
                        elements += make_table(data_latest, f"รายชื่อผู้ลงทะเบียนเดือน{month_latest}", header_style, body_style, col_widths)
                        
                        table_html_lastest = generate_html_table(data_latest)
                        table_html_mobile_lastest = generate_mobile_table(data_latest, col_list)
                    elif sixmonth_work:
                        data_range = range_months.iloc[:, :idx]
                        elements += make_table(data_range, topic_text, header_style, body_style, col_widths)
                        
                        table_html_range = generate_html_table(data_range)
                        table_html_mobile_range = generate_mobile_table(data_range, col_list)

                    doc.build(elements, onFirstPage=add_page_info, onLaterPages=add_page_info)
                    #print(f"Created {pdf_path}")
                    
                    mail_to = each_mail.values[0][-2]
                    
                    dynamic_table_html = generate_table_blocks_html(work, lastest_work, sixmonth_work, month_latest, topic_text,
                                            table_html_lastest, table_html_mobile_lastest,
                                            table_html_range, table_html_mobile_range,x,i)
                    
                    # Generate HTML email body
                    email_body = f"""\
                                <!DOCTYPE html>
                                <html lang="th">
                                <head>
                                <meta charset="UTF-8">
                                <style>

                                /* Desktop table visible on large screens */
                                .desktop-table {{
                                    display: table;
                                    width: 100%;
                                }}

                                /* Mobile layout hidden by default */
                                .mobile-table {{
                                    display: none;
                                }}

                                @media only screen and (max-width: 1000px) {{
                                    .desktop-table {{
                                    display: none;
                                    }}
                                    .mobile-table {{
                                    display: block;
                                    }}
                                }}
                                
                                .line {{
                                    line-height: 1.35;
                                }}
                                
                                </style>
                                </head>
                                <body style="margin:0px; padding:10px; font-family: 'TH Sarabun New', sans-serif;">
                                    <div style="padding:20px 0 24px 0;background-color:#2e2e2e;text-align:center;">
                                        <img src="https://thelist.group/realist/assets/images/real-data-logo.png" style="height: 27px;" alt="realdata-logo">
                                    </div>
                                    <p>เรียน {mail_to}</p>

                                    <p>
                                        REAL DATA ขอส่งสรุปข้อมูลผู้ลงทะเบียนแสดงความสนใจ{mail_text} ที่เกิดขึ้นในเดือน{month_latest} ปี {year}
                                        และ {month_ago} เดือนย้อนหลังก่อนหน้านั้น โดยมีข้อมูลดังต่อไปนี้ ทั้งในรูปแบบ email และ ไฟล์ PDF แนบ เพื่อความสะดวกในการปริ้นเอกสาร
                                    </p>

                                    {dynamic_table_html}

                                    <p>ขอบคุณค่ะ<br>ตั้งโอ๋</p>

                                    <p>
                                        <div class="line">Warm regards,<br></div>
                                        <div class="line"><b>ณัฐริกา ชาญเชิดศักดิ์</b><br></div>
                                        <div class="line">Nattarika Chancherdsak<br></div>
                                        <div class="line">Sales Executive<br></div>
                                        <div class="line">M: +6666 153 4445<br></div>
                                        <div class="line">T: +6683 555-1488</div>
                                    </p>

                                    <p>
                                        <div class="line"><b>THE LIST</b><br></div>
                                        <div class="line">
                                            W: <a href="https://thelist.group" target="_blank">thelist.group</a>&nbsp;&nbsp;
                                            YT: <a href="https://www.youtube.com/@thelistgroup" target="_blank">@thelistgroup</a><br>
                                        </div>
                                        <div class="line"><b>REALIST</b><br></div>
                                        <div class="line">
                                            FB: <a href="https://www.facebook.com/realist.co.th" target="_blank">Realist</a>&nbsp;&nbsp;
                                            IG: <a href="https://www.instagram.com/realist.co.th/" target="_blank">realist.co.th</a>&nbsp;&nbsp;
                                            LINE: <a href="https://line.me/R/ti/p/@sok4032q" target="_blank">@realist.co.th</a><br>
                                        </div>
                                        <div class="line"><b>METROPOLIS</b><br></div>
                                        <div class="line">
                                            FB: <a href="https://www.facebook.com/METROPOLIS.TH" target="_blank">The Metropolis</a>&nbsp;&nbsp;
                                            IG: <a href="https://www.instagram.com/metropolis.th/" target="_blank">metropolis.th</a><br>
                                        </div>
                                        <div class="line"><b>LUXURIST</b><br></div>
                                        <div class="line">
                                            FB: <a href="https://www.facebook.com/luxurist.th" target="_blank">Luxurist</a>&nbsp;&nbsp;
                                            IG: <a href="https://www.instagram.com/luxurist.th/" target="_blank">luxurist.th</a><br>
                                        </div>
                                    </p>
                                    <div style="padding:8px;background-color:#2e2e2e;text-align:center;">
                                        <p style="font-size: 14px;font-family: 'TH Sarabun New';font-weight:400;color: #fff;">Contact us</p>
                                        <p style="font-size: 14px;font-family: 'TH Sarabun New';font-weight:400;color: #fff;">realist@thelist.group</p>
                                        <p style="font-size: 14px;font-family: 'TH Sarabun New';font-weight:400;color: #fff;">083-555-1488</p>
                                        <p style="font-size: 14px;font-family: 'TH Sarabun New';font-weight:400;color: #fff;">©2024 by Realist Solution Co., Ltd. All right reserved.</p>
                                    </div>
                                </body>
                                </html>
                                """
                    check_html = os.path.join(pdf_subfolder, f"{file_text}_{today.day}_{today.month}_{today.year}_{email_text}.html")
                    with open(check_html, "w", encoding="utf-8") as f:
                        f.write(email_body)
                    
                    #if i != 1:
                    #emails = 'warintorn.realist@gmail.com;tar5649@gmail.com'
                    #emails = 'samiessm.realist@gmail.com;whitech@gmail.com'
                    emails = email
                    to_email = [e.strip() for e in emails.split(';') if e.strip()]
                    bcc_email = 'warintorn.realist@gmail.com'
                        
                    # Email config
                    message = Mail(
                        from_email=('realdata@thelist.group', 'REAL DATA Team'),
                        to_emails=to_email,
                        subject=f'สรุปยอดคนลงทะเบียนสนใจ{subject_text}ผ่าน REAL DATA',
                        html_content=email_body
                    )
                    
                    # Attach a PDF file
                    with open(pdf_path, 'rb') as f:
                        data = f.read()
                        encoded_file = base64.b64encode(data).decode()

                    attachment = Attachment(
                        FileContent(encoded_file),
                        FileName('contact.pdf'),
                        FileType('application/pdf'),
                        Disposition('attachment')
                    )

                    message.attachment = attachment
                    
                    personalization = Personalization()
                    personalization.add_to(Email(to_email))
                    personalization.add_bcc(Email(bcc_email))
                    message.add_personalization(personalization)
                    
                    # Send the email
                    api_key = os.environ.get("SENDGRID_API_KEY")
                    sg = SendGridAPIClient(api_key)
                    #print("API Key:", os.environ.get('SENDGRID_API_KEY'))
                    response = sg.send(message)
                    print("Send email success")

    cursor.close()
    connection.close()
print("Done")