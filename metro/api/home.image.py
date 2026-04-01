import math
import random
from typing import List, Dict, Any
import json
from db import get_db

conn = get_db()
cur = conn.cursor(dictionary=True)

# =====================================================================
# CORE ALGORITHM FUNCTIONS
# =====================================================================

def generate_dynamic_pattern(counts: Dict[str, int], chunk_size: int) -> List[str]:
    """
    MATHEMATICAL CORE: Generates a perfectly interleaved sequence using 
    Square Root Allocation and Urgency Scoring.
    
    INPUT:
        counts (dict): A dictionary mapping a key to its total inventory count.
                    e.g., {'project': 3500, 'product': 5000, 'professional': 100}
        chunk_size (int): The number of slots in the repeating pattern (e.g., 15)
        
    OUTPUT:
        list: A perfectly balanced array of strings representing the sequence.
            e.g., ['product', 'project', 'professional', 'product', ...]
    """
    weights = {}
    total_weight = 0.0

    # 1. Square Root Allocation
    # Dampens massive inventories (Products) and boosts rare ones (Professionals)
    for key, count in counts.items():
        if count > 0:
            weights[key] = math.sqrt(count)
            total_weight += weights[key]

    if total_weight == 0:
        return list(counts.keys())

    # 2. Base Allocations & Remainders
    allocations = {}
    remainders = []
    allocated_sum = 0

    for key, weight in weights.items():
        exact_share = chunk_size * (weight / total_weight)
        rounded_floor = math.floor(exact_share)
        
        allocations[key] = rounded_floor
        allocated_sum += rounded_floor
        remainders.append({"type": key, "rem": exact_share - rounded_floor})

    # 3. Distribute leftover slots to the highest remainders
    remainders.sort(key=lambda x: x["rem"], reverse=True)
    slots_needed = chunk_size - allocated_sum
    for i in range(slots_needed):
        allocations[remainders[i]["type"]] += 1

    # 4. Urgency Interleaving
    # Prevents items from clumping together by tracking which item is most "due"
    pattern = []
    current_allocs = allocations.copy()

    while len(pattern) < chunk_size:
        best_type = None
        max_urgency = -1.0
        
        for key, remaining in current_allocs.items():
            if remaining > 0:
                # Urgency = remaining slots to place / total slots originally granted
                urgency = remaining / allocations[key]
                if urgency > max_urgency:
                    max_urgency = urgency
                    best_type = key
                    
        pattern.append(best_type)
        current_allocs[best_type] -= 1

    return pattern


def interleave_categories(items: List[Dict[str, Any]], item_type: str) -> List[Dict[str, Any]]:
    """
    PHASE 1A (SUB-MIXER): Solves the "Tail Depletion Problem" for categories.
    Ensures that rare categories (like Museums) are stretched mathematically
    across the timeline of abundant categories (like Houses).
    
    INPUT:
        items (list): Raw list of dictionaries from the DB for a specific type.
        item_type (str): 'project', 'professional', or 'product'
        
    OUTPUT:
        list: The same items, sorted mathematically so categories don't clump.
            e.g., [Museum1, Mall1, Hotel1, Condo1, House1, House2, Museum2...]
    """
    order_map = CATEGORY_ORDER[item_type]
    
    # Group items by their specific category
    grouped = {cat: [] for cat in order_map}
    cat_counts = {cat: 0 for cat in order_map}
    
    for item in items:
        cat = item.get('category')
        if cat in grouped:
            grouped[cat].append(item)
            cat_counts[cat] += 1

    # Generate a category-specific chunk pattern 
    # Chunk size is strictly (number of categories * 3) to give the math room to breathe.
    cat_chunk_size = len(order_map) * 3
    category_pattern = generate_dynamic_pattern(cat_counts, cat_chunk_size)
    
    # Store the generated pattern for the printout
    GENERATED_PATTERNS[f"{item_type}_category"] = category_pattern
    
    interleaved = []
    pattern_index = 0
    items_remaining = len(items)

    # Pull items using the mathematical category pattern
    while items_remaining > 0:
        target_cat = category_pattern[pattern_index]
        item_added = False

        if grouped.get(target_cat) and len(grouped[target_cat]) > 0:
            interleaved.append(grouped[target_cat].pop(0))
            item_added = True
            items_remaining -= 1

        # Fallback: If a category runs dry before the others, 
        # pull the next most important available category.
        if not item_added:
            for fallback_cat in order_map:
                if grouped.get(fallback_cat) and len(grouped[fallback_cat]) > 0:
                    interleaved.append(grouped[fallback_cat].pop(0))
                    items_remaining -= 1
                    break
                    
        pattern_index = (pattern_index + 1) % len(category_pattern)
        
    return interleaved


