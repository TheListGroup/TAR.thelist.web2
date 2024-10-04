SELECT 
  wp.ID, 
  d.user_nicename AS User_Name, 
  wp.post_date, 
  wp.post_title,
  ifnull(pm.aaa_housing,'') as aaa_housing,
  tag_type.tag_name,
  CONCAT('https://thelist.group/realist/blog/', wp.post_name) AS Link
FROM wp_posts wp
LEFT JOIN wp_users d ON wp.post_author = d.ID
left join (select post_id, group_concat(meta_value separator ', ') AS aaa_housing
          from wp_postmeta 
          where meta_key = 'aaa_housing'
          and meta_value <> ''
          group by post_id) pm
on wp.ID = pm.post_id
LEFT JOIN (select wpr.object_id, group_concat(wt.name separator ', ') as tag_name 
          from wp_term_relationships wpr
          left join wp_term_taxonomy wtt on wpr.term_taxonomy_id = wtt.term_taxonomy_id
          left join wp_terms wt on wtt.term_id = wt.term_id
          where wtt.term_id in (6,7,156,760,867,869,972)
          group by wpr.object_id) tag_type
ON wp.ID = tag_type.object_id
WHERE wp.post_status = 'publish'
AND wp.post_password = ''
and tag_type.tag_name is not null
ORDER BY wp.ID DESC;