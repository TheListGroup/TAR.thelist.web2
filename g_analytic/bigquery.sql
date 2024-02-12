SELECT user_pseudo_id, traffic_source.medium
FROM `the-list-ga-data-1687412203404.analytics_286074701.events_20231205`
where event_name = 'page_view'
and traffic_source.medium = 'organic'
and (select value.string_value from unnest(event_params) where key = "page_location") like "%realist/condo%"


-- 2023-10-25 to 2023-10-31 page_vie_per_sessiongroup_blog/condo
SELECT traffic_source.medium, count(*)
FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202310*`
where event_date between '20231025' and '20231031'
and event_name = 'page_view'
group by traffic_source.medium
order by 2 desc


-- 2023-10-25 to 2023-10-31 page_view_condo
SELECT count(*)
FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202310*`
where event_date between '20231025' and '20231031'
and event_name = 'page_view'
and (select value.string_value from unnest(event_params) where key = "page_location") like "%realist/condo/%"

-- 2023-10-25 to 2023-10-31 page_view_blog
SELECT count(*)
FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202310*`
where event_date between '20231025' and '20231031'
and event_name = 'page_view'
and (select value.string_value from unnest(event_params) where key = "page_location") like "%realist/condo/%"

-- 2023-10-25 to 2023-10-31 page_view_all
SELECT count(*)
FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202310*`
where event_date between '20231025' and '20231031'
and event_name = 'page_view'




with base as 
    (SELECT user_pseudo_id,traffic_source.medium,collected_traffic_source.manual_medium
    FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202401*`
    where event_name = 'page_view'
    order by event_timestamp),

    union_medium as (select user_pseudo_id,medium,manual_medium,if(medium in (null,'(none)'),if(manual_medium is null,null,manual_medium),medium) as cal
    from base)

select cal,count(*)
from union_medium
group by cal
order by 2 desc


with base as 
    (SELECT user_pseudo_id,traffic_source.medium,collected_traffic_source.manual_medium
    FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202401*`
    where event_name = 'page_view'
    order by event_timestamp),

    union_medium as (select user_pseudo_id,medium,manual_medium,if(manual_medium is null,if(medium in (null,'(none)'),null,medium),manual_medium) as cal
    from base)

select cal,count(*)
from union_medium
group by cal
order by 2 desc



with base as 
    (SELECT user_pseudo_id,traffic_source.medium,collected_traffic_source.manual_medium
    FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202310*`
    where event_name = 'page_view'
    and event_date between '20231025' and '20231031'
    order by event_timestamp),

    union_medium as (select user_pseudo_id,medium,manual_medium,if(medium in (null,'(none)'),if(manual_medium is null,null,manual_medium),medium) as cal
    from base)

select cal,count(*)
from union_medium
group by cal
order by 2 desc

with base as 
    (SELECT user_pseudo_id,traffic_source.medium,collected_traffic_source.manual_medium
    FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202310*`
    where event_name = 'page_view'
    and event_date between '20231025' and '20231031'
    order by event_timestamp),

    union_medium as (select user_pseudo_id,medium,manual_medium,if(manual_medium is null,if(medium in (null,'(none)'),null,medium),manual_medium) as cal
    from base)

select cal,count(*)
from union_medium
group by cal
order by 2 desc





with base as 
    (SELECT user_pseudo_id,traffic_source.medium,collected_traffic_source.manual_medium
    FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202402*`
    where event_name = 'page_view'
    and event_date between '20240201' and '20240205'
    and (select value.string_value from unnest(event_params) where key = "page_location") like "%realist/condo/%"
    order by event_timestamp),
    
    union_medium as (select user_pseudo_id,medium,manual_medium,if(medium = 'cpc',medium,if(medium = 'organic',medium,if(manual_medium = 'organic',manual_medium,null))) as cal
    from base)

select cal,count(*)
from union_medium
group by cal
order by 2 desc




with base as 
    (SELECT user_pseudo_id,traffic_source.source as s,collected_traffic_source.manual_source
    FROM `the-list-ga-data-1687412203404.analytics_286074701.events_202402*`
    where event_name = 'page_view'
    and event_date between '20240201' and '20240205'
    and (select value.string_value from unnest(event_params) where key = "page_location") like "%realist/condo/%"
    order by event_timestamp),
    
    union_medium as (select user_pseudo_id,s,manual_source,if(s = '(direct)',s,if(s is not null,s,manual_source)) as cal
    from base)

select cal,count(*)
from union_medium
group by cal
order by 2 desc