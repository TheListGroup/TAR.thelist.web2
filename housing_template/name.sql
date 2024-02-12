SELECT rc1.Condo_Code
    ,if(rc2.Condo_Code2 is not null,'',SUBSTRING_INDEX(SUBSTRING_INDEX(rc1.Condo_Name, '\n', 2), '\n', -1)) as Condo_Name 
    , if(rc2.Condo_Code2 is not null,'',SUBSTRING_INDEX(SUBSTRING_INDEX(rc1.Condo_ENName, '\n', 2), '\n', -1)) as Condo_ENName
FROM `real_condo` rc1
left JOIN ( select Condo_Code as Condo_Code2
                            ,   Condo_ENName as Condo_ENName2
                        from real_condo
                        WHERE Condo_ENName NOT LIKE '%\n%' 
                        AND Condo_ENName NOT LIKE '%\r%') rc2
on rc1.Condo_Code = rc2.Condo_Code2;


SELECT District_Name
	, replace(District_Name_Eng,concat(District_Code,'-'),'') as  District_Name_Eng
FROM `realist_district`;

SELECT SubDistrict_Name
	, replace(SubDistrict_Name_Eng,concat(SubDistrict_Code,'-'),'') as  SubDistrict_Name
FROM `realist_sub_district`;