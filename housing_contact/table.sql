-- housing_contact_dev_agent
-- housing_contact_send_to_who
-- housing_contact_email_log
-- housing_contact_dev_agent_detail

-- Table housing_contact_dev_agent
CREATE TABLE `housing_contact_dev_agent` (
    `Dev_Agent_Contact_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Company_Name` varchar(250) NOT NULL,
    `Contact_Name` varchar(250) NULL,
    `Dev_or_Agent` ENUM('D','A') NOT NULL,
    `Email` TEXT NOT NULL,
    `Developer_Code` varchar(20) NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Dev_Agent_Contact_ID`),
    INDEX h_dev_agent_admin1 (Created_By),
    INDEX h_dev_agent_admin2 (Last_Updated_By),
    INDEX h_dev_agent_developer (Developer_Code),
    CONSTRAINT h_dev_agent_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_dev_agent_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID)
) ENGINE=InnoDB;

-- Table housing_contact_send_to_who
CREATE TABLE `housing_contact_send_to_who` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` varchar(50) NOT NULL,
    `Dev_Agent_Contact_ID` INT UNSIGNED NOT NULL,
    `Created_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Created_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Last_Updated_By` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `Last_Updated_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX h_send_admin1 (Created_By),
    INDEX h_send_admin2 (Last_Updated_By),
    INDEX h_send_dev_agent (Dev_Agent_Contact_ID),
    CONSTRAINT h_send_admin1 FOREIGN KEY (Created_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_send_admin2 FOREIGN KEY (Last_Updated_By) REFERENCES user_admin(User_ID),
    CONSTRAINT h_send_dev_agent FOREIGN KEY (Dev_Agent_Contact_ID) REFERENCES housing_contact_dev_agent(Dev_Agent_Contact_ID)
) ENGINE=InnoDB;

-- housing_contact_email_log
CREATE TABLE `housing_contact_email_log` (
    `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
    `Contact_ID` int NULL,
    `Housing_Code` varchar(50) NULL,
    `Contact_Type` enum('Main','Near') NULL,
    `Dev_Agent_Contact_ID` int NULL,
    `Dev_or_Agent` varchar(1) NULL,
    `Company_Name` varchar(250) NULL,
    `Contact_Name` varchar(250) NULL,
    `Email` text NULL,
    `Contact_Sent` enum('Y','N','W','E') NULL,
    `Error_Reason` text NULL,
    `Contact_Sent_Date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

-- table housing_contact_dev_agent_detail
CREATE TABLE `housing_contact_dev_agent_detail` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `Housing_Code` varchar(50) NOT NULL,
    `Housing_Sold_Out` BOOLEAN NOT NULL,
    `Dev_or_Agent` ENUM('D','A') NOT NULL,
    `Dev_Agent_Contact_ID` INT UNSIGNED NULL,
    `Company_Name` varchar(250) NULL DEFAULT '',
    `Contact_Name` varchar(250) NULL DEFAULT '',
    `Email` text NULL,
    PRIMARY KEY (`ID`)
) ENGINE=InnoDB;