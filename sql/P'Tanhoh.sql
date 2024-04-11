SELECT Contact_Type, Contact_Ref_ID, Contact_Name, Contact_Tel, Contact_Email, Contact_Link, Contact_Date FROM `real_contact_form`
where Contact_Link like 'https://thelist.group/realist/condo/proj%'
and Contact_Name not in ('Tar','tar','white test ถ้าได้บอกหน่อย','ต้าเอง','Srisamarn','ต้าเองรอบสอง','test','ซามี่เองค่ะ','ต้าลองครั้งที่2','ต้าลองครั้งที่ 3','ต้าลองครั้งที่ 4','pika','Beam Test','ton junjue','ซามี่','ซามี่ 3','ทดสอบ')


SELECT Contact_Type, Contact_Ref_ID, Contact_Name, Contact_Tel, Contact_Email, Contact_Link, Contact_Date
FROM `real_contact_form` 
WHERE Contact_Type LIKE 'classified' 
and Contact_Name not in ('Tar','tar','white test ถ้าได้บอกหน่อย','ต้าเอง','Srisamarn','ต้าเองรอบสอง','test','ซามี่เองค่ะ','ต้าลองครั้งที่2','ต้าลองครั้งที่ 3','ต้าลองครั้งที่ 4','pika','Beam Test','ton junjue','ซามี่','ซามี่ 3','ทดสอบ');