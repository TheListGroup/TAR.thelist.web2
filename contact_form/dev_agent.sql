Insert into real_contact_dev_agent (Company_Name,Contact_Name,Dev_or_Agent,Email,Created_By,Last_Updated_By) values 
('Plus Property','คุณหลิว','A','saijai.to@plus.co.th',32,32),
('Serve','คุุณนิก','A','info@serve.co.th',32,32),
('The Agent ','คุณแคท','A','resale@theagent.co.th',32,32),
('Bridge','คุณสุธี จิรธาดานนท์ (ต๋ง)','A','inquiry@bridgethailand.com',32,32),
('Bangkok Citismart','คุณแอนท์','A','info@bkkcitismart.com',32,32);

-- Agent, BC, Bridge
insert into real_contact_condo_send_to_who (Condo_Code,Dev_Agent_Contact_ID ,Created_By ,Last_Updated_By )
SELECT a.Condo_Code
    , b.Dev_Agent_Contact_ID,32,32
FROM all_condo_price_calculate a
cross join real_contact_dev_agent b
where b.Dev_Agent_Contact_ID in (74,75,76);

-- Plus
insert into real_contact_condo_send_to_who (Condo_Code,Dev_Agent_Contact_ID ,Created_By ,Last_Updated_By)
SELECT a.Condo_Code
    , b.Dev_Agent_Contact_ID,32,32
FROM all_condo_price_calculate a
cross join real_contact_dev_agent b
where b.Dev_Agent_Contact_ID = 72
and (a.Condo_Price_Per_Square >= 160000 or a.Condo_Price_Per_Unit >= 3000000);

-- Serve
insert into real_contact_condo_send_to_who (Condo_Code,Dev_Agent_Contact_ID ,Created_By ,Last_Updated_By )
SELECT a.Condo_Code
    , b.Dev_Agent_Contact_ID,32,32
FROM all_condo_price_calculate a
left join (select Condo_Code, Station_Code
            from condo_around_station
            where Station_Code in ('N9','N8','N7','N6','N5','N4','N3','N2','N1','CEN-1','E1','E2','E3','E4','E5','E6','E7')) light_green
on a.Condo_Code = light_green.Condo_Code
left join (select Condo_Code, Station_Code
            from condo_around_station
            where Station_Code in ('W1','CEN-2','S1','S2','S3','S4','S5','S6','S7','S8')) dark_green
on a.Condo_Code = dark_green.Condo_Code
left join (select Condo_Code, Station_Code
            from condo_around_station
            where Station_Code in ('BL16','BL17','BL18','BL19','BL20','BL21','BL22','BL23','BL24','BL25','BL26')) blue
on a.Condo_Code = blue.Condo_Code
cross join real_contact_dev_agent b
where (a.Condo_Price_Per_Square >= 100000 or a.Condo_Price_Per_Unit >= 3000000)
and (light_green.Station_Code is not null or dark_green.Station_Code is not null or blue.Station_Code is not null)
and b.Dev_Agent_Contact_ID = 73
group by a.Condo_Code;


