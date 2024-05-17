from PIL import Image
import os

folder = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\new 300\cover"

files = os.listdir(folder)
total = len(files)
x,hori,verti,sq = 0,0,0,0
verti_list = []

print('WORKING.....')
for file_name in files:
    image_path = os.path.join(folder, file_name)
    img = Image.open(image_path)
    width, height = img.size

    if width > height:
        hori += 1
    elif height > width:
        verti += 1
        verti_list.append(file_name)
    else:
        sq += 1
    
    x+=1
    if x % 800 == 0:
        print(f"IMAGE {x} DONE")

print(f"Total is {total}\n- Horizontal {hori}\n- Vertical {verti} -- {verti_list}\n- Square {sq}")