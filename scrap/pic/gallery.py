import os
from PIL import Image

x = 0
starting_directory = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\house_image"
for root, dirs, files in os.walk(starting_directory): #folder
    for file in files: #file
        filepath = os.path.join(root, file)
        img = Image.open(filepath)
        width, height = img.size
        ratio = width / height
        new_width = ratio * 300
        img = img.resize((round(new_width), 300))
        file_name = file[:7] + '-300' + file[-5:]
        filepath = os.path.join(root, file_name)
        img.save(filepath)
    
    if x % 800 == 0:
        print(f"IMAGE {x} NAME {root} DONE")
    x += 1

print("DONE")