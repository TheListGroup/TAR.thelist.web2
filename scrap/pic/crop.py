from PIL import Image
import os
import re

def crop_and_resize(input_path,output_path1,output_path2,output_path3,target_ratio,target_size,new_file_name):
    img = input_path 
    current_ratio = width / height
    # Calculate the cropping dimensions and coordinates
    if current_ratio > target_ratio:
        # Image is too flat, crop left and right
        #print('FLAT')
        new_width = int(height * target_ratio)
        left_margin = (width - new_width) // 2
        img = img.crop((left_margin, 0, width - left_margin, height))
    elif current_ratio < target_ratio:
        # Image is too tall, crop top and bottom
        #print('TALL')
        new_height = int(width / target_ratio)
        top_margin = (height - new_height) // 2
        img = img.crop((0, top_margin, width, height - top_margin))
    
    img = img.resize(target_size)
    new_file_name = new_file_name + '-' + str(target_size[0]) + file_type
    if target_size == (1920,1080):
        output_path1 = os.path.join(output_path1, new_file_name)
        img.save(output_path1)
    elif target_size == (675,1200):
        output_path2 = os.path.join(output_path2, new_file_name)
        img.save(output_path2)
    else:
        output_path3 = os.path.join(output_path3, new_file_name)
        img.save(output_path3)

folder = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\new 300\cover"
output_folder_1 = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\crop_1920"
output_folder_2 = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\crop_675"
output_folder_3 = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\crop_240"

size_list = [(1920,1080),(675,1200),(240,240)]
ratio_list = [16/9,9/16,1/1]

x = 1
files = os.listdir(folder)
print('WORKING.....')
for file_name in files:
    file_type = file_name[-5:]
    new_file_name = re.sub(file_type,'',file_name).strip()
    #print(f"{new_file_name} -- {file_type}")
    image_path = os.path.join(folder, file_name)
    
    img = Image.open(image_path)
    width, height = img.size
    
    for i, ratio in enumerate(ratio_list):
        crop_and_resize(img,output_folder_1,output_folder_2,output_folder_3,ratio,size_list[i],new_file_name)
    
    if x % 800 == 0:
        print(f"IMAGE {x} NAME {file_name} DONE")
    x += 1

print('DONE ALL')