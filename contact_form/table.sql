-- Table
    -- real_contact_dev_agent
    -- real_contact_condo_send_to_who
    -- real_contact_condo_send_to_who_log
-- real_contact_dev_agent_detail_view

-- Table real_contact_dev_agent
CREATE TABLE `real_contact_dev_agent` (
    `Dev_Agent_Contact_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Company_Name` varchar(250) NOT NULL,
    `Contact_Name` varchar(250) NULL,
    `Dev_or_Agent` ENUM('D','A') NOT NULL,
    `Email` TEXT NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Dev_Agent_Contact_ID`),
    INDEX dev_agent_admin1 (Created_By),
    INDEX dev_agent_admin2 (Last_Updated_By),
    CONSTRAINT dev_agent_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT dev_agent_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID)
) ENGINE=InnoDB;


-- Table real_contact_condo_send_to_who
CREATE TABLE `real_contact_condo_send_to_who` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Condo_Code` varchar(50) NOT NULL,
    `Dev_Agent_Contact_ID` INT UNSIGNED NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX send_admin1 (Created_By),
    INDEX send_admin2 (Last_Updated_By),
    INDEX send_dev_agent (Dev_Agent_Contact_ID),
    CONSTRAINT send_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT send_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT send_dev_agent FOREIGN KEY (Dev_Agent_Contact_ID) REFERENCES real_contact_dev_agent(Dev_Agent_Contact_ID)
) ENGINE=InnoDB;

-- log
CREATE TABLE `real_contact_condo_send_to_who_log` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Contact_ID` INT UNSIGNED NOT NULL,
    `Condo_Code` varchar(50) NOT NULL,
    `Main_or_Near` ENUM('Main','Near') NOT NULL,
    `Dev_Agent_Contact_ID` INT UNSIGNED NOT NULL,
    `Sent` ENUM('Y','N') NOT NULL,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

-- view real_contact_dev_agent_detail
CREATE OR REPLACE VIEW real_contact_dev_agent_detail as
select rc.Condo_Code
    , sm.Condo_Sold_Out
    , if(sm.Condo_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , 'D'
            , da.Dev_or_Agent)
        , ifnull(da.Dev_or_Agent,'D')) as Dev_or_Agent
    , if(sm.Condo_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , 0
            , sw.Dev_Agent_Contact_ID)
        , ifnull(sw.Dev_Agent_Contact_ID,null)) as Dev_Agent_Contact_ID
    , if(sm.Condo_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , 'Sold Out'
            , da.Company_Name)
        , ifnull(da.Company_Name,'')) as Company_Name
    , if(sm.Condo_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , ''
            , da.Contact_Name)
        , ifnull(da.Contact_Name,'')) as Contact_Name
    , if(sm.Condo_Sold_Out = 1
        , if(sw.Dev_Agent_Contact_ID is null
            , ''
            , da.Email)
        , ifnull(da.Email,'')) as Email
from real_condo rc
left join (select Condo_Code, Dev_Agent_Contact_ID
            from (select rc.Condo_Code
                        , sw.Dev_Agent_Contact_ID
                    from real_condo rc
                    left join (select sw.Condo_Code
                                    , sw.Dev_Agent_Contact_ID
                                from real_contact_condo_send_to_who sw
                                left join real_contact_dev_agent rda on sw.Dev_Agent_Contact_ID = rda.Dev_Agent_Contact_ID
                                where rda.Dev_or_Agent = 'D') sw
                    on rc.Condo_Code = sw.Condo_Code) swd
            union all select Condo_Code, Dev_Agent_Contact_ID 
                        from (select rc.Condo_Code
                                    , sw.Dev_Agent_Contact_ID
                                from real_condo rc
                                left join real_contact_condo_send_to_who sw on rc.Condo_Code = sw.Condo_Code
                                left join real_contact_dev_agent rda on sw.Dev_Agent_Contact_ID = rda.Dev_Agent_Contact_ID
                                where rda.Dev_or_Agent = 'A') swa) sw
on rc.Condo_Code = sw.Condo_Code
left join real_contact_dev_agent da on sw.Dev_Agent_Contact_ID = da.Dev_Agent_Contact_ID
left join (select Condo_Code
                , if((year(curdate()) - CAST(Condo_Built_Date AS SIGNED) >= 10)
                    or (Condo_Sold_Status_Show_Value = '1')
                    or (Condo_Sold_Status_Show_Value = 'RESALE'),1,0) as Condo_Sold_Out
            from all_condo_price_calculate) sm 
on rc.Condo_Code = sm.Condo_Code
where rc.Condo_Status <> 2
order by rc.Condo_Code, da.Dev_or_Agent;