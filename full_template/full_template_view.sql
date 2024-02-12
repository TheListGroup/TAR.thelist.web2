-- source_full_template_element_image_view
	-- รูปทุกรูปในทุก section ทุก element
CREATE OR REPLACE VIEW source_full_template_element_image_view AS 
select 
    fte.Condo_Code AS Condo_Code,
    fts.Section_ID AS Section_ID,
    fts.Section_Name AS Section,
    fts.Section_Status AS Section_Status,
    ftset.Set_ID AS Set_ID,
    ftset.Set_Name AS Set_Name,
    ftset.Display_Order_in_Condo AS Set_Order,
    ftset.Set_Status AS Set_Status,
    CAST( if(ftset.Set_ID is not null,(select JSON_ARRAYAGG(JSON_OBJECT('Unit_Type_ID', ftu.Unit_Type_ID, 'Unit_Type_Name', ftu.Unit_Type_Name, 'Room_Type_ID', ftu.Room_Type_ID, 'Unit_Type_Image', ftu.Unit_Type_Image, 'BathRoom', ftu.BathRoom,'Unit_Floor_Type_ID', ftu.Unit_Floor_Type_ID, 'MaidRoom', ftu.MaidRoom, 'Size', ftu.Size)) from full_template_set_unit_type_relationship as fre left join full_template_unit_type as ftu on fre.Unit_Type_ID = ftu.Unit_Type_ID where ftset.Set_ID = fre.Set_ID and (ftu.Unit_Type_Status is null or ftu.Unit_Type_Status <> 2)),null) AS JSON) AS Unit_Type,
    fte.Element_ID AS Element_ID,
    fte.Element_Name AS Element,
	fte.Long_Text AS Long_Text,
    fte.Display_Order_in_Section AS Display_Order_in_Section,
    fte.Element_Status AS Element_Status,
    ftc.Category_ID AS Category_ID,
    ftc.Category_Name AS Category,
    ftc.Category_Status AS Category_Status,
    JSON_ARRAYAGG(JSON_OBJECT('Image_ID', fti.Image_ID, 'Image_Caption', fti.Image_Caption, 'Image_URL',fti.Image_URL ,'Date_Taken',fti.Date_Taken, 'Display_Order_in_Element', fti.Display_Order_in_Element, 'Element_ID',fti.Element_ID, 'Image_Type_ID',fti.Image_Type_ID)) AS Image
from full_template_element AS fte
inner join full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
inner join full_template_section as fts on ftc.Section_ID = fts.Section_ID
left join full_template_set as ftset on fte.Set_ID = ftset.Set_ID
inner join full_template_image as fti on fte.Element_ID = fti.Element_ID
where fte.Element_Status = 1
and ftc.Category_Status = 1
and fts.Section_Status = 1
and fti.Image_Status = 1
and (ftset.Set_Status is null or ftset.Set_Status = 1)
group by fte.Condo_Code,fts.Section_ID,ftset.Set_ID,fte.Element_ID,ftc.Category_ID
ORDER BY fte.Condo_Code,fts.Section_ID,ftset.Display_Order_in_Condo,fte.Display_Order_in_Section,ftc.Category_Order;

-- credit_view
	-- credit_logo, credit_url ในทุกโครงการ
	-- sort ตาม Condo_Code, Credit_Order
CREATE OR REPLACE VIEW source_full_template_credit_view AS 
SELECT
	ftcu.condo_code AS Condo_Code,
    ftc.Credit_ID AS Credit_ID,
    ftc.Credit_Name AS Credit,
    ftcu.ID AS Credit_url_ID,
    ftcu.Credit_URL AS Credit_URL,
    ftc.Credit_Logo AS Credit_Logo,
    ftcu.Credit_Order AS Credit_Order
from full_template_credit as ftc
inner join full_template_credit_url_condo as ftcu on ftc.Credit_ID = ftcu.Credit_ID
where ftc.Credit_Status = 1
and ftcu.Credit_Status = 1
order by ftcu.Condo_Code,ftcu.Credit_Order;

-- view ใช้ทำเรื่อง icon (รวมทุก element ที่อยู่ใน section facility)
	-- sort ตาม Condo_Code, Category_Order, Display_Order_in_Section, Display_Order_in_Element
CREATE OR REPLACE VIEW full_template_facilities_raw_view AS
select fte.Condo_Code
	,	 ftc.Category_Order
	,    ftc.Category_ID
	,    ftc.Category_Name
	,    ftc.Category_Icon
	,	fte.Display_Order_in_Section
	,	fte.Element_ID
	,	fte.Element_Name
	,	fti.Display_Order_in_Element
	,	fti.Image_Id
	,	fti.Image_URL
	,   fti.Image_Status
	from full_template_element AS fte
		inner join full_template_category AS ftc on fte.Category_ID = ftc.Category_ID
		inner join full_template_section as fts on ftc.Section_ID = fts.Section_ID
		left join full_template_image as fti on fte.Element_ID = fti.Element_ID
	where fts.Section_ID = 5
	and fte.Element_Status = 1
	and ftc.Category_Status = 1
	ORDER BY Condo_Code, ftc.Category_Order, fte.Display_Order_in_Section, fti.Display_Order_in_Element;

-- source_full_template_facilities_icon_view
	-- facility ไหนโชว์รูป ไหนโชว์ text
CREATE OR REPLACE VIEW source_full_template_facilities_icon_view AS
SELECT 	Condo_Code
	,	Category_Order
	,	Category_ID
	,	Category_Name
	,	Category_Icon
	,	Image_URL
	,	Category_Text
FROM	(SELECT  Condo_Code
			,	 Category_Order
			,	 Category_ID
			,	 Category_Name
			,	 Category_Icon
		FROM	 full_template_facilities_raw_view
		GROUP BY Condo_Code, Category_ID
		ORDER BY Condo_Code, Category_Order) AS main
		LEFT JOIN 
			(	SELECT Condo_Code AS Condo_Code2,
								Category_ID as Category_ID2,
				Image_URL as Image_URL
				FROM (SELECT Condo_Code
						, Category_ID
						, Image_URL
						, ROW_NUMBER() OVER (PARTITION BY Condo_Code,Category_ID ORDER BY Display_Order_in_Section, Display_Order_in_Element) AS RowNum
						FROM full_template_facilities_raw_view
						where Image_Status = 1) sub
				WHERE RowNum = 1
			) AS sub_image
			ON	main.Condo_Code = sub_image.Condo_Code2
			AND main.Category_ID = sub_image.Category_ID2
		LEFT JOIN
		-- ทุก text ของทุก element ในแต่ละ category
			(	SELECT   Condo_Code		AS Condo_Code3
					,   Category_ID	AS Category_ID3
					,   JSON_ARRAYAGG(JSON_OBJECT('text' , Element_Name, 'Order', Display_Order_in_Section)) AS Category_Text
				FROM   full_template_facilities_raw_view
				WHERE 	 Image_ID IS NULL
				GROUP BY Condo_Code3, Category_ID3
			) AS sub_text
			ON	main.Condo_Code = sub_text.Condo_Code3
			AND main.Category_ID = sub_text.Category_ID3
-- sort ตาม Condo_Code, Category_Order
ORDER BY Condo_Code, Category_Order;