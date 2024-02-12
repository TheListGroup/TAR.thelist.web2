/* CLEANING TABLES, ล้างอันที่ว่าง, เปลี่ยน data type */

/* REAL_CONDO_PRICE */

/*
Price_Average_56_1_Square           CLEAN   ALTER FLOAT
Price_Average_56_1_Square_Date      CLEAN   ALTER DATE
Price_Average_Resale_Square         CLEAN   ALTER FLOAT
Price_Average_Resale_Square_Date    CLEAN   ALTER DATE
Price_Start_Blogger_Square          CLEAN   ALTER FLOAT
Price_Start_Blogger_Square_Date     CLEAN   ALTER DATE
Price_Start_Day1_Square             CLEAN   ALTER FLOAT
Price_Start_Day1_Square_Date        CLEAN   ALTER DATE

Price_Start_Blogger_Unit            CLEAN   ALTER FLOAT
Price_Start_Blogger_Unit_Date       CLEAN   ALTER DATE
Price_Start_Day1_Unit               CLEAN   ALTER FLOAT
Price_Start_Day1_Unit_Date          CLEAN   ALTER DATE
Price_Start_56_1_Unit               CLEAN   ALTER FLOAT
Price_Start_56_1_Unit_Date          CLEAN   ALTER DATE

Condo_Sold_Status_56_1_Percent      CLEAN   ALTER FLOAT
Condo_Sold_Status_56_1_Date         CLEAN   ALTER DATE

Condo_Built_Finished                CLEAN   ALTER DATE
Condo_Built_Start                   CLEAN   ALTER DATE

Condo_Common_Fee                    CLEAN   ALTER FLOAT
Condo_Salable_Area                  CLEAN   ALTER FLOAT

Condo_Segment                       CLEAN   (VARCHAR เหมือนเดิม)
*/

/* REAL_CONDO */
/*
Condo_TotalUnit                     CLEAN   ALTER INT
Lat, Long ปล่อยไว้เหมือนเดิม
*/

/* REAL_CONDO_FULL_TEMPLATE */
/*
Parking_Amount                      CLEAN   ALTER INT
Passenger_Lift_Amount               CLEAN   ALTER INT
Service_Lift_Amount                 CLEAN   ALTER INT
Pool_Width                          CLEAN   ALTER FLOAT
Pool_Length                         CLEAAN  ALTER FLOAT
*/

/**************************************************/
/*      REAL_CONDO_PRICE                          */
/**************************************************/



UPDATE real_condo_price
SET Price_Average_56_1_Square = NULL
WHERE Price_Average_56_1_Square = '' ;

ALTER TABLE real_condo_price CHANGE Price_Average_56_1_Square 
Price_Average_56_1_Square FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Average_56_1_Square_Date = NULL
WHERE Price_Average_56_1_Square_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Average_56_1_Square_Date 
Price_Average_56_1_Square_Date DATE NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Average_Resale_Square = NULL
WHERE 	Price_Average_Resale_Square = '' ;

ALTER TABLE real_condo_price CHANGE Price_Average_Resale_Square 
Price_Average_Resale_Square FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Average_Resale_Square_Date = NULL
WHERE Price_Average_Resale_Square_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Average_Resale_Square_Date 
Price_Average_Resale_Square_Date DATE NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Blogger_Square = NULL
WHERE Price_Start_Blogger_Square = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Blogger_Square 
Price_Start_Blogger_Square FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Blogger_Square_Date = NULL
WHERE Price_Start_Blogger_Square_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Blogger_Square_Date 
Price_Start_Blogger_Square_Date DATE NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Day1_Square = NULL
WHERE Price_Start_Day1_Square = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Day1_Square 
Price_Start_Day1_Square FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Day1_Square_Date = NULL
WHERE Price_Start_Day1_Square_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Day1_Square_Date 
Price_Start_Day1_Square_Date DATE NULL DEFAULT NULL;




UPDATE real_condo_price
SET Price_Start_Blogger_Unit = NULL
WHERE Price_Start_Blogger_Unit = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Blogger_Unit 
Price_Start_Blogger_Unit FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Blogger_Unit_Date = NULL
WHERE Price_Start_Blogger_Unit_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Blogger_Unit_Date 
Price_Start_Blogger_Unit_Date DATE NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Day1_Unit = NULL
WHERE Price_Start_Day1_Unit = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Day1_Unit 
Price_Start_Day1_Unit FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_Day1_Unit_Date = NULL
WHERE Price_Start_Day1_Unit_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_Day1_Unit_Date 
Price_Start_Day1_Unit_Date DATE NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_56_1_Unit = NULL
WHERE Price_Start_56_1_Unit = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_56_1_Unit 
Price_Start_56_1_Unit FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Price_Start_56_1_Unit_Date = NULL
WHERE Price_Start_56_1_Unit_Date = '' ;

