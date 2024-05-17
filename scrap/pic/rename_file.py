import os
from PIL import Image

folder_real = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\house_image" 
folder_675 = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\crop_675"
folder_240 = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\crop_240"
folder = [folder_675,folder_240]

print('WORKING.....')
folders_real = os.listdir(folder_real)
for folder_path in folder:
    x = 1
    files = os.listdir(folder_path)
    pic_size = folder_path[-3:]
    
    if pic_size == '675':
        pic_type = 'V'
    else:
        pic_type = 'S'
        
    for file_name in files:
        image_path = os.path.join(folder_path, file_name)
        img = Image.open(image_path)
        file_type = file_name[-5:]
        housing_id = file_name[:4]
        new_file_name = f"{housing_id}-PE-01-Exterior-{pic_type}-{pic_size}{file_type}"
        
        for folder_name in folders_real:
            if folder_name == housing_id:
                image_path = os.path.join(folder_real, folder_name, new_file_name)
                img.save(image_path)
                break
        
        if x % 800 == 0:
            print(f"IMAGE {x} NAME {file_name} IN {pic_size} DONE")
        x += 1

print("DONE")