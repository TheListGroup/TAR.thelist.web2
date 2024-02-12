from PIL import Image
import re

folder = '0001'
file = '0001'
file_type = '.webp'
prefix = 'HP'
input_image_path = f"D:\PYTHON\TAR.thelist.web-2\scrap\house_image\{folder}\{file}-011{file_type}"
output_image_path = f"D:\PYTHON\TAR.thelist.web-2\scrap\house_image\{folder}\{prefix}{folder}-01."

img = Image.open(input_image_path)
width, height = img.size
size_list = [(1920,1080),(675,1200),(240,240)]
ratio_list = [16/9,9/16,1/1]

def crop_and_resize(input_path,output_path,target_ratio,target_size):
    img = input_path
    current_ratio = width / height
    # Calculate the cropping dimensions and coordinates
    if current_ratio > target_ratio:
        # Image is too flat, crop left and right
        print('FLAT')
        new_width = int(height * target_ratio)
        left_margin = (width - new_width) // 2
        img = img.crop((left_margin, 0, width - left_margin, height))
    elif current_ratio < target_ratio:
        # Image is too tall, crop top and bottom
        print('TALL')
        new_height = int(width / target_ratio)
        top_margin = (height - new_height) // 2
        img = img.crop((0, top_margin, width, height - top_margin))
    img = img.resize(target_size)
    img.save(output_path + str(i+1) + file_type)

for i, ratio in enumerate(ratio_list):
    crop_and_resize(img,output_image_path,ratio,size_list[i])