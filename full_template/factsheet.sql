-- update table
update real_condo
set Road_Name = null
where Road_Name = '';

update real_condo
set RealDistrict_Code = null
where RealDistrict_Code = '';

update real_condo
set RealSubDistrict_Code = null
where RealSubDistrict_Code = '';

-- update table
update real_condo_full_template
set Condo_Fund_Fee = null
where Condo_Fund_Fee = '';

-- function ใส่หน่วย
DELIMITER //

CREATE FUNCTION bath(letter VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = CONCAT(letter, ' บ./ตร.ม.');
    RETURN unit;
END //

-- function ใส่วงเล็บ
DELIMITER //

CREATE FUNCTION bk(brank VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = CONCAT('(',brank,')');
    RETURN unit;
END //

-- function check null
DELIMITER //

CREATE FUNCTION nun(nan VARCHAR(250))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE unit VARCHAR(250);
    SET unit = if(nan='','-',ifnull(nan,'-'));
    RETURN unit;
END //


CREATE OR REPLACE VIEW `all_condo_price_calculate_view` AS
select
    `a`.`Condo_Code` AS `Condo_Code`,
    if(
        (`b`.`Condo_Built_Finished` is not null),
        if(
            (
                (
                    year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)
                ) > 0
            ),
            'OLD-finishDate',
            'NEW-finishDate'
        ),
        if(
            (`b`.`Condo_Built_Start` is not null),
            if(
                (
                    (`a`.`Condo_HighRise` = 1)
                    or (
                        (`a`.`Condo_HighRise` = 0)
                        and (`a`.`Condo_LowRise` = 0)
                    )
                ),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)
                        ) > 0
                    ),
                    'OLD-launchDate-HighRise(4)',
                    'NEW-launchDate-HighRise(4)'
                ),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)
                        ) > 0
                    ),
                    'OLD-launchDate-LowRise(3)',
                    'NEW-launchDate-LowRise(3)'
                )
            ),
            'OLD-donno'
        )
    ) AS `Old_or_New`,
    if(
        isnull(`b`.`Price_Average_56_1_Square`),
        if(
            isnull(`b`.`Price_Average_Resale_Square`),
            if(
                isnull(`b`.`Price_Start_Blogger_Square`),
                if(
                    isnull(`b`.`Price_Start_Day1_Square`),
                    '',
                    'ราคาเริ่มต้น'
                ),
                'ราคาเริ่มต้น'
            ),
            'ราคาเฉลี่ย'
        ),
        'ราคาเฉลี่ย'
    ) AS `Condo_Age_Status_Square_Text`,
    if(
        (
            if(
                (`b`.`Condo_Built_Finished` is not null),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)
                        ) > 0
                    ),
                    'OLD',
                    'NEW'
                ),
                if(
                    (`b`.`Condo_Built_Start` is not null),
                    if(
                        (
                            (`a`.`Condo_HighRise` = 1)
                            or (
                                (`a`.`Condo_HighRise` = 0)
                                and (`a`.`Condo_LowRise` = 0)
                            )
                        ),
                        if(
                            (
                                (
                                    year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)
                                ) > 0
                            ),
                            'OLD',
                            'NEW'
                        ),
                        if(
                            (
                                (
                                    year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)
                                ) > 0
                            ),
                            'OLD',
                            'NEW'
                        )
                    ),
                    'OLD'
                )
            ) = 'NEW'
        ),
        ifnull(
            `b`.`Price_Average_56_1_Square`,
            ifnull(
                `b`.`Price_Average_Resale_Square`,
                ifnull(
                    `b`.`Price_Start_Blogger_Square`,
                    `b`.`Price_Start_Day1_Square`
                )
            )
        ),
        ifnull(
            `b`.`Price_Average_Resale_Square`,
            ifnull(
                `b`.`Price_Average_56_1_Square`,
                ifnull(
                    `b`.`Price_Start_Blogger_Square`,
                    `b`.`Price_Start_Day1_Square`
                )
            )
        )
    ) AS `Condo_Price_Per_Square`,
    if(
        (
            if(
                (`b`.`Condo_Built_Finished` is not null),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)
                        ) > 0
                    ),
                    'OLD',
                    'NEW'
                ),
                if(
                    (`b`.`Condo_Built_Start` is not null),
                    if(
                        (
                            (`a`.`Condo_HighRise` = 1)
                            or (
                                (`a`.`Condo_HighRise` = 0)
                                and (`a`.`Condo_LowRise` = 0)
                            )
                        ),
                        if(
                            (
                                (
                                    year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)
                                ) > 0
                            ),
                            'OLD',
                            'NEW'
                        ),
                        if(
                            (
                                (
                                    year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)
                                ) > 0
                            ),
                            'OLD',
                            'NEW'
                        )
                    ),
                    'OLD'
                )
            ) = 'NEW'
        ),
        if(
            isnull(`b`.`Price_Average_56_1_Square`),
            if(
                isnull(`b`.`Price_Average_Resale_Square`),
                if(
                    isnull(`b`.`Price_Start_Blogger_Square`),
                    if(
                        isnull(`b`.`Price_Start_Day1_Square`),
                        NULL,
                        `b`.`Price_Start_Day1_Square_Date`
                    ),
                    `b`.`Price_Start_Blogger_Square_Date`
                ),
                `b`.`Price_Average_Resale_Square_Date`
            ),
            `b`.`Price_Average_56_1_Square_Date`
        ),
        if(
            isnull(`b`.`Price_Average_Resale_Square`),
            if(
                isnull(`b`.`Price_Average_56_1_Square`),
                if(
                    isnull(`b`.`Price_Start_Blogger_Square`),
                    if(
                        isnull(`b`.`Price_Start_Day1_Square`),
                        NULL,
                        `b`.`Price_Start_Day1_Square_Date`
                    ),
                    `b`.`Price_Start_Blogger_Square_Date`
                ),
                `b`.`Price_Average_56_1_Square_Date`
            ),
            `b`.`Price_Average_Resale_Square_Date`
        )
    ) AS `Condo_Price_Per_Square_Date`,
    if(
        isnull(`b`.`Price_Start_Blogger_Unit`),
        if(
            isnull(`b`.`Price_Start_Day1_Unit`),
            if(
                isnull(`b`.`Price_Start_56_1_Unit`),
                '',
                'ราคาเฉลี่ย'
            ),
            'ราคาเริ่มต้น'
        ),
        'ราคาเริ่มต้น'
    ) AS `Condo_Price_Per_Unit_Text`,
    ifnull(
        `b`.`Price_Start_Blogger_Unit`,
        ifnull(
            `b`.`Price_Start_Day1_Unit`,
(`b`.`Price_Start_56_1_Unit` * 1000000)
        )
    ) AS `Condo_Price_Per_Unit`,
    if(
        isnull(`b`.`Price_Start_Blogger_Unit`),
        if(
            isnull(`b`.`Price_Start_Day1_Unit`),
            `b`.`Price_Start_56_1_Unit_Date`,
            `b`.`Price_Start_Day1_Unit_Date`
        ),
        `b`.`Price_Start_Blogger_Unit_Date`
    ) AS `Condo_Price_Per_Unit_Date`,
    if(
        isnull(`b`.`Condo_Sold_Status_56_1_Percent`),
        if(
            (`b`.`Condo_Built_Finished` is not null),
            if(
                (
                    (`b`.`Condo_Built_Finished` + interval 5 year) < now()
                ),
                'RESALE',
                NULL
            ),
            if(
                (`b`.`Condo_Built_Start` is not null),
                if(
                    (`a`.`Condo_HighRise` = 1),
                    if(
                        (
                            (`b`.`Condo_Built_Start` + interval 9 year) < now()
                        ),
                        'RESALE',
                        NULL
                    ),
                    if(
                        (
                            (`b`.`Condo_Built_Start` + interval 8 year) < now()
                        ),
                        'RESALE',
                        NULL
                    )
                ),
                'RESALE'
            )
        ),
        if(
            (`b`.`Condo_Sold_Status_56_1_Percent` <= 0),
            'PRESALE',
            if(
                (`b`.`Condo_Sold_Status_56_1_Percent` >= 1),
                'RESALE',
                round(`b`.`Condo_Sold_Status_56_1_Percent`, 2)
            )
        )
    ) AS `Condo_Sold_Status_Show_Value`,
    `b`.`Condo_Sold_Status_56_1_Date` AS `Condo_Sold_Status_Date`,
    if(
        isnull(`b`.`Condo_Built_Finished`),
        if(
            isnull(`b`.`Condo_Built_Start`),
            NULL,
            'ปีที่เปิดตัว'
        ),
        if(
            (`b`.`Condo_Built_Finished` > now()),
            'คาดว่าจะแล้วเสร็จ',
            'ปีที่แล้วเสร็จ'
        )
    ) AS `Condo_Built_Text`,
    if(
        isnull(`b`.`Condo_Built_Finished`),
        if(
            isnull(`b`.`Condo_Built_Start`),
            NULL,
            year(`b`.`Condo_Built_Start`)
        ),
        year(`b`.`Condo_Built_Finished`)
    ) AS `Condo_Built_Date`,
    if(
        (`b`.`Condo_Built_Start` is not null),
        `b`.`Condo_Built_Start`,
        convert(
            if(
                (
                    (`a`.`Condo_HighRise` = 1)
                    or (
                        (`a`.`Condo_HighRise` = 0)
                        and (`a`.`Condo_LowRise` = 0)
                    )
                ),
(`b`.`Condo_Built_Finished` - interval 4 year),
(`b`.`Condo_Built_Finished` - interval 3 year)
            ) using utf8
        )
    ) AS `Condo_Date_Calculate`,
    if(
        (
            if(
                (`b`.`Condo_Built_Finished` is not null),
                if(
                    (
                        (
                            year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)
                        ) > 0
                    ),
                    'OLD',
                    'NEW'
                ),
                if(
                    (`b`.`Condo_Built_Start` is not null),
                    if(
                        (
                            (`a`.`Condo_HighRise` = 1)
                            or (
                                (`a`.`Condo_HighRise` = 0)
                                and (`a`.`Condo_LowRise` = 0)
                            )
                        ),
                        if(
                            (
                                (
                                    year(curdate()) - (year(`b`.`Condo_Built_Start`) + 4)
                                ) > 0
                            ),
                            'OLD',
                            'NEW'
                        ),
                        if(
                            (
                                (
                                    year(curdate()) - (year(`b`.`Condo_Built_Start`) + 3)
                                ) > 0
                            ),
                            'OLD',
                            'NEW'
                        )
                    ),
                    'OLD'
                )
            ) = 'NEW'
        ),
        ifnull(
            `b`.`Price_Average_56_1_Square`,
            `b`.`Price_Average_Resale_Square`
        ),
        ifnull(
            `b`.`Price_Average_Resale_Square`,
            `b`.`Price_Average_56_1_Square`
        )
    ) AS `Condo_Price_Per_Square_New`,
    ifnull(
        `b`.`Price_Start_Blogger_Unit`,
        `b`.`Price_Start_Day1_Unit`
    ) AS `Condo_Price_Per_Unit_New`
