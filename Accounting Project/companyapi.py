from requests import Session
import zeep
from zeep import Client
from zeep.transports import Transport

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

session = Session()
session.verify = False
transport = Transport(session=session)

client = Client('https://rdws.rd.go.th/serviceRD3/vatserviceRD3.asmx?wsdl',
                transport=transport)
result = client.service.Service(
    username='anonymous',
    password='anonymous',
    TIN='0105542021041',
    ProvinceCode=0,
    BranchNumber=0,
    AmphurCode=9
)
# Convert Zeep Response object (in this case Service) to Python dict.
result = zeep.helpers.serialize_object(result)
# print(result)
for k in result.keys():
    # print(k, result[k])
    if result[k] is not None:
        v = result[k].get('anyType', None)[0]
        print(k, v)