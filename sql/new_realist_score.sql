create or replace VIEW `realist_score` AS
SELECT
    ads_base.Prop_Code AS Condo_Code,
    sum(
        if(
            (
                (
                    (
                        (
                            to_days(
                                (
                                    date(ads_base.Published_Date) + interval (ads_base.Show_Days + ads_base.Left_Days) day
                                )
                            ) - to_days(now())
                        ) * 0.005479452055
                    ) + 8
                ) < 2
            ),
            2,
            if(
                (
                    (
                        (
                            (
                                to_days(
                                    (
                                        date(ads_base.Published_Date) + interval (ads_base.Show_Days + ads_base.Left_Days) day
                                    )
                                ) - to_days(now())
                            ) * 0.005479452055
                        ) + 8
                    ) > 10
                ),
                10,
                (
                    (
                        (
                            to_days(
                                (
                                    date(ads_base.Published_Date) + interval (ads_base.Show_Days + ads_base.Left_Days) day
                                )
                            ) - to_days(now())
                        ) * 0.005479452055
                    ) + 8
                )
            )
        )
    ) AS `Realist_Score`
FROM
    ads_base
where
    ads_base.AD_Status = '1'
    and ads_base.Prop_Type = 'CD'
group by
    ads_base.Prop_Code
order by
    ads_base.Prop_Code;