-- create HP9001 panalee, HP0059 VINCES

update ads_base
set Prop_Code = 'HP0182'
where Prop_Code = 'HP0001';

update property_type_relationship set Prop_Code = 'HP0182' where Prop_Code = 'HP0001';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0001')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0001'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0001'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0001')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0001')
where Housing_Code = 'HP0182';

update ads_base
set Prop_Code = 'HP3499'
where Prop_Code = 'HP0002';

update property_type_relationship set Prop_Code = 'HP3499' where Prop_Code = 'HP0002';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0002')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0002'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0002'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0002')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0002')
where Housing_Code = 'HP3499';

update ads_base
set Prop_Code = 'HP1700'
where Prop_Code = 'HP0003';

update property_type_relationship set Prop_Code = 'HP1700' where Prop_Code = 'HP0003';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0003')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0003'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0003'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0003')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0003')
where Housing_Code = 'HP1700';

update ads_base
set Prop_Code = 'HP0373'
where Prop_Code = 'HP0004';

update property_type_relationship set Prop_Code = 'HP0373' where Prop_Code = 'HP0004';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0004')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0004'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0004'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0004')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0004')
where Housing_Code = 'HP0373';

update ads_base
set Prop_Code = 'HP1055'
where Prop_Code = 'HP0005';

update property_type_relationship set Prop_Code = 'HP1055' where Prop_Code = 'HP0005';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0005')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0005'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0005'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0005')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0005')
where Housing_Code = 'HP1055';

update ads_base
set Prop_Code = 'HP0522'
where Prop_Code = 'HP0006';

update property_type_relationship set Prop_Code = 'HP0522' where Prop_Code = 'HP0006';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0006')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0006'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0006'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0006')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0006')
where Housing_Code = 'HP0522';

update ads_base
set Prop_Code = 'HP0763'
where Prop_Code = 'HP0007';

update property_type_relationship set Prop_Code = 'HP0763' where Prop_Code = 'HP0007';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0007')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0007'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0007'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0007')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0007')
where Housing_Code = 'HP0763';

update ads_base
set Prop_Code = 'HP0646'
where Prop_Code = 'HP0008';

update property_type_relationship set Prop_Code = 'HP0646' where Prop_Code = 'HP0008';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0008')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0008'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0008'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0008')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0008')
where Housing_Code = 'HP0646';

update ads_base
set Prop_Code = 'HP0076'
where Prop_Code = 'HP0009';

update property_type_relationship set Prop_Code = 'HP0076' where Prop_Code = 'HP0009';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0009')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0009'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0009'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0009')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0009')
where Housing_Code = 'HP0076';

update ads_base
set Prop_Code = 'HP0469'
where Prop_Code in ('HP0010','HP0036');

update property_type_relationship set Prop_Code = 'HP0469' where Prop_Code in ('HP0010','HP0036');

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0010')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0010'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0010'))
    , Housing_Latitude = 13.77915618691862
    , Housing_Longitude = 100.54007812496825
where Housing_Code = 'HP0469';

update ads_base
set Prop_Code = 'HP1927'
where Prop_Code = 'HP0011';

update property_type_relationship set Prop_Code = 'HP1927' where Prop_Code = 'HP0011';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0011')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0011'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0011'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0011')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0011')
where Housing_Code = 'HP1927';

update ads_base
set Prop_Code = 'HP0876'
where Prop_Code = 'HP0012';

update property_type_relationship set Prop_Code = 'HP0876' where Prop_Code = 'HP0012';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0012')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0012'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0012'))
    , Housing_Latitude = 13.632655184621067
    , Housing_Longitude = 100.7187079064304
where Housing_Code = 'HP0876';

update ads_base
set Prop_Code = 'HP1722'
where Prop_Code = 'HP0013';

update property_type_relationship set Prop_Code = 'HP1722' where Prop_Code = 'HP0013';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0013')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0013'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0013'))
    , Housing_Latitude = 13.634422028211096
    , Housing_Longitude = 100.71780602636628
where Housing_Code = 'HP1722';

update ads_base
set Prop_Code = 'HP2457'
where Prop_Code = 'HP0014';

update property_type_relationship set Prop_Code = 'HP2457' where Prop_Code = 'HP0014';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0014')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0014'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0014'))
    , Housing_Latitude = 13.896160861145937
    , Housing_Longitude = 100.57828812520117
where Housing_Code = 'HP2457';

update ads_base
set Prop_Code = 'HP0297'
where Prop_Code = 'HP0015';

update property_type_relationship set Prop_Code = 'HP0297' where Prop_Code = 'HP0015';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0015')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0015'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0015'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0015')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0015')
where Housing_Code = 'HP0297';

