SELECT wp.ID, wp.post_date, wp.post_title, concat('https://thelist.group/realist/blog/', wp.post_name) as Link
, if(h.ID is not null, 'TRUE', 'FALSE') as 'House'
, if(sd.ID is not null, 'TRUE', 'FALSE') as 'Single Detached House'
, if(th.ID is not null, 'TRUE', 'FALSE') as 'Town Home'
, if(ho.ID is not null, 'TRUE', 'FALSE') as 'Home Office'
, if(sh.ID is not null, 'TRUE', 'FALSE') as 'Shop House'
, if(dd.ID is not null, 'TRUE', 'FALSE') as 'Semi Detached House'
from wp_terms wt 
left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
left join wp_posts wp on wpr.object_id = wp.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 972
            and wp.post_status = 'publish'
            and wp.post_password = '') h
on wp.ID = h.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 6
            and wp.post_status = 'publish'
            and wp.post_password = '') sd
on wp.ID = sd.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 7
            and wp.post_status = 'publish'
            and wp.post_password = '') th
on wp.ID = th.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id in (156,760)
            and wp.post_status = 'publish'
            and wp.post_password = '') ho
on wp.ID = ho.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 867
            and wp.post_status = 'publish'
            and wp.post_password = '') sh
on wp.ID = sh.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 869
            and wp.post_status = 'publish'
            and wp.post_password = '') dd
on wp.ID = dd.ID
where wp.post_status = 'publish'
and wp.post_password = ''
and wtt.term_id in (6,7,156,760,867,869,972)
group by wp.ID
order by wp.ID;


SELECT wp.ID, wp.post_date, wp.post_title, concat('https://thelist.group/realist/blog/', wp.post_name) as Link
, if(condo.ID is not null, 'TRUE', 'FALSE') as 'Condo'
, if(h.ID is not null, 'TRUE', 'FALSE') as 'House'
, if(sd.ID is not null, 'TRUE', 'FALSE') as 'Single Detached House'
, if(th.ID is not null, 'TRUE', 'FALSE') as 'Town Home'
, if(ho.ID is not null, 'TRUE', 'FALSE') as 'Home Office'
, if(sh.ID is not null, 'TRUE', 'FALSE') as 'Shop House'
, if(dd.ID is not null, 'TRUE', 'FALSE') as 'Semi Detached House'
, if(proj.ID is not null, 'TRUE', 'FALSE') as 'Project'
, if(re.ID is not null, 'TRUE', 'FALSE') as 'Project Review'
, if(pr.ID is not null, 'TRUE', 'FALSE') as 'PR News'
, if(ins.ID is not null, 'TRUE', 'FALSE') as 'Real Insight'
, if(stu.ID is not null, 'TRUE', 'FALSE') as 'Market Study'
from wp_terms wt 
left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
left join wp_posts wp on wpr.object_id = wp.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 972
            and wp.post_status = 'publish'
            and wp.post_password = '') h
on wp.ID = h.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 6
            and wp.post_status = 'publish'
            and wp.post_password = '') sd
on wp.ID = sd.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 7
            and wp.post_status = 'publish'
            and wp.post_password = '') th
on wp.ID = th.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id in (156,760)
            and wp.post_status = 'publish'
            and wp.post_password = '') ho
on wp.ID = ho.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 867
            and wp.post_status = 'publish'
            and wp.post_password = '') sh
on wp.ID = sh.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 869
            and wp.post_status = 'publish'
            and wp.post_password = '') dd
on wp.ID = dd.ID
left join (SELECT c.ID
            FROM `wp_postmeta` `a`
            left join `wp_posts` `c` on `a`.`post_id` = `c`.`ID`
            WHERE `a`.`meta_key` = 'aaa_condo'
            AND `c`.`post_status` = 'publish'
            AND `c`.`post_password` = '') condo
on wp.ID = condo.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 5
            and wp.post_status = 'publish'
            and wp.post_password = '') proj
on wp.ID = proj.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 120
            and wp.post_status = 'publish'
            and wp.post_password = '') re
on wp.ID = re.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 204
            and wp.post_status = 'publish'
            and wp.post_password = '') pr
on wp.ID = pr.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 242
            and wp.post_status = 'publish'
            and wp.post_password = '') ins
on wp.ID = ins.ID
left join (SELECT wp.ID as ID
            from wp_terms wt 
            left join wp_term_taxonomy wtt on wt.term_id = wtt.term_id 
            left join wp_term_relationships wpr on wtt.term_taxonomy_id = wpr.term_taxonomy_id 
            left join wp_posts wp on wpr.object_id = wp.ID 
            where wtt.term_id = 426
            and wp.post_status = 'publish'
            and wp.post_password = '') stu
on wp.ID = stu.ID
where wp.post_status = 'publish'
and wp.post_password = ''
and (condo.ID is not null or h.ID is not null or sd.ID is not null or th.ID is not null or ho.ID is not null or sh.ID is not null or dd.ID is not null)
group by wp.ID  
ORDER BY `wp`.`post_date` DESC  