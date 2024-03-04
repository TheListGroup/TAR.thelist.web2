from PIL import Image
import os

folder_real = "D:\PYTHON\TAR.thelist.web-2\scrap\pic\gall_house_image" 
folder_1920 = "D:\PYTHON\TAR.thelist.web-2\scrap\pic\crop_1920"
size_list = [(1920,1080),(1280,720),(1024,576),(420,236),(240,135)]

x = 1
folders_real = os.listdir(folder_real)
files = os.listdir(folder_1920)
for file_name in files:
    image_path = os.path.join(folder_1920, file_name)
    img = Image.open(image_path)
    
    file_type = file_name[-5:]
    housing_id = file_name[:4]
    
    for folder_name in folders_real:
        if folder_name == housing_id:
            for size in size_list:
                img = img.resize(size)
                new_file_name = f"{housing_id}-PE-01-Exterior-H-{str(size[0])}{file_type}"
                image_path = os.path.join(folder_real, folder_name, new_file_name)
                img.save(image_path)
            break
    
    if x % 800 == 0:
        print(f"IMAGE {x} NAME {file_name} DONE")
    x += 1

print("DONE")