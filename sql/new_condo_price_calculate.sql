CREATE OR REPLACE VIEW `source_condo_price_calculate_view` AS
SELECT
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
        (`b`.`Price_Average_56_1_Square` is null),
        if(
            (`b`.`Price_Average_Resale_Square` is null),
            if(
                (`b`.`Price_Start_Blogger_Square` is null),
                if(
                    (`b`.`Price_Start_Day1_Square` is null),
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
            (`b`.`Price_Average_56_1_Square` is null),
            if(
                (`b`.`Price_Average_Resale_Square` is null),
                if(
                    (`b`.`Price_Start_Blogger_Square` is null),
                    if(
                        (`b`.`Price_Start_Day1_Square` is null),
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
            (`b`.`Price_Average_Resale_Square` is null),
            if(
                (`b`.`Price_Average_56_1_Square` is null),
                if(
                    (`b`.`Price_Start_Blogger_Square` is null),
                    if(
                        (`b`.`Price_Start_Day1_Square` is null),
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
        (`b`.`Price_Start_Blogger_Unit` is null),
        if(
            (`b`.`Price_Start_Day1_Unit` is null),
            if(
                (`b`.`Price_Start_56_1_Unit` is null),
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
    if((`b`.`Price_Start_Blogger_Unit` is null),
        if((`b`.`Price_Start_Day1_Unit` is null),
            `b`.`Price_Start_56_1_Unit_Date`,
            `b`.`Price_Start_Day1_Unit_Date`),
        `b`.`Price_Start_Blogger_Unit_Date`
    ) AS `Condo_Price_Per_Unit_Date`,
    if(
        (`b`.`Condo_Sold_Status_56_1_Percent` is null),
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
        (`b`.`Condo_Built_Finished` is null),
        if(
            (`b`.`Condo_Built_Start` is null),
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
        (`b`.`Condo_Built_Finished` is null),
        if(
            (`b`.`Condo_Built_Start` is null),
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
            ) using utf8mb3
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
FROM
    (
        `real_condo_price` `b`
        left join `real_condo` `a` on((`a`.`Condo_Code` = `b`.`Condo_Code`))
    )
WHERE
    (
        (`a`.`Condo_Latitude` <> '')
        AND (`a`.`Condo_Longitude` <> '')
        AND (`a`.`Province_ID` in (10, 11, 12, 13, 73, 74))
        AND (`a`.`Condo_Status` = 1)
        and a.Condo_Code = 'CD1005'
    )
ORDER BY
    `a`.`Condo_Code` ASC;


SELECT
    `a`.`Condo_Code` AS `Condo_Code`,
    if(`b`.`Price_Average_56_1_Square` is null,
        if(`b`.`Price_Average_Resale_Square` is null,
            if(`b`.`Price_Start_Blogger_Square` is null,
                if(`b`.`Price_Start_Day1_Square` is null,
                    '',
                    'ราคาเริ่มต้น'),
                'ราคาเริ่มต้น'),
            'ราคาเฉลี่ย'),
        'ราคาเฉลี่ย') AS `Condo_Age_Status_Square_Text`,
    if((if(`b`.`Condo_Built_Finished` is not null,
                if((year(curdate()) - (year(`b`.`Condo_Built_Finished`) + 1)) > 0,
                    'OLD',
                    'NEW'),
                if(`b`.`Condo_Built_Start` is not null,
                    if(((`a`.`Condo_HighRise` = 1) or ((`a`.`Condo_HighRise` = 0) and (`a`.`Condo_LowRise` = 0))),
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
            (`b`.`Price_Average_56_1_Square` is null),
            if(
                (`b`.`Price_Average_Resale_Square` is null),
                if(
                    (`b`.`Price_Start_Blogger_Square` is null),
                    if(
                        (`b`.`Price_Start_Day1_Square` is null),
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
            (`b`.`Price_Average_Resale_Square` is null),
            if(
                (`b`.`Price_Average_56_1_Square` is null),
                if(
                    (`b`.`Price_Start_Blogger_Square` is null),
                    if(
                        (`b`.`Price_Start_Day1_Square` is null),
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
        (`b`.`Price_Start_Blogger_Unit` is null),
        if(
            (`b`.`Price_Start_Day1_Unit` is null),
            if(
                (`b`.`Price_Start_56_1_Unit` is null),
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
    if((`b`.`Price_Start_Blogger_Unit` is null),
        if((`b`.`Price_Start_Day1_Unit` is null),
            `b`.`Price_Start_56_1_Unit_Date`,
            `b`.`Price_Start_Day1_Unit_Date`),
        `b`.`Price_Start_Blogger_Unit_Date`
    ) AS `Condo_Price_Per_Unit_Date`
FROM
    (
        `real_condo_price` `b`
        left join `real_condo` `a` on((`a`.`Condo_Code` = `b`.`Condo_Code`))
    )
WHERE
    (
        (`a`.`Condo_Latitude` <> '')
        AND (`a`.`Condo_Longitude` <> '')
        AND (`a`.`Province_ID` in (10, 11, 12, 13, 73, 74))
        AND (`a`.`Condo_Status` = 1)
        and a.Condo_Code = 'CD1005'
    )
ORDER BY
    `a`.`Condo_Code` ASC;