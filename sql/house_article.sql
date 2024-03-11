SELECT wp.ID, wp.post_date, wp.post_title, concat('https://thelist.group/realist/blog/', wp.post_name) as Link
, if(h.object_id is not null, 'TRUE', 'FALSE') as 'House'
, if(sd.object_id is not null, 'TRUE', 'FALSE') as 'Single Detached House'
, if(th.object_id is not null, 'TRUE', 'FALSE') as 'Town Home'
, if(ho.object_id is not null, 'TRUE', 'FALSE') as 'Home Office'
, if(sh.object_id is not null, 'TRUE', 'FALSE') as 'Shop House'
, if(dd.object_id is not null, 'TRUE', 'FALSE') as 'Semi Detached House'
FROM `wp_posts` wp
left join wp_term_relationships wpr on wp.ID = wpr.object_id
left join wp_terms wt on wpr.term_taxonomy_id = wt.term_id
left join (select object_id, term_taxonomy_id from wp_term_relationships where term_taxonomy_id = 6) sd
on wp.ID = sd.object_id
left join (select object_id, term_taxonomy_id from wp_term_relationships where term_taxonomy_id = 7) th
on wp.ID = th.object_id
left join (select object_id, term_taxonomy_id from wp_term_relationships where term_taxonomy_id = 760) ho
on wp.ID = ho.object_id
left join (select object_id, term_taxonomy_id from wp_term_relationships where term_taxonomy_id = 867) sh
on wp.ID = sh.object_id
left join (select object_id, term_taxonomy_id from wp_term_relationships where term_taxonomy_id = 869) dd
on wp.ID = dd.object_id
left join (select object_id, term_taxonomy_id from wp_term_relationships where term_taxonomy_id = 972) h
on wp.ID = h.object_id
where wp.post_status = 'publish'
and wpr.term_taxonomy_id IN (6,7,156,760,867,869,972)
and wp.post_password = ''
group by wp.ID
order by wp.ID;