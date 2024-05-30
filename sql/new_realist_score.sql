create or replace VIEW `realist_score` AS
select Condo_Code
    , sum(Score_cal) as Realist_Score
from (SELECT Prop_Code AS Condo_Code
        , if(AD_Type = 'Auto', Auto_AD_Budget, Manual_AD_Day * 7500) as AD_Budget
        , least(if(AD_Type = 'Auto', Auto_AD_Budget / 7500, Manual_AD_Day), 10) as Start_Score
        , to_days(date(Published_Date)) - to_days(now()) as interval_day
        , GREATEST(LEAST(if(AD_Type = 'Auto', Auto_AD_Budget / 7500, Manual_AD_Day), 10) - ((DATEDIFF(CURDATE(), Published_Date) / 365) * 0.2 
            * LEAST(if(AD_Type = 'Auto', Auto_AD_Budget / 7500, Manual_AD_Day), 10))
            , 0.2 * LEAST(if(AD_Type = 'Auto', Auto_AD_Budget / 7500, Manual_AD_Day), 10)) as Score_cal
    FROM ads_base
    WHERE ((ads_base.AD_Status = '1') AND (ads_base.Prop_Type = 'CD'))
    ORDER BY ads_base.Prop_Code ASC) cal
group by Condo_Code
ORDER BY Condo_Code ASC;