def build_master_queue(items: List[Dict[str, Any]], item_type: str) -> List[Dict[str, Any]]:
    """
    PHASE 1B (ROUND-ROBIN): Takes the interleaved categories and flattens
    their photos. Pulls all Cover Photos (rank 0) first, then secondary photos, etc.
    
    INPUT:
        items (list): Raw list of dictionaries from DB.
        item_type (str): 'project', 'professional', or 'product'
        
    OUTPUT:
        list: A flattened 1D array of individual photos, perfectly prioritized.
    """
    # First, mix the items so buildings/products don't clump
    interleaved_items = interleave_categories(items, item_type)
    
    master_queue = []
    
    # Find the deepest photo array across all items
    max_photos = 0
    for item in items:
        for con in item.get('contributors', []):
            count = len(con.get('photos', []))
            if count > max_photos:
                max_photos = count

    # Loop horizontally across the items
    for photo_index in range(max_photos):
        for current_item in interleaved_items:
            # ดึงลิสต์ผู้ร่วมออกแบบทั้งหมดในโปรเจกต์นี้
            contributors = current_item.get('contributors', [])
            for con in contributors:
                photos = con.get('photos', [])
                
                # ถ้าคนนี้ (contributor) มีรูปในลำดับที่ photo_index ให้ดึงออกมา
                if photo_index < len(photos):
                    master_queue.append({
                        "type": item_type,
                        "category": current_item.get("category"),
                        "category_hierarchy": current_item.get("full_path"),
                        "item_title": current_item.get("title"),
                        "name": current_item.get("name"),
                        "sub_name": con.get("sub_name"), # ดึงชื่อคนที่เป็นเจ้าของรูปนั้นจริงๆ
                        "brief": current_item["brief"],
                        "logo": current_item["logo"],
                        "link": current_item["url"],
                        "all_cate": current_item["head_cate"],
                        "photo_data": photos[photo_index],
                        "photo_rank": photo_index 
                    })
                
    return master_queue


def generate_masonry_feed(project_items: List[Dict], prof_items: List[Dict], product_items: List[Dict], chunk_size: int = 15) -> List[Dict]:
    """
    PHASE 2 (FINAL MIXER): Weaves the three highly-organized Master Queues
    into the final infinite-scroll masonry feed.
    
    INPUT:
        project_items, prof_items, product_items: Raw data arrays from DB.
        chunk_size (int): The global repeating pattern length (default 15).
        
    OUTPUT:
        list: The finalized feed array (thousands of items long) ready for caching/frontend.
    """
    # 1. Build the perfectly sorted queues
    project_queue = build_master_queue(project_items, 'project')
    prof_queue = build_master_queue(prof_items, 'professional')
    product_queue = build_master_queue(product_items, 'product')

    # 2. Dynamically calculate the Main Feed pattern based on actual photo volumes
    dynamic_pattern = generate_dynamic_pattern({
        'project': len(project_queue),
        'professional': len(prof_queue),
        'product': len(product_queue)
    }, chunk_size)

    # Store the generated pattern for the printout
    GENERATED_PATTERNS['main_feed'] = dynamic_pattern

    final_feed = []
    pattern_index = 0

    # 3. Pull from the queues using the pattern until all are entirely empty
    while project_queue or prof_queue or product_queue:
        target_type = dynamic_pattern[pattern_index]
        photo_added = False

        # Attempt to pull from the assigned type queue
        if target_type == 'project' and project_queue:
            final_feed.append(project_queue.pop(0))
            photo_added = True
        elif target_type == 'product' and product_queue:
            final_feed.append(product_queue.pop(0))
            photo_added = True
        elif target_type == 'professional' and prof_queue:
            final_feed.append(prof_queue.pop(0))
            photo_added = True
            
        # Fallback: If the assigned queue ran completely out, 
        # seamlessly patch the hole with whatever queue has the most left.
        if not photo_added:
            if product_queue: final_feed.append(product_queue.pop(0))
            elif project_queue: final_feed.append(project_queue.pop(0))
            elif prof_queue: final_feed.append(prof_queue.pop(0))

        pattern_index = (patternIndex := pattern_index + 1) % len(dynamic_pattern)

    return final_feed