-- developer email
insert into real_contact_condo_send_to_who (Condo_Code,Dev_Agent_Contact_ID,Created_By,Last_Updated_By) values 
('CD0001',43,32,32),
('CD0002',43,32,32),
('CD0003',43,32,32),
('CD0004',43,32,32),
('CD0005',43,32,32),
('CD0007',5,32,32),
('CD0008',66,32,32),
('CD0009',66,32,32),
('CD0010',57,32,32),
('CD0012',51,32,32),
('CD0016',3,32,32),
('CD0019',8,32,32),
('CD0020',31,32,32),
('CD0021',51,32,32),
('CD0023',69,32,32),
('CD0024',69,32,32),
('CD0025',69,32,32),
('CD0026',69,32,32),
('CD0027',39,32,32),
('CD0028',69,32,32),
('CD0032',45,32,32),
('CD0034',19,32,32),
('CD0036',39,32,32),
('CD0039',51,32,32),
('CD0040',69,32,32),
('CD0043',31,32,32),
('CD0055',39,32,32),
('CD0056',31,32,32),
('CD0059',3,32,32),
('CD0064',57,32,32),
('CD0065',45,32,32),
('CD0066',45,32,32),
('CD0067',45,32,32),
('CD0068',45,32,32),
('CD0069',45,32,32),
('CD0070',45,32,32),
('CD0072',31,32,32),
('CD0073',51,32,32),
('CD0074',31,32,32),
('CD0075',15,32,32),
('CD0076',15,32,32),
('CD0078',31,32,32),
('CD0079',51,32,32),
('CD0084',51,32,32),
('CD0085',31,32,32),
('CD0086',41,32,32),
('CD0096',45,32,32),
('CD0097',45,32,32),
('CD0098',45,32,32),
('CD0099',57,32,32),
('CD0100',31,32,32),
('CD0104',57,32,32),
('CD0105',57,32,32),
('CD0106',41,32,32),
('CD0107',43,32,32),
('CD0108',43,32,32),
('CD0109',43,32,32),
('CD0110',45,32,32),
('CD0111',57,32,32),
('CD0113',43,32,32),
('CD0131',39,32,32),
('CD0132',43,32,32),
('CD0135',48,32,32),
('CD0136',31,32,32),
('CD0137',51,32,32),
('CD0140',51,32,32),
('CD0141',51,32,32),
('CD0142',51,32,32),
('CD0145',35,32,32),
('CD0147',20,32,32),
('CD0149',31,32,32),
('CD0151',64,32,32),
('CD0153',48,32,32),
('CD0155',71,32,32),
('CD0156',71,32,32),
('CD0157',71,32,32),
('CD0158',31,32,32),
('CD0161',63,32,32),
('CD0163',6,32,32),
('CD0164',57,32,32),
('CD0165',57,32,32),
('CD0166',57,32,32),
('CD0174',51,32,32),
('CD0177',39,32,32),
('CD0178',17,32,32),
('CD0180',48,32,32),
('CD0181',54,32,32),
('CD0183',3,32,32),
('CD0186',39,32,32),
('CD0187',51,32,32),
('CD0190',51,32,32),
('CD0194',39,32,32),
('CD0197',3,32,32),
('CD0199',40,32,32),
('CD0201',66,32,32),
('CD0203',27,32,32),
('CD0206',20,32,32),
('CD0207',20,32,32),
('CD0212',58,32,32),
('CD0213',57,32,32),
('CD0215',18,32,32),
('CD0217',39,32,32),
('CD0219',51,32,32),
('CD0220',51,32,32),
('CD0227',48,32,32),
('CD0229',39,32,32),
('CD0234',39,32,32),
('CD0235',71,32,32),
('CD0238',41,32,32),
('CD0241',31,32,32),
('CD0242',39,32,32),
('CD0243',6,32,32),
('CD0246',39,32,32),
('CD0250',31,32,32),
('CD0253',61,32,32),
('CD0257',57,32,32),
('CD0260',48,32,32),
('CD0265',6,32,32),
('CD0266',39,32,32),
('CD0269',31,32,32),
('CD0272',48,32,32),
('CD0273',39,32,32),
('CD0276',57,32,32),
('CD0277',31,32,32),
('CD0286',51,32,32),
('CD0287',39,32,32),
('CD0288',39,32,32),
('CD0290',18,32,32),
('CD0291',31,32,32),
('CD0296',41,32,32),
('CD0300',57,32,32),
('CD0302',39,32,32),
('CD0304',39,32,32),
('CD0305',25,32,32),
('CD0307',48,32,32),
('CD0308',48,32,32),
('CD0309',20,32,32),
('CD0310',18,32,32),
('CD0315',39,32,32),
('CD0319',39,32,32),
('CD0320',57,32,32),
('CD0321',51,32,32),
('CD0322',57,32,32),
('CD0324',39,32,32),
('CD0327',31,32,32),
('CD0328',31,32,32),
('CD0330',31,32,32),
('CD0340',39,32,32),
('CD0344',57,32,32),
('CD0351',20,32,32),
('CD0354',48,32,32),
('CD0355',21,32,32),
('CD0356',57,32,32),
('CD0363',6,32,32),
('CD0365',31,32,32),
('CD0383',46,32,32),
('CD0384',7,32,32),
('CD0386',48,32,32),
('CD0387',57,32,32),
('CD0390',57,32,32),
('CD0397',27,32,32),
('CD0398',27,32,32),
('CD0400',39,32,32),
('CD0405',71,32,32),
('CD0407',48,32,32),
('CD0412',16,32,32),
('CD0413',57,32,32),
('CD0415',6,32,32),
('CD0416',6,32,32),
('CD0419',46,32,32),
('CD0421',51,32,32),
('CD0423',48,32,32),
('CD0424',48,32,32),
('CD0425',57,32,32),
('CD0426',48,32,32),
('CD0428',48,32,32),
('CD0435',51,32,32),
('CD0440',20,32,32),
('CD0444',57,32,32),
('CD0445',48,32,32),
('CD0455',62,32,32),
('CD0460',46,32,32),
('CD0461',48,32,32),
('CD0462',48,32,32),
('CD0464',51,32,32),
('CD0467',31,32,32),
('CD0468',31,32,32),
('CD0471',27,32,32),
('CD0475',48,32,32),
('CD0476',48,32,32),
('CD0478',48,32,32),
('CD0479',48,32,32),
('CD0480',48,32,32),
('CD0481',48,32,32),
('CD0482',48,32,32),
('CD0483',6,32,32),
('CD0484',48,32,32),
('CD0485',48,32,32),
('CD0487',4,32,32),
('CD0488',32,32,32),
('CD0494',57,32,32),
('CD0498',48,32,32),
('CD0500',71,32,32),
('CD0503',14,32,32),
('CD0507',51,32,32),
('CD0511',40,32,32),
('CD0512',48,32,32),
('CD0519',31,32,32),
('CD0520',31,32,32),
('CD0521',31,32,32),
('CD0523',7,32,32),
('CD0524',33,32,32),
('CD0525',7,32,32),
('CD0526',48,32,32),
('CD0529',48,32,32),
('CD0530',48,32,32),
('CD0531',57,32,32),
('CD0534',45,32,32),
('CD0537',70,32,32),
('CD0540',39,32,32),
('CD0556',18,32,32),
('CD0557',61,32,32),
('CD0560',48,32,32),
('CD0562',31,32,32),
('CD0563',31,32,32),
('CD0564',31,32,32),
('CD0567',57,32,32),
('CD0568',31,32,32),
('CD0569',31,32,32),
('CD0577',46,32,32),
('CD0578',17,32,32),
('CD0579',40,32,32),
('CD0581',14,32,32),
('CD0582',14,32,32),
('CD0590',43,32,32),
('CD0592',54,32,32),
('CD0597',57,32,32),
('CD0600',43,32,32),
('CD0601',43,32,32),
('CD0602',43,32,32),
('CD0603',43,32,32),
('CD0604',43,32,32),
('CD0605',43,32,32),
('CD0606',43,32,32),
('CD0607',43,32,32),
('CD0608',54,32,32),
('CD0609',6,32,32),
('CD0610',31,32,32),
('CD0611',39,32,32),
('CD0615',58,32,32),
('CD0617',52,32,32),
('CD0620',71,32,32),
('CD0621',48,32,32),
('CD0623',48,32,32),
('CD0625',35,32,32),
('CD0626',31,32,32),
('CD0627',57,32,32),
('CD0633',54,32,32),
('CD0635',31,32,32),
('CD0643',57,32,32),
('CD0645',6,32,32),
('CD0646',39,32,32),
('CD0648',48,32,32),
('CD0652',64,32,32),
('CD0654',6,32,32),
('CD0660',18,32,32),
('CD0664',51,32,32),
('CD0675',71,32,32),
('CD0679',6,32,32),
('CD0680',48,32,32),
('CD0690',17,32,32),
('CD0692',22,32,32),
('CD0696',27,32,32),
('CD0703',40,32,32),
('CD0704',40,32,32),
('CD0707',71,32,32),
('CD0710',35,32,32),
('CD0711',6,32,32),
('CD0712',6,32,32),
('CD0718',17,32,32),
('CD0720',54,32,32),
('CD0722',58,32,32),
('CD0723',58,32,32),
('CD0728',40,32,32),
('CD0732',48,32,32),
('CD0733',48,32,32),
('CD0734',41,32,32),
('CD0735',42,32,32),
('CD0741',57,32,32),
('CD0744',48,32,32),
('CD0745',48,32,32),
('CD0756',48,32,32),
('CD0757',54,32,32),
('CD0760',7,32,32),
('CD0761',48,32,32),
('CD0762',71,32,32),
('CD0763',14,32,32),
('CD0764',14,32,32),
('CD0766',14,32,32),
('CD0772',54,32,32),
('CD0776',48,32,32),
('CD0779',31,32,32),
('CD0780',35,32,32),
('CD0781',35,32,32),
('CD0782',57,32,32),
('CD0785',57,32,32),
('CD0790',40,32,32),
('CD0795',41,32,32),
('CD0796',57,32,32),
('CD0797',35,32,32),
('CD0798',35,32,32),
('CD0800',32,32,32),
('CD0801',41,32,32),
('CD0802',46,32,32),
('CD0806',35,32,32),
('CD0807',33,32,32),
('CD0808',43,32,32),
('CD0812',57,32,32),
('CD0814',58,32,32),
('CD0815',57,32,32),
('CD0816',43,32,32),
('CD0817',43,32,32),
('CD0818',43,32,32),
('CD0819',43,32,32),
('CD0824',54,32,32),
('CD0825',7,32,32),
('CD0827',6,32,32),
('CD0831',35,32,32),
('CD0837',54,32,32),
('CD0839',46,32,32),
('CD0843',55,32,32),
('CD0844',18,32,32),
('CD0845',6,32,32),
('CD0846',44,32,32),
('CD0847',6,32,32),
('CD0850',54,32,32),
('CD0853',35,32,32),
('CD0855',33,32,32),
('CD0858',55,32,32),
('CD0859',6,32,32),
('CD0861',35,32,32),
('CD0874',35,32,32),
('CD0884',31,32,32),
('CD0885',6,32,32),
('CD0886',54,32,32),
('CD0894',17,32,32),
('CD0897',48,32,32),
('CD0899',58,32,32),
('CD0900',48,32,32),
('CD0907',58,32,32),
('CD0919',6,32,32),
('CD0920',6,32,32),
('CD0921',6,32,32),
('CD0922',6,32,32),
('CD0924',32,32,32),
('CD0931',33,32,32),
('CD0933',35,32,32),
('CD0934',32,32,32),
('CD0935',32,32,32),
('CD0939',41,32,32),
('CD0940',32,32,32),
('CD0944',58,32,32),
('CD0947',32,32,32),
('CD0952',32,32,32),
('CD0955',58,32,32),
('CD0957',33,32,32),
('CD0959',58,32,32),
('CD0960',57,32,32),
('CD0961',6,32,32),
('CD0962',57,32,32),
('CD0964',58,32,32),
('CD0970',57,32,32),
('CD0972',51,32,32),
('CD0975',51,32,32),
('CD0980',58,32,32),
('CD0982',23,32,32),
('CD0984',35,32,32),
('CD0992',58,32,32),
('CD0993',57,32,32),
('CD0994',57,32,32),
('CD0997',34,32,32),
('CD1000',48,32,32),
('CD1012',4,32,32),
('CD1015',31,32,32),
('CD1020',48,32,32),
('CD1029',31,32,32),
('CD1045',38,32,32),
('CD1046',43,32,32),
('CD1050',44,32,32),
('CD1054',39,32,32),
('CD1056',35,32,32),
('CD1057',35,32,32),
('CD1061',31,32,32),
('CD1064',32,32,32),
('CD1065',48,32,32),
('CD1067',48,32,32),
('CD1068',48,32,32),
('CD1070',48,32,32),
('CD1071',6,32,32),
('CD1072',6,32,32),
('CD1073',40,32,32),
('CD1075',6,32,32),
('CD1084',48,32,32),
('CD1085',48,32,32),
('CD1086',35,32,32),
('CD1087',48,32,32),
('CD1093',35,32,32),
('CD1094',35,32,32),
('CD1095',17,32,32),
('CD1099',33,32,32),
('CD1102',16,32,32),
('CD1105',43,32,32),
('CD1106',39,32,32),
('CD1107',5,32,32),
('CD1108',27,32,32),
('CD1109',27,32,32),
('CD1111',54,32,32),
('CD1114',55,32,32),
('CD1115',6,32,32),
('CD1117',31,32,32),
('CD1123',71,32,32),
('CD1126',43,32,32),
('CD1127',71,32,32),
('CD1130',6,32,32),
('CD1132',43,32,32),
('CD1133',6,32,32),
('CD1135',5,32,32),
('CD1137',54,32,32),
('CD1138',48,32,32),
('CD1139',48,32,32),
('CD1145',56,32,32),
('CD1147',25,32,32),
('CD1148',43,32,32),
('CD1163',43,32,32),
('CD1165',48,32,32),
('CD1166',43,32,32),
('CD1167',43,32,32),
('CD1168',48,32,32),
('CD1169',43,32,32),
('CD1170',6,32,32),
('CD1171',7,32,32),
('CD1172',18,32,32),
('CD1173',15,32,32),
('CD1177',39,32,32),
('CD1179',7,32,32),
('CD1180',18,32,32),
('CD1181',18,32,32),
('CD1183',18,32,32),
('CD1185',6,32,32),
('CD1189',43,32,32),
('CD1190',17,32,32),
('CD1191',17,32,32),
('CD1193',17,32,32),
('CD1194',17,32,32),
('CD1196',17,32,32),
('CD1197',17,32,32),
('CD1198',17,32,32),
('CD1199',17,32,32),
('CD1202',17,32,32),
('CD1204',17,32,32),
('CD1208',17,32,32),
('CD1209',17,32,32),
('CD1210',17,32,32),
('CD1219',35,32,32),
('CD1220',35,32,32),
('CD1230',71,32,32),
('CD1231',43,32,32),
('CD1233',43,32,32),
('CD1234',43,32,32),
('CD1235',43,32,32),
('CD1237',48,32,32),
('CD1239',48,32,32),
('CD1241',48,32,32),
('CD1242',48,32,32),
('CD1244',48,32,32),
('CD1245',48,32,32),
('CD1246',48,32,32),
('CD1247',48,32,32),
('CD1248',48,32,32),
('CD1249',48,32,32),
('CD1250',48,32,32),
('CD1251',48,32,32),
('CD1252',48,32,32),
('CD1253',48,32,32),
('CD1254',48,32,32),
('CD1255',48,32,32),
('CD1256',48,32,32),
('CD1257',48,32,32),
('CD1258',48,32,32),
('CD1259',48,32,32),
('CD1260',48,32,32),
('CD1263',39,32,32),
('CD1264',3,32,32),
('CD1265',37,32,32),
('CD1268',63,32,32),
('CD1269',27,32,32),
('CD1273',49,32,32),
('CD1274',31,32,32),
('CD1276',31,32,32),
('CD1280',27,32,32),
('CD1281',27,32,32),
('CD1282',27,32,32),
('CD1283',27,32,32),
('CD1286',53,32,32),
('CD1296',15,32,32),
('CD1299',46,32,32),
('CD1300',30,32,32),
('CD1301',54,32,32),
('CD1304',2,32,32),
('CD1307',66,32,32),
('CD1310',68,32,32),
('CD1311',68,32,32),
('CD1313',51,32,32),
('CD1314',46,32,32),
('CD1318',19,32,32),
('CD1320',57,32,32),
('CD1322',20,32,32),
('CD1323',20,32,32),
('CD1324',20,32,32),
('CD1325',20,32,32),
('CD1326',20,32,32),
('CD1330',48,32,32),
('CD1334',58,32,32),
('CD1337',51,32,32),
('CD1338',51,32,32),
('CD1340',57,32,32),
('CD1341',71,32,32),
('CD1342',46,32,32),
('CD1343',46,32,32),
('CD1345',20,32,32),
('CD1347',51,32,32),
('CD1348',22,32,32),
('CD1354',59,32,32),
('CD1355',31,32,32),
('CD1356',57,32,32),
('CD1358',48,32,32),
('CD1360',57,32,32),
('CD1361',20,32,32),
('CD1365',51,32,32),
('CD1366',31,32,32),
('CD1370',31,32,32),
('CD1372',58,32,32),
('CD1373',6,32,32),
('CD1376',31,32,32),
('CD1379',5,32,32),
('CD1381',68,32,32),
('CD1382',68,32,32),
('CD1402',51,32,32),
('CD1403',51,32,32),
('CD1404',58,32,32),
('CD1405',32,32,32),
('CD1406',32,32,32),
('CD1407',32,32,32),
('CD1408',32,32,32),
('CD1409',32,32,32),
('CD1410',32,32,32),
('CD1411',32,32,32),
('CD1412',32,32,32),
('CD1413',32,32,32),
('CD1416',39,32,32),
('CD1417',39,32,32),
('CD1418',39,32,32),
('CD1419',39,32,32),
('CD1420',39,32,32),
('CD1421',39,32,32),
('CD1422',39,32,32),
('CD1423',39,32,32),
('CD1424',39,32,32),
('CD1425',39,32,32),
('CD1427',46,32,32),
('CD1428',46,32,32),
('CD1433',43,32,32),
('CD1434',43,32,32),
('CD1435',43,32,32),
('CD1437',43,32,32),
('CD1438',43,32,32),
('CD1439',43,32,32),
('CD1440',43,32,32),
('CD1441',43,32,32),
('CD1442',43,32,32),
('CD1443',43,32,32),
('CD1444',43,32,32),
('CD1445',43,32,32),
('CD1446',43,32,32),
('CD1447',43,32,32),
('CD1448',43,32,32),
('CD1449',31,32,32),
('CD1450',31,32,32),
('CD1453',22,32,32),
('CD1454',22,32,32),
('CD1455',22,32,32),
('CD1456',22,32,32),
('CD1457',59,32,32),
('CD1458',59,32,32),
('CD1459',59,32,32),
('CD1460',59,32,32),
('CD1461',59,32,32),
('CD1462',59,32,32),
('CD1471',35,32,32),
('CD1472',35,32,32),
('CD1479',58,32,32),
('CD1480',41,32,32),
('CD1481',41,32,32),
('CD1482',41,32,32),
('CD1483',58,32,32),
('CD1484',58,32,32),
('CD1485',58,32,32),
('CD1486',58,32,32),
('CD1487',58,32,32),
('CD1488',58,32,32),
('CD1489',45,32,32),
('CD1493',43,32,32),
('CD1494',43,32,32),
('CD1495',43,32,32),
('CD1496',43,32,32),
('CD1505',47,32,32),
('CD1511',41,32,32),
('CD1514',66,32,32),
('CD1517',6,32,32),
('CD1519',48,32,32),
('CD1527',18,32,32),
('CD1528',20,32,32),
('CD1543',57,32,32),
('CD1544',57,32,32),
('CD1545',57,32,32),
('CD1546',33,32,32),
('CD1547',27,32,32),
('CD1548',31,32,32),
('CD1550',31,32,32),
('CD1551',31,32,32),
('CD1552',31,32,32),
('CD1553',31,32,32),
('CD1555',57,32,32),
('CD1556',57,32,32),
('CD1559',31,32,32),
('CD1560',31,32,32),
('CD1561',57,32,32),
('CD1565',57,32,32),
('CD1572',43,32,32),
('CD1576',43,32,32),
('CD1588',16,32,32),
('CD1589',45,32,32),
('CD1590',45,32,32),
('CD1591',45,32,32),
('CD1593',31,32,32),
('CD1594',27,32,32),
('CD1596',48,32,32),
('CD1597',31,32,32),
('CD1599',48,32,32),
('CD1618',57,32,32),
('CD1623',48,32,32),
('CD1624',31,32,32),
('CD1626',31,32,32),
('CD1630',57,32,32),
('CD1640',31,32,32),
('CD1643',35,32,32),
('CD1646',57,32,32),
('CD1647',43,32,32),
('CD1654',31,32,32),
('CD1655',7,32,32),
('CD1658',31,32,32),
('CD1659',71,32,32),
('CD1663',31,32,32),
('CD1664',57,32,32),
('CD1667',57,32,32),
('CD1679',6,32,32),
('CD1684',43,32,32),
('CD1686',57,32,32),
('CD1687',48,32,32),
('CD1696',16,32,32),
('CD1697',34,32,32),
('CD1712',8,32,32),
('CD1713',20,32,32),
('CD1714',31,32,32),
('CD1715',31,32,32),
('CD1716',31,32,32),
('CD1717',31,32,32),
('CD1722',27,32,32),
('CD1727',31,32,32),
('CD1728',45,32,32),
('CD1729',45,32,32),
('CD1730',45,32,32),
('CD1735',46,32,32),
('CD1736',6,32,32),
('CD1739',6,32,32),
('CD1743',5,32,32),
('CD1745',39,32,32),
('CD1759',48,32,32),
('CD1766',31,32,32),
('CD1769',17,32,32),
('CD1775',43,32,32),
('CD1780',56,32,32),
('CD1782',33,32,32),
('CD1785',57,32,32),
('CD1787',33,32,32),
('CD1788',6,32,32),
('CD1791',51,32,32),
('CD1795',46,32,32),
('CD1802',48,32,32),
('CD1807',18,32,32),
('CD1808',42,32,32),
('CD1816',6,32,32),
('CD1817',6,32,32),
('CD1818',6,32,32),
('CD1821',6,32,32),
('CD1824',31,32,32),
('CD1828',55,32,32),
('CD1842',51,32,32),
('CD1844',7,32,32),
('CD1845',7,32,32),
('CD1846',7,32,32),
('CD1850',22,32,32),
('CD1852',22,32,32),
('CD1853',48,32,32),
('CD1855',23,32,32),
('CD1872',31,32,32),
('CD1873',31,32,32),
('CD1874',31,32,32),
('CD1875',31,32,32),
('CD1876',31,32,32),
('CD1877',31,32,32),
('CD1878',31,32,32),
('CD1879',31,32,32),
('CD1880',31,32,32),
('CD1881',31,32,32),
('CD1882',31,32,32),
('CD1883',31,32,32),
('CD1885',31,32,32),
('CD1886',31,32,32),
('CD1887',31,32,32),
('CD1888',31,32,32),
('CD1889',31,32,32),
('CD1890',31,32,32),
('CD1891',31,32,32),
('CD1892',31,32,32),
('CD1893',31,32,32),
('CD1894',31,32,32),
('CD1895',31,32,32),
('CD1896',31,32,32),
('CD1897',31,32,32),
('CD1898',31,32,32),
('CD1899',31,32,32),
('CD1901',31,32,32),
('CD1902',31,32,32),
('CD1903',31,32,32),
('CD1904',31,32,32),
('CD1905',57,32,32),
('CD1906',31,32,32),
('CD1907',31,32,32),
('CD1908',31,32,32),
('CD1909',31,32,32),
('CD1910',43,32,32),
('CD1911',31,32,32),
('CD1912',31,32,32),
('CD1914',31,32,32),
('CD1917',31,32,32),
('CD1918',31,32,32),
('CD1920',31,32,32),
('CD1921',31,32,32),
('CD1922',31,32,32),
('CD1923',31,32,32),
('CD1924',27,32,32),
('CD1926',31,32,32),
('CD1927',31,32,32),
('CD1928',31,32,32),
('CD1929',31,32,32),
('CD1930',32,32,32),
('CD1931',27,32,32),
('CD1932',22,32,32),
('CD1935',43,32,32),
('CD1936',43,32,32),
('CD1937',43,32,32),
('CD1938',43,32,32),
('CD1939',43,32,32),
('CD1941',6,32,32),
('CD1942',51,32,32),
('CD1943',40,32,32),
('CD1944',51,32,32),
('CD1954',48,32,32),
('CD1955',41,32,32),
('CD1956',41,32,32),
('CD1962',57,32,32),
('CD1975',58,32,32),
('CD1976',58,32,32),
('CD1978',51,32,32),
('CD1979',51,32,32),
('CD1980',51,32,32),
('CD1981',51,32,32),
('CD1982',51,32,32),
('CD1983',43,32,32),
('CD1984',51,32,32),
('CD1993',57,32,32),
('CD1998',48,32,32),
('CD1999',57,32,32),
('CD2002',48,32,32),
('CD2003',48,32,32),
('CD2004',48,32,32),
('CD2005',48,32,32),
('CD2006',48,32,32),
('CD2007',51,32,32),
('CD2008',48,32,32),
('CD2009',6,32,32),
('CD2010',48,32,32),
('CD2011',48,32,32),
('CD2012',48,32,32),
('CD2013',57,32,32),
('CD2014',57,32,32),
('CD2015',57,32,32),
('CD2016',57,32,32),
('CD2017',57,32,32),
('CD2018',57,32,32),
('CD2020',57,32,32),
('CD2021',57,32,32),
('CD2022',57,32,32),
('CD2023',57,32,32),
('CD2024',57,32,32),
('CD2029',35,32,32),
('CD2032',39,32,32),
('CD2033',35,32,32),
('CD2035',39,32,32),
('CD2036',36,32,32),
('CD2037',71,32,32),
('CD2038',71,32,32),
('CD2039',71,32,32),
('CD2042',43,32,32),
('CD2045',48,32,32),
('CD2046',48,32,32),
('CD2050',3,32,32),
('CD2051',39,32,32),
('CD2052',59,32,32),
('CD2053',39,32,32),
('CD2054',51,32,32),
('CD2062',45,32,32),
('CD2065',56,32,32),
('CD2066',17,32,32),
('CD2067',27,32,32),
('CD2068',43,32,32),
('CD2069',33,32,32),
('CD2071',39,32,32),
('CD2076',48,32,32),
('CD2082',6,32,32),
('CD2086',43,32,32),
('CD2087',48,32,32),
('CD2088',48,32,32),
('CD2089',48,32,32),
('CD2091',40,32,32),
('CD2093',57,32,32),
('CD2097',43,32,32),
('CD2102',44,32,32),
('CD2103',16,32,32),
('CD2107',55,32,32),
('CD2110',43,32,32),
('CD2112',4,32,32),
('CD2113',16,32,32),
('CD2114',43,32,32),
('CD2115',28,32,32),
('CD2117',15,32,32),
('CD2124',22,32,32),
('CD2127',27,32,32),
('CD2128',70,32,32),
('CD2134',26,32,32),
('CD2140',57,32,32),
('CD2141',45,32,32),
('CD2142',45,32,32),
('CD2146',3,32,32),
('CD2147',43,32,32),
('CD2150',31,32,32),
('CD2154',70,32,32),
('CD2155',43,32,32),
('CD2156',28,32,32),
('CD2161',43,32,32),
('CD2162',71,32,32),
('CD2163',4,32,32),
('CD2165',71,32,32),
('CD2166',54,32,32),
('CD2169',43,32,32),
('CD2171',52,32,32),
('CD2173',31,32,32),
('CD2175',43,32,32),
('CD2176',43,32,32),
('CD2177',43,32,32),
('CD2178',43,32,32),
('CD2179',43,32,32),
('CD2183',27,32,32),
('CD2184',31,32,32),
('CD2186',57,32,32),
('CD2188',27,32,32),
('CD2189',27,32,32),
('CD2190',27,32,32),
('CD2191',27,32,32),
('CD2192',43,32,32),
('CD2194',27,32,32),
('CD2195',27,32,32),
('CD2196',27,32,32),
('CD2201',71,32,32),
('CD2202',17,32,32),
('CD2203',31,32,32),
('CD2209',45,32,32),
('CD2210',18,32,32),
('CD2215',31,32,32),
('CD2219',31,32,32),
('CD2248',14,32,32),
('CD2260',57,32,32),
('CD2263',17,32,32),
('CD2268',48,32,32),
('CD2269',18,32,32),
('CD2270',47,32,32),
('CD2272',30,32,32),
('CD2274',51,32,32),
('CD2277',35,32,32),
('CD2278',35,32,32),
('CD2282',66,32,32),
('CD2284',27,32,32),
('CD2285',66,32,32),
('CD2286',66,32,32),
('CD2289',68,32,32),
('CD2291',66,32,32),
('CD2292',66,32,32),
('CD2293',66,32,32),
('CD2301',27,32,32),
('CD2312',47,32,32),
('CD2319',35,32,32),
('CD2328',22,32,32),
('CD2339',33,32,32),
('CD2340',45,32,32),
('CD2353',49,32,32),
('CD2354',17,32,32),
('CD2370',17,32,32),
('CD2397',43,32,32),
('CD2438',27,32,32),
('CD2449',45,32,32),
('CD2455',51,32,32),
('CD2465',16,32,32),
('CD2466',39,32,32),
('CD2468',20,32,32),
('CD2473',47,32,32),
('CD2474',35,32,32),
('CD2475',1,32,32),
('CD2478',24,32,32),
('CD2479',41,32,32),
('CD2481',48,32,32),
('CD2482',48,32,32),
('CD2483',48,32,32),
('CD2484',48,32,32),
('CD2485',35,32,32),
('CD2486',35,32,32),
('CD2487',61,32,32),
('CD2489',58,32,32),
('CD2490',43,32,32),
('CD2491',43,32,32),
('CD2492',51,32,32),
('CD2493',44,32,32),
('CD2495',51,32,32),
('CD2496',5,32,32),
('CD2498',66,32,32),
('CD2499',66,32,32),
('CD2500',39,32,32),
('CD2502',64,32,32),
('CD2503',57,32,32),
('CD2506',51,32,32),
('CD2508',35,32,32),
('CD2509',17,32,32),
('CD2510',6,32,32),
('CD2511',47,32,32),
('CD2515',20,32,32),
('CD2516',43,32,32),
('CD2520',29,32,32),
('CD2523',33,32,32),
('CD2526',69,32,32),
('CD2530',6,32,32),
('CD2531',7,32,32),
('CD2532',18,32,32),
('CD2534',37,32,32),
('CD2535',48,32,32),
('CD2536',48,32,32),
('CD2537',7,32,32),
('CD2538',48,32,32),
('CD2541',39,32,32),
('CD2542',22,32,32),
('CD2543',14,32,32),
('CD2546',31,32,32),
('CD2547',45,32,32),
('CD2548',45,32,32),
('CD2550',39,32,32),
('CD2552',35,32,32),
('CD2553',58,32,32),
('CD2554',35,32,32),
('CD2555',48,32,32),
('CD2557',51,32,32),
('CD2558',51,32,32),
('CD2559',57,32,32),
('CD2561',54,32,32),
('CD2563',27,32,32),
('CD2564',27,32,32),
('CD2565',48,32,32),
('CD2566',19,32,32),
('CD2569',48,32,32),
('CD2571',27,32,32),
('CD2573',35,32,32),
('CD2574',35,32,32),
('CD2575',35,32,32),
('CD2576',42,32,32),
('CD2577',65,32,32),
('CD2578',54,32,32),
('CD2579',51,32,32),
('CD2582',39,32,32),
('CD2584',13,32,32),
('CD2585',51,32,32),
('CD2586',51,32,32),
('CD2587',51,32,32),
('CD2588',35,32,32),
('CD2589',57,32,32),
('CD2590',6,32,32),
('CD2591',6,32,32),
('CD2592',6,32,32),
('CD2596',60,32,32),
('CD2597',39,32,32),
('CD2598',39,32,32),
('CD2599',3,32,32),
('CD2602',32,32,32),
('CD2603',45,32,32),
('CD2605',51,32,32),
('CD2607',48,32,32),
('CD2608',48,32,32),
('CD2609',48,32,32),
('CD2611',43,32,32),
('CD2612',51,32,32),
('CD2613',17,32,32),
('CD2614',39,32,32),
('CD2615',51,32,32),
('CD2616',43,32,32),
('CD2617',39,32,32),
('CD2618',39,32,32),
('CD2619',8,32,32),
('CD2620',51,32,32),
('CD2623',67,32,32),
('CD2625',54,32,32),
('CD2626',57,32,32),
('CD2627',21,32,32),
('CD2635',31,32,32),
('CD2638',71,32,32),
('CD2640',57,32,32),
('CD2641',51,32,32),
('CD2642',48,32,32),
('CD2643',39,32,32),
('CD2644',39,32,32),
('CD2645',39,32,32),
('CD2646',39,32,32),
('CD2647',39,32,32),
('CD2648',48,32,32),
('CD2649',39,32,32),
('CD2650',31,32,32),
('CD2651',31,32,32),
('CD2652',32,32,32),
('CD2653',39,32,32),
('CD2656',48,32,32),
('CD2658',35,32,32),
('CD2659',57,32,32),
('CD2661',42,32,32),
('CD2664',57,32,32),
('CD2670',51,32,32),
('CD2671',39,32,32),
('CD2672',51,32,32),
('CD2677',51,32,32),
('CD2678',48,32,32),
('CD2681',66,32,32),
('CD2684',50,32,32),
('CD2686',66,32,32),
('CD2687',66,32,32),
('CD2688',66,32,32),
('CD2689',66,32,32),
('CD2690',66,32,32),
('CD2709',8,32,32),
('CD2710',31,32,32),
('CD2711',39,32,32),
('CD2718',51,32,32),
('CD2723',57,32,32),
('CD2749',32,32,32),
('CD2780',40,32,32),
('CD2786',33,32,32),
('CD2593',39,32,32),
('CD2920',42,32,32),
('CD2921',31,32,32),
('CD2933',39,32,32),
('CD2934',39,32,32),
('CD2935',39,32,32),
('CD2936',39,32,32),
('CD2937',39,32,32),
('CD2938',35,32,32),
('CD2939',52,32,32),
('CD2940',39,32,32),
('CD2944',39,32,32),
('CD2945',39,32,32),
('CD2947',63,32,32),
('CD2948',39,32,32),
('CD2952',68,32,32),
('CD2954',39,32,32),
('CD2955',43,32,32),
('CD2957',22,32,32),
('CD2960',39,32,32),
('CD2961',22,32,32),
('CD2962',51,32,32),
('CD2964',48,32,32),
('CD2965',48,32,32),
('CD2966',48,32,32),
('CD2969',51,32,32),
('CD2970',44,32,32),
('CD2971',39,32,32),
('CD2975',71,32,32),
('CD2979',43,32,32),
('CD2981',43,32,32),
('CD2982',31,32,32),
('CD2984',48,32,32),
('CD2985',58,32,32),
('CD2986',58,32,32),
('CD2987',48,32,32),
('CD2989',34,32,32),
('CD2991',51,32,32),
('CD2992',48,32,32),
('CD2994',57,32,32),
('CD2998',48,32,32),
('CD2999',48,32,32),
('CD3000',31,32,32),
('CD3003',48,32,32),
('CD3005',44,32,32),
('CD3007',39,32,32),
('CD3009',39,32,32),
('CD3012',39,32,32),
('CD3017',27,32,32),
('CD3025',48,32,32),
('CD3027',43,32,32),
('CD3031',48,32,32),
('CD3028',17,32,32),
('CD3030',51,32,32),
('CD3032',51,32,32),
('CD3035',49,32,32),
('CD3038',51,32,32),
('CD3039',51,32,32),
('CD3040',51,32,32),
('CD3041',63,32,32),
('CD3042',33,32,32),
('CD3043',39,32,32),
('CD3045',51,32,32),
('CD3047',39,32,32),
('CD3048',57,32,32),
('CD3049',31,32,32),
('CD3051',29,32,32),
('CD3054',66,32,32),
('CD3055',48,32,32),
('CD2488',9,32,32),
('CD2950',9,32,32),
('CD2545',9,32,32),
('CD3122',9,32,32),
('CD2572',9,32,32),
('CD2075',9,32,32),
('CD2477',9,32,32),
('CD3052',9,32,32),
('CD2943',9,32,32),
('CD1136',10,32,32),
('CD0184',10,32,32),
('CD2567',10,32,32),
('CD2568',10,32,32),
('CD2958',10,32,32),
('CD2953',10,32,32),
('CD3104',10,32,32),
('CD2540',11,32,32),
('CD2942',11,32,32),
('CD3061',11,32,32),
('CD2519',11,32,32),
('CD2988',11,32,32),
('CD2680',11,32,32),
('CD3126',11,32,32),
('CD2581',11,32,32),
('CD2924',12,32,32),
('CD2956',12,32,32),
('CD2544',12,32,32),
('CD1278',12,32,32),
('CD3016',12,32,32),
('CD3072',12,32,32);


