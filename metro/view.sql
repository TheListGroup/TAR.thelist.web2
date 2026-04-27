create or replace view prof_url as
SELECT b.Prof_ID, c.Logo_URL, if(d.Prof_ID is not null, 1, 0) as cover, count(a.Proj_ID) as count_project, if(c.Logo_URL is not null and d.Prof_ID is not null and count(a.Proj_ID) >= 1,1,0) as Url_Status
from proj_prof_relationship a
join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID and b.Relationship_Status = '1'
join professionals c on b.Prof_ID = c.ID and c.Prof_Status = '1'
left join (select Prof_ID 
                        from prof_cover 
                        where Image_Status = '1'
                        group by Prof_ID) d
on c.ID = d.Prof_ID
group by b.Prof_ID;

create or replace view prod_url as
SELECT DISTINCT a.ID, if(a.Content is not null, 1, 0) as Content, if(b.Entity_ID is not null, 1, 0) as cover, if(a.Content is not null and b.Entity_ID is not null, 1, 0) as Url_Status
from product_entities a
left join product_cover b on a.ID = b.Entity_ID and b.Image_Status = '1';