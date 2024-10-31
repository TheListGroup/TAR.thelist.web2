import xml.etree.ElementTree as ET
import re
import os
import mysql.connector

district = r'C:\PYTHON\TAR.thelist.web2\realist\boundary\district'
subdistrict = r'C:\PYTHON\TAR.thelist.web2\realist\boundary\subdistrict'

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

def read_kml(file_path):
    def work(coordinates):
        coordinates = coordinates.split(",0") 
        #for i in range(0, len(coordinates), 10):
        #    coor = coordinates[i]
        for coor in coordinates:
            if coor != '':
                format_coor = re.sub("\n","",coor).strip()
                coor_split = format_coor.split(",")
                lat,long = coor_split[1],coor_split[0]
                latlong = lat + ',' + long
                all_coordinates.append(latlong)
        return all_coordinates

    # Namespace dictionary
    ns = {'kml': 'http://www.opengis.net/kml/2.2'}
    
    # Parse the KML file
    tree = ET.parse(file_path)
    root = tree.getroot()

    placemarks_data = []

    # Iterate through each Placemark
    for placemark in root.findall('.//kml:Placemark', ns):
        # Extract ADM2_PCODE from SimpleData within SchemaData
        if 'subdistrict' in file_path:
            adm2_pcode_elem = placemark.find('.//kml:SchemaData/kml:SimpleData[@name="ADM3_PCODE"]', ns)
        else:
            adm2_pcode_elem = placemark.find('.//kml:SchemaData/kml:SimpleData[@name="ADM2_PCODE"]', ns)
        adm2_pcode = re.sub("TH","",adm2_pcode_elem.text).strip() if adm2_pcode_elem is not None else None

        # Check for MultiGeometry
        multi_geometry = placemark.find('.//kml:MultiGeometry', ns)
        if multi_geometry is not None:
            multi_coordinates = []
            # Extract coordinates from each Polygon within MultiGeometry
            for polygon in multi_geometry.findall('.//kml:Polygon', ns):
                coordinates_elem = polygon.find('.//kml:outerBoundaryIs/kml:LinearRing/kml:coordinates', ns)
                if coordinates_elem is not None:
                    all_coordinates = []
                    coordinates = coordinates_elem.text.strip()
                    
                    all_coordinates = work(coordinates)
                    all_coordinates = " ".join(all_coordinates)
                    multi_coordinates.append(all_coordinates)
            all_coordinates = ";".join(multi_coordinates)
        else:
            # Extract coordinates from single Polygon
            coordinates_elem = placemark.find('.//kml:Polygon/kml:outerBoundaryIs/kml:LinearRing/kml:coordinates', ns)
            if coordinates_elem is not None:
                all_coordinates = []
                coordinates = coordinates_elem.text.strip()
        
                all_coordinates = work(coordinates)
                all_coordinates = " ".join(all_coordinates)

        placemarks_data.append((
            adm2_pcode,
            all_coordinates
        ))

    return placemarks_data

def save(folder,table,column1):
    update = 1
    open_json = "["
    close_json = "]"
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        placemarks = read_kml(file_path)
        for placemark in placemarks:
            data_list = []
            code = placemark[0]
            boundary_all = placemark[1]
            boundarys = placemark[1].split(";")
            for boundary in boundarys:
                boundary = '{"Boundary": "' + boundary + '"}'
                data_list.append(boundary)
            data_list = open_json + ", ".join(data_list) + close_json
            query = f"UPDATE {table} SET boundary = %s WHERE {column1} = %s"
            val = (boundary_all, code)
            query2 = f"UPDATE {table} SET boundary_json = %s WHERE {column1} = %s"
            val2 = (data_list, code)
            try:
                cursor.execute(query,val)
                connection.commit()
                cursor.execute(query2,val2)
                connection.commit()
                if update % 500 == 0:
                    print(f"Update {table} {update} Rows")
                update += 1
            except Exception as e:
                print(f'Error: {e}')
                break
    print(f"Total Update {table} {update-1} Rows")

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

if sql:
    save(district,"thailand_district","district_code")
    #save(subdistrict,"thailand_subdistrict","subdistrict_code")

print("Done")