update ads_base
set Prop_Code = 'HP1570'
where Prop_Code = 'HP0016';

update property_type_relationship set Prop_Code = 'HP1570' where Prop_Code = 'HP0016';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0016')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0016'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0016'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0016')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0016')
where Housing_Code = 'HP1570';

update ads_base
set Prop_Code = 'HP0064'
where Prop_Code = 'HP0017';

update property_type_relationship set Prop_Code = 'HP0064' where Prop_Code = 'HP0017';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0017')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0017'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0017'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0017')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0017')
where Housing_Code = 'HP0064';

update ads_base
set Prop_Code = 'HP0190'
where Prop_Code = 'HP0018';

update property_type_relationship set Prop_Code = 'HP0190' where Prop_Code = 'HP0018';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0018')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0018'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0018'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0018')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0018')
where Housing_Code = 'HP0190';

update ads_base
set Prop_Code = 'HP0497'
where Prop_Code = 'HP0019';

update property_type_relationship set Prop_Code = 'HP0497' where Prop_Code = 'HP0019';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0019')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0019'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0019'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0019')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0019')
where Housing_Code = 'HP0497';

update ads_base
set Prop_Code = 'HP1184'
where Prop_Code = 'HP0020';

update property_type_relationship set Prop_Code = 'HP1184' where Prop_Code = 'HP0020';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0020')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0020'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0020'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0020')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0020')
where Housing_Code = 'HP1184';

update ads_base
set Prop_Code = 'HP0394'
where Prop_Code = 'HP0021';

update property_type_relationship set Prop_Code = 'HP0394' where Prop_Code = 'HP0021';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0021')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0021'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0021'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0021')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0021')
where Housing_Code = 'HP0394';

update ads_base
set Prop_Code = 'HP0585'
where Prop_Code = 'HP0022';

update property_type_relationship set Prop_Code = 'HP0585' where Prop_Code = 'HP0022';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0022')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0022'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0022'))
    , Housing_Latitude = 12.723696179766865
    , Housing_Longitude = 101.07339256728042
where Housing_Code = 'HP0585';

update ads_base
set Prop_Code = 'HP0154'
where Prop_Code = 'HP0023';

update property_type_relationship set Prop_Code = 'HP0154' where Prop_Code = 'HP0023';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0023')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0023'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0023'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0023')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0023')
where Housing_Code = 'HP0154';

update ads_base
set Prop_Code = 'HP2356'
where Prop_Code = 'HP0024';

update property_type_relationship set Prop_Code = 'HP2356' where Prop_Code = 'HP0024';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0024')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0024'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0024'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0024')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0024')
where Housing_Code = 'HP2356';

update ads_base
set Prop_Code = 'HP1158'
where Prop_Code = 'HP0025';

update property_type_relationship set Prop_Code = 'HP1158' where Prop_Code = 'HP0025';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0025')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0025'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0025'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0025')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0025')
where Housing_Code = 'HP1158';

update ads_base
set Prop_Code = 'HP1065'
where Prop_Code = 'HP0026';

update property_type_relationship set Prop_Code = 'HP1065' where Prop_Code = 'HP0026';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0026')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0026'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0026'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0026')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0026')
where Housing_Code = 'HP1065';

update ads_base
set Prop_Code = 'HP1219'
where Prop_Code = 'HP0027';

update property_type_relationship set Prop_Code = 'HP1219' where Prop_Code = 'HP0027';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0027')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0027'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0027'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0027')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0027')
where Housing_Code = 'HP1219';

update ads_base
set Prop_Code = 'HP0069'
where Prop_Code = 'HP0028';

update property_type_relationship set Prop_Code = 'HP0069' where Prop_Code = 'HP0028';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0028')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0028'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0028'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0028')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0028')
where Housing_Code = 'HP0069';

update ads_base
set Prop_Code = 'HP0304'
where Prop_Code = 'HP0029';

update property_type_relationship set Prop_Code = 'HP0304' where Prop_Code = 'HP0029';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0029')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0029'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0029'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0029')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0029')
where Housing_Code = 'HP0304';

update ads_base
set Prop_Code = 'HP1142'
where Prop_Code = 'HP0030';

update property_type_relationship set Prop_Code = 'HP1142' where Prop_Code = 'HP0030';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0030')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0030'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0030'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0030')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0030')
where Housing_Code = 'HP1142';

update ads_base
set Prop_Code = 'HP0396'
where Prop_Code = 'HP0031';

update property_type_relationship set Prop_Code = 'HP0396' where Prop_Code = 'HP0031';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0031')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0031'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0031'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0031')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0031')
where Housing_Code = 'HP0396';

