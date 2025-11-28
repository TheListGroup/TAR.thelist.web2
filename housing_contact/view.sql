-- view housing_contact_dev_agent_detail
CREATE OR REPLACE VIEW source_housing_contact_dev_agent_detail as
select h.Housing_Code
    , sm.Housing_Sold_Out
    , if(sm.Housing_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , 'D'
            , da.Dev_or_Agent)
        , ifnull(da.Dev_or_Agent,'D')) as Dev_or_Agent
    , if(sm.Housing_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , 0
            , sw.Dev_Agent_Contact_ID)
        , ifnull(sw.Dev_Agent_Contact_ID,null)) as Dev_Agent_Contact_ID
    , if(sm.Housing_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , 'Sold Out'
            , da.Company_Name)
        , ifnull(da.Company_Name,'')) as Company_Name
    , if(sm.Housing_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , ''
            , da.Contact_Name)
        , ifnull(da.Contact_Name,'')) as Contact_Name
    , if(sm.Housing_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , ''
            , da.Email)
        , ifnull(da.Email,'')) as Email
from housing h
left join (select Housing_Code, Dev_Agent_Contact_ID
            from (select h.Housing_Code
                        , sw.Dev_Agent_Contact_ID
                    from housing h
                    left join (select sw.Housing_Code
                                    , sw.Dev_Agent_Contact_ID
                                from housing_contact_send_to_who sw
                                left join housing_contact_dev_agent hda on sw.Dev_Agent_Contact_ID = hda.Dev_Agent_Contact_ID
                                where hda.Dev_or_Agent = 'D') sw
                    on h.Housing_Code = sw.Housing_Code) swd
            union all select Housing_Code, Dev_Agent_Contact_ID 
                        from (select sw.Housing_Code
                                    , sw.Dev_Agent_Contact_ID
                                from housing_contact_send_to_who sw
                                left join housing_contact_dev_agent hda on sw.Dev_Agent_Contact_ID = hda.Dev_Agent_Contact_ID
                                where hda.Dev_or_Agent = 'A') swa) sw
on h.Housing_Code = sw.Housing_Code
left join housing_contact_dev_agent da on sw.Dev_Agent_Contact_ID = da.Dev_Agent_Contact_ID
left join (select Housing_Code
                , if((year(curdate()) - CAST(ifnull(year(Housing_Built_Finished), year(Housing_Built_Start)) AS SIGNED) >= 10)
                    or (Housing_Sold_Status_Raw_Number = 100),1,0) as Housing_Sold_Out
            from housing) sm 
on h.Housing_Code = sm.Housing_Code
where h.Housing_Status = '1'
order by h.Housing_Code, da.Dev_or_Agent;