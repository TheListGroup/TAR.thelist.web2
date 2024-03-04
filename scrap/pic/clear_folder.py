import os

def remove_empty_folders(root_folder):
    # Traverse through all directories and subdirectories
    for folder_name, _, _ in os.walk(root_folder, topdown=False):
        if not os.listdir(folder_name):  # Check if directory is empty
            os.rmdir(folder_name)

# Example usage
root_folder = "D:\PYTHON\TAR.thelist.web-2\scrap\pic\gall_house_image"
remove_empty_folders(root_folder)
print('DONE')