from
    (
        `real_condo_price` `b`
        left join `real_condo` `a` on((`a`.`Condo_Code` = `b`.`Condo_Code`))
    )
where
    (
        (`a`.`Condo_Latitude` is not null)
        and (`a`.`Condo_Longitude` is not null)
        and (`a`.`Condo_Status` = 1)
    )
order by
    `a`.`Condo_Code`;


CREATE OR REPLACE VIEW source_full_template_factsheet_view AS 
SELECT cpc.Condo_Code as Condo_Code,
        nun(Station) as Station,
        nun(rc.Road_Name) as Road_Name, -- ถ้า null จะเป็น "-"
        if(rc.District_ID is not null,
            nun(td.name_th),'-') as District_Name, -- ถ้ามี District_ID ให้เช็ค name_th ถ้า null จะเป็น "-"
        if(rc.RealDistrict_Code is not null,
            nun(rd.District_Name),'-') as Real_District, -- ถ้ามี RealDistrict_Code ให้เช็ค District_Name ถ้า null จะเป็น "-"
        nun(tp.name_th) as Province, -- ถ้า null จะเป็น "-"
		ifnull(bk(year(rcp.Price_Average_56_1_Square_Date)),null) as Price_Average_Square_Date, -- เอาปีมาใส่วงเล็บ
        nun(bath(format(round(rcp.Price_Average_56_1_Square,-3),0))) as Price_Average_Square, -- เอาราคามาปัดหลักพันแล้วใส่หน่วย ถ้า null จะเป็น "-"
        ifnull(bk(year(rcp.Price_Average_Resale_Square_Date)),null) as Price_Average_Resale_Square_Date, -- เอาปีมาใส่วงเล็บ
        nun(bath(format(round(rcp.Price_Average_Resale_Square,-3),0))) as Price_Average_Resale_Square, -- เอาราคามาปัดหลักพันแล้วใส่หน่วย ถ้า null จะเป็น "-"
        if(rcp.Price_Start_Blogger_Square is not null,
            ifnull(bk(year(rcp.Price_Start_Blogger_Square_Date)),null), -- ถ้ามีราคา เอาปีมาใส่วงเล็บ
			if(rcp.Price_Start_Day1_Square is not null,
                    ifnull(bk(year(rcp.Price_Start_Day1_Square_Date)),null),null)) as Price_Start_Square_Date, -- ถ้ามีราคา เอาปีมาใส่วงเล็บ
        ifnull(bath(format(round(rcp.Price_Start_Blogger_Square,-3),0)),
            nun(bath(format(round(rcp.Price_Start_Day1_Square,-3),0)))) as Price_Start_Square, -- เอาราคามาปัดหลักพันแล้วใส่หน่วย ถ้าไม่มีราคา blogger ใช้ราคา day1
        if(cpc.Condo_Price_Per_Unit_Text='','ราคาเริ่มต้น / ยูนิต',concat(cpc.Condo_Price_Per_Unit_Text,' / ยูนิต')) as Condo_Price_Per_Unit_Text, -- ถ้าไม่มีคำเดิมใช้ "ราคาเริ่มต้น / ยูนิต"
        ifnull(bk(year(cpc.Condo_Price_Per_Unit_Date)),null) as Price_Start_Unit_Date, -- เอาปีมาใส่วงเล็บ
        nun(concat(round((cpc.Condo_Price_Per_Unit/1000000),2),' ลบ.')) as Price_Start_Unit, -- หารล้าน ใส่หน่วย
        nun(concat(rcp.Condo_Common_Fee,' บ./ตร.ม./เดือน')) as Common_Fee,
        ifnull(cpc.Condo_Built_Text,'ปีที่แล้วเสร็จ') as Condo_Built_Text,
        nun(cpc.Condo_Built_Date) as Condo_Built_Date, -- ถ้า null จะเป็น "-"
        nun(concat(format(rc.Condo_TotalRai,2),' ไร่')) as Land,
        nun(rc.Condo_Building) as Condo_Building, -- ถ้า null จะเป็น "-"
        nun(concat(rc.Condo_TotalUnit,' ยูนิต')) as Condo_Total_Unit, -- ใส่หน่วย ถ้า null จะเป็น "-"
        if(cpc.Condo_Sold_Status_Show_Value = 'RESALE','RESALE',
            nun(concat(format((cpc.Condo_Sold_Status_Show_Value*100),0),'% SOLD'))) as Condo_Sold_Status_Show_Value,
        nun(STU_Size) as STU_Size, -- ถ้า min = max จะโชว์เลขเดียวพร้อมหน่วยและปัด
        nun(1BED_Size) as 1BED_Size,
        nun(2BED_Size) as 2BED_Size,
        nun(3BED_Size) as 3BED_Size,
        nun(4BED_Size) as 4BED_Size,
        nun(concat(rcft.Parking_Amount,' คัน')) as Parking_Amount,
        if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'Y'),'ที่จอดรถแบบวนจอด, อัตโนมัติ',
            if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'N'),'ที่จอดรถอัตโนมัติ',
                if((rcft.Auto_Parking_Status = 'N' and rcft.Manual_Parking_Status = 'Y'),'ที่จอดรถแบบวนจอด',
                    if((rcft.Auto_Parking_Status = 'N' and rcft.Parking_Amount is not null),'ที่จอดรถแบบวนจอด',
                        if(rcft.Manual_Parking_Status = 'Y','ที่จอดรถแบบวนจอด',
                            if(rcft.Auto_Parking_Status = 'Y','ที่จอดรถอัตโนมัติ',
                                if(rcft.Parking_Amount is not null,'ที่จอดรถแบบวนจอด','ที่จอดรถแบบวนจอด, อัตโนมัติ'))))))) as Parking_Text, -- ถ้า status ชัดเจนก็ตามนั้น ถ้าไม่มีั status แต่มีจำนวนที่จอดกำหนดให้เป็นที่จอดรถทั่วไป
        if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'Y'),
                ifnull(concat(rcft.Manual_Parking_Amount,' + ',rcft.Auto_Parking_Amount,' คัน'),
                ifnull(concat(rcft.Manual_Parking_Amount,' + ',rcft.Parking_Amount-rcft.Manual_Parking_Amount,' คัน'),
                ifnull(concat(rcft.Parking_Amount-rcft.Auto_Parking_Amount,' + ',rcft.Auto_Parking_Amount,' คัน'),
                nun(concat(rcft.Parking_Amount,' คัน'))))),
                    if((rcft.Auto_Parking_Status = 'Y' and rcft.Manual_Parking_Status = 'N'),
                        ifnull(concat(rcft.Auto_Parking_Amount,' คัน'),
                        nun(concat(rcft.Parking_Amount,' คัน'))),
                            if((rcft.Auto_Parking_Status = 'N' and rcft.Manual_Parking_Status = 'Y'),
                                ifnull(concat(rcft.Manual_Parking_Amount,' คัน'),
                                nun(concat(rcft.Parking_Amount,' คัน'))),
                                    if((rcft.Auto_Parking_Status = 'N' and rcft.Parking_Amount is not null),
                                        ifnull(concat(rcft.Manual_Parking_Amount,' คัน'),
                                        nun(concat(rcft.Parking_Amount,' คัน'))),
                                            if(rcft.Manual_Parking_Status = 'Y',
                                                ifnull(concat(rcft.Manual_Parking_Amount,' คัน'),
                                                nun(concat(rcft.Parking_Amount,' คัน'))),
                                                    if(rcft.Auto_Parking_Status = 'Y',
                                                        ifnull(concat(rcft.Auto_Parking_Amount,' คัน'),
                                                        nun(concat(rcft.Parking_Amount,' คัน'))),
                                                            if(rcft.Parking_Amount is not null,
                                                                nun(concat(rcft.Parking_Amount,' คัน')),'-'))))))) as Parking_Type_Amount,
        nun(concat(format(((rcft.Parking_Amount/rc.Condo_TotalUnit)*100),0),' %')) as Parking_Per_Unit,
        nun(concat(format(((rcft.Parking_Amount)/if(((ifnull(rcft.STU_Amount,0)*1)
                                                        +(ifnull(rcft.1BR_Amount,0)*1)
                                                            +(ifnull(rcft.2BR_Amount,0)*2)
                                                                +(ifnull(rcft.3BR_Amount,0)*3)
                                                                    +(ifnull(rcft.4BR_Amount,0)*4))>0,
                                                        ((ifnull(rcft.STU_Amount,0)*1)
                                                            +(ifnull(rcft.1BR_Amount,0)*1)
                                                                +(ifnull(rcft.2BR_Amount,0)*2)
                                                                    +(ifnull(rcft.3BR_Amount,0)*3)
                                                                        +(ifnull(rcft.4BR_Amount,0)*4)),null)*100),0),'%')) as Parking_Per_BedRoom, -- ห้ามตัวส่วนเป็น 0
        nun(bath(rcft.Condo_Fund_Fee)) as Condo_Fund_Fee,
        if((rcft.Passenger_Lift_Amount and rcft.Service_Lift_Amount)>0,'ลิฟท์โดยสาร, Service',
                    if(rcft.Passenger_Lift_Amount > 0,'ลิฟท์โดยสาร',
                        if(rcft.Service_Lift_Amount > 0,'ลิฟท์ Service','ลิฟท์โดยสาร, Service'))) as Lift_Type_Text,
        if((rcft.Passenger_Lift_Amount and rcft.Service_Lift_Amount)>0,
                    nun(concat(rcft.Passenger_Lift_Amount,', ',rcft.Service_Lift_Amount,' ชุด')),
                        if(rcft.Passenger_Lift_Amount > 0,
                            nun(concat(rcft.Passenger_Lift_Amount,' ชุด')),
                                if(rcft.Service_Lift_Amount > 0,
                                    nun(concat(rcft.Service_Lift_Amount,' ชุด')),'-'))) as Lift_Type_Amount,
        nun(concat('1 : ',format(rc.Condo_TotalUnit/if(rcft.Passenger_Lift_Amount>0,rcft.Passenger_Lift_Amount,null),0))) as Passanger_Lift_Unit_Ratio,
        if((rcft.Private_Lift_Status = 'Y' and rcft.LockElevator_Status = 'Y' and rcft.UnLockElevator_Status = 'Y'),'ส่วนตัว, ล็อคชั้น, ไม่ล็อคชั้น',
            if((rcft.Private_Lift_Status = 'Y' and rcft.LockElevator_Status = 'Y'),'ส่วนตัว, ล็อคชั้น',
            if((rcft.Private_Lift_Status = 'Y' and rcft.UnLockElevator_Status = 'Y'),'ส่วนตัว, ไม่ล็อคชั้น',
            if((rcft.LockElevator_Status = 'Y' and rcft.UnLockElevator_Status = 'Y'),'ล็อคชั้น, ไม่ล็อคชั้น',
                if(rcft.Private_Lift_Status = 'Y','ส่วนตัว',
                if(rcft.LockElevator_Status = 'Y','ล็อคชั้น',
                if(rcft.UnLockElevator_Status = 'Y','ไม่ล็อคชั้น','-'))))))) as Lift_Type,
        ifnull(concat('สระว่ายน้ำ ',rcft.Pool_Name),'สระว่ายน้ำ') as Pool_Text,
        ifnull(concat(rcft.Pool_Width,' x ',rcft.Pool_Length,' ม.'),
                    ifnull(concat(rcft.Pool_Width,' ม.'),
                        nun(concat(rcft.Pool_Length,' ม.')))) as Pool_Size,
        ifnull(concat('สระว่ายน้ำ ',rcft.Pool_2_Name),
            if(rcft.Pool_2_Width is not null or rcft.Pool_2_Length is not null,'สระว่ายน้ำ',null)) as Pool_2_Text,
        ifnull(concat(rcft.Pool_2_Width,' x ',rcft.Pool_2_Length,' ม.'),
                    ifnull(concat(rcft.Pool_2_Width,' ม.'),
                        ifnull(concat(rcft.Pool_2_Length,' ม.'),null))) as Pool_2_Size,
        if(if(ifnull(rcft.Parking_Amount,0)+ifnull(rcft.Condo_Fund_Fee,0)>0,1,0) + 
            if(if(ifnull(rcft.Passenger_Lift_Amount,0)+ifnull(rcft.Service_Lift_Amount,0)>0,1,0) + 
                if(ifnull(rcft.Pool_Width,0)+ifnull(rcft.Pool_Length,0)>0,1,0)>0,1,0)=2,1,0) as FactSheet_Status