def create_image_group(state):
    if state == "proj":
        id_key = "Proj_ID"
        cat_key = "category"
        name_key = "Proj_Name"
        sub_name_key = 'prof_name'
        query = f"""WITH RECURSIVE CategoryHierarchy AS (
                        -- จุดเริ่มต้น: หาหมวดหมู่ที่สูงที่สุด (Parent_ID IS NULL)
                        SELECT 
                            ID, 
                            Category_Name, 
                            Parent_ID, 
                            CONCAT('PROJECT > ', upper(Category_Name)) as Full_Path,
                            1 as Depth
                        FROM proj_categories
                        WHERE Parent_ID IS NULL
                        and Categories_Status = '1'
                        UNION ALL
                        -- วิ่งไล่ลงไปหาลูกหลาน
                        SELECT 
                            child.ID, 
                            child.Category_Name, 
                            child.Parent_ID, 
                            CONCAT(parent.Full_Path, ' > ', upper(child.Category_Name)),
                            parent.Depth + 1
                        FROM proj_categories child
                        JOIN CategoryHierarchy parent ON child.Parent_ID = parent.ID
                    ),
                    CombinedImages AS (
                        -- [1] ก้อน Cover: ดึงทุกโปรเจกต์ที่มี Cover
                        SELECT 
                            ch.Full_Path,
                            a.Category_Name as category,
                            c.Proj_ID,
                            ifnull(cov2.Image_URL, cov1.Image_URL) as Image_URL,
                            b.Categories_Order as Parent_Order,
                            a.Categories_Order as Cat_Order,
                            0 as img_group_priority, -- กลุ่มที่ 1: cover ทั้งหมด
                            f.Expertise_Order as expertise_order,
                            CASE WHEN d.Content IS NULL OR d.Content = '' THEN 1 ELSE 0 END as has_content,
                            (SELECT h2.Name_EN 
                                FROM proj_prof_relationship d2
                                JOIN prof_expertise_relationship e2 ON d2.Prof_Expertise_Relationship_ID = e2.ID and e2.Relationship_Status = '1'
                                JOIN prof_expertise f2 ON e2.Expertise_ID = f2.ID and f2.Expertise_Status = '1'
                                JOIN professionals h2 ON e2.Prof_ID = h2.ID and h2.Prof_Status = '1'
                                WHERE d2.Proj_ID = c.Proj_ID 
                                AND d2.Relationship_Status = '1'
                                ORDER BY f2.Expertise_Order ASC, isnull(d2.Content), h2.Name_EN
                                LIMIT 1) as prof_name,
                            0 as internal_img_order,
                            proj.Name_EN as Proj_Name,
                            proj.Brief_Description,
                            null as Logo,
                            proj.Proj_URL_Tag as Link,
                            category_helper.All_Category_JSON as All_Category
                        FROM CategoryHierarchy ch
                        JOIN proj_categories a ON ch.ID = a.ID
                        JOIN proj_categories b ON a.Parent_ID = b.ID AND b.Categories_Status = '1'
                        JOIN proj_category_relationship c ON a.ID = c.Category_ID AND c.Relationship_Status = '1'
                        JOIN proj_prof_relationship d ON c.Proj_ID = d.Proj_ID AND d.Relationship_Status = '1'
                        JOIN prof_expertise_relationship e ON d.Prof_Expertise_Relationship_ID = e.ID AND e.Relationship_Status = '1'
                        JOIN prof_expertise f ON e.Expertise_ID = f.ID AND f.Expertise_Status = '1'
                        left JOIN proj_cover cov1 ON c.Proj_ID = cov1.Proj_ID AND cov1.Image_Status = '1' and cov1.Ratio_Type = '16:9'
                        left JOIN proj_cover cov2 ON c.Proj_ID = cov2.Proj_ID AND cov2.Image_Status = '1' and cov2.Ratio_Type = '9:16'
                        JOIN projects proj ON c.Proj_ID = proj.ID AND proj.Proj_Status = '1'
                        LEFT JOIN (SELECT 
                                        c.Proj_ID,
                                        CONCAT('[', 
                                            GROUP_CONCAT(DISTINCT '"', b.Category_Name, '"' SEPARATOR ','), 
                                            ',',
                                            GROUP_CONCAT(DISTINCT '"', a.Category_Name, '"' SEPARATOR ','),
                                        ']') as All_Category_JSON
                                    FROM proj_categories a
                                    JOIN proj_categories b ON a.Parent_ID = b.ID AND b.Categories_Status = '1'
                                    JOIN proj_category_relationship c ON a.ID = c.Category_ID AND c.Relationship_Status = '1'
                                    WHERE a.Categories_Status = '1'
                                    GROUP BY c.Proj_ID
                                ) category_helper ON c.Proj_ID = category_helper.Proj_ID
                        WHERE a.Categories_Status = '1'
                        UNION ALL
                        -- [2] ก้อน Gallery: ดึงทุกโปรเจกต์ที่มี Gallery
                        SELECT 
                            ch.Full_Path,
                            a.Category_Name as category,
                            c.Proj_ID,
                            REPLACE(g.Image_URL, '1440', '800') as Image_URL,
                            b.Categories_Order as Parent_Order,
                            a.Categories_Order as Cat_Order,
                            1 as img_group_priority, -- กลุ่มที่ 1: Gallery ทั้งหมด (ต่อท้าย Cover)
                            f.Expertise_Order as expertise_order,
                            CASE WHEN d.Content IS NULL OR d.Content = '' THEN 1 ELSE 0 END as has_content,
                            h.Name_EN as prof_name,
                            g.Image_Order as internal_img_order,
                            proj.Name_EN as Proj_Name,
                            proj.Brief_Description,
                            null as Logo,
                            proj.Proj_URL_Tag as Link,
                            category_helper.All_Category_JSON as All_Category
                        FROM CategoryHierarchy ch
                        JOIN proj_categories a ON ch.ID = a.ID
                        JOIN proj_categories b ON a.Parent_ID = b.ID AND b.Categories_Status = '1'
                        JOIN proj_category_relationship c ON a.ID = c.Category_ID AND c.Relationship_Status = '1'
                        JOIN proj_prof_relationship d ON c.Proj_ID = d.Proj_ID AND d.Relationship_Status = '1'
                        JOIN prof_expertise_relationship e ON d.Prof_Expertise_Relationship_ID = e.ID AND e.Relationship_Status = '1'
                        JOIN prof_expertise f ON e.Expertise_ID = f.ID AND f.Expertise_Status = '1'
                        JOIN proj_gallery g ON d.ID = g.Proj_Profs_Relationship_ID AND g.Image_Status = '1'
                        JOIN professionals h ON e.Prof_ID = h.ID AND h.Prof_Status = '1'
                        JOIN projects proj ON c.Proj_ID = proj.ID AND proj.Proj_Status = '1'
                        LEFT JOIN (SELECT 
                                        c.Proj_ID,
                                        CONCAT('[', 
                                            GROUP_CONCAT(DISTINCT '"', b.Category_Name, '"' SEPARATOR ','), 
                                            ',',
                                            GROUP_CONCAT(DISTINCT '"', a.Category_Name, '"' SEPARATOR ','),
                                        ']') as All_Category_JSON
                                    FROM proj_categories a
                                    JOIN proj_categories b ON a.Parent_ID = b.ID AND b.Categories_Status = '1'
                                    JOIN proj_category_relationship c ON a.ID = c.Category_ID AND c.Relationship_Status = '1'
                                    WHERE a.Categories_Status = '1'
                                    GROUP BY c.Proj_ID
                                ) category_helper ON c.Proj_ID = category_helper.Proj_ID
                        WHERE a.Categories_Status = '1'
                    ),
                    RankedData AS (
                        -- [3] คัดหมวดหมู่ที่ซ้ำออก (เลือกหมวดหมู่ลำดับดีที่สุดสำหรับรูปนั้นๆ)
                        SELECT *,
                            ROW_NUMBER() OVER (
                                PARTITION BY img_group_priority, Image_URL, Proj_ID -- แยก Rank ระหว่าง Cover/Gallery
                                ORDER BY Parent_Order, Cat_Order -- เรียง cat ไหนมาก่อน
                            ) as category_rank,
                            COUNT(*) OVER (PARTITION BY Proj_ID) as photo_count_per_proj
                        FROM CombinedImages
                    )
                    -- [4] จัดเรียงแบบยกแผง
                    SELECT Full_Path, category, Proj_ID, Image_URL, img_group_priority, Proj_Name, prof_name, Brief_Description, Logo, Link
                        , All_Category
                    FROM RankedData
                    WHERE category_rank = 1 and Image_URL is not null
                    ORDER BY 
                        img_group_priority, -- สำคัญสุด: 0 (Cover ทุกตัว) จะมาก่อน 1 (Gallery ทุกตัว)
                        Parent_Order,       -- เรียงตามหมวดหมู่ใหญ่
                        Cat_Order,          -- เรียงตามหมวดหมู่เล็ก
                        photo_count_per_proj DESC, -- หัวใจสำคัญ: ใครรูปเยอะสุดในหมวดหมู่ ขึ้นก่อน
                        expertise_order,    -- ลำดับเฉพาะของ Gallery
                        has_content,
                        prof_name,
                        internal_img_order"""
    elif state == "prof":
        id_key = "Prof_ID"
        cat_key = "expertise"
        name_key = "prof_name"
        sub_name_key = 'experience_category'
        query = f"""WITH RECURSIVE CategoryHierarchy AS (
                        -- จุดเริ่มต้น: หาหมวดหมู่ที่สูงที่สุด (Parent_ID IS NULL)
                        SELECT 
                            ID, 
                            Responsibility, 
                            Parent_ID, 
                            CONCAT('PROFESSIONAL > ', upper(Responsibility)) as Full_Path,
                            1 as Depth
                        FROM prof_expertise
                        WHERE Expertise_Status = '1'
                        UNION ALL
                        -- วิ่งไล่ลงไปหาลูกหลาน
                        SELECT 
                            child.ID, 
                            child.Responsibility, 
                            child.Parent_ID, 
                            CONCAT(parent.Full_Path, ' > ', upper(child.Responsibility)),
                            parent.Depth + 1
                        FROM prof_expertise child
                        JOIN CategoryHierarchy parent ON child.Parent_ID = parent.ID
                    ), 
                    CombinedImages AS (
                        -- [1] ก้อน Cover
                        SELECT
                            ch.Full_Path,
                            a.Responsibility as expertise,
                            c.Prof_ID,
                            ifnull(cov2.Image_URL, cov1.Image_URL) as Image_URL,
                            a.Expertise_Order as Expertise_Order,
                            0 as img_group_priority, -- กลุ่มที่ 0: Cover ทั้งหมด
                            h.Name_EN as prof_name,
                            cate.Category as experience_category,
                            0 as internal_img_order,
                            null as Brief_Description,
                            h.Logo_URL as Logo,
                            h.Prof_URL_Tag as Link,
                            expertise_helper.All_Category_JSON as All_Category
                        FROM CategoryHierarchy ch
                        JOIN prof_expertise a on ch.ID = a.ID
                        JOIN prof_expertise_relationship c ON a.ID = c.Expertise_ID AND c.Relationship_Status = '1'
                        left JOIN prof_cover cov1 ON c.Prof_ID = cov1.Prof_ID AND cov1.Image_Status = '1' and cov1.Ratio_Type = '16:9' and cov1.Image_URL like '%{1920}%'
                        left JOIN prof_cover cov2 ON c.Prof_ID = cov2.Prof_ID AND cov2.Image_Status = '1' and cov2.Ratio_Type = '9:16'
                        JOIN professionals h ON c.Prof_ID = h.ID AND h.Prof_Status = '1'
                        join prof_url pf_url on h.ID = pf_url.Prof_ID and pf_url.Url_Status = 1
                        LEFT JOIN (
                            select Prof_ID
                                , CONCAT_WS(', ', MAX(CASE WHEN row_num = 1 THEN UPPER(Category_Name) END), MAX(CASE WHEN row_num = 2 THEN UPPER(Category_Name) END)) AS Category
                            from (
                                SELECT
                                    b.Prof_ID,
                                    c.Category_ID,
                                    d.Category_Name,
                                    COUNT(DISTINCT ra.Proj_ID) as Count_Proj,
                                    ROW_NUMBER() OVER (PARTITION BY b.Prof_ID ORDER BY COUNT(DISTINCT ra.Proj_ID) DESC) as row_num 
                                FROM proj_prof_relationship ra
                                JOIN prof_expertise_relationship b ON ra.Prof_Expertise_Relationship_ID = b.ID AND b.Relationship_Status = '1'
                                JOIN proj_category_relationship c ON ra.Proj_ID = c.Proj_ID AND c.Relationship_Status = '1'
                                join proj_categories d on c.Category_ID = d.ID and d.Categories_Status = '1'
                                WHERE ra.Relationship_Status = '1'
                                GROUP BY b.Prof_ID, c.Category_ID) aaa
                            WHERE row_num <= 2
                            group by Prof_ID
                        ) cate ON c.Prof_ID = cate.Prof_ID
                        LEFT JOIN (SELECT 
                                        c.Prof_ID,
                                        CONCAT('[', group_concat(DISTINCT '"', a.Responsibility, '"' SEPARATOR ','), ']') as All_Category_JSON
                                    FROM prof_expertise a
                                    JOIN prof_expertise_relationship c ON a.ID = c.Expertise_ID AND c.Relationship_Status = '1'
                                    where a.Expertise_Status = '1'
                                    group by c.Prof_ID
                                ) expertise_helper 
                        ON c.Prof_ID = expertise_helper.Prof_ID                     
                        WHERE a.Expertise_Status = '1' 
                        UNION ALL
                        -- [2] ก้อน Gallery
                        SELECT
                            ch.Full_Path,
                            a.Responsibility as expertise,
                            c.Prof_ID,
                            REPLACE(gal.Image_URL, '1440', '800') as Image_URL,
                            a.Expertise_Order as Expertise_Order,
                            1 as img_group_priority, -- กลุ่มที่ 1: Gallery ทั้งหมด (ต่อท้าย Cover)
                            h.Name_EN as prof_name,
                            cate.Category as experience_category,
                            gal.Image_Order as internal_img_order,
                            null as Brief_Description,
                            h.Logo_URL as Logo,
                            h.Prof_URL_Tag as Link,
                            expertise_helper.All_Category_JSON as All_Category
                        FROM CategoryHierarchy ch
                        JOIN prof_expertise a on ch.ID = a.ID
                        JOIN prof_expertise_relationship c ON a.ID = c.Expertise_ID AND c.Relationship_Status = '1'
                        JOIN prof_gallery gal ON c.Prof_ID = gal.Prof_ID AND gal.Image_Status = '1'
                        JOIN professionals h ON c.Prof_ID = h.ID AND h.Prof_Status = '1'
                        join prof_url pf_url on h.ID = pf_url.Prof_ID and pf_url.Url_Status = 1
                        LEFT JOIN (
                            select Prof_ID
                                , CONCAT_WS(', ', MAX(CASE WHEN row_num = 1 THEN UPPER(Category_Name) END), MAX(CASE WHEN row_num = 2 THEN UPPER(Category_Name) END)) AS Category
                            from (
                                SELECT
                                    b.Prof_ID,
                                    c.Category_ID,
                                    d.Category_Name,
                                    COUNT(DISTINCT ra.Proj_ID) as Count_Proj,
                                    ROW_NUMBER() OVER (PARTITION BY b.Prof_ID ORDER BY COUNT(DISTINCT ra.Proj_ID) DESC) as row_num 
                                FROM proj_prof_relationship ra
                                JOIN prof_expertise_relationship b ON ra.Prof_Expertise_Relationship_ID = b.ID AND b.Relationship_Status = '1'
                                JOIN proj_category_relationship c ON ra.Proj_ID = c.Proj_ID AND c.Relationship_Status = '1'
                                join proj_categories d on c.Category_ID = d.ID and d.Categories_Status = '1'
                                WHERE ra.Relationship_Status = '1'
                                GROUP BY b.Prof_ID, c.Category_ID) aaa
                            WHERE row_num <= 2
                            group by Prof_ID
                        ) cate ON c.Prof_ID = cate.Prof_ID
                        LEFT JOIN (SELECT 
                                        c.Prof_ID,
                                        CONCAT('[', group_concat(DISTINCT '"', a.Responsibility, '"' SEPARATOR ','), ']') as All_Category_JSON
                                    FROM prof_expertise a
                                    JOIN prof_expertise_relationship c ON a.ID = c.Expertise_ID AND c.Relationship_Status = '1'
                                    where a.Expertise_Status = '1'
                                    group by c.Prof_ID
                                ) expertise_helper 
                        ON c.Prof_ID = expertise_helper.Prof_ID     
                        WHERE a.Expertise_Status = '1'
                    ),
                    RankedData AS (
                        -- [3] คัดหมวดหมู่ที่ซ้ำออก (เลือกหมวดหมู่ลำดับดีที่สุดสำหรับรูปนั้นๆ)
                        SELECT *,
                            ROW_NUMBER() OVER (
                                PARTITION BY img_group_priority, Image_URL, Prof_ID -- แยก Rank ระหว่าง Cover/Gallery
                                ORDER BY Expertise_Order
                            ) as category_rank,
                            COUNT(*) OVER (PARTITION BY Prof_ID) as photo_count_per_prof
                        FROM CombinedImages
                    )
                    -- [4] จัดเรียงแบบยกแผง
                    SELECT Full_Path, expertise, Prof_ID, Image_URL, img_group_priority, prof_name, experience_category, Brief_Description, Logo, Link
                        , All_Category
                    FROM RankedData
                    WHERE category_rank = 1 and Image_URL is not null
                    ORDER BY 
                        img_group_priority, -- สำคัญสุด: 0 (Cover ทุกตัว) จะมาก่อน 1 (Gallery ทุกตัว)
                        Expertise_Order,       -- เรียงตามหมวดหมู่ใหญ่
                        photo_count_per_prof DESC, -- หัวใจสำคัญ: ใครรูปเยอะสุดในหมวดหมู่ ขึ้นก่อน
                        prof_name,
                        internal_img_order"""
    elif state == "prod":
        pass
    
    cur.execute(query)
    rows = cur.fetchall()
    # 1. ใช้ dict ชุดเดียวเพื่อรันเลข Title (MUSEUM 1, 2, 3...)
    cat_counters = {} 

    # 2. Key ในการเช็คโปรเจกต์ซ้ำให้ใช้แค่ ID เท่านั้น
    # เพื่อให้รูปจาก Cover และ Gallery วิ่งเข้าไปที่ Object เดียวกัน
    project_map = {} 

    # 3. สร้าง List เพื่อเก็บลำดับการเรียงให้เหมือน SQL (เพราะ dict ปกติอาจไม่รักษาลำดับ)
    ordered_projects = []

    for row in rows:
        p_id = row[id_key]
        cat = row[cat_key]
        name = row[name_key]
        sub_name = row[sub_name_key]
        
        path_parts = [p.strip() for p in row['Full_Path'].split('>')]
        hierarchy_dict = {f"l{i}": p_name for i, p_name in enumerate(path_parts, 1)}
        hierarchy_json_str = json.dumps(hierarchy_dict, ensure_ascii=False)
        
        if p_id not in project_map:
            # ถ้านี่คือครั้งแรกที่เจอ Project นี้ (ไม่ว่าจะเจอจาก Cover หรือ Gallery ก่อน)
            cat_counters[cat] = cat_counters.get(cat, 0) + 1
            
            project_obj = {
                "category": cat,
                "title": f"{cat.upper()} {cat_counters[cat]}",
                "name": name,
                "brief": row["Brief_Description"],
                "logo": row["Logo"],
                "url": row["Link"],
                "full_path": hierarchy_json_str,
                "head_cate": row["All_Category"],
                "contributors": []
            }
            
            project_map[p_id] = project_obj
            ordered_projects.append(project_obj)
        
        contributor = next((item for item in project_map[p_id]['contributors'] if item["sub_name"] == sub_name), None)
        if not contributor:
            # ถ้ายังไม่มีกลุ่มของคนนี้ ให้สร้างใหม่
            contributor = {
                "sub_name": sub_name,
                "photos": []
            }
            project_map[p_id]['contributors'].append(contributor)
        
        # เพิ่มรูปภาพเข้าไปใน photos (ไม่ว่าจะเป็นรูปจาก Cover หรือ Gallery)
        # เนื่องจาก SQL เรียง img_group_priority (0=Cover) มาก่อนอยู่แล้ว 
        # รูป Cover จะไปอยู่ที่ photos[0] โดยอัตโนมัติ
        if row['Image_URL']:
            contributor['photos'].append(row['Image_URL'])
    
    unique_categories = []
    seen_cat = set()

    for proj in ordered_projects:
        cat_name = proj['category']
        if cat_name not in seen_cat:
            unique_categories.append(cat_name)
            seen_cat.add(cat_name)

    return ordered_projects, unique_categories

