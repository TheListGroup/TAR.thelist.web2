#!/bin/bash

echo "BC Call Project_API"
python3 /home/gitprod/ta_python/classifield/BC/BC_getAPI_proj.py
echo "BC Call Property_API"
python3 /home/gitprod/ta_python/classifield/BC/BC_getAPI_prop.py
echo "BC Start Match Project"
python3 /home/gitprod/ta_python/classifield/BC/BC_match.py
echo "BC Start Insert Property"
python3 /home/gitprod/ta_python/classifield/BC/BC_insert_prop.py

echo "BC Finished"

echo "AG Call Project_API"
python3 /home/gitprod/ta_python/classifield/AG/AG_getAPI_proj.py
echo "AG Call Property_API"
python3 /home/gitprod/ta_python/classifield/AG/AG_getAPI_prop.py
echo "AG Start Match Project"
python3 /home/gitprod/ta_python/classifield/AG/AG_match.py
echo "AG Start Insert Property"
python3 /home/gitprod/ta_python/classifield/AG/AG_insert_prop.py

echo "AG Finished"
