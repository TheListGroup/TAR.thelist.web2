SELECT *
FROM `housing`
where Housing_Status = '1'
and (Housing_Price_Min >= 60000000 or Housing_Price_Max >= 60000000)
and year(Housing_Built_Start) BETWEEN 2019 and 2024