ALTER TABLE real_condo_price CHANGE Price_Start_56_1_Unit_Date 
Price_Start_56_1_Unit_Date DATE NULL;




UPDATE real_condo_price
SET Condo_Sold_Status_56_1_Percent = NULL
WHERE Condo_Sold_Status_56_1_Percent = '' ;

ALTER TABLE real_condo_price CHANGE Condo_Sold_Status_56_1_Percent 
Condo_Sold_Status_56_1_Percent FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Condo_Sold_Status_56_1_Date = NULL
WHERE Condo_Sold_Status_56_1_Date = '' ;

ALTER TABLE real_condo_price CHANGE Condo_Sold_Status_56_1_Date 
Condo_Sold_Status_56_1_Date DATE NULL DEFAULT NULL;




UPDATE real_condo_price
SET Condo_Built_Finished = NULL
WHERE Condo_Built_Finished = '' ;

ALTER TABLE real_condo_price CHANGE Condo_Built_Finished 
Condo_Built_Finished DATE NULL DEFAULT NULL;

UPDATE real_condo_price
SET Condo_Built_Start = NULL
WHERE Condo_Built_Start = '' ;

ALTER TABLE real_condo_price CHANGE Condo_Built_Start 
Condo_Built_Start DATE NULL DEFAULT NULL;




UPDATE real_condo_price
SET Condo_Common_Fee = NULL
WHERE Condo_Common_Fee = '' ;

ALTER TABLE real_condo_price CHANGE Condo_Common_Fee 
Condo_Common_Fee FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Condo_Salable_Area = NULL
WHERE Condo_Salable_Area = '' ;

ALTER TABLE real_condo_price CHANGE Condo_Salable_Area 
Condo_Salable_Area FLOAT NULL DEFAULT NULL;

UPDATE real_condo_price
SET Condo_Segment = NULL
WHERE Condo_Segment = '' ;



/**************************************************/
/*      REAL_CONDO                                */
/**************************************************/

UPDATE real_condo
SET Condo_TotalUnit = NULL
WHERE Condo_TotalUnit = '' ;

ALTER TABLE real_condo CHANGE Condo_TotalUnit 
Condo_TotalUnit INT NULL DEFAULT NULL;


/**************************************************/
/*      REAL_CONDO_FULL_TEMPLATE                  */
/**************************************************/


UPDATE real_condo_full_template
SET Parking_Amount = NULL
WHERE Parking_Amount = '' ;

UPDATE real_condo_full_template
SET Parking_Amount = NULL
WHERE Parking_Amount = 'n/a' ;

ALTER TABLE real_condo_full_template CHANGE Parking_Amount 
Parking_Amount INT NULL DEFAULT NULL;

UPDATE real_condo_full_template
SET Passenger_Lift_Amount = NULL
WHERE Passenger_Lift_Amount = '' ;

ALTER TABLE real_condo_full_template CHANGE Passenger_Lift_Amount 
Passenger_Lift_Amount INT NULL DEFAULT NULL;

UPDATE real_condo_full_template
SET Service_Lift_Amount = NULL
WHERE Service_Lift_Amount = '' ;

ALTER TABLE real_condo_full_template CHANGE Service_Lift_Amount 
Service_Lift_Amount INT NULL DEFAULT NULL;

UPDATE real_condo_full_template
SET Pool_Width = NULL
WHERE Pool_Width = '' ;

UPDATE real_condo_full_template
SET Pool_Width = NULL
WHERE Pool_Width = 'n/a' ;

UPDATE real_condo_full_template
SET Pool_Width = NULL
WHERE Pool_Width = 'N/A' ;

UPDATE real_condo_full_template 
SET Pool_Width = '4.5', Pool_Length = '32' WHERE real_condo_full_template.id = '1291' ;

ALTER TABLE real_condo_full_template CHANGE Pool_Width 
Pool_Width FLOAT NULL DEFAULT NULL;

UPDATE real_condo_full_template
SET Pool_Length = NULL
WHERE Pool_Length = '' ;

ALTER TABLE real_condo_full_template CHANGE Pool_Length 
Pool_Length FLOAT NULL DEFAULT NULL;