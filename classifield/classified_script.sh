#!/bin/bash

echo "BC Call Project_API"
python3 /home/gitdev/ta_python/classifield/BC/BC_getAPI_proj.py
echo "BC Call Property_API"
python3 /home/gitdev/ta_python/classifield/BC/BC_getAPI_prop.py
echo "BC Start Match Project"
python3 /home/gitdev/ta_python/classifield/BC/BC_match.py
echo "BC Start Insert Property"
python3 /home/gitdev/ta_python/classifield/BC/BC_insert_prop.py
echo "BC Finished"

echo "AG Call Project_API"
python3 /home/gitdev/ta_python/classifield/AG/AG_getAPI_proj.py
echo "AG Call Property_API"
python3 /home/gitdev/ta_python/classifield/AG/AG_getAPI_prop.py
echo "AG Start Match Project"
python3 /home/gitdev/ta_python/classifield/AG/AG_match.py
echo "AG Start Insert Property"
python3 /home/gitdev/ta_python/classifield/AG/AG_insert_prop.py
echo "AG Finished"

echo "Plus Call Project_API"
python3 /home/gitdev/ta_python/classifield/Plus/Plus_getAPI_proj.py
echo "Plus Call Property_API"
python3 /home/gitdev/ta_python/classifield/Plus/Plus_getAPI_prop.py
echo "Plus Start Match Project"
python3 /home/gitdev/ta_python/classifield/Plus/Plus_match.py
echo "Plus Start Insert Property"
python3 /home/gitdev/ta_python/classifield/Plus/Plus_insert_prop.py
echo "Plus Finished"

echo "Serve Classified"
python3 /home/gitdev/ta_python/classifield/Serve/Serve_Classified.py
echo "Serve Finished"

echo "Bridge Classified"
python3 /home/gitdev/ta_python/classifield/Bridge/Bridge_Classified.py
echo "Bridge Finished"

echo "HHR Classified"
python3 /home/gitdev/ta_python/classifield/HHR/Hhr_Classified.py
echo "HHR Finished"

echo "ERA Classified"
python3 /home/gitdev/ta_python/classifield/ERA/ERA_Classified.py
echo "ERA Finished"