-- developer email รอบเพิ่มเติม
insert into real_contact_condo_send_to_who (Condo_Code,Dev_Agent_Contact_ID,Created_By,Last_Updated_By) values 
('CD0341',78,32,32),
('CD0364',78,32,32),
('CD0403',78,32,32),
('CD0522',78,32,32),
('CD0595',78,32,32),
('CD0689',78,32,32),
('CD0811',78,32,32),
('CD0813',78,32,32),
('CD0848',78,32,32),
('CD0869',78,32,32),
('CD0870',78,32,32),
('CD0871',78,32,32),
('CD0887',78,32,32),
('CD0893',78,32,32),
('CD0943',78,32,32),
('CD0974',78,32,32),
('CD0976',78,32,32),
('CD0991',78,32,32),
('CD0999',78,32,32),
('CD1048',78,32,32),
('CD1074',78,32,32),
('CD1076',78,32,32),
('CD1098',78,32,32),
('CD1101',78,32,32),
('CD1122',44,32,32),
('CD1158',58,32,32),
('CD1232',43,32,32),
('CD1262',80,32,32),
('CD1266',81,32,32),
('CD1329',78,32,32),
('CD1333',64,32,32),
('CD1374',80,32,32),
('CD1503',48,32,32),
('CD1504',80,32,32),
('CD1531',78,32,32),
('CD1541',77,32,32),
('CD1574',78,32,32),
('CD1665',78,32,32),
('CD1670',78,32,32),
('CD1693',80,32,32),
('CD1694',80,32,32),
('CD1771',80,32,32),
('CD1776',78,32,32),
('CD1860',78,32,32),
('CD1861',78,32,32),
('CD1862',78,32,32),
('CD1863',78,32,32),
('CD1864',78,32,32),
('CD1865',78,32,32),
('CD1866',78,32,32),
('CD1867',78,32,32),
('CD1868',78,32,32),
('CD1869',78,32,32),
('CD1870',78,32,32),
('CD1871',78,32,32),
('CD1900',6,32,32),
('CD1985',80,32,32),
('CD1986',80,32,32),
('CD1997',80,32,32),
('CD2040',78,32,32),
('CD2078',78,32,32),
('CD2145',31,32,32),
('CD2205',78,32,32),
('CD2220',79,32,32),
('CD2428',78,32,32),
('CD2444',48,32,32),
('CD2459',22,32,32),
('CD2562',48,32,32),
('CD2606',39,32,32),
('CD2660',48,32,32),
('CD2682',39,32,32),
('CD2741',35,32,32),
('CD2768',48,32,32),
('CD2926',39,32,32),
('CD2963',48,32,32),
('CD2976',43,32,32),
('CD2977',43,32,32),
('CD3002',48,32,32),
('CD3015',78,32,32),
('CD3060',48,32,32),
('CD3062',32,32,32),
('CD3065',48,32,32),
('CD3066',17,32,32),
('CD3068',6,32,32),
('CD3070',32,32,32),
('CD3071',32,32,32),
('CD3076',63,32,32),
('CD3077',39,32,32),
('CD3078',48,32,32),
('CD3080',48,32,32),
('CD3083',18,32,32),
('CD3087',39,32,32),
('CD3088',39,32,32),
('CD3089',48,32,32),
('CD3091',51,32,32),
('CD3094',58,32,32),
('CD3103',48,32,32),
('CD3105',39,32,32),
('CD3107',39,32,32),
('CD3108',39,32,32),
('CD3109',39,32,32),
('CD3110',39,32,32),
('CD3111',39,32,32),
('CD3112',39,32,32),
('CD3113',43,32,32),
('CD3114',48,32,32),
('CD3115',3,32,32),
('CD3116',48,32,32),
('CD3117',35,32,32),
('CD3123',57,32,32),
('CD3124',41,32,32),
('CD3125',41,32,32),
('CD3128',32,32,32),
('CD3129',48,32,32),
('CD3130',58,32,32),
('CD3131',48,32,32),
('CD3133',15,32,32),
('CD3135',48,32,32),
('CD3136',39,32,32),
('CD3137',48,32,32),
('CD3138',35,32,32),
('CD3139',32,32,32),
('CD3140',48,32,32),
('CD3144',48,32,32),
('CD3145',57,32,32),
('CD3146',48,32,32),
('CD3152',48,32,32),
('CD3156',58,32,32),
('CD3157',58,32,32),
('CD3158',58,32,32),
('CD3160',57,32,32);