FROM all_condo_price_calculate_view as cpc
inner join real_condo_price as rcp on cpc.Condo_Code = rcp.Condo_Code
inner join real_condo as rc on cpc.Condo_Code = rc.Condo_Code
inner join real_condo_full_template as rcft on cpc.Condo_Code = rcft.Condo_Code
left join thailand_district as td on rc.District_ID = td.district_code
left join real_yarn_main as rd on rc.RealDistrict_Code = rd.District_Code
inner join thailand_province as tp on rc.Province_ID = tp.province_code
-- ถ้า min = max จะโชว์เลขเดียวพร้อมหน่วยและปัด
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS STU_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 1
            GROUP BY Condo_Code) as size1
on cpc.Condo_Code = size1.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 1BED_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 2
            GROUP BY Condo_Code) as size2
on cpc.Condo_Code = size2.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 2BED_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 4
            GROUP BY Condo_Code) as size3
on cpc.Condo_Code = size3.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 3BED_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 5
            GROUP BY Condo_Code) as size4
on cpc.Condo_Code = size4.Condo_Code
left join (SELECT Condo_Code
            ,   if(roundsize(min(size))=roundsize(max(size)),unitsqm(roundsize(min(Size))),
                    unitsqm(CONCAT(roundsize(min(Size)), '-', roundsize(max(Size))))) AS 4BED_Size
            FROM full_template_unit_type
            where Unit_Type_Status <> 2
            and Room_Type_ID = 6
            GROUP BY Condo_Code) as size5
