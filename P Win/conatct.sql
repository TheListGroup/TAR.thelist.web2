SELECT cd.Developer_ENName, count(rcf.Contact_Ref_ID)
FROM `real_contact_form` rcf
left join real_condo rc on rcf.Contact_Ref_ID = rc.Condo_Code
left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
where rcf.Contact_Type = 'contact'
and (rcf.Contact_Date like '2024-05%' or rcf.Contact_Date like '2024-06%')
and cd.Developer_ENName is not null
group by cd.Developer_ENName
ORDER BY cd.Developer_ENName;