# =====================================================================
# CONFIGURATION
# Defines the strict hierarchy of importance for each main type.
# =====================================================================
# Global dictionary to store generated patterns for debugging and visibility
GENERATED_PATTERNS = {}

# =====================================================================
# DEVELOPMENT / TESTING BLOCK
# Developer can run `python metropolis_algorithm.py` to see the output.
# =====================================================================
if __name__ == "__main__":
    print("Generating mock data...")
    #products = make_mocks('product', [
    #    {'cat': 'furniture', 'count': 300}, {'cat': 'electronics', 'count': 120}, {'cat': 'kitchen appliances', 'count': 80}
    #], 10, 10)
    
    projects, proj_cat = create_image_group("proj")
    profs, prof_cat = create_image_group("prof")
    products, prod_cat = [], []
    
    CATEGORY_ORDER = {
        'project': proj_cat,
        'professional': prof_cat,
        'product': []
    }

    print(f"Data generated. Projects: {len(projects)}, Profs: {len(profs)}, Products: {len(products)}")
    print("Running Mixing Algorithm...")
    
    # Run the core function
    master_feed = generate_masonry_feed(projects, profs, products, chunk_size=15)
    
    print(f"Successfully generated feed of {len(master_feed)} total photos!")

    print("\n--- CALCULATED CHUNK PATTERNS ---")
    print(f"1. Main Feed Type Pattern   : {GENERATED_PATTERNS.get('main_feed')}")
    print(f"2. Project Category Pattern : {GENERATED_PATTERNS.get('project_category')}")
    print(f"3. Prof. Category Pattern   : {GENERATED_PATTERNS.get('professional_category')}")
    print(f"4. Product Category Pattern : {GENERATED_PATTERNS.get('product_category')}")
    
    data_list = []
    for i, image in enumerate(master_feed):
        image_type = image["type"].upper()
        image_category = image["category"].upper()
        image_category_path = image["category_hierarchy"]
        image_name = image["name"]
        image_sub_name = image["sub_name"]
        image_logo = image["logo"]
        image_brief = image["brief"]
        image_path = image["photo_data"]
        url = image["link"]
        all_cate = image["all_cate"]
        image_order = i + 1
        data_list.append((image_type, image_category, image_category_path, image_name, image_sub_name, image_logo
                        , image_brief, image_path, image_order, url, all_cate))
    
    try:
        cur.execute("truncate home_image")
        cur.executemany(f"""insert into home_image (Card_Type, Category, Category_Hierarchy, Card_Name, Card_Sub_Name
                        , Card_Logo, Brief_Description, Image_URL, Image_Order, Card_Url, Last_Updated_Date
                        , All_Category)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP, %s)""", data_list)
        conn.commit()
    except Exception as e:
        print(f"Error inserting data: {e}")
    finally:
        cur.close()
        conn.close()
print("Data inserted successfully!")