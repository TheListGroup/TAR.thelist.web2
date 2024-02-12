-- view ใช้ทำเรื่อง shortcut (ทุก element ที่มีรูป)
CREATE OR REPLACE VIEW full_template_section_shortcut_raw_view AS
select fte.Condo_Code
    ,   fts.Section_ID
    ,   fts.Section_Name    
	,	ftc.Category_Order
	,   ftc.Category_ID
	,   ftc.Category_Name
	,   ftc.Category_Icon
	,	fte.Display_Order_in_Section
	,	fte.Element_ID
	,	fte.Element_Name
	,	fti.Display_Order_in_Element
	,	fti.Image_Id
	,	fti.Image_URL
	from full_template_element AS fte
		inner join full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
		inner join full_template_section as fts on ftc.Section_ID = fts.Section_ID
		inner join full_template_image as fti on fte.Element_ID = fti.Element_ID
	where fte.Element_Status = 1
	and ftc.Category_Status = 1
	and fti.Image_Status = 1
    and fts.Section_Status = 1
	ORDER BY fte.Condo_Code, fts.Section_ID,ftc.Category_Order, fte.Display_Order_in_Section, fti.Display_Order_in_Element;


-- source_full_template_section_shortcut_view
	-- ชื่อ section, รูปแรกของ element แรก
CREATE OR REPLACE VIEW source_full_template_section_shortcut_view AS
select Condo_Code
	,	Section_1_shortcut_Name
	,	Overview_Image
	,	Section_2_shortcut_Name
	,	Exterior_Image
	,	Section_3_shortcut_Name
	,	Show_Unit_Image
	,	if(Spec_Image is not null,'Specification',null) as Section_4_shortcut_Name 
	,	Spec_Image
	,	Section_5_shortcut_Name
	,	Facilities_Image
	,	if(Article_Image is null,null,'Article') as Section_Article_shortcut_Name 
	,	if(File_Type = 'jpg'
			, replace(Article_Image,'.jpg','.webp')
			, if(File_Type = 'png'
				, replace(Article_Image,'.png','.webp')
				, if(File_Type = 'jpeg'
					, replace(Article_Image,'.jpeg','.webp')
					, Article_Image))) as Article_Image
	,	if(if(Overview_Image is not null,1,0) + if(Exterior_Image is not null,1,0) + if(Show_Unit_Image is not null,1,0) 
		+ if(Facilities_Image is not null,1,0) + if(Article_Image is not null,1,0) + if(Spec_Image is not null,1,0)>=3,1,0) as Status
from (select Condo_Code 
		from full_template_section_shortcut_raw_view
		GROUP BY Condo_Code) as main
left join ( SELECT Condo_Code AS Condo_Code1,
				Image_URL as Overview_Image,
				Section_Name as Section_1_shortcut_Name
			FROM (  SELECT Condo_Code
					, Section_Name
					, Image_URL
					, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
					FROM full_template_section_shortcut_raw_view
					where Section_ID = 1) sub
			WHERE RowNum = 1) as overview
on main.Condo_Code = overview.Condo_Code1
left join ( SELECT Condo_Code AS Condo_Code2,
				Image_URL as Exterior_Image,
				Section_Name as Section_2_shortcut_Name
			FROM (	SELECT Condo_Code
						, Section_Name
						, Image_URL
						, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
					FROM full_template_section_shortcut_raw_view
					where Section_ID = 2) sub
			WHERE RowNum = 1) as exterior
on main.Condo_Code = exterior.Condo_Code2
left join (	SELECT Condo_Code AS Condo_Code3,
				Image_URL as Show_Unit_Image,
				Section_Name as Section_3_shortcut_Name
			FROM (	SELECT Condo_Code
						, Section_Name
						, Image_URL
						, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
					FROM full_template_section_shortcut_raw_view
					where Section_ID = 3) sub
			WHERE RowNum = 1) as show_unit
on main.Condo_Code = show_unit.Condo_Code3
left join (	SELECT Condo_Code AS Condo_Code5,
				Image_URL as Facilities_Image,
				Section_Name as Section_5_shortcut_Name
			FROM (	SELECT Condo_Code
						, Section_Name
						, Image_URL
						, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
					FROM full_template_section_shortcut_raw_view
					where Section_ID = 5) sub
			WHERE RowNum = 1) as facilities
on main.Condo_Code = facilities.Condo_Code5
left join ( select Condo_Code as Condo_Code6
				, meta_value as Article_Image
				, REVERSE(SUBSTRING_INDEX(REVERSE(meta_value), '.', 1)) AS File_Type
			from (	select ss.Condo_Code
					,	wm.meta_value
					,	ROW_NUMBER() OVER (PARTITION BY ss.Condo_Code ORDER BY am.post_date desc) AS RowNum
					from full_template_section_shortcut_raw_view ss
					left join article_condo_fetch_for_map am on ss.Condo_Code = am.Condo_Code
					left join wp_postmeta wm on am.ID = wm.post_id
					where wm.meta_key = '_yoast_wpseo_opengraph-image'
					order by ss.Condo_Code ) a
			where RowNum = 1) as article
on main.Condo_Code = article.Condo_Code6
left join (select Condo_Code as Condo_Code4, 
					if(Image_URL_2 is not null,ifnull(Image_URL_1,ifnull(Image_URL_2,null)),null) as Spec_Image
			from (select Condo_Code 
					from full_template_section_shortcut_raw_view
					WHERE Section_ID = 4
					group by Condo_Code) as spec_main
			LEFT JOIN (SELECT Condo_Code AS Condo_Code4_1
								, Image_URL AS Image_URL_1 
						FROM (SELECT Condo_Code
								, Section_ID
								, Image_URL
								, Display_Order_in_Section
								, Display_Order_in_Element
								, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
								FROM full_template_section_shortcut_raw_view
								where Section_ID = 3) sub
						WHERE RowNum = 2) as con1
            on spec_main.Condo_Code = con1.Condo_Code4_1
			left join (	SELECT Condo_Code AS Condo_Code4_2,
								Image_URL as Image_URL_2
						FROM (SELECT Condo_Code
								, Image_URL
								, ROW_NUMBER() OVER (PARTITION BY Condo_Code ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
								FROM full_template_section_shortcut_raw_view
								where Section_ID = 4) sub
						WHERE RowNum = 1) as own_spec
			on spec_main.Condo_Code = own_spec.Condo_Code4_2
			order by Condo_Code) as spec
on main.Condo_Code = spec.Condo_Code4
order by Condo_Code;

-- เช็คนามสกุลรูปในบทความ
SELECT REVERSE(SUBSTRING_INDEX(REVERSE(meta_value), '.', 1)) AS last_word_after_dot
FROM `wp_postmeta`
WHERE `meta_key` LIKE '_yoast_wpseo_opengraph-image'
group by REVERSE(SUBSTRING_INDEX(REVERSE(meta_value), '.', 1));