-- ap
insert into real_contact_condo_send_to_who (Condo_Code,Dev_Agent_Contact_ID,Created_By,Last_Updated_By) values 
('CD0270',83,32,32),
('CD0280',83,32,32),
('CD0311',83,32,32),
('CD0371',83,32,32),
('CD0457',83,32,32),
('CD0565',83,32,32),
('CD0674',83,32,32),
('CD0730',83,32,32),
('CD0767',83,32,32),
('CD0810',83,32,32),
('CD0906',83,32,32),
('CD0918',83,32,32),
('CD0945',83,32,32),
('CD1010',83,32,32),
('CD1051',83,32,32),
('CD1052',83,32,32),
('CD1053',83,32,32),
('CD1079',83,32,32),
('CD1080',83,32,32),
('CD1096',83,32,32),
('CD1317',83,32,32),
('CD1321',83,32,32),
('CD1335',83,32,32),
('CD1369',83,32,32),
('CD1383',83,32,32),
('CD1384',83,32,32),
('CD1385',83,32,32),
('CD1386',83,32,32),
('CD1388',83,32,32),
('CD1392',83,32,32),
('CD1393',83,32,32),
('CD1394',83,32,32),
('CD1395',83,32,32),
('CD1396',83,32,32),
('CD1506',83,32,32),
('CD1507',83,32,32),
('CD1602',83,32,32),
('CD1645',83,32,32),
('CD1657',83,32,32),
('CD1671',83,32,32),
('CD1678',83,32,32),
('CD1789',83,32,32),
('CD1790',83,32,32),
('CD1820',83,32,32),
('CD1826',83,32,32),
('CD1827',83,32,32),
('CD1829',83,32,32),
('CD1831',83,32,32),
('CD2167',83,32,32),
('CD2168',83,32,32),
('CD2180',83,32,32),
('CD2283',83,32,32),
('CD2398',83,32,32),
('CD2476',83,32,32),
('CD2583',83,32,32),
('CD2595',83,32,32),
('CD2633',83,32,32),
('CD2919',83,32,32),
('CD2972',83,32,32),
('CD2973',83,32,32),
('CD2995',83,32,32),
('CD2996',83,32,32),
('CD3086',83,32,32),
('CD3096',83,32,32),
('CD3119',83,32,32),
('CD3120',83,32,32),
('CD3147',83,32,32);