on cpc.Condo_Code = size5.Condo_Code
-- หาสถานีที่ใกล้ที่สุดในแต่ละโครงการ
left join ( select Condo_Code,Station_THName_Display as Station
            from (  select cv.Condo_Code
                            , ms.Station_THName_Display
                            , ROW_NUMBER() OVER (PARTITION BY cv.Condo_Code ORDER BY cv.Total_Point) AS RowNum
                    from condo_around_station_view as cv 
                    inner join mass_transit_station as ms on cv.Station_Code = ms.Station_Code
                    order by cv.Condo_Code) a
            where a.RowNum = 1) as sub_station
on cpc.Condo_Code = sub_station.Condo_Code
order by cpc.Condo_Code;

-- -----------------------------------------------------
-- Table `full_template_factsheet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `full_template_factsheet` (
    `Condo_Code` VARCHAR(10) NOT NULL,
    `Station` VARCHAR(200) NOT NULL,
    `Road_Name` VARCHAR(150) NOT NULL,
    `District_Name` VARCHAR(150) NOT NULL,
    `Real_District` VARCHAR(150) NOT NULL,
    `Province` VARCHAR(150) NOT NULL,
    `Price_Average_Square_Date` VARCHAR(6) NULL,
    `Price_Average_Square` VARCHAR(50) NOT NULL,
    `Price_Average_Resale_Square_Date` VARCHAR(6) NULL,
    `Price_Average_Resale_Square` VARCHAR(50) NOT NULL,
    `Price_Start_Square_Date` VARCHAR(6) NULL,
    `Price_Start_Square` VARCHAR(50) NOT NULL,
    `Condo_Price_Per_Unit_Text` VARCHAR(60) NOT NULL,
    `Price_Start_Unit_Date` VARCHAR(6) NULL,
    `Price_Start_Unit` VARCHAR(20) NOT NULL,
    `Common_Fee` VARCHAR(50) NOT NULL,
    `Condo_Built_Text` VARCHAR(60) NOT NULL,
    `Condo_Built_Date` VARCHAR(4) NOT NULL,
    `Land` VARCHAR(20) NOT NULL,
    `Condo_Building` VARCHAR(250) NOT NULL,
    `Condo_Total_Unit` VARCHAR(30) NOT NULL,
    `Condo_Sold_Status_Show_Value` VARCHAR(10) NOT NULL,
    `STU_Size` VARCHAR(50) NOT NULL,
    `1BED_Size` VARCHAR(50) NOT NULL,
    `2BED_Size` VARCHAR(50) NOT NULL,
    `3BED_Size` VARCHAR(50) NOT NULL,
    `4BED_Size` VARCHAR(50) NOT NULL,
    `Parking_Amount` VARCHAR(20) NOT NULL,
    `Parking_Text` VARCHAR(80) NOT NULL,
    `Parking_Type_Amount` VARCHAR(100) NOT NULL,
    `Parking_Per_Unit` VARCHAR(6) NOT NULL,
    `Parking_Per_BedRoom` VARCHAR(6) NOT NULL,
    `Condo_Fund_Fee` VARCHAR(30) NOT NULL,
    `Lift_Type_Text` VARCHAR(50) NOT NULL,
    `Lift_Type_Amount` VARCHAR(20) NOT NULL,
    `Passanger_Lift_Unit_Ratio` VARCHAR(10) NOT NULL,
    `Lift_Type` VARCHAR(60) NOT NULL,
    `Pool_Text` VARCHAR(250) NOT NULL,
    `Pool_Size` VARCHAR(20) NOT NULL,
    `Pool_2_Text` VARCHAR(250) NULL,
    `Pool_2_Size` VARCHAR(20) NULL,
    `FactSheet_Status` INT(1) UNSIGNED NOT NULL,
    PRIMARY KEY (`Condo_Code`))
ENGINE = InnoDB;

-- truncateInsert_full_template_factsheet
DROP PROCEDURE IF EXISTS truncateInsert_full_template_factsheet;
DELIMITER //

CREATE PROCEDURE truncateInsert_full_template_factsheet ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_rows INT DEFAULT 0;
    DECLARE v_name VARCHAR(250) DEFAULT NULL;
    DECLARE v_name1 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name2 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name3 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name4 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name5 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name6 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name7 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name8 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name9 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name10 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name11 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name12 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name13 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name14 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name15 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name16 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name17 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name18 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name19 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name20 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name21 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name22 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name23 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name24 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name25 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name26 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name27 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name28 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name29 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name30 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name31 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name32 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name33 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name34 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name35 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name36 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name37 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name38 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name39 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name40 VARCHAR(250) DEFAULT NULL;
    DECLARE v_name41 VARCHAR(250) DEFAULT NULL;

    DECLARE proc_name       VARCHAR(50) DEFAULT 'truncateInsert_full_template_factsheet';
    DECLARE code            VARCHAR(10) DEFAULT '00000';
    DECLARE msg             TEXT;
    DECLARE rowCount        INTEGER     DEFAULT 0;
    DECLARE nrows           INTEGER     DEFAULT 0;
    DECLARE errorcheck      BOOLEAN  DEFAULT 1;

    -- Declare a variable to indicate when there are no more records
    DECLARE done INT DEFAULT FALSE;

    -- Declare the cursor for the view
    DECLARE cur CURSOR FOR SELECT * FROM source_full_template_factsheet_view;
    -- more columns here as needed

    -- Declare a continue handler to handle errors
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
            SET msg = CONCAT(msg,' AT ',v_name);
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(1, code, msg, proc_name);
        set errorcheck = 0;
        -- Do nothing and continue with the next record
    END;

    -- Declare a continue handler to handle when there are no more records
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE    full_template_factsheet;

    -- Open the cursor
    OPEN cur;

    -- Start the loop
    read_loop: LOOP
        -- Fetch the next record from the cursor into the variables
        FETCH cur INTO v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41;
        -- more variables here as needed

        -- Check if there are no more records
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO
            full_template_factsheet(
                `Condo_Code`,
                `Station`,    
                `Road_Name`,
                `District_Name`,
                `Real_District`,
                `Province`,
                `Price_Average_Square_Date`,
                `Price_Average_Square`,
                `Price_Average_Resale_Square_Date`,
                `Price_Average_Resale_Square`,
                `Price_Start_Square_Date`,
                `Price_Start_Square`,
                `Condo_Price_Per_Unit_Text`,
                `Price_Start_Unit_Date`,
                `Price_Start_Unit`,
                `Common_Fee`,
                `Condo_Built_Text`,
                `Condo_Built_Date`,
                `Land`,
                `Condo_Building`,
                `Condo_Total_Unit`,
                `Condo_Sold_Status_Show_Value`,
                `STU_Size`,
                `1BED_Size`,
                `2BED_Size`,
                `3BED_Size`,
                `4BED_Size`,
                `Parking_Amount`,
                `Parking_Text`,
                `Parking_Type_Amount`,
                `Parking_Per_Unit`,
                `Parking_Per_BedRoom`,
                `Condo_Fund_Fee`,
                `Lift_Type_Text`,
                `Lift_Type_Amount`,
                `Passanger_Lift_Unit_Ratio`,
                `Lift_Type`,
                `Pool_Text`,
                `Pool_Size`,
                `Pool_2_Text`,
                `Pool_2_Size`,
                `FactSheet_Status`
                )
        VALUES(v_name,v_name1,v_name2,v_name3,v_name4,v_name5,v_name6,v_name7,v_name8,v_name9,v_name10,v_name11,v_name12,v_name13,v_name14,v_name15,v_name16,v_name17,v_name18,v_name19,v_name20,v_name21,v_name22,v_name23,v_name24,v_name25,v_name26,v_name27,v_name28,v_name29,v_name30,v_name31,v_name32,v_name33,v_name34,v_name35,v_name36,v_name37,v_name38,v_name39,v_name40,v_name41);
        -- more columns and variables here as needed
        GET DIAGNOSTICS nrows = ROW_COUNT;
        SET total_rows = total_rows + nrows;
        SET i = i + 1;
    END LOOP;

    if errorcheck then
        SET code    = '00000';
        SET msg     = CONCAT(total_rows,' rows inserted.');
        INSERT INTO realist_log (Type, SQL_State, Message, Location) VALUES(0,code , msg, proc_name);
    end if;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;