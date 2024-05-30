import os
from PIL import Image

#def rename_folder_and_files(root_path):
#    # Get a sorted list of directories in the root_path
#    directories = sorted([d for d in os.listdir(root_path) if os.path.isdir(os.path.join(root_path, d))])
#    
#    for directory in directories:
#        old_folder_path = os.path.join(root_path, directory)
#        new_folder_name = f'{int(directory) + 5959:04d}'
#        new_folder_path = os.path.join(root_path, new_folder_name)
#        
#        # Rename the directory
#        os.rename(old_folder_path, new_folder_path)
#        
#        # Get a sorted list of files in the new folder path
##        files = sorted([f for f in os.listdir(new_folder_path) if os.path.isfile(os.path.join(new_folder_path, f))])
#       
#        for file in files:
#            file_parts = file.split('-')
#            if len(file_parts) == 2:
#                file_suffix = file_parts[1]
#                new_file_name = f'{new_folder_name}-{file_suffix}'
#                old_file_path = os.path.join(new_folder_path, file)
#                new_file_path = os.path.join(new_folder_path, new_file_name)
#                
#                # Rename the file
#                os.rename(old_file_path, new_file_path)
#
## Example usage
#root_directory_path = r'C:\PYTHON\TAR.thelist.web2\scrap\pic\new 300\cover'
#rename_folder_and_files(root_directory_path)
#print('done')

directory = r'C:\PYTHON\TAR.thelist.web2\scrap\pic\new 300\cover'

# List all files in the directory
for filename in os.listdir(directory):
    # Construct full file path
    old_file = os.path.join(directory, filename)
    file_parts = filename.split('-')
    file_suffix = file_parts[1]
    new_file_name = f'{int(file_parts[0]) + 5959:04d}-{file_suffix}'
    
    # Define the new file name (for example, prefixing with "new_")
    new_file = os.path.join(directory, new_file_name)
    
    # Rename the file
    os.rename(old_file, new_file)
    
    print(f'Renamed: {old_file} to {new_file}')