update ads_base
set Prop_Code = 'HP0316'
where Prop_Code = 'HP0032';

update property_type_relationship set Prop_Code = 'HP0316' where Prop_Code = 'HP0032';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0032')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0032'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0032'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0032')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0032')
where Housing_Code = 'HP0316';

update ads_base
set Prop_Code = 'HP0804'
where Prop_Code = 'HP0033';

update property_type_relationship set Prop_Code = 'HP0804' where Prop_Code = 'HP0033';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0033')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0033'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0033'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0033')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0033')
where Housing_Code = 'HP0804';

update ads_base
set Prop_Code = 'HP0554'
where Prop_Code = 'HP0034';

update property_type_relationship set Prop_Code = 'HP0554' where Prop_Code = 'HP0034';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0034')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0034'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0034'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0034')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0034')
where Housing_Code = 'HP0554';

update ads_base
set Prop_Code = 'HP0078'
where Prop_Code = 'HP0035';

update property_type_relationship set Prop_Code = 'HP0078' where Prop_Code = 'HP0035';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0035')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0035'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0035'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0035')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0035')
where Housing_Code = 'HP0078';

update ads_base
set Prop_Code = 'HP0293'
where Prop_Code = 'HP0037';

update property_type_relationship set Prop_Code = 'HP0293' where Prop_Code = 'HP0037';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0037')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0037'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0037'))
    , Housing_Latitude = 13.760534491085298
    , Housing_Longitude = 100.5862886231183
where Housing_Code = 'HP0293';

update ads_base
set Prop_Code = 'HP0583'
where Prop_Code = 'HP0038';

update property_type_relationship set Prop_Code = 'HP0583' where Prop_Code = 'HP0038';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0038')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0038'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0038'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0038')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0038')
where Housing_Code = 'HP0583';

update ads_base
set Prop_Code = 'HP4470'
where Prop_Code = 'HP0039';

update property_type_relationship set Prop_Code = 'HP4470' where Prop_Code = 'HP0039';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0039')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0039'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0039'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0039')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0039')
where Housing_Code = 'HP4470';

update ads_base
set Prop_Code = 'HP0140'
where Prop_Code = 'HP0040';

update property_type_relationship set Prop_Code = 'HP0140' where Prop_Code = 'HP0040';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0040')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0040'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0040'))
    , Housing_Latitude = 13.8050591567838
    , Housing_Longitude = 100.44500612311901
where Housing_Code = 'HP0140';

update ads_base
set Prop_Code = 'HP0508'
where Prop_Code = 'HP0041';

update property_type_relationship set Prop_Code = 'HP0508' where Prop_Code = 'HP0041';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0041')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0041'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0041'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0041')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0041')
where Housing_Code = 'HP0508';

update ads_base
set Prop_Code = 'HP0170'
where Prop_Code = 'HP0061';

update property_type_relationship set Prop_Code = 'HP0170' where Prop_Code = 'HP0061';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0061')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0061'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0061'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0061')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0061')
where Housing_Code = 'HP0170';

update ads_base
set Prop_Code = 'HP0061'
where Prop_Code = 'HP0042';

update property_type_relationship set Prop_Code = 'HP0061' where Prop_Code = 'HP0042';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0042')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0042'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0042'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0042')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0042')
where Housing_Code = 'HP0061';

update ads_base
set Prop_Code = 'HP0346'
where Prop_Code = 'HP0043';

update property_type_relationship set Prop_Code = 'HP0346' where Prop_Code = 'HP0043';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0043')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0043'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0043'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0043')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0043')
where Housing_Code = 'HP0346';

update ads_base
set Prop_Code = 'HP0012'
where Prop_Code = 'HP0044';

update property_type_relationship set Prop_Code = 'HP0012' where Prop_Code = 'HP0044';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0044')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0044'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0044'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0044')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0044')
where Housing_Code = 'HP0012';

update ads_base
set Prop_Code = 'HP0231'
where Prop_Code = 'HP0045';

update property_type_relationship set Prop_Code = 'HP0231' where Prop_Code = 'HP0045';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0045')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0045'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0045'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0045')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0045')
where Housing_Code = 'HP0231';

update ads_base
set Prop_Code = 'HP0203'
where Prop_Code = 'HP0046';

update property_type_relationship set Prop_Code = 'HP0203' where Prop_Code = 'HP0046';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0046')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0046'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0046'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0046')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0046')
where Housing_Code = 'HP0203';

update ads_base
set Prop_Code = 'HP0687'
where Prop_Code = 'HP0063';

update property_type_relationship set Prop_Code = 'HP0687' where Prop_Code = 'HP0063';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0063')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0063'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0063'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0063')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0063')
where Housing_Code = 'HP0687';

update ads_base
set Prop_Code = 'HP0063'
where Prop_Code = 'HP0047';

update property_type_relationship set Prop_Code = 'HP0063' where Prop_Code = 'HP0047';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0047')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0047'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0047'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0047')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0047')
where Housing_Code = 'HP0063';

update ads_base
set Prop_Code = 'HP0229'
where Prop_Code = 'HP0048';

update property_type_relationship set Prop_Code = 'HP0229' where Prop_Code = 'HP0048';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0048')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0048'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0048'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0048')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0048')
where Housing_Code = 'HP0229';

update ads_base
set Prop_Code = 'HP0009'
where Prop_Code = 'HP0049';

update property_type_relationship set Prop_Code = 'HP0009' where Prop_Code = 'HP0049';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0049')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0049'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0049'))
    , Housing_Latitude = 14.017075741138939
    , Housing_Longitude = 100.4762108856829
where Housing_Code = 'HP0009';

update ads_base
set Prop_Code = 'HP0898'
where Prop_Code = 'HP0050';

update property_type_relationship set Prop_Code = 'HP0898' where Prop_Code = 'HP0050';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0050')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0050'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0050'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0050')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0050')
where Housing_Code = 'HP0898';

update ads_base
set Prop_Code = 'HP0002'
where Prop_Code = 'HP0051';

update property_type_relationship set Prop_Code = 'HP0002' where Prop_Code = 'HP0051';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0051')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0051'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0051'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0051')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0051')
where Housing_Code = 'HP0002';

update ads_base
set Prop_Code = 'HP0014'
where Prop_Code = 'HP0052';

update property_type_relationship set Prop_Code = 'HP0014' where Prop_Code = 'HP0052';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0052')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0052'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0052'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0052')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0052')
where Housing_Code = 'HP0014';

update ads_base
set Prop_Code = 'HP0028'
where Prop_Code = 'HP0053';

update property_type_relationship set Prop_Code = 'HP0028' where Prop_Code = 'HP0053';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0053')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0053'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0053'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0053')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0053')
where Housing_Code = 'HP0028';

update ads_base
set Prop_Code = 'HP0289'
where Prop_Code = 'HP0054';

update property_type_relationship set Prop_Code = 'HP0289' where Prop_Code = 'HP0054';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0054')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0054'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0054'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0054')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0054')
where Housing_Code = 'HP0289';

update ads_base
set Prop_Code = 'HP0271'
where Prop_Code = 'HP0055';

update property_type_relationship set Prop_Code = 'HP0271' where Prop_Code = 'HP0055';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0055')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0055'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0055'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0055')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0055')
where Housing_Code = 'HP0271';

update ads_base
set Prop_Code = 'HP0167'
where Prop_Code = 'HP0056';

update property_type_relationship set Prop_Code = 'HP0167' where Prop_Code = 'HP0056';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0056')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0056'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0056'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0056')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0056')
where Housing_Code = 'HP0167';

update ads_base
set Prop_Code = 'HP0377'
where Prop_Code = 'HP0057';

update property_type_relationship set Prop_Code = 'HP0377' where Prop_Code = 'HP0057';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0057')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0057'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0057'))
    , Housing_Latitude = 13.671253213724619
    , Housing_Longitude = 100.70009163601063
where Housing_Code = 'HP0377';

update ads_base
set Prop_Code = 'HP0721'
where Prop_Code = 'HP9002';

update property_type_relationship set Prop_Code = 'HP0721' where Prop_Code = 'HP9002';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP9002')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP9002'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP9002'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP9002')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP9002')
where Housing_Code = 'HP0721';

update ads_base
set Prop_Code = 'HP0825'
where Prop_Code = 'HP0062';

update property_type_relationship set Prop_Code = 'HP0825' where Prop_Code = 'HP0062';

update housing
set Housing_ENName = (select House_ENName from ads_housing_project where House_Code = 'HP0062')
    , Housing_Built_Start = ifnull(Housing_Built_Start, (select House_Build_Start from ads_housing_project where House_Code = 'HP0062'))
    , Housing_Built_Finished = ifnull(Housing_Built_Finished, (select House_Build_Finish from ads_housing_project where House_Code = 'HP0062'))
    , Housing_Latitude = (select House_Latitude from ads_housing_project where House_Code = 'HP0062')
    , Housing_Longitude = (select House_Longitude from ads_housing_project where House_Code = 'HP0062')
where Housing_Code